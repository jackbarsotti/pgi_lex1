trigger AutoDelete_Child_Companies on PGi_Entity__c (before delete) {
    
    Set<Id> EntityIds = new Set<Id>();
    for(PGi_Entity__c entity : Trigger.old)
    {
        EntityIds.add(entity.id);
    }  
    List<PGi_Company__c> companyList = [SELECT Id FROM PGi_Company__c WHERE PGi_Entity__c in :EntityIds];
    
    delete companyList;
}