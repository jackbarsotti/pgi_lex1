trigger PGiEntityTrigger on PGi_Entity__c (before insert, before update, before delete, after insert, after update, after undelete, after delete) {
	new PGiEntityTriggerHandler().run();
}