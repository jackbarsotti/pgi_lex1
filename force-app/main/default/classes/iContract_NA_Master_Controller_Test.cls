@isTest
private class iContract_NA_Master_Controller_Test {
    @TestSetup
    static void makeData(){
        PGITestUtilities.disableSalesWings();
        Country__c us = new Country__c(Name = 'United States', Region__c = 'US');
        Country__c can = new Country__c(Name = 'Canada', Region__c = 'CAN');
        Country__c ind = new Country__c(Name = 'India', Region__c = 'APAC');
        Country__c spa = new Country__c(Name = 'Spain', Region__c = 'EMEA');
        insert new List<Country__c>{us, can,ind,spa};
    }
    private static final String LOG_TAG = 'test_iContract_NA_Master_Controller: ';
    static LicenseSet__c createLicenseSet(String lsname) {
        LicenseSet__c lstest = new LicenseSet__c();
        lstest.Name = 'Testing LicenseSet '+ lsname;
        lstest.Product_Name__c = 'Product Name';
        return lstest;
    }

    static Associated_Rate__c createAssociatedRate(LicenseSet__c lstest, Rate__c rate) {
        Associated_Rate__c artest = new Associated_Rate__c();
        if (rate != null) {
            artest.Rate_Name__c = rate.Rate_Name__c;
            artest.Rate__c = rate.Id;
            artest.Rate__r = rate;
        }
        artest.LicenseSet__c = lstest.id;
        artest.Default__c = 0;
        artest.Override__c = 0;
        return artest;
    }

    static testMethod void TestSorting() {
        System.debug(LOG_TAG + 'TestSorting Started!');

        // insert necessary data

        // Offerings to Sort
        List<Offerings__c> Os = new List<Offerings__c>();
        Offerings__c O_1 = new Offerings__c(Name='Offering', Product_Name__c='Offering', Order__c=1, Unique_ID__c='1');
        Os.add(O_1);
        Offerings__c O_4 = new Offerings__c(Name='Offering', Product_Name__c='Offering', Order__c=4, Unique_ID__c='4');
        Os.add(O_4);
        Offerings__c O_2a = new Offerings__c(Name='Offering A', Product_Name__c='Offering A', Order__c=2, Unique_ID__c='2a');
        Os.add(O_2a);
        Offerings__c O_2b = new Offerings__c(Name='Offering B', Product_Name__c='Offering B', Order__c=2, Unique_ID__c='2b');
        Os.add(O_2b);
        Offerings__c O_b = new Offerings__c(Name='Offering B', Product_Name__c='Offering B', Unique_ID__c='b');
        Os.add(O_b);
        Offerings__c O_a = new Offerings__c(Name='Offering A', Product_Name__c='Offering A', Unique_ID__c='a');
        Os.add(O_a);
        insert Os;

        // Rate Groups to Sort
        List<Rate_Group__c> RGs = new List<Rate_Group__c>();
        Rate_Group__c RG_1 = new Rate_Group__c(Name='RG_1', Order__c=1, Unique_ID__c='1');
        RGs.add(RG_1);
        Rate_Group__c RG_4 = new Rate_Group__c(Name='RG_4', Order__c=4, Unique_ID__c='4');
        RGs.add(RG_4);
        Rate_Group__c RG_2b = new Rate_Group__c(Name='RG_2b', Order__c=2, Unique_ID__c='2b');
        RGs.add(RG_2b);
        Rate_Group__c RG_2a = new Rate_Group__c(Name='RG_2a', Order__c=2, Unique_ID__c='2a');
        RGs.add(RG_2a);
        Rate_Group__c RG_b = new Rate_Group__c(Name='RG_b', Unique_ID__c='b');
        RGs.add(RG_b);
        Rate_Group__c RG_a = new Rate_Group__c(Name='RG_a', Unique_ID__c='a');
        RGs.add(RG_a);
        insert RGs;

        // Rates to Sort
        List<Rate__c> Rs = new List<Rate__c>();
        Rate__c R_1 = new Rate__c(Name='Rate', Rate_Name__c='R_1', Type__c='Usage', Rate_Group__c=RG_1.Id, Rate_Group__r=RG_1, Order__c=1, Unique_ID__c='1');
        Rs.add(R_1);
        Rate__c R_4 = new Rate__c(Name='Rate', Rate_Name__c='R_4', Type__c='Usage', Rate_Group__c=RG_1.Id, Rate_Group__r=RG_1, Order__c=4, Unique_ID__c='4');
        Rs.add(R_4);
        Rate__c R_2b = new Rate__c(Name='Rate B', Rate_Name__c='R_2b', Type__c='Usage', Rate_Group__c=RG_1.Id, Rate_Group__r=RG_1, Order__c=2, Unique_ID__c='2b');
        Rs.add(R_2b);
        Rate__c R_2a = new Rate__c(Name='Rate A', Rate_Name__c='R_2a', Type__c='Usage', Rate_Group__c=RG_1.Id, Rate_Group__r=RG_1, Order__c=2, Unique_ID__c='2a');
        Rs.add(R_2a);
        Rate__c R_b = new Rate__c(Name='Rate B', Rate_Name__c='R_b', Type__c='Usage', Rate_Group__c=RG_1.Id, Rate_Group__r=RG_1, Unique_ID__c='b');
        Rs.add(R_b);
        Rate__c R_a = new Rate__c(Name='Rate A', Rate_Name__c='R_a', Type__c='Usage', Rate_Group__c=RG_1.Id, Rate_Group__r=RG_1, Unique_ID__c='a');
        Rs.add(R_a);
        // Rates to enable Sorting on all Rate Groups
        Rate__c R_RG_4 = new Rate__c(Name='Rate', Rate_Name__c='R_RG_4', Type__c='Usage', Rate_Group__c=RG_4.Id, Rate_Group__r=RG_4, Order__c=1, Unique_ID__c='RG_4');
        Rs.add(R_RG_4);
        Rate__c R_RG_2b = new Rate__c(Name='Rate B', Rate_Name__c='R_RG_2b', Type__c='Usage', Rate_Group__c=RG_2b.Id, Rate_Group__r=RG_2b, Order__c=1, Unique_ID__c='RG_2b');
        Rs.add(R_RG_2b);
        Rate__c R_RG_2a = new Rate__c(Name='Rate A', Rate_Name__c='R_RG_2a', Type__c='Usage', Rate_Group__c=RG_2a.Id, Rate_Group__r=RG_2a, Order__c=1, Unique_ID__c='RG_2a');
        Rs.add(R_RG_2a);
        Rate__c R_RG_b = new Rate__c(Name='Rate B', Rate_Name__c='R_RG_b', Type__c='Usage', Rate_Group__c=RG_b.Id, Rate_Group__r=RG_b, Order__c=1, Unique_ID__c='RG_b');
        Rs.add(R_RG_b);
        Rate__c R_RG_a = new Rate__c(Name='Rate A', Rate_Name__c='R_RG_a', Type__c='Usage', Rate_Group__c=RG_a.Id, Rate_Group__r=RG_a, Order__c=1, Unique_ID__c='RG_a');
        Rs.add(R_RG_a);
        insert Rs;

        // setup reusable data
        ConMan_Contract__c ctc = new ConMan_Contract__c();
        LicenseSet__c LS;
        List<Associated_Rate__c> ARs = new List<Associated_Rate__c>();
        iContract_NA_Master_Controller.LicenseData LD;
        List<iContract_NA_Master_Controller.LicenseData> LDs = new List<iContract_NA_Master_Controller.LicenseData>();

        test.startTest();

        // Insertions to test Offering Sorts
        LS = new LicenseSet__c(Name='O_4', Product_Name__c='O_4', Enterprise_Name__c=O_4.Id, Enterprise_Name__r=O_4);
        LD = new iContract_NA_Master_Controller.LicenseData(LS, ARs, ctc);
        LDs.add(LD);

        LS = new LicenseSet__c(Name='O_2a', Product_Name__c='O_2a', Enterprise_Name__c=O_2a.Id, Enterprise_Name__r=O_2a);
        LD = new iContract_NA_Master_Controller.LicenseData(LS, ARs, ctc);
        LDs.add(LD);

        LS = new LicenseSet__c(Name='Z_5', Product_Name__c='Z_5');
        LD = new iContract_NA_Master_Controller.LicenseData(LS, ARs, ctc);
        LDs.add(LD);

        LS = new LicenseSet__c(Name='O_1', Product_Name__c='O_1', Enterprise_Name__c=O_1.Id, Enterprise_Name__r=O_1);
        LD = new iContract_NA_Master_Controller.LicenseData(LS, ARs, ctc);
        LDs.add(LD);

        LS = new LicenseSet__c(Name='O_b', Product_Name__c='O_b', Enterprise_Name__c=O_b.Id, Enterprise_Name__r=O_b);
        LD = new iContract_NA_Master_Controller.LicenseData(LS, ARs, ctc);
        LDs.add(LD);

        LS = new LicenseSet__c(Name='Z_1', Product_Name__c='Z_1');
        LD = new iContract_NA_Master_Controller.LicenseData(LS, ARs, ctc);
        LDs.add(LD);

        LS = new LicenseSet__c(Name='O_2b', Product_Name__c='O_2b', Enterprise_Name__c=O_2b.Id, Enterprise_Name__r=O_2b);
        LD = new iContract_NA_Master_Controller.LicenseData(LS, ARs, ctc);
        LDs.add(LD);

        LS = new LicenseSet__c(Name='Z_2', Product_Name__c='Z_2');
        LD = new iContract_NA_Master_Controller.LicenseData(LS, ARs, ctc);
        LDs.add(LD);

        LS = new LicenseSet__c(Name='O_a', Product_Name__c='O_a', Enterprise_Name__c=O_a.Id, Enterprise_Name__r=O_a);
        LD = new iContract_NA_Master_Controller.LicenseData(LS, ARs, ctc);
        LDs.add(LD);

        // Insertions to test Rate Group and Rate Sorts
        LS = new LicenseSet__c(Name='O_4 X', Product_Name__c='O_4 X', Enterprise_Name__c=O_4.Id, Enterprise_Name__r=O_4);
        Associated_Rate__c AR_1 = new Associated_Rate__c(Name='R', Rate_Name__c='R_1', Rate__c=R_1.Id, Rate__r=R_1, LicenseSet__r=LS);
        ARs.add(AR_1);
        Associated_Rate__c AR_4 = new Associated_Rate__c(Name='R', Rate_Name__c='R_4', Rate__c=R_4.Id, Rate__r=R_4, LicenseSet__r=LS);
        ARs.add(AR_4);
        Associated_Rate__c AR_2b = new Associated_Rate__c(Name='R', Rate_Name__c='R_2b', Rate__c=R_2b.Id, Rate__r=R_2b, LicenseSet__r=LS);
        ARs.add(AR_2b);
        Associated_Rate__c AR_2a = new Associated_Rate__c(Name='R', Rate_Name__c='R_2a', Rate__c=R_2a.Id, Rate__r=R_2a, LicenseSet__r=LS);
        ARs.add(AR_2a);
        Associated_Rate__c AR_b = new Associated_Rate__c(Name='R', Rate_Name__c='R_b', Rate__c=R_b.Id, Rate__r=R_b, LicenseSet__r=LS);
        ARs.add(AR_b);
        Associated_Rate__c AR_a = new Associated_Rate__c(Name='R', Rate_Name__c='R_a', Rate__c=R_a.Id, Rate__r=R_a, LicenseSet__r=LS);
        ARs.add(AR_a);
        Associated_Rate__c AR_RG_4 = new Associated_Rate__c(Name='R', Rate_Name__c='R_RG_4', Rate__c=R_RG_4.Id, Rate__r=R_RG_4, LicenseSet__r=LS);
        ARs.add(AR_RG_4);
        Associated_Rate__c AR_RG_2b = new Associated_Rate__c(Name='R', Rate_Name__c='R_RG_2b', Rate__c=R_RG_2b.Id, Rate__r=R_RG_2b, LicenseSet__r=LS);
        ARs.add(AR_RG_2b);
        Associated_Rate__c AR_RG_2a = new Associated_Rate__c(Name='R', Rate_Name__c='R_RG_2a', Rate__c=R_RG_2a.Id, Rate__r=R_RG_2a, LicenseSet__r=LS);
        ARs.add(AR_RG_2a);
        Associated_Rate__c AR_RG_b = new Associated_Rate__c(Name='R', Rate_Name__c='R_RG_b', Rate__c=R_RG_b.Id, Rate__r=R_RG_b, LicenseSet__r=LS);
        ARs.add(AR_RG_b);
        Associated_Rate__c AR_RG_a = new Associated_Rate__c(Name='R', Rate_Name__c='R_RG_a', Rate__c=R_RG_a.Id, Rate__r=R_RG_a, LicenseSet__r=LS);
        ARs.add(AR_RG_a);
        Associated_Rate__c AR_x5 = new Associated_Rate__c(Name='R', Rate_Name__c='RX 5');
        ARs.add(AR_x5);
        Associated_Rate__c AR_x2 = new Associated_Rate__c(Name='R', Rate_Name__c='RX 2');
        ARs.add(AR_x2);
        LD = new iContract_NA_Master_Controller.LicenseData(LS, ARs, ctc);
        LDs.add(LD);

        // Do the License Sort (Also does Rage Group sort, which triggers a Rate sort)
        LDs.sort();

        test.stopTest();

        // Test Offerings are Sorted
        System.assertEquals('O_a',    LDs.get(0).name, 'Offering Sorted: #1 = O_a');
        System.assertEquals('O_b',    LDs.get(1).name, 'Offering Sorted: #2 = O_b');
        System.assertEquals('Z_1',    LDs.get(2).name, 'Offering Sorted: #3 = Z_1');
        System.assertEquals('Z_2',    LDs.get(3).name, 'Offering Sorted: #4 = Z_2');
        System.assertEquals('Z_5',    LDs.get(4).name, 'Offering Sorted: #5 = Z_5');
        System.assertEquals('O_1',    LDs.get(5).name, 'Offering Sorted: #6 = O_1');
        System.assertEquals('O_2a',   LDs.get(6).name, 'Offering Sorted: #7 = O_2a');
        System.assertEquals('O_2b',   LDs.get(7).name, 'Offering Sorted: #8 = O_2b');
        System.assertEquals('O_4',    LDs.get(8).name, 'Offering Sorted: #9 = O_4');
        System.assertEquals('O_4 X',  LDs.get(9).name, 'Offering Sorted: #10 = O_4 X');

        // Test Rate Groups are Sorted
        iContract_NA_Master_Controller.LicenseData LDSorted = LDs.get(9);
        System.assertEquals('',       LDSorted.rateGroups.get(LDSorted.rateGroupOrder.get(0)).header, 'Rate Group Sorted: #1 = <blank>');
        System.assertEquals('RG_a',   LDSorted.rateGroups.get(LDSorted.rateGroupOrder.get(1)).header, 'Rate Group Sorted: #2 = RG_a');
        System.assertEquals('RG_b',   LDSorted.rateGroups.get(LDSorted.rateGroupOrder.get(2)).header, 'Rate Group Sorted: #3 = RG_b');
        System.assertEquals('RG_1',  LDSorted.rateGroups.get(LDSorted.rateGroupOrder.get(3)).header, 'Rate Group Sorted: #4 = RG_1');
        System.assertEquals('RG_2a', LDSorted.rateGroups.get(LDSorted.rateGroupOrder.get(4)).header, 'Rate Group Sorted: #5 = RG_2a');
        System.assertEquals('RG_2b', LDSorted.rateGroups.get(LDSorted.rateGroupOrder.get(5)).header, 'Rate Group Sorted: #6 = RG_2b');
        System.assertEquals('RG_4',  LDSorted.rateGroups.get(LDSorted.rateGroupOrder.get(6)).header, 'Rate Group Sorted: #7 = RG_4');

        // Test Rates are Sorted
        iContract_NA_Master_Controller.RateGroupData RGSorted = LDSorted.rateGroups.get('');
        System.assertEquals('RX 2', RGSorted.rates.get(0).name, '<blank> Rate Sorted: #1 = RX 2');
        System.assertEquals('RX 5', RGSorted.rates.get(1).name, '<blank> Rate Sorted: #2 = RX 5');

        RGSorted = LDSorted.rateGroups.get(RG_1.Id);
        System.assertEquals('R_a',  RGSorted.rates.get(0).name, 'RG_z1 Rate Sorted: #1 = R_a');
        System.assertEquals('R_b',  RGSorted.rates.get(1).name, 'RG_z1 Rate Sorted: #2 = R_b');
        System.assertEquals('R_1',  RGSorted.rates.get(2).name, 'RG_z1 Rate Sorted: #3 = R_1');
        System.assertEquals('R_2a', RGSorted.rates.get(3).name, 'RG_z1 Rate Sorted: #4 = R_2a');
        System.assertEquals('R_2b', RGSorted.rates.get(4).name, 'RG_z1 Rate Sorted: #5 = R_2b');
        System.assertEquals('R_4',  RGSorted.rates.get(5).name, 'RG_z1 Rate Sorted: #6 = R_4');

        System.debug(LOG_TAG + 'TestSorting Passed!');
    }

    static testMethod void TestLicenseData() {
        System.debug(LOG_TAG + 'TestLicenseData Started!');

        // insert necessary data
        Offerings__c O = new Offerings__c(Name='Offering', Product_Name__c='Offering', Unique_ID__c='1');
        insert O;
        Rate_Group__c RG = new Rate_Group__c(Name='Rate Group', Unique_ID__c='1');
        insert RG;
        Rate__c R = new Rate__c(Name='Rate', Type__c='Usage', Rate_Group__c=RG.Id, Unique_ID__c='1');
        insert R;
        R.Rate_Group__r = RG;
        Rate__c Rotc = new Rate__c(Name='Rate', Type__c='Once', Rate_Group__c=RG.Id, Unique_ID__c='2');
        insert Rotc;
        Rate__c Rsub = new Rate__c(Name='Rate', Type__c='Sub', Rate_Group__c=RG.Id, Unique_ID__c='3');
        insert Rsub;
        Rate__c Rcommit = new Rate__c(Name='Rate', Type__c='Commit', Rate_Group__c=RG.Id, Unique_ID__c='4');
        insert Rcommit;
        Rate__c Rbun = new Rate__c(Name='Rate', Type__c='Bundle', Rate_Group__c=RG.Id, Unique_ID__c='5');
        insert Rbun;
        Rate__c Raccess = new Rate__c(Name='Rate', Type__c='Access', Rate_Group__c=RG.Id, Unique_ID__c='6');
        insert Raccess;

        // setup reusable data
        LicenseSet__c LS = new LicenseSet__c(Name='Testing', CurrencyIsoCode='USD', Price__c=95.0);
        List<Associated_Rate__c> ARs = new List<Associated_Rate__c>();
        Associated_Rate__c AR;
        iContract_NA_Master_Controller.LicenseData LD;
        ConMan_Contract__c ctc = new ConMan_Contract__c();

        test.startTest();

        // initialize without rates
        ARs.clear();
        LD = new iContract_NA_Master_Controller.LicenseData(LS, ARs, ctc);
        system.assertEquals(LS.Name, LD.licenseSet.Name, 'LS stored correctly');
        system.assertEquals(1, LD.rateGroupOrder.size(), 'LS without Rates starts with a plain Rate Group');
        system.assertEquals(0, LD.rateGroups.get('').rates.size(), 'LS without Rates starts with a plain and empty Rate Group');
        system.assertEquals(false, LD.hasRates, 'LS without Rates starts with a plain and empty Rate Group');
        system.assertEquals(false, LD.hasOneTimeCharges, 'LS without Rates starts without One-Time Charges');
        system.assertEquals(false, LD.hasSubscriptions, 'LS without Rates starts without Subscriptions');
        system.assertEquals(false, LD.hasCommitments, 'LS without Rates starts without Commitments');
        system.assertEquals(false, LD.hasBundleDetails, 'LS without Rates starts without Bundle Details');
        system.assertEquals(false, LD.hasAccessTypes, 'LS without Rates starts without Bundle Details');

        // add rates w/o group
        AR = new Associated_Rate__c(Name='AR 1');
        LD.addAssociatedRate(AR, ctc);
        system.assertEquals(1, LD.rateGroupOrder.size(), 'Added a plain AR into plain Rate Group keeps existing Rate Group');
        system.assertEquals(1, LD.rateGroups.get('').rates.size(), 'Added a plain AR into plain Rate Group');
        system.assertEquals(true, LD.hasRates, 'Added a plain AR into plain Rate Group');
        system.assertEquals(false, LD.hasOneTimeCharges, 'LS without Rates starts without One-Time Charges');
        system.assertEquals(false, LD.hasSubscriptions, 'LS without Rates starts without Subscriptions');
        system.assertEquals(false, LD.hasCommitments, 'LS without Rates starts without Commitments');
        system.assertEquals(false, LD.hasBundleDetails, 'LS without Rates starts without Bundle Details');
        system.assertEquals(false, LD.hasAccessTypes, 'LS without Rates starts without Bundle Details');

        // add rates w/ group
        AR = new Associated_Rate__c(Name='AR 1', Rate__c=R.Id, Rate__r=R);
        LD.addAssociatedRate(AR, ctc);
        system.assertEquals(2, LD.rateGroupOrder.size(), 'Added a grouped AR adds Rate Group');
        system.assertEquals(1, LD.rateGroups.get(RG.Id).rates.size(), 'Added a grouped AR into new Rate Group');
        system.assertEquals(true, LD.hasRates, 'Added a grouped AR into new Rate Group');
        system.assertEquals(false, LD.hasOneTimeCharges, 'LS without Rates starts without One-Time Charges');
        system.assertEquals(false, LD.hasSubscriptions, 'LS without Rates starts without Subscriptions');
        system.assertEquals(false, LD.hasCommitments, 'LS without Rates starts without Commitments');
        system.assertEquals(false, LD.hasBundleDetails, 'LS without Rates starts without Bundle Details');
        system.assertEquals(false, LD.hasAccessTypes, 'LS without Rates starts without Bundle Details');

        // add rate types
        AR = new Associated_Rate__c(Name='AR 1', Rate__c=Rotc.Id, Rate__r=Rotc);
        LD.addAssociatedRate(AR, ctc);
        system.assertEquals(2, LD.rateGroupOrder.size(), 'Added a grouped AR adds Rate Group');
        system.assertEquals(1, LD.rateGroups.get(RG.Id).rates.size(), 'Added a grouped AR into new Rate Group');
        system.assertEquals(true, LD.hasRates, 'Added a grouped AR into new Rate Group');
        system.assertEquals(true, LD.hasOneTimeCharges, 'Added a One-Time Charge');
        system.assertEquals(false, LD.hasSubscriptions, 'LS without Rates starts without Subscriptions');
        system.assertEquals(false, LD.hasCommitments, 'LS without Rates starts without Commitments');
        system.assertEquals(false, LD.hasBundleDetails, 'LS without Rates starts without Bundle Details');
        system.assertEquals(false, LD.hasAccessTypes, 'LS without Rates starts without Bundle Details');

        AR = new Associated_Rate__c(Name='AR 1', Rate__c=Rsub.Id, Rate__r=Rsub);
        LD.addAssociatedRate(AR, ctc);
        system.assertEquals(2, LD.rateGroupOrder.size(), 'Added a grouped AR adds Rate Group');
        system.assertEquals(1, LD.rateGroups.get(RG.Id).rates.size(), 'Added a grouped AR into new Rate Group');
        system.assertEquals(true, LD.hasRates, 'Added a grouped AR into new Rate Group');
        system.assertEquals(true, LD.hasOneTimeCharges, 'Added a One-Time Charge');
        system.assertEquals(true, LD.hasSubscriptions, 'Added a Subscription');
        system.assertEquals(false, LD.hasCommitments, 'LS without Rates starts without Commitments');
        system.assertEquals(false, LD.hasBundleDetails, 'LS without Rates starts without Bundle Details');
        system.assertEquals(false, LD.hasAccessTypes, 'LS without Rates starts without Bundle Details');

        AR = new Associated_Rate__c(Name='AR 1', Rate__c=Rcommit.Id, Rate__r=Rcommit);
        LD.addAssociatedRate(AR, ctc);
        system.assertEquals(2, LD.rateGroupOrder.size(), 'Added a grouped AR adds Rate Group');
        system.assertEquals(1, LD.rateGroups.get(RG.Id).rates.size(), 'Added a grouped AR into new Rate Group');
        system.assertEquals(true, LD.hasRates, 'Added a grouped AR into new Rate Group');
        system.assertEquals(true, LD.hasOneTimeCharges, 'Added a One-Time Charge');
        system.assertEquals(true, LD.hasSubscriptions, 'Added a Subscription');
        system.assertEquals(true, LD.hasCommitments, 'Added a Commitment');
        system.assertEquals(false, LD.hasBundleDetails, 'LS without Rates starts without Bundle Details');
        system.assertEquals(false, LD.hasAccessTypes, 'LS without Rates starts without Bundle Details');

        AR = new Associated_Rate__c(Name='AR 1', Rate__c=Rbun.Id, Rate__r=Rbun);
        LD.addAssociatedRate(AR, ctc);
        system.assertEquals(2, LD.rateGroupOrder.size(), 'Added a grouped AR adds Rate Group');
        system.assertEquals(1, LD.rateGroups.get(RG.Id).rates.size(), 'Added a grouped AR into new Rate Group');
        system.assertEquals(true, LD.hasRates, 'Added a grouped AR into new Rate Group');
        system.assertEquals(true, LD.hasOneTimeCharges, 'Added a One-Time Charge');
        system.assertEquals(true, LD.hasSubscriptions, 'Added a Subscription');
        system.assertEquals(true, LD.hasCommitments, 'Added a Commitment');
        system.assertEquals(true, LD.hasBundleDetails, 'Added a Bundle Detail');
        system.assertEquals(false, LD.hasAccessTypes, 'LS without Rates starts without Bundle Details');

        AR = new Associated_Rate__c(Name='AR 1', Rate__c=Raccess.Id, Rate__r=Raccess);
        LD.addAssociatedRate(AR, ctc);
        system.assertEquals(2, LD.rateGroupOrder.size(), 'Added a grouped AR adds Rate Group');
        system.assertEquals(1, LD.rateGroups.get(RG.Id).rates.size(), 'Added a grouped AR into new Rate Group');
        system.assertEquals(true, LD.hasRates, 'Added a grouped AR into new Rate Group');
        system.assertEquals(true, LD.hasOneTimeCharges, 'Added a One-Time Charge');
        system.assertEquals(true, LD.hasSubscriptions, 'Added a Subscription');
        system.assertEquals(true, LD.hasCommitments, 'Added a Commitment');
        system.assertEquals(true, LD.hasBundleDetails, 'Added a Bundle Detail');
        system.assertEquals(true, LD.hasAccessTypes, 'Added an Access Type');

        // test name
        system.assertEquals(LS.Id, LD.id, 'Incorrect Id');
        system.assertEquals(LS.Product_Name__c, LD.name, 'Incorrect name');
        system.assert(LD.isCustomName, 'Custom Name for LS without Offering');
        LS.Enterprise_Name__c = O.Id;
        LS.Enterprise_Name__r = O;
        system.assert(LD.isCustomName, 'Custom Name for LS with different Offering');
        LS.Product_Name__c = O.Product_Name__c;
        system.assert(!LD.isCustomName, 'Non Custom Name for LS with same Offering');

        // test disabled
        system.assert(!LD.isDisabled, 'Starts enabled');
        LS.Disabled__c = true;
        system.assert(LD.isDisabled, 'Disabled');
        LS.Disabled__c = false;

        test.stopTest();
        System.debug(LOG_TAG + 'TestLicenseData Passed!');
    }

    static testMethod void TestRateData() {
        System.debug(LOG_TAG + 'TestRateData Started!');

        // insert necessary data
        Rate_Group__c RG = new Rate_Group__c(Name='Rate Group', Unique_ID__c='1');
        insert RG;
        Rate__c R = new Rate__c(Name='Rate', Rate_Name__c='TestRate', Type__c='Usage', Rate_Group__c=RG.Id, Recurrence__c='minute', Unique_ID__c='1', CurrencyIsoCode='USD');
        insert R;
        R.Rate_Group__r = RG;

        // setup reusable data
        LicenseSet__c LS = new LicenseSet__c(Name='Testing', CurrencyIsoCode='USD', Price__c=95.0);
        Associated_Rate__c AR;
        iContract_NA_Master_Controller.RateData RD;
        CONMAN_Contract__c ctc = new CONMAN_Contract__c();

        test.startTest();

        // test name
        AR = new Associated_Rate__c(Name='AR 1');
        RD = new iContract_NA_Master_Controller.RateData(AR, ctc);
        system.assertEquals('', RD.name, 'Blank name');
        AR.Rate_Name__c = 'Test';
        system.assertEquals(AR.Rate_Name__c, RD.name, 'Correct name');
        system.assert(RD.isCustomName, 'Custom Name for AR without Rate');
        AR.Rate__c = R.Id;
        AR.Rate__r = R;
        system.assert(RD.isCustomName, 'Custom Name for AR with different Rate');
        AR.Rate_Name__c = R.Rate_Name__c;
        system.assert(!RD.isCustomName, 'Non Custom Name for AR with same Rate');
        system.assert(!RD.isDisabled, 'Not Disabled');
        AR.Disabled__c = true;
        system.assert(RD.isDisabled, 'Disabled');

        // test description
        AR = new Associated_Rate__c(Name='AR 1');
        RD = new iContract_NA_Master_Controller.RateData(AR, ctc);
        system.assertEquals('', RD.description, 'Blank description');
        AR.Description__c = 'Test';
        system.assertEquals(AR.Description__c, RD.description, 'Correct description');
        system.assert(RD.isCustomDescription, 'Custom Description for AR without Rate');
        AR.Rate__c = R.Id;
        AR.Rate__r = R;
        system.assert(RD.isCustomDescription, 'Custom Description for AR with different Rate');
        AR.Description__c = R.Description__c;
        system.assert(!RD.isCustomDescription, 'Non Custom Description for AR with same Rate');

        // test quantity & recurrence
        AR = new Associated_Rate__c(Name='AR 1', CurrencyIsoCode='USD');
        RD = new iContract_NA_Master_Controller.RateData(AR, ctc);
        system.assert(!RD.hasQuantity, 'No Quantity');
        system.assertEquals('1', RD.quantity, 'No Quantity');
        AR.Quantity__c = 5;
        system.assertEquals('5', RD.quantity, 'Correct Quantity');
        system.assert(RD.hasQuantity, 'Quantity');
        AR.Override__c = 0.05;
        system.assertEquals('5 * USD 0.05', RD.rate, 'Correct Quantity');
        AR.Recurrence__c = 'minute';
        system.assertEquals('5 * USD 0.05 / minute', RD.rate, 'Correct Quantity');
        AR.Tier_Bundling__c = 3;
        system.assertEquals('2 * USD 0.05 / minute', RD.rate, 'Correct Quantity (3 tiered)');
        AR.Tier_Bundling__c = 7;
        system.assertEquals('1 * USD 0.05 / minute', RD.rate, 'Correct Quantity (7 tiered)');
        AR.Tier_Bundling__c = null;
        AR.Recurrence__c = 'No Charge';
        system.assertEquals('5 @ No Charge', RD.rate, 'Correct No Charge with Quantity');
        AR.Quantity__c = null;
        AR.Rate__c = R.Id;
        AR.Rate__r = R;
        system.assertEquals('No Charge', RD.rate, 'Correct No Charge');
        system.assert(RD.isCustomRecurrence, 'Custom Recurrence');
        AR.Recurrence__c = 'minute';
        system.assert(!RD.isCustomRecurrence, 'Standard Recurrence');

        // test one-time charge
        AR = new Associated_Rate__c(Name='AR 1', CurrencyIsoCode='USD');
        RD = new iContract_NA_Master_Controller.RateData(AR, ctc);
        system.assert(!RD.hasQuantity, 'No Quantity');
        system.assertEquals('1', RD.quantity, 'No Quantity');
        system.assertEquals('USD 0.00', RD.totc, 'Correct Total One-Time Charge');
        AR.Quantity__c = 5;
        system.assertEquals('USD 0.00', RD.totc, 'Correct Total One-Time Charge');
        AR.Override__c = 10;
        system.assertEquals('USD 50.00', RD.totc, 'Correct Total One-Time Charge');

        // test Normal Rate
        AR = new Associated_Rate__c(Name='AR 1', CurrencyIsoCode='USD');
        RD = new iContract_NA_Master_Controller.RateData(AR, ctc);
        system.assert(!RD.isOverridden, 'Blank Override');
        system.assertEquals('', RD.originalRate, 'No Original');
        system.assertEquals('USD 0.00', RD.rate, 'No Override');
        AR.Override__c = 0.0150;
        system.assertEquals('USD 0.0150', RD.rate, 'Correct Override w/o Recurrence');
        AR.Recurrence__c = 'minute';
        system.assertEquals('USD 0.0150 / minute', RD.rate, 'Correct Override');
        system.assertEquals('', RD.originalRate, 'No Original');
        system.assert(RD.isOverridden, 'Override for AR without Default');
        AR.Default__c = 0.02;
        system.assert(RD.isOverridden, 'Override for AR with different Default');
        system.assertEquals('USD 0.02', RD.originalRate, 'Correct Original');
        AR.Override__c = null;
        system.assert(!RD.isOverridden, 'Override for AR without Override');
        system.assertEquals('USD 0.02 / minute', RD.rate, 'No Override');
        AR.Override__c = AR.Default__c;
        system.assert(!RD.isOverridden, 'Non Override for AR with same Default');

        // test prices
        R.Type__c = 'Sub';
        AR = new Associated_Rate__c(Name='AR 1', CurrencyIsoCode='USD');
        AR.Rate__c = R.Id;
        AR.Rate__r = R;
        RD = new iContract_NA_Master_Controller.RateData(AR, ctc);

        AR.Override__c = 95;
        AR.Quantity__c = 50;
        RD.termLength = 12;
        RD.termFrequency = 1;
        system.assertEquals('USD 95.00 / month', RD.ppu, 'Correct PPU');
        system.assertEquals('USD 4750.00 / month', RD.mip, 'Correct MIP');
        system.assertEquals('USD 57000.00', RD.tsf, 'Correct TSF');
        system.assertEquals('50', RD.quantity, 'Correct Quantity');

        AR.Override__c = 66.5;
        AR.Quantity__c = 33;
        RD.termLength = 24;
        RD.termFrequency = 12;
        system.assertEquals('USD 798.00 / year', RD.ppu, 'Correct PPU');
        system.assertEquals('USD 26334.00 / year', RD.mip, 'Correct MIP');
        system.assertEquals('USD 52668.00', RD.tsf, 'Correct TSF');
        system.assertEquals('33', RD.quantity, 'Correct Quantity');

        AR.Override__c = 12;
        AR.Quantity__c = 42;
        RD.termLength = 4;
        RD.termFrequency = 1;
        system.assertEquals('USD 12.00 / month', RD.ppu, 'Correct PPU');
        system.assertEquals('USD 504.00 / month', RD.mip, 'Correct MIP');
        system.assertEquals('USD 2016.00', RD.tsf, 'Correct TSF');
        system.assertEquals('42', RD.quantity, 'Correct Quantity');

        AR.Override__c = 11;
        AR.Quantity__c = 13;
        RD.termLength = 4;
        RD.termFrequency = 4;
        system.assertEquals('USD 44.00 / quarter', RD.ppu, 'Correct PPU');
        system.assertEquals('USD 572.00 / quarter', RD.mip, 'Correct MIP');
        system.assertEquals('USD 572.00', RD.tsf, 'Correct TSF');
        system.assertEquals('13', RD.quantity, 'Correct Quantity');

        AR.Override__c = 0;
        AR.Quantity__c = 13;
        RD.termLength = 4;
        RD.termFrequency = 4;
        system.assertEquals('Included', RD.ppu, 'Correct PPU');
        system.assertEquals('', RD.mip, 'Correct MIP');
        system.assertEquals('', RD.tsf, 'Correct TSF');
        system.assertEquals('13', RD.quantity, 'Correct Quantity');

        AR.Override__c = 11;
        AR.Quantity__c = -1;
        RD.termLength = 4;
        RD.termFrequency = 4;
        system.assertEquals('USD 44.00 / quarter', RD.ppu, 'Correct PPU');
        system.assertEquals('USD 44.00 / quarter', RD.mip, 'Correct MIP');
        system.assertEquals('USD 44.00', RD.tsf, 'Correct TSF');
        system.assertEquals('Unlimited', RD.quantity, 'Correct Quantity');

        AR.Override__c = 11;
        AR.Quantity__c = 2;
        AR.Tier_Bundling__c = 5;
        RD.termLength = 4;
        RD.termFrequency = 4;
        system.assertEquals('', RD.ppu, 'Correct PPU');
        system.assertEquals('USD 44.00 / quarter', RD.mip, 'Correct MIP');
        system.assertEquals('USD 44.00', RD.tsf, 'Correct TSF');
        system.assertEquals('2', RD.quantity, 'Correct Quantity');

        AR.Override__c = 11;
        AR.Quantity__c = 7;
        AR.Tier_Bundling__c = 5;
        RD.termLength = 4;
        RD.termFrequency = 4;
        system.assertEquals('', RD.ppu, 'Correct PPU');
        system.assertEquals('USD 88.00 / quarter', RD.mip, 'Correct MIP');
        system.assertEquals('USD 88.00', RD.tsf, 'Correct TSF');
        system.assertEquals('7', RD.quantity, 'Correct Quantity');

        // test commitments
        R.Type__c = 'Commit';
        AR = new Associated_Rate__c(Name='AR 1', CurrencyIsoCode='USD');
        AR.Rate__c = R.Id;
        AR.Rate__r = R;
        RD = new iContract_NA_Master_Controller.RateData(AR, ctc);

        AR.Override__c = 95;
        RD.termLength = 12;
        RD.termFrequency = 12;
        system.assertEquals('USD 95.00 / year', RD.ppu, 'Correct PPU');
        system.assertEquals('USD 95.00 / year', RD.mip, 'Correct MIP');
        system.assertEquals('USD 95.00', RD.tsf, 'Correct TSF');
        system.assertEquals('1', RD.quantity, 'Correct Quantity');

        AR.Override__c = 95;
        RD.termLength = 12;
        RD.termFrequency = 1;
        system.assertEquals('USD 95.00 / month', RD.ppu, 'Correct PPU');
        system.assertEquals('USD 95.00 / month', RD.mip, 'Correct MIP');
        system.assertEquals('USD 1140.00', RD.tsf, 'Correct TSF');
        system.assertEquals('1', RD.quantity, 'Correct Quantity');

        AR.Override__c = 66.5;
        RD.termLength = 24;
        RD.termFrequency = 12;
        system.assertEquals('USD 66.50 / year', RD.ppu, 'Correct PPU');
        system.assertEquals('USD 66.50 / year', RD.mip, 'Correct MIP');
        system.assertEquals('USD 133.00', RD.tsf, 'Correct TSF');
        system.assertEquals('1', RD.quantity, 'Correct Quantity');

        AR.Override__c = 12;
        RD.termLength = 4;
        RD.termFrequency = 1;
        system.assertEquals('USD 12.00 / month', RD.ppu, 'Correct PPU');
        system.assertEquals('USD 12.00 / month', RD.mip, 'Correct MIP');
        system.assertEquals('USD 48.00', RD.tsf, 'Correct TSF');
        system.assertEquals('1', RD.quantity, 'Correct Quantity');

        AR.Override__c = 11;
        RD.termLength = 4;
        RD.termFrequency = 4;
        system.assertEquals('USD 11.00 / quarter', RD.ppu, 'Correct PPU');
        system.assertEquals('USD 11.00 / quarter', RD.mip, 'Correct MIP');
        system.assertEquals('USD 11.00', RD.tsf, 'Correct TSF');
        system.assertEquals('1', RD.quantity, 'Correct Quantity');

        // test bundle details
        R.Type__c = 'Bundle';
        AR = new Associated_Rate__c(Name='AR 1', CurrencyIsoCode='USD');
        AR.Rate__c = R.Id;
        AR.Rate__r = R;
        RD = new iContract_NA_Master_Controller.RateData(AR, ctc);

        AR.Override__c = 95;
        AR.Quantity__c = 50;
        RD.termLength = 12;
        RD.termFrequency = 1;
        system.assertEquals('USD 95.00 / month', RD.ppu, 'Correct PPU');
        system.assertEquals('USD 4750.00 / month', RD.mip, 'Correct MIP');
        system.assertEquals('USD 57000.00', RD.tsf, 'Correct TSF');
        system.assertEquals('50', RD.quantity, 'Correct Quantity');

        AR.Override__c = 66.5;
        AR.Quantity__c = 33;
        RD.termLength = 24;
        RD.termFrequency = 12;
        system.assertEquals('USD 798.00 / year', RD.ppu, 'Correct PPU');
        system.assertEquals('USD 26334.00 / year', RD.mip, 'Correct MIP');
        system.assertEquals('USD 52668.00', RD.tsf, 'Correct TSF');
        system.assertEquals('33', RD.quantity, 'Correct Quantity');

        AR.Override__c = 0;
        AR.Quantity__c = 42;
        RD.termLength = 4;
        RD.termFrequency = 1;
        system.assertEquals('Included', RD.ppu, 'Correct PPU');
        system.assertEquals('', RD.mip, 'Correct MIP');
        system.assertEquals('', RD.tsf, 'Correct TSF');
        system.assertEquals('42', RD.quantity, 'Correct Quantity');

        AR.Override__c = 11;
        AR.Quantity__c = 13;
        RD.termLength = 4;
        RD.termFrequency = 4;
        system.assertEquals('USD 44.00 / quarter', RD.ppu, 'Correct PPU');
        system.assertEquals('USD 572.00 / quarter', RD.mip, 'Correct MIP');
        system.assertEquals('USD 572.00', RD.tsf, 'Correct TSF');
        system.assertEquals('13', RD.quantity, 'Correct Quantity');

        AR.Override__c = 0;
        AR.Quantity__c = -1;
        RD.termLength = 4;
        RD.termFrequency = 4;
        system.assertEquals('Included', RD.ppu, 'Correct PPU');
        system.assertEquals('', RD.mip, 'Correct MIP');
        system.assertEquals('', RD.tsf, 'Correct TSF');
        system.assertEquals('Unlimited', RD.quantity, 'Correct Quantity');

        AR.Override__c = 11;
        AR.Quantity__c = -1;
        RD.termLength = 4;
        RD.termFrequency = 4;
        system.assertEquals('USD 44.00 / quarter', RD.ppu, 'Correct PPU');
        system.assertEquals('USD 44.00 / quarter', RD.mip, 'Correct MIP');
        system.assertEquals('USD 44.00', RD.tsf, 'Correct TSF');
        system.assertEquals('Unlimited', RD.quantity, 'Correct Quantity');

        test.stopTest();
        System.debug(LOG_TAG + 'TestRateData Passed!');
    }

    static testMethod void TestRateGroupData() {
        System.debug(LOG_TAG + 'TestRateGroupData Started!');

        // setup reusable data
        Rate_Group__c RG = new Rate_Group__c(Name='Rate Group', Unique_ID__c='1');
        Associated_Rate__c AR = new Associated_Rate__c(Name='AR 1');
        iContract_NA_Master_Controller.RateGroupData RGD;
        CONMAN_Contract__c ctc = new CONMAN_Contract__c();

        test.startTest();

        // test header
        RGD = new iContract_NA_Master_Controller.RateGroupData(new Rate_Group__c(Unique_ID__c='blank'));
        system.assertEquals('', RGD.header, 'Blank name');
        RGD = new iContract_NA_Master_Controller.RateGroupData(RG);
        system.assertEquals(RG.Name, RGD.header, 'Correct name');

        // test description and footer
        RGD = new iContract_NA_Master_Controller.RateGroupData(RG);
        system.assert(!RGD.hasDescription, 'Blank description');
        system.assertEquals('', RGD.description, 'Blank description');
        RG.Description__c = 'Test';
        system.assert(RGD.hasDescription, 'Correct description');
        system.assertEquals(RG.Description__c, RGD.description, 'Correct description');
        system.assert(!RGD.hasFooter, 'Blank footer');
        system.assertEquals('', RGD.footer, 'Blank footer');
        RG.Footer__c = 'Test';
        system.assert(RGD.hasFooter, 'Correct footer');
        system.assertEquals(RG.Footer__c, RGD.footer, 'Correct footer');

        // test types
        RGD = new iContract_NA_Master_Controller.RateGroupData(new Rate_Group__c(Name='Standard', Unique_ID__c='blank'));
        system.assert(!RGD.createNewPage, 'No new page for < 40 rates');
        for (integer rateIndex = 0; rateIndex < 42; rateIndex++)
            RGD.addAssociatedRate(new Associated_Rate__c(Name=String.valueOf(rateIndex)), ctc);
        system.assert(RGD.createNewPage, 'New page for > 40 rates');

        test.stopTest();
        System.debug(LOG_TAG + 'TestRateGroupData Passed!');
    }

    static testMethod void TestAccessTypeData() {
        System.debug(LOG_TAG + 'TestAccessTypeData Started!');


        // setup reusable data
        Rate_Group__c RG = new Rate_Group__c(Name='Rate Group', Unique_ID__c='1');
        Associated_Rate__c AR = new Associated_Rate__c(Name='AR 1');
        iContract_NA_Master_Controller.AccessTypeData ATD;
        CONMAN_Contract__c ctc = new CONMAN_Contract__c();

        Rate__c Rddo = new Rate__c(Name='Rate', Rate_Name__c='DDO', Type__c='Access', Rate_Group__c=RG.Id, Unique_ID__c='1', CurrencyIsoCode='USD');
        insert Rddo;
        Rate__c Rla = new Rate__c(Name='Rate', Rate_Name__c='LA', Type__c='Access', Rate_Group__c=RG.Id, Unique_ID__c='2', CurrencyIsoCode='USD');
        insert Rla;
        Rate__c Rpp = new Rate__c(Name='Rate', Rate_Name__c='PP', Type__c='Access', Rate_Group__c=RG.Id, Unique_ID__c='3', CurrencyIsoCode='USD');
        insert Rpp;
        Rate__c Rmb = new Rate__c(Name='Rate', Rate_Name__c='MB', Type__c='Access', Rate_Group__c=RG.Id, Unique_ID__c='4', CurrencyIsoCode='USD');
        insert Rmb;
        Rate__c Rtf = new Rate__c(Name='Rate', Rate_Name__c='TF', Type__c='Access', Rate_Group__c=RG.Id, Unique_ID__c='5', CurrencyIsoCode='USD');
        insert Rtf;

        test.startTest();

        // test header
        ATD = new iContract_NA_Master_Controller.AccessTypeData(new Rate_Group__c(Unique_ID__c='blank'));
        system.assertEquals('', ATD.header, 'Blank name');
        ATD = new iContract_NA_Master_Controller.AccessTypeData(RG);
        system.assertEquals(RG.Name, ATD.header, 'Correct name');
        system.assert(!ATD.createNewPage, 'No new page for < 40 rates');

        // test description and footer
        ATD = new iContract_NA_Master_Controller.AccessTypeData(RG);
        system.assert(!ATD.hasDescription, 'Blank description');
        system.assertEquals('', ATD.description, 'Blank description');
        RG.Description__c = 'Test';
        system.assert(ATD.hasDescription, 'Correct description');
        system.assertEquals(RG.Description__c, ATD.description, 'Correct description');
        system.assert(!ATD.hasFooter, 'Blank footer');
        system.assertEquals('', ATD.footer, 'Blank footer');
        RG.Footer__c = 'Test';
        system.assert(ATD.hasFooter, 'Correct footer');
        system.assertEquals(RG.Footer__c, ATD.footer, 'Correct footer');

        // test grid columns
        ATD = new iContract_NA_Master_Controller.AccessTypeData(new Rate_Group__c(Name='International Grid', Unique_ID__c='blank'));
        ATD.sort();
        system.assertEquals(ATD.locationCount, 0, 'No locations');
        //system.assertEquals(ATD.accessTypes.size(), 0, 'No access types');
        system.assertEquals(ATD.locationOrders.size(), 0, 'No location orders');
        //system.assertEquals(ATD.locationsOverridden.size(), 0, 'No location overrides');
        //system.assertEquals(ATD.gridLocationColumnPercentWidth, 20, 'Default Location width');
        //system.assertEquals(ATD.gridColumnPercentWidth, 12, 'Default Column width');

        ATD.addAssociatedRate(new Associated_Rate__c(Rate_Name__c='Loc1', Override__c=1, Default__c=1, Rate__c=Rddo.Id, Rate__r=Rddo), ctc);
        ATD.sort();
        system.assertEquals(ATD.locationCount, 1, 'Location');
        //system.assertEquals(ATD.accessTypes.size(), 1, 'Access Types');
        system.assertEquals(ATD.locationOrders.size(), 1, 'Location orders');
        //system.assertEquals(ATD.locationsOverridden.size(), 1, 'Location overrides');
        //system.assertEquals(ATD.gridLocationColumnPercentWidth, 70, '1 Location width');
        //system.assertEquals(ATD.gridColumnPercentWidth, 30, '1 Column width');

        ATD.addAssociatedRate(new Associated_Rate__c(Rate_Name__c='Loc1', Override__c=1, Default__c=1, Rate__c=Rla.Id, Rate__r=Rla), ctc);
        ATD.sort();
        system.assertEquals(ATD.locationCount, 1, 'Location');
        //system.assertEquals(ATD.accessTypes.size(), 2, 'Access Types');
        system.assertEquals(ATD.locationOrders.size(), 1, 'Location orders');
        //system.assertEquals(ATD.locationsOverridden.size(), 1, 'Location overrides');
        //system.assertEquals(ATD.gridLocationColumnPercentWidth, 40, '2 Location width');
        //system.assertEquals(ATD.gridColumnPercentWidth, 30, '2 Column width');

        ATD.addAssociatedRate(new Associated_Rate__c(Rate_Name__c='Loc1', Override__c=1, Default__c=1, Rate__c=Rpp.Id, Rate__r=Rpp), ctc);
        ATD.sort();
        system.assertEquals(ATD.locationCount, 1, 'Location');
        //system.assertEquals(ATD.accessTypes.size(), 3, 'Access Types');
        system.assertEquals(ATD.locationOrders.size(), 1, 'Location orders');
        //system.assertEquals(ATD.locationsOverridden.size(), 1, 'Location overrides');
        //system.assertEquals(ATD.gridLocationColumnPercentWidth, 40, '3 Location width');
        //system.assertEquals(ATD.gridColumnPercentWidth, 20, '3 Column width');

        ATD.addAssociatedRate(new Associated_Rate__c(Rate_Name__c='Loc1', Override__c=1, Default__c=1, Rate__c=Rmb.Id, Rate__r=Rmb), ctc);
        ATD.sort();
        system.assertEquals(ATD.locationCount, 1, 'Location');
        //system.assertEquals(ATD.accessTypes.size(), 4, 'Access Types');
        system.assertEquals(ATD.locationOrders.size(), 1, 'Location orders');
        //system.assertEquals(ATD.locationsOverridden.size(), 1, 'Location overrides');
        //system.assertEquals(ATD.gridLocationColumnPercentWidth, 32, '4 Location width');
        //system.assertEquals(ATD.gridColumnPercentWidth, 17, '4 Column width');

        ATD.addAssociatedRate(new Associated_Rate__c(Rate_Name__c='Loc1', Override__c=1, Default__c=1, Rate__c=Rtf.Id, Rate__r=Rtf), ctc);
        ATD.sort();
        system.assertEquals(ATD.locationCount, 1, 'Location');
        //system.assertEquals(ATD.accessTypes.size(), 5, 'Access Types');
        system.assertEquals(ATD.locationOrders.size(), 1, 'Location orders');
        //system.assertEquals(ATD.locationsOverridden.size(), 1, 'Location overrides');
        //system.assertEquals(ATD.gridLocationColumnPercentWidth, 30, '5 Location width');
        //system.assertEquals(ATD.gridColumnPercentWidth, 14, '5 Column width');

        // test multigrids - 1
        integer rateIndex = 0;
        ATD = new iContract_NA_Master_Controller.AccessTypeData(new Rate_Group__c(Name='International Grid', Unique_ID__c='blank'));
        system.assertEquals(1, ATD.grids, 'MultiGrid_1: 1 Grid for no Grids');
        system.assertEquals(0, ATD.gridData.size(), 'MultiGrid_1: Empty grids for 0 rates');
        for (rateIndex = 0; rateIndex < 6; rateIndex++)
            ATD.addAssociatedRate(new Associated_Rate__c(Name=String.valueOf(ATD.locations.size()), Rate_Name__c=String.valueOf(ATD.locations.size()), Override__c=1, Default__c=1, Rate__c=Rddo.Id, Rate__r=Rddo), ctc);
        ATD.sort();
        system.assertEquals(1, ATD.gridData.size(), 'MultiGrid_1: 1 grid for ' + ATD.locations.size() + ' rates');
        system.assertEquals(6, ATD.gridData.get(0).locations.size(), 'MultiGrid_1: 1 grid for ' + ATD.locations.size() + ' rates: 6 in 0');

        // test multigrids - 2
        ATD = new iContract_NA_Master_Controller.AccessTypeData(new Rate_Group__c(Name='International Grid', Unique_ID__c='blank'));
        ATD.rateGroup.Multi_Grid__c = 2;
        system.assertEquals(2, ATD.grids, 'MultiGrid_2: 2 Grids');
        system.assertEquals(0, ATD.gridData.size(), 'MultiGrid_2: Empty grids for 0 rates');

        for (rateIndex = 0; rateIndex < 3; rateIndex++)
            ATD.addAssociatedRate(new Associated_Rate__c(Name=String.valueOf(ATD.locations.size()), Rate_Name__c=String.valueOf(ATD.locations.size()), Override__c=1, Default__c=1, Rate__c=Rddo.Id, Rate__r=Rddo), ctc);
        ATD.sort();
        system.assertEquals(1, ATD.gridData.size(), 'MultiGrid_2: 1 grid for ' + ATD.locations.size() + ' rates');
        system.assertEquals(3, ATD.gridData.get(0).locations.size(), 'MultiGrid_2: 1 grid for ' + ATD.locations.size() + ' rates: 3 in 0');

        for (rateIndex = 0; rateIndex < 5; rateIndex++)
            ATD.addAssociatedRate(new Associated_Rate__c(Name=String.valueOf(ATD.locations.size()), Rate_Name__c=String.valueOf(ATD.locations.size()), Override__c=1, Default__c=1, Rate__c=Rddo.Id, Rate__r=Rddo), ctc);
        ATD.sort();
        system.assertEquals(2, ATD.gridData.size(), 'MultiGrid_2: 2 grids for ' + ATD.locations.size() + ' rates');
        system.assertEquals(4, ATD.gridData.get(0).locations.size(), 'MultiGrid_2: 2 grids for ' + ATD.locations.size() + ' rates: 4 in 0');
        system.assertEquals(4, ATD.gridData.get(1).locations.size(), 'MultiGrid_2: 2 grids for ' + ATD.locations.size() + ' rates: 4 in 1');
        system.assertEquals(50, ATD.gridPercentWidth, 'MultiGrid_2: 2 grids at 50% each');

        // test multigrids - 3
        ATD = new iContract_NA_Master_Controller.AccessTypeData(new Rate_Group__c(Name='International Grid', Unique_ID__c='blank'));
        ATD.rateGroup.Multi_Grid__c = 3;
        system.assertEquals(3, ATD.grids, 'MultiGrid_3: 3 Grids');
        system.assertEquals(0, ATD.gridData.size(), 'MultiGrid_3: Empty grids for 0 rates');

        for (rateIndex = 0; rateIndex < 3; rateIndex++)
            ATD.addAssociatedRate(new Associated_Rate__c(Name=String.valueOf(ATD.locations.size()), Rate_Name__c=String.valueOf(ATD.locations.size()), Override__c=1, Default__c=1, Rate__c=Rddo.Id, Rate__r=Rddo), ctc);
        ATD.sort();
        system.assertEquals(1, ATD.gridData.size(), 'MultiGrid_3: 1 grid for ' + ATD.locations.size() + ' rates');
        system.assertEquals(3, ATD.gridData.get(0).locations.size(), 'MultiGrid_3: 1 grid for ' + ATD.locations.size() + ' rates: 3 in 0');

        for (rateIndex = 0; rateIndex < 2; rateIndex++)
            ATD.addAssociatedRate(new Associated_Rate__c(Name=String.valueOf(ATD.locations.size()), Rate_Name__c=String.valueOf(ATD.locations.size()), Override__c=1, Default__c=1, Rate__c=Rddo.Id, Rate__r=Rddo), ctc);
        ATD.sort();
        system.assertEquals(2, ATD.gridData.size(), 'MultiGrid_3: 2 grids for ' + ATD.locations.size() + ' rates');
        system.assertEquals(3, ATD.gridData.get(0).locations.size(), 'MultiGrid_3: 2 grids for ' + ATD.locations.size() + ' rates: 3 in 0');
        system.assertEquals(2, ATD.gridData.get(1).locations.size(), 'MultiGrid_3: 2 grids for ' + ATD.locations.size() + ' rates: 2 in 1');

        for (rateIndex = 0; rateIndex < 8; rateIndex++)
            ATD.addAssociatedRate(new Associated_Rate__c(Name=String.valueOf(ATD.locations.size()), Rate_Name__c=String.valueOf(ATD.locations.size()), Override__c=1, Default__c=1, Rate__c=Rddo.Id, Rate__r=Rddo), ctc);
        ATD.sort();
        system.assertEquals(3, ATD.gridData.size(), 'MultiGrid_3: 3 grids for ' + ATD.locations.size() + ' rates');
        system.assertEquals(5, ATD.gridData.get(0).locations.size(), 'MultiGrid_3: 3 grids for ' + ATD.locations.size() + ' rates: 5 in 0');
        system.assertEquals(4, ATD.gridData.get(1).locations.size(), 'MultiGrid_3: 3 grids for ' + ATD.locations.size() + ' rates: 4 in 1');
        system.assertEquals(4, ATD.gridData.get(2).locations.size(), 'MultiGrid_3: 3 grids for ' + ATD.locations.size() + ' rates: 4 in 2');
        system.assertEquals(33, ATD.gridPercentWidth, 'MultiGrid_3: 3 grids at 33% each');

        // test multigrids - 4
        ATD = new iContract_NA_Master_Controller.AccessTypeData(new Rate_Group__c(Name='International Grid', Unique_ID__c='blank'));
        ATD.rateGroup.Multi_Grid__c = 4;
        system.assertEquals(4, ATD.grids, 'MultiGrid_4: 3 Grids');
        system.assertEquals(0, ATD.gridData.size(), 'MultiGrid_4: Empty grids for 0 rates');

        for (rateIndex = 0; rateIndex < 10; rateIndex++)
            ATD.addAssociatedRate(new Associated_Rate__c(Name=String.valueOf(ATD.locations.size()), Rate_Name__c=String.valueOf(ATD.locations.size()), Override__c=1, Default__c=1, Rate__c=Rddo.Id, Rate__r=Rddo), ctc);
        ATD.sort();
        system.assertEquals(3, ATD.gridData.size(), 'MultiGrid_4: 3 grids for ' + ATD.locations.size() + ' rates');
        system.assertEquals(4, ATD.gridData.get(0).locations.size(), 'MultiGrid_4: 3 grids for ' + ATD.locations.size() + ' rates: 4 in 0');
        system.assertEquals(3, ATD.gridData.get(1).locations.size(), 'MultiGrid_4: 3 grids for ' + ATD.locations.size() + ' rates: 3 in 1');
        system.assertEquals(3, ATD.gridData.get(2).locations.size(), 'MultiGrid_4: 3 grids for ' + ATD.locations.size() + ' rates: 3 in 2');

        for (rateIndex = 0; rateIndex < 21; rateIndex++)
            ATD.addAssociatedRate(new Associated_Rate__c(Name=String.valueOf(ATD.locations.size()), Rate_Name__c=String.valueOf(ATD.locations.size()), Override__c=1, Default__c=1, Rate__c=Rddo.Id, Rate__r=Rddo), ctc);
        ATD.sort();
        system.assertEquals(4, ATD.gridData.size(), 'MultiGrid_4: 4 grids for ' + ATD.locations.size() + ' rates');
        system.assertEquals(8, ATD.gridData.get(0).locations.size(), 'MultiGrid_4: 4 grids for ' + ATD.locations.size() + ' rates: 8 in 0');
        system.assertEquals(8, ATD.gridData.get(1).locations.size(), 'MultiGrid_4: 4 grids for ' + ATD.locations.size() + ' rates: 8 in 1');
        system.assertEquals(8, ATD.gridData.get(2).locations.size(), 'MultiGrid_4: 4 grids for ' + ATD.locations.size() + ' rates: 8 in 2');
        system.assertEquals(7, ATD.gridData.get(3).locations.size(), 'MultiGrid_4: 4 grids for ' + ATD.locations.size() + ' rates: 7 in 3');
        system.assertEquals(25, ATD.gridPercentWidth, 'MultiGrid_4: 4 grids at 25% each');
        system.assert(!ATD.createNewPage, 'No new page for < 60 rates');

        test.stopTest();
        System.debug(LOG_TAG + 'TestAccessTypeData Passed!');
    }

    static testMethod void TestSingleGridData() {
        System.debug(LOG_TAG + 'TestSingleGridData Started!');


        // setup reusable data
        Rate_Group__c RG = new Rate_Group__c(Name='Rate Group', Unique_ID__c='1');
        Associated_Rate__c AR = new Associated_Rate__c(Name='AR 1');
        iContract_NA_Master_Controller.SingleGridData SGD;
        CONMAN_Contract__c ctc = new CONMAN_Contract__c();

        Rate__c Rddo = new Rate__c(Name='Rate', Rate_Name__c='DDO', Type__c='Access', Rate_Group__c=RG.Id, Unique_ID__c='1', CurrencyIsoCode='USD');
        insert Rddo;
        Rate__c Rla = new Rate__c(Name='Rate', Rate_Name__c='LA', Type__c='Access', Rate_Group__c=RG.Id, Unique_ID__c='2', CurrencyIsoCode='USD');
        insert Rla;
        Rate__c Rpp = new Rate__c(Name='Rate', Rate_Name__c='PP', Type__c='Access', Rate_Group__c=RG.Id, Unique_ID__c='3', CurrencyIsoCode='USD');
        insert Rpp;
        Rate__c Rmb = new Rate__c(Name='Rate', Rate_Name__c='MB', Type__c='Access', Rate_Group__c=RG.Id, Unique_ID__c='4', CurrencyIsoCode='USD');
        insert Rmb;
        Rate__c Rtf = new Rate__c(Name='Rate', Rate_Name__c='TF', Type__c='Access', Rate_Group__c=RG.Id, Unique_ID__c='5', CurrencyIsoCode='USD');
        insert Rtf;

        test.startTest();

        // test grid columns
        SGD = new iContract_NA_Master_Controller.SingleGridData();
        SGD.sort();
        system.assertEquals(SGD.locations.size(), 0, 'No locations');
        system.assertEquals(SGD.accessTypes.size(), 0, 'No access types');
        system.assertEquals(SGD.locationOrders.size(), 0, 'No location orders');
        system.assertEquals(SGD.locationsOverridden.size(), 0, 'No location overrides');
        system.assertEquals(SGD.gridLocationColumnPercentWidth, 20, 'Default Location width');
        system.assertEquals(SGD.gridColumnPercentWidth, 12, 'Default Column width');

        SGD.addRate(new iContract_NA_Master_Controller.RateData(new Associated_Rate__c(Rate_Name__c='Loc1', Override__c=1, Default__c=1, Rate__c=Rddo.Id, Rate__r=Rddo), ctc));
        SGD.sort();
        system.assertEquals(SGD.locations.size(), 1, 'Location');
        system.assertEquals(SGD.accessTypes.size(), 1, 'Access Types');
        system.assertEquals(SGD.locationOrders.size(), 1, 'Location orders');
        system.assertEquals(SGD.locationsOverridden.size(), 1, 'Location overrides');
        system.assertEquals(SGD.locationsOverridden.get('Loc1'), false, 'Location override 1');
        system.assertEquals(SGD.gridLocationColumnPercentWidth, 70, '1 Location width');
        system.assertEquals(SGD.gridColumnPercentWidth, 30, '1 Column width');

        SGD.addRate(new iContract_NA_Master_Controller.RateData(new Associated_Rate__c(Rate_Name__c='Loc1', Override__c=1, Default__c=1, Rate__c=Rla.Id, Rate__r=Rla), ctc));
        SGD.sort();
        system.assertEquals(SGD.locations.size(), 1, 'Location');
        system.assertEquals(SGD.accessTypes.size(), 2, 'Access Types');
        system.assertEquals(SGD.locationOrders.size(), 1, 'Location orders');
        system.assertEquals(SGD.locationsOverridden.size(), 1, 'Location overrides');
        system.assertEquals(SGD.locationsOverridden.get('Loc1'), false, 'Location override 1');
        system.assertEquals(SGD.gridLocationColumnPercentWidth, 40, '2 Location width');
        system.assertEquals(SGD.gridColumnPercentWidth, 30, '2 Column width');

        SGD.addRate(new iContract_NA_Master_Controller.RateData(new Associated_Rate__c(Rate_Name__c='Loc1', Override__c=1, Default__c=1, Rate__c=Rpp.Id, Rate__r=Rpp), ctc));
        SGD.sort();
        system.assertEquals(SGD.locations.size(), 1, 'Location');
        system.assertEquals(SGD.accessTypes.size(), 3, 'Access Types');
        system.assertEquals(SGD.locationOrders.size(), 1, 'Location orders');
        system.assertEquals(SGD.locationsOverridden.size(), 1, 'Location overrides');
        system.assertEquals(SGD.locationsOverridden.get('Loc1'), false, 'Location override 1');
        system.assertEquals(SGD.gridLocationColumnPercentWidth, 40, '3 Location width');
        system.assertEquals(SGD.gridColumnPercentWidth, 20, '3 Column width');

        SGD.addRate(new iContract_NA_Master_Controller.RateData(new Associated_Rate__c(Rate_Name__c='Loc1', Override__c=1, Default__c=1, Rate__c=Rmb.Id, Rate__r=Rmb), ctc));
        SGD.sort();
        system.assertEquals(SGD.locations.size(), 1, 'Location');
        system.assertEquals(SGD.accessTypes.size(), 4, 'Access Types');
        system.assertEquals(SGD.locationOrders.size(), 1, 'Location orders');
        system.assertEquals(SGD.locationsOverridden.size(), 1, 'Location overrides');
        system.assertEquals(SGD.locationsOverridden.get('Loc1'), false, 'Location override 1');
        system.assertEquals(SGD.gridLocationColumnPercentWidth, 32, '4 Location width');
        system.assertEquals(SGD.gridColumnPercentWidth, 17, '4 Column width');

        SGD.addRate(new iContract_NA_Master_Controller.RateData(new Associated_Rate__c(Rate_Name__c='Loc1', Override__c=1, Default__c=1, Rate__c=Rtf.Id, Rate__r=Rtf), ctc));
        SGD.sort();
        system.assertEquals(SGD.locations.size(), 1, 'Location');
        system.assertEquals(SGD.accessTypes.size(), 5, 'Access Types');
        system.assertEquals(SGD.locationOrders.size(), 1, 'Location orders');
        system.assertEquals(SGD.locationsOverridden.size(), 1, 'Location overrides');
        system.assertEquals(SGD.locationsOverridden.get('Loc1'), false, 'Location override 1');
        system.assertEquals(SGD.gridLocationColumnPercentWidth, 30, '5 Location width');
        system.assertEquals(SGD.gridColumnPercentWidth, 14, '5 Column width');

        SGD.addRate(new iContract_NA_Master_Controller.RateData(new Associated_Rate__c(Rate_Name__c='Loc2', Override__c=1, Default__c=1, Rate__c=Rtf.Id, Rate__r=Rtf), ctc));
        SGD.sort();
        system.assertEquals(SGD.locations.size(), 2, 'Location');
        system.assertEquals(SGD.accessTypes.size(), 5, 'Access Types');
        system.assertEquals(SGD.locationOrders.size(), 2, 'Location orders');
        system.assertEquals(SGD.locationsOverridden.size(), 2, 'Location overrides');
        system.assertEquals(SGD.locationsOverridden.get('Loc1'), false, 'Location override 1');
        system.assertEquals(SGD.locationsOverridden.get('Loc2'), false, 'Location override 2');
        system.assertEquals(SGD.gridLocationColumnPercentWidth, 30, '6 Location width');
        system.assertEquals(SGD.gridColumnPercentWidth, 14, '5 Column width');

        SGD.addRate(new iContract_NA_Master_Controller.RateData(new Associated_Rate__c(Rate_Name__c='Loc2', Override__c=0.5, Default__c=1, Rate__c=Rtf.Id, Rate__r=Rtf), ctc));
        SGD.sort();
        system.assertEquals(SGD.locations.size(), 2, 'Location');
        system.assertEquals(SGD.accessTypes.size(), 5, 'Access Types');
        system.assertEquals(SGD.locationOrders.size(), 2, 'Location orders');
        system.assertEquals(SGD.locationsOverridden.size(), 2, 'Location overrides');
        system.assertEquals(SGD.locationsOverridden.get('Loc1'), false, 'Location override 1');
        system.assertEquals(SGD.locationsOverridden.get('Loc2'), true, 'Location override 2');
        system.assertEquals(SGD.gridLocationColumnPercentWidth, 30, '7 Location width');
        system.assertEquals(SGD.gridColumnPercentWidth, 14, '5 Column width');

        test.stopTest();
        System.debug(LOG_TAG + 'TestSingleGridData Passed!');
    }

    static testMethod void TestVerbiageData() {
        System.debug(LOG_TAG + 'TestVerbiageData Started!');

        // insert necessary data
        PGIServicesInformation__c av_PIT = new PGIServicesInformation__c(Name='Contract Terms', Active__c=true, Order__c=1, Section__c='Pre-Intro Table', Agreement_Type__c='Subscription License Order', Content_RTF__c='Contract Terms', Unique_ID__c='1');
        insert av_PIT;
        PGIServicesInformation__c av_I = new PGIServicesInformation__c(Name='Contract Terms', Active__c=true, Order__c=1, Section__c='Intro', Agreement_Type__c='Subscription License Order', Content_RTF__c='Contract Terms', Unique_ID__c='2');
        insert av_I;
        PGIServicesInformation__c av_S = new PGIServicesInformation__c(Name='Contract Terms', Active__c=true, Order__c=1, Section__c='Signature', Agreement_Type__c='Subscription License Order', Content_RTF__c='Contract Terms', Unique_ID__c='3');
        insert av_S;

        Contract_Terms__c pv = new Contract_Terms__c(Name='Product Terms', Terms_and_Conditions_RTF__c='Product Terms', Unique_ID__c='1');
        insert pv;

        // setup reusable data
        CONMAN_Contract_Verbiage__c cv = new CONMAN_Contract_Verbiage__c(Name='test', Verbiage__c='Terms');
        iContract_NA_Master_Controller.VerbiageData tvd;

        test.startTest();

        // test Ids
        tvd = new iContract_NA_Master_Controller.VerbiageData(cv);
        system.assertEquals(cv, tvd.contractVerbiage, 'Correct Id');
        system.assertEquals('', tvd.originalId, 'Blank Original Id');
        cv.Contract_General_Content__c = av_PIT.Id;
        cv.Contract_Product_Verbiage__c = null;
        system.assertEquals(av_PIT.Id, tvd.originalId, 'Correct av_PIT Original Id');
        cv.Contract_General_Content__c = null;
        cv.Contract_Product_Verbiage__c = pv.Id;
        system.assertEquals(pv.Id, tvd.originalId, 'Correct pv Original Id');

        // test Name
        tvd = new iContract_NA_Master_Controller.VerbiageData(cv);
        system.assertEquals(cv.Name, tvd.name, 'Correct Name');
        cv.Contract_General_Content__c = null;
        cv.Contract_General_Content__r = null;
        cv.Contract_Product_Verbiage__c = null;
        cv.Contract_Product_Verbiage__r = null;
        system.assert(tvd.isCustomName, 'Blank Custom Name');
        cv.Contract_General_Content__c = av_PIT.Id;
        cv.Contract_General_Content__r = av_PIT;
        cv.Contract_Product_Verbiage__c = null;
        cv.Contract_Product_Verbiage__r = null;
        system.assert(tvd.isCustomName, 'Correct Custom Name');
        cv.Name = av_PIT.Name;
        system.assert(!tvd.isCustomName, 'Correct Custom Name');
        cv.Contract_General_Content__c = null;
        cv.Contract_General_Content__r = null;
        cv.Contract_Product_Verbiage__c = pv.Id;
        cv.Contract_Product_Verbiage__r = pv;
        system.assert(tvd.isCustomName, 'Correct Custom Name');
        cv.Name = pv.Name;
        system.assert(!tvd.isCustomName, 'Correct Custom Name');

        // test Verbiage
        tvd = new iContract_NA_Master_Controller.VerbiageData(cv);
        system.assertEquals(cv.Verbiage__c, tvd.verbiage, 'Correct Verbiage');
        cv.Contract_General_Content__c = null;
        cv.Contract_General_Content__r = null;
        cv.Contract_Product_Verbiage__c = null;
        cv.Contract_Product_Verbiage__r = null;
        system.assert(tvd.isCustomVerbiage, 'Blank Custom Verbiage');
        cv.Contract_General_Content__c = av_PIT.Id;
        cv.Contract_General_Content__r = av_PIT;
        cv.Contract_Product_Verbiage__c = null;
        cv.Contract_Product_Verbiage__r = null;
        system.assert(tvd.isCustomVerbiage, 'Correct Custom Verbiage');
        cv.Verbiage__c = av_PIT.Content_RTF__c;
        system.assert(!tvd.isCustomVerbiage, 'Correct Custom Verbiage');
        cv.Contract_General_Content__c = null;
        cv.Contract_General_Content__r = null;
        cv.Contract_Product_Verbiage__c = pv.Id;
        cv.Contract_Product_Verbiage__r = pv;
        system.assert(tvd.isCustomVerbiage, 'Correct Custom Verbiage');
        cv.Verbiage__c = pv.Terms_and_Conditions_RTF__c;
        system.assert(!tvd.isCustomVerbiage, 'Correct Custom Verbiage');

        // test Sorting
        List<iContract_NA_Master_Controller.VerbiageData> VDs = new List<iContract_NA_Master_Controller.VerbiageData>();
        VDs.add(new iContract_NA_Master_Controller.VerbiageData(new CONMAN_Contract_Verbiage__c(Order__c=1)));
        VDs.add(new iContract_NA_Master_Controller.VerbiageData(new CONMAN_Contract_Verbiage__c(Order__c=5)));
        VDs.add(new iContract_NA_Master_Controller.VerbiageData(new CONMAN_Contract_Verbiage__c(Order__c=-5)));
        VDs.sort();
        system.assertEquals(-5, VDs.get(0).contractVerbiage.Order__c, 'First item sorted');
        system.assertEquals(1, VDs.get(1).contractVerbiage.Order__c, 'Second item sorted');
        system.assertEquals(5, VDs.get(2).contractVerbiage.Order__c, 'Third item sorted');

        test.stopTest();
        System.debug(LOG_TAG + 'TestVerbiageData Passed!');
    }

    static testMethod void TestControllerFields() {
        System.debug(LOG_TAG + 'TestControllerFields Started!');

        // insert necessary data
        PGIServicesInformation__c av_PIT = new PGIServicesInformation__c(Name='Contract Terms', Active__c=true, Order__c=1, Section__c='Pre-Intro Table', Agreement_Type__c='Subscription License Order', Content_RTF__c='Contract Terms', Unique_ID__c='1');
        insert av_PIT;
        PGIServicesInformation__c av_I = new PGIServicesInformation__c(Name='Contract Terms', Active__c=true, Order__c=1, Section__c='Intro', Agreement_Type__c='Subscription License Order', Content_RTF__c='Contract Terms', Unique_ID__c='2');
        insert av_I;
        PGIServicesInformation__c av_S = new PGIServicesInformation__c(Name='Contract Terms', Active__c=true, Order__c=1, Section__c='Signature', Agreement_Type__c='Subscription License Order', Content_RTF__c='Contract Terms', Unique_ID__c='3');
        insert av_S;

        Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;

        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        insert opptytest;

        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        cntcttest.MailingCountry = 'Canada';
        cntcttest.Language_Preference__c = 'EN';
        insert cntcttest;

        OpportunityContactRole opptyCntcRole = new OpportunityContactRole();
        opptyCntcRole.ContactId = cntcttest.Id;
        opptyCntcRole.OpportunityId = opptytest.Id;
        opptyCntcRole.IsPrimary = true;
        opptyCntcRole.Role = 'Agreement Signer'; 
        insert opptyCntcRole;

        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        ctrctest.Contract_Status__c = 'Legal Rejected';
        insert ctrctest;

        CONMAN_Contract_Verbiage__c cv_PIT = new CONMAN_Contract_Verbiage__c(Name='test', Verbiage__c='Terms', Contract_General_Content__c=av_PIT.Id, PGi_Contract__c=ctrctest.Id,Language__c = 'en_US');
        insert cv_PIT;
        CONMAN_Contract_Verbiage__c cv_I = new CONMAN_Contract_Verbiage__c(Name='test', Verbiage__c='Terms', Contract_General_Content__c=av_I.Id, PGi_Contract__c=ctrctest.Id,Language__c = 'en_US');
        insert cv_I;
        CONMAN_Contract_Verbiage__c cv_S = new CONMAN_Contract_Verbiage__c(Name='test', Verbiage__c='Terms', Contract_General_Content__c=av_S.Id, PGi_Contract__c=ctrctest.Id,Language__c = 'en_US');
        insert cv_S;

        LicenseSet__c licSet = new LicenseSet__c(name='Billing Services', PGi_Contract__c = ctrctest.id);
        insert licSet;

        licSet = new LicenseSet__c(name='Non-contiguous US Call Charges', PGi_Contract__c = ctrctest.id);
        insert licSet;

        licSet = new LicenseSet__c(name='Other NL', PGi_Contract__c = ctrctest.id);
        insert licSet;

        List<Associated_Rate__c> arstest = new List<Associated_Rate__c>();
        for (Integer i : new Integer[] {0, 1}) {
            LicenseSet__c lstest = createLicenseSet(''+i);
            lstest.Opportunity__c = opptytest.Id;
            lstest.PGi_Contract__c = ctrctest.Id;
        	insert lstest;
            arstest.add(createAssociatedRate(lstest, null));
        }

        Rate__c Rsub = new Rate__c(Unique_ID__c='1', Type__c='Sub');
        insert Rsub;
        arstest.add(createAssociatedRate(licSet, Rsub));

        Rate__c Rotc = new Rate__c(Unique_ID__c='2', Type__c='Once');
        insert Rotc;
        arstest.add(createAssociatedRate(licSet, Rotc));
        insert arstest;

        test.startTest();

        ApexPages.currentPage().getParameters().put('id', ctrctest.Id);
        iContract_NA_Master_Controller cd = new iContract_NA_Master_Controller();

        system.assert(cd.contract.id == ctrctest.id, 'Controller\'s contract same as passed to it');
        system.assert(cd.contactData.id == cntcttest.id, 'Controller\'s contact same as passed to it');
        // system.assertEquals('3250 Bloor St. W, East Tower Suite 400, Toronto, ON  M8X 2X9', cd.pgiAddress, 'PGi Address correct for Region.');
        // system.assertEquals('Premiere Conferencing (Canada) Limited d/b/a Premiere Global Services', cd.pgiName, 'PGi Name correct for Region.');

        system.assert(!cd.isExemptTelecomSurcharge, 'Starts Non-Exempt for Telecom Surcharge');
        cd.contract.Exempt_Telecom_Surcharge__c = true;
        system.assert(cd.isExemptTelecomSurcharge, 'Exempt for Telecom Surcharge');

        system.assert(!cd.isExemptServiceFee, 'Starts Non-Exempt for Telecom Surcharge');
        cd.contract.Exempt_Service_Fee__c = true;
        system.assert(cd.isExemptServiceFee, 'Exempt for Telecom Surcharge');

        system.assert(cd.canExportWord, 'Editing for Verbiage'); // System Admin from Tests
        system.assert(cd.canEditVerbiage, 'Editing for Verbiage'); // System Admin from Tests
        system.assert(cd.canEditPricing, 'Editing for Pricing'); // System Admin from Tests

        system.assertEquals('Unknown Opportunity', cd.contractTitle, 'Unknown Contract Title');
        cd.oppData.Type = 'Existing Cust- Existing Svc';
        system.assertEquals('PGi Amendment', cd.contractTitle, 'Amendment Contract Title');
        cd.oppData.Type = 'New Logo';
        system.assertEquals('PGi Subscription License Order', cd.contractTitle, 'Default Contract Title');
        
        system.assertEquals(1, cd.firstPageVerbiage.size(), 'Intro Verbiage');
        system.assertEquals(cv_I.Id, cd.firstPageVerbiage.get(0).Id, 'Intro Verbiage');
        system.assertEquals(1, cd.sortedTableContractVerbiage.size(), 'Pre-Intro Table Verbiage');
        system.assertEquals(cv_PIT.Id, cd.sortedTableContractVerbiage.get(0).Id, 'Pre-Intro Table Verbiage');
        system.assertEquals(1, cd.signingVerbiage.size(), 'Signature Verbiage');
        system.assertEquals(cv_S.Id, cd.signingVerbiage.get(0).Id, 'Signature Verbiage');

        system.assert(!cd.hasProductVerbiage, 'Verbiage');
        system.assert(cd.hasLicenseData, 'Has License Data');
        system.assert(cd.hasOneTimeCharges, 'Has OTCs Licenses');
        system.assert(cd.hasSubscriptions, 'Has Subscription Licenses');
        cd.licenseData.clear();
        system.assert(!cd.hasLicenseData, 'No Licenses');
        system.assert(!cd.hasOneTimeCharges, 'No OTCs Licenses');
        system.assert(!cd.hasSubscriptions, 'No Subscription Licenses');

        cd.contract.Contract_Type__c = 'Subscription License Order';
        system.assert(cd.isSLO, 'SLO: Yes');
        system.assert(!cd.isSLA, 'SLA: No');
        system.assert(!cd.isAmendment, 'Amendment: No');
        system.assert(!cd.isRateChange, 'Rate Modification Amendment: No');
        cd.contract.Contract_Type__c = 'Subscription License Agreement';
        system.assert(!cd.isSLO, 'SLO: No');
        system.assert(cd.isSLA, 'SLA: Yes');
        system.assert(!cd.isAmendment, 'Amendment: No');
        system.assert(!cd.isRateChange, 'Rate Modification Amendment: No');
        cd.contract.Contract_Type__c = 'Amendment';
        system.assert(!cd.isSLO, 'SLO: No');
        system.assert(!cd.isSLA, 'SLA: No');
        system.assert(cd.isAmendment, 'Amendment: Yes');
        system.assert(!cd.isRateChange, 'Rate Modification Amendment: No');
        cd.contract.Contract_Type__c = 'Rate Modification Amendment';
        system.assert(!cd.isSLO, 'SLO: No');
        system.assert(!cd.isSLA, 'SLA: No');
        system.assert(!cd.isAmendment, 'Amendment: No');
        system.assert(cd.isRateChange, 'Rate Modification Amendment: Yes');

        system.assertEquals('', cd.salesRepTerritoryCode, 'No Territory Code');
        cd.oppData.Territory_Code__c = 'D1';
        system.assertEquals('(D1)', cd.salesRepTerritoryCode, 'Territory Code');

        cd.save();
        cd.cancel();

        test.stopTest();

        System.debug(LOG_TAG + 'TestControllerFields Passed!');
    }

    static testMethod void TestAddRateToLicenseSet() {
        System.debug(LOG_TAG + 'TestAddRateToLicenseSet Started!');

        Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;

        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        insert opptytest;

        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        insert cntcttest;

        OpportunityContactRole opptyCntcRole = new OpportunityContactRole();
        opptyCntcRole.ContactId = cntcttest.Id;
        opptyCntcRole.OpportunityId = opptytest.Id;
        opptyCntcRole.IsPrimary = true;
        insert opptyCntcRole;

        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        insert ctrctest;

        LicenseSet__c licSetNC = new LicenseSet__c(name='Non-contiguous US Call Charges', PGi_Contract__c = ctrctest.id);
        insert licSetNC;

        Associated_Rate__c artest = new Associated_Rate__c(Default__c=0.5, Rate_Name__c = 'test', LicenseSet__c = licSetNC.id);
        insert artest;

        test.startTest();

        ApexPages.currentPage().getParameters().put('id', ctrctest.Id);
        iContract_NA_Master_Controller cd = new iContract_NA_Master_Controller();

        System.assertEquals(1, cd.licenseData.get(0).rateGroups.get('').rates.size(), 'Rate already added to License');

        cd.actOnLicenseSetId = licSetNC.Id;
        cd.addRateToLicenseSet();

        System.assertEquals(2, cd.licenseData.get(0).rateGroups.get('').rates.size(), 'Rate not added to License');

        test.stopTest();

        System.debug(LOG_TAG + 'TestAddRateToLicenseSet Passed!');
    }

    static testMethod void TestAddLicenseSet() {
        System.debug(LOG_TAG + 'TestAddLicenseSet Started!');

        Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;

        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        insert opptytest;

        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        insert cntcttest;

        OpportunityContactRole opptyCntcRole = new OpportunityContactRole();
        opptyCntcRole.ContactId = cntcttest.Id;
        opptyCntcRole.OpportunityId = opptytest.Id;
        opptyCntcRole.IsPrimary = true;
        insert opptyCntcRole;
		PGi_Internal_Entity__c objInternalEntity = new PGi_Internal_Entity__c();
        objInternalEntity.Address_1__c='A1';
        objInternalEntity.Address_2__c='A2';
            objInternalEntity.Business_Registration__c='TestBusiness';
            objInternalEntity.City__c='Vegas';
            objInternalEntity.Country__c='United States';
            objInternalEntity.Legal_Entity_Name__c='Test1';
            objInternalEntity.State__c='Toranto';
            objInternalEntity.Zip_Postal_Code__c='0123';
        Insert objInternalEntity;
        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        ctrctest.PGi_Internal_Entity__c=objInternalEntity.Id;
        insert ctrctest;

        LicenseSet__c licSetNC = new LicenseSet__c(name='Non-contiguous US Call Charges', PGi_Contract__c = ctrctest.id);
        insert licSetNC;

        test.startTest();

        ApexPages.currentPage().getParameters().put('id', ctrctest.Id);
        iContract_NA_Master_Controller cd = new iContract_NA_Master_Controller();

        System.assertEquals(1, cd.licenseData.size(), 'License already added');
		PGi_Internal_Entity__c objEntityInternal =cd.pgiInternalEntity;
        cd.addLicenseSet();

        System.assertEquals(2, cd.licenseData.size(), 'License not added');
        cd.updateProductdetails();
        test.stopTest();

        System.debug(LOG_TAG + 'TestAddLicenseSet Passed!');
    }

    static testMethod void TestDeleteRateFromLicenseSet() {
        System.debug(LOG_TAG + 'TestDeleteRateFromLicenseSet Started!');

        Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;

        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        insert opptytest;

        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        insert cntcttest;

        OpportunityContactRole opptyCntcRole = new OpportunityContactRole();
        opptyCntcRole.ContactId = cntcttest.Id;
        opptyCntcRole.OpportunityId = opptytest.Id;
        opptyCntcRole.IsPrimary = true;
        insert opptyCntcRole;

        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        insert ctrctest;

        LicenseSet__c licSetNC = new LicenseSet__c(name='Non-contiguous US Call Charges', PGi_Contract__c = ctrctest.id);
        insert licSetNC;

        Associated_Rate__c artestND = new Associated_Rate__c(Default__c=0.5, Rate_Name__c = 'test', LicenseSet__c = licSetNC.id);
        insert artestND;

        Associated_Rate__c artest = new Associated_Rate__c(Default__c=0.5, Rate_Name__c = 'test', LicenseSet__c = licSetNC.id);
        insert artest;

        test.startTest();

        ApexPages.currentPage().getParameters().put('id', ctrctest.Id);
        iContract_NA_Master_Controller cd = new iContract_NA_Master_Controller();

        System.assertEquals(2, cd.licenseData.get(0).rateGroups.get('').rates.size(), 'Rate not in License');
		PGi_Internal_Entity__c objEntityInternal =cd.pgiInternalEntity;
        String termLength = cd.termLength;
        Boolean isCSA =cd.isCSA;
        boolean isAddressValid =cd.isAddressValid;
        boolean isAddressNAM =cd.isAddressNAM;
        cd.actOnLicenseSetId = licSetNC.Id;
        cd.actOnAssociatedRateId = artest.Id;
        cd.deleteRateFromLicenseSet();
        cd.save();

        System.assertEquals(2, cd.licenseData.get(0).rateGroups.get('').rates.size(), 'Rate in License deleted');
        System.assertEquals(true, [SELECT Disabled__c FROM Associated_Rate__c WHERE Id = :artest.Id].Disabled__c,
                           'Rate not disabled');

        test.stopTest();

        System.debug(LOG_TAG + 'TestDeleteRateFromLicenseSet Passed!');
    }

    static testMethod void TestDeleteLicenseSet() {
        System.debug(LOG_TAG + 'TestDeleteLicenseSet Started!');

        Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;

        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        insert opptytest;

        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        insert cntcttest;

        OpportunityContactRole opptyCntcRole = new OpportunityContactRole();
        opptyCntcRole.ContactId = cntcttest.Id;
        opptyCntcRole.OpportunityId = opptytest.Id;
        opptyCntcRole.IsPrimary = true;
        insert opptyCntcRole;

        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        insert ctrctest;

        LicenseSet__c licSetBS = new LicenseSet__c(name='Billing Services', PGi_Contract__c = ctrctest.id);
        insert licSetBS;

        LicenseSet__c licSetNC = new LicenseSet__c(name='Non-contiguous US Call Charges', PGi_Contract__c = ctrctest.id);
        insert licSetNC;

        test.startTest();

        ApexPages.currentPage().getParameters().put('id', ctrctest.Id);
        iContract_NA_Master_Controller cd = new iContract_NA_Master_Controller();

        System.assertEquals(2, cd.licenseData.size(), 'LicenseSet not in licenseData');

        cd.actOnLicenseSetId = licSetNC.Id;
        cd.deleteLicenseSet();
        cd.save();

        System.assertEquals(2, cd.licenseData.size(), 'LicenseSet not in licenseData');
        System.assertEquals(true, [SELECT Disabled__c FROM LicenseSet__c WHERE Id = :licSetNC.Id].Disabled__c,
                           'LicenseSet not disabled');

        test.stopTest();

        System.debug(LOG_TAG + 'TestDeleteLicenseSet Passed!');
    }
    static testMethod void TestDeleteRateGroup() {
        System.debug(LOG_TAG + 'TestDeleteRateGroup Started!');

        Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;

        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        insert opptytest;

        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        insert cntcttest;

        OpportunityContactRole opptyCntcRole = new OpportunityContactRole();
        opptyCntcRole.ContactId = cntcttest.Id;
        opptyCntcRole.OpportunityId = opptytest.Id;
        opptyCntcRole.IsPrimary = true;
        insert opptyCntcRole;

        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        insert ctrctest;

        LicenseSet__c licSetNC = new LicenseSet__c(Name='Non-contiguous US Call Charges', PGi_Contract__c = ctrctest.id);
        insert licSetNC;

        Rate_Group__c rgtestND = new Rate_Group__c(Name='Not Deleted', Unique_ID__c='Not Deleted');
        insert rgtestND;
        Rate__c rtestND = new Rate__c(Name='Not Deleted', Type__c='Usage', Unique_ID__c='Not Deleted', Rate_Group__c=rgtestND.Id);
        insert rtestND;

        Rate_Group__c rgtest = new Rate_Group__c(Name='Deleted', Unique_ID__c='Deleted');
        insert rgtest;
        Rate__c rtest1 = new Rate__c(Name='Deleted', Type__c='Usage', Unique_ID__c='Deleted 1', Rate_Group__c=rgtest.Id);
        insert rtest1;
        Rate__c rtest2 = new Rate__c(Name='Deleted', Type__c='Usage', Unique_ID__c='Deleted 2', Rate_Group__c=rgtest.Id);
        insert rtest2;

        Associated_Rate__c artestND = new Associated_Rate__c(Default__c=0.5, Rate_Name__c = 'test', Rate__c=rtestND.Id, LicenseSet__c = licSetNC.id);
        insert artestND;

        Associated_Rate__c artest1 = new Associated_Rate__c(Default__c=0.5, Rate_Name__c = 'test', Rate__c=rtest1.Id, LicenseSet__c = licSetNC.id);
        insert artest1;
        Associated_Rate__c artest2 = new Associated_Rate__c(Default__c=0.5, Rate_Name__c = 'test', Rate__c=rtest2.Id, LicenseSet__c = licSetNC.id);
        insert artest2;

        test.startTest();

        ApexPages.currentPage().getParameters().put('id', ctrctest.Id);
        iContract_NA_Master_Controller cd = new iContract_NA_Master_Controller();

        System.assertEquals(1, cd.licenseData.get(0).rateGroups.get(rgtestND.Id).rates.size(), 'Rate not in License');
        System.assertEquals(2, cd.licenseData.get(0).rateGroups.get(rgtest.Id).rates.size(), 'Rate not in License');

        cd.actOnLicenseSetId = licSetNC.Id;
        cd.actOnRateGroup = rgtest.Id;
        cd.deleteRateGroup();
        cd.save();

        System.assertEquals(1, cd.licenseData.get(0).rateGroups.get(rgtestND.Id).rates.size(), 'Rate in Rate Group not deleted');
        System.assertEquals(2, cd.licenseData.get(0).rateGroups.get(rgtest.Id).rates.size(), 'Rate in Rate Group deleted');
        System.assertEquals(false, [SELECT Disabled__c FROM Associated_Rate__c WHERE Id = :artestND.Id].Disabled__c,
                           'Rate disabled');
        System.assertEquals(true, [SELECT Disabled__c FROM Associated_Rate__c WHERE Id = :artest1.Id].Disabled__c,
                           'Rate not disabled');
        System.assertEquals(true, [SELECT Disabled__c FROM Associated_Rate__c WHERE Id = :artest2.Id].Disabled__c,
                           'Rate not disabled');

        test.stopTest();

        System.debug(LOG_TAG + 'TestDeleteRateGroup Passed!');
    }

    static testMethod void TestSaveOpp() {
        System.debug(LOG_TAG + 'TestSaveOpp Started!');

        Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;

        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        insert opptytest;

        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        insert cntcttest;

        OpportunityContactRole opptyCntcRole = new OpportunityContactRole();
        opptyCntcRole.ContactId = cntcttest.Id;
        opptyCntcRole.OpportunityId = opptytest.Id;
        opptyCntcRole.IsPrimary = true;
        insert opptyCntcRole;

        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        ctrctest.Contract_Status__c = 'New';
        insert ctrctest;

        LicenseSet__c licSet = new LicenseSet__c(name='Billing Services', PGi_Contract__c = ctrctest.id);
        insert licSet;

        test.startTest();

        ApexPages.currentPage().getParameters().put('id', ctrctest.Id);
        iContract_NA_Master_Controller cd = new iContract_NA_Master_Controller();
        cd.oppData.Primary_Won_Reason__c = 'Add-on or Renewal';
        cd.oppData.Secondary_Won_Reason__c = 'Pricing Structure';
        cd.oppData.Differentiating_Win_Factors__c = 'test';
        cd.oppData.Competitor_s__c = 'Airtel';
        cd.oppData.Incumbent__c = 'Airtel';
        cd.oppData.Competitor_Other_Product__c = 'test competitor';
        cd.oppData.Incumbent_Other_Product__c = 'test incumbent';

        PageReference saveOppPage = cd.saveOpp();

        System.assert(!saveOppPage.getParameters().containsKey('errorMsg'), 'Error Message: ' + saveOppPage.getParameters().get('errorMsg'));

        opptytest = [SELECT Id, Primary_Won_Reason__c, Secondary_Won_Reason__c,
                     Differentiating_Win_Factors__c, Competitor_s__c, Incumbent__c,
                     Competitor_Other_Product__c,Incumbent_Other_Product__c
                     FROM Opportunity WHERE Id = :opptytest.Id];

        System.assertEquals('Add-on or Renewal', opptytest.Primary_Won_Reason__c, 'Primary_Won_Reason__c Not Updated');
        System.assertEquals('Pricing Structure', opptytest.Secondary_Won_Reason__c, 'Secondary_Won_Reason__c Not Updated');
        System.assertEquals('test', opptytest.Differentiating_Win_Factors__c, 'Differentiating_Win_Factors__c Not Updated');
        System.assertEquals('Airtel', opptytest.Competitor_s__c, 'Competitor_s__c Not Updated');
        System.assertEquals('Airtel', opptytest.Incumbent__c, 'Incumbent__c Not Updated');

        test.stopTest();

        System.debug(LOG_TAG + 'TestSaveOpp Passed!');
    }

    static testMethod void TestPDF() {
        System.debug(LOG_TAG + 'TestPDF Started!');

        Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;

        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        insert opptytest;

        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        insert cntcttest;

        OpportunityContactRole opptyCntcRole = new OpportunityContactRole();
        opptyCntcRole.ContactId = cntcttest.Id;
        opptyCntcRole.OpportunityId = opptytest.Id;
        opptyCntcRole.IsPrimary = true;
        insert opptyCntcRole;

        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        insert ctrctest;

        LicenseSet__c licSet = new LicenseSet__c(name='Billing Services', PGi_Contract__c = ctrctest.id);
        insert licSet;

        test.startTest();

        ApexPages.currentPage().getParameters().put('id', ctrctest.Id);
        ApexPages.currentPage().getParameters().put('pdfShow', 'true');
        ApexPages.currentPage().getParameters().put('excelShow', 'true');
        iContract_NA_Master_Controller cd = new iContract_NA_Master_Controller();

        System.assertEquals('pdf', cd.renderingService, 'PDF Rendering Service set');
        System.assertEquals('application/pdf#contract.pdf', cd.renderedContentType, 'PDF Rendering Type set');
        System.assertEquals('9', cd.fontSize, 'PDF Font Size set');
        System.assertEquals('', cd.backgroundColor, 'PDF BG Color set');
        System.assertEquals('', cd.textColor, 'PDF FG Color set');
        System.assertEquals('#F8F8F8', cd.tableHeaderBackgroundColor, 'PDF BG Table Color set');
        System.assertEquals('#000000', cd.tableHeaderTextColor, 'PDF FG Table Color set');
        System.assertEquals(false, cd.renderingAsHtml, 'HTML Rendering set');

        cd.contract.Contract_Status__c = 'New';
        System.assert(cd.canDownloadPDF, 'Can Download PDF');
        System.assert(cd.canDownloadQuotePDF, 'Can Download Quote PDF');
        cd.contract.Contract_Status__c = null;
        System.assert(!cd.canDownloadPDF, 'Cannot Download PDF: Null Status');
        System.assert(!cd.canDownloadQuotePDF, 'Cannot Download Quote PDF: Null Status');
        cd.contract.Contract_Status__c = 'Contract Pricing Rejected';
        System.assert(!cd.canDownloadPDF, 'Cannot Download PDF: Contract Pricing Rejected');
        System.assert(!cd.canDownloadQuotePDF, 'Cannot Download Quote PDF: Contract Pricing Rejected');
        cd.contract.Contract_Status__c = 'Awaiting Approval';
        System.assert(!cd.canDownloadPDF, 'Cannot Download PDF: Awaiting Approval');
        System.assert(!cd.canDownloadQuotePDF, 'Cannot Download Quote PDF: Awaiting Approval');
        cd.contract.Contract_Status__c = 'Awaiting Manager Approval';
        System.assert(!cd.canDownloadPDF, 'Cannot Download PDF: Awaiting Manager Approval');
        System.assert(!cd.canDownloadQuotePDF, 'Cannot Download Quote PDF: Awaiting Manager Approval');
        cd.contract.Contract_Status__c = 'Awaiting RVP Approval';
        System.assert(!cd.canDownloadPDF, 'Cannot Download PDF: Awaiting RVP Approval');
        System.assert(!cd.canDownloadQuotePDF, 'Cannot Download Quote PDF: Awaiting RVP Approval');
        cd.contract.Contract_Status__c = 'Awaiting SVP Approval';
        System.assert(!cd.canDownloadPDF, 'Cannot Download PDF: Awaiting SVP Approval');
        System.assert(!cd.canDownloadQuotePDF, 'Cannot Download Quote PDF: Awaiting SVP Approval');
        cd.contract.Contract_Status__c = 'Pending Pricing Approval';
        System.assert(!cd.canDownloadPDF, 'Cannot Download PDF: Pending Pricing Approval');
        System.assert(!cd.canDownloadQuotePDF, 'Cannot Download Quote PDF: Pending Pricing Approval');
        cd.contract.Contract_Status__c = 'Pending Legal Approval';
        System.assert(!cd.canDownloadPDF, 'Cannot Download PDF: Pending Legal Approval');
        System.assert(cd.canDownloadQuotePDF, 'Can Download Quote PDF: Pending Legal Approval');
        cd.contract.Contract_Status__c = 'Legal Rejected';
        System.assert(!cd.canDownloadPDF, 'Cannot Download PDF: Legal Rejected');
        System.assert(!cd.canDownloadQuotePDF, 'Cannot Download Quote PDF: Legal Rejected');
        cd.contract.Contract_Status__c = 'Pending Approval';
        System.assert(!cd.canDownloadPDF, 'Cannot Download PDF: Pending Approval');
        System.assert(!cd.canDownloadQuotePDF, 'Cannot Download Quote PDF: Pending Approval');
        cd.contract.Contract_Status__c = 'Rejected';
        System.assert(!cd.canDownloadPDF, 'Cannot Download PDF: Rejected');
        System.assert(!cd.canDownloadQuotePDF, 'Cannot Download Quote PDF: Rejected');
        cd.contract.Contract_Status__c = 'New';
        cd.contract.Required_Approval_ARG__c = true;
        System.assert(!cd.canDownloadPDF, 'Cannot Download PDF: Required Approval ARG');
        System.assert(!cd.canDownloadQuotePDF, 'Cannot Download Quote PDF: Required Approval ARG');
        cd.contract.Required_Approval_ARG__c = false;
        cd.contract.Required_Approval_Deal_Desk__c = true;
        System.assert(!cd.canDownloadPDF, 'Cannot Download PDF: Required Approval Deal Desk');
        System.assert(!cd.canDownloadQuotePDF, 'Cannot Download Quote PDF: Required Approval Deal Desk');
        cd.contract.Required_Approval_Deal_Desk__c = false;
        cd.contract.Required_Approval_Pricing_Manager__c = true;
        System.assert(!cd.canDownloadPDF, 'Cannot Download PDF: Required Approval Manager');
        System.assert(!cd.canDownloadQuotePDF, 'Cannot Download Quote PDF: Required Approval Manager');
        cd.contract.Required_Approval_Pricing_Manager__c = false;
        cd.contract.Required_Approval_Pricing_RVP__c = true;
        System.assert(!cd.canDownloadPDF, 'Cannot Download PDF: Required Approval RVP');
        System.assert(!cd.canDownloadQuotePDF, 'Cannot Download Quote PDF: Required Approval RVP');
        cd.contract.Required_Approval_Pricing_RVP__c = false;
        cd.contract.Required_Approval_Pricing_SVP__c = true;
        System.assert(!cd.canDownloadPDF, 'Cannot Download PDF: Required Approval SVP');
        System.assert(!cd.canDownloadQuotePDF, 'Cannot Download Quote PDF: Required Approval SVP');
        cd.contract.Required_Approval_Pricing_SVP__c = false;
        cd.contract.Required_Approval_Legal__c = true;
        System.assert(!cd.canDownloadPDF, 'Cannot Download PDF: Required Approval Legal');
        System.assert(cd.canDownloadQuotePDF, 'Can Download Quote PDF: Required Approval Legal');
        cd.contract.Required_Approval_Legal__c = false;
        cd.contract.Required_Approval_Billing__c = true;
        System.assert(!cd.canDownloadPDF, 'Cannot Download PDF: Required Approval Billing');
        System.assert(!cd.canDownloadQuotePDF, 'Cannot Download Quote PDF: Required Approval Billing');
        cd.contract.Required_Approval_Billing__c = false;
        cd.contract.Word_File_In_Use__c = true;
        System.assert(!cd.canDownloadPDF, 'Cannot Download PDF: Word File');
        System.assert(!cd.canDownloadQuotePDF, 'Cannot Download Quote PDF: Word File');
        cd.contract.Word_File_In_Use__c = false;

        cd.downloadPDFEvent();
        cd.toggleLongForm();
    

        ctrctest = [SELECT Id, Contract_Status__c FROM CONMAN_Contract__c WHERE Id = :ctrctest.Id];
        System.assertEquals('Downloaded', ctrctest.Contract_Status__c, 'Status updated');
        List<Attachment> atts = [SELECT Id FROM Attachment WHERE ParentId = :ctrctest.Id];
        System.assertEquals(1, atts.size(), 'Attachment inserted');

        test.stopTest();

        System.debug(LOG_TAG + 'TestPDF Passed!');
    }

    static testMethod void TestWord() {
        System.debug(LOG_TAG + 'TestWord Started!');

        Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;

        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        insert opptytest;

        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        insert cntcttest;

        OpportunityContactRole opptyCntcRole = new OpportunityContactRole();
        opptyCntcRole.ContactId = cntcttest.Id;
        opptyCntcRole.OpportunityId = opptytest.Id;
        opptyCntcRole.IsPrimary = true;
        insert opptyCntcRole;

        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        ctrctest.Contract_Status__c = 'Legal Rejected';
        insert ctrctest;

        LicenseSet__c licSet = new LicenseSet__c(name='Billing Services', PGi_Contract__c = ctrctest.id);
        insert licSet;

        test.startTest();

        ApexPages.currentPage().getParameters().put('id', ctrctest.Id);
        iContract_NA_Master_Controller cd = new iContract_NA_Master_Controller();

        System.assertEquals('html', cd.renderingService, 'HTML Rendering Service set');
        System.assertEquals('text/html', cd.renderedContentType, 'HTML Rendering Type set');
        System.assertEquals('13', cd.fontSize, 'HTML Font Size set');
        System.assertEquals('', cd.backgroundColor, 'HTML BG Color set');
        System.assertEquals('', cd.textColor, 'HTML FG Color set');
        System.assertEquals('#F8F8F8', cd.tableHeaderBackgroundColor, 'HTML BG Table Color set');
        System.assertEquals('#000000', cd.tableHeaderTextColor, 'HTML FG Table Color set');
        System.assertEquals(true, cd.renderingAsHtml, 'HTML Rendering set');

        ApexPages.currentPage().getParameters().put('wordShow', 'true');
        System.assertEquals('', cd.renderingService, 'Word Rendering Service set');
        System.assertEquals('application/msword#contract.doc', cd.renderedContentType, 'Word Rendering Type set');
        System.assertEquals('9', cd.fontSize, 'Word Font Size set');
        System.assertEquals('', cd.backgroundColor, 'Word BG Color set');
        System.assertEquals('', cd.textColor, 'Word FG Color set');
        System.assertEquals('#F8F8F8', cd.tableHeaderBackgroundColor, 'Word BG Table Color set');
        System.assertEquals('#000000', cd.tableHeaderTextColor, 'Word FG Table Color set');
        System.assertEquals(false, cd.renderingAsHtml, 'Word Rendering set');
        ApexPages.currentPage().getParameters().remove('wordShow');

        cd.downloadWordEvent();

        ctrctest = [SELECT Id, Word_File_In_Use__c, Contract_Status__c FROM CONMAN_Contract__c WHERE Id = :ctrctest.Id];
        System.assertEquals(True, ctrctest.Word_File_In_Use__c, 'Word flag not set');
        System.assertEquals('Legal Rejected', ctrctest.Contract_Status__c, 'Status not same');

        System.assertEquals('html', cd.renderingService, 'HTML Rendering Service set');
        System.assertEquals('text/html', cd.renderedContentType, 'HTML Rendering Type set');
        System.assertEquals('13', cd.fontSize, 'HTML Font Size set');
        System.assertEquals('#808080', cd.backgroundColor, 'HTML BG Color set');
        System.assertEquals('#FFFFFF', cd.textColor, 'HTML FG Color set');
        System.assertEquals('#808080', cd.tableHeaderBackgroundColor, 'HTML BG Table Color set');
        System.assertEquals('#FFFFFF', cd.tableHeaderTextColor, 'HTML FG Table Color set');
        System.assertEquals(true, cd.renderingAsHtml, 'HTML Rendering set');

        cd.resetWordEvent();

        ctrctest = [SELECT Id, Word_File_In_Use__c FROM CONMAN_Contract__c WHERE Id = :ctrctest.Id];
        System.assertEquals(False, ctrctest.Word_File_In_Use__c, 'Word flag not unset');

        System.assertEquals('html', cd.renderingService, 'HTML Rendering Service set');
        System.assertEquals('text/html', cd.renderedContentType, 'HTML Rendering Type set');
        System.assertEquals('13', cd.fontSize, 'HTML Font Size set');
        System.assertEquals('', cd.backgroundColor, 'HTML BG Color set');
        System.assertEquals('', cd.textColor, 'HTML FG Color set');
        System.assertEquals(true, cd.renderingAsHtml, 'HTML Rendering set');

        test.stopTest();

        System.debug(LOG_TAG + 'TestWord Passed!');
    }

    static testMethod void TestESign() {
        System.debug(LOG_TAG + 'TestESign Started!');

        Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;

        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        insert opptytest;

        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        insert cntcttest;

        OpportunityContactRole opptyCntcRole = new OpportunityContactRole();
        opptyCntcRole.ContactId = cntcttest.Id;
        opptyCntcRole.OpportunityId = opptytest.Id;
        opptyCntcRole.IsPrimary = true;
        insert opptyCntcRole;

        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        ctrctest.Contract_Status__c = 'New';
        insert ctrctest;

        LicenseSet__c licSet = new LicenseSet__c(name='Billing Services', PGi_Contract__c = ctrctest.id);
        insert licSet;

        echosign_dev1__Agreement_Template__c eSignTemplate = new echosign_dev1__Agreement_Template__c();
        insert eSignTemplate;

        test.startTest();

        ApexPages.currentPage().getParameters().put('id', ctrctest.Id);
        iContract_NA_Master_Controller cd = new iContract_NA_Master_Controller();
        cd.eSignTemplate = eSignTemplate.Id;

        System.assert(!cd.canSubmitEsignature, 'Cannot start eSignature yet');
        cd.oppData.Primary_Won_Reason__c = 'Pricing';
        cd.oppData.Competitor_s__c = 'AAPT';
        cd.oppData.Incumbent__c = 'AAPT';
        cd.oppData.Differentiating_Win_Factors__c = 'test win';
        cd.oppData.Competitor_Other_Product__c = 'test competitor';
        cd.oppData.Incumbent_Other_Product__c = 'test incumbent';
        //System.assert(cd.canSubmitEsignature, 'Can start eSignature');

        PageReference eSignPage = cd.startESignEvent();

        System.assert(!eSignPage.getParameters().containskey('errorMsg'), 'Error Message: ' + eSignPage.getParameters().get('errorMsg'));
       
        echosign_dev1__SIGN_Agreement__c eSign = [SELECT Id, Created_by_iContract__c FROM echosign_dev1__SIGN_Agreement__c LIMIT 1];
        system.assertEquals(True, eSign.Created_by_iContract__c, 'eSign not set to Created by iContract');
        eSign.echosign_dev1__Opportunity__c = opptytest.Id;
        UPDATE eSign;

        Attachment att = [SELECT Id, ParentId FROM Attachment WHERE ParentId = :eSign.Id];
        system.assertEquals(eSign.Id, att.ParentId, 'eSign has no attachment');
        
        ApexPages.currentPage().getParameters().put('id', ctrctest.Id);
        cd = new iContract_NA_Master_Controller();
        system.assertEquals(true, cd.hasESigns, 'eSign on Controller');
        system.assertEquals(1, cd.eSigns.size(), 'eSign on Controller');

        test.stopTest();

        System.debug(LOG_TAG + 'TestESign Passed!');
    }

    static testMethod void TestAccountAgreementName() {
        System.debug(LOG_TAG + 'TestAccountAgreementName Started!');

        Account accttest = PGITestUtilities.getAccountDetails();
        accttest.Name = 'Chas Test';
        insert accttest;

        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        insert opptytest;

        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        insert cntcttest;

        OpportunityContactRole opptyCntcRole = new OpportunityContactRole();
        opptyCntcRole.ContactId = cntcttest.Id;
        opptyCntcRole.OpportunityId = opptytest.Id;
        opptyCntcRole.IsPrimary = true;
        insert opptyCntcRole;

        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        ctrctest.Contract_Status__c = 'New';
        insert ctrctest;

        LicenseSet__c licSet = new LicenseSet__c(name='Billing Services', PGi_Contract__c = ctrctest.id);
        insert licSet;

        test.startTest();

        ApexPages.currentPage().getParameters().put('id', ctrctest.Id);
        iContract_NA_Master_Controller cd = new iContract_NA_Master_Controller();

        system.assertEquals('Chas Test', cd.agreementAccountName, 'Agreement Account Name was not populated.');
        system.assertEquals('2300 Lakeview Parkway, Suite 300, Alpharetta, GA 30009', cd.pgiAddress, 'PGi Address not correct for Region.');
        system.assertEquals('American Teleconferencing Services, Ltd. d/b/a Premiere Global Services', cd.pgiName, 'PGi Name not correct for Region.');

        ctrctest.Account_s_Agreement_Name__c = 'New Agreement name';
        update ctrctest;
        cd = new iContract_NA_Master_Controller();
        system.assertEquals('New Agreement name', cd.agreementAccountName, 'Agreement Account Name was not populated.');

        test.stopTest();

        System.debug(LOG_TAG + 'TestAccountAgreementName Passed!');
    }

    static testMethod void TestCalculateTerm() {
        System.debug(LOG_TAG + 'TestCalculateTerm Started!');

        test.startTest();

        System.assertEquals('1 month ', iContract_NA_Master_Controller.calculateTerm('[termLength]', 1),
                     'CalculateTerm failed for 1 month(s)');
        System.assertEquals('8 months ', iContract_NA_Master_Controller.calculateTerm('[termLength]', 8),
                     'CalculateTerm failed for 8 month(s)');
        System.assertEquals('1 year ', iContract_NA_Master_Controller.calculateTerm('[termLength]', 12),
                     'CalculateTerm failed for 12 month(s)');
        System.assertEquals('2 years ', iContract_NA_Master_Controller.calculateTerm('[termLength]', 24),
                     'CalculateTerm failed for 24 month(s)');
        System.assertEquals('3 years ', iContract_NA_Master_Controller.calculateTerm('[termLength]', 36),
                     'CalculateTerm failed for 36 month(s)');
        System.assertEquals('32 months ', iContract_NA_Master_Controller.calculateTerm('[termLength]', 32),
                     'CalculateTerm failed for 32 month(s)');

        test.stopTest();

        System.debug(LOG_TAG + 'TestCalculateTerm Passed!');
    }

    static testMethod void TestIsRateChanged() {
        System.debug(LOG_TAG + 'TestIsRateChanged Started!');

        test.startTest();

        Associated_Rate__c ARo = new Associated_Rate__c();
        ARo.Override__c = 0.9;
        Associated_Rate__c ARo2 = new Associated_Rate__c();
        ARo2.Override__c = 0.8;
        System.assert(iContract_NA_Master_Controller.isRateChanged(ARo, ARo2), 'Overridde difference not detected');

        Associated_Rate__c ARd = new Associated_Rate__c();
        ARd.Description__c = 'Test';
        Associated_Rate__c ARd2 = new Associated_Rate__c();
        ARd2.Description__c = 'Test2';
        System.assert(iContract_NA_Master_Controller.isRateChanged(ARd, ARd2), 'Description difference not detected');

        Associated_Rate__c ARr = new Associated_Rate__c();
        ARr.Recurrence__c = 'Year';
        Associated_Rate__c ARr2 = new Associated_Rate__c();
        ARr2.Recurrence__c = 'Hour';
        System.assert(iContract_NA_Master_Controller.isRateChanged(ARr, ARr2), 'Recurrence difference not detected');

        Associated_Rate__c ARrn = new Associated_Rate__c();
        ARrn.Rate_Name__c = 'test';
        Associated_Rate__c ARrn2 = new Associated_Rate__c();
        ARrn2.Rate_Name__c = 'test2';
        System.assert(iContract_NA_Master_Controller.isRateChanged(ARrn, ARrn2), 'Rate Name difference not detected');

        Associated_Rate__c AR = new Associated_Rate__c();
        Associated_Rate__c AR2 = new Associated_Rate__c();
        System.assert(!iContract_NA_Master_Controller.isRateChanged(AR, AR2), 'No difference detected');

        test.stopTest();

        System.debug(LOG_TAG + 'TestIsRateChanged Passed!');
    }

    static testMethod void TestIsLicenseChanged() {
        System.debug(LOG_TAG + 'TestIsLicenseChanged Started!');

        test.startTest();

        LicenseSet__c LSpn = new LicenseSet__c();
        LSpn.Product_Name__c = 'One';
        LicenseSet__c LSpn2 = new LicenseSet__c();
        LSpn2.Product_Name__c = 'Two';
        System.assert(iContract_NA_Master_Controller.isLicenseChanged(LSpn, LSpn2), 'Product Name difference not detected');

        LicenseSet__c LS = new LicenseSet__c();
        LicenseSet__c LS2 = new LicenseSet__c();
        System.assert(!iContract_NA_Master_Controller.isLicenseChanged(LS, LS2), 'No difference detected');

        test.stopTest();

        System.debug(LOG_TAG + 'TestIsLicenseChanged Passed!');
    }
	/**
    * RT-299 : this testmethod is to verify the mergeFields 
    */
    static testMethod void TestMergeField() {
        Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;

        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        insert opptytest;

        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        cntcttest.MailingCountry = 'Canada';
        cntcttest.Language_Preference__c = 'EN';
        insert cntcttest;

        OpportunityContactRole opptyCntcRole = new OpportunityContactRole();
        opptyCntcRole.ContactId = cntcttest.Id;
        opptyCntcRole.OpportunityId = opptytest.Id;
        opptyCntcRole.IsPrimary = true;
        insert opptyCntcRole;

        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        ctrctest.Contract_Status__c = 'Legal Rejected';
        ctrctest.Contracted_Term__c = 12;
        ctrctest.Company_s_Name__c='TestCompany';
        ctrctest.Title__c = 'Test';
        insert ctrctest;

        test.startTest();
        ApexPages.currentPage().getParameters().put('id', ctrctest.Id);
        List<CONMAN_Contract_Verbiage__c> conmanList = new List<CONMAN_Contract_Verbiage__c>();
        List<CONMAN_Contract_Verbiage__c> conmanListResults = new List<CONMAN_Contract_Verbiage__c>();
        conmanList.add(new CONMAN_Contract_Verbiage__c(PGi_Contract__c=ctrctest.Id, Name='test1', Verbiage__c='{!Contract.Contract_Status__c}:Terms'));
        conmanList.add(new CONMAN_Contract_Verbiage__c(PGi_Contract__c=ctrctest.Id, Name='test2', Verbiage__c='{!Contract.Contract}:terms to be signed'));
        conmanList.add(new CONMAN_Contract_Verbiage__c(PGi_Contract__c=ctrctest.Id, Name='test3', Verbiage__c='{!Contract.Contracted_Term__c}:terms to test'));
        conmanList.add(new CONMAN_Contract_Verbiage__c(PGi_Contract__c=ctrctest.Id, Name='test4', Verbiage__c='{!Contract.Title__c}:terms to test'));
        INSERT conmanList;
        iContract_NA_Master_Controller icontractObj = new iContract_NA_Master_Controller();
        conmanListResults = icontractObj.handleMergeFields(conmanList);
        System.assertEquals(conmanListResults[0].Verbiage__c, 'Legal Rejected:Terms');
        System.assertEquals(conmanListResults[1].Verbiage__c, '{!Contract.Contract}:terms to be signed');
        System.assertEquals(conmanListResults[2].Verbiage__c, '12:terms to test');
        System.assertEquals(conmanListResults[3].Verbiage__c, 'Test:terms to test');
        test.stopTest();
    }
    static testMethod void TestDialogBox(){
         Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;

        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        insert opptytest;

        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        cntcttest.MailingCountry = 'Canada';
        cntcttest.Language_Preference__c = 'EN';
        insert cntcttest;

        OpportunityContactRole opptyCntcRole = new OpportunityContactRole();
        opptyCntcRole.ContactId = cntcttest.Id;
        opptyCntcRole.OpportunityId = opptytest.Id;
        opptyCntcRole.IsPrimary = true;
        insert opptyCntcRole;

        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        ctrctest.Contract_Status__c = 'Legal Rejected';
        ctrctest.Contracted_Term__c = 12;
        ctrctest.Title__c = 'Test';
        insert ctrctest;
        test.startTest();
        ApexPages.currentPage().getParameters().put('id', ctrctest.Id);
        iContract_NA_Master_Controller icontractObj = new iContract_NA_Master_Controller();
        icontractObj.downloadWordEvent();
        ctrctest = [SELECT Id, Word_File_In_Use__c, Contract_Status__c FROM CONMAN_Contract__c WHERE Id = :ctrctest.Id];
        System.assertEquals(True, ctrctest.Word_File_In_Use__c);
        
        icontractObj.resetWordEvent();
        ctrctest = [SELECT Id, Word_File_In_Use__c FROM CONMAN_Contract__c WHERE Id = :ctrctest.Id];
        System.assertEquals(False, ctrctest.Word_File_In_Use__c);
       }
    static testMethod void TestForAPACUser() {
        System.debug(LOG_TAG + 'TestDeleteLicenseSet Started!');

        Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;

        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        insert opptytest;

        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        insert cntcttest;
    	cntcttest.MailingCountry='India';
        Update cntcttest;

        OpportunityContactRole opptyCntcRole = new OpportunityContactRole();
        opptyCntcRole.ContactId = cntcttest.Id;
        opptyCntcRole.OpportunityId = opptytest.Id;
        opptyCntcRole.IsPrimary = true;
        insert opptyCntcRole;
		PGIServicesInformation__c av_S = new PGIServicesInformation__c(Name='Contract Terms', Active__c=true,Language__c='en_us', Order__c=1, Section__c='Signature', Agreement_Type__c='Subscription License Order;Service Agreement',Region__c='APAC',Intl_Order_Type__c='Long Form;Short Form', Content_RTF__c='Contract Terms', Unique_ID__c='3');
        insert av_S;
        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        insert ctrctest;
    	ctrctest.Contract_Type__c='Service Agreement';
    	ctrctest.Intl_Order_Type__c='Long Form';
    	Update ctrctest;
        LicenseSet__c licSetBS = new LicenseSet__c(name='Billing Services', PGi_Contract__c = ctrctest.id);
        insert licSetBS;
		CONMAN_Contract_Verbiage__c cv = new CONMAN_Contract_Verbiage__c(PGi_Contract__c=ctrctest.Id, Name='test1',Contract_General_Content__c=av_S.Id);
    	Insert cv;
        LicenseSet__c licSetNC = new LicenseSet__c(name='Non-contiguous US Call Charges', PGi_Contract__c = ctrctest.id);
        insert licSetNC;

        test.startTest();

        ApexPages.currentPage().getParameters().put('id', ctrctest.Id);
        iContract_NA_Master_Controller cd = new iContract_NA_Master_Controller();

        System.assertEquals(2, cd.licenseData.size(), 'LicenseSet not in licenseData');

        cd.actOnLicenseSetId = licSetNC.Id;
        cd.deleteLicenseSet();
        cd.save();

        System.assertEquals(2, cd.licenseData.size(), 'LicenseSet not in licenseData');
        System.assertEquals(true, [SELECT Disabled__c FROM LicenseSet__c WHERE Id = :licSetNC.Id].Disabled__c,
                           'LicenseSet not disabled');

        test.stopTest();

        System.debug(LOG_TAG + 'TestDeleteLicenseSet Passed!');
    }
    static testMethod void TestForEMEAUser() {
        System.debug(LOG_TAG + 'TestDeleteLicenseSet Started!');

        Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;

        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        insert opptytest;

        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        insert cntcttest;
    	cntcttest.MailingCountry='Spain';
        Update cntcttest;

        OpportunityContactRole opptyCntcRole = new OpportunityContactRole();
        opptyCntcRole.ContactId = cntcttest.Id;
        opptyCntcRole.OpportunityId = opptytest.Id;
        opptyCntcRole.IsPrimary = true;
        insert opptyCntcRole;
		PGIServicesInformation__c av_S = new PGIServicesInformation__c(Name='Contract Terms', Active__c=true,Language__c='en_us', Order__c=1, Section__c='Intro', Agreement_Type__c='Subscription License Order;Service Agreement',Region__c='APAC',Intl_Order_Type__c='Long Form;Short Form', Content_RTF__c='Contract Terms', Unique_ID__c='3');
        insert av_S;
        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        insert ctrctest;
    	ctrctest.Contract_Type__c='Service Agreement';
        // ctrctest.Intl_Order_Type__c='Long Form';
        ctrctest.Intl_Order_Type__c='Short Form';
    	Update ctrctest;
        LicenseSet__c licSetBS = new LicenseSet__c(name='Billing Services', PGi_Contract__c = ctrctest.id);
        insert licSetBS;
		CONMAN_Contract_Verbiage__c cv = new CONMAN_Contract_Verbiage__c(PGi_Contract__c=ctrctest.Id, Name='test1',Contract_General_Content__c=av_S.Id);
    	Insert cv;
        LicenseSet__c licSetNC = new LicenseSet__c(name='Non-contiguous US Call Charges', PGi_Contract__c = ctrctest.id);
        insert licSetNC;
        test.startTest();

        ApexPages.currentPage().getParameters().put('id', ctrctest.Id);
        iContract_NA_Master_Controller cd = new iContract_NA_Master_Controller();
        System.assertEquals(2, cd.licenseData.size(), 'LicenseSet not in licenseData');

        cd.actOnLicenseSetId = licSetNC.Id;
        cd.deleteLicenseSet();
        cd.save();

        System.assertEquals(2, cd.licenseData.size(), 'LicenseSet not in licenseData');
        System.assertEquals(true, [SELECT Disabled__c FROM LicenseSet__c WHERE Id = :licSetNC.Id].Disabled__c,
                           'LicenseSet not disabled');

        test.stopTest();
    }
    static testMethod void TestForMuliLocationSites() {
        Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;

        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        insert opptytest;

        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        insert cntcttest;
    	cntcttest.MailingCountry='Spain';
        Update cntcttest;

        OpportunityContactRole opptyCntcRole = new OpportunityContactRole();
        opptyCntcRole.ContactId = cntcttest.Id;
        opptyCntcRole.OpportunityId = opptytest.Id;
        opptyCntcRole.IsPrimary = true;
        insert opptyCntcRole;
		PGIServicesInformation__c av_S = new PGIServicesInformation__c(Name='Contract Terms', Active__c=true,Language__c='en_us', Order__c=1, Section__c='Intro', Agreement_Type__c='Subscription License Order;Service Agreement',Region__c='APAC',Intl_Order_Type__c='Long Form;Short Form', Content_RTF__c='Contract Terms', Unique_ID__c='3');
        insert av_S;
        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        insert ctrctest;
    	ctrctest.Contract_Type__c='TPx Service Agreement';
        // ctrctest.Intl_Order_Type__c='Long Form';
        //ctrctest.Intl_Order_Type__c='Short Form';
        Update ctrctest;
        CPQ_Location_Sites__c locationSite = new CPQ_Location_Sites__c(PGi_Contract__c=ctrctest.Id, Site_Location_Name__c = 'USA', Site_Location_Address__c = 'test123', Site_Location_Product_Notes__c = 'test Product Notes');
        Insert locationSite;
        // LicenseSet__c licSetBS = new LicenseSet__c(name='Billing Services', PGi_Contract__c = ctrctest.id);
        // insert licSetBS;
		// CONMAN_Contract_Verbiage__c cv = new CONMAN_Contract_Verbiage__c(PGi_Contract__c=ctrctest.Id, Name='test1',Contract_General_Content__c=av_S.Id);
    	// Insert cv;
        // LicenseSet__c licSetNC = new LicenseSet__c(name='Non-contiguous US Call Charges', PGi_Contract__c = ctrctest.id);
        // insert licSetNC;
        test.startTest();

        // ApexPages.currentPage().getParameters().put('id', ctrctest.Id);
        List<CPQ_Location_Sites__c> locations = iContract_NA_Master_Controller.getSiteLocations(ctrctest.Id, 1);
        iContract_NA_Master_Controller cd = new iContract_NA_Master_Controller();
        System.assertEquals(1, locations.size());
        test.stopTest();
    }
}