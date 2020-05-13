@isTest
public class EventWebcastingRateTest {
	@isTest
	public static void testDuplicates() {
	    Account testWithDuplicate = new Account();
	    testWithDuplicate.Name = 'test';
	    //testWithDuplicate.Billing_State__c = 'CO';
	    testWithDuplicate.Invoice_Types__c = 'Account Summary';
	    testWithDuplicate.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkAccountRecordTypes[0].Id;

	    Account testWithoutDuplicate = new Account();
	    testWithoutDuplicate.Name = 'test';
	    //testWithoutDuplicate.Billing_State__c = 'CO';
	    testWithoutDuplicate.Invoice_Types__c = 'Account Summary';
	    testWithoutDuplicate.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkAccountRecordTypes[0].Id;
	    insert new List<Account>{testWithDuplicate, testWithoutDuplicate};

	    delete [SELECT Id FROM Event_Webcasting_Rates__c WHERE Related_Account__c =: testWithoutDuplicate.Id];
	    //reset the trigger handler
	    EventWebcastingRateTriggerHandler.existingWebcastingRates = null;
	    Event_Webcasting_Rates__c rate1 = new Event_Webcasting_Rates__c(Related_Account__c = testWithoutDuplicate.Id);

	    Event_Webcasting_Rates__c rate2 = new Event_Webcasting_Rates__c(Related_Account__c = testWithDuplicate.Id);

	    Database.insert(new List<Event_Webcasting_Rates__c>{rate1, rate2}, false);

	    System.assert([SELECT Id FROM Event_Webcasting_Rates__c].size() == 2);
	}
}