@isTest
private class AccountUltimateParentBilledRevBatchTest {
	static Account testUltimateParentAccount {get;set;}
	static Account testAccountChild {get;set;}
	static Account testAccountGrandChild {get;set;}
	static Account testAccountGreatGrandChild {get;set;}

	static PGi_Company__c testPGiCompany {get;set;}
	static CONMAN_Contract__c testPGiContract {get;set;}
	
	
	static testMethod void testScheduleBatch() {
		Test.startTest();
		AccountUltimateParentBilledRevenueBatch ultimateParentBatch = new AccountUltimateParentBilledRevenueBatch();
		String sch = '0 0 23 * * ?'; 
		System.schedule('Test Account Ultimate Parent Revenue Batch', sch, ultimateParentBatch);
		Test.stopTest();
	}

	static testMethod void testRunBatchNow() {
		Init();

		Test.startTest();
		Database.executeBatch(new AccountUltimateParentBilledRevenueBatch());
		Test.stopTest();

		System.assertEquals(50, [SELECT Id, Ultimate_Parent_Billed_Revenue__c FROM Account WHERE Id = :testUltimateParentAccount.Id].Ultimate_Parent_Billed_Revenue__c);
		System.assertEquals([SELECT Id, Ultimate_Parent_Account__c FROM Account WHERE Id = :testAccountChild.Id].Ultimate_Parent_Account__c, testUltimateParentAccount.Id);		
		System.assertEquals([SELECT Id, Ultimate_Parent_Account__c FROM Account WHERE Id = :testAccountGrandChild.Id].Ultimate_Parent_Account__c, testUltimateParentAccount.Id);
		System.assertEquals([SELECT Id, Ultimate_Parent_Account__c FROM Account WHERE Id = :testAccountGreatGrandChild.Id].Ultimate_Parent_Account__c, testUltimateParentAccount.Id);
	}

	static void Init() {
		testUltimateParentAccount = PGITestUtilities.createAccount(false);
		testUltimateParentAccount.Billed_Revenue_Last_13_Months__c = 5;
		insert testUltimateParentAccount;
		testAccountChild = PGITestUtilities.createAccount(false);
		testAccountChild.Billed_Revenue_Last_13_Months__c = 10;
		testAccountChild.ParentId = testUltimateParentAccount.Id;
		insert testAccountChild;
		testAccountGrandChild = PGITestUtilities.createAccount(false);
		testAccountGrandChild.Billed_Revenue_Last_13_Months__c = 15;
		testAccountGrandChild.ParentId = testAccountChild.Id;
		insert testAccountGrandChild;
		testAccountGreatGrandChild = PGITestUtilities.createAccount(false);
		testAccountGreatGrandChild.Billed_Revenue_Last_13_Months__c = 20;
		testAccountGreatGrandChild.ParentId = testAccountGrandChild.Id;
		insert testAccountGreatGrandChild;

		testPGiCompany = PGITestUtilities.createCompany(PGITestUtilities.createEntity(true), false);
		testPGiCompany.RelatedAccount__c = testAccountChild.Id;
		insert testPGiCompany;

		testPGiContract = PGITestUtilities.createConManContract(testAccountChild, PGITestUtilities.createOpportunity(testAccountChild, true), false);
		testPGiContract.Account_Name__c = testAccountChild.Id;
		insert testPGiContract;
	}
}