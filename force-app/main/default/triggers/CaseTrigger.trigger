trigger CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after undelete, after delete) {
    new CaseTriggerHandler().run();
}