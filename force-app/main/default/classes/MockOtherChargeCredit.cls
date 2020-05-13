public class MockOtherChargeCredit {
    
    public Id AccessCode = MockSubscription.getNewSubscription().Id;
    public Date BilledDate = Date.newInstance(3010, 1, 1);
    public String Description = 'Test Description';
    public Decimal ChargeOrCredit = 1.0;
    public String Product = 'Test Product';
    public String InternalNotes = 'foo';
    public String Reason = 'Fraud';
        
    private void setupOtherChargeCredit(OtherChargeCredit__c o) {
        o.AccessCode__c = AccessCode;    
        o.BilledDate__c = BilledDate;
        o.Description__c = Description;
        o.ChargeOrCredit__c = ChargeOrCredit;
        o.Product__c = Product;
        o.Internal_Notes__c = InternalNotes;
        o.Reason__c = Reason;
    }
       
    public static OtherChargeCredit__c getNewOtherChargeCredit() {
        OtherChargeCredit__c o = new OtherChargeCredit__c();
        MockOtherChargeCredit m = new MockOtherChargeCredit();
        m.setupOtherChargeCredit(o);        
        Database.insert(o);        
        return o;
    }
    
    public OtherChargeCredit__c getOtherChargeCredit() {
        OtherChargeCredit__c o = new OtherChargeCredit__c();
        setupOtherChargeCredit(o);        
        Database.insert(o);        
        return o;
    }
}