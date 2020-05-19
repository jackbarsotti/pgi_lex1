@isTest
public class ContactInactiveControllerTest{

    static testMethod void testUpdateContact(){
        Contact conObj=new Contact();
        conObj.LastName='testCont1';
        insert conObj;
        
        ContactInactiveController.updateContact(conObj.Id);
        Contact contactObj=[SELECT Id,Inactive__c FROM Contact WHERE Id=:conObj.Id];
        System.assertEquals(true, contactObj.Inactive__c);
    }
    
}