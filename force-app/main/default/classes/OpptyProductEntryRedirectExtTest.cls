@isTest
public class OpptyProductEntryRedirectExtTest {
    @testSetup static void setup(){
        Id pgiRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('PGi_Opportunity').getRecordTypeId();
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
        oppor.RecordTypeId=pgiRT;
        oppor.Opportunity_Deal_Type__c='Win Back';
        insert oppor;
    }
    static testMethod Void testOpprRTPGI(){
        Opportunity oppor =[Select Id,RecordTypeId,Opportunity_Deal_Type__c from Opportunity where name = 'Test oppor-1']; 
        PageReference pageRef = Page.OpportunityProductEntryRedirect;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(oppor);
        ApexPages.currentPage().getParameters().put('id',oppor.Id);
        OpportunityProductEntryRedirectExtension obj = new OpportunityProductEntryRedirectExtension(sc);
        obj.redirect();
        PageReference expectedPage  = new PageReference('/apex/opportunityProductEntry?id=' + oppor.Id);
        System.assertEquals(expectedPage.getUrl(), obj.redirect().getUrl());
    }
    static testMethod Void testOpprNullCond(){
        Opportunity oppor =[Select Id,RecordTypeId,Opportunity_Deal_Type__c from Opportunity where name = 'Test oppor-1']; 
        oppor.Opportunity_Deal_Type__c=null;
        Update oppor;
        PageReference pageRef = Page.OpportunityProductEntryRedirect;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(oppor);
        ApexPages.currentPage().getParameters().put('id',oppor.Id);
        OpportunityProductEntryRedirectExtension obj = new OpportunityProductEntryRedirectExtension(sc);
        System.assertEquals(null, obj.redirect());
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertEquals(1, pageMessages.size());
    }
    static testMethod Void testOpprRTiMC(){
        Id iMcRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('iMC_Opportunity').getRecordTypeId();
        Opportunity oppor =[Select Id,RecordTypeId,Opportunity_Deal_Type__c from Opportunity where name = 'Test oppor-1']; 
        oppor.RecordTypeId=iMcRT;
        Update oppor;
        PageReference pageRef = Page.OpportunityProductEntryRedirect;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(oppor);
        ApexPages.currentPage().getParameters().put('id',oppor.Id);
        OpportunityProductEntryRedirectExtension obj = new OpportunityProductEntryRedirectExtension(sc);
        PageReference expectedPage  = new PageReference('/apex/ReadyTalkOpportunityProductEntry?id=' + oppor.Id);
        System.assertEquals(expectedPage.getUrl(), obj.redirect().getUrl());
    }
}