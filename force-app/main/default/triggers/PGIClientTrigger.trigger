trigger PGIClientTrigger on PGi_Client__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
	new PGIClientTriggerHandler().run();
}