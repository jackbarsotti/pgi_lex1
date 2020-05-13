@isTest
private class eSignatureControllerTest {
	 @testSetup static void setupTest() {
	   PGITestUtilities.disableSalesWings();
	   Account acc = new Account();
	   acc.Name = 'Test Account';
	   insert acc;
	   Contact con = new Contact();
	   con.LastName = 'Test Contact';
	   con.AccountId = acc.Id;
	   insert con;
	   Attachment attach=new Attachment();       
	   attach.Name='Unit Test Attachment';
	   Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
	   attach.body=bodyBlob;
	   attach.parentId=acc.Id;
	   insert attach;
    }
	@isTest 
	private static void eSignExistingContact(){
		Test.startTest();
		Opportunity testOpp = setUp();
		Contact testContact = PGITestUtilities.getContactDetails(testOpp.AccountId);
		insert testContact;
		
		PageReference testPage = Page.eSignature;
		Test.setCurrentPage(testPage);
		eSignatureController controller = new eSignatureController(new ApexPages.StandardController(testOpp));
		PageReference pageRef1 = controller.Yes();
		System.assertEquals(false, ApexPages.hasMessages());
		
		controller = new eSignatureController(new ApexPages.StandardController(testOpp));
		controller.ConManContract.Docusign_Customer_Signer__c = testContact.Id;
		Id rtId = [SELECT Id FROM RecordType WHERE sObjectType = 'CONMAN_Contract__c' AND DeveloperName = 'iContract'].Id; // iContract is rename from NA Contract
    	ConMan_Contract__c testContract = [SELECT Id FROM ConMan_Contract__c];
    	testContract.RecordTypeId = rtId;
    	update testContract;
		System.assertEquals('NA Contract', [SELECT RecordType.Name FROM ConMan_Contract__c].recordType.Name);
		controller.PopulateContact();
		controller.UpdateContact();
		System.assertEquals(false, ApexPages.hasMessages());
		
		controller.attachment = PGITestUtilities.createAttachment(null);
		controller.Upload();
		System.assertEquals(false, ApexPages.hasMessages(), ApexPages.getMessages());
        
        //for exception
	    controller.Upload();
		System.assertEquals(true, ApexPages.hasMessages(), ApexPages.getMessages());
        
		controller.UpdateConManContract();
		controller.Back();
		PageReference ref = controller.Cancel();
		System.assertEquals(true, ApexPages.hasMessages());
		
		List<ConMan_Contract__c> contracts = [SELECT Account_Name__c, Docusign_Customer_Signer__c FROM ConMan_Contract__c WHERE Opportunity__c =: testOpp.Id];
		System.assert(contracts.size()>0);
		System.assertEquals(contracts[0].Account_Name__c, testOpp.AccountId);
		System.assertEquals(contracts[0].Docusign_Customer_Signer__c, testContact.Id);
		
		/*List<dsfs__DocuSign_Status__c> dsStatusList = [SELECT Id, dsfs__Opportunity__c FROM dsfs__DocuSign_Status__c WHERE ConMan_Contract__c=:contracts[0].Id];
		System.assert(dsStatusList.size()>0);
		if(dsStatusList.size()>0){
			system.assertEquals(dsStatusList[0].dsfs__Opportunity__c, testOpp.Id);
		}*/
		Test.stopTest();
	}
	
	@isTest
	private static void eSignNewContact(){
		Test.startTest();	
		Opportunity testOpp = setUp();
		
		PageReference testPage = Page.eSignature;
		Test.setCurrentPage(testPage);
		eSignatureController controller = new eSignatureController(new ApexPages.StandardController(testOpp));
		PageReference pageRef1 = controller.No();
		System.assertEquals(false, ApexPages.hasMessages());
		System.assertEquals(controller.contact.AccountId, testOpp.AccountId);
		
		controller.contact = PGITestUtilities.getContactDetails(testOpp.AccountId);
		controller.SaveContact();
		System.assertEquals(false, ApexPages.hasMessages());
        //catch exception
        controller.SaveContact();
        System.assertEquals(true, ApexPages.hasMessages());
        
		List<ConMan_Contract__c> contracts = [SELECT Account_Name__c, Docusign_Customer_Signer__c FROM ConMan_Contract__c WHERE Opportunity__c =: testOpp.Id];
		System.assert(contracts.size()>0);
		System.assertEquals(contracts[0].Account_Name__c, testOpp.AccountId);
		System.assert(contracts[0].Docusign_Customer_Signer__c != null);
		
		Test.stopTest();
	}
	
	@isTest
	private static void eSignExistingAttachmentcatchUpdate(){
		Test.startTest();
		Account acc= new Account();
        acc.Name='TestAccountSetImplementationOwnerOnOpportunity';
        acc.BillingCountryCode = 'US';
        acc.BillingStateCode = 'AL';
        acc.BillingPostalCode = '35630';
        acc.BillingStreet = '110 abc street';
        insert acc;
            
     	Opportunity opp1 = new Opportunity();
        opp1.Name = 'test1';
    	opp1.AccountId = acc.Id;
        opp1.CloseDate = system.today();
        opp1.StageName = 'Awareness';
        opp1.CurrencyIsoCode = 'USD';
        opp1.Products_of_Interest__c = 'Foxden';
        insert opp1;
		
		PageReference testPage = Page.eSignature;
		Test.setCurrentPage(testPage);
		eSignatureController controller = new eSignatureController(new ApexPages.StandardController(opp1));
		controller.UpdateContact();
		System.assertEquals(true, ApexPages.hasMessages());
		
		

		Test.stopTest();
	}
    
	@isTest
	private static void eSignExistingAttachment(){
		Test.startTest();
		Opportunity testOpp = setUp();
		//ConMan_Contract__c testContract = PGITestUtilities.getConManContractDetails(testOpp.AccountId, testOpp.Id);
		ConMan_Contract__c testContract = new ConMan_Contract__c();
    	testContract.Account_Name__c = testOpp.AccountId;
    	testContract.Opportunity__c = testOpp.Id;
		insert testContract;
		Attachment attachment = [SELECT Id, ParentId, Name, Body FROM Attachment WHERE Name = 'Unit Test Attachment'];
		Contact testContact = [SELECT Id,LastName FROM Contact WHERE LastName = 'Test Contact'];
		// Attachment attachment = PGITestUtilities.createAttachment(testContract.Id);
		// insert attachment;
		// Contact testContact = PGITestUtilities.getContactDetails(testOpp.AccountId);
		// insert testContact;
		
		PageReference testPage = Page.eSignature;
		Test.setCurrentPage(testPage);
		eSignatureController controller = new eSignatureController(new ApexPages.StandardController(testOpp));
		PageReference pageRef1 = controller.Yes();
		System.assertEquals(false, ApexPages.hasMessages());
        String Pag = controller.page;
        Attachment attac = controller.attachment;
		controller.ConManContract.Docusign_Customer_Signer__c = testContact.Id;
		controller.PopulateContact();
		controller.UpdateContact();
		System.assertEquals(false, ApexPages.hasMessages());
		
		Contact testContact2 = PGITestUtilities.getContactDetails(testOpp.AccountId);
		controller.contact = testContact2;
		controller.SaveContact();
		System.assertEquals(false, ApexPages.hasMessages());
       
        

		Test.stopTest();
	}
    
	private static Opportunity setUp(){
		Account testAccount = PGITestUtilities.getAccountDetails();
		insert testAccount;
		Opportunity testOpp = PGITestUtilities.getOpportunityDetails();
		testOpp.AccountId = testAccount.Id;
		insert testOpp;
		// Product2 product = PGITestUtilities.getStdProduct();
		// insert product;
		// PricebookEntry pbe = PGITestUtilities.CreatePriceBookEntryForProduct(product);
		// insert pbe;
		// OpportunityLineItem testOli = PGITestUtilities.getOpportunityLineItemDetails(testOpp.Id, pbe.Id);
		// insert testOli;

		return testOpp;
	}
}