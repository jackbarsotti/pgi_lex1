public without sharing class PGIServicesInformationTriggerHandler extends TriggerHandler{
    public PGIServicesInformationTriggerHandler() {
        super('PGIServicesInformationTriggerHandler');
    }
    protected override void afterUpdate() {
		StorePreviousVersion();
    }
    private void StorePreviousVersion() {
        Set<Id> pgiSevicesInfoIdset = new Set<Id>();
        Map<Object,Object> attachmentSizeByPGIServiceIdMap = new Map<Object,Object>();

        for(PGIServicesInformation__c pgiSeviceInfoObject : (List<PGIServicesInformation__c>)Trigger.old){
            pgiSevicesInfoIdset.add(pgiSeviceInfoObject.Id);
        }
        for(AggregateResult agregatedResults :[SELECT ParentId, COUNT(Id) size FROM Attachment Where ParentId IN: pgiSevicesInfoIdset
                                GROUP BY ParentId ]){
            attachmentSizeByPGIServiceIdMap.put(agregatedResults.get('ParentId'), agregatedResults.get('size'));
        }
        List<Attachment> attachmentList = new List<Attachment>();
        for(PGIServicesInformation__c pgiSeviceInfoObject : (List<PGIServicesInformation__c>)Trigger.old){
                Attachment attach=new Attachment();     
                if(attachmentSizeByPGIServiceIdMap.containsKey(pgiSeviceInfoObject.Id)){
                    attach.Name='V.'+String.valueOf(Integer.valueOf(attachmentSizeByPGIServiceIdMap.get(pgiSeviceInfoObject.Id)) + 1);
                }else{
                    attach.Name='V.1';
                }
                Blob bodyBlob=Blob.valueOf(JSON.serialize(pgiSeviceInfoObject));
                attach.body=bodyBlob;
                attach.parentId=pgiSeviceInfoObject.id;
                attachmentList.add(attach);
        }
        if(!attachmentList.isEmpty()){
            INSERT attachmentList;
        }
    }
}