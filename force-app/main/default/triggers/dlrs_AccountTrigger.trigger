/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_AccountTrigger on Account
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
	if(!OpportunityTriggerHandlerTest.bypassDlrs){
		try{
	    	dlrs.RollupService.triggerHandler();
	    } catch (exception e) {
	    	for(Account a: Trigger.new) {
	    		a.addError('Failed to update the account record due to the following error: ' + e.getMessage());
	    	}
	    }
	}
}