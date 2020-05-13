@isTest//Insted Used FoxDenUserActionsTest
public class FoxDenUserAfterInsertAfterUpdateTest {
   /* @testSetup static void setup() {
        Account acc = new Account();
        acc.Name = 'testAcc';
        INSERT acc;
        Contact c = new Contact();
        c.AccountId=acc.Id;
        c.LastName = 'test Contact';
        INSERT c;
        
        FoxDen_User__c FUser = new FoxDen_User__c();
        FUser.Contact__c = c.Id;
        FUser.Email__c = 'vijay@raagvitech.com';
        FUser.Name = 'test';
        FUser.Status__c = 'Active';
        FUser.ProvisioningEmailSent__c = Date.newInstance(2019, 11, 19);
        FUser.Password__c = 'test1';
        INSERT FUser;       
    }*/
    
    /*static testMethod void testUpdate(){
        // FoxDen_User__c objFoxDenOld = [SELECT Id,Status__c,Name,Password__c,ProvisioningEmailSent__c FROM FoxDen_User__c WHERE Name ='test' LIMIT 1];
        FoxDen_User__c objFoxDenNew = [SELECT Id,Status__c,Name,Password__c,ProvisioningEmailSent__c FROM FoxDen_User__c WHERE Name ='test' LIMIT 1];
        // System.debug('objFoxDenOld>>>>'+objFoxDenOld);
        //objFoxDenNew.Status__c = 'Active';
        objFoxDenNew.ProvisioningEmailSent__c = null;
        objFoxDenNew.Password__c = 'testPassword';
        UPDATE objFoxDenNew;
    }*/
    /*static testMethod void testUpdate1(){
        // FoxDen_User__c objFoxDenOld = [SELECT Id,Status__c,Name,Password__c,ProvisioningEmailSent__c FROM FoxDen_User__c WHERE Name ='test' LIMIT 1];
        FoxDen_User__c objFoxDenNew = [SELECT Id,Status__c,Contact__c,Name,Password__c,ProvisioningEmailSent__c FROM FoxDen_User__c WHERE Name ='test' LIMIT 1];
        System.debug('The Error'+objFoxDenNew);
        objFoxDenNew.ProvisioningEmailSent__c = null;
        objFoxDenNew.Password__c = 'test1';
        UPDATE objFoxDenNew;
    }*/
}