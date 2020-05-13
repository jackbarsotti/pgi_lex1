@isTest
public class OpportunityProductExtensionTest {
    @testSetup static void setup(){
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
        Product2 standardProduct = PGITestUtilities.getStdProduct();
        insert standardProduct;
        PricebookEntry standardPbe = PGITestUtilities.CreatePriceBookEntryForProduct(standardProduct);
        insert standardPbe;
        OpportunityLineItem oli = PGITestUtilities.getOpportunityLineItemDetails(oppor.Id, standardPbe.Id);
        oli.Existing_Service__c = false;
        insert oli; 
    }
    static testMethod Void testOpprProdExtention(){
        Opportunity opp = [SELECT Id, RecordType.DeveloperName FROM Opportunity where name = 'Test oppor-1'];       
        String recordType =opp.RecordType.DeveloperName;
        OpportunityLineItem oppLineItem =[Select Id,OpportunityId from OpportunityLineItem Where Existing_Service__c = false]; 
        PageReference pageRef = Page.OpportunityProductViewPage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(oppLineItem);
        OpportunityProductExtension obj = new OpportunityProductExtension(sc);
        Opportunity oppty =obj.oppty;
        String opptyRecordTypeName = obj.opptyRecordTypeName;
        List<Schema.FieldSetMember> fieldSet =obj.fieldSet;
        List<LayoutDescriberHelper.LayoutSection> layoutSections=obj.layoutSections;
        System.assertEquals(opp,oppty);
        System.assertEquals(recordType,opptyRecordTypeName);
    }

}