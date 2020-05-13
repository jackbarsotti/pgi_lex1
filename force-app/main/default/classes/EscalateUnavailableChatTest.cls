@isTest
private class EscalateUnavailableChatTest {

    static testMethod void createGMCCaseMethod(){
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;

        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorId = lcv.Id;
        lct.First_Name__c = 'John';
        lct.Last_Name__c = 'Doe';
        lct.Name__c = 'John Doe';
        lct.Email_Address__c = 'john.doe@pgi.com';
        lct.Query_Topic__c = 'Web or Audio Meetings';
        lct.Subject__c = 'Testing';
        lct.Region__c = null;
        insert lct;

        List<EscalateUnavailableChat.Input> inputList = new List<EscalateUnavailableChat.Input>();
        EscalateUnavailableChat.Input input = new EscalateUnavailableChat.Input();
        input.routableId = lct.Id;
        inputList.add(input);

        List<EscalateUnavailableChat.Output> outputList = EscalateUnavailableChat.escalateChat(inputList);
        System.assert(outputList[0].ticketNumber.length() > 0);

        LiveChatTranscript transcriptRecord = [SELECT CaseId FROM LiveChatTranscript WHERE Id = :lct.Id];
        System.assertNotEquals(transcriptRecord.CaseId, null);
    }

    static testMethod void createEventCaseMethod(){
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;

        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorId = lcv.Id;
        lct.First_Name__c = 'John';
        lct.Last_Name__c = 'Doe';
        lct.Name__c = 'John Doe';
        lct.Email_Address__c = 'john.doe@pgi.com';
        lct.Query_Topic__c = 'Operator Assisted Events';
        lct.Subject__c = 'Testing';
        lct.Region__c = null;
        insert lct;

        List<EscalateUnavailableChat.Input> inputList = new List<EscalateUnavailableChat.Input>();
        EscalateUnavailableChat.Input input = new EscalateUnavailableChat.Input();
        input.routableId = lct.Id;
        inputList.add(input);

        List<EscalateUnavailableChat.Output> outputList = EscalateUnavailableChat.escalateChat(inputList);
        System.assert(outputList[0].ticketNumber.length() > 0);

        LiveChatTranscript transcriptRecord = [SELECT CaseId FROM LiveChatTranscript WHERE Id = :lct.Id];
        System.assertNotEquals(transcriptRecord.CaseId, null);
    }

    static testMethod void createPhoneCaseMethod(){
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;

        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorId = lcv.Id;
        lct.First_Name__c = 'John';
        lct.Last_Name__c = 'Doe';
        lct.Name__c = 'John Doe';
        lct.Email_Address__c = 'john.doe@pgi.com';
        lct.Query_Topic__c = 'Business Phone Systems';
        lct.Subject__c = 'Testing';
        lct.Region__c = null;
        insert lct;

        List<EscalateUnavailableChat.Input> inputList = new List<EscalateUnavailableChat.Input>();
        EscalateUnavailableChat.Input input = new EscalateUnavailableChat.Input();
        input.routableId = lct.Id;
        inputList.add(input);

        List<EscalateUnavailableChat.Output> outputList = EscalateUnavailableChat.escalateChat(inputList);
        System.assert(outputList[0].ticketNumber.length() > 0);

        LiveChatTranscript transcriptRecord = [SELECT CaseId FROM LiveChatTranscript WHERE Id = :lct.Id];
        System.assertNotEquals(transcriptRecord.CaseId, null);
    }

    static testMethod void createFinReqMethod(){
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;

        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorId = lcv.Id;
        lct.First_Name__c = 'John';
        lct.Last_Name__c = 'Doe';
        lct.Name__c = 'John Doe';
        lct.Email_Address__c = 'john.doe@pgi.com';
        lct.Query_Topic__c = 'Billing';
        lct.Subject__c = 'Testing';
        lct.Region__c = 'NA';
        insert lct;

        List<EscalateUnavailableChat.Input> inputList = new List<EscalateUnavailableChat.Input>();
        EscalateUnavailableChat.Input input = new EscalateUnavailableChat.Input();
        input.routableId = lct.Id;
        inputList.add(input);

        List<EscalateUnavailableChat.Output> outputList = EscalateUnavailableChat.escalateChat(inputList);
        System.assert(outputList[0].ticketNumber.length() > 0);

        LiveChatTranscript transcriptRecord = [SELECT Financial_Request__c FROM LiveChatTranscript WHERE Id = :lct.Id];
        System.assertNotEquals(transcriptRecord.Financial_Request__c, null);
    }

}