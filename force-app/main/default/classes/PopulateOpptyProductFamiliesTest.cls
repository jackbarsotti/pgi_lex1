@isTest
public class PopulateOpptyProductFamiliesTest {
    @testSetup static void setup(){
       /* PGITestUtilities.disableSalesWings();*/
        Account act = new account(Name = 'Test32',ABM_Last_PES__c='testData',ABM_PES_Last_Change_Date__c =Date.today(),Bill_Address_Verification__c =Date.today().AddDays(2), Z_Source__c = 'eCommerce');
        insert act;
        Opportunity oppor = new Opportunity();
        oppor.name = 'Test oppor-1';
        oppor.stagename = 'Awareness';
        oppor.ECommerce_Convert__c=false;
        oppor.closeDate= system.today().addDays(100);
        oppor.ECommerce_Account_Number__c = 'Ecom-000000001';
        oppor.accountid = act.id;
        oppor.Z_Source__c = 'eCommerce';
        oppor.Acct_Admin_Decison_Maker_Checked__c = 'Yes';
        insert oppor;
       /* Product2 standardProduct = PGITestUtilities.getStdProduct();
        insert standardProduct;
        PricebookEntry standardPbe = PGITestUtilities.CreatePriceBookEntryForProduct(standardProduct);
        insert standardPbe;
        OpportunityLineItem oli = PGITestUtilities.getOpportunityLineItemDetails(oppor.Id, standardPbe.Id);
        oli.Existing_Service__c = false;
        insert oli; */
    }
    static testMethod void testBeforeUpdate(){
        Opportunity oppr = [Select Id ,name,stagename,ECommerce_Convert__c,closeDate,ECommerce_Account_Number__c,Accountid,Z_Source__c,Acct_Admin_Decison_Maker_Checked__c from opportunity Where Name='Test oppor-1'];
    	oppr.name='Test1';
        Update oppr;
    }
}