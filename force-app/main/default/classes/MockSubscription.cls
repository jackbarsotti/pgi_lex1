public class MockSubscription {
    
    public String Name = '1000001';
    public String PassCode = '12589';
    public String SecurityPasscode = 'No security'; 
    public String AudioSubscriptionSize = '96';
    public String CardName = 'Test Card Name';
    public String Email = 'qa@readytalk.com';
    public String StreetAddress1 = '1234 Sesame St.';
    public String StreetAddress2 = 'Suite 350';
    public String City = 'Denver';
    public String State = 'CO';
    public String Zip = '80202';
    public String Country = 'UNITED STATES';
    public Date WebStartDate = Date.today();
    public Date WebSubscriptionRenewalDate;
    public String WebSubDefaultType='None';
    public String Promotion;
    public Id OwnerId = MockUser.getNewUser().Id;
    public Id ContactId = MockContact.getNewContact().Id;
    public boolean Inactive = false;
    public Double BillingID;
    public DateTime CreatedDate;
        
    private void setupSubscription(Subscription__c s) {
        s.Name = Name;
        s.Passcode__c = PassCode;
        s.Security_Passcode__c = SecurityPasscode;  
        s.Audio_subscription_size__c = AudioSubscriptionSize;
        s.Card_Name__c = CardName;
        s.Subscription_Email__c = Email;
        s.Address_Line_1__c = StreetAddress1;
        s.Address_Line_2__c = StreetAddress2;
        s.City__c = City;
        s.State__c = State;
        s.Zip__c = Zip;
        s.Country__c = Country;
        s.Web_Start_Date__c = WebStartDate;
        s.Web_Subscription_Renewal_Date__c = WebSubscriptionRenewalDate;
        s.Web_Sub_Default_Type__c = WebSubDefaultType;  
        s.Promotion__c = Promotion;
        s.OwnerId = OwnerId;
        s.Contact__c = ContactId;
        s.inactive__c = Inactive;
        s.Billing_ID__c = BillingID;
        s.ProvisioningEmailSent__c = Datetime.now();
    }
       
    public static Subscription__c getNewSubscription() {
        Subscription__c s = new Subscription__c();
        MockSubscription ms = new MockSubscription();
        ms.setupSubscription(s);        
        Database.insert(s);        
        return s;
    }
    
    public Subscription__c getSubscription() {
        Subscription__c s = new Subscription__c();
        setupSubscription(s);      
        Database.insert(s);        
        return s;
    }
}