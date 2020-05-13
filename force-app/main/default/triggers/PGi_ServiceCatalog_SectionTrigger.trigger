trigger PGi_ServiceCatalog_SectionTrigger on PGi_ServiceCatalog_Section__c (before insert, before update) {
	PGi_ServiceCatalog_TriggerHandler th = new PGi_ServiceCatalog_TriggerHandler(trigger.new);
}