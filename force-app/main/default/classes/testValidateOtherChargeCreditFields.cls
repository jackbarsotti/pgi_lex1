@isTest
private class testValidateOtherChargeCreditFields {
     @testSetup static void setup() {
       PGITestUtilities.disableSalesWings();
    }
	
    static testMethod void testValidateChargeCredit() {
        MockOtherChargeCredit mock = new MockOtherChargeCredit();
        mock.ChargeOrCredit = 0;
        System.assert(ValidateOtherChargeCreditFields.validateChargeCredit(mock.getOtherChargeCredit()) == false);
        
        mock.Product = 'Credit';
        mock.ChargeOrCredit = 1;
        System.assert(ValidateOtherChargeCreditFields.validateChargeCredit(mock.getOtherChargeCredit()) == false);
        
        mock.Product = 'Not a Credit';
        mock.ChargeOrCredit = -1;
        System.assert(ValidateOtherChargeCreditFields.validateChargeCredit(mock.getOtherChargeCredit()) == false);                
    }
}