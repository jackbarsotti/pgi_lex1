public class MockRTEvent {
    
    public Date EventDate = Date.newInstance(3010, 1, 1);
    private Subscription__c billToSub = MockSubscription.getNewSubscription();
    private Subscription__c ac = MockSubscription.getNewSubscription();
    private Integer duration = 100;
    private Integer participants = 100;
        
    private void setupRTEvent(RTEvent__c e) {
      e.Event_Date__c = EventDate;
      e.Access_Code__c = ac.Id;
      e.Bill_to_Access_Code__c = billToSub.Id;
      e.Bill_to_Access_Code__r = billToSub;
      e.Broadcast_Audio_Event_Duration2__c = duration;
      e.Broadcast_Audio_Event_Participants__c = participants;
      e.Total_lines_reserved__c = 10;
    }
       
    public static RTEvent__c getNewRTEvent() {
      RTEvent__c e = new RTEvent__c();
      MockRTEvent m = new MockRTEvent();
      m.setupRTEvent(e);      
      Database.insert(e);      
      return e;
    }
}