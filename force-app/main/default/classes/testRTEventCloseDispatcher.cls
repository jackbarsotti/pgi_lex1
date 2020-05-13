@isTest
private class testRTEventCloseDispatcher {

  private static ApexPages.StandardController controller;

  static{
    Test.startTest();
    PGITestUtilities.disableSalesWings();
    Test.stopTest();
    //Because there is a bug with controller.addFields in tests, let's do this...
    List<RTEvent__c> events = RTDatabaseUtils.getSObjectList('RTEvent__c', String.join(RTEventCloseDispatcher.additionalFields, ','), ' where id = \''+MockRTEvent.getNewRTEvent().Id+'\'');
    if(events.size()>0)
      controller = new ApexPages.StandardController(events.get(0));
  }

  //RTEventCloseDispatcher.RTEventCloseDispatcher
  static testMethod void testConstruct() {
    RTEventCloseDispatcher c = new RTEventCloseDispatcher(controller);
  }

  //RTEventCloseDispatcher.createEventClose
  static testMethod void testCreateEventClose() {
    //Assert that we can call createEventClose
    RTEventCloseDispatcher c = new RTEventCloseDispatcher(controller);
    PageReference pr = c.createEventClose();
    System.assert(pr != null);
  }
}