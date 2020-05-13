@isTest
public class ContactRepositoryTest {
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
        System.assertEquals(contactObj.Account.Id, contactMatchDeptLst[0].Account.Id);
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
        System.assertEquals(true, conReturnObj.Inactive__c);
        System.assertEquals(accObj.Id, conReturnObj.Account.Id); 
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
        System.assertEquals(true, contactReturnObj.Inactive__c);
        System.assertEquals('Delete', contactReturnObj.Status__c);
    }
}