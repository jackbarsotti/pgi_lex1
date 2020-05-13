/*
* Test for RequestForChangeTriggerHandler.cls
*/
@isTest
public class RequestForChangeTriggerHandlerTest {
   static Request_for_Change__c testRFC {get;set;}
   static void init() {
       testRFC = PGITestUtilities.createRFC(false);
       insert testRFC;
   }
   @isTest
   public static void testAutoProcesApproval() {
    init();
    Test.startTest();
    update testRFC;
   	Test.stopTest();
   }
}