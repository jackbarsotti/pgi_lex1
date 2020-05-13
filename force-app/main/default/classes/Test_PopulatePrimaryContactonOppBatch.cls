/*********************************************************************
Name : Test_PopulatePrimaryContactonOppBatch
Created On : Sep 13,2016
Created By : Archana Rajendran
Description : Test Class for PopulatePrimaryContactonOpportunityBatch
**********************************************************************/

@isTest
private class Test_PopulatePrimaryContactonOppBatch {
     @testSetup static void setup() {
       PGITestUtilities.disableSalesWings();
    }
	
    static testmethod void test() 
    {
       Account acc = PGITestUtilities.getAccountDetails();
       acc.website = 'www.test.com';
       insert acc;
       Contact con = PGITestUtilities.getContactDetails(Acc.id);
       insert con;
       Opportunity opp =  PGITestUtilities.getOpportunityDetails();
       opp.accountid = acc.id;
       insert opp;
       OpportunityContactRole ocr = new OpportunityContactRole();
       ocr.OpportunityId = opp.Id;
       ocr.ContactId = con.Id;
       ocr.IsPrimary = TRUE;
       ocr.role='Business User';
       insert ocr;
       
       Test.startTest();
       PopulatePrimaryContactonOpportunityBatch a = new PopulatePrimaryContactonOpportunityBatch();
       Database.executeBatch(a);
       Test.stopTest();
       
       Contact c1=[select id,primary_contact_on_opp__c from contact where id =: con.id];
       System.assertEquals(c1.primary_contact_on_opp__c,true); 
             
    }
}