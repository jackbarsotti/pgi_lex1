public class CaseEmailRelatedListControllerLex {
@AuraEnabled(cacheable=true)
    public static List<EmailMessage> getAllEmailMessage(String recordID){
        List<String> isOutOrInBoundRtLst= new List<String>{'Outbound_Email_Support','Inbound_Email_Support'};
        Map<Id,RecordType> idByRecordTypeMap=new Map<Id,RecordType>([SELECT ID,DeveloperName from RecordType WHERE DeveloperName=:isOutOrInBoundRtLst]);
        System.debug('>>>idByRecordTypeMap>>>'+idByRecordTypeMap);
        Id outboundCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Outbound_Email_Support').getRecordTypeId();
        Id inboundCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Inbound_Email_Support').getRecordTypeId();
       List<EmailMessage> emailMsgLst;
        System.debug('The id'+recordID);
        emailMsgLst = [SELECT Id, ParentId, Status, ToAddress , HasAttachment , CreatedDate,MessageDate, Subject, FromName, FromAddress, TextBody, HtmlBody 
                    FROM EmailMessage 
                    WHERE ParentId =:recordID 
                        ORDER BY MessageDate DESC];
        system.debug('The value'+emailMsgLst);
        return emailMsgLst;
    }

}