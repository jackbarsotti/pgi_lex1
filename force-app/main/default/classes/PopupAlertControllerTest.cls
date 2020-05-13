@isTest
public class PopupAlertControllerTest {
    static testMethod void SendAnEmailMethod(){
        Account accountObj= new Account();
        accountObj.Name='Test';
        Insert accountObj;
        Contact contactObj= new Contact();
       	contactObj.AccountId=accountObj.Id;
        contactObj.Email='Test@eX.com';
        contactObj.LastName='Test';
        contactObj.Language_Preference__c='EN';
        contactObj.Title='test';
        Insert contactObj;
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('US','US'));
        options.add(new SelectOption('CANADA','Canada'));
        options.add(new SelectOption('MEXICO','Mexico')); 
        ApexPages.StandardController sc = new ApexPages.StandardController(contactObj);
        PageReference pageRef = Page.popUp;
        Test.setCurrentPage(pageRef);
        PopupAlertController popUpObj= new PopupAlertController(sc);
        popUpObj.showPopup();
        System.assertEquals(true,popUpObj.displayPopup);
        popUpObj.closePopup();
        System.assertEquals(false,popUpObj.displayPopup);
        popUpObj.getItems();
        System.assertEquals(options,popUpObj.getItems());
        popUpObj.redirectPopup();
    }
}