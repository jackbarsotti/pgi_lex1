global class SchedulableAggreagatePGICompany implements Schedulable, Database.Batchable<sObject> {
    global void execute(SchedulableContext ctx) {
        SchedulableAggreagatePGICompany b = new SchedulableAggreagatePGICompany();
        Database.executeBatch(b,10);
        
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id FROM PGI_Entity__c');
    }
    public void execute(Database.BatchableContext BC, List<PGI_Entity__c> scope) {
        Set<String> pgiEntitySet = new Set<String>();
        for(PGI_Entity__c pgiEntity: scope){
            pgiEntitySet.add(pgiEntity.Id);
        }
        TotangoQueueableRecords objChildQueue = new TotangoQueueableRecords(new Set<String>(), pgiEntitySet);
        TotangoPgiEntityController obj = new TotangoPgiEntityController(new Set<String>(), pgiEntitySet);
        objChildQueue.recordsInstance = obj;
        system.enqueueJob(objChildQueue); 
    }
    public void finish(Database.BatchableContext BC) {

    }
}