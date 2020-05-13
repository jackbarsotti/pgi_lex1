@IsTest
public without sharing class RTEventTriggerTest {
  @TestSetup
  static void makeData(){
    Test.startTest();
      
      Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(
            ProfileId = pf.Id,
            LastName = 'test User',
            Email = 'test.FromTestCEmailComposer.com@pgi.com',
            Username = 'test.FromTestCEmailComposer01.com@pgi.com' ,
            CompanyName = 'RT',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            EmployeeNumber = 'one'
       );
       insert u;
       System.runAs(u) {
        PGITestUtilities.disableSalesWings();
       }
      Test.stopTest();
  }
  private static void init() {
    EventDate = Date.newInstance(3010, 1, 1);
    billToSub = MockSubscription.getNewSubscription();
    ac = MockSubscription.getNewSubscription();
    duration = 100;
    participants = 100;
  }
    public static Date EventDate;
    private static Subscription__c billToSub;
    private static Subscription__c ac;
    private static Integer duration;
    private static Integer participants;
        
    private static void setupRTEvent(RTEvent__c e) {
      User usr = [SELECT Id, Username, LastName FROM User WHERE UserName = 'test.FromTestCEmailComposer01.com@pgi.com' AND IsActive = true];
      e.Event_Date__c = EventDate;
      e.Access_Code__c = ac.Id;
      e.Bill_to_Access_Code__c = billToSub.Id;
      e.Bill_to_Access_Code__r = billToSub;
      e.Broadcast_Audio_Event_Duration2__c = duration;
      e.Broadcast_Audio_Event_Participants__c = participants;
      e.Total_lines_reserved__c = 10;

      e.Coordinator_Notes_New__c = 'Test Coordinator_Notes_New__c Description';
      e.Event_Manager_Notes_New__c = 'Test Event_Manager_Notes_New__c Description';
      e.status__c = 'CANCELLED';
      e.eventManager__c = UserInfo.getUserId();

    }
    @IsTest 
    public static void testRateAssociation() {
      init();
      Test.startTest();
      Account acct = new Account();
	    acct.Name = 'test';
	    //acct.Billing_State__c = 'CO';
	    acct.Invoice_Types__c = 'Account Summary';
	    acct.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkAccountRecordTypes[0].Id;
      insert new List<Account>{acct};
	    //test update
	    RTEvent__c updateEvent = getNewRTEvent(true);
	    updateEvent = [SELECT Event_Webcasting_Rates__c FROM RTEvent__c WHERE Id =: updateEvent.Id];
	    System.assert(updateEvent.Event_Webcasting_Rates__c == null);
	    updateEvent.Account__c = acct.Id;
	    update updateEvent;
	    updateEvent = [SELECT Event_Webcasting_Rates__c FROM RTEvent__c WHERE Id =: updateEvent.Id];
	    updateEvent.Event_Webcasting_Rates__c = null;
	    update updateEvent;
	    updateEvent = [SELECT Event_Webcasting_Rates__c FROM RTEvent__c WHERE Id =: updateEvent.Id];
	    System.assert(updateEvent.Event_Webcasting_Rates__c != null);
	    //test insert
	    RTEvent__c insertEvent = getNewRTEvent(false);
	    insertEvent.Account__c = acct.Id;
      insertEvent.eventManager__c = UserInfo.getUserId();
	    insert insertEvent;
	    insertEvent = [SELECT Event_Webcasting_Rates__c FROM RTEvent__c WHERE Id =: insertEvent.Id];
      System.assert(insertEvent.Event_Webcasting_Rates__c != null);
      
      // Event evnt = new Event();
      // evnt.WhatId = insertEvent.Id;
      // evnt.DurationInMinutes = 4;
      // evnt.ActivityDate = date.newInstance(2020, 3, 10);
      // evnt.ActivityDateTime = datetime.newInstance(2020, 3, 10, 16, 30, 0);
      // insert evnt;
      Test.stopTest();
    }

    public static RTEvent__c getNewRTEvent(Boolean doInsert) {
      RTEvent__c e = new RTEvent__c();
      setupRTEvent(e);
      if(doInsert) {
      	Database.insert(e);
      }
      return e;
    }

    @IsTest 
    public static void test() {
      init();
      Test.startTest();
       Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
      //   User u = new User(
      //       ProfileId = pf.Id,
      //       LastName = 'test.FromTestCEmailComposer01.com@pgi.com New',
      //       Email = 'test.FromTestCEmailComposer.com@pgi.com',
      //       Username = 'test.FromTestCEmailComposer01.com@pgi.com' ,
      //       CompanyName = 'RT',
      //       Title = 'title',
      //       Alias = 'alias',
      //       TimeZoneSidKey = 'America/Los_Angeles',
      //       EmailEncodingKey = 'UTF-8',
      //       LanguageLocaleKey = 'en_US',
      //       LocaleSidKey = 'en_US',
      //       EmployeeNumber = 'one'
      //     );
      //  insert u;
      User usr = [SELECT Id, Username, LastName FROM User WHERE UserName = 'test.FromTestCEmailComposer01.com@pgi.com' AND IsActive = true];

        RTEvent__c insertEventNew = new RTEvent__c();
        insertEventNew.Account__c = acc.Id;
        insertEventNew.Coordinator_Notes_New__c = 'Test Description';
        insertEventNew.Event_Manager_Notes_New__c = 'Test Description';
        insertEventNew.status__c = 'CANCELLED';
        insertEventNew.eventManager__c = usr.Id;
        insert insertEventNew;
       
        // insertEventNew.eventManager__c = UserInfo.getUserId();
        insertEventNew.status__c = 'Closed';
        update insertEventNew;

        Event evnt = new Event();
        evnt.WhatId = insertEventNew.Id;
        evnt.DurationInMinutes = 4;
        evnt.ActivityDate = date.newInstance(2020, 3, 10);
        evnt.ActivityDateTime = datetime.newInstance(2020, 3, 10, 16, 30, 0);
        insert evnt;
    }
}