public without sharing class VersioningTriggerHandler extends TriggerHandler{
    protected override void beforeUpdate() {
        setVersionHistory();
    }
    protected override void beforeInsert() {
        setVersionHistory();
    }
    protected override void afterUpdate() {
		StoreCurrentVersion();
    }
    protected override void afterInsert() {
		StoreCurrentVersion();
    }
    /**
    * @description Creating a version history record for the sobject
    * @author Anup Kage (anup@cloudfastener.com) | 4/1/2020 
    * @return void 
    **/
    private void setVersionHistory() {
        Map<Object,Version_History__c> versionHistoryBySobjectUniqueId = new Map<Object,Version_History__c>(); 
        // List<Version_History__c> verHistoryObjList = new List<Version_History__c>();
        for(sObject sObj : (List<sObject>)Trigger.new){
            if(sObj.get('Version_History__c')== null){
                Version_History__c verHistoryObj = new Version_History__c();
                verHistoryObj.Name = 'Version History.1';
                // sObj.put('Version_History__c', verHistoryObj);// = verHistoryObj;
                versionHistoryBySobjectUniqueId.put(sObj.get('Unique_ID__c'), verHistoryObj);
            }
        }
        if(!versionHistoryBySobjectUniqueId.Values().isEmpty()){
            INSERT versionHistoryBySobjectUniqueId.Values();
        }
        for(sObject sObj : (List<sObject>)Trigger.new){
            if(sObj.get('Version_History__c')== null && versionHistoryBySobjectUniqueId.containsKey(sObj.get('Unique_ID__c'))){
                sObject sObjectVer = versionHistoryBySobjectUniqueId.get(sObj.get('Unique_ID__c'));
                String str = (String)sObj.put('Version_History__c', sObjectVer.Id);
            }
        }
    }
    /**
    * @description Creating the attachment for the Version history with Present Sobject record
    * @author Anup Kage (anup@cloudfastener.com) | 4/1/2020 
    * @return void 
    **/
    private void StoreCurrentVersion() {
        Set<Id> versionHistoryIdset = new Set<Id>();
        Map<Object,Object> attachmentCountByVerHistoryId = new Map<Object,Object>();
        // Map<String,Attachment> attachmentByVerHistoryId = new Map<String,Attachment>();

        for(sObject sObj : (List<sObject>)Trigger.new){
            versionHistoryIdset.add((Id)sObj.get('Version_History__c'));
        }
        for(AggregateResult agregatedResults :[SELECT ParentId, COUNT(Id) size 
                                              FROM Attachment 
                                              Where ParentId IN: versionHistoryIdset
                                              GROUP BY ParentId ]){
            attachmentCountByVerHistoryId.put(agregatedResults.get('ParentId'), agregatedResults.get('size'));
        }
        // for(Attachment attach : [SELECT ParentId, CreatedBy.Name, createdDate 
        //                         FROM attachment 
        //                         WHERE ParentId IN: versionHistoryIdset]){
        //     attachmentByVerHistoryId.put(attach.ParentId, attach);
        // }
        List<Attachment> attachmentList = new List<Attachment>();
        Map<Id, Blob> blobByVerHistoryId = new Map<Id, Blob>();
        for(sObject sObj : (List<sObject>)Trigger.new){
                    Attachment attach = new Attachment();  
                    if(attachmentCountByVerHistoryId.containsKey((Id)sObj.get('Version_History__c'))){
                        //Attachment atch = attachmentByVerHistoryId.get((Id)sObj.get('Version_History__c'));
                        attach.Name='V'+String.valueOf(Integer.valueOf(attachmentCountByVerHistoryId.get(sObj.get('Version_History__c'))) + 1) +'-'+ UserInfo.getName() +' - '+ sObj.get('LastModifiedDate');
                    }else{
                        // Attachment atch = attachmentByVerHistoryId.get((Id)sObj.get('Version_History__c'));
                        attach.Name='V1 -'+ UserInfo.getName() +' - '+ sObj.get('LastModifiedDate') ; 
                    }   
                    Blob bodyBlob=Blob.valueOf(JSON.serialize(sObj));
                    attach.body = bodyBlob;
                    attach.parentId = (Id)trigger.newMap.get(sObj.Id).get('Version_History__c');
                    attachmentList.add(attach);    
        }
        if(!attachmentList.isEmpty()){
            INSERT attachmentList;
        }
    }
}