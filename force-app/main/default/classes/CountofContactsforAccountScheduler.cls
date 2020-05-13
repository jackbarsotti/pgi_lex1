/*********************************************************************
Name : CountofContactsforAccountScheduler
Created On : Jul 11, 2016
Created By : Archana Rajendran
Description : Scheduler to update number of contacts associated to an account 
**********************************************************************/
global class CountofContactsforAccountScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        CountofContactsforAccountBatch b = new CountofContactsforAccountBatch();
        database.executebatch(b,200);
    }
}