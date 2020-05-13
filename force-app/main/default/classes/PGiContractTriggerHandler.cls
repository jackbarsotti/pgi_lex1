public without sharing class PGiContractTriggerHandler extends TriggerHandler {
	public PGiContractTriggerHandler() {
		super('PGiContractTriggerHandler');
	}
	protected override void beforeUpdate(){ 
		updateUltimateParentAccount();
		// validateDealDesk();
	}
	protected override void beforeInsert(){ 
		updateUltimateParentAccount();
	}
	protected override void afterInsert() {
		closeOpp();
	}
	protected override void afterUpdate() {
		closeOpp();
		checkApprovedContracts();
	}
	// Set CONMAN_Contract__c.Ultimate_Parent_Account__c
	// CONMAN_Contract__c.Related_Ultimate_Parent_Account__c
	// CONMAN_Contract__c.Related_Account_Name__c
	private void updateUltimateParentAccount() {
		for(CONMAN_Contract__c pgiContract : (List<CONMAN_Contract__c>)Trigger.new) {
			if(pgiContract.Ultimate_Parent_Account__c != pgiContract.Related_Ultimate_Parent_Account__c && !pgiContract.Related_Account_Name__c.contains('unmatch')) {
				pgiContract.Ultimate_Parent_Account__c = pgiContract.Related_Ultimate_Parent_Account__c;
			}
		}
	}
	// private void validateDealDesk(){
	// 	for(CONMAN_Contract__c contract: (List<CONMAN_Contract__c>)Trigger.new) {
	// 		CONMAN_Contract__c oldValue = (CONMAN_Contract__c)Trigger.oldMap.get(contract.Id);
	// 		if(contract.Deal_Desk_Approved__c == true && oldValue.Deal_Desk_Approved__c == false) {
	// 			if(contract.T_Cs_Were_Manually_Changed__c == null || contract.Product_Details_Were_Manually_Changed__c == null){
    // 				contract.addError('Please edit the PGi Contract and specify a value for the following fields: \'T&Cs Were Manually Changed\' and \'Product Details Were Manually Changed\'');
	// 			}
	// 		}
	// 	}
	// }
	private void closeOpp() {
		Map<Id, Opportunity> oppsToUpdate = new Map<Id, Opportunity>();
		for(CONMAN_Contract__c cont: (List<CONMAN_Contract__c>)Trigger.new) {
			if(isChanged('Contract_Status__c', cont) && cont.Contract_Status__c == 'Customer Accepted') {
				Opportunity opp = relatedOpp.get(cont.Opportunity__c);
				if(opp != null  && opp.RecordType.Name == 'PGi Opportunity') {
					if(opp.isClosed == false && opp.StageName != 'Closed Pending Approval' && opp.StageName != 'Closed Won') {
						opp.StageName = 'Closed Pending Approval';
						oppsToUpdate.put(opp.Id, opp);
					} 
				} 
			}
		}
		update oppsToUpdate.values();
	}

	private static Set<Id> approvedIdsProcessed = new Set<Id>();
	private void checkApprovedContracts(){
		Set<Id> approvedContractIds = new Set<Id>();
		for(CONMAN_Contract__c contract : (List<CONMAN_Contract__c>)Trigger.new) {
			if(isChanged('Contract_Status__c', contract) && contract.Contract_Status__c == 'Approved' && !approvedContractIds.contains(contract.Id)) {
				approvedContractIds.add(contract.Id);
			}
		}
		if (!approvedContractIds.isEmpty()){
			approvedIdsProcessed.addAll(approvedContractIds);
			createApprovedVersion(approvedContractIds);
		}
	}

	@future(callout=true)
	private static void createApprovedVersion(Set<Id> approvedContractIds) {
		List<CPQ_Contract_Approved_Version__c> approvedVersionsToCreate = new List<CPQ_Contract_Approved_Version__c>();
		Map<Id, Attachment> attachmentsToCreateMap = new Map<Id, Attachment>();

		List<CONMAN_Contract__c> contracts = new List<CONMAN_Contract__c>([SELECT Id, Contract_Status__c FROM CONMAN_Contract__c WHERE Id IN :approvedContractIds]);
		for(CONMAN_Contract__c contract : contracts) {
			CPQ_Contract_Approved_Version__c approvedVersion = new CPQ_Contract_Approved_Version__c();
			approvedVersion.PGi_Contract__c = contract.Id;
			approvedVersionsToCreate.add(approvedVersion);

			PageReference contractPdf = Page.iContract_NA_Master;
			contractPdf.getParameters().put('id', contract.Id);
			contractPdf.getParameters().put('pdfDownload', 'true');

			Attachment att = new Attachment();
			att.Name = 'Approved Version - ' + Datetime.now().format('yyyy-MM-dd') + '.pdf';
			if (!System.Test.isRunningTest()){
				att.body = contractPdf.getContent();
			} else {
				att.body = EncodingUtil.convertFromHex('00000000000000000000000000000000');
			}
			attachmentsToCreateMap.put(contract.Id, att);
		}		
		if (approvedVersionsToCreate.size() > 0) {
			insert approvedVersionsToCreate;
			for (CPQ_Contract_Approved_Version__c approvedVersion : approvedVersionsToCreate){
				attachmentsToCreateMap.get(approvedVersion.PGi_Contract__c).parentId = approvedVersion.Id;
			}
			insert attachmentsToCreateMap.values();
		}
	}

	private static Map<Id, Opportunity> relatedOpp {get {
		if(relatedOpp == null) {
			Set<Id> oppIds = new Set<Id>();
			for(CONMAN_Contract__c cont: (List<CONMAN_Contract__c>)Trigger.new) {
				oppIds.add(cont.Opportunity__c);
			}
			oppIds.remove(null);
			relatedOpp = new Map<Id, Opportunity>([SELECT Id, IsClosed,RecordType.Name, StageName FROM Opportunity WHERE Id in: OppIds AND RecordType.Name = 'PGi Opportunity']);
		}
		return relatedOpp;
	} set;}
}