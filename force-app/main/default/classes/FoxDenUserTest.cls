@isTest
private class FoxDenUserTest {
 
    static testMethod void testConstruct() {
        Contact c = new Contact();
        c.LastName = 'test Contact';
        INSERT c;
        
        FoxDen_User__c FUser = new FoxDen_User__c();
        FUser.Contact__c = c.Id;
        FUser.Email__c = 'vijay@raagvitech.com';
        FUser.Name = 'test';
        FUser.Status__c = 'Pending';
        INSERT FUser;
        FoxDenUser FUserController = new FoxDenUser();
        FUserController.findById(FUser.Id);
        FoxDenUser.builderValidator ObjFuser = new FoxDenUser.builderValidator();
        ObjFuser.validate(FUser);
        
       FoxDen_User__c objUser = [SELECT Id,Name FROM FoxDen_User__c WHERE Id=: FUser.Id];
        System.assertEquals(objUser.Name, 'test');
       
    }
}