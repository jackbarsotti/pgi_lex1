/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_TaskTrigger on Task
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
	if(!OpportunityTriggerHandlerTest.bypassDlrs){
		try {
	    	dlrs.RollupService.triggerHandler(Task.SObjectType);
	    } catch (exception e) {
	    	System.debug(e.getMessage());
	    }
	}
}