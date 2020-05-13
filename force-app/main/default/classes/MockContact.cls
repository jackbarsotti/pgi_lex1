public class MockContact {
    
    public String Status = 'New';
    public Account acct = MockAccount.getNewAccount();
    public Id AccountId = acct.id;
    public String LastName = 'Mock Last Name';
    public String FirstName = 'Mock First Name';
    public String MailingAddress1 = '123 Main St.';
    public String MailingAddress2 = 'Unit 350';
    public String MailingCity = 'Denver';
    public String MailingStateCode = 'CO';
    public String MailingState = 'Colorado';
    public String MailingCountry = 'United States';
    public String MailingCountryCode = 'US';
    public String MailingZip = '80202';
    public Id OwnerId = MockUser.getNewUser().Id;
    public boolean Inactive = false;
    public String email = 'qa@readytalk.com';
    
    public void setupContact(Contact c) {
        c.Status__c = Status;     
        c.AccountId = AccountId;
        c.Account = acct;
        c.LastName = LastName;
        c.FirstName = FirstName;
        c.OwnerId = OwnerId;
        c.inactive__c = Inactive;
        c.MailingStreet = MailingAddress1;
        //c.Mailing_Address_2__c = MailingAddress2;
        c.MailingCity = MailingCity;
        c.MailingState = MailingState;
        c.MailingStateCode = MailingStateCode;
        c.MailingPostalCode = MailingZip;
        c.MailingCountry = MailingCountry;
        c.MailingCountryCode = MailingCountryCode;
        c.Email = email;     
        c.Individual_ID__c = '1234'; 
    }
       
    public static Contact getNewContact() {        
        Contact c = new Contact();
        MockContact mc = new MockContact();
        mc.setupContact(c);
        Database.insert(c);      
        return c;
    }
    
    public Contact getContact() {
        Contact c = new Contact();
        setupContact(c);        
        Database.insert(c);        
        return c;
    }
}