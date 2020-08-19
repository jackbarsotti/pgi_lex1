/*
* Test class for LeadTriggerHandler
*/
@isTest
public class LeadTriggerHandlerTest {
    
    //@isTest
    //   public static void SystemAdminUnitTest() {
    //   	Lead testLead = new Lead();
    //   	insert testLead;
    //   }
     @testSetup static void setup() {
       PGITestUtilities.disableSalesWings();
    }   
    public static Lead objLead;
    public static User u;
    static void createData(){
        
        Id pgiRecordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('PGi Leads').getRecordTypeId();
        
        objLead = PGITestUtilities.getLeadDetails();
        objLead.RecordTypeId = pgiRecordTypeIdLead;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        u = new User(Alias = 'standt', Email='rt@cloudfastener.com', 
                          EmailEncodingKey='UTF-8', FirstName='SF Marketing Cloud' ,LastName='Integration', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,EmployeeNumber='1234565', 
                          TimeZoneSidKey='America/Los_Angeles', UserName='RTstandarduser@cloudfastener.com');
        
        System.runAs(u) {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId()); 
            INSERT objLead;
        }
        
        System.debug('objLead>>>>>>>>>>> '+[SELECT Id,CreatedbyId,Createdby.Name, OwnerId FROM Lead Where Id = :objLead.Id]);
    }
    
    static testMethod void testLeadinsert(){
        createData();
        System.runAs(u) {
            Lead objLeadUpdate = [SELECT Id FROM Lead Where Id = :objLead.Id];
            objLeadUpdate.Global_MQL__c = false;
            UPDATE objLeadUpdate;
            System.assertEquals(false, [SELECT Id,Global_MQL__c FROM Lead Where Id = :objLead.Id].Global_MQL__c);
        }
    }
    @isTest
    public static void testLeadMatch() {
        Account a = new Account(Name = 'Test Account11');
        insert a;
        Lead objLead = PGITestUtilities.getLeadDetails();
        objLead.Email = null;
        objLead.Company = 'Test Account11';
        insert objLead;
        Lead l = [SELECT Id, Account__c FROM Lead];
        System.assertEquals(null, l.Account__c);
    }
    @isTest
    public static void testLeadMultiMatch() {
        Account a = new Account(Name = 'Test Account11');
        insert a;
        Account a1 = new Account(Name = 'Test Account11');
        insert a1;
        Lead objLead = PGITestUtilities.getLeadDetails();
        objLead.Email = null;
        objLead.Company = 'Test Account11';
        insert objLead;
        Lead l = [SELECT Id, Account__c FROM Lead];
        System.assertEquals(null, l.Account__c);
    }
    @isTest
    public static void testDomainDomainMatch() {
        Account a = new Account(Name = 'Test Account11', Website = 'test.com');
        insert a;
        Lead objLead = PGITestUtilities.getLeadDetails();
        objLead.Email = 'Test@test.com';
        objLead.Company = 'Test Account11';
        insert objLead;
        Lead l = [SELECT Id, Account__c FROM Lead];
        System.assertEquals(null, l.Account__c);
    }
    @isTest
    public static void testLeadDomainMultiMatch() {
        Account a = new Account(Name = 'Test Account11', Website = 'test.com');
        insert a;
        Account a1 = new Account(Name = 'Test Account11', Website = 'test.com');
        insert a1;
        Lead objLead = PGITestUtilities.getLeadDetails();
        objLead.Email = 'Test@test.com';
        objLead.Company = 'Test Account11';
        insert objLead;
        Lead l = [SELECT Id, Account__c FROM Lead];
        System.assertEquals(null, l.Account__c);
    }
}