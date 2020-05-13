public class MockAccount {
    
    public String Status = 'New';
    public String Name = 'Mock Account Object';
    public String AccountNumber = '12345';    
    public String CorporateLicenseType;
    public Date CorporateLicenseStartDate;
    public String CorporateLicenseBillingFrequency;
    public Decimal CorporateLicenseRate;
    public Date CorporateLicenseRenewalDate;
    public Id OwnerId = MockUser.getNewUser().Id;
    public String WebSubDefaultType = 'None (Per-Minute Rates Apply)';
    public Date WebRateStartDate = Date.newInstance(3010, 1, 1);
    public Date AudioRateStartDate = Date.newInstance(2010, 1, 1);
    public String WebSubBillPeriod = 'Monthly';
    public Decimal ReservationlessWeb = 0.150;
    public DateTime DateProvisioned = DateTime.newInstance(Date.newInstance(2010, 1, 1), Time.newInstance(0, 0, 0, 0));
    public String State = 'CO';
    public String StreetAddress1 = '123 Sesame Street';
    public String BillingCity = 'Denver';
    public String BillingZip = '80202';
    public String BillingContactName = 'Fred';
    public String BillingContactEmail = 'fred@readytalk.com';
    public String invoiceTypes = 'Account Summary';
        
    private void setupAccount(Account a) {
        a.Status__c = Status;
        a.Name = Name;
        a.AccountNumber = '12345';
        a.Web_Sub_Bill_Period__c = WebSubBillPeriod;
        a.corporateLicenseType__c = CorporateLicenseType;
        a.corpLicStartDate__c = CorporateLicenseStartDate;
        a.corpLicBillingFrequency__c = CorporateLicenseBillingFrequency;
        a.corporateLicenseRate__c = CorporateLicenseRate;
        //a.corpLicRenewalDate__c = CorporateLicenseRenewalDate;
        a.OwnerId = OwnerId;
        a.Web_Sub_Default_Type__c = WebSubDefaultType;
        a.Rate_Start_Date__c = AudioRateStartDate;
        a.Web_Rate_Start_Date__c = WebRateStartDate;
        a.Web_Sub_Bill_Period__c = WebSubBillPeriod;
        a.Date_Provisioned__c = DateProvisioned;
        a.Reservationless_Web__c = ReservationlessWeb;
        //a.Billing_State__c= State;
        //a.Billing_Street_Address_1__c = StreetAddress1;
        //a.Billing_City__c = BillingCity;
        //a.Billing_Zip__c = BillingZip;
        a.Biling_Contact__c = BillingContactName;
        a.Billing_Contact_Email__c = BillingContactEmail;
        a.Invoice_Types__c = invoiceTypes;
        a.Toll_Free_Number__c = '8009371839';
        a.Toll_Number__c = '8009371839';
        RecordType accntRecordtype = [SELECT Id,Name FROM RecordType WHERE sObjectType = 'Account' AND Name LIKE '%ReadyTalk%' LIMIT 1];
        a.RecordTypeId = accntRecordtype.Id;
    }
       
    public static Account getNewAccount() {
        Account a = new Account();
        MockAccount ma = new MockAccount();
        ma.setupAccount(a);
        Database.insert(a);
        return a;
    }
    
    public Account getAccount() {
        Account a = new Account();
        setupAccount(a);        
        Database.insert(a);        
        return a;
    }
}