/*********************************************************************
Name : Test_UpdateQuoteCEAPriorDateBatch
Created On : Mar 09, 2016
Created By : Archana Rajendran
Description : Test Class for UpdateQuoteCEAPriorDateBatch 
**********************************************************************/

@isTest
private class Test_UpdateQuoteCEAPriorDateBatch {
     @testSetup static void setup() {
       PGITestUtilities.disableSalesWings();
    }
	
    static testmethod void test() 
    {
       Account acc = PGITestUtilities.getAccountDetails();
       insert acc;
       Contact con = PGITestUtilities.getContactDetails(Acc.id);
       insert con;
       Opportunity opp =  PGITestUtilities.getOpportunityDetails();
       opp.accountid = acc.id;
       insert opp;
       CONMAN_Contract__c testPGiContract = new CONMAN_Contract__c();
       testPGiContract.Opportunity__c = opp.Id;
       testPGiContract.Account_Name__c = acc.Id;
       insert testPGiContract;
       //Quote quote = PGITestUtilities.getQuoteDetails(Acc.id,Con.id,Opp.id);
       //quote.File_Store_Contract_Status__c='Active';
       //quote.SC_Auto_renewal_Interval_in_months__c=3;
       //quote.CEA_Date_Active__c =system.TODAY() - 2;
       //insert quote;
       /**/
       Test.startTest();
       UpdateQuoteCEAPriorDateBatch a = new UpdateQuoteCEAPriorDateBatch();
       Database.executeBatch(a);
       Test.stopTest();
       
       //Quote q1=[select id,CEA_Date_Prior_to_Renewal__c,CEA_Date_Active__c from quote where id =: quote.id];
       //System.assertEquals(q1.CEA_Date_Prior_to_Renewal__c,system.TODAY() - 2); 
       /**/
       
             
    }
}