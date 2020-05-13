trigger FinancialAfterInsertAfterUpdate on NetSuite_Financial__c (after insert, after update) {
  FinancialActions.insertStartDates(Trigger.new);
}