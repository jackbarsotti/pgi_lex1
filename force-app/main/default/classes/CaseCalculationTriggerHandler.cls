public without sharing class CaseCalculationTriggerHandler extends TriggerHandler{
    public CaseCalculationTriggerHandler() {
        super('CaseCalculationTriggerHandler');
    }
    protected override void afterUpdate() {
        fireEventHandler();
    }
    protected override void afterInsert() {
        fireEventHandler();
    }
    /*
    * Method to insert records to fiere Platform Event
    */
    private void fireEventHandler(){
        if(Trigger_Settings__c.getInstance().Bypass_Totango__c) { return; }
        List<Aggregate_Calculation_Event__e> listOfagregateEvents = new List<Aggregate_Calculation_Event__e>();
    
        for(Case caseObj :(List<Case>)Trigger.new){
            if(caseObj.PGI_Company__c != null){
                Aggregate_Calculation_Event__e obj = new Aggregate_Calculation_Event__e() ;   
                obj.PGI_Company_Id__c = caseObj.PGI_Company__c;
                listOfagregateEvents.add(obj);
            }
        }
        if(!listOfagregateEvents.isEmpty()){
            List<Database.SaveResult> results = EventBus.publish(listOfagregateEvents);
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' +
                                     err.getStatusCode() +
                                     ' - ' +
                                     err.getMessage());
                    }
                }
                
            }
        }
        
    }
}