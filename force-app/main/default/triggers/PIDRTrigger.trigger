trigger PIDRTrigger on PIDR__c (before insert, before update, before delete, after insert, after update, after undelete, after delete) {
    new PIDRTriggerHandler().run();
}