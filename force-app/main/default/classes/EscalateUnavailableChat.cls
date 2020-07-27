public with sharing class EscalateUnavailableChat {

    public class Input {
        @InvocableVariable(required=true)
        public Id routableId;
    }
    
    public class Output {
        @InvocableVariable(required=false)
        public String ticketNumber;
    }

    @InvocableMethod(label='Escalate No Agent Chat')
    public static List<Output> escalateChat(List<Input> inputs) {

        Input input = inputs[0];
    
        LiveChatTranscript currentChatTranscript = [SELECT Id, ContactId, PGi_Client__c, Email_Address__c, Name__c, PGi_Company__c, Subject__c, Location_Region__c, Query_Topic__c FROM LiveChatTranscript WHERE Id = :input.routableId];
        
        Output output = new Output();
        
        switch on currentChatTranscript.Query_Topic__c {
            when 'Web or Audio Meetings', 'Unknown' {
                Case newCase = new Case(
                    Origin = 'Chat', 
                    RecordTypeId = [SELECT Id FROM RecordType WHERE name LIKE '%Inbound Email Support%' and SobjectType = 'Case' LIMIT 1].Id,
                    OwnerId = [SELECT Id FROM Group WHERE DeveloperName = 'PGi_Email_GL_Tier_1'].Id,
                    ContactId = currentChatTranscript.ContactId,
                    SLA_in_Minutes__c = 120,
                    PGi_Client__c = currentChatTranscript.PGi_Client__c,
                    PGi_Company__c = currentChatTranscript.PGi_Company__c,
                    SuppliedName = currentChatTranscript.Name__c,
                    SuppliedEmail = currentChatTranscript.Email_Address__c,
                    Subject = currentChatTranscript.Subject__c
                );
                
                INSERT newCase;
                currentChatTranscript.CaseId = newCase.Id;
                UPDATE currentChatTranscript;
                output.ticketNumber = 'Case# ' + [SELECT CaseNumber From Case WHERE Id = :newCase.Id].CaseNumber;
            }
            when 'Operator Assisted Events' {
                Case newCase = new Case(
                    Origin = 'Email - GL - RES - CallBack Email - PGiBrand',
                    RecordTypeId = [SELECT Id FROM RecordType WHERE name LIKE '%Inbound Email Support%' and SobjectType = 'Case' LIMIT 1].Id,
                    OwnerId = [SELECT Id FROM Group WHERE DeveloperName = 'PGi_Email_GL_Attended'].Id,
                    ContactId = currentChatTranscript.ContactId,
                    SLA_in_Minutes__c = 120,
                    PGi_Client__c = currentChatTranscript.PGi_Client__c,
                    PGi_Company__c = currentChatTranscript.PGi_Company__c,
                    SuppliedName = currentChatTranscript.Name__c,
                    SuppliedEmail = currentChatTranscript.Email_Address__c,
                    Subject = currentChatTranscript.Subject__c
                );
                
                INSERT newCase;
                currentChatTranscript.CaseId = newCase.Id;
                UPDATE currentChatTranscript;
                output.ticketNumber = 'Case# ' + [SELECT CaseNumber From Case WHERE Id = :newCase.Id].CaseNumber;
            }
            when 'Business Phone Systems' {
                Case newCase = new Case(
                    Origin = 'Chat',
                    RecordTypeId = [SELECT Id FROM RecordType WHERE name LIKE '%Inbound Email Support%' and SobjectType = 'Case' LIMIT 1].Id,
                    OwnerId = [SELECT Id FROM Group WHERE DeveloperName = 'PGi_Email_GL_Tier_1'].Id,
                    ContactId = currentChatTranscript.ContactId,
                    SLA_in_Minutes__c = 120,
                    PGi_Client__c = currentChatTranscript.PGi_Client__c,
                    PGi_Company__c = currentChatTranscript.PGi_Company__c,
                    SuppliedName = currentChatTranscript.Name__c,
                    SuppliedEmail = currentChatTranscript.Email_Address__c,
                    Subject = currentChatTranscript.Subject__c
                );
                
                INSERT newCase;
                currentChatTranscript.CaseId = newCase.Id;
                UPDATE currentChatTranscript;
                output.ticketNumber = 'Case# ' + [SELECT CaseNumber From Case WHERE Id = :newCase.Id].CaseNumber;
            }
            when 'Billing' {
                Financial_Request__c newFinReq = new Financial_Request__c(
                    Origin__c = 'Chat', 
                    RecordTypeId = [SELECT Id FROM RecordType WHERE name LIKE '%Billing Support%' and SobjectType = 'Financial_Request__c' LIMIT 1].Id,
                    Region__c = (currentChatTranscript.Location_Region__c != 'Unknown' ? currentChatTranscript.Location_Region__c : 'NA'),
                    PGi_Client__c = currentChatTranscript.PGi_Client__c,
                    PGi_Company__c = currentChatTranscript.PGi_Company__c,
                    SuppliedEmail__c = currentChatTranscript.Email_Address__c,
                    Requested_For__c = currentChatTranscript.Email_Address__c,
                    RequestorsEmail__c = currentChatTranscript.Email_Address__c,
                    Subject__c = currentChatTranscript.Subject__c
                );
                
                INSERT newFinReq;
                currentChatTranscript.Financial_Request__c = newFinReq.Id;
                UPDATE currentChatTranscript;
                output.ticketNumber = [SELECT Name From Financial_Request__c WHERE Id = :newFinReq.Id].Name;
            }
            when 'Sales' {
                Case newCase = new Case(
                    Origin = 'Chat', 
                    RecordTypeId = [SELECT Id FROM RecordType WHERE name LIKE '%Inbound Email Support%' and SobjectType = 'Case' LIMIT 1].Id,
                    OwnerId = [SELECT Id FROM Group WHERE DeveloperName = 'PGi_Email_GL_Tier_1'].Id,
                    ContactId = currentChatTranscript.ContactId,
                    SLA_in_Minutes__c = 120,
                    PGi_Client__c = currentChatTranscript.PGi_Client__c,
                    PGi_Company__c = currentChatTranscript.PGi_Company__c,
                    SuppliedName = currentChatTranscript.Name__c,
                    SuppliedEmail = currentChatTranscript.Email_Address__c,
                    Subject = currentChatTranscript.Subject__c
                );
                
                INSERT newCase;
                currentChatTranscript.CaseId = newCase.Id;
                UPDATE currentChatTranscript;
                output.ticketNumber = 'Case# ' + [SELECT CaseNumber From Case WHERE Id = :newCase.Id].CaseNumber;
            }
        }
        
        List<Output> returnWrapper = new List<Output>();
        returnWrapper.add(output);
    
        return returnWrapper;
    }
}