trigger DefaultValueTrigger on Default_Value__c (before insert, before update) {
    PGi_ServiceCatalog_TriggerHandler th = new PGi_ServiceCatalog_TriggerHandler(trigger.new);
}