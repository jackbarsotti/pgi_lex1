/*
* Test class for ContactTriggerHandler
*/
@isTest
public class ContactTriggerHandlerTest {
    @isTest
    public static void SystemAdminUnitTest() {
        Test.startTest();
        PGITestUtilities.disableSalesWings();
        Account a1 = PGITestUtilities.createAccount(false);
        Account a2 = PGITestUtilities.createAccount(false);        
        insert new List<Account>{a1, a2};
            
            Contact c1a1 = PGITestUtilities.createContact(a1, false);
        // c1a1.AccountId = a1.Id;
        c1a1.Campaign_Code__c = 'test123';
        c1a1.Marketing_Program__c='testasd';
        // c1a1.NetSuite_Locked__c=false;
        c1a1.NetSuite_Locked__c= true;
        c1a1.Celigo_Update__c=false;
        c1a1.RecordTypeId='0121B000001q5WXQAY';
        Contact c2a1 = PGITestUtilities.createContact(a1, false);
        c2a1.Campaign_Code__c='test123';
        c2a1.Marketing_Program__c='testasd';
        c2a1.NetSuite_Locked__c=true;
        c2a1.Celigo_Update__c=true;
        Contact c3a1 = new Contact();
        c3a1.LastName = 'Test Con';
        c3a1.Campaign_Code__c='test123';
        c3a1.Marketing_Program__c='testasd';
        c3a1.NetSuite_Locked__c=true;
        c3a1.Celigo_Update__c=true;
        insert new List<Contact>{c1a1, c2a1, c3a1};
            
            Contact contactObj=[SELECT id,Celigo_Update__c FROM Contact WHERE id=:c1a1.Id];
        System.assertEquals(false, contactObj.Celigo_Update__c);
        Test.stopTest();
        /* 	Contact testContact = new Contact();
testContact.AccountId = testAccount.Id;
testContact.FirstName = 'Test';
testContact.Campaign_Code__c='test123';
testContact.Marketing_Program__c='testasd';
testContact.LastName = 'Test';
testContact.NetSuite_Locked__c=false;
testContact.Celigo_Update__c=false;
testContact.RecordTypeId='0121B000001q5WXQAY';
insert testContact; */
        
        
    }
    @isTest
    public static void testMQLOnOpportunity() {
        Test.startTest();
        PGITestUtilities.disableSalesWings();
        Account a1 = PGITestUtilities.createAccount(false);
        Account a2 = PGITestUtilities.createAccount(false);        
        insert new List<Account>{a1, a2};
            
        Contact c1a1 = PGITestUtilities.createContact(a1, false);
        // c1a1.Form_Submissions__c = frmSubmission.Id;
        c1a1.Campaign_Code__c='test123';
        c1a1.Marketing_Program__c='testasd';
        // c1a1.NetSuite_Locked__c =true;
        c1a1.NetSuite_Locked__c=false;
        c1a1.Celigo_Update__c=false;
        c1a1.RecordTypeId='0121B000001q5WXQAY';
        Contact c2a1 = PGITestUtilities.createContact(a1, false);
        c2a1.Campaign_Code__c='test123';
        c2a1.Marketing_Program__c='testasd';
        c2a1.NetSuite_Locked__c=true;
        c2a1.Celigo_Update__c=true;
        insert new List<Contact>{c1a1, c2a1};
            
            Contact contactObj=[SELECT id,Celigo_Update__c FROM Contact WHERE id=:c1a1.Id];
        System.assertEquals(false, contactObj.Celigo_Update__c);
        Test.stopTest();
        /* 	Contact testContact = new Contact();
testContact.AccountId = testAccount.Id;
testContact.FirstName = 'Test';
testContact.Campaign_Code__c='test123';
testContact.Marketing_Program__c='testasd';
testContact.LastName = 'Test';
testContact.NetSuite_Locked__c=false;
testContact.Celigo_Update__c=false;
testContact.RecordTypeId='0121B000001q5WXQAY';
insert testContact; */
        
        
    }
    
    @isTest
    public static void testCascadeFoxDenUser() {
        Test.startTest();
        PGITestUtilities.disableSalesWings();
        Account a1 = PGITestUtilities.createAccount(false);
        Account a2 = PGITestUtilities.createAccount(false);        
        insert new List<Account>{a1, a2};
            
            Contact c1a1 = PGITestUtilities.createContact(a1, false);
        c1a1.Global_Contact_MQL__c=true;
        c1a1.Global_Contact_MQL_Assignment_date__c=System.now();
        c1a1.Status__c = 'Active';
        Contact c2a1 = PGITestUtilities.createContact(a1, false);
        c2a1.Status__c = 'Active';
        c2a1.Global_Contact_MQL__c=true;
        c2a1.Global_Contact_MQL_Assignment_date__c=System.now();
        Contact c3a2 = PGITestUtilities.createContact(a2, false);
        c3a2.Global_Contact_MQL__c=true;
        c3a2.Global_Contact_MQL_Assignment_date__c=System.now();
        Contact c4a2 = PGITestUtilities.createContact(a2, false);
        c4a2.Status__c = 'Active';
        c4a2.Global_Contact_MQL__c=true;
        c4a2.Global_Contact_MQL_Assignment_date__c=System.now();
        insert new List<Contact>{c1a1, c2a1, c3a2, c4a2};
            
            Opportunity o1a1=PGITestUtilities.createOpportunity(a1, false); 
        o1a1.CreatedDate=System.now();
        Opportunity o2a2=PGITestUtilities.createOpportunity(a2, false); 
        o2a2.CreatedDate=System.now();
        insert new List<Opportunity>{o1a1,o2a2};
            
            FoxDen_User__c fc1a1 = new FoxDen_User__c(Contact__c = c1a1.Id, Status__c = 'Active', Email__c = c1a1.Email);
        //   FoxDen_User__c fc2a1 = new FoxDen_User__c(Contact__c = c2a1.Id, Status__c = 'Active', Email__c = c2a1.Email);
        FoxDen_User__c fc3a2 = new FoxDen_User__c(Contact__c = c3a2.Id, Status__c = 'Active', Email__c = c3a2.Email);
        //  FoxDen_User__c fc4a2 = new FoxDen_User__c(Contact__c = c4a2.Id, Status__c = 'Active', Email__c = c4a2.Email);
        insert new List<FoxDen_User__c>{fc1a1,fc3a2};
            
            //    c4a2.Status__c = 'Inactive';
            //    update c4a2;
            
            //   o2a2.CloseDate=Date.today().addDays(13);
            //   update o2a2;
            
            //  FoxDen_User__c fu = [SELECT Id, Status__c FROM FoxDen_User__c WHERE Id =: fc4a2.Id];
            //  System.assertEquals(c4a2.Status__c, fu.Status__c);
            
            FoxDen_User__c fu2 = [SELECT Id, Status__c FROM FoxDen_User__c WHERE Id =: fc1a1.Id];
        System.assertEquals(c1a1.Status__c, fu2.Status__c);
        Test.stopTest();
    } 
    
    @isTest
    public static void testSetConvertedMQLOnOpportunity() {
        Test.startTest();
        PGITestUtilities.disableSalesWings();
        Account a3 = PGITestUtilities.createAccount(false);
        Account a4 = PGITestUtilities.createAccount(false);        
        insert new List<Account>{a3, a4};
            
        
      
        
        Contact c1a1 =new Contact();
        c1a1.AccountId=a3.Id;
        c1a1.LastName='opptyContact1';
        c1a1.Status__c = 'Active';
        Contact c2a1 = new Contact();
        c2a1.AccountId=a3.Id;
        c2a1.LastName='opptyContact2';
        c2a1.Status__c = 'Active';
        insert new List<Contact>{c1a1, c2a1};
        Form_Submissions__c formSub1=new Form_Submissions__c();
        formSub1.Contact_Id__c =c1a1.id;
        formSub1.Email__c='testForm@fs.com';
        Insert formSub1;   
        c2a1.Email='Test123@pgi.com';
        Update c1a1;

        // System.assertEquals(true, [Select Id,Global_Contact_MQL__c from contact Where Id=:c1a1.Id].Global_Contact_MQL__c);
        Test.stopTest();
    } 

    // @isTest
    // public static void test() {
    //     Test.startTest();
    //     Contact con = new Contact();
    //     con.LastName = 'Test Contact';
    //     con.NetSuite_Locked__c = true;
    //     Contact con1 = new Contact();
    //     con1.LastName = 'Test Contact';
    //     con1.NetSuite_Locked__c = true;
    //     insert new List<Contact>{con, con1};
    //     Test.stopTest();
    // }
}