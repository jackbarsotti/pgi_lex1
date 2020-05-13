public without sharing class AggregateCalculationTriggerHandler extends TriggerHandler {
    public AggregateCalculationTriggerHandler() {
        super('AggregateCalculationTriggerHandler');
    }
    protected override void afterInsert() {
        fireQueuableClass();
    }

    private void fireQueuableClass(){
        Set<String> pgiCompanyIdSet = new Set<String>();
        Set<String> pgiEntityIdSet = new Set<String>();
        for (Aggregate_Calculation_Event__e event : (List<Aggregate_Calculation_Event__e>)Trigger.New) {
            if (event.PGI_Company_Id__c != null) {
                pgiCompanyIdSet.add(event.PGI_Company_Id__c);
            }
            if (event.PGI_Entity__c != null) {
                pgiEntityIdSet.add(event.PGI_Entity__c);
            }
        }
        TotangoQueueableRecords objChildQueue = new TotangoQueueableRecords(pgiCompanyIdSet, pgiEntityIdSet);
        system.enqueueJob(objChildQueue); 
    }
}