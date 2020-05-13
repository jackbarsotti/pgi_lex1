/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_Zendesk_Zendesk_TicketTrigger on Zendesk__Zendesk_Ticket__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
	try {
    	dlrs.RollupService.triggerHandler(Zendesk__Zendesk_Ticket__c.SObjectType);
	} catch (exception e) {
		System.debug(e);
	}
}