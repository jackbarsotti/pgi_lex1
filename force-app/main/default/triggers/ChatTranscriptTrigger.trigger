trigger ChatTranscriptTrigger on LiveChatTranscript (before insert, before update, before delete, after insert, after update, after undelete, after delete) {
    new ChatTranscriptTriggerHandler().run();
}