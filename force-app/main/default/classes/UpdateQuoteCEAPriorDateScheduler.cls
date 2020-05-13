/*********************************************************************
Name : UpdateQuoteCEAPriorDateScheduler
Created On : Mar 09, 2016
Created By : Archana Rajendran
Description : Scheduler to update CEA Date Prior-to-Renewal and CEA Active Date 
**********************************************************************/
global class UpdateQuoteCEAPriorDateScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        UpdateQuoteCEAPriorDateBatch b = new UpdateQuoteCEAPriorDateBatch();
        database.executebatch(b,50);
    }
}