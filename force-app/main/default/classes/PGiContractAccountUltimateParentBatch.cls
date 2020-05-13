public without sharing class PGiContractAccountUltimateParentBatch implements Database.Batchable<sObject> {
	public Database.QueryLocator start(Database.BatchableContext bc) {
    	String query = 'SELECT Id, Ultimate_Parent_Account__c, Related_Ultimate_Parent_Account__c FROM CONMAN_Contract__c';
    	return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<CONMAN_Contract__c> scope) {
        List<CONMAN_Contract__c> updatePGiContracts = new List<CONMAN_Contract__c>();
    	for(CONMAN_Contract__c pgiContract : scope) {
    		if(pgiContract.Ultimate_Parent_Account__c != null && pgiContract.Related_Ultimate_Parent_Account__c != null) {
    			if(pgiContract.Ultimate_Parent_Account__c != pgiContract.Related_Ultimate_Parent_Account__c) {
    				updatePGiContracts.add(pgiContract);
    			}
    		}
    	}
    	if(!updatePGiContracts.isEmpty()) {
    		LoggerUtil.handleSaveResults('Failed to update PGi Contract Account Ultimate Parent Batch', Database.update(updatePGiContracts, false));
    	}
        LoggerUtil.commitLogs();    
    }
    public void finish(Database.BatchableContext bc) {

    }
}