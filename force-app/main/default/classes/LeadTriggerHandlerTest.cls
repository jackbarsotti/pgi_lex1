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
    @isTest
    public static void testLeadMQL(){
        Profile p = [SELECT Id FROM Profile WHERE Name='PGi Marketing User'];		
        User usrMQLTester = PGITestUtilities.getTestUser(p);
		usrMQLTester.username = 'User' + Math.random()*100 + '@pgi.com';
		usrMQLTester.EmployeeNumber='12345';
        INSERT usrMQLTester;

        p = [SELECT Id FROM Profile WHERE Name='PGi Sales User'];		
        User usrSales = PGITestUtilities.getTestUser(p);
		usrSales.username = 'User' + Math.random()*100 + '@pgi.com';
		usrSales.EmployeeNumber='12345';
        INSERT usrSales;

        System.runAs(usrMQLTester){
            // on insert: creator is marketing user & owner is sales user
            Lead mqlLead1 = PGITestUtilities.getLeadDetails();
            mqlLead1.OwnerId = usrSales.Id;
            INSERT mqlLead1;
            System.assertEquals(true, [SELECT Id, Global_MQL__c FROM Lead Where Id = :mqlLead1.Id].Global_MQL__c);

            // on insert: MQL lead source
            Lead mqlLead2 = PGITestUtilities.getLeadDetails();
            mqlLead2.LeadSource = 'Inbound Call';
            INSERT mqlLead2;
            System.assertEquals(true, [SELECT Id, Global_MQL__c FROM Lead Where Id = :mqlLead2.Id].Global_MQL__c);

            // on update (ownership change): creator is marketing user and owner is not
            Lead mqlLead3 = PGITestUtilities.getLeadDetails();
            INSERT mqlLead3;
            System.assertEquals(false, [SELECT Id, Global_MQL__c FROM Lead Where Id = :mqlLead3.Id].Global_MQL__c);
            mqlLead3.ownerId = usrSales.Id;
            UPDATE mqlLead3;
            System.assertEquals(true, [SELECT Id, Global_MQL__c FROM Lead Where Id = :mqlLead3.Id].Global_MQL__c);
            mqlLead3.Global_MQL__c = false;
            UPDATE mqlLead3;
            // negative test
            mqlLead3.ownerId = usrMQLTester.Id;
            UPDATE mqlLead3;
            System.assertEquals(false, [SELECT Id, Global_MQL__c FROM Lead Where Id = :mqlLead3.Id].Global_MQL__c);
        }
    }
    static testMethod void testLeadinsert(){
        Test.startTest();
        createData();
        System.runAs(u) {
            Lead objLeadUpdate = [SELECT Id,OwnerId FROM Lead Where Id = :objLead.Id];
            objLeadUpdate.Global_MQL__c = false;
            objLeadUpdate.LeadSource = 'Inbound Call';
            UPDATE objLeadUpdate;
            System.assertEquals(false, [SELECT Id,Global_MQL__c FROM Lead Where Id = :objLead.Id].Global_MQL__c);
        }
        Test.stopTest();
    }
    @isTest
    public static void testLeadMatch() {
        Test.startTest();
        Account a = new Account(Name = 'Test Account11');
        insert a;
        Lead objLead = PGITestUtilities.getLeadDetails();
        objLead.Email = null;
        objLead.Company = 'Test Account11';
        objLead.LeadSource = 'Web Chat';
        insert objLead;
        Lead l = [SELECT Id, Account__c FROM Lead];
        System.assertEquals(null, l.Account__c);
        Test.stopTest();
    }
    @isTest
    public static void testLeadMultiMatch() {
        Test.startTest();
        Account a = new Account(Name = 'Test Account11');
        insert a;
        Account a1 = new Account(Name = 'Test Account11');
        insert a1;
        Lead objLead = PGITestUtilities.getLeadDetails();
        objLead.Email = null;
        objLead.Company = 'Test Account11';
        objLead.LeadSource = 'Inbound Call';
        insert objLead;
        Lead l = [SELECT Id, Account__c FROM Lead];
        System.assertEquals(null, l.Account__c);
        Test.stopTest();
    }
    @isTest
    public static void testDomainDomainMatch() {
        Test.startTest();
        Account a = new Account(Name = 'Test Account11', Website = 'test.com');
        insert a;
        Lead objLead = PGITestUtilities.getLeadDetails();
        objLead.Email = 'Test@test.com';
        objLead.Company = 'Test Account11';
        insert objLead;
        Lead l = [SELECT Id, Account__c FROM Lead];
        System.assertEquals(null, l.Account__c);
        Test.stopTest();
    }
    @isTest
    public static void testLeadDomainMultiMatch() {
        Test.startTest();
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
        Test.stopTest();
    }
    
    @isTest
    public static void testNew() {
        Test.startTest();
        Lead leadobj = PGITestUtilities.createLead(true);
        leadobj.Global_MQL__c = false;
        leadobj.ownerId = PGITestUtilities.readyTalkUser.Id;
        leadobj.LeadSource = 'Inbound Call';
        update leadobj;
        Lead leadobj1 = PGITestUtilities.createLead(true);
        leadobj1.Global_MQL__c = false;
        leadobj1.ownerId = PGITestUtilities.readyTalkUser.Id;
        leadobj1.LeadSource = 'Customer Referral';
        update leadobj1;
        Lead l = [SELECT Id,Global_MQL__c FROM Lead WHERE Id =: leadobj.Id ];
        System.assertEquals(true, l.Global_MQL__c);
        Test.stopTest();
    }
    @isTest
    public static void test() {
        Test.startTest();
        Lead leadobj = PGITestUtilities.createLead(true);
        leadobj.Global_MQL__c = true;
        // leadobj.ownerId = PGITestUtilities.readyTalkUser.Id;
        update leadobj;
        Lead leadobj1 = PGITestUtilities.createLead(true);
        // leadobj1.ownerId = PGITestUtilities.readyTalkUser.Id;
        update leadobj1;

        Account a = new Account(Name = 'Test Account11',
                                Global_Account_MQA__c = false,
                                Global_Account_MQA_Assignment_date__c = date.newInstance(2020, 04, 29),
                                Lead_ID__c = leadobj.Id);
        insert a;
        Opportunity opp = PGITestUtilities.createOpportunity(a,true);
        // Database.LeadConvert lc = new database.LeadConvert();
        // lc.setLeadId(leadobj.Id);
        // lc.setAccountId(a.Id);
        // lc.setOpportunityId(opp.Id);
       
        // LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
        // lc.setConvertedStatus(convertStatus.MasterLabel);
       
        // Database.LeadConvertResult lcr = Database.convertLead(lc);
        // System.assert(lcr.isSuccess());
        Test.stopTest();
    }
}