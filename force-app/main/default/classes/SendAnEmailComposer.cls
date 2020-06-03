public with sharing class SendAnEmailComposer {
    @AuraEnabled(cacheable=true)
    public static List<OrgWideEmailAddress> getFromAdress(){
      List<OrgWideEmailAddress>  orgWideEmailList = [SELECT Id, Address, DisplayName 
                                                    FROM OrgWideEmailAddress 
                                                    ORDER BY DisplayName ASC];
      List<Email_SLA_Management__c> emailSLAList = new List<Email_SLA_Management__c>(
                                                    [SELECT Id, Origin__c, Email_Template__c, From_Address__c, Default_Queue__c 
                                                    FROM Email_SLA_Management__c 
                                                    WHERE From_Address__c != null 
                                                    ORDER BY From_Address__c]);
        Map<String, String> fromAddressByDisplayName = new Map<String,String>();
        List<OrgWideEmailAddress> orgWideSLAWrapperList = new List<OrgWideEmailAddress>();
        for(Email_SLA_Management__c sla: emailSLAList) {
            for(OrgWideEmailAddress owea: orgWideEmailList) {
                if(owea.Address == sla.From_Address__c) {
                    // OrgWideSLAWrapper wrapObject = new OrgWideSLAWrapper();
                    // wrapObject.displayName = owea.DisplayName;
                    // wrapObject.slaId = sla.Id;
                    // fromAddressByDisplayName.put(owea.DisplayName, sla.From_Address__c);
                    orgWideSLAWrapperList.add(owea);
                }       
            }
        }
        return orgWideSLAWrapperList;
    }
    @AuraEnabled(cacheable=true)
    public static Email_SLA_Management__c getEmailSLA(String emailAddress){
        return [SELECT Id, Origin__c, Email_Template__c, From_Address__c, Default_Queue__c 
                                                    FROM Email_SLA_Management__c 
                                                    WHERE From_Address__c =: emailAddress];
    }
    @AuraEnabled(cacheable=true)
    public static EmailTemplate generatePreview(String templateName, String recId ) {
        EmailTemplate emailTemplate = [SELECT Id, Name  
                                        FROM EmailTemplate 
                                        WHERE DeveloperName =: templateName LIMIT 1];
        Contact contactRec = [SELECT Id FROM Contact WHERE email <> null LIMIT 1];
        if(emailTemplate != null && emailTemplate.Id != null) {
           
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.SingleEmailMessage tempEmail = new Messaging.SingleEmailMessage();
            tempEmail.setUseSignature(false);
            tempEmail.setSaveAsActivity(false);
            tempEmail.setSenderDisplayName('No Replay');
            tempEmail.setTemplateId(emailTemplate.Id);
            tempEmail.setWhatId(recId);
            tempEmail.setTargetObjectId(contactRec.Id);
            // Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {tempEmail});
           
            // Database.rollback(sp);
            emailTemplate.HtmlValue = tempEmail.getHtmlBody();
            emailTemplate.Subject = tempEmail.getSubject();
        }
        return emailTemplate;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<EmailTemplate> getTemplates(String folderId){
        system.debug('===>'+folderId);
        String soql = 'Select Id, Name, DeveloperName FROM EmailTemplate WHERE FolderId =: folderId ORDER BY Name';
        soql = soql + ' LIMIT 1000';
        System.debug(soql);
        return database.query(soql); 
    }
    @AuraEnabled(cacheable=true)
    public static List<Folder> getEmailFolders(){
        return [SELECT ID, Name 
                FROM Folder 
                WHERE Type = 'Email' ORDER BY Name];
    }
    @AuraEnabled(cacheable=true)
    public static string sendAnMail(){
        Messaging.SingleEmailMessage singleEmailMsg = new Messaging.SingleEmailMessage();
        singleEmailMsg.setWhatId();
        singleEmailMsg.setSaveAsActivity(true);
        singleEmailMsg.setUseSignature(false);
        singleEmailMsg.setOrgWideEmailAddressId(slaFromToOrgWideEmail.get(fromAddress));
        //TODO -  INVALID_MESSAGE_ID_REFERENCE, References header is not valid singleEmailMsg.setReferences('<' + currentCase.ID + '>');
        List<Messaging.SendEmailResult> results =  Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {singleEmailMsg});  
        
    }
    public class OrgWideSLAWrapper{
        public String displayName;
        public String slaId;
    }
}
