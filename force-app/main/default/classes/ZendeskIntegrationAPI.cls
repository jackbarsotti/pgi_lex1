@RestResource(urlMapping='/ZendeskIntegrationAPI/*')
global without sharing class ZendeskIntegrationAPI {
	@HttpPost	
	global static void createNewCase(Case c, Integer i) {
        if(i == 9988) {
            List<Case> cList = [SELECT Id FROM Case WHERE ZD_Ticket_Id__c =: c.ZD_Ticket_ID__c];
            if(cList.size()>0){
                c.Id = cList[0].Id;
                update c;
            } else {
                insert c;
            }
        }
	}
}