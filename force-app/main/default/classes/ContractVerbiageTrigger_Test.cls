@isTest
public class ContractVerbiageTrigger_Test {
    static testMethod void testUpdatingProductPricingContentFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        Contract_Terms__c verbiage = new Contract_Terms__c(Name='Testing', Terms_and_Conditions_RTF__c='Original Product Terms', Unique_ID__c='1');
        insert verbiage;

        CONMAN_Contract_Verbiage__c contractVerbiage = new CONMAN_Contract_Verbiage__c(Name='Testing', Verbiage__c='Original Product Terms', Contract_Product_Verbiage__c=verbiage.Id, PGi_Contract__c=testContract.Id,
                                                                                      Pricing_Team_Changes_Allowed__c=True);
        insert contractVerbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract did not start as not needing Billing Approval');

        Test.startTest();
        contractVerbiage.Verbiage__c = 'New Info';
        update contractVerbiage;
        Test.stopTest();

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'Contract did not need Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(true, contractVerbiage.Modified__c,
                            'Contract Verbiage not marked as Modified');
    }

    static testMethod void testUpdatingBillingFootnotesFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        Contract_Terms__c verbiage = new Contract_Terms__c(Name='Services & Pricing Schedule Billing Footnotes', Terms_and_Conditions_RTF__c='Original Product Terms', Unique_ID__c='1');
        insert verbiage;

        CONMAN_Contract_Verbiage__c contractVerbiage = new CONMAN_Contract_Verbiage__c(Name='Services & Pricing Schedule Billing Footnotes', Verbiage__c='Original Product Terms', Contract_Product_Verbiage__c=verbiage.Id, PGi_Contract__c=testContract.Id,
                                                                                      Pricing_Team_Changes_Allowed__c=False);
        insert contractVerbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract did not start as not needing Billing Approval');

        Test.startTest();
        contractVerbiage.Verbiage__c = 'New Info';
        update contractVerbiage;
        Test.stopTest();

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'Contract did not need Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(true, contractVerbiage.Modified__c,
                            'Contract Verbiage not marked as Modified');
    }

    static testMethod void testUpdatingGeneralPricingContentFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        PGIServicesInformation__c verbiage = new PGIServicesInformation__c(Name='Testing', Agreement_Type__c='Subscription License Order', Section__c='Intro', Order__c=1, Content_RTF__c='Original General Terms', Unique_ID__c='1');
        insert verbiage;

        CONMAN_Contract_Verbiage__c contractVerbiage = new CONMAN_Contract_Verbiage__c(Name='Testing', Verbiage__c='Original General Terms', Contract_General_Content__c=verbiage.Id, PGi_Contract__c=testContract.Id,
                                                                                      Pricing_Team_Changes_Allowed__c=True);
        insert contractVerbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract did not start as not needing Billing Approval');

        Test.startTest();
        contractVerbiage.Verbiage__c = 'New Info';
        update contractVerbiage;
        Test.stopTest();

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'Contract did not need Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(true, contractVerbiage.Modified__c,
                            'Contract Verbiage not marked as Modified');
    }

    static testMethod void testInsertingGeneralPricingContentFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        PGIServicesInformation__c verbiage = new PGIServicesInformation__c(Name='Testing', Agreement_Type__c='Subscription License Order', Section__c='Intro', Order__c=1, Content_RTF__c='Original General Terms', Unique_ID__c='1');
        insert verbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract did not start as not needing Billing Approval');

        Test.startTest();
        CONMAN_Contract_Verbiage__c contractVerbiage = new CONMAN_Contract_Verbiage__c(Name='Testing', Verbiage__c='Custom General Terms', Contract_General_Content__c=verbiage.Id, PGi_Contract__c=testContract.Id,
                                                                                      Pricing_Team_Changes_Allowed__c=True);
        insert contractVerbiage;
        Test.stopTest();

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract needed Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(true, contractVerbiage.Modified__c,
                            'Contract Verbiage not marked as Modified');
    }

    static testMethod void testInsertingProductPricingContentFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        Contract_Terms__c verbiage = new Contract_Terms__c(Name='Testing', Terms_and_Conditions_RTF__c='Original Product Terms', Unique_ID__c='1');
        insert verbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract did not start as not needing Billing Approval');

        Test.startTest();
        CONMAN_Contract_Verbiage__c contractVerbiage = new CONMAN_Contract_Verbiage__c(Name='Testing', Verbiage__c='Custom Product Terms', Contract_Product_Verbiage__c=verbiage.Id, PGi_Contract__c=testContract.Id,
                                                                                      Pricing_Team_Changes_Allowed__c=True);
        insert contractVerbiage;
        Test.stopTest();

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract needed Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(true, contractVerbiage.Modified__c,
                            'Contract Verbiage not marked as Modified');
    }

    static testMethod void testInsertingGeneralNoPricingContentFlagsNoBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        PGIServicesInformation__c verbiage = new PGIServicesInformation__c(Name='Testing', Agreement_Type__c='Subscription License Order', Section__c='Intro', Order__c=1, Content_RTF__c='Original General Terms', Unique_ID__c='1');
        insert verbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract did not start as not needing Billing Approval');

        Test.startTest();
        CONMAN_Contract_Verbiage__c contractVerbiage = new CONMAN_Contract_Verbiage__c(Name='Testing', Verbiage__c='Custom General Terms', Contract_General_Content__c=verbiage.Id, PGi_Contract__c=testContract.Id,
                                                                                      Pricing_Team_Changes_Allowed__c=False);
        insert contractVerbiage;
        Test.stopTest();

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract needed Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(true, contractVerbiage.Modified__c,
                            'Contract Verbiage not marked as Modified');
    }

    static testMethod void testInsertingProductNoPricingContentFlagsNoBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        Contract_Terms__c verbiage = new Contract_Terms__c(Name='Testing', Terms_and_Conditions_RTF__c='Original Product Terms', Unique_ID__c='1');
        insert verbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract did not start as not needing Billing Approval');

        Test.startTest();
        CONMAN_Contract_Verbiage__c contractVerbiage = new CONMAN_Contract_Verbiage__c(Name='Testing', Verbiage__c='Custom Product Terms', Contract_Product_Verbiage__c=verbiage.Id, PGi_Contract__c=testContract.Id,
                                                                                      Pricing_Team_Changes_Allowed__c=False);
        insert contractVerbiage;
        Test.stopTest();

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract needed Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(true, contractVerbiage.Modified__c,
                            'Contract Verbiage not marked as Modified');
    }

    static testMethod void testUpdatingProductNonPricingContentFlagsNoBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        Contract_Terms__c verbiage = new Contract_Terms__c(Name='Testing', Terms_and_Conditions_RTF__c='Original Product Terms', Unique_ID__c='1');
        insert verbiage;

        CONMAN_Contract_Verbiage__c contractVerbiage = new CONMAN_Contract_Verbiage__c(Name='Testing', Verbiage__c='Original Product Terms', Contract_Product_Verbiage__c=verbiage.Id, PGi_Contract__c=testContract.Id,
                                                                                      Pricing_Team_Changes_Allowed__c=False);
        insert contractVerbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract did not start as not needing Billing Approval');

        Test.startTest();
        contractVerbiage.Verbiage__c = 'New Info';
        update contractVerbiage;
        Test.stopTest();

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract needed Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(true, contractVerbiage.Modified__c,
                            'Contract Verbiage not marked as Modified');
    }

    static testMethod void testUpdatingGeneralNonPricingContentFlagsNoBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        PGIServicesInformation__c verbiage = new PGIServicesInformation__c(Name='Testing', Agreement_Type__c='Subscription License Order', Section__c='Intro', Order__c=1, Content_RTF__c='Original General Terms', Unique_ID__c='1');
        insert verbiage;

        CONMAN_Contract_Verbiage__c contractVerbiage = new CONMAN_Contract_Verbiage__c(Name='Testing', Verbiage__c='Original General Terms', Contract_General_Content__c=verbiage.Id, PGi_Contract__c=testContract.Id,
                                                                                      Pricing_Team_Changes_Allowed__c=False);
        insert contractVerbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract did not start as not needing Billing Approval');

        Test.startTest();
        contractVerbiage.Verbiage__c = 'New Info';
        update contractVerbiage;
        Test.stopTest();

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract needed Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(true, contractVerbiage.Modified__c,
                            'Contract Verbiage not marked as Modified');
    }

    static testMethod void testUpdatingGeneralPricingContentThenNameFlagsNoBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        PGIServicesInformation__c verbiage = new PGIServicesInformation__c(Name='Testing', Agreement_Type__c='Subscription License Order', Section__c='Intro', Order__c=1, Content_RTF__c='Original General Terms', Unique_ID__c='1');
        insert verbiage;

        CONMAN_Contract_Verbiage__c contractVerbiage = new CONMAN_Contract_Verbiage__c(Name='Testing', Verbiage__c='Original General Terms', Contract_General_Content__c=verbiage.Id, PGi_Contract__c=testContract.Id,
                                                                                      Pricing_Team_Changes_Allowed__c=True);
        insert contractVerbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract did not start as not needing Billing Approval');

        Test.startTest();
        contractVerbiage.Verbiage__c = 'New Info';
        update contractVerbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'Contract did not need Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(true, contractVerbiage.Modified__c,
                            'Contract Verbiage not marked as Modified');

        testContract.Required_Approval_Billing__c = false;
        update testContract;

        contractVerbiage.Modified__c = false;
        update contractVerbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract needed Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(false, contractVerbiage.Modified__c,
                            'Contract Verbiage marked as Modified');

        contractVerbiage.Name = 'New Name';
        update contractVerbiage;
        Test.stopTest();

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract needed Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(false, contractVerbiage.Modified__c,
                            'Contract Verbiage marked as Modified');
    }

    static testMethod void testUpdatingGeneralPricingContentTwiceFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        PGIServicesInformation__c verbiage = new PGIServicesInformation__c(Name='Testing', Agreement_Type__c='Subscription License Order', Section__c='Intro', Order__c=1, Content_RTF__c='Original General Terms', Unique_ID__c='1');
        insert verbiage;

        CONMAN_Contract_Verbiage__c contractVerbiage = new CONMAN_Contract_Verbiage__c(Name='Testing', Verbiage__c='Original General Terms', Contract_General_Content__c=verbiage.Id, PGi_Contract__c=testContract.Id,
                                                                                      Pricing_Team_Changes_Allowed__c=True);
        insert contractVerbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract did not start as not needing Billing Approval');

        Test.startTest();
        contractVerbiage.Verbiage__c = 'New Info';
        update contractVerbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'Contract did not need Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(true, contractVerbiage.Modified__c,
                            'Contract Verbiage not marked as Modified');

        testContract.Required_Approval_Billing__c = false;
        update testContract;

        contractVerbiage.Modified__c = false;
        update contractVerbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract needed Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(false, contractVerbiage.Modified__c,
                            'Contract Verbiage marked as Modified');

        contractVerbiage.Verbiage__c = 'New Testing Info v2';
        update contractVerbiage;
        Test.stopTest();

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'Contract did not need Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(true, contractVerbiage.Modified__c,
                            'Contract Verbiage not marked as Modified');
    }

    static testMethod void testUpdatingProductNonPricingToUnknownFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        Contract_Terms__c verbiage = new Contract_Terms__c(Name='Testing', Terms_and_Conditions_RTF__c='Original Product Terms', Unique_ID__c='1');
        insert verbiage;

        CONMAN_Contract_Verbiage__c contractVerbiage = new CONMAN_Contract_Verbiage__c(Name='Testing', Verbiage__c='Original Product Terms', Contract_Product_Verbiage__c=verbiage.Id, PGi_Contract__c=testContract.Id,
                                                                                      Pricing_Team_Changes_Allowed__c=False);
        insert contractVerbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract did not start as not needing Billing Approval');

        Test.startTest();
        contractVerbiage.Contract_Product_Verbiage__c = null;
        update contractVerbiage;
        Test.stopTest();

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'Contract did not need Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(true, contractVerbiage.Modified__c,
                            'Contract Verbiage not marked as Modified');
    }

    static testMethod void testUpdatingProductPricingToUnknownFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        Contract_Terms__c verbiage = new Contract_Terms__c(Name='Testing', Terms_and_Conditions_RTF__c='Original Product Terms', Unique_ID__c='1');
        insert verbiage;

        CONMAN_Contract_Verbiage__c contractVerbiage = new CONMAN_Contract_Verbiage__c(Name='Testing', Verbiage__c='Original Product Terms', Contract_Product_Verbiage__c=verbiage.Id, PGi_Contract__c=testContract.Id,
                                                                                      Pricing_Team_Changes_Allowed__c=True);
        insert contractVerbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract did not start as not needing Billing Approval');

        Test.startTest();
        contractVerbiage.Contract_Product_Verbiage__c = null;
        update contractVerbiage;
        Test.stopTest();

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'Contract did not need Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(true, contractVerbiage.Modified__c,
                            'Contract Verbiage not marked as Modified');
    }

    static testMethod void testUpdatingGeneralNonPricingToUnknownFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        PGIServicesInformation__c verbiage = new PGIServicesInformation__c(Name='Testing', Agreement_Type__c='Subscription License Order', Section__c='Intro', Order__c=1, Content_RTF__c='Original General Terms', Unique_ID__c='1');
        insert verbiage;

        CONMAN_Contract_Verbiage__c contractVerbiage = new CONMAN_Contract_Verbiage__c(Name='Testing', Verbiage__c='Original General Terms', Contract_General_Content__c=verbiage.Id, PGi_Contract__c=testContract.Id,
                                                                                      Pricing_Team_Changes_Allowed__c=False);
        insert contractVerbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract did not start as not needing Billing Approval');

        Test.startTest();
        contractVerbiage.Contract_General_Content__c = null;
        update contractVerbiage;
        Test.stopTest();

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'Contract did not need Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(true, contractVerbiage.Modified__c,
                            'Contract Verbiage not marked as Modified');
    }

    static testMethod void testUpdatingGeneralPricingToUnknownFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        PGIServicesInformation__c verbiage = new PGIServicesInformation__c(Name='Testing', Agreement_Type__c='Subscription License Order', Section__c='Intro', Order__c=1, Content_RTF__c='Original General Terms', Unique_ID__c='1');
        insert verbiage;

        CONMAN_Contract_Verbiage__c contractVerbiage = new CONMAN_Contract_Verbiage__c(Name='Testing', Verbiage__c='Original General Terms', Contract_General_Content__c=verbiage.Id, PGi_Contract__c=testContract.Id,
                                                                                      Pricing_Team_Changes_Allowed__c=True);
        insert contractVerbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract did not start as not needing Billing Approval');

        Test.startTest();
        contractVerbiage.Contract_General_Content__c = null;
        update contractVerbiage;
        Test.stopTest();

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'Contract did not need Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(true, contractVerbiage.Modified__c,
                            'Contract Verbiage not marked as Modified');
    }

    static testMethod void testInsertingUnknownPricingFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract did not start as not needing Billing Approval');

        Test.startTest();
        CONMAN_Contract_Verbiage__c contractVerbiage = new CONMAN_Contract_Verbiage__c(Name='Testing', Verbiage__c='Custom Terms', PGi_Contract__c=testContract.Id,
                                                                                      Pricing_Team_Changes_Allowed__c=True);
        insert contractVerbiage;
        Test.stopTest();

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'Contract did not need Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(true, contractVerbiage.Modified__c,
                            'Contract Verbiage not marked as Modified');
    }

    static testMethod void testInsertingUnknownNoPricingFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract did not start as not needing Billing Approval');

        Test.startTest();
        CONMAN_Contract_Verbiage__c contractVerbiage = new CONMAN_Contract_Verbiage__c(Name='Testing', Verbiage__c='Custom Terms', PGi_Contract__c=testContract.Id,
                                                                                      Pricing_Team_Changes_Allowed__c=False);
        insert contractVerbiage;
        Test.stopTest();

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'Contract did not need Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(true, contractVerbiage.Modified__c,
                            'Contract Verbiage not marked as Modified');
    }

    static testMethod void testUpdatingUnknownPricingFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract did not start as not needing Billing Approval');

        Test.startTest();
        CONMAN_Contract_Verbiage__c contractVerbiage = new CONMAN_Contract_Verbiage__c(Name='Testing', Verbiage__c='Custom Terms', PGi_Contract__c=testContract.Id,
                                                                                      Pricing_Team_Changes_Allowed__c=True);
        insert contractVerbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'Contract did not need Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(true, contractVerbiage.Modified__c,
                            'Contract Verbiage not marked as Modified');

        testContract.Required_Approval_Billing__c = false;
        update testContract;

        contractVerbiage.Modified__c = false;
        update contractVerbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract needed Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(false, contractVerbiage.Modified__c,
                            'Contract Verbiage marked as Modified');

        contractVerbiage.Verbiage__c = 'New Testing Verbiage';
        update contractVerbiage;
        Test.stopTest();

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'Contract did not need Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(true, contractVerbiage.Modified__c,
                            'Contract Verbiage not marked as Modified');
    }

    static testMethod void testUpdatingUnknownNoPricingFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract did not start as not needing Billing Approval');

        Test.startTest();
        CONMAN_Contract_Verbiage__c contractVerbiage = new CONMAN_Contract_Verbiage__c(Name='Testing', Verbiage__c='Custom Terms', PGi_Contract__c=testContract.Id,
                                                                                      Pricing_Team_Changes_Allowed__c=False);
        insert contractVerbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'Contract did not need Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(true, contractVerbiage.Modified__c,
                            'Contract Verbiage not marked as Modified');

        testContract.Required_Approval_Billing__c = false;
        update testContract;

        contractVerbiage.Modified__c = false;
        update contractVerbiage;

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract needed Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(false, contractVerbiage.Modified__c,
                            'Contract Verbiage marked as Modified');

        contractVerbiage.Verbiage__c = 'New Testing Verbiage';
        update contractVerbiage;
        Test.stopTest();

        testContract = [SELECT Id, Required_Approval_Billing__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'Contract did not need Billing Approval');

        contractVerbiage = [SELECT Id, Modified__c FROM CONMAN_Contract_Verbiage__c WHERE Id = :contractVerbiage.Id];
        System.assertEquals(true, contractVerbiage.Modified__c,
                            'Contract Verbiage not marked as Modified');
    }
}