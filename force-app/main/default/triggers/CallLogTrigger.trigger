trigger CallLogTrigger on Call_Log__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    new CallLogTriggerHandler().run();

}