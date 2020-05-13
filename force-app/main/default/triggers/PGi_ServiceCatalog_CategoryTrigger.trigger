trigger PGi_ServiceCatalog_CategoryTrigger on PGi_ServiceCatalog_Category__c (before insert, before update) {
	PGi_ServiceCatalog_TriggerHandler th = new PGi_ServiceCatalog_TriggerHandler(trigger.new);
}