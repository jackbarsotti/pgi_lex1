/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_PGi_CompanyTrigger on PGi_Company__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
	if(!OpportunityTriggerHandlerTest.bypassDlrs){
	    dlrs.RollupService.triggerHandler(PGi_Company__c.SObjectType);
	}
}