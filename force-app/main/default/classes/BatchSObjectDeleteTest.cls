@isTest
public class BatchSObjectDeleteTest {
    static testMethod void testSubscription() {
        Account a =new Account(Name = 'testAcc00',Inactive__c = true,Status__c='Deleting');
        Insert a;
        Contact c = new Contact(Lastname = 'testcon',AccountId = a.Id);
        Insert c;
        Department__c d= new Department__c(Name = 'Testdept', Parent_Account__c = a.id ,Inactive__c = false, Status__c = 'error');
        Insert d;
        Subscription__c s =new Subscription__c(Name = 'testsub00',Security_Passcode__c = 'No security',Provision__c = true,Inactive__c = false,Contact__c = c.Id);
        insert s;
        List<Department__c> departments = BatchSObjectDelete.getDepartmentsFromAccountId(a.Id);
        List<Contact> contacts = BatchSObjectDelete.getContactsByAccountId(a.Id);
        /*BatchSObjectDelete batchDelete1 = new BatchSObjectDelete();
batchDelete1.sObjectName = 'Subscription';
batchDelete1.action = 'DeleteSubscription';
batchDelete1.subscriptionsDeleted = false; 
batchDelete1.contactsDeleted = false;    
batchDelete1.departmentsDeleted = false;
batchDelete1.subscriptions = BatchSObjectDelete.getSubscriptionsFromContactList(contacts);  
batchDelete1.contacts = contacts;
batchDelete1.departments = departments;
batchDelete1.accountId = a.Id;
Database.executeBatch(batchDelete1); */
        BatchSObjectDelete batchDelete = new BatchSObjectDelete();
        batchDelete.sObjectName = 'Subscription';
        batchDelete.action = 'DeleteSubscription';
        batchDelete.subscriptionsDeleted = false; 
        batchDelete.subscriptions = BatchSObjectDelete.getSubscriptionsFromContactList(contacts);   
        Database.executeBatch(batchDelete);
    }
    
    
    //Subscription class
 /*   static testmethod void testbatchSObjdelete(){
        
        List<Account> accList = new List<Account>{
            new Account(Name = 'testAcc00',Inactive__c = true,Status__c='Deleting'),
                new Account(Name = 'testAcc11',Status__c = 'Delete',Inactive__c = true) };
                    insert accList;
        
        List<Contact> contList = new List<Contact>{new Contact(Lastname = 'testcon',AccountId = accList[0].Id),
            new Contact(Lastname = 'testcon00',AccountId = accList[1].Id)};
                insert contList;
        
        List<Id> contactIds = new List<Id>{contList[0].Id,contList[1].Id};
            
            List<Subscription__c> subList = new List<Subscription__c>{
                new Subscription__c(Name = 'testsub00',Security_Passcode__c = 'No security',Provision__c = true,Inactive__c = false,Contact__c = contList[0].Id), 
                    new Subscription__c(Name = 'testsub11',Security_Passcode__c = 'No security',Provision__c = false,Inactive__c = false,Contact__c = contList[1].Id) };
                        insert subList;
        
        List<Department__c> deptList = new List<Department__c>{new Department__c(
            Name = 'Testdept', Parent_Account__c = accList[0].id ,Inactive__c = false, Status__c = 'error'),
            new Department__c(Name = 'Testdept00', Parent_Account__c = accList[1].id,Provision__c =false ,Inactive__c = false, Status__c = 'Deleting')};
                insert  deptList;
        
        Test.startTest();
        
        Subscription sObj = new Subscription();
        sObj.findById(subList[0].Id);
        sObj.getSubscriptionsWhereContactInList(contactIds);
        sObj.del(subList[0]);
        
        Database.executeBatch(new BatchSObjectDelete()); 
        System.assertEquals('Deleting', [Select id,Status__c from Subscription__c where Name = 'testsub00' limit 1].Status__c); 
        Test.stopTest();
    }*/
    //end sub
    //Contact class
    @testSetup static void setup() {
        Account ac = new Account();
        ac.Name='Ac1';
        insert ac;
        Department__c departMentObj = new Department__c();
        departMentObj.Name = 'Testdept';
        departMentObj.Parent_Account__c = ac.id;
        departMentObj.Inactive__c = false;
        departMentObj.Status__c = 'error';
        Insert departMentObj;
        Contact con=new Contact();
        con.Department_Parent__c = departMentObj.Id;
        con.Inactive__c = false;
        con.Inactivated_By__c = 'TestUser';
        con.Provisioned__c = true;
        con.Status__c = 'Pending';
        con.Date_Deleted__c = Date.today();
        con.AccountId=ac.Id;
        con.LastName= 'test';
        con.FirstName='test';
        con.Phone= '9887678558';
        con.Email= 'hsk@test.com';
        insert con;
    }
    static  testmethod void testContactRepositoryById(){
        Account accObj =[Select Id,Name from Account Where Name='Ac1'];
        List<Id> deptListId = new List<Id>();
        Department__c deptObj = [Select Id from Department__c Where Status__c = 'error'];
        deptListId.add(deptObj.Id);
        Contact contactObj = [Select id,name,Account.Id,Department_Parent__c,Inactive__c, Inactivated_By__c, Provisioned__c, Status__c, Date_Deleted__c from Contact];
        ContactRepository obj = new ContactRepository();
        obj.getContactsByAccountId(accObj.Id);
        List<contact> contactMatchAccLst = obj.getContactsByAccountId(accObj.Id);
        System.assertEquals(contactObj.Name, contactMatchAccLst[0].Name);
        List<contact> contactMatchDeptLst = obj.getContactsWhereDepartmentInList(deptListId);
        
        BatchSObjectDelete bsdobj = new BatchSObjectDelete();
        bsdobj.afterSubscriptionDeleteRemoveContacts();
        bsdobj.afterContactDeleteRemoveDepartments();
        
        
    }
    static  testmethod void testContactCascadeDelete(){
        Account accObj =[Select Id,Name from Account Where Name='Ac1'];
        Contact contactObj = [Select id,name,Account.Id,Department_Parent__c,Inactive__c, Inactivated_By__c, Provisioned__c, Status__c, Date_Deleted__c from Contact];
        contactObj.Inactive__c = true;
        contactObj.Status__c = 'Deleting';
        Update contactObj;
        List<contact> conList = new List<Contact>();
        conList.add(contactObj);
        ContactRepository obj = new ContactRepository();
        obj.cascadeDelete(contactObj);  
        contact conReturnObj = [Select id,name,Account.Id,Department_Parent__c,Inactive__c, Inactivated_By__c, Provisioned__c, Status__c, Date_Deleted__c from Contact];
        
    }
    static  testmethod void testContactDel(){
        Contact contactObj = [Select id,name,Account.Id,Department_Parent__c,Inactive__c, Inactivated_By__c, Provisioned__c, Status__c, Date_Deleted__c from Contact];
        contactObj.Inactive__c = false;
        contactObj.Status__c = 'Deleting';
        contactObj.Inactivated_By__c=null;
        contactObj.Date_Deleted__c=null;
        Update contactObj;
        List<contact> conList = new List<Contact>();
        conList.add(contactObj);
        ContactRepository obj = new ContactRepository();
        Obj.del(conList);
        Contact contactReturnObj = [Select Inactive__c,Status__c,Inactivated_By__c,Date_Deleted__c from contact];
        
    }
    //end cont
    //Department class
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
    }
    //END Dpt
    //Account class
    static testMethod void testCustomDelete() {
        List<Account> accList = new List<Account>{new Account(Name = 'testAcc'),
            new Account(Name = 'testAcc00',Inactive__c = true,Status__c='Deleting'),
            new Account(Name = 'testAcc11',Status__c = 'Delete',Inactive__c = true) };
                insert accList;
        
        Test.startTest();
        AccountRepository a = new AccountRepository();
        a.findById(accList[0].Id);
        a.cascadeDelete(accList[1]);
        a.del(accList[2]);
        
        Test.stopTest();
    }
    //end acc
}