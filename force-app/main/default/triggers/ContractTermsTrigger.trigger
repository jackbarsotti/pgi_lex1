trigger ContractTermsTrigger on Contract_Terms__c (before update, after update, before insert, after insert) {
    new VersioningTriggerHandler().run();
}