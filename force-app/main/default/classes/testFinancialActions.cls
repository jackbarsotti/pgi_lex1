@isTest
public class testFinancialActions {
    
  static testMethod void testFinancialTriggerWithInsert() {
    // dummy test to fire trigger action.
    NetSuite_Financial__c financial = new NetSuite_Financial__c();
    financial.Transaction_Date__c = Date.today();
    financial.Name = '1234';
    financial.Account__c = MockAccount.getNewAccount().Id;
    insert financial;
    
    System.assert(true);
  }
    
  static testMethod void testInsertStartDatesWithRevenue () {
	Account acct = MockAccount.getNewAccount();
    System.assert(acct.Billing_Start_Date__c == null);
    System.assert(acct.Commission_Start_Date__c == null);
    NetSuite_Financial__c financial = new NetSuite_Financial__c();
    financial.Transaction_Date__c = Date.today();
    financial.Name = '1234';
    financial.Account__c = acct.Id;
    financial.Revenue_Total__c = 20.40;
    insert financial;
    acct = [select Id, Billing_Start_Date__c, Commission_Start_Date__c from Account where Id = :acct.Id];
    System.assert(acct.Billing_Start_Date__c == Date.today());
    System.assert(acct.Commission_Start_Date__c == Date.today());
  }

  static testMethod void testInsertStartDatesWithoutRevenue () {
	Account acct = MockAccount.getNewAccount();
    System.assert(acct.Billing_Start_Date__c == null);
    System.assert(acct.Commission_Start_Date__c == null);
    NetSuite_Financial__c financial = new NetSuite_Financial__c();
    financial.Transaction_Date__c = Date.today();
    financial.Name = '1234';
    financial.Account__c = acct.Id;
    insert financial;
    acct = [select Id, Billing_Start_Date__c, Commission_Start_Date__c from Account where Id = :acct.Id];
    System.assert(acct.Billing_Start_Date__c == Date.today());
    System.assert(acct.Commission_Start_Date__c == null);
  }

  static testMethod void testInsertStartDatesWhenDatesAlreadyExist () {
	Account acct = MockAccount.getNewAccount();
    acct.Billing_Start_Date__c = Date.today() -3;
    acct.Commission_Start_Date__c = Date.today() - 2;
	update acct;      
    NetSuite_Financial__c financial = new NetSuite_Financial__c();
    financial.Transaction_Date__c = Date.today();
    financial.Name = '1234';
    financial.Revenue_Total__c = 20.40;
    financial.Account__c = acct.Id;
    insert financial;
    acct = [select Id, Billing_Start_Date__c, Commission_Start_Date__c from Account where Id = :acct.Id];
    System.assert(acct.Billing_Start_Date__c == Date.today() - 3);
    System.assert(acct.Commission_Start_Date__c == Date.today() - 2);
  }

}