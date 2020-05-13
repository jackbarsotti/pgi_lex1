public without sharing class PGiCompanyAccountUltimateParentBatch implements Database.Batchable<sObject> {
	public Database.QueryLocator start(Database.BatchableContext bc) {
    	String query = 'SELECT Id, Ultimate_Parent_Account__c, Related_Ultimate_Parent_Account__c FROM PGi_Company__c';
    	return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<PGi_Company__c> scope) {
    	List<PGi_Company__c> updatePGiCompanies = new List<PGi_Company__c>();
    	for(PGi_Company__c pgiCompany : scope) {
    		if(pgiCompany.Related_Ultimate_Parent_Account__c != null) {
    			if(pgiCompany.Ultimate_Parent_Account__c != pgiCompany.Related_Ultimate_Parent_Account__c) {
    				updatePGiCompanies.add(pgiCompany);
    			}
    		}
    	}
    	if(!updatePGiCompanies.isEmpty()) {
    		LoggerUtil.handleSaveResults('Failed to update PGi Company Account Ultimate Parent Batch', Database.update(updatePGiCompanies, false));
    	}
        LoggerUtil.commitLogs();
    }
    public void finish(Database.BatchableContext bc) {

    }
}