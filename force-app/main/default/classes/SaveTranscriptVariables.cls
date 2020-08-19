public with sharing class SaveTranscriptVariables {

    public class Input {
        @InvocableVariable(required=true)
        public Id routableId;
        
        @InvocableVariable(required=false)
        public String subject;
        
        @InvocableVariable(required=true)
        public String email;
        
        @InvocableVariable(required=false)
        public String productArea;
    }
    
    public class Output {
        @InvocableVariable(required=true)
        public Id chatQueue;
    }

    @InvocableMethod(label='Save Chat User Details')
    public static List<Output> saveChatDetails(List<Input> inputs) {

        Input input = inputs[0];
        Id pgiClientId;
        Id pgiCompanyId;
        
        try {
            PGi_Client__c pgiClient = [SELECT Id, PGi_Company__c FROM PGi_Client__c WHERE Client_Email__c = :input.email LIMIT 1];
            pgiClientId = pgiClient.Id;
            pgiCompanyId = pgiClient.PGi_Company__c;
        }
        catch (Exception e) {
            pgiClientId = null;
            pgiCompanyId = null;
        }

        LiveChatTranscript transcriptRecord = [SELECT Id, Location_Region__c FROM LiveChatTranscript WHERE Id = :input.routableId];
        
        transcriptRecord.Email_Address__c = input.email;
        transcriptRecord.Subject__c = input.subject;
        transcriptRecord.PGi_Client__c = pgiClientId;
        transcriptRecord.PGi_Company__c = pgiCompanyId;
        transcriptRecord.Query_Topic__c = (input.productArea != null ? input.productArea : 'Sales');
        update transcriptRecord;
        
        Output output = new Output();
        switch on transcriptRecord.Query_Topic__c {
            when 'Web or Audio Meetings' {
                output.chatQueue = [SELECT Id FROM Group WHERE DeveloperName = 'Chat_GlobalMeet_Web_and_Audio'].Id;
            }
            when 'Operator Assisted Events' {
                output.chatQueue = [SELECT Id FROM Group WHERE DeveloperName = 'Chat_Operator_Assisted_Support'].Id;
            }
            when 'Business Phone Systems' {
                output.chatQueue = [SELECT Id FROM Group WHERE DeveloperName = 'Chat_GM_Voice_Support'].Id;
            }
            when 'Billing' {
                if (transcriptRecord.Location_Region__c == 'Unknown' || transcriptRecord.Location_Region__c == 'NA') {
                    output.chatQueue = [SELECT Id FROM Group WHERE DeveloperName = 'Chat_Billing_US'].Id;
                }
                else {
                    output.chatQueue = [SELECT Id FROM Group WHERE DeveloperName = 'Chat_Billing_INTL'].Id;
                }
            }
            when 'Sales' {
                output.chatQueue = [SELECT Id FROM Group WHERE DeveloperName = 'Chat_Sales'].Id;
            }
        }
        
        List<Output> returnWrapper = new List<Output>();
        returnWrapper.add(output);
        return returnWrapper;
    }
}