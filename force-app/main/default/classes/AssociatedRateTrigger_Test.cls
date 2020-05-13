@isTest
public class AssociatedRateTrigger_Test {
    static testMethod void testInsertingNameNoFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        LicenseSet__c licenseSet = new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=12,
                                  Product_Name__c='Test LS',Price__c=58.54,Opportunity__c=testOppty.Id,
                                  Payment_Plan__c='Annual', PGi_Contract__c=testContract.Id);
        insert licenseSet;

        Rate__c rate = new Rate__c(Name='Arate', Rate_Name__c='Arate', Description__c='Testing Description', Recurrence__c='Minute',
                                   Unique_ID__c='1');
        insert rate;

        Test.startTest();

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];

        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract starts at no Billing Approval');

        Associated_Rate__c associatedRate = new Associated_Rate__c(Rate_Name__c='Custom Name', Description__c='Testing Description', Recurrence__c='Minute',
                                                                   Rate__c=rate.Id, LicenseSet__c=licenseSet.Id,
                                                                   Sales_Rep__c=0.050, Default__c=0.070);
        insert associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');
        Test.stopTest();
    }

    static testMethod void testInsertingDescriptionNoFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        LicenseSet__c licenseSet = new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=12,
                                  Product_Name__c='Test LS',Price__c=58.54,Opportunity__c=testOppty.Id,
                                  Payment_Plan__c='Annual', PGi_Contract__c=testContract.Id);
        insert licenseSet;

        Rate__c rate = new Rate__c(Name='Arate', Rate_Name__c='Arate', Description__c='Testing Description', Recurrence__c='Minute',
                                   Unique_ID__c='1');
        insert rate;

        Test.startTest();
        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];

        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract starts at no Billing Approval');

        Associated_Rate__c associatedRate = new Associated_Rate__c(Rate_Name__c='Arate', Description__c='Custom Description', Recurrence__c='Minute',
                                                                   Rate__c=rate.Id, LicenseSet__c=licenseSet.Id,
                                                                   Sales_Rep__c=0.050, Default__c=0.070);
        insert associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');
        Test.stopTest();
    }

    static testMethod void testInsertingRecurrenceNoFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        LicenseSet__c licenseSet = new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=12,
                                  Product_Name__c='Test LS',Price__c=58.54,Opportunity__c=testOppty.Id,
                                  Payment_Plan__c='Annual', PGi_Contract__c=testContract.Id);
        insert licenseSet;

        Rate__c rate = new Rate__c(Name='Arate', Rate_Name__c='Arate', Description__c='Testing Description',
                                   Recurrence__c='Minute', Unique_ID__c='1');
        insert rate;

        Test.startTest();
        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];

        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract starts at no Billing Approval');

        Associated_Rate__c associatedRate = new Associated_Rate__c(Rate_Name__c='Arate', Description__c='Testing Description',
                                                                   Rate__c=rate.Id, LicenseSet__c=licenseSet.Id,
                                                                   Recurrence__c='Custom Recurrence', Sales_Rep__c=0.050, Default__c=0.070);
        insert associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');
        Test.stopTest();
    }

    static testMethod void testUpdatingNameFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        LicenseSet__c licenseSet = new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=12,
                                  Product_Name__c='Test LS',Price__c=58.54,Opportunity__c=testOppty.Id,
                                  Payment_Plan__c='Annual', PGi_Contract__c=testContract.Id);
        insert licenseSet;

        Rate__c rate = new Rate__c(Name='Arate', Rate_Name__c='Arate', Description__c='Testing Description', Recurrence__c='Minute',
                                   Unique_ID__c='1');
        insert rate;

        Associated_Rate__c associatedRate = new Associated_Rate__c(Rate_Name__c='Arate', Description__c='Testing Description', Recurrence__c='Minute',
                                                                   Rate__c=rate.Id, LicenseSet__c=licenseSet.Id,
                                                                   Sales_Rep__c=0.050, Default__c=0.070);
        insert associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];

        Test.startTest();
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract starts at no Billing Approval');

        associatedRate.Rate_Name__c = 'New Name';
        update associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');
        Test.stopTest();
    }

    static testMethod void testUpdatingDescriptionFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        LicenseSet__c licenseSet = new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=12,
                                  Product_Name__c='Test LS',Price__c=58.54,Opportunity__c=testOppty.Id,
                                  Payment_Plan__c='Annual', PGi_Contract__c=testContract.Id);
        insert licenseSet;

        Rate__c rate = new Rate__c(Name='Arate', Rate_Name__c='Arate', Description__c='Testing Description', Recurrence__c='Minute',
                                   Unique_ID__c='1');
        insert rate;

        Associated_Rate__c associatedRate = new Associated_Rate__c(Rate_Name__c='Arate', Description__c='Testing Description', Recurrence__c='Minute',
                                                                   Rate__c=rate.Id, LicenseSet__c=licenseSet.Id,
                                                                   Sales_Rep__c=0.050, Default__c=0.070);
        insert associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];

        Test.startTest();
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract starts at no Billing Approval');

        associatedRate.Description__c = 'New Description';
        update associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');
        Test.stopTest();
    }

    static testMethod void testUpdatingRecurrenceFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        LicenseSet__c licenseSet = new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=12,
                                  Product_Name__c='Test LS',Price__c=58.54,Opportunity__c=testOppty.Id,
                                  Payment_Plan__c='Annual', PGi_Contract__c=testContract.Id);
        insert licenseSet;

        Rate__c rate = new Rate__c(Name='Arate', Rate_Name__c='Arate', Description__c='Testing Description',
                                   Recurrence__c='Minute', Unique_ID__c='1');
        insert rate;

        Associated_Rate__c associatedRate = new Associated_Rate__c(Rate_Name__c='Arate', Description__c='Testing Description',
                                                                   Rate__c=rate.Id, LicenseSet__c=licenseSet.Id,
                                                                   Recurrence__c='Minute', Sales_Rep__c=0.050, Default__c=0.070);
        insert associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];

        Test.startTest();
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract starts at no Billing Approval');

        associatedRate.Recurrence__c = 'New Recurrence';
        update associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');
        Test.stopTest();
    }

    static testMethod void testUpdatingToUnknownFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        LicenseSet__c licenseSet = new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=12,
                                  Product_Name__c='Test LS',Price__c=58.54,Opportunity__c=testOppty.Id,
                                  Payment_Plan__c='Annual', PGi_Contract__c=testContract.Id);
        insert licenseSet;

        Rate__c rate = new Rate__c(Name='Arate', Rate_Name__c='Arate', Description__c='Testing Description',
                                   Recurrence__c='Minute', Unique_ID__c='1');
        insert rate;

        Associated_Rate__c associatedRate = new Associated_Rate__c(Rate_Name__c='Arate', Description__c='Testing Description',
                                                                   Rate__c=rate.Id, LicenseSet__c=licenseSet.Id,
                                                                   Recurrence__c='Minute', Sales_Rep__c=0.050, Default__c=0.070);
        insert associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];

        Test.startTest();
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract starts at no Billing Approval');

        associatedRate.Rate__c = null;
        update associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');
        Test.stopTest();
    }

    static testMethod void testInsertingUnknownFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        LicenseSet__c licenseSet = new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=12,
                                  Product_Name__c='Test LS',Price__c=58.54,Opportunity__c=testOppty.Id,
                                  Payment_Plan__c='Annual', PGi_Contract__c=testContract.Id);
        insert licenseSet;

        Rate__c rate = new Rate__c(Name='Arate', Rate_Name__c='Arate', Description__c='Testing Description',
                                   Recurrence__c='Minute', Unique_ID__c='1');
        insert rate;

        Test.startTest();
        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract starts at no Billing Approval');

        Associated_Rate__c associatedRate = new Associated_Rate__c(Rate_Name__c='Arate', Description__c='Testing Description',
                                                                   LicenseSet__c=licenseSet.Id,
                                                                   Recurrence__c='Minute', Sales_Rep__c=0.050, Default__c=0.070);
        insert associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');
        Test.stopTest();
    }

    static testMethod void testUpdatingUnknownNameFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        LicenseSet__c licenseSet = new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=12,
                                  Product_Name__c='Test LS',Price__c=58.54,Opportunity__c=testOppty.Id,
                                  Payment_Plan__c='Annual', PGi_Contract__c=testContract.Id);
        insert licenseSet;

        Test.startTest();
        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract starts at no Billing Approval');

        Associated_Rate__c associatedRate = new Associated_Rate__c(Rate_Name__c='Arate', Description__c='Testing Description',
                                                                   LicenseSet__c=licenseSet.Id,
                                                                   Recurrence__c='Minute', Sales_Rep__c=0.050, Default__c=0.070);
        insert associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');

        testContract.Required_Approval_Billing__c = false;
        update testContract;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');

        associatedRate.Rate_Name__c = 'Updated Name';
        update associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');
        Test.stopTest();
    }

    static testMethod void testUpdatingUnknownDescriptionFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        LicenseSet__c licenseSet = new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=12,
                                  Product_Name__c='Test LS',Price__c=58.54,Opportunity__c=testOppty.Id,
                                  Payment_Plan__c='Annual', PGi_Contract__c=testContract.Id);
        insert licenseSet;

        Test.startTest();
        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract starts at no Billing Approval');

        Associated_Rate__c associatedRate = new Associated_Rate__c(Rate_Name__c='Arate', Description__c='Testing Description',
                                                                   LicenseSet__c=licenseSet.Id,
                                                                   Recurrence__c='Minute', Sales_Rep__c=0.050, Default__c=0.070);
        insert associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');

        testContract.Required_Approval_Billing__c = false;
        update testContract;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');

        associatedRate.Description__c = 'Updated Description';
        update associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');
        Test.stopTest();
    }

    static testMethod void testUpdatingUnknownRecurrenceFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        LicenseSet__c licenseSet = new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=12,
                                  Product_Name__c='Test LS',Price__c=58.54,Opportunity__c=testOppty.Id,
                                  Payment_Plan__c='Annual', PGi_Contract__c=testContract.Id);
        insert licenseSet;

        Test.startTest();
        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract starts at no Billing Approval');

        Associated_Rate__c associatedRate = new Associated_Rate__c(Rate_Name__c='Arate', Description__c='Testing Description',
                                                                   LicenseSet__c=licenseSet.Id,
                                                                   Recurrence__c='Minute', Sales_Rep__c=0.050, Default__c=0.070);
        insert associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');

        testContract.Required_Approval_Billing__c = false;
        update testContract;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');

        associatedRate.Recurrence__c = 'Updated Recurrence';
        update associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');
        Test.stopTest();
    }

    static testMethod void testUpdatingWaivedNoFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        LicenseSet__c licenseSet = new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=12,
                                  Product_Name__c='Test LS',Price__c=58.54,Opportunity__c=testOppty.Id,
                                  Payment_Plan__c='Annual', PGi_Contract__c=testContract.Id);
        insert licenseSet;

        Rate__c rate = new Rate__c(Name='Arate', Rate_Name__c='Arate', Description__c='Testing Description',
                                   Recurrence__c='Minute', Unique_ID__c='1');
        insert rate;

        Associated_Rate__c associatedRate = new Associated_Rate__c(Rate_Name__c='Arate', Description__c='Testing Description',
                                                                   Rate__c=rate.Id, LicenseSet__c=licenseSet.Id,
                                                                   Recurrence__c='Minute', Sales_Rep__c=0.050, Default__c=0.070);
        insert associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];

        Test.startTest();
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract starts at no Billing Approval');

        associatedRate.Recurrence__c = 'Waived';
        update associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');
        Test.stopTest();
    }

    static testMethod void testUpdatingPriceNoFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        LicenseSet__c licenseSet = new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=12,
                                  Product_Name__c='Test LS',Price__c=58.54,Opportunity__c=testOppty.Id,
                                  Payment_Plan__c='Annual', PGi_Contract__c=testContract.Id);
        insert licenseSet;

        Rate__c rate = new Rate__c(Name='Arate', Rate_Name__c='Arate', Description__c='Testing Description',
                                   Recurrence__c='Minute', Unique_ID__c='1');
        insert rate;

        Associated_Rate__c associatedRate = new Associated_Rate__c(Rate_Name__c='Arate', Description__c='Testing Description',
                                                                   Rate__c=rate.Id, LicenseSet__c=licenseSet.Id,
                                                                   Recurrence__c='Minute', Sales_Rep__c=0.050, Default__c=0.070);
        insert associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];

        Test.startTest();
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract starts at no Billing Approval');

        associatedRate.Override__c = 0.50;
        update associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');
        Test.stopTest();
    }

    static testMethod void testUpdatingDescriptionTwiceFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        LicenseSet__c licenseSet = new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=12,
                                  Product_Name__c='Test LS',Price__c=58.54,Opportunity__c=testOppty.Id,
                                  Payment_Plan__c='Annual', PGi_Contract__c=testContract.Id);
        insert licenseSet;

        Rate__c rate = new Rate__c(Name='Arate', Rate_Name__c='Arate', Description__c='Testing Description', Recurrence__c='Minute',
                                   Unique_ID__c='1');
        insert rate;

        Associated_Rate__c associatedRate = new Associated_Rate__c(Rate_Name__c='Arate', Description__c='Testing Description', Recurrence__c='Minute',
                                                                   Rate__c=rate.Id, LicenseSet__c=licenseSet.Id,
                                                                   Sales_Rep__c=0.050, Default__c=0.070);
        insert associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];

        Test.startTest();
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract starts at no Billing Approval');

        associatedRate.Description__c = 'New Description';
        update associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(true, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');

        testContract.Required_Approval_Billing__c = false;
        update testContract;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');

        associatedRate.Override__c = 0.50;
        update associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');
        Test.stopTest();
    }

    static testMethod void testInsertingNameAccessTypeNoFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        LicenseSet__c licenseSet = new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=12,
                                  Product_Name__c='Test LS',Price__c=58.54,Opportunity__c=testOppty.Id,
                                  Payment_Plan__c='Annual', PGi_Contract__c=testContract.Id);
        insert licenseSet;

        Rate__c rate = new Rate__c(Name='Arate', Rate_Name__c='Arate', Description__c='Testing Description', Recurrence__c='Minute',
                                   Type__c='Access', Unique_ID__c='1');
        insert rate;

        Test.startTest();

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];

        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract starts at no Billing Approval');

        Associated_Rate__c associatedRate = new Associated_Rate__c(Rate_Name__c='Custom Name', Description__c='Custom Description', Recurrence__c='Custom', Rate__c=rate.Id, LicenseSet__c=licenseSet.Id, Sales_Rep__c=0.050, Default__c=0.070);
        insert associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');
        Test.stopTest();
    }

    static testMethod void testUpdatingNameAccessTypeNoFlagsBilling(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        LicenseSet__c licenseSet = new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=12,
                                  Product_Name__c='Test LS',Price__c=58.54,Opportunity__c=testOppty.Id,
                                  Payment_Plan__c='Annual', PGi_Contract__c=testContract.Id);
        insert licenseSet;

        Rate__c rate = new Rate__c(Name='Arate', Rate_Name__c='Arate', Description__c='Testing Description', Recurrence__c='Minute',
                                   Type__c='Access', Unique_ID__c='1');
        insert rate;

        Associated_Rate__c associatedRate = new Associated_Rate__c(Rate_Name__c='Arate', Description__c='Testing Description', Recurrence__c='Minute',
                                                                   Rate__c=rate.Id, LicenseSet__c=licenseSet.Id,
                                                                   Sales_Rep__c=0.050, Default__c=0.070);
        insert associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];

        Test.startTest();
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'Contract starts at no Billing Approval');

        associatedRate.Rate_Name__c = 'New Name';
        associatedRate.Description__c = 'New Description';
        associatedRate.Recurrence__c = 'New Recurrence';
        update associatedRate;

        testContract = [SELECT Id, Required_Approval_Billing__c
                        FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(false, testContract.Required_Approval_Billing__c,
                            'New Billing Approval Value');
        Test.stopTest();
    }
}