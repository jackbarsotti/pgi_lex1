/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_RTEventTrigger on RTEvent__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
	if(!OpportunityTriggerHandlerTest.bypassDlrs){
		try {
	    	dlrs.RollupService.triggerHandler(RTEvent__c.SObjectType);
	    } catch (exception e) {
	    	System.debug(e.getMessage());
	    }
	}
}