@isTest
private class testRTEventCloseController {
  private static RTEventClose__c eventClose;
  private static ApexPages.StandardController controller;

  static {
    Test.startTest();
    PGITestUtilities.disableSalesWings();
    Test.stopTest();
    eventClose = MockRTEventClose.getNewRTEventClose();
    controller = new ApexPages.StandardController(RTDatabaseUtils.getEntireSObject(new RTEventClose__c(), eventClose.id));
    ApexPages.currentPage().getParameters().put('id', eventClose.id);
  }

  static testMethod void testConstruct() {
    RTEventCloseController c = new RTEventCloseController(controller);
    System.assert(c != null);    
    System.assert(c.getEvent().Event_Date__c == Date.newInstance(3010, 1, 1));
  }

  static testMethod void testDateValidation() {
    RTEventCloseController c = new RTEventCloseController(controller);
    c.getEvent().Event_Date__c = null;    
    c.preview();    
    System.assert(c != null);
  }
 
  static testMethod void testDurationValidation() {
    RTEventCloseController c = new RTEventCloseController(controller);
    c.getEvent().Broadcast_Audio_Event_Duration2__c = null;
    c.preview();    
    System.assert(c != null);
  }

  static testMethod void testIntlTollFreeBookedTrue() {
    RTEventCloseController c = new RTEventCloseController(controller);
    c.getEventClose().ITF_Add_on_Rate__c = 115.25;
    c.getEvent().Int_l_Toll_Free_Booked__c = true;
    c.preview();
    
    for (OtherChargeCredit__c occ : c.getPreviewOtherChargeCredit()) {
      if (occ.Product__c.contains('International Toll-Free Add-On')) {
        System.assertEquals(115.25, occ.ChargeOrCredit__c);
      }
    }
    System.assert(c != null);
  }

  static testMethod void testIntlTollFreeBookedFalse() {
    RTEventCloseController c = new RTEventCloseController(controller);
    c.getEventClose().ITF_Add_on_Rate__c = 115.25;
    c.getEvent().Int_l_Toll_Free_Booked__c = false;
    c.preview();
    
    for (OtherChargeCredit__c occ : c.getPreviewOtherChargeCredit()) {
      if (occ.Product__c.contains('International Toll-Free Add-On')) {
        //throw new ValidationException('Did not expect an International Toll-Free Add-On occ record.');
      }
    }
    System.assert(c != null);
  }  
  
  static testMethod void testAdditionalMinutesCharge() {
    RTEventCloseController c = new RTEventCloseController(controller);
    c.getEvent().Broadcast_Audio_Event_Participants__c = 111;
    c.getEvent().Broadcast_Audio_Event_Duration2__c = 71;
    c.getEventClose().Additional_Minutes_Rate__c = 250.00;
    c.preview();
    
    for (OtherChargeCredit__c occ : c.getPreviewOtherChargeCredit()) {
      if (occ.Product__c.contains('Additional Minutes')) {
        System.assertEquals(500.00, occ.ChargeOrCredit__c);
      }
    }

    System.assert(c != null);
  }

  static testMethod void testAdditionalParticipantCharge() {
    RTEventCloseController c = new RTEventCloseController(controller);
    c.getEvent().Broadcast_Audio_Event_Participants__c = 300;
    c.getEventClose().Additional_Participants_Rate__c = 500.00;
    c.preview();
    
    for (OtherChargeCredit__c occ : c.getPreviewOtherChargeCredit()) {
      if (occ.Product__c.contains('Additional Participants')) {
        System.assertEquals(1000.00, occ.ChargeOrCredit__c);
      }
    }
    System.assert(c != null);
  }

  static testMethod void testPost() {
    RTEventCloseController c = new RTEventCloseController(controller);
    c.post();
    System.assert(c != null);
  }
}