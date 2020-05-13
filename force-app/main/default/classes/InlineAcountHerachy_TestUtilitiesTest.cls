@isTest
public class InlineAcountHerachy_TestUtilitiesTest {
    @testSetup static void setup(){
        Account act = new account(Name = 'Test32',ABM_Last_PES__c='testData',ABM_PES_Last_Change_Date__c =Date.today(),Bill_Address_Verification__c =Date.today().AddDays(2), Z_Source__c = 'eCommerce');
        insert act;
        
        System.assert(act.id <> null);
        
        Contact ct = new Contact();
        ct.FirstName = 'klnasknjaskldasd';
        ct.LastName  = 'efoijasjkndalkmsd';
        ct.Phone     = '3819405828';
        ct.Email     = 'knasdlkmsdklgasd@premierglobal.com';
        ct.accountId = act.id;
        ct.License_Profile__c = true;
        insert ct;
    }
    static testMethod void testInlineAcountHerachy1else()
    {
        InlineAcountHerachy_TestUtilities obj = new InlineAcountHerachy_TestUtilities();
        Set<String> fieldsSet = new Set<String>();
        fieldsSet.add('SystemModstamp');
        List<Contact> conList =obj.testConList;
        List<Lead> leadList=obj.testLeadList;
        List<opportunity> opprList=obj.testOppList;
        List<Task> tskList=obj.testTaskList;
        List<User> usrList=obj.testUserList;
		System.assertEquals(false, obj.checkObjectCrud('Account', fieldsSet,'Create'));
        System.assertEquals(false, obj.checkObjectCrud('Account', fieldsSet,'Update'));
    }
     static testMethod void testInlineAcountHerachyif()
    {
        InlineAcountHerachy_TestUtilities obj = new InlineAcountHerachy_TestUtilities();
        Set<String> fieldsSet = new Set<String>();
        fieldsSet.add('LastModifiedById');
        Account ac=obj.testAcc;
        Contact c=obj.testCon;
        Lead l=obj.testLead;
        Opportunity o=obj.testOpp;
        Task t=obj.testTask;
        User u=obj.testUser;
        obj.createAccounts(1, fieldsSet);
        Account a= [Select Id ,Name,ShippingPostalCode from Account Where AnnualRevenue = 10000];
        System.assertEquals('12345', a.ShippingPostalCode);
    }
   /* static testMethod void testupdateAccountList()
    {
        
        InlineAcountHerachy_TestUtilities obj = new InlineAcountHerachy_TestUtilities();
        
        Set<String> fieldsSet = new Set<String>();
        fieldsSet.add('SystemModstamp');
        obj.updateAccountList(fieldsSet);
    }*/
     static testMethod void testupdateAccountList1()
    {
        InlineAcountHerachy_TestUtilities obj = new InlineAcountHerachy_TestUtilities();
       Account a =[Select Id,Name from Account];
       List<Account> aList = new List<Account>();
        aList.add(a);
        Set<String> fieldsSet = new Set<String>();
        fieldsSet.add('LastModifiedById');
        obj.testAccList=aList;
        obj.updateAccountList(fieldsSet);
    }
}