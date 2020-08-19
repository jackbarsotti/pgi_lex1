@isTest
private class SaveTranscriptVariablesTest {

    static testMethod void saveVariablesMethod(){
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;

        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorId = lcv.Id;
        lct.First_Name__c = 'John';
        lct.Last_Name__c = 'Doe';
        insert lct;

        //Web or Audio Meetings test
        List<SaveTranscriptVariables.Input> inputList = new List<SaveTranscriptVariables.Input>();
        SaveTranscriptVariables.Input input = new SaveTranscriptVariables.Input();
        input.routableId = lct.Id;
        input.subject = 'This is a test';
        input.email = 'john.doe@pgi.com';
        input.productArea = 'Web or Audio Meetings';
        inputList.add(input);

        List<SaveTranscriptVariables.Output> outputList = SaveTranscriptVariables.saveChatDetails(inputList);
        System.assertEquals(outputList[0].chatQueue, [SELECT Id FROM Group WHERE DeveloperName = 'Chat_GlobalMeet_Web_and_Audio'].Id);

        LiveChatTranscript transcriptRecord = [SELECT Email_Address__c, Subject__c, PGi_Client__c, PGi_Company__c FROM LiveChatTranscript WHERE Id = :lct.Id];
        System.assertEquals(transcriptRecord.Email_Address__c, input.email);
        System.assertEquals(transcriptRecord.Subject__c, input.subject);
        System.assertEquals(transcriptRecord.PGi_Client__c, null);
        System.assertEquals(transcriptRecord.PGi_Company__c, null);

        //Billing test
        inputList = new List<SaveTranscriptVariables.Input>();
        input = new SaveTranscriptVariables.Input();
        input.routableId = lct.Id;
        input.subject = 'This is a billing test';
        input.email = 'john.doe.billing@pgi.com';
        input.productArea = 'Billing';
        inputList.add(input);

        outputList = SaveTranscriptVariables.saveChatDetails(inputList);
        System.assertEquals(outputList[0].chatQueue, [SELECT Id FROM Group WHERE DeveloperName = 'Chat_Billing_INTL'].Id);

        transcriptRecord = [SELECT Email_Address__c, Subject__c, PGi_Client__c, PGi_Company__c FROM LiveChatTranscript WHERE Id = :lct.Id];
        System.assertEquals(transcriptRecord.Email_Address__c, input.email);
        System.assertEquals(transcriptRecord.Subject__c, input.subject);
        System.assertEquals(transcriptRecord.PGi_Client__c, null);
        System.assertEquals(transcriptRecord.PGi_Company__c, null);
    }
}