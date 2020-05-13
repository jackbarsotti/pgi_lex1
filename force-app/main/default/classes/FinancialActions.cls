public class FinancialActions { 
  /**
  * SFB-1520 Billing Start Date and Commission Start Date on Account
  */
  public static void insertStartDates(List<NetSuite_Financial__c> financialsIn) {
    Set<Id> financialIds = new Set<Id>();

    for(NetSuite_Financial__c financial : financialsIn){
      financialIds.add(financial.Id);
    }

    List<NetSuite_Financial__c> financials = (List<NetSuite_Financial__c>)[select Id, Revenue_Total__c, Account__r.Billing_Start_Date__c,
        Account__r.Commission_Start_Date__c, Transaction_Date__c from NetSuite_Financial__c where Id in :financialIds];

    //Modify the values
    for(NetSuite_Financial__c financial : financials){
      System.debug('financial.Id = ' + financial.Id);
      if (financial.Account__r.Billing_Start_Date__c == null) {
        Account account = new Account();
        account.Id = financial.Account__c;
        account.Billing_Start_Date__c = financial.Transaction_Date__c;
        update(account);
      }
      if (financial.Account__r.Commission_Start_Date__c == null && financial.Revenue_Total__c != null && financial.Revenue_Total__c > 0) {
        Account account = new Account();
        account.Id = financial.Account__c;
        account.Commission_Start_Date__c = financial.Transaction_Date__c;
        update(account);
      } 
    }
  }
}