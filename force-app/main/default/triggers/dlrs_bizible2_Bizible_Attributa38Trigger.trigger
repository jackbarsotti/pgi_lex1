/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_bizible2_Bizible_Attributa38Trigger on bizible2__Bizible_Attribution_Touchpoint__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
	try {
    	dlrs.RollupService.triggerHandler(bizible2__Bizible_Attribution_Touchpoint__c.SObjectType);
	} catch (exception e) {
		System.debug(e);
	}
}