public class CaseEmailRelatedListControllerLex {
@AuraEnabled(cacheable=true)
    public static List<EmailMessage> getAllEmailMessage(String recordID){
        List<String> isOutOrInBoundRtLst= new List<String>{'Outbound_Email_Support','Inbound_Email_Support'};
        Map<Id,RecordType> idByRecordTypeMap=new Map<Id,RecordType>([SELECT ID,DeveloperName from RecordType WHERE DeveloperName=:isOutOrInBoundRtLst]);
        System.debug('>>>idByRecordTypeMap>>>'+idByRecordTypeMap);
        Id outboundCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Outbound_Email_Support').getRecordTypeId();
        Id inboundCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Inbound_Email_Support').getRecordTypeId();
       List<EmailMessage> emailMsgLst;
        //RT- 474 Custom Email Related List should hide emails from System
        Set<Id> allUserIdSet = new Set<Id>();
        for(EmailMessage emailobj : [SELECT CreatedById 
                                            FROM EmailMessage 
                                            WHERE ParentId =:recordID]){
            allUserIdSet.add(emailobj.CreatedById);
        }
        //To store only the user who are not System user.
        Set<Id> notSystemUserId = new Set<Id>();
        for(User objUser : [SELECT Id 
                                FROM User 
                                WHERE Name != 'System' AND Id=:allUserIdSet]){
            notSystemUserId.add(objUser.Id);
        }
        emailMsgLst = [SELECT Id, ParentId, Status, ToAddress , HasAttachment , CreatedDate,MessageDate, Subject, FromName, FromAddress, TextBody, HtmlBody 
                    FROM EmailMessage 
                    WHERE ParentId =:recordID 
                        AND ((CreatedById =:notSystemUserId AND Incoming = false) 
                            OR Incoming = true) 
                        AND (NOT Subject_Indexed__c LIKE 'Automatic Reply%') 
                        ORDER BY MessageDate DESC];
        system.debug('The value'+emailMsgLst);
        return emailMsgLst;
    }

}