trigger NetSuiteFinancialTrigger on NetSuite_Financial__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
	new NetSuiteFinancialTriggerHandler().run();
}