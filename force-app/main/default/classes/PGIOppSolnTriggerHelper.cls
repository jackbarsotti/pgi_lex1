/********************************************************************************
Name:  PGIOppSolnTriggerHelper()  
Copyright © 2012  PGI   
======================================================
======================================================
Purpose:
-------    
To avoid recurssive Trigger
======================================================
======================================================
History
-------
VERSION  AUTHOR                DATE           DETAIL              
1.0    - CapgeminiIndia         13/10/2012         Initial Development 
********************************************************************************/  
Public Class PGIOppSolnTriggerHelper{
	public static set<string> ExecutedTriggers = new set<string>();
	//@isTest(SeeAllData=true)
	@isTest
    private static void testPGIQuoteContractTypeTrigger(){
		 PGITestUtilities.disableSalesWings();
		//Profile testProfile = [select id from Profile where name='PGi Sales User - NA' limit 1];
		//User testUser = PGITestUtilities.getTestUser(testProfile);
		//insert testUser;
        
		Test.startTest();
		//System.runAs(testUser){
            Account testAccount = PGITestUtilities.getAccountDetails();
            insert testAccount;
            Contact testContact = PGITestUtilities.getContactDetails(testAccount.Id);
            insert testContact;
            Opportunity testOpp = PGITestUtilities.getOpportunityDetails();
            insert testOpp;
			Quote testQuote = PGITestUtilities.getQuoteDetails(testAccount.Id, testContact.Id, testOpp.Id);
			insert testQuote;
		//}
		Test.stopTest();
	}
}