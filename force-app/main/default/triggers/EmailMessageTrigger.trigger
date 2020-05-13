trigger EmailMessageTrigger on EmailMessage (before insert, before update, before delete, after insert, after update, after undelete) {
    new EmailMessageTriggerHandler().run();
}