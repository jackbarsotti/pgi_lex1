trigger PGi_ServiceCatalog_HiddenInputTrigger on PGi_ServiceCatalog_Hidden_Input_Value__c (before insert, before update) {
	PGi_ServiceCatalog_TriggerHandler th = new PGi_ServiceCatalog_TriggerHandler(trigger.new);
}