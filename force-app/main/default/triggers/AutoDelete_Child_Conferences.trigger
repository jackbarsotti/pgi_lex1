trigger AutoDelete_Child_Conferences on PGi_Client__c (before delete) {
    
    Set<Id> ClientIds = new Set<Id>();
    for(PGi_Client__c client : Trigger.old)
    {
        ClientIds.add(client.id);
    }  
    List<PGi_Conference__c> confList = [SELECT Id FROM PGi_Conference__c WHERE PGi_Client__c in :ClientIds];
    
    delete confList;
}