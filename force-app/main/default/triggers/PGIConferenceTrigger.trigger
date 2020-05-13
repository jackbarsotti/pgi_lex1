trigger PGIConferenceTrigger on PGI_Conference__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
	new PGIConferenceTriggerHandler().run();
}