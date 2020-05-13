public class MockRTEventClose {

    private RTEvent__c event = MockRTEvent.getNewRTEvent();    
    private Decimal baseEventCharge = 120.00;
    private Decimal additionalParticipantsRate = 1.25;
    private Decimal additionalMinutesRate = 1.25; 
    private Decimal itfAddOnRate = 10.15;
    private Decimal liveMonitoringRate = 500.00;
    private Decimal premiumOpAssistRate = 150.00;
        
    private void setupRTEventClose(RTEventClose__c e) {
      e.RT_Event__r = event;
      e.RT_Event__c = event.Id;
      e.Base_Event_Charge__c = baseEventCharge;
      e.Additional_Participants_Rate__c = additionalParticipantsRate;
      e.Additional_Minutes_Rate__c = additionalMinutesRate; 
      e.ITF_Add_on_Rate__c = itfAddOnRate;
      e.Live_Event_Monitoring_Rate__c = liveMonitoringRate;
      e.Premium_Op_Assist_Rate__c = premiumOpAssistRate;
    }
       
    public static RTEventClose__c getNewRTEventClose() {
      RTEventClose__c e = new RTEventClose__c();
      MockRTEventClose m = new MockRTEventClose();
      m.setupRTEventClose(e);      
      Database.insert(e);
      return e;
    }
}