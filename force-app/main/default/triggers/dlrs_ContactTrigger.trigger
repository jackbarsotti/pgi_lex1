/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_ContactTrigger on Contact
    (before delete, before insert, before update, after delete, after insert, after undelete, after update) 
    {
	if(!OpportunityTriggerHandlerTest.bypassDlrs){
		try{
	    	dlrs.RollupService.triggerHandler();
	    } catch (exception e) {
	    	System.debug(e.getMessage());
	    }
	}
}