public without sharing class ContractTerms_cTriggerHandler extends TriggerHandler{
    protected override void afterUpdate() {
		StorePreviousVersion();
    }
    private void StorePreviousVersion() {
        Set<Id> contractTermsIdset = new Set<Id>();
        Map<Object,Object> attachmentSizeByContractsTermsId = new Map<Object,Object>();

        for(Contract_Terms__c contractTermsObject : (List<Contract_Terms__c>)Trigger.old){
            contractTermsIdset.add(contractTermsObject.Id);
        }
        for(AggregateResult agregatedResults :[SELECT ParentId, COUNT(Id) size FROM Attachment Where ParentId IN: contractTermsIdset
                                GROUP BY ParentId ]){
            attachmentSizeByContractsTermsId.put(agregatedResults.get('ParentId'), agregatedResults.get('size'));
        }
        List<Attachment> attachmentList = new List<Attachment>();
        for(Contract_Terms__c contractTermsObject : (List<Contract_Terms__c>)Trigger.old){
                Attachment attach=new Attachment();  
                if(attachmentSizeByContractsTermsId.containsKey(contractTermsObject.Id)){
                    attach.Name='V.'+String.valueOf(Integer.valueOf(attachmentSizeByContractsTermsId.get(contractTermsObject.Id)) + 1);
                }else{
                    attach.Name='V.1';
                }   
                Blob bodyBlob=Blob.valueOf(JSON.serialize(contractTermsObject));
                attach.body=bodyBlob;
                attach.parentId=contractTermsObject.id;
                attachmentList.add(attach);
        }
        
        if(!attachmentList.isEmpty()){
            INSERT attachmentList;
        }
    }
}