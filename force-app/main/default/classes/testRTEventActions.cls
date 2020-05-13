@isTest
public class testRTEventActions {
    private static RTEvent__c rtEvent;
    
    static testMethod void testUpdateRTEventNotes() {
        Test.startTest();
        PGITestUtilities.disableSalesWings();
        Test.stopTest();
        rtEvent = MockRTEvent.getNewRTEvent();
        
       /* List<RTEvent__c> rtEvents = new List<RTEvent__c>();
        rtEvents.add(rtEvent);
        
        RTEventActions.updateRTEventNotes(rtEvents);*/
    }
    
    static testMethod void testAddEventRecords() {
        Test.startTest();
        PGITestUtilities.disableSalesWings();
        
        rtEvent = MockRTEvent.getNewRTEvent();
        
       /* Map<Id, RTEvent__c> rtEvents = new Map<Id, RTEvent__c>();
        rtEvents.put(rtEvent.Id, rtEvent);
        
        RTEventActions.addEventRecords(rtEvents, null);*/
        Test.stopTest();
    }
    static testMethod void testAddEventRecords1() {
        Test.startTest();
        PGITestUtilities.disableSalesWings();
        Subscription__c ac = MockSubscription.getNewSubscription();
        Subscription__c billToSub = MockSubscription.getNewSubscription();
        RTEvent__c rtEvent = new RTEvent__c();
        rtEvent.Event_Date__c = Date.newInstance(3010, 1, 1);
        rtEvent.Access_Code__c = ac.Id;
        rtEvent.Bill_to_Access_Code__c = billToSub.Id;
        rtEvent.Bill_to_Access_Code__r = billToSub;
        rtEvent.Broadcast_Audio_Event_Duration2__c = 100;
        rtEvent.Broadcast_Audio_Event_Participants__c = 100;
        rtEvent.Total_lines_reserved__c = 10;
        insert rtEvent;
        
        /*rtEvent.eventManager__c = userinfo.getuserid();
        update rtEvent;
       /* Map<Id, RTEvent__c> rtEvents = new Map<Id, RTEvent__c>();
        rtEvents.put(rtEvent.Id, rtEvent);
        
        RTEventActions.addEventRecords(rtEvents, null);*/
        Test.stopTest();
    }
}