trigger EmployeePerformanceManagementTrigger on Employee_Performance_Management__c (after insert,after update) {
    new EmployeePerformanceMgmtTriggerHandler().run();
}