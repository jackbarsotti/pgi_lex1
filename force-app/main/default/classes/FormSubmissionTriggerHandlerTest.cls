@isTest
public class FormSubmissionTriggerHandlerTest {
@isTest
    public static void setContactMql() {
         PGITestUtilities.disableSalesWings();
        Account a3 = PGITestUtilities.createAccount(false);
        Insert a3;
        Contact c1a1 =new Contact();
        c1a1.AccountId=a3.Id;
        c1a1.LastName='opptyContact1';
        c1a1.Status__c = 'Active';
        Insert c1a1;
        Form_Submissions__c formSub1=new Form_Submissions__c();
        formSub1.Contact_Id__c =c1a1.id;
        formSub1.Email__c='testForm@fs.com';
        Insert formSub1;  

        // System.assertEquals(true, [Select Id,Global_Contact_MQL__c from contact Where Id=:c1a1.Id].Global_Contact_MQL__c);

    }
}