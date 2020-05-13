trigger RtEventTrigger on RTEvent__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
	new RtEventTriggerHandler().run();
}