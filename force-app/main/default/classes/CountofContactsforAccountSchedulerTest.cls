@isTest
public class CountofContactsforAccountSchedulerTest {
    static testMethod void testschedule() {
        Test.startTest();
        CountofContactsforAccountScheduler countObj = new CountofContactsforAccountScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('CountofContactsforAccountScheduler', sch, countObj);
        Test.stopTest();
   }
}