public class EmailMessageTriggerHandler extends TriggerHandler {
    public EmailMessageTriggerHandler() {
        super('EmailMessageTriggerHandler');
    }
    
    /* 

4. First_Response_Time__c (the time the first email is sent to the customer from an agent)
-Date Time field set by trigger
5. First_Response_SLA__c (would capture the "SLA Time Remaining" value when the "First Response Time" is populated)
Numeric - value in minutes
*/
    
    protected override void beforeInsert(){
        // Dev -Anup : commeneted because this logic is handled in updateCaseStatus()
        //updateCase(); 
        
        // Nick RT-294
        // timestamp the First_Response_Time__c
        //RT-462 Subject – Indexed
        setSlaTime(); 
        setSubjectIndexed();
        
    }
    protected override void beforeUpdate(){
        //RT-462 Subject – Indexed
        setSubjectIndexed();
        setAverageSlaTimeInMinutes();
    }
    protected override void afterInsert(){
        // Dev -Anup : commeneted because this logic is handled in updateCaseStatus()
        //updateCase(); 
        
        // Nick RT-294
        // timestamp the First_Response_Time__c
        setFirstReplyTime();
        setAverageSlaTimeInMinutes();
        setCaseFirstResponseTime();
    }
    protected override void afterUpdate(){
        updateCase();        
    }
    protected override void beforeDelete(){
        validationOnEmailMessageDelete();        
    }
    
    private static final Id SYSTEM_USER_ID = [SELECT Id,Name FROM User WHERE Name = 'System'].Id; 
    
    public static List<String> orgWideEmailList {get {
        if(orgWideEmailList == null) {
            orgWideEmailList = new List<String>();
            for(OrgWideEmailAddress owea: [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress ORDER BY DisplayName ASC]) {
                orgWideEmailList.add(owea.Address);
            }
        }
        return orgWideEmailList;
    }set;}
    
    //RT-462 Subject – Indexed 
    private void setSubjectIndexed() {
        for(EmailMessage em : (List<EmailMessage>)Trigger.new) {
            if(String.isNotBlank(em.Subject)) {
                if(em.Subject.length() > 255) {
                    em.Subject_Indexed__c = em.Subject.left(255);
                } else {
                    em.Subject_Indexed__c = em.Subject;
                }
            }
            
        } 
    }
    
    private void setFirstReplyTime() {
        Set<Id> emailParentIdSet = new Set<Id>();
        List<Case> updateCases = new List<Case>();
        for(EmailMessage em : (List<EmailMessage>)Trigger.new) {
            emailParentIdSet.add(em.ParentId);
        }
        for(case caseObj :[Select Id,First_Reply_Time__c,(Select Id,SLA_Time_Capture__c From EmailMessages LIMIT 1)from case WHERE Id=:emailParentIdSet]){
            Integer count = 0;
            for(EmailMessage em: caseObj.EmailMessages) {
                count++;
                break;
            }
            if(count == 0 || caseObj.First_Reply_Time__c == null) {
                datetime currentTime = datetime.now();
                caseObj.First_Reply_Time__c=currentTime.format('HH:mm');
                updateCases.add(caseObj);
            }
        }
        if(!updateCases.isEmpty()) {
            update updateCases;
        }
    }
    private void setAverageSlaTimeInMinutes() {
        Set<Id> emailParentIdSet = new Set<Id>();
        // List<Case> updateCases = new List<Case>();
        List<Case> caseToUpdate = new List<Case>();
        Map<Id,List<EmailMessage>> caseEmailMap = new Map<Id,List<EmailMessage>>();
        for(EmailMessage em : (List<EmailMessage>)Trigger.new) {
            emailParentIdSet.add(em.ParentId);
        } 
        for(case caseObj :[SELECT Id, Average_SLA_In_Minutes__c, Total_Reply_Time__c, IsUpdateFromCaseComment__c,
                           (SELECT Id,SLA_Time_Capture__c, Reply_Time__c FROM EmailMessages WHERE Incoming = false AND CreatedById !=: SYSTEM_USER_ID AND SLA_Time_Capture__c != '')
                           FROM case
                           WHERE Id=:emailParentIdSet]){
                               Decimal caseTotal = 0;
                               Decimal numOfEmails = 0;
                               Decimal replyTime = 0;
                               if(caseObj.EmailMessages.size() > 0) {
                                   for(EmailMessage em: caseObj.EmailMessages) {
                                       if(String.isNotBlank(em.SLA_Time_Capture__c)) {
                                           Decimal sizeofEmaillst = caseObj.EmailMessages.size();
                                           Decimal sumOfSla = 0;
                                           
                                           for(EmailMessage emailMessageObj :caseObj.EmailMessages){
                                               if(String.isNotBlank(emailMessageObj.SLA_Time_Capture__c)) {
                                                   String slaString =emailMessageObj.SLA_Time_Capture__c.replace(':', '.');
                                                   if(slaString.length() > 1){
                                                       sumOfSla = sumOfSla + Decimal.valueOf(slaString.trim());
                                                   }
                                                   
                                               }
                                           }
                                           if(em.Reply_Time__c != null) {
                                            replyTime += em.Reply_Time__c;
                                        }
                                           Decimal averageSla =sumOfSla/sizeofEmaillst;
                                           String averageSlaStr =String.valueOf(averageSla.setScale(2));
                                           String strAvgSlaTime=averageSlaStr.replace('.', ':');
                                           List<String> avgSlaSplitList=strAvgSlaTime.split(':');
                                           Boolean isNegativeValue =strAvgSlaTime.contains('-');
                                           decimal hrsInInMin;
                                           if(avgSlaSplitList.size() > 0){
                                               hrsInInMin= (Decimal.valueOf(avgSlaSplitList[0].removeStart('-'))*60) + Decimal.valueOf(avgSlaSplitList[1]);
                                           }
                                           String hrsinmStr= String.valueOf(hrsInInMin);
                                           if(isNegativeValue){
                                               hrsinmStr ='-'+hrsinmStr;
                                           }
                                           caseTotal += Decimal.valueOf(hrsinmStr);
                                           numOfEmails ++;
                                       }
                                   }
                                   if(numOfEmails > 0) {
                                       caseObj.Average_SLA_In_Minutes__c = caseTotal / numOfEmails; 
                                       caseObj.Total_Reply_Time__c = replyTime / 1000 / 60;
                                       caseObj.IsUpdateFromCaseComment__c = !caseObj.IsUpdateFromCaseComment__c;
                                       caseToUpdate.add(caseObj);
                                   }
                               }
                           }
        if(!caseToUpdate.isEmpty()) {
            update caseToUpdate;
        }
    }
    // Added by Vijay 
    // RT-407:  When the user sends an outbound email we should capture Case SLA_Time_Remaining2__c time and Populated on Email Message Field SLA_Time_Capture__c
    // Date: 21/01/2020
    
    private void setSlaTime() {
        if(UserInfo.getUserName() == null || UserInfo.getUserName().contains('automatedcase')) {
            return;
        }
        Set<Id> emailParentIdSet = new Set<Id>();
        for(EmailMessage em : (List<EmailMessage>)Trigger.new) {
            emailParentIdSet.add(em.ParentId);
        } 
        Map<Id,Case> caseMap = new Map<Id,Case>([SELECT Id,IsClosed,SLA_In_Minutes__c, SLA_Time_Remaining2__c, SLA_Time_to_Complete__c, RecordTypeId from Case WHERE Id IN: emailParentIdSet]);
        for(EmailMessage em : (List<EmailMessage>)Trigger.new) { 
            if(!caseMap.isEmpty() && caseMap.containsKey(em.ParentId) && !em.Incoming){
                em.SLA_Time_Capture__c = caseMap.get(em.ParentId).SLA_Time_Remaining2__c;
                if(caseMap.get(em.ParentId).SLA_Time_to_Complete__c != null && caseMap.get(em.ParentId).SLA_In_Minutes__c != null) {
                    //We changed the condition bebause whenever inbond or outbound Cases are created Sla_in_Minutes is Added to case
                    //as well as sla_Time_to_Complete+minutes so if we substract that minutes from Sla_Time_To_complete then we will get the time when sla is set;                 
                    //em.Reply_Time__c =System.now().getTime() - caseMap.get(em.ParentId).SLA_Time_to_Complete__c.getTime()  ;
                    //Since case is already there Sla_time to Complete Will always be lesser that Now() so we Get the remaining.
                    em.Reply_Time__c = System.now().getTime() - caseMap.get(em.ParentId).SLA_Time_to_Complete__c.addMinutes(- Integer.valueOf(caseMap.get(em.ParentId).SLA_In_Minutes__c)).getTime();
                }
            }           
        } 
    }
    private void setCaseFirstResponseTime() {
        Set<Id> caseIds = new set<Id>();
        List<Case> updateCases = new List<Case>();
        Set<Id> createdByIds = new Set<Id>();
        for(EmailMessage em : (List<EmailMessage>)Trigger.new) {
            Id emParentId = em.ParentId;
            createdByIds.add(em.CreatedById);
        }
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN: createdByIDs]);
        for(EmailMessage em : (List<EmailMessage>)Trigger.new) {
            Id emParentId = em.ParentId;
            if(userMap.get(em.createdById) != null && userMap.get(em.createdById).Name != 'System' &&
               String.ValueOf(emParentId.getsobjecttype()) == 'Case' && 
               orgWideEmailList.contains(em.FromAddress)) {
                   caseIds.add(em.ParentId);
               }
        }
        
        if(!caseIds.isEmpty()){
            for(Case thisCase : [SELECT Id, SLA_Time_Remaining2__c, First_Response_Time__c, SLA_Time_to_Complete__c
                                 FROM Case 
                                 WHERE Id IN : caseIds]) {
                                     System.debug('Testing');
                                     if(thisCase.First_Response_Time__c == null && thisCase.SLA_Time_to_Complete__c != null) {
                                         thisCase.First_Response_SLA__c = thisCase.SLA_Time_Remaining2__c;
                                         thisCase.First_Response_Time__c = System.now();
                                     }
                                     thisCase.Most_Recent_SLA_Start__c = null;
                                     thisCase.SLA_Time_To_Complete__c = null;
                                     updateCases.add(thisCase);
                                 }
        }
        
        if(!updateCases.isEmpty()) {
            TriggerHandler.bypass('CaseTriggerHandler');
            update updateCases;
            TriggerHandler.clearBypass('CaseTriggerHandler');
        }
    }
    
    private void updateCase(){        
        Set<Id> caseIds = new set<Id>();
        List<Case> upCase = new List<Case>();
        for(EmailMessage em: (List<EmailMessage>)Trigger.New){
            Id sampleid = em.ParentId;
            if(String.ValueOf(sampleid.getsobjecttype()) == 'Case'){
                caseIds.add(em.ParentId);
            }
        }
        
        if(!caseIds.isEmpty()){
            for(Case cse:[Select Id,IsUpdateFromCaseComment__c from Case Where Id IN : caseIds]){
                if(cse.IsUpdateFromCaseComment__c){
                    cse.IsUpdateFromCaseComment__c = false;
                }else{
                    cse.IsUpdateFromCaseComment__c = true;
                }
                upCase.add(cse);
            }
        }
        if(!upCase.isEmpty()){
            update upCase;
        }
    }

    private static Profile profile {get {
        return PGI_Utility.profile;
    } set; }
    
    private void validationOnEmailMessageDelete(){
        
        for(EmailMessage e: (List<EmailMessage>)Trigger.old) {
            if(String.valueOf(e.ParentId).startsWith('500') && !profile.Name.equals('System Administrator')){
                e.adderror('You dont have the Permission to Delete this message');
            }
        }
    }
    // private void setTotalReplyTime() {
    //     List<Case> caseToUpdate = new List<Case>();
    //     Id outboundCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Outbound Email Support').getRecordTypeId();
    //     Id InboundCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound Email Support').getRecordTypeId();
    //     Set<Id> emailParentIdSet = new Set<Id>(); 
    //     Set<Id> recordTypeIds = new Set<Id>{outboundCaseRTId,InboundCaseRTId};
        
    //     for(EmailMessage em : (List<EmailMessage>)Trigger.new) {
    //         emailParentIdSet.add(em.ParentId);
    //     }
    //     for(Case objCase :[SELECT Id,Total_Reply_Time__c, (SELECT Id, Reply_Time__c FROM EmailMessages)
    //                         FROM case 
    //                         WHERE Id =:emailParentIdSet 
    //                      AND RecordTypeId =:recordTypeIds
    //                      FOR UPDATE]) {
    //         Integer replyTimeInMs = 0;
    //         for(EmailMessage em: EmailMessages) {
    //             if(em.Reply_Time__c != null) {
    //                 replyTimeInMs += em.Reply_Time__c;
    //             }
    //         }
    //         objCase.Total_Reply_Time__c = Integer.valueOf(replyTimeInMs/60000);
    //         caseToUpdate.add(objCase);
    //     }  
    //     if(!caseToUpdate.isEmpty()){
    //         UPDATE caseToUpdate;
    //     }
    // }

    
}