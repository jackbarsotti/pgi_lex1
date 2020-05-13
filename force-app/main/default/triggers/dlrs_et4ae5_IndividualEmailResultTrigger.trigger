/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_et4ae5_IndividualEmailResultTrigger on et4ae5__IndividualEmailResult__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(et4ae5__IndividualEmailResult__c.SObjectType);
}