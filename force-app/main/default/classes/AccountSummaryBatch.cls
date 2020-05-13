/*******************************************************************************************
Name : AccountSummaryBatch
Created On : March 2018
Created By : Timothy Barsotti
Description : Batch Apex to summarize the revenue associated to an account
********************************************************************************************/
public without sharing class AccountSummaryBatch implements Database.Batchable<sObject>, Schedulable {
	public void execute(SchedulableContext sc) {
		Database.ExecuteBatch(new AccountSummaryBatch(), 100);
	}
    public Database.QueryLocator start(Database.BatchableContext bc){
    	String query = 'SELECT Id, Billed_Revenue_Last_13_Months__c FROM Account';
    	return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Account> scope){
        List<Account> acctList = [SELECT Id, Billed_Revenue_Last_13_Months__c, (SELECT Id, Last_13_Months_Billed_Revenue__c FROM PGi_Companies__r) FROM Account WHERE Id IN: scope];
    	List<Account> toUpdate = new List<Account>();
    	for(Account acct: acctList) {
    		Decimal revenue = 0;
    		for(PGI_Company__c comp: acct.PGi_Companies__r) {
    			if(comp.Last_13_Months_Billed_Revenue__c != null){
    				revenue += comp.Last_13_Months_Billed_Revenue__c;
    			}
    		}
    		if(acct.Billed_Revenue_Last_13_Months__c != revenue) {
    			acct.Billed_Revenue_Last_13_Months__c = revenue;
    			toUpdate.add(acct);
    		}
    	}
    	Database.update(toUpdate, false);
    }
    public void finish(Database.BatchableContext bc){

    }
}