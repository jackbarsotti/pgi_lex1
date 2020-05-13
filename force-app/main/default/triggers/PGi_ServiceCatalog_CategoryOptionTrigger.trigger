trigger PGi_ServiceCatalog_CategoryOptionTrigger on PGi_ServiceCatalog_Category_Option__c (before insert, before update) {
	PGi_ServiceCatalog_TriggerHandler th = new PGi_ServiceCatalog_TriggerHandler(trigger.new);
}