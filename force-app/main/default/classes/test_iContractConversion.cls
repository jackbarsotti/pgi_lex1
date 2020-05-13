@isTest
public class test_iContractConversion {
     @testSetup static void setup() {
       PGITestUtilities.disableSalesWings();
    }
	
    private static String LOG_TAG = 'iContractConversion:';
    private static final String REQUEST_URI = '/services/apexrest/iContractConversion/';
    
    static String request(String parameters, String convertType) {
        RestRequest req     = new RestRequest();
        RestResponse res    = new RestResponse();
        req.requestURI      = REQUEST_URI + parameters;
        req.httpMethod      = 'GET';

        RestContext.request = req;
        RestContext.response= res;
        return iContractConversion.convert(convertType);
    }

    static List<PGIServicesInformation__c> createTerms() {
        List<PGIServicesInformation__c> terms = new List<PGIServicesInformation__c>();
        terms.add(new PGIServicesInformation__c(Name='Parties, Underlying Agreement & Amendment Effective Date',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Amendment',
            Section__c='Intro',
            Region__c='US', Unique_ID__c='100'));
        terms.add(new PGIServicesInformation__c(Name='Parties, Underlying Agreement & Amendment Effective Date CAN',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Amendment',
            Section__c='Intro',
            Region__c='CAN', Unique_ID__c='200'));
        terms.add(new PGIServicesInformation__c(Name='Recitals',
            Order__c=2,Language__c = 'en_US',
            Agreement_Type__c='Amendment',
            Section__c='Pre-Intro Table',
            Region__c='US;CAN', Unique_ID__c='300'));
        terms.add(new PGIServicesInformation__c(Name='Acknowledgement Amendment',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Amendment',
            Section__c='Intro',
            Region__c='US;CAN', Unique_ID__c='400'));
        terms.add(new PGIServicesInformation__c(Name='Signing Area Amendment',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Amendment',
            Section__c='Signature',
            Region__c='US;CAN', Unique_ID__c='500'));
        terms.add(new PGIServicesInformation__c(Name='Services & Pricing Schedule Billing Footnotes SG',
            Order__c=100,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order;Subscription License Agreement;Amendment;Rate Modification Amendment',
            Section__c='Intro',
            Region__c='US', Unique_ID__c='600'));
        terms.add(new PGIServicesInformation__c(Name='Services & Pricing Schedule Billing Footnotes CAN',
            Order__c=100,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order;Subscription License Agreement;Amendment;Rate Modification Amendment',
            Section__c='Intro',
            Region__c='CAN', Unique_ID__c='700'));
        terms.add(new PGIServicesInformation__c(Name='Rate Modification Agreement US',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Rate Modification Amendment',
            Section__c='Intro',
            Region__c='US;CAN', Unique_ID__c='800'));
        terms.add(new PGIServicesInformation__c(Name='Services, Rates and Terms iContract SLO',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order',
            Section__c='Intro',
            Region__c='US', Unique_ID__c='900'));
        terms.add(new PGIServicesInformation__c(Name='Services, Rates and Terms iContract CAN SLO',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order',
            Section__c='Intro',
            Region__c='CAN', Unique_ID__c='110'));
        terms.add(new PGIServicesInformation__c(Name='Term SG',
            Order__c=2,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order;Subscription License Agreement',
            Section__c='Pre-Intro Table',
            Region__c='US;CAN', Unique_ID__c='120'));
        terms.add(new PGIServicesInformation__c(Name='Acknowledgement',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order;Subscription License Agreement',
            Section__c='Intro',
            Region__c='US;CAN', Unique_ID__c='130'));
        terms.add(new PGIServicesInformation__c(Name='Signing Area',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order;Subscription License Agreement',
            Section__c='Signature',
            Region__c='US;CAN', Unique_ID__c='140'));
        terms.add(new PGIServicesInformation__c(Name='Services, Rates and Terms iContract SLA',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Agreement',
            Section__c='Intro',
            Region__c='US', Unique_ID__c='150'));
        terms.add(new PGIServicesInformation__c(Name='Services, Rates and Terms iContract CAN SLA',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Agreement',
            Section__c='Intro',
            Region__c='CAN', Unique_ID__c='160'));
        return terms;
    }

    static testMethod void test_emptyCartRequest_invalid() {
        System.debug(LOG_TAG + 'test_emptyCartRequest_invalid Started!');
        test.startTest();
        system.assertNotEquals('"success"', request('badid', 'badconvert'),
                              'Success message for an invalid ID');
        test.stopTest();
        System.debug(LOG_TAG + 'test_emptyCartRequest_invalid Finished!');
    }

    static testMethod void test_emptyCartRequest_empty() {
        System.debug(LOG_TAG + 'test_emptyCartRequest_empty Initializing!');
        Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;
        
        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        opptytest.AccountId = accttest.Id;
        insert opptytest;
        
        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        insert cntcttest;
        
        insert new OpportunityContactRole(OpportunityId=opptytest.Id, ContactId=cntcttest.Id, IsPrimary=true);
        
        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        ctrctest.Contract_Type__c = 'Quote';
        insert ctrctest;
        
        List<PGIServicesInformation__c> terms = createTerms();
        insert terms;
        
        System.debug(LOG_TAG + 'test_emptyCartRequest_empty Started!');
        test.startTest();
        
        system.assertEquals(iContract.SUCCESS, request(ctrctest.id, 'Subscription License Order'),
                              'No success message for a valid ID that\'s already empty');
        CONMAN_Contract__c foundContract = [SELECT Contract_Type__c from CONMAN_Contract__c where id= :ctrctest.id];
        
        system.assertEquals('Subscription License Order', foundContract.Contract_Type__c, 'Contract Type has not been updated');
        List<CONMAN_Contract_Verbiage__c> verbiageList = [SELECT Id, Pricing_Team_Changes_Allowed__c FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :ctrctest.id];
        system.assertEquals(5, verbiageList.size(),
                              'ContractVerbiage not created');
        for (CONMAN_Contract_Verbiage__c verbiage : verbiageList)
            system.assertEquals(false, verbiage.Pricing_Team_Changes_Allowed__c,
                              'ContractVerbiage editable by Pricing');
        
        test.stopTest();
        System.debug(LOG_TAG + 'test_emptyCartRequest_empty Finished!');
    }

    static testMethod void test_emptyCartRequest() {
        System.debug(LOG_TAG + 'test_emptyCartRequest Initializing!');
        Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;
        
        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        opptytest.AccountId = accttest.Id;
        insert opptytest;
        
        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        insert cntcttest;
        
        insert new OpportunityContactRole(OpportunityId=opptytest.Id, ContactId=cntcttest.Id, IsPrimary=true);
        
        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        ctrctest.Contract_Type__c = 'Subscription License Order';
        insert ctrctest;
        
        LicenseSet__c licSet = new LicenseSet__c(PGi_Contract__c = ctrctest.id);
        insert licSet;
        
        Associated_Rate__c assoRate = new Associated_Rate__c(LicenseSet__c = licSet.id);
        insert assoRate;
        
        CONMAN_Contract_Verbiage__c verb = new CONMAN_Contract_Verbiage__c(Name='Custom Language from Legal', PGi_Contract__c = ctrctest.id);
        insert verb;
        
        List<PGIServicesInformation__c> terms = createTerms();
        insert terms;
        
        system.assertEquals(1, [SELECT Id FROM LicenseSet__c WHERE PGi_Contract__c = :ctrctest.id].size(),
                              'LicenseSet not attached to Contract during setup');
        system.assertEquals(1, [SELECT Id FROM Associated_Rate__c WHERE LicenseSet__c = :licSet.id].size(),
                              'AssociatedRate not attached to LicenseSet during setup');
        system.assertEquals(1, [SELECT Id FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :ctrctest.id].size(),
                              'ContractVerbiage not attached to Contract during setup');
        
        System.debug(LOG_TAG + 'test_emptyCartRequest Started!');
        test.startTest();
        
        system.assertEquals(iContract.SUCCESS, request(ctrctest.id, 'Subscription License Order'),
                              'No success message for a valid ID with records');
        
        CONMAN_Contract__c foundContract = [SELECT Contract_Type__c from CONMAN_Contract__c where id= :ctrctest.id];
        
        system.assertEquals('Subscription License Order', foundContract.Contract_Type__c, 'Contract Type has not been updated');
        
        system.assertEquals(1, [SELECT Id FROM LicenseSet__c WHERE PGi_Contract__c = :ctrctest.id].size(),
                              'LicenseSet not deleted');
        system.assertEquals(1, [SELECT Id FROM Associated_Rate__c WHERE LicenseSet__c = :licSet.id].size(),
                              'AssociatedRate not deleted');
        system.assertEquals(1, [SELECT Id FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :ctrctest.id].size(),
                              'ContractVerbiage not added (no conversion)');
        
        test.stopTest();
        System.debug(LOG_TAG + 'test_emptyCartRequest Finished!');
    }

    static testMethod void test_emptyCartRequestSLA() {
        System.debug(LOG_TAG + 'test_emptyCartRequestSLA Initializing!');
        Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;
        
        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        opptytest.AccountId = accttest.Id;
        insert opptytest;
        
        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        insert cntcttest;
        
        insert new OpportunityContactRole(OpportunityId=opptytest.Id, ContactId=cntcttest.Id, IsPrimary=true);
        
        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        ctrctest.Contract_Type__c = 'Subscription License Agreement';
        insert ctrctest;
        
        LicenseSet__c licSet = new LicenseSet__c(PGi_Contract__c = ctrctest.id);
        insert licSet;
        
        Associated_Rate__c assoRate = new Associated_Rate__c(LicenseSet__c = licSet.id);
        insert assoRate;
        
        CONMAN_Contract_Verbiage__c verb = new CONMAN_Contract_Verbiage__c(Name='Custom Pricing Langauge', PGi_Contract__c = ctrctest.id);
        insert verb;
        
        List<PGIServicesInformation__c> terms = createTerms();
        insert terms;
        
        system.assertEquals(1, [SELECT Id FROM LicenseSet__c WHERE PGi_Contract__c = :ctrctest.id].size(),
                              'LicenseSet not attached to Contract during setup');
        system.assertEquals(1, [SELECT Id FROM Associated_Rate__c WHERE LicenseSet__c = :licSet.id].size(),
                              'AssociatedRate not attached to LicenseSet during setup');
        system.assertEquals(1, [SELECT Id FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :ctrctest.id].size(),
                              'ContractVerbiage not attached to Contract during setup');
        
        System.debug(LOG_TAG + 'test_emptyCartRequestSLA Started!');
        test.startTest();
        
        system.assertEquals(iContract.SUCCESS, request(ctrctest.id, 'Subscription License Agreement'),
                              'No success message for a valid ID with records');

        CONMAN_Contract__c foundContract = [SELECT Contract_Type__c from CONMAN_Contract__c where id= :ctrctest.id];
        
        system.assertEquals('Subscription License Agreement', foundContract.Contract_Type__c, 'Contract Type has not been updated');
        
        system.assertEquals(1, [SELECT Id FROM LicenseSet__c WHERE PGi_Contract__c = :ctrctest.id].size(),
                              'LicenseSet not deleted');
        system.assertEquals(1, [SELECT Id FROM Associated_Rate__c WHERE LicenseSet__c = :licSet.id].size(),
                              'AssociatedRate not deleted');
        system.assertEquals(1, [SELECT Id FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :ctrctest.id].size(),
                              'ContractVerbiage not deleted (no conversion)');
        
        test.stopTest();
        System.debug(LOG_TAG + 'test_emptyCartRequestSLA Finished!');
    }

    static testMethod void test_emptyCartRequestExisting() {
        System.debug(LOG_TAG + 'test_emptyCartRequestExisting Initializing!');
        Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;
        
        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        opptytest.AccountId = accttest.Id;
        insert opptytest;
        
        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        insert cntcttest;
        
        insert new OpportunityContactRole(OpportunityId=opptytest.Id, ContactId=cntcttest.Id, IsPrimary=true);
        
        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        ctrctest.Contract_Type__c = 'Amendment';
        insert ctrctest;
        
        LicenseSet__c licSet = new LicenseSet__c(PGi_Contract__c = ctrctest.id);
        insert licSet;
        
        LicenseSet__c licS = new LicenseSet__c(PGi_Contract__c = ctrctest.id);
        insert licS;
                
        Associated_Rate__c assoRate = new Associated_Rate__c(LicenseSet__c = licSet.id);
        insert assoRate;
        
        List<PGIServicesInformation__c> terms = createTerms();
        insert terms;
        
        CONMAN_Contract_Verbiage__c verb = new CONMAN_Contract_Verbiage__c(Name=terms.get(3).Name, Contract_General_Content__c = terms.get(3).Id, PGi_Contract__c = ctrctest.id);
        insert verb;
        
        system.assertEquals(2, [SELECT Id FROM LicenseSet__c WHERE PGi_Contract__c = :ctrctest.id].size(),
                              'LicenseSet not attached to Contract during setup');
        system.assertEquals(1, [SELECT Id FROM Associated_Rate__c WHERE LicenseSet__c = :licSet.id].size(),
                              'AssociatedRate not attached to LicenseSet during setup');
        system.assertEquals(1, [SELECT Id FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :ctrctest.id].size(),
                              'ContractVerbiage not attached to Contract during setup');
        
        System.debug(LOG_TAG + 'test_emptyCartRequestExisting Started!');
        test.startTest();
        
        system.assertEquals(iContract.SUCCESS, request(ctrctest.id, 'Amendment'),
                              'No success message for a valid ID with records');
        
        CONMAN_Contract__c foundContract = [SELECT Contract_Type__c from CONMAN_Contract__c where id= :ctrctest.id];
       
        system.assertEquals('Amendment', foundContract.Contract_Type__c, 'Contract Type has not been updated');
        
        system.assertEquals(2, [SELECT Id FROM LicenseSet__c WHERE PGi_Contract__c = :ctrctest.id].size(),
                              'LicenseSet not deleted');
        system.assertEquals(1, [SELECT Id FROM Associated_Rate__c WHERE LicenseSet__c = :licSet.id].size(),
                              'AssociatedRate not deleted');
        system.assertEquals(1, [SELECT Id FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :ctrctest.id].size(),
                              'ContractVerbiage not deleted (no conversion)');
        
        test.stopTest();
        System.debug(LOG_TAG + 'test_emptyCartRequestExisting Finished!');
    }

    static testMethod void test_emptyCartRequestRCA() {
        System.debug(LOG_TAG + 'test_emptyCartRequestRCA Initializing!');
        Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;
        
        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        opptytest.AccountId = accttest.Id;
        insert opptytest;
        
        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        insert cntcttest;
        
        insert new OpportunityContactRole(OpportunityId=opptytest.Id, ContactId=cntcttest.Id, IsPrimary=true);
        
        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        ctrctest.Contract_Type__c = 'Amendment';
        insert ctrctest;
        
        LicenseSet__c licSet = new LicenseSet__c(PGi_Contract__c = ctrctest.id);
        insert licSet;
        
        LicenseSet__c licS = new LicenseSet__c(PGi_Contract__c = ctrctest.id);
        insert licS;
                
        Associated_Rate__c assoRate = new Associated_Rate__c(LicenseSet__c = licSet.id);
        insert assoRate;
        
        List<PGIServicesInformation__c> terms = createTerms();
        insert terms;
        
        CONMAN_Contract_Verbiage__c verb = new CONMAN_Contract_Verbiage__c(Name=terms.get(3).Name, Contract_General_Content__c = terms.get(3).Id, PGi_Contract__c = ctrctest.id);
        insert verb;
        
        system.assertEquals(2, [SELECT Id FROM LicenseSet__c WHERE PGi_Contract__c = :ctrctest.id].size(),
                              'LicenseSet not attached to Contract during setup');
        system.assertEquals(1, [SELECT Id FROM Associated_Rate__c WHERE LicenseSet__c = :licSet.id].size(),
                              'AssociatedRate not attached to LicenseSet during setup');
        system.assertEquals(1, [SELECT Id FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :ctrctest.id].size(),
                              'ContractVerbiage not attached to Contract during setup');
        
        System.debug(LOG_TAG + 'test_emptyCartRequestRCA Started!');
        test.startTest();
        
        system.assertEquals(iContract.SUCCESS, request(ctrctest.id, 'Rate Modification Amendment'),
                              'No success message for a valid ID with records');
        
        CONMAN_Contract__c foundContract = [SELECT Contract_Type__c from CONMAN_Contract__c where id= :ctrctest.id];
       
        system.assertEquals('Rate Modification Amendment', foundContract.Contract_Type__c, 'Contract Type has not been updated');
        
        system.assertEquals(2, [SELECT Id FROM LicenseSet__c WHERE PGi_Contract__c = :ctrctest.id].size(),
                              'LicenseSet deleted');
        system.assertEquals(1, [SELECT Id FROM Associated_Rate__c WHERE LicenseSet__c = :licSet.id].size(),
                              'AssociatedRate deleted');
        // system.assertEquals(3, [SELECT Id FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :ctrctest.id].size(),
        //                       'ContractVerbiage not deleted and re-created');
        
        test.stopTest();
        System.debug(LOG_TAG + 'test_emptyCartRequestRCA Finished!');
    }
}