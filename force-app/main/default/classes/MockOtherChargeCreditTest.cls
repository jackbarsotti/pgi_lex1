@isTest
public class MockOtherChargeCreditTest {
  @isTest Static void testMock()
    {
        PGITestUtilities.disableSalesWings();
        OtherChargeCredit__c o = MockOtherChargeCredit.getNewOtherChargeCredit();
        System.assertEquals('Fraud',o.Reason__c);
        System.assertEquals('Test Description',o.Description__c);
    }
  @isTest Static void testMock1()
    {
        PGITestUtilities.disableSalesWings();
        MockOtherChargeCredit obj = new MockOtherChargeCredit();
        OtherChargeCredit__c o = obj.getOtherChargeCredit();
        System.assertEquals('foo',o.Internal_Notes__c);
        System.assertEquals('Test Product',o.Product__c);
        System.assertEquals(1.0,o.ChargeOrCredit__c);
    }
}