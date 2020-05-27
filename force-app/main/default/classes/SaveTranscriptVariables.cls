public with sharing class SaveTranscriptVariables {

    public class Input {
        @InvocableVariable(required=true)
        public Id routableId;
        
        @InvocableVariable(required=false)
        public String subject;
        
        @InvocableVariable(required=false)
        public String email;
        
        @InvocableVariable(required=false)
        public String productArea;

        @InvocableVariable(required=false)
        public String companyName;
    }
    
    public class Output {
        @InvocableVariable(required=true)
        public Id chatQueue;
    }

    @InvocableMethod(label='Save Chat User Details')
    public static List<Output> saveChatDetails(List<Input> inputs) {

        Input input = inputs[0];

        LiveChatTranscript transcriptRecord = [SELECT Id, Location_Region__c, Referring_Webpage__c FROM LiveChatTranscript WHERE Id = :input.routableId];
        
        transcriptRecord.Email_Address__c = input.email;
        transcriptRecord.Subject__c = input.subject;
        transcriptRecord.Query_Topic__c = (input.productArea != null ? input.productArea : 'Unknown');
        transcriptRecord.Company_Name__c = input.companyName;
        update transcriptRecord;
        
        Output output = new Output();
        
        switch on transcriptRecord.Query_Topic__c {
            when 'Web or Audio Meetings', 'Unknown' {
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
                String domain = transcriptRecord.Referring_Webpage__c.split('/')[2];

                if(domain == 'www.pgi.com' || domain == 'www.pgi.ca') {
                    output.chatQueue = [SELECT Id FROM Group WHERE DeveloperName = 'Chat_Sales_NA'].Id;
                }
                else if(domain == 'uk.pgi.com' || domain == 'ie.pgi.com') {
                    output.chatQueue = [SELECT Id FROM Group WHERE DeveloperName = 'Chat_Sales_EMEA'].Id;
                }
                else if(domain == 'in.pgi.com') {
                    output.chatQueue = [SELECT Id FROM Group WHERE DeveloperName = 'Chat_Sales_APAC'].Id;
                }
                else {
                    output.chatQueue = [SELECT Id FROM Group WHERE DeveloperName = 'Chat_Sales_NA'].Id;
                }
            }
        }
        
        List<Output> returnWrapper = new List<Output>();
        returnWrapper.add(output);
        return returnWrapper;
    }
}