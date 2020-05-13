trigger FinancialRequestTrigger on Financial_Request__c (after update, before insert, before update, after insert ) {
    new FinancialRequestTriggerHandler().run();
}