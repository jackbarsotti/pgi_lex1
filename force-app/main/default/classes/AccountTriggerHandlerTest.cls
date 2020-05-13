@isTest
public class AccountTriggerHandlerTest {
	private static Account queriedAccount;
	@isTest
	public static void testParent() {
		
	}

	@isTest
	public static void testMapZoomCountries() {

	}
//moved to batch job
	//static testMethod void testPGi_Account_Billed_Revenue_Last_13_Mont() {

	//	//
 //       // SELECT Last_13_Months_Billed_Revenue__c , RelatedAccount__c FROM PGi_Company__c WHERE isDeleted = false ORDER BY Id DESC NULLS LAST
 //       //
 //       //
 //       // PGi_Company__c > Last_13_Months_Billed_Revenue__c 
 //       //
 //       //
 //       // CURRENCY to rollup into Account.Billed_Revenue_Last_13_Months__c
 //       //

 //       Account testAcct = new Account(); 
 //       testAcct.Name = 'test';
 //       insert testAcct;

 //       List<PGi_Company__c> testRecords = new List<PGi_Company__c>();
 //       for(Integer i = 0, j = 0; i < 3; i++) {
        
 //           testRecords.add(new PGi_Company__c(RelatedAccount__c = testAcct.Id, Last_13_Months_Billed_Revenue__c = 10));
 //       }   
 //       insert testRecords;

 //       Test.startTest();

 //       System.assertEquals([SELECT Billed_Revenue_Last_13_Months__c FROM Account WHERE Id = :testAcct.Id].Billed_Revenue_Last_13_Months__c, 30);

 //       Test.stopTest();
	//}

	static testMethod void testNumberofZenDeskTicketsSubmitted_Last_5_Days() {
		//
        // SELECT Zendesk__Ticket_Form_Id__c , Zendesk__Organization__c FROM Zendesk__Zendesk_Ticket__c WHERE isDeleted = false
        //
        //
        // Account.of_Tickets_Last_5_Days__c
        //
        //
        // Zendesk__Zendesk_Ticket__c > Zendesk__Ticket_Form_Id__c 
        //

        Account testAcct = new Account(); 
        testAcct.Name = 'test';
        insert testAcct;

        List<Zendesk__Zendesk_Ticket__c> testRecords = new List<Zendesk__Zendesk_Ticket__c>();
        for(Integer i = 0, j = 0; i < 3; i++) {
        
            testRecords.add(new Zendesk__Zendesk_Ticket__c(Zendesk__Organization__c = testAcct.Id, Zendesk__Ticket_Form_Id__c = i));
        }   
        insert testRecords;

        Test.startTest();

        System.assertEquals([SELECT of_Tickets_Last_5_Days__c FROM Account WHERE Id = :testAcct.Id].of_Tickets_Last_5_Days__c, 3);

        Test.stopTest();
	}

	// static testMethod void testAccount_Count_of_Leads() {
    //     //
    //     // SELECT IsDeleted, Account__c FROM Lead WHERE isDeleted = false
    //     //
    //     //
    //     // Account.Count_of_Leads__c
    //     //

    //     Account testAcct = new Account(); 
    //     testAcct.Name = 'test';
    //     insert testAcct;

    //     List<Lead> testRecords = new List<Lead>();
    //     for(Integer i = 0, j = 0; i < 3; i++) {
        
    //         testRecords.add(new Lead(Account__c = testAcct.Id, LastName = 'test', Company = 'test', Email = 'test@test.com'));
    //     }   
    //     insert testRecords;

    //     Test.startTest();

    //     System.assertEquals([SELECT Count_of_Leads__c FROM Account WHERE Id = :testAcct.Id].Count_of_Leads__c, 3);

    //     Test.stopTest();
    // }
	
	@isTest
	public static void testSameAsUltimate() {
		DandBCompany ultimateDb = PGITestUtilities.createDandBCompany('123', '123', true);
		Account a = PGITestUtilities.createAccount(false);
		a.DandBCompanyId = ultimateDb.Id;
		a.DUNSNumber = '123';
		a.DUNS_Number__c = '123';
		//a.Channel__c = 'Marketing';
		a.RecordTypeId = AccountTriggerHandler.PGIRecordTypeId;
		insert a;
		queriedAccount = [SELECT Id, ParentId FROM Account];
		System.assert(queriedAccount.ParentId == null);
		AccountTriggerHandler.parentsChecked = new Set<Id>();
		update a;
		queriedAccount = [SELECT Id, ParentId FROM Account];
		System.assert(queriedAccount.ParentId == null);

	}
	@isTest
	public static void testDuplicateParent() {
		DandBCompany ultimateDb = PGITestUtilities.createDandBCompany('123', '123', true);
		DandBCompany childDb = PGITestUtilities.createDandBCompany('321', '123', true);
		Account parentAcct = PGITestUtilities.createAccount(false);
		parentAcct.DandBCompanyId = ultimateDb.Id;
		parentAcct.DUNS_Number__c = '123';
		parentAcct.DUNSNumber = '123';
		//parentAcct.Channel__c = 'Marketing';
		parentAcct.RecordTypeId = AccountTriggerHandler.PGIRecordTypeId;
		insert parentAcct;

		Account dupeParentAcct = PGITestUtilities.createAccount(false);
		dupeParentAcct.DandBCompanyId = ultimateDb.Id;
		dupeParentAcct.DUNS_Number__c = '123';
		dupeParentAcct.DUNSNumber = '123';
		//dupeParentAcct.Channel__c = 'Marketing';
		dupeParentAcct.RecordTypeId = AccountTriggerHandler.PGIRecordTypeId;
		insert dupeParentAcct;
		queriedAccount = [SELECT Id, Potiential_Duplicate_via_DUNS__c, DuplicateDetectedforParentLookup__c FROM Account WHERE Id =: dupeParentAcct.Id];
		System.assert(queriedAccount.Potiential_Duplicate_via_DUNS__c == true, 'failed to set potential duplicate');
		System.assert(queriedAccount.DuplicateDetectedforParentLookup__c == true, 'failed to set potential duplicate parent');
		Account childAcct = PGITestUtilities.createAccount(false);
		childAcct.DandBCompanyId = childDb.Id;
		childAcct.DUNSNumber = '321';
		childAcct.DUNS_Number__c = '321';
		//childAcct.Channel__c = 'Marketing';
		childAcct.RecordTypeId = AccountTriggerHandler.PGIRecordTypeId;
		insert childAcct;
		queriedAccount = [SELECT Id, ParentId, Potiential_Duplicate_via_DUNS__c, DuplicateDetectedforParentLookup__c FROM Account WHERE Id =: childAcct.Id];
		System.assert(queriedAccount.Potiential_Duplicate_via_DUNS__c == false, 'set as potential duplicate');
		System.assert(queriedAccount.DuplicateDetectedforParentLookup__c == true, 'failed to set potential duplicate parent');

		System.assert(queriedAccount.ParentId == null, 'set parent!!');

		delete dupeParentAcct;

		AccountTriggerHandler.parentsChecked = new Set<Id>();
		update childAcct;
		queriedAccount = [SELECT Id, ParentId, Potiential_Duplicate_via_DUNS__c, DuplicateDetectedforParentLookup__c FROM Account WHERE Id =: childAcct.Id];
		System.assert(queriedAccount.ParentId == parentAcct.Id, 'failed to set parent!!');
		System.assert(queriedAccount.Potiential_Duplicate_via_DUNS__c == false, 'set as potential duplicate');
		System.assert(queriedAccount.DuplicateDetectedforParentLookup__c == false, 'set potential duplicate parent');
	}
    
  /*  @isTest
    public static void testSetConvertedMQAFieldOnOpportunity(){
          PGITestUtilities.disableSalesWings();
          Account a1 = PGITestUtilities.createAccount(false);
          a1.Global_Account_MQA__c=true;
          a1.Global_Account_MQA_Assignment_date__c=Date.today().addDays(-2);
          Account a2 = PGITestUtilities.createAccount(false);
          a2.Global_Account_MQA__c=true;
          a2.Global_Account_MQA_Assignment_date__c=Date.today().addDays(4);        
          insert new List<Account>{a1, a2};
              
         Opportunity o1a1=PGITestUtilities.createOpportunity(a1, false); 
         o1a1.CreatedDate=Date.today();
         Opportunity o2a2=PGITestUtilities.createOpportunity(a2, false); 
         o2a2.CreatedDate=Date.today();
         insert new List<Opportunity>{o1a1,o2a2};
             
         Opportunity o=[SELECT Id,Converted_from_MQA__c FROM Opportunity WHERE Id=:o1a1.Id];    
         System.assertEquals(false,o.Converted_from_MQA__c);    
    } */
}