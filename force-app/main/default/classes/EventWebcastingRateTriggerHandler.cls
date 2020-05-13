public without sharing class EventWebcastingRateTriggerHandler extends TriggerHandler {
	public EventWebcastingRateTriggerHandler() {
		super('EventWebcastingRateTriggerHandler');
	}
	protected override void beforeInsert() {
		checkForDuplicates();
	}
	private Set<Id> accountIds = new Set<Id>();
	private void checkForDuplicates() {
		for(Event_Webcasting_Rates__c rate: existingWebcastingRates) {
			accountIds.add(rate.Related_Account__c);
		}
		for(Event_Webcasting_Rates__c rate: (List<Event_Webcasting_Rates__c>)Trigger.new) {
			if(accountIds.contains(rate.Related_Account__c)) {
				rate.addError('Only one Event Webcasting Rate record is allowed per account');
			}
		}
	}
	@TestVisible private static List<Event_Webcasting_Rates__c> existingWebcastingRates { get {
		if(existingWebcastingRates == null) {
			Set<Id> accountIds = new Set<Id>();
			for(Event_Webcasting_Rates__c rate: (List<Event_Webcasting_Rates__c>)Trigger.new) {
				if(rate.Related_Account__c != null) {
					accountIds.add(rate.Related_Account__c);
				}
			}
			existingWebcastingRates = [SELECT Id, Related_Account__c FROM Event_Webcasting_Rates__c WHERE Related_Account__c IN: accountIds];
		}
		return existingWebcastingRates;
	} set; }
}