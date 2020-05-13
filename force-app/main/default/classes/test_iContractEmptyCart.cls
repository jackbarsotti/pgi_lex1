@isTest
public class test_iContractEmptyCart {
    @testSetup static void setup() {
       PGITestUtilities.disableSalesWings();
    }
    private static String LOG_TAG = 'iContractEmptyCart:';
    private static final String REQUEST_URI = '/services/apexrest/iContractEmptyCart/';
    
    static String request(String parameters) {
        RestRequest req 	= new RestRequest();
        RestResponse res 	= new RestResponse();
        req.requestURI 		= REQUEST_URI + parameters;
        req.httpMethod 		= 'GET';

        RestContext.request = req;
        RestContext.response= res;
        return iContractEmptyCart.emptyCartRequest();
    }

    static testMethod void test_emptyCartRequest_invalid() {
        System.debug(LOG_TAG + 'test_emptyCartRequest_invalid Started!');
        test.startTest();
        system.assertNotEquals('"success"', request('badid'),
                              'Success message for an invalid ID');
        test.stopTest();
        System.debug(LOG_TAG + 'test_emptyCartRequest_invalid Finished!');
    }

    static testMethod void test_emptyCartRequest_empty() {
        System.debug(LOG_TAG + 'test_emptyCartRequest_empty Initializing!');
        Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;
        
        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        insert opptytest;
        
        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        insert cntcttest;
        
        insert new OpportunityContactRole(OpportunityId=opptytest.Id, ContactId=cntcttest.Id, IsPrimary=true);
        
        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        ctrctest.Contract_Type__c = 'Subscription License Order';
        insert ctrctest;
        
        System.debug(LOG_TAG + 'test_emptyCartRequest_empty Started!');
        test.startTest();
        
        system.assertEquals(iContract.SUCCESS, request(ctrctest.id),
                              'No success message for a valid ID that\'s already empty');
        system.assertEquals(0, [SELECT Id FROM LicenseSet__c WHERE PGi_Contract__c = :ctrctest.id].size(),
                              'LicenseSets not added');
        
        test.stopTest();
        System.debug(LOG_TAG + 'test_emptyCartRequest_empty Finished!');
    }

    static testMethod void test_emptyCartRequest() {
        System.debug(LOG_TAG + 'test_emptyCartRequest Initializing!');
        Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;
        
        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
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
        
        CONMAN_Contract_Verbiage__c verb = new CONMAN_Contract_Verbiage__c(PGi_Contract__c = ctrctest.id);
        insert verb;
        
        System.debug(LOG_TAG + 'test_emptyCartRequest Started!');
        test.startTest();
        
        system.assertEquals(1, [SELECT Id FROM LicenseSet__c WHERE PGi_Contract__c = :ctrctest.id].size(),
                              'LicenseSet not attached to Contract during setup');
        system.assertEquals(1, [SELECT Id FROM Associated_Rate__c WHERE LicenseSet__c = :licSet.id].size(),
                              'AssociatedRate not attached to LicenseSet during setup');
        system.assertEquals(1, [SELECT Id FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :ctrctest.id].size(),
                              'ContractVerbiage not attached to Contract during setup');
        
        system.assertEquals(iContract.SUCCESS, request(ctrctest.id),
                              'No success message for a valid ID with records');
        
        system.assertEquals(0, [SELECT Id FROM LicenseSet__c WHERE PGi_Contract__c = :ctrctest.id].size(),
                              'LicenseSet not deleted');
        system.assertEquals(0, [SELECT Id FROM Associated_Rate__c WHERE LicenseSet__c = :licSet.id].size(),
                              'AssociatedRate not deleted');
        system.assertEquals(1, [SELECT Id FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :ctrctest.id].size(),
                              'ContractVerbiage deleted');
        
        test.stopTest();
        System.debug(LOG_TAG + 'test_emptyCartRequest Finished!');
    }
}