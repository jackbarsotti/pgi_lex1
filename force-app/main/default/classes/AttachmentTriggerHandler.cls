public without sharing class AttachmentTriggerHandler extends TriggerHandler {
	public AttachmentTriggerHandler() {
        super('AttachmentTriggerHandler');
    }
    
    protected override void beforeInsert() {
        
    }
    
	protected override void afterInsert() {
		checkCaseAttachments();
        checkContractInsert();
        updatePGiContractHasAttachments();
        // moveESigFinalToOpp();
	}
	protected override void afterUpdate() {
        checkCaseAttachments();
	}
    protected override void afterDelete() {
        updatePGiContractHasAttachments();
    }
   protected override void beforeDelete(){
        validationOnAttachmentDeleteFrmCase();        
    } 

    /* COD-1712
        As Patricia Pricing, I need to ensure that users who are working International Contracts on the PGi Contract table are NOT able to attach files, 
            so that they are informed they must attach the file to the related Opportunity instead.
        Error Messaging: "Attachments must be attached to the related Opportunity only."
        NOTE: this should only occur on the PGi Contract object and only on records where the record type is International Contract
    */
    private void checkContractInsert() {
        Set<Id> contractIds = new Set<Id>();
        String contractPrefix = CONMAN_Contract__c.SObjectType.getDescribe().getKeyPrefix();
        for(Attachment a: (List<Attachment>)Trigger.new) {
            String idString = (String)a.ParentId;
            if(String.isNotBlank(a.ParentId) && idString.startsWith(contractPrefix)) {
                contractIds.add(a.ParentId);
            }
        }
        if(!contractIds.isEmpty()) {
            Map<Id, CONMAN_Contract__c> contractMap = getContracts(contractIds);
            if(contractMap != null) {
               for(Attachment a: (List<Attachment>)Trigger.new) {
                String idString = (String)a.ParentId;
                    if(String.isNotBlank(a.ParentId) && idString.startsWith(contractPrefix)) {
                        if(contractMap.get(a.ParentId) != null) {
                            CONMAN_Contract__c relatedContract = contractMap.get(a.ParentId);
                            if(relatedContract.RecordType.Name == 'International Contract') {
                                a.addError('Attachments must be attached to the related Opportunity only.');
                            }
                        }
                    }
                }
            }
        }
    }
    private Map<Id, CONMAN_Contract__c> getContracts(Set<Id> contractIds) {
        if(contractIds.isEmpty()) { return null; }
         return new Map<Id, CONMAN_Contract__c>([SELECT Id, RecordType.Name FROM CONMAN_Contract__c WHERE Id IN: contractIds]);
        
    }
     
    // private void moveESigFinalToOpp() {
	// 	Set<Id> esigIds = new Set<Id>();
	// 	for (Attachment a : (List<Attachment>)Trigger.new) {
	// 		if (a.ParentId != null && a.ParentId.getSobjectType() == Schema.echosign_dev1__SIGN_Agreement__c.SobjectType) {
    //             esigIds.add(a.ParentId);
    //         }
    //     }
        
	// 	if (esigIds.isEmpty()) {
    //         return;
    //     }
    //     System.debug('esigIds' + esigIds);
    //     Map<Id, echosign_dev1__SIGN_Agreement__c> esigFinalIds = new Map<Id, echosign_dev1__SIGN_Agreement__c>([
    //         SELECT Id, echosign_dev1__Opportunity__c
    //         FROM echosign_dev1__SIGN_Agreement__c
    //         WHERE Id IN :esigIds
    //         AND echosign_dev1__Status__c = 'Signed'
    //         AND echosign_dev1__Opportunity__c != null
    //     ]);
    //     System.debug('esigIds' + esigFinalIds);
	// 	if (esigFinalIds.isEmpty()) {
    //         return;
    //     }
    //     List<Attachment> attachmentList = new List<Attachment>();
    //     for (Attachment agAttach : (List<Attachment>)Trigger.new) {
    //         if (esigFinalIds.containsKey(agAttach.ParentId)) {
    //             String oppId = esigFinalIds.get(agAttach.ParentId).echosign_dev1__Opportunity__c;
    //             System.debug('oppId' + oppId);
    //             if(String.isNotBlank(oppId)) {
    //                 Attachment oppAttach = new Attachment();
    //                 oppAttach.Name = agAttach.Name;
    //                 oppAttach.body = agAttach.body;
    //                 oppAttach.parentId = oppId;
    //                 attachmentList.add(oppAttach);
    //             }
    //         }
    //     }
    //     System.debug(attachmentList);
    //     insert attachmentList;
    // }
    
	private void checkCaseAttachments() {
		Set<Id> caseIds = new Set<Id>();
		for (Attachment a : (List<Attachment>)Trigger.new)
			if (a.ParentId != null && a.ParentId.getSobjectType() == Schema.Case.SobjectType)
				caseIds.add(a.ParentId);
		if (caseIds.isEmpty()) return;
		List<Case> casesToUpdate = [SELECT Id, IsUpdateFromCaseComment__c FROM Case WHERE Id IN: caseIds];
        for (Case caseToUpdate : casesToUpdate)
			caseToUpdate.IsUpdateFromCaseComment__c = !caseToUpdate.IsUpdateFromCaseComment__c;
        UPDATE casesToUpdate;
    }
    
    private void updatePGiContractHasAttachments() {
        Map<Id, Attachment> attachments;
        if (Trigger.isAfter) {
            if (Trigger.isInsert)
                attachments = (Map<Id, Attachment>)Trigger.newMap;
            else if (Trigger.isDelete)
                attachments = (Map<Id, Attachment>)Trigger.oldMap;
        }
        
        if (attachments == null || attachments.isEmpty())
            return;
        
        Set<Id> PGiContractIds = new Set<Id>();
        
        for (Attachment attachment : attachments.values()) {
            // New Attachments on PGi Contracts
            if (Trigger.isInsert)
                if (attachment.ParentId != null && attachment.ParentId.getSobjectType() == Schema.CONMAN_Contract__c.SobjectType)
                    PGiContractIds.add(attachment.ParentId);
            
            // Deleted Attachments from PGi Contracts
            if (Trigger.isDelete)
                if (attachment.ParentId != null && attachment.ParentId.getSobjectType() == Schema.CONMAN_Contract__c.SobjectType)
                    PGiContractIds.add(attachment.ParentId);
        }
        
        if (PGiContractIds.isEmpty())
            return;
        
        List<CONMAN_Contract__c> PGiContracts = [SELECT Id, Has_Attachment__c, (SELECT Id FROM Attachments) FROM CONMAN_Contract__c WHERE Id IN :PGiContractIds];
        
        List<CONMAN_Contract__c> PGiContractsToUpdate = new List<CONMAN_Contract__c>();
        for (CONMAN_Contract__c PGiContract : PGiContracts) {
            if (PGiContract.Has_Attachment__c && (PGiContract.Attachments == null || PGiContract.Attachments.isEmpty())) {
                PGiContract.Has_Attachment__c = false;
                PGiContractsToUpdate.add(PGiContract);
            }
            if (!PGiContract.Has_Attachment__c && PGiContract.Attachments != null && !PGiContract.Attachments.isEmpty()) {
                PGiContract.Has_Attachment__c = true;
                PGiContractsToUpdate.add(PGiContract);
            }
        }
        UPDATE PGiContractsToUpdate;
    }
    
    private static Profile profile {get {
        return PGI_Utility.profile;
    } set; }
    
    private void validationOnAttachmentDeleteFrmCase(){
        // 0Q1 outbound email
        for(Attachment a: (List<Attachment>)Trigger.old) {
            if(a.Description != 'Email-Temp-Attachment' && !profile.Name.equals('System Administrator') && (String.valueOf(a.ParentId).startsWith('02s') || String.valueOf(a.ParentId).startsWith('0Q1'))){
               a.adderror('You don\'t have permission to Delete this Attachment. Please contact your System Administrator.');
            }
        }
    }
}