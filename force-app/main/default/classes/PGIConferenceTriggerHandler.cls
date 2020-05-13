public without sharing class PGIConferenceTriggerHandler extends TriggerHandler{
	public PGIConferenceTriggerHandler() {
		super('PGIConferenceTriggerHandler');
	}
	protected override void beforeInsert() {
		matchOnClientID();
	}
	protected override void beforeUpdate() {
		matchOnClientID();
	}

	private void matchOnClientID() {
		for(PGi_Conference__c conf: (List<PGI_Conference__c>)Trigger.new){
			if(String.isNotBlank(conf.Client_ID__c)) {
				if(relatedClientsByClientName.get(conf.Client_ID__c) != null) {
					if(relatedClientsByClientName.get(conf.Client_ID__c).size() == 1){
						//one match
						conf.PGi_Client__c = relatedClientsByClientName.get(conf.Client_ID__c)[0].Id;
					} else {
						//multiple matches
					}
					
				} else {
					//no match
				}
			}
		}
	}

	private Map<String, List<PGI_Client__c>> relatedClientsByClientName {
		get {
			if(relatedClientsByClientName == null) {
				relatedClientsByClientName = new Map<String, List<PGI_Client__c>>();
				for(PGI_Client__c client: [SELECT Id, Name FROM PGI_Client__c WHERE Name IN: clientNameSet]) {
					List<PGI_Client__c> clientsForName = new List<PGI_Client__c>();
					if(relatedClientsByClientName.get(client.Name) != null) {
						clientsForName = relatedClientsByClientName.get(client.Name);
					}
					clientsForName.add(client);
					relatedClientsByClientName.put(client.Name, clientsForName);
				}
			}
			return relatedClientsByClientName;
	} set;}
	
	private Set<String> clientNameSet {get{	
		clientNameSet = new Set<String>();
		for(PGi_Conference__c conf: (List<PGI_Conference__c>)Trigger.new){
			if(String.isNotBlank(conf.Client_ID__c)) {
				clientNameSet.add(conf.Client_ID__c);
			}
		}
		return clientNameSet;
	}set;}
	//private void notifyAdmins() {
	//	if(!Conferenceswithnomatch.isEmpty()){
	//		Messaging.SingleEmailMessage nomatchemail = new Messaging.SingleEmailMessage();
	//		nomatchemail.setToAddresses(new String[] {'timothy.barsotti@pgi.com','jessica.combs@pgi.com','cody.royster@pgi.com'});
	//		nomatchemail.setSubject('System Generated Notification : PGi Client ID has NO matches found');
	//		String emailplainTextBody = '';
	//		emailplainTextBody += 'Dear Salesforce Admin,\n\n';
	//		emailplainTextBody += 'This is to notify you that the following PGi Conferences have found NO matches for PGi Clients:' + conferencesWithNoMatch;
	//		nomatchemail.setPlainTextBody(emailplainTextBody);
	//		emails.add(nomatchemail);        
 //    	}
     
	//	if(!Conferenceswithmultiplematches.isEmpty()) {
	//		Messaging.SingleEmailMessage multiplematchemail = new Messaging.SingleEmailMessage();
	//		multiplematchemail.setToAddresses(new String[] {'timothy.barsotti@pgi.com','jessica.combs@pgi.com','cody.royster@pgi.com'});
	//		multiplematchemail.setSubject('System Generated Notification : PGi Client ID has MULTIPLE matches found'); 
	//		String emailplainTextbodymultiple = '';
	//		emailplainTextBodymultiple += 'Dear Salesforce Admin,\n\n'; 
	//		emailplainTextBodymultiple += 'This is to notify you that the following PGi Conferences have found multiple matches for PGi Clients - \n\n';
	//		emailplainTextBodymultiple += 'PGi Conference:'+ conferencesWithMultipleMatches;
	//		multiplematchemail.setPlainTextBody(emailplainTextBodymultiple);
	//	}
	//	emails.add(multiplematchemail);
	//	Messaging.sendEmail(emails);
	//	}   
	//}
}