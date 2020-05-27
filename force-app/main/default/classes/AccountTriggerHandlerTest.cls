@isTest
public class AccountTriggerHandlerTest {
	private static Account queriedAccount;
	@isTest
	public static void testParent() {
		
	}

	@isTest
	public static void testMapZoomCountries() {

	}

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