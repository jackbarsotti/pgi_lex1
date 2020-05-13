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
        //Vijay RT-510
        setTotalReplyTime();
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
        for(case caseObj :[Select Id,First_Reply_Time__c,(Select Id,SLA_Time_Capture__c From EmailMessages)from case WHERE Id=:emailParentIdSet]){
            if(caseObj.EmailMessages.size() == 0 || caseObj.First_Reply_Time__c == null )
            {
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
                                       caseObj.Total_Reply_Time__c = replyTime / 1000 / 60 / 60;
                                       caseObj.IsUpdateFromCaseComment__c = !caseObj.IsUpdateFromCaseComment__c;
                                       caseToUpdate.add(caseObj);
                                   }
                               }
                           }
        if(!caseToUpdate.isEmpty()) {
            update caseToUpdate;
        }
        
        
        
        
        //     Set<Decimal> slaInNumber =new Set<Decimal>();
        //    for(EmailMessage emailMessageObj :[Select Id,ParentId,SLA_Time_Capture__c From EmailMessage WHERE ParentId IN: emailParentIdSet]){
        //             if(emailMessageObj.SLA_Time_Capture__c != null)
        //             {  
        //                 if(!caseEmailMap.containskey(emailMessageObj.ParentId))
        //                 {
        //                   caseEmailMap.put(emailMessageObj.ParentId, new List<EmailMessage>{ emailMessageObj });
        //                 }else{
        //                     caseEmailMap.get(emailMessageObj.ParentId).add(emailMessageObj);
        //                 }   
        //             }
        //     } 
        //     for(Case caseObj: [SELECT Id,Average_SLA_Time__c from Case Where Id IN: caseEmailMap.keySet()]){
        //         Decimal sumOfSla = 0;
        //         List<EmailMessage> emailMessageList = caseEmailMap.get(caseObj.Id);
        //         for(EmailMessage emailMessageObj : emailMessageList){
        //             String slaString =emailMessageObj.SLA_Time_Capture__c.replace(':', '.');
        //             if(slaString.length() > 1){
        //             sumOfSla = sumOfSla + Decimal.valueOf(slaString.trim());
        //             }
        //         }
        //         Decimal averageSla =sumOfSla/emailMessageList.size();
        //         String averageSlaStr =String.valueOf(averageSla.setScale(2));
        //         caseObj.Average_SLA_Time__c = averageSlaStr.replace('.', ':');
        //         updateCases.add(caseObj);
        //     }
        //     if(!updateCases.isEmpty()) {
        //         update updateCases;
        //     }
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
    //commented for testcode coverage
    /* private void updateCaseStatus(){
List<Case> caseUpdateList = new List<Case>();
Map<Id, EmailMessage> emailMessageById = (Map<Id, EmailMessage>)Trigger.newMap;
Map<Id,Case> caseById = new Map<Id, Case>([SELECT ID, Status, LastModifiedDate, IsClosed, IsUpdateFromCaseComment__c
FROM Case 
WHERE Id IN (SELECT ParentId 
FROM EmailMessage 
WHERE ID =: emailMessageById.keySet())]);
for(EmailMessage objEM : emailMessageById.values()) {
if(caseById.containsKey(objEM.ParentId)){
Case objCase = caseById.get(objEM.ParentId);
if(objEM.Incoming = true ){
if(getTimeafterClose(objCase) <= 48 && objCase.isClosed){
objCase.Status = 'Customer Replied';
}else if(!objCase.isClosed && objCase.Status != 'New'){
objCase.Status = 'Customer Replied';
}
}
// code from updateCase()
Boolean isTrue = objCase.IsUpdateFromCaseComment__c;
objCase.IsUpdateFromCaseComment__c = isTrue ? false : true;
caseUpdateList.add(objCase);
}
}
Database.update(caseUpdateList, false);
}
private long getTimeafterClose(Case objCase){
Long convertedHour = 0;
Long miliseconds =  objCase.LastModifiedDate.getTime() - System.now().getTime(); //ServerTime.getTime();
if(miliseconds > 1000){
Long convertedSec = miliseconds/ 1000;
if(convertedSec > 60){
Long convertedMin = convertedSec / 60;
if(convertedMin > 60)
convertedHour = convertedMin / 60 ;
}
}
return convertedHour;

}*/
    
    
    
    
    
    
    
    
    
    
    /*
protected override void beforeInsert(){
//assignEmailToOldCase();
}

private String extractMainSubject(String emailSubject)
{
if(emailSubject == null || emailSubject.length() < 3)
return emailSubject;
String[] prefixes = new String[] {'re: sandbox: re:','fw:','re:', 'automatic reply:', 'out of office autoreply:', 'out of office', 'fwd:'};  
String target = emailSubject.toLowerCase();
for(String prefix: prefixes) {
Integer index = target.indexOf(prefix); 
if(index == 0 ){
String mainSubject = emailSubject.substring(prefix.length(),emailSubject.length());
return mainSubject.trim();
}  
}
return emailSubject;     
}

//private void emailToCaseFindParentCase(){

//    List<Case> caseUpdateList = new List<Case>();
//    Map<Id, EmailMessage> emailMessageById = (Map<Id, EmailMessage>)Trigger.newMap;
//    Map<Id, Case> caseById = new Map<Id, Case>([SELECT ID, Subject, RequestorsEmail__c, Status, LastModifiedDate, CreatedDate, IsClosed,
//                        (SELECT ID FROM EmailMessages)
//                        FROM Case 
//                        WHERE Id IN (SELECT ParentId FROM EmailMessage WHERE ID =: Trigger.newMap.keySet() )]);

//    // {
//    //     // if(objCase.EmailMessages.Size() > 1){
//    //     //     caseUpdateList
//    //     // }
//    // }
//}


private void emailONError(String strMessage){

Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
String[] toAddresses = new String[] {'anup@cloudfastener.com'};
mail.setToAddresses(toAddresses);
mail.setReplyTo('support@acme.com');
mail.setSenderDisplayName('Salesforce Support');
mail.setSubject('Salesforce Email Error');
mail.setBccSender(false);
mail.setUseSignature(false);
mail.setPlainTextBody('Your Case: '+ strMessage);
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
}

private void assignEmailToOldCase(){
Map<String, EmailMessage> emailMessageBySubject = new Map<String,  EmailMessage>();
List<Case> upCase = new List<Case>();
for(EmailMessage em: (List<EmailMessage>)Trigger.New){
String emailSubject = em.Subject;       
emailMessageBySubject.put(emailSubject, em);
emailMessageBySubject.put(extractMainSubject(emailSubject), em);
}
Map<Id,Case> caseUpdateById = new Map<Id, Case>();

Map<Id, Case> caseById = new Map<Id, Case>([SELECT ID, Subject, RequestorsEmail__c, Status, LastModifiedDate, CreatedDate, IsClosed, parentId 
FROM Case 
WHERE Id IN (SELECT ParentId FROM EmailMessage WHERE Subject =: EmailMessageBySubject.keySet()) ]);

Map<Id, EmailMessage> emailMessageByCaseID = new Map<Id, EmailMessage>();
for(EmailMessage objEmail : [SELECT Id, ParentId, HtmlBody, Headers, Subject, FromName, FromAddress, ToAddress, CcAddress, BccAddress 
FROM EmailMessage 
WHERE Subject =: EmailMessageBySubject.keySet()  ORDER BY CreatedDate DESC])
{
//emailONError('inside of email ');
EmailMessage em = EmailMessageBySubject.get(objEmail.Subject); // new Email 
List<String> EmailsList = new List<String>(); //  if we got replay mail from cc.
if(String.isNotBlank(objEmail.CcAddress)){
EmailsList.addALL(objEmail.CcAddress.toLowerCase().split(';'));
}
if(String.isNotBlank(objEmail.BccAddress)){
EmailsList.addALL(objEmail.BccAddress.toLowerCase().split(';'));
}
if(String.isNotBlank(objEmail.FromAddress)){
EmailsList.add(objEmail.FromAddress.toLowerCase());
}
emailONError('inside of email '+EmailsList.size());
if(EmailsList.contains(em.FromAddress.toLowerCase()) && em.ParentId != objEmail.ParentId){
emailONError('inside of email if');
Case objParentCase = caseById.get(objEmail.ParentId);
Case newEmailCase = caseById.get(em.ParentId);
Long miliseconds =  objParentCase.LastModifiedDate.getTime() - objParentCase.CreatedDate.getTime(); //ServerTime.getTime();
Long convertedSec = miliseconds/ 1000;
Long convertedMin = convertedSec / 60;
Long convertedHour = convertedMin / 60 ;

if(objParentCase.IsClosed && convertedHour <= 48 ){  // checking case has been closed in less then 48 hrs

updateCaseFields(caseUpdateById, objParentCase, newEmailCase);
emailONError(String.valueOf(caseUpdateById.size()));

}else{ 
// Checking case is not closed.
updateCaseFields(caseUpdateById, objParentCase, newEmailCase);
emailONError(String.valueOf(caseUpdateById.size()));

} 
// TODO: deactivate the workflow.
}
}

TriggerHandler.bypass('CaseTriggerHandler');
if(!caseUpdateById.isEmpty()){
UPDATE caseUpdateById.values();
}
TriggerHandler.clearBypass('CaseTriggerHandler');
}
private void updateCaseFields(Map<Id,Case> caseUpdateById, Case objParentCase, Case newEmailCase){
// check parentCase has a parent Case
if(objParentCase.parentId != null){
if(objParentCase.Status != 'New'){
if(!caseUpdateById.containsKey(objParentCase.parentId)){
caseUpdateById.put(objParentCase.parentId, new Case(Id =objParentCase.parentId));
}
caseUpdateById.get(objParentCase.parentId).Status = 'Customer Replied';
}
if(!caseUpdateById.containsKey(newEmailCase.id)){
caseUpdateById.put(newEmailCase.id, new Case(Id = newEmailCase.id));
}
caseUpdateById.get(newEmailCase.parentId).parentId = objParentCase.parentId;

}else{
if(objParentCase.Status != 'New'){
if(!caseUpdateById.containsKey(objParentCase.Id)){
caseUpdateById.put(objParentCase.Id, new Case(Id = objParentCase.Id));
}
caseUpdateById.get(objParentCase.Id).Status = 'Customer Replied';
}
if(!caseUpdateById.containsKey(newEmailCase.parentId)){
caseUpdateById.put(newEmailCase.Id, new Case(Id = newEmailCase.Id));
}
caseUpdateById.get(newEmailCase.Id).parentId = objParentCase.Id;
}
//return caseUpdateById;
}
*/
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
    private void setTotalReplyTime() {
        List<Case> caseToUpdate = new List<Case>();
        Id outboundCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Outbound Email Support').getRecordTypeId();
         Id InboundCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound Email Support').getRecordTypeId();
        Set<Id> emailParentIdSet = new Set<Id>(); 
        Set<Id> recordTypeIds = new Set<Id>{outboundCaseRTId,InboundCaseRTId};
        Map<Id,EmailMessage> emailToReplyTimeMap = new Map<Id,EmailMessage>();
       for(EmailMessage em : (List<EmailMessage>)Trigger.new) {
           emailParentIdSet.add(em.ParentId);
           emailToReplyTimeMap.put(em.ParentId,em);
         }
      for(Case objCase :[SELECT Id,Total_Reply_Time__c 
                            FROM case 
                            WHERE Id =:emailParentIdSet 
                         AND RecordTypeId =:recordTypeIds]) {
                             if(emailToReplyTimeMap.keySet() != null &&  emailToReplyTimeMap.get(objCase.Id).Reply_Time__c !=Null ) {
                                 if(objCase.Total_Reply_Time__c == null){
                                //    objCase.Total_Reply_Time__c =  Integer.valueOf(emailToReplyTimeMap.get(objCase.Id).Reply_Time__c/60000);
                                 caseToUpdate.add(objCase);
                                 }
                                 else{
                                     Integer replyTimeInMin = Integer.valueOf(emailToReplyTimeMap.get(objCase.Id).Reply_Time__c/60000);
                                    //  objCase.Total_Reply_Time__c = objCase.Total_Reply_Time__c + replyTimeInMin; 
                                     caseToUpdate.add(objCase);
                                 }
                             }
                         }  
        if(!caseToUpdate.isEmpty()){
            UPDATE caseToUpdate;
        }
    }
    
     //Vijay RT-510 capture total replay time.
     /*private void setTotalReplyTime() {
         
         Set<Id> emailParentIdSet = new Set<Id>();
         List<Case> caseToUpdateLst = new List<Case>();
         for(EmailMessage em : (List<EmailMessage>)Trigger.new) {
             emailParentIdSet.add(em.ParentId);
         }
         for(Case objCase :[SELECT Id, First_Response_Time__c,Total_Reply_Time__c 
                            FROM case 
                            WHERE Id =:emailParentIdSet 
                            AND RecordTypeId =:recordTypeIds]) {
                                 if(objCase.First_Response_Time__c != null ){
                                     System.debug('The Now >>>>>>>>>>>>>>>>>>'+System.now());
                                     System.debug('The First_Response_Time__c'+objCase.First_Response_Time__c);
                                     Integer min1 = System.now().minute();
                                     Integer min2 = objCase.First_Response_Time__c.minute();
                                     Integer minutesDifference;
                                     if(min1 >=min2){
                                         minutesDifference = min1 -min2; 
                                     }
                                     else{
                                         minutesDifference = min2 -min1;
                                     }
                                     System.debug('Minutes Difference'+minutesDifference);
                                     Long dt1Long = objCase.First_Response_Time__c.getTime();
                                     Long dt2Long = System.now().getTime();
                                     Long milliseconds = dt2Long - dt1Long;
                                     Long seconds = milliseconds / 1000;
                                     Long minutes = seconds / 60;
                                     Long hours = minutes / 60;
                                     Long days = hours / 24;
                                    System.debug('The Total_Reply_Time__c'+objCase.Total_Reply_Time__c);
                                    System.debug('The minutes'+minutesDifference);
                                     System.debug('The minutes'+minutes);
                                    System.debug('The days between'+days);
                                     System.debug('The days hours'+hours);
                                    //Set minutes now no t set Because doubt
                                        objCase.Total_Reply_Time__c = 0;
                                     
                                     caseToUpdateLst.add(objCase);
                                 }
                            }
         if(!caseToUpdateLst.isEmpty()){
             UPDATE caseToUpdateLst;
         }            
     }*/
    
}