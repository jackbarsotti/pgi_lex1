@isTest
public without sharing class AttachmentTriggerHandlerTest {
    @testSetup static void setup()
    {
        Profile p = [Select Id from Profile where Name='PGi Legal'];
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZtest',
                         Email = 'Example@pgi.com', 
                         Username = 'Example1@pgi.com', 
                         EmailEncodingKey = 'UTF-8', 
                         Alias = 'Test', 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US',
                         EmployeeNumber='12332',
                         ProfileId = p.Id
                        ); 
        insert uu;
        
         System.runAs(uu) {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId()); 
        }
        
    }
     @isTest static void createAttachmentForCase(){ 
        Case c = PGITestUtilities.createCase();
        insert c;
        
        Attachment a = PGITestUtilities.createAttachment(c.Id);
        insert a;
        
        Case myCase = [SELECT Id, IsUpdateFromCaseComment__c FROM Case];
        system.assert(myCase.IsUpdateFromCaseComment__c == true);
    }
    
  @isTest static void createAttachmentOnPGiContract(){ 
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        testOppty.AccountId = testAcct.Id;
        insert testOppty;
        
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;
        
        Test.startTest();
        
        Attachment a = PGITestUtilities.createAttachment(testContract.Id);
        insert a;
        
        testContract = [SELECT Id, Has_Attachment__c FROM CONMAN_Contract__c];
        system.assert(testContract.Has_Attachment__c, 'Has Attachment set to True after insert');
        
        Test.stopTest();
    }
    
   @isTest static void deleteAttachmentOnPGiContract(){ 
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        testOppty.AccountId = testAcct.Id;
        insert testOppty;
        
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;
        
        Attachment a1 = PGITestUtilities.createAttachment(testContract.Id);
        insert a1;
        Attachment a2 = PGITestUtilities.createAttachment(testContract.Id);
        insert a2;
        
        Test.startTest();
        
        testContract = [SELECT Id, Has_Attachment__c FROM CONMAN_Contract__c];
        system.assert(testContract.Has_Attachment__c, 'Has Attachment set to True after 2 insert');
        
        delete a1;
        
        testContract = [SELECT Id, Has_Attachment__c FROM CONMAN_Contract__c];
        system.assert(testContract.Has_Attachment__c, 'Has Attachment set to True after 1 delete');
        
        delete a2;
        
        testContract = [SELECT Id, Has_Attachment__c FROM CONMAN_Contract__c];
        system.assert(!testContract.Has_Attachment__c, 'Has Attachment set to False after 2 deletes');
        
        Test.stopTest();
    }
    @isTest
    private static void onPGiContract(){ 
        Account testAcct = PGITestUtilities.getAccountDetails();
        insert testAcct;
        
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        testOppty.AccountId = testAcct.Id;
        insert testOppty;
        
        CONMAN_Contract__c internationalContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        
        RecordType internationalContractRt = [SELECT Id FROM RecordType WHERE sObjectType = 'CONMAN_Contract__c' AND DeveloperName  = 'International_Contract']; // International_Contract is renamed to APAC Contract
        internationalContract.RecordTypeId = internationalContractRt.Id;
        CONMAN_Contract__c domesticContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        
        RecordType iContract = [SELECT Id FROM RecordType WHERE sObjectType = 'CONMAN_Contract__c' AND DeveloperName = 'iContract']; // iContract is rename to NA Contract
        domesticContract.RecordTypeId = iContract.Id;
        insert new List<CONMAN_Contract__c>{internationalContract, domesticContract};
            
            Attachment a1 = PGITestUtilities.createAttachment(internationalContract.Id);
        Attachment a2 = PGITestUtilities.createAttachment(domesticContract.Id);
        Database.insert(new List<Attachment>{a1, a2}, false);
        System.assertNotEquals(null, a2.Id);
        System.assertNotEquals(null, a1.Id);
        
    }
    @isTest static void testValidationOnAttachmentDeleteFrmCase(){ 
        user uu =[Select Id from User where lastName='XYZtest'];      
        System.runAs(uu){
            PGITestUtilities.disableSalesWings();
            Account ac = new Account(Name='Ac1',BillingCountry='India',BillingStreet='xyz');
            insert ac;
            Contact con=new Contact(AccountId=ac.Id,LastName= 'test',FirstName='test',Phone= '9887678558',Email= 'hsk@test.com');
            insert con;
            Case caseObj1 = new Case(ContactId = con.Id,AccountId = ac.Id,Status = 'Working',Origin = 'Phone');
            insert caseObj1;
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            Attachment attach=new Attachment(Name='Test',body=bodyBlob,parentId=caseObj1.id); 
            insert attach;
            try{
                Delete attach;
            }
            catch(DmlException e)
            {
                System.debug(e);
            }
            System.assert(attach.Id != null);
        } 
    } 
}