trigger ToValidateApprovals on Product_Engagement_Request__c (before update) {

for(Product_Engagement_Request__c per : Trigger.new)
{
if(per.Status__c == 'Approved' && ( per.Count_of_JIRA_Requests__c == 0 || per.TotalCostEstimateofWork__c == null || per.CurrentlyonRoadmap__c == null ))
per.adderror('You can\'t approve this record until all of the following is provided: At least one related Product JIRA Request, populate the Total Cost to Expedite field, and the Currently On Roadmap field');
}
 
}