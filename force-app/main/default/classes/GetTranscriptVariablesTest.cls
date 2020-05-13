@isTest
private class GetTranscriptVariablesTest {

    static testMethod void getChatDetailsMethod(){
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;

        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorId = lcv.Id;
        lct.First_Name__c = 'John';
        lct.Last_Name__c = 'Doe';
        insert lct;
        
        List<GetTranscriptVariables.Input> gettvInput = new List<GetTranscriptVariables.Input>();
        GetTranscriptVariables.Input inp = new GetTranscriptVariables.Input();
        inp.routableId = lct.Id;
        gettvInput.add(inp);

        List<GetTranscriptVariables.Output> gettvOutput = GetTranscriptVariables.getUserName(gettvInput);
        System.assertEquals(gettvOutput[0].firstName, 'John');

        LiveChatTranscript lct_new = [SELECT Name__c FROM LiveChatTranscript WHERE id = :lct.Id];
        System.assertEquals(lct_new.Name__c, 'John Doe');
    }
}