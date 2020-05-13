trigger RequestForChangeTrigger on Request_For_Change__c (before insert, before delete, before update, after insert, after undelete, after update) {
	new RequestForChangeTriggerHandler().run();
}