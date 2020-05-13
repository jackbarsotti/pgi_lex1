trigger EventWebcastingRateTrigger on Event_Webcasting_Rates__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
	new EventWebcastingRateTriggerHandler().run();
}