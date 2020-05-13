trigger PGIServicesInformationTrigger on PGIServicesInformation__c (before update, after update, before insert, after insert) {
    new VersioningTriggerHandler().run();
}