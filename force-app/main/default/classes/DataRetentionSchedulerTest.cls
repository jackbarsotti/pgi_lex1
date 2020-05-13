@isTest
public with sharing class DataRetentionSchedulerTest {
   static testMethod void testschedule() {
       Test.startTest();
        DataRetentionScheduler dtsObj = new DataRetentionScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('DataRetentionScheduler', sch, dtsObj);
       Test.stopTest();
   }
}