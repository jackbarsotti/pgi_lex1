@isTest
public class test_iContractStartLegalApproval {
     @testSetup static void setup() {
       PGITestUtilities.disableSalesWings();
    }
	
    private static String LOG_TAG = 'iContractStartLegalApproval:';
    private static final String REQUEST_URI = '/services/apexrest/iContractStartApproval/';
    
    static String request(String parameters) {
        RestRequest req   = new RestRequest();
        RestResponse res   = new RestResponse();
        req.requestURI     = REQUEST_URI + parameters;
        req.httpMethod     = 'GET';

        RestContext.request = req;
        RestContext.response= res;
        return iContractStartLegalApproval.ApprovalRequest();
    }

    static testMethod void test_NoApprovalRequest() {
        System.debug(LOG_TAG + 'test_NoApprovalRequest Initializing!');
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        Account accttest = PGITestUtilities.getAccountDetails();
        insert accttest;
        
        Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
        insert opptytest;
        
        Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
        insert cntcttest;
        
        ConMan_Contract__c ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
        ctrctest.Contract_Status__c = 'New';
        insert ctrctest;
        
        System.debug(LOG_TAG + 'test_NoApprovalRequest Started!');
        test.startTest();
        
        system.assertEquals(iContract.UNNECESSARY, request(ctrctest.id));
        CONMAN_Contract__c foundContract = [SELECT CreatedDate, Contract_Status__c from CONMAN_Contract__c where id= :ctrctest.id];
        system.assertEquals(ctrctest.id, foundContract.Id);
        
		system.assertEquals('New',  foundContract.Contract_Status__c, 'Contract Status not changed');

        try {
            ProcessInstance pi = [SELECT TargetObjectId, CreatedDate FROM ProcessInstance WHERE TargetObjectId = :ctrctest.id];
        	System.assert(false, 'Approval Process found on Contract!');
        } catch (Exception e) {
        	System.assert(true, 'No Approval Process on Contract');
        }
        
        test.stopTest();
        System.debug(LOG_TAG + 'test_NoApprovalRequest Finished!');
    }

    static testMethod void test_RVPApprovalRequest() {
        System.debug(LOG_TAG + 'test_RVPApprovalRequest Initializing!');
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User m = new User(Alias = 'standtm', Email='standardusermanager@pgi.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, EmployeeNumber='12345', 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardusermanager@pgi.com');
        insert m;
        User u = new User(Alias = 'standt', Email='standarduser@pgi.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, RVP__c = m.Id, EmployeeNumber='12345',
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@pgi.com');
        insert u;
        
        ConMan_Contract__c ctrctest;
        System.runAs(u) {
            Account accttest = PGITestUtilities.getAccountDetails();
            insert accttest;
            
            Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
            insert opptytest;
            
            Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
            insert cntcttest;
            
            ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
            ctrctest.OwnerId = u.Id;
            ctrctest.Owners_RVP__c = m.Id;
            ctrctest.Required_Approval_Pricing_RVP__c = true;
            ctrctest.Required_Approval_Pricing_SVP__c = false;
            insert ctrctest;
        
        	system.assertEquals(iContract.SUCCESS, request(ctrctest.id));
        }
        
        System.debug(LOG_TAG + 'test_RVPApprovalRequest Started!');
        test.startTest();
        
        CONMAN_Contract__c foundContract = [SELECT CreatedDate, Contract_Status__c from CONMAN_Contract__c where id= :ctrctest.id];
        system.assertEquals(ctrctest.id, foundContract.Id);
        
		system.assertEquals('Pending Approval',  foundContract.Contract_Status__c, 'Contract Status not changed');

        ProcessInstance pi = [SELECT TargetObjectId, CreatedDate FROM ProcessInstance WHERE TargetObjectId = :ctrctest.id];
        System.assertEquals(foundContract.CreatedDate.Date(), pi.CreatedDate.Date(), 'No Approval Process on Contract');
        
        test.stopTest();
        System.debug(LOG_TAG + 'test_RVPApprovalRequest Finished!');
    }

    static testMethod void test_SVPApprovalRequest() {
        System.debug(LOG_TAG + 'test_SVPApprovalRequest Initializing!');
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User m = new User(Alias = 'standtm', Email='standardusermanager@pgi.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, EmployeeNumber='12345',
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardusermanager@pgi.com');
        insert m;
        User u = new User(Alias = 'standt', Email='standarduser@pgi.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, SVP__c = m.Id, EmployeeNumber='12345',
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@pgi.com');
        insert u;
        
        ConMan_Contract__c ctrctest;
        System.runAs(u) {
            Account accttest = PGITestUtilities.getAccountDetails();
            insert accttest;
            
            Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
            insert opptytest;
            
            Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
            insert cntcttest;
            
            ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
            ctrctest.OwnerId = u.Id;
            ctrctest.Owners_SVP__c = m.Id;
            ctrctest.Required_Approval_Pricing_SVP__c = true;
             ctrctest.Required_Approval_Pricing_RVP__c = false;
            insert ctrctest;
                
        	system.assertEquals(iContract.SUCCESS, request(ctrctest.id));
        }
        
        System.debug(LOG_TAG + 'test_SVPApprovalRequest Started!');
        test.startTest();
        
        CONMAN_Contract__c foundContract = [SELECT CreatedDate, Contract_Status__c from CONMAN_Contract__c where id= :ctrctest.id];
        system.assertEquals(ctrctest.id, foundContract.Id);
        
		system.assertEquals('Pending Approval',  foundContract.Contract_Status__c, 'Contract Status not changed');

        ProcessInstance pi = [SELECT TargetObjectId, CreatedDate FROM ProcessInstance WHERE TargetObjectId = :ctrctest.id];
        System.assertEquals(foundContract.CreatedDate.Date(), pi.CreatedDate.Date(), 'No Approval Process on Contract');
        
        test.stopTest();
        System.debug(LOG_TAG + 'test_SVPApprovalRequest Finished!');
    }

    static testMethod void test_NoRVPApprovalRequest() {
        System.debug(LOG_TAG + 'test_NoRVPApprovalRequest Initializing!');
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@pgi.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, EmployeeNumber='12345',
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@pgi.com');
        insert u;
        
        ConMan_Contract__c ctrctest;
        System.runAs(u) {
            Account accttest = PGITestUtilities.getAccountDetails();
            insert accttest;
            
            Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
            insert opptytest;
            
            Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
            insert cntcttest;
            
            ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
            ctrctest.Required_Approval_Pricing_RVP__c = true;
            ctrctest.Contract_Status__c = 'New';
            ctrctest.OwnerId = u.Id;
            insert ctrctest;
            
        	system.assertEquals(iContract.SUCCESS, request(ctrctest.id));
        }
        
        System.debug(LOG_TAG + 'test_NoRVPApprovalRequest Started!');
        test.startTest();
        
        CONMAN_Contract__c foundContract = [SELECT CreatedDate, Contract_Status__c from CONMAN_Contract__c where id= :ctrctest.id];
        system.assertEquals(ctrctest.id, foundContract.Id);
        
		system.assertEquals('Rejected',  foundContract.Contract_Status__c, 'Contract Status not changed');

        try {
            ProcessInstance pi = [SELECT TargetObjectId, CreatedDate FROM ProcessInstance WHERE TargetObjectId = :ctrctest.id];
        	System.assert(true, 'Approval Process not found on Contract!');
        } catch (Exception e) {
        	System.assert(false, 'Approval Process found on Contract');
        }
        
        test.stopTest();
        System.debug(LOG_TAG + 'test_NoRVPApprovalRequest Finished!');
    }

    static testMethod void test_LegalApprovalRequest() {
        System.debug(LOG_TAG + 'test_LegalApprovalRequest Initializing!');
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User m = new User(Alias = 'standtm', Email='standardusermanager@pgi.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, EmployeeNumber='12345',
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardusermanager@pgi.com');
        User u = new User(Alias = 'standt', Email='standarduser@pgi.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, EmployeeNumber='12345',
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@pgi.com',
                          Manager=m);
        insert m;
        insert u;
        
        ConMan_Contract__c ctrctest;
        System.runAs(u) {
            Account accttest = PGITestUtilities.getAccountDetails();
            insert accttest;
            
            Opportunity opptytest = PGITestUtilities.getOpportunityDetails();
            insert opptytest;
            
            Contact cntcttest = PGITestUtilities.getContactDetails(accttest.id);
            insert cntcttest;
            
            ctrctest = PGITestUtilities.getConManContractDetails(accttest.id, opptytest.id);
            ctrctest.Required_Approval_Legal__c = true;
            ctrctest.OwnerId = u.Id;
            insert ctrctest;
            
        	system.assertEquals(iContract.SUCCESS, request(ctrctest.id));
        }
        
        System.debug(LOG_TAG + 'test_LegalApprovalRequest Started!');
        test.startTest();
        
        CONMAN_Contract__c foundContract = [SELECT CreatedDate, Contract_Status__c from CONMAN_Contract__c where id= :ctrctest.id];
        system.assertEquals(ctrctest.id, foundContract.Id);
        
		system.assertEquals('Pending Approval',  foundContract.Contract_Status__c, 'Contract Status not changed');

        ProcessInstance pi = [SELECT TargetObjectId, CreatedDate FROM ProcessInstance WHERE TargetObjectId = :ctrctest.id];
        System.assertEquals(foundContract.CreatedDate.Date(), pi.CreatedDate.Date(), 'No Approval Process on Contract');
        
        test.stopTest();
        System.debug(LOG_TAG + 'test_LegalApprovalRequest Finished!');
    }
}