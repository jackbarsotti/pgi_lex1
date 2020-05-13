/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_PlanAssignmentTrigger on PlanAssignment__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
	try {
    	dlrs.RollupService.triggerHandler(PlanAssignment__c.SObjectType);
	} catch (exception e) {
		System.debug(e);
	}
}