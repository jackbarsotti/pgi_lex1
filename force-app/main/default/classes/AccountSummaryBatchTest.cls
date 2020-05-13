@isTest
public class AccountSummaryBatchTest {

	@isTest
	static void testBillingStateError() {
		//TriggerHandler.bypass('AccountReadyTalkTriggerHandler');
		Account with100Revenue = PGITestUtilities.createAccount(true);
		//TriggerHandler.clearBypass('AccountReadyTalkTriggerHandler');
	}

	@isTest
	static void testSummary() {
		//setup 3 accounts
		Account with100Revenue = PGITestUtilities.createAccount(true);
		Account with10Revenue = PGITestUtilities.createAccount(true);
		Account with0Revenue = PGITestUtilities.createAccount(true);
		Account withNoCompanies = PGITestUtilities.createAccount(true);
		//setup 12 companies 
		List<PGI_Company__c> companyList = new List<PGI_Company__c>();
		for(Integer i = 0; i < 5; i++) {
			PGI_Company__c pc = PGITestUtilities.getPGiCompany(with100Revenue.Id);
			pc.Last_13_Months_Billed_Revenue__c = 20;
			companyList.add(pc);
			
			PGI_Company__c pc2 = PGITestUtilities.getPGiCompany(with10Revenue.Id);
			pc2.Last_13_Months_Billed_Revenue__c = 2;
			companyList.add(pc2);
			
			PGI_Company__c pc3 = PGITestUtilities.getPGiCompany(with0Revenue.Id);
			pc3.Last_13_Months_Billed_Revenue__c = null;
			companyList.add(pc3);
		}
		insert companyList;
		companyList = [SELECT Id, Last_13_Months_Billed_Revenue__c FROM PGI_Company__c];
		Integer twenty = 0, two = 0, nullCnt = 0;
		for(PGI_Company__c comp: companyList) {
			if(comp.Last_13_Months_Billed_Revenue__c == 20) {
				twenty++;
			} else if(comp.Last_13_Months_Billed_Revenue__c == 2) {
				two++;
			} else if(comp.Last_13_Months_Billed_Revenue__c == null || comp.Last_13_Months_Billed_Revenue__c == 0) {
				nullCnt++;
			} else {
				System.assert(false, 'Company revenue was not as expected - actual ' + comp.Last_13_Months_Billed_Revenue__c);
			}
		}
		System.assertEquals(nullCnt, 5, 'Incorrrect count found for null values');
		System.assertEquals(twenty, 5, 'Incorrrect count found for twenty values');
		System.assertEquals(two, 5, 'Incorrrect count found for two values');

		List<Account> accountList = [SELECT Id, Billed_Revenue_Last_13_Months__c FROM Account];
		for(Account a: accountList) {
			system.assert(a.Billed_Revenue_Last_13_Months__c == null, a.Billed_Revenue_Last_13_Months__c);
		}
		Test.startTest();
		Database.executeBatch(new AccountSummaryBatch(), 4);
		Test.stopTest();
		Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Billed_Revenue_Last_13_Months__c FROM Account]);

		System.assertEquals(accountMap.get(with100Revenue.Id).Billed_Revenue_Last_13_Months__c, 100, 'Aggregation failed');
		System.assertEquals(accountMap.get(with10Revenue.Id).Billed_Revenue_Last_13_Months__c, 10, 'Aggregation failed');
		System.assertEquals(accountMap.get(with0Revenue.Id).Billed_Revenue_Last_13_Months__c, 0, 'Aggregation failed');
		System.assertEquals(accountMap.get(withNoCompanies.Id).Billed_Revenue_Last_13_Months__c, 0, 'Aggregation failed');
	}
}