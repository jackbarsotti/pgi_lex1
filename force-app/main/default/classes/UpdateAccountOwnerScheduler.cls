/*******************************************************************************
Name : UpdateAccountOwnerScheduler
Created On : Jan 21, 2016
Created By : Archana Rajendran
Description : Scheduler to update account owner based on TESLA Company Owner 
*******************************************************************************/
global class UpdateAccountOwnerScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        UpdateAccountOwnerBatch a= new UpdateAccountOwnerBatch();
        database.executebatch(a,1);
    }
}