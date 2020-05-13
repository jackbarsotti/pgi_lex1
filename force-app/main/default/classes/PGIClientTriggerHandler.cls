public class PGIClientTriggerHandler extends TriggerHandler{
	public PGIClientTriggerHandler() {
		super('PGIClientTriggerHandler');
	}
	protected override void beforeInsert() {
		matchOnCompanyID();
	}
	protected override void beforeUpdate() {
		matchOnCompanyID();
	}
	
	private void matchOnCompanyID() {
		for(PGi_Client__c client: (List<PGi_Client__c>)Trigger.new){
			if(String.isNotBlank(client.PGi_Company_ID__c)) {
				if(relatedCompanyByCompanyName.get(client.PGi_Company_ID__c) != null) {
					if(relatedCompanyByCompanyName.get(client.PGi_Company_ID__c).size() == 1){
						//one match
						client.PGi_Company__c = relatedCompanyByCompanyName.get(client.PGi_Company_ID__c)[0].Id;
					} else {
						//multiple matches
					}
					
				} else {
					//no match
				}
			}
		}
	}

	private Map<String, List<PGi_Company__c>> relatedCompanyByCompanyName {
		get {
			if(relatedCompanyByCompanyName == null) {
				relatedCompanyByCompanyName = new Map<String, List<PGi_Company__c>>();
				for(PGi_Company__c company: [SELECT Id, Name FROM PGi_Company__c WHERE Name IN: companyNameSet]) {
					List<PGi_Company__c> companiesForName = new List<PGi_Company__c>();
					if(relatedCompanyByCompanyName.get(company.Name) != null) {
						companiesForName = relatedCompanyByCompanyName.get(company.Name);
					}
					companiesForName.add(company);
					relatedCompanyByCompanyName.put(company.Name, companiesForName);
				}
			}
			return relatedCompanyByCompanyName;
	} set;}
	
	private Set<String> companyNameSet {get{
		companyNameSet = new Set<String>();
		for(PGi_Client__c client: (List<PGi_Client__c>)Trigger.new){
			if(String.isNotBlank(client.PGi_Company_ID__c)) {
				companyNameSet.add(client.PGi_Company_ID__c);
			}
		}
		return companyNameSet;
	}set;}
}