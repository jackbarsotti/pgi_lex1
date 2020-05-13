@isTest
public class AccountRepositoryTest {
    static testMethod void testCustomDelete() {
        List<Account> accList = new List<Account>{new Account(Name = 'testAcc'),
            new Account(Name = 'testAcc00',Inactive__c = true,Status__c='Deleting'),
            new Account(Name = 'testAcc11',Status__c = 'Delete',Inactive__c = true) };
        insert accList;
        
        Test.startTest();
        AccountRepository a = new AccountRepository();
        a.findById(accList[0].Id);
        a.cascadeDelete(accList[1]);
       //  Database.SaveResult srList = Database.update(accList[2], false);
        a.del(accList[2]);
        Test.stopTest();
        System.assertEquals(0, [select id,Status__c from account where Status__c = 'Delete'].size());
    }
}