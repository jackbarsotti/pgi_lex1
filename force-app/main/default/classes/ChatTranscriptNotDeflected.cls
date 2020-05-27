public with sharing class ChatTranscriptNotDeflected {

    public class Input {
        @InvocableVariable(required=true)
        public Id routableID;
    }

    @InvocableMethod(label='Mark Chat As Not Deflected')
    public static void chatNotDeflected(List<Input> inputs) {
        Input input = inputs[0];

        LiveChatTranscript transcriptRecord = [SELECT Id FROM LiveChatTranscript WHERE Id = :input.routableID];
        transcriptRecord.Deflected__c = false;
        update transcriptRecord;
    }
}