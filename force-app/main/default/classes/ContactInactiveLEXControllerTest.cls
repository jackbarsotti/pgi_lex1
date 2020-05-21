@isTest
public class ContactInactiveLEXControllerTest{

    static testMethod void testUpdateContact(){
        Contact conObj = new Contact();
        conObj.LastName = 'testCont1';
        INSERT conObj;
        
        ContactInactiveLEXController.updateContact(conObj.Id);
        Contact contactObj=[SELECT Id,Inactive__c FROM Contact WHERE Id=:conObj.Id];
        System.assertEquals(true, contactObj.Inactive__c);
    }
    
}