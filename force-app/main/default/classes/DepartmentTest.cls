@isTest
public class DepartmentTest {
    
    static testMethod void cascadeDeleteDeptTest() {
         
        List<Account> accList = new List<Account>{new account(Name = 'TestAcc',Type = 'carrier',Website = 'http://google.com')};
            Insert accList;
        List<Department__c> deptList = new List<Department__c>{new Department__c(
            Name = 'Testdept', Parent_Account__c = accList[0].id ,Inactive__c = false, Status__c = 'error')};
            insert  deptList;
        Test.startTest();   
       // delete deptList[0];
        new Department().getDepartmentsByAccountId(accList[0].id);
        new Department().cascadeDelete(deptList[0]);
            
		 Test.stopTest();
    }
    
    static testMethod void deldepttest() {
       Test.startTest();
        List<Account> accList = new List<Account>{new account(Name = 'TestAcc00',Type = 'carrier',Website = 'http://google.com')};
            Insert accList;
        system.debug('Recordtype==>'+[SELECT Id,Name,RecordType.Name FROM Account WHERE Name = 'TestAcc00'].RecordType.Name);
        List<Department__c> deptList = new List<Department__c>{new Department__c(
            Name = 'Testdept00', Parent_Account__c = accList[0].id,Provision__c =false ,Inactive__c = false, Status__c = 'Deleting')};
            insert  deptList;
       
        new Department().del(deptList);
        Test.stopTest();
        
        System.assertEquals('Delete', [select id ,Status__c from Department__c where Name = 'Testdept00'].Status__c);
    }
}