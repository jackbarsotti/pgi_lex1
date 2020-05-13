@isTest
public class FoxDenUserActionsTest {
    
    @testSetup static void setup() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u){
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'name';
            validEmailTemplate.DeveloperName = 'Provisioning_FoxDen';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            validEmailTemplate.Body='Test123';
            validEmailTemplate.HtmlValue='Test456';
            insert validEmailTemplate;
        }
        Account acc = new Account();
        acc.Name = 'testAcc';
        INSERT acc;
        Contact c = new Contact();
        c.LastName = 'test Contact';
        c.Email = 'vijay@test.com';
        c.AccountId = acc.Id;
        INSERT c;
        
        FoxDen_User__c FUser = new FoxDen_User__c();
        FUser.Contact__c = c.Id;
        FUser.Email__c = 'vijay@test.com';
        FUser.Name = 'test';
        FUser.Status__c = 'Active';
        FUser.ProvisioningEmailSent__c = null;
        FUser.Password__c = 'test@123';
        INSERT FUser; 
        
    }
    
    
    static testMethod void testActiveStatusUpdate(){
        
        FoxDen_User__c objFoxDenOld = [SELECT Id,Contact__c,Status__c,Name,Password__c,ProvisioningEmailSent__c FROM FoxDen_User__c WHERE Name ='test' LIMIT 1];
        FoxDen_User__c objFoxDenNewu = new FoxDen_User__c();
        objFoxDenNewu.id = objFoxDenOld.Id;
        objFoxDenNewu.Status__c = 'Active';
        objFoxDenNewu.ProvisioningEmailSent__c = null;
        objFoxDenNewu.Password__c = 'test@123';
        UPDATE objFoxDenNewu;
        FoxDen_User__c foxUser =[Select Id, ProvisioningEmailSent__c from FoxDen_User__c Where Password__c = 'test@123'];
        System.assertEquals(foxUser.ProvisioningEmailSent__c.format(),Datetime.now().format());
    }
    
}