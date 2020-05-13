trigger dlrs_NetSuite_FinancialTrigger on NetSuite_Financial__c (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
	try {
    	dlrs.RollupService.triggerHandler(NetSuite_Financial__c.SObjectType);
    } catch (exception e) {
    	System.debug(e.getMessage());
    }
}