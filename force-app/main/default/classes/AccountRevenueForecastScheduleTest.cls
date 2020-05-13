@isTest
public class AccountRevenueForecastScheduleTest {
	@TestSetup
	static void setupMethod() {
		Account a1 = PGITestUtilities.createAccount(false);
		a1.Commission_Start_Date__c = System.today();
		a1.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkAccountRecordTypes[0].Id;
		a1.Active_Account__c = true;
		Account a2 = PGITestUtilities.createAccount(false);
		a2.Commission_Start_Date__c = System.today().addYears(-1);
		a2.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkAccountRecordTypes[0].Id;
		a2.Active_Account__c = true;
		Account a3 = PGITestUtilities.createAccount(false);
		a3.Commission_Start_Date__c = System.today().addYears(1);
		a3.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkAccountRecordTypes[0].Id;
		a3.Active_Account__c = true;
		Account a4 = PGITestUtilities.createAccount(false);
		Account a5 = PGITestUtilities.createAccount(false);
		Account a6 = PGITestUtilities.createAccount(false);
		insert new List<Account>{a1, a2, a3, a4, a5, a6};
	}

	@isTest
	static void testBatchJob(){
		Test.startTest();
		AccountRevenueForecastSchedule b = new AccountRevenueForecastSchedule();
		Database.executeBatch(b);
		Test.stopTest();
		Integer currentYear = System.today().year();
		List<Account> aList = [SELECT Id, Commission_Start_Date__c, Revenue_Category__c, RecordTypeId FROM Account];
		Map<Integer, Boolean> testMapResults = new Map<Integer, Boolean>();
		Map<Id, RecordType> readyTalkRTMap = new Map<Id, RecordType>(ReadyTalkRecordTypeHelper.readyTalkAccountRecordTypes);
		for(Account a: aList) {
			if(readyTalkRTMap.keySet().contains(a.RecordTypeId)) {
				if(a.Commission_Start_Date__c.year() == currentYear) {
					System.assertEquals('New', a.Revenue_Category__c);
					testMapResults.put(1, true);
				} else if (a.Commission_Start_Date__c.year() == (currentYear - 1)) {
					System.assertEquals('Transition', a.Revenue_Category__c);
					testMapResults.put(2, true);
				} else {
					System.assertEquals('Base', a.Revenue_Category__c);
					testMapResults.put(3, true);
				}
			} else {
				System.assertEquals(null, a.Revenue_Category__c);
				testMapResults.put(4, true);
			}
		}
		System.assert(testMapResults.get(1), true);
		System.assert(testMapResults.get(2), true);
		System.assert(testMapResults.get(3), true);
		System.assert(testMapResults.get(4), true);
	}
}