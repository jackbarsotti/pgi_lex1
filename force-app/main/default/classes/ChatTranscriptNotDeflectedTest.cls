@isTest
private class ChatTranscriptNotDeflectedTest {
    static testMethod void ChatNotDeflectedTest() {
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;

        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorId = lcv.Id;
        lct.Deflected__c = true;
        insert lct;
        
        List<ChatTranscriptNotDeflected.Input> input = new List<ChatTranscriptNotDeflected.Input>();
        ChatTranscriptNotDeflected.Input inp = new ChatTranscriptNotDeflected.Input();
        inp.routableId = lct.Id;
        input.add(inp);

        ChatTranscriptNotDeflected.chatNotDeflected(input);
        LiveChatTranscript lct_new = [SELECT Deflected__c FROM LiveChatTranscript WHERE id = :lct.Id];
        System.assertEquals(lct_new.Deflected__c, false);
    }
}