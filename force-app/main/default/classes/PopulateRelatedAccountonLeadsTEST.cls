@isTest 
public class PopulateRelatedAccountonLeadsTEST
{
    static testMethod void populateaccount() 
    {
    
        Account testacc = PGITestUtilities.getAccountDetails(); 
        testacc.website = 'www.testaccount.com';
        testacc.name = 'TestAccount123456789';
        insert testacc;   
        
        Account testacc2 = PGITestUtilities.getAccountDetails(); 
        testacc2.website = 'www.testaccount2.com';
        testacc2.name = 'TestAccount123456789';
        insert testacc2;
        
        Account testacc3 = PGITestUtilities.getAccountDetails(); 
        testacc3.website = 'www.testaccount2.com';
        testacc3.name = 'TestAccount123456789';
        insert testacc3;     
        
        Test.StartTest();
        
        Lead testlead = PGITestUtilities.getLeadDetails();
        testlead.company = 'TestAccount123456789';
        testlead.email = 'test@testaccount.com';
        insert testlead;
        
        Lead testlead2 = PGITestUtilities.getLeadDetails();
        testlead2.company = 'TestAccount123456789';
        testlead2.email = 'test@testaccount2.com';
        insert testlead2;
        
        Lead ld1=[select id,account__c from Lead where id =: testlead.id];
        Lead ld2=[select id,account__c from Lead where id =: testlead2.id];

        system.assertequals(ld2.account__c, null);
        
        Test.StopTest();

    }
}