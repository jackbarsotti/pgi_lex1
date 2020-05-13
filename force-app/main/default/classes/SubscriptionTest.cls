@isTest
public class SubscriptionTest {
    @testSetup static void setupsubscription() {
        
        List<Account> accList = new List<Account>{new Account(Name = 'testAcc')};
            insert accList;
        List<Contact> contList = new List<Contact>{new Contact(Lastname = 'testcon',AccountId = accList[0].Id) };
            insert contList;
        
        List<Subscription__c> subList = new List<Subscription__c>{new Subscription__c(Name = 'testsub',Security_Passcode__c = 'No security'),
            new Subscription__c(Name = 'testsub00',Security_Passcode__c = 'No security',Provision__c = true,Inactive__c = false,Contact__c = contList[0].Id) };
                insert subList;
    }
    static testmethod void testfindById(){
        List<Subscription__c> subList = [select Id,Name ,Security_Passcode__c ,Provision__c,Inactive__c ,Contact__c from Subscription__c];
        List<Contact> contList = [Select id from contact];
        List<Id> contactIds = new List<Id>{contList[0].Id};
            Test.startTest();
        Subscription sObj = new Subscription();
        sObj.findById(subList[0].Id);
        sObj.getSubscriptionsWhereContactInList(contactIds);
        sObj.del(subList[0]);
        System.assertEquals('Deleting', [Select id,Status__c from Subscription__c where Name = 'testsub' limit 1].Status__c);
        Test.stopTest();
    }
}