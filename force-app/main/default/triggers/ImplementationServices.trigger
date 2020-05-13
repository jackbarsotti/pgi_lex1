trigger ImplementationServices on Implementation_Services__c (before insert, before delete, before update, after insert, after undelete, after update) {
	new ImplementationServiceTriggerHandler().run();
}