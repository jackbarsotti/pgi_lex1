@isTest
public class CampaignMemberTriggerHandlerTest {
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
        Campaign camp = new Campaign();
        camp.Type='Email';
        camp.Name='Test';
        camp.CurrencyIsoCode='USD';
        camp.Product_Family_Interest__c ='Collaboration';
        camp.Region__c='APAC';
        Insert camp;
        CampaignMember newMember =new CampaignMember(ContactId = c1a1.id, status='Sent', campaignid = camp.id);
        insert newMember;
        //  System.assertEquals(true, [Select Id,Global_Contact_MQL__c from contact Where Id=:c1a1.Id].Global_Contact_MQL__c);
    }
}