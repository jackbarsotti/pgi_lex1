/*******************************************************************************
Name : PopulatePrimaryContactonOppScheduler
Created On : Sep 13, 2016
Created By : Archana Rajendran
Description : Scheduler to update primary contact on opportunity 
*******************************************************************************/
global class PopulatePrimaryContactonOppScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        PopulatePrimaryContactonOpportunityBatch a= new PopulatePrimaryContactonOpportunityBatch();
        database.executebatch(a,50);
    }
}