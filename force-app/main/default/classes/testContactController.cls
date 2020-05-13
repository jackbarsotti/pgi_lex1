@isTest
private class testContactController {
    @testSetup static void setup() {
        PGITestUtilities.disableSalesWings();
    }
    static {
        ApexPages.currentPage().getParameters().put('id', MockAccount.getNewAccount().id);
    }
    
    static testMethod void testConstruct() {
        ContactController c = new ContactController();
        System.assert(c!=null);
        
        ApexPages.currentPage().getParameters().put('id', MockDepartment.getNewDepartment().id);
        c = new ContactController();
        System.assert(c!=null);
        
        ApexPages.currentPage().getParameters().put('id', MockAccount.getNewAccount().id);
        c = new ContactController();
        System.assert(c!=null);
        
        ApexPages.currentPage().getParameters().put('delID', MockContact.getNewContact().id);
        c = new ContactController();
        System.assert(c!=null);        
    }
    
    static testMethod void testSave() {
        ContactController c = new ContactController();
        System.assert(c.save()==null);
    }
    
    static testMethod void testSaveThenNew() {
        ContactController c = new ContactController();
        System.assert(c.saveThenNew()!=null);
    } 
    
    /*static testMethod void testCustomDelete() {
ApexPages.currentPage().getParameters().put('id', '/'+MockContact.getNewContact().id);
ApexPages.currentPage().getParameters().put('delID', '/'+MockContact.getNewContact().id);
ApexPages.currentPage().getParameters().put('retURL', '/'+MockContact.getNewContact().id);
ContactController c = new ContactController();
c.init();
System.assert(1==1);
}  */
    
    static testMethod void testCancelDelete() {
        ContactController c = new ContactController();
        System.assert(c.cancelDelete()!=null);
    }  
    //new
    static testMethod void testInit() {
        ApexPages.currentPage().getParameters().put('retURL', '/'+MockContact.getNewContact().id);
        ContactController c = new ContactController();
        System.assert(c.init()==null);
    }  
    static testMethod void testInitWithContact() {
        ApexPages.currentPage().getParameters().put('delID', MockContact.getNewContact().id);
        ApexPages.currentPage().getParameters().put('retURL', '/'+MockContact.getNewContact().id);
        ContactController c = new ContactController();
        c.init();
    } 
    //new
    /*static testMethod void testcontroller() {
ApexPages.currentPage().getParameters().put('Id', '/'+MockContact.getNewContact().id);
ContactController c = new ContactController();
System.assert(c.init()==null);
}*/
    
    
    static testMethod void testGetContact() {
        ContactController c = new ContactController();
        c.setContact(new Contact());
        System.assert(c.getContact()!=null);
    }  
    
    static testMethod void testGetAdministratorInformationTitle() {
        ContactController c = new ContactController();
        System.assert(c.getAdministratorInformationTitle()!=null);
    }  
    
    static testMethod void testSetWaitDialogContent() {
        ContactController c = new ContactController();
        c.setWaitDialogContent();
        System.assert(c.getWaitDialog()!=null);
    } 
    static testMethod void testrestoreDateNull() {
        ApexPages.currentPage().getParameters().put('delID', MockContact.getNewContact().id);   
        ContactController c = new ContactController();
        String Id =ApexPages.currentPage().getParameters().get('delID');  
        Contact contactObj =[Select Account.Id,Status__c from Contact where Id=:ApexPages.currentPage().getParameters().get('delID')];
        contactObj.Status__c='Delete'; 
        Update contactObj;
        Account accountObj =[Select Status__c from Account Where Id=:contactObj.AccountId];
        accountObj.Status__c='Active'; 
        Update accountObj;  
        ContactController.restore(Id);
        System.assertEquals('Contact must have a Date Deleted value set before restoring.',ContactController.restore(Id));
    }
    static testMethod void testrestoreDate() {
        ApexPages.currentPage().getParameters().put('delID', MockContact.getNewContact().id);   
        ContactController c = new ContactController();
        String Id =ApexPages.currentPage().getParameters().get('delID');  
        Contact contactObj =[Select Account.Id,Status__c from Contact where Id=:ApexPages.currentPage().getParameters().get('delID')];
        contactObj.Status__c='Delete'; 
        contactObj.Date_Deleted__c=Date.today().addDays(-31);
        Update contactObj;
        Account accountObj =[Select Status__c from Account Where Id=:contactObj.AccountId];
        accountObj.Status__c='Active'; 
        Update accountObj;  
        System.assertEquals('Cannot restore Contacts that were deleted more than 30 days ago.',ContactController.restore(Id));
    }
    static testMethod void testrestore() {
        ApexPages.currentPage().getParameters().put('delID', MockContact.getNewContact().id);   
        ContactController c = new ContactController();
        String Id =ApexPages.currentPage().getParameters().get('delID');  
        Contact contactObj =[Select Account.Id,Status__c from Contact where Id=:ApexPages.currentPage().getParameters().get('delID')];
        contactObj.Status__c='Delete'; 
        contactObj.Date_Deleted__c=Date.today();   
        Update contactObj;
        Account accountObj =[Select Status__c from Account Where Id=:contactObj.AccountId];
        accountObj.Status__c='Active'; 
        Update accountObj; 
        ContactController.restore(Id);
        Contact objContact =[Select Inactive__c,Status__c From Contact];
        System.assertEquals(false, objContact.Inactive__c);
        System.assertEquals('Restoring', objContact.Status__c);
    }
    
    static testMethod void testrestoreAccountException() {
        ApexPages.currentPage().getParameters().put('delID', MockContact.getNewContact().id);   
        ContactController c = new ContactController();
        String Id =ApexPages.currentPage().getParameters().get('delID');  
        System.assertEquals('Related Account must be in an Active status before restoring.',ContactController.restore(Id)); 
    }
    static testMethod void testrestoreDeptValidation() {
        ApexPages.currentPage().getParameters().put('id', MockDepartment.getNewDepartment().id);
        ApexPages.currentPage().getParameters().put('delID', MockContact.getNewContact().id);   
        ContactController c = new ContactController();
        String Id =ApexPages.currentPage().getParameters().get('delID');  
        Id deptId = ApexPages.currentPage().getParameters().get('id');
        Contact contactObj =[Select Account.Id,Status__c from Contact where Id=:ApexPages.currentPage().getParameters().get('delID')];
        contactObj.Status__c='Delete'; 
        contactObj.Department_Parent__c=deptId;
        contactObj.Date_Deleted__c=Date.today();   
        Update contactObj;
        Account accountObj =[Select Status__c from Account Where Id=:contactObj.AccountId];
        accountObj.Status__c='Active'; 
        Update accountObj; 
        System.assertEquals('Related Department must be in an Active status before restoring.',ContactController.restore(Id)); 
    }
    static testMethod void testrestoreStatusException() {
        ApexPages.currentPage().getParameters().put('delID', MockContact.getNewContact().id);   
        ContactController c = new ContactController();
        String Id =ApexPages.currentPage().getParameters().get('delID');  
        Contact contactObj =[Select Account.Id,Status__c from Contact where Id=:ApexPages.currentPage().getParameters().get('delID')];
        contactObj.Date_Deleted__c=Date.today();
        Update contactObj;
        Account accountObj =[Select Status__c from Account Where Id=:contactObj.AccountId];
        accountObj.Status__c='Active';
        update accountObj;
        System.assertEquals('Contact must be in a Delete satus before restoring.',ContactController.restore(Id));
    }
    static testMethod void testcustomDelete() {
        ApexPages.currentPage().getParameters().put('delID', MockContact.getNewContact().id);  
        ContactController c = new ContactController();
        c.customDelete();
        Contact objContact =[Select Inactive__c,Status__c From Contact];
        System.assertEquals(true, objContact.Inactive__c);
        System.assertEquals('Deleting', objContact.Status__c);
    } 
    static testMethod void testcustomDeleteElse() {
        ContactController c = new ContactController();
        System.assert(c.customDelete()==null);
    } 
}