/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class CeligoTestCreditMemoTotal {

  @isTest static void myUnitTest() {
        NetSuite_Financial__c credit = new NetSuite_Financial__c();
        Account a = MockAccount.getNewAccount();
        credit.Subtotal__c = 1.25;
        credit.Total__c = 1.50;
        credit.Shipping_Total__c = 0.25;
        credit.Name = 'Test Credit';
        credit.Type__c = 'Credit Memo';
        credit.Account__c = a.id;
        
        NetSuite_Financial__c invoice = new NetSuite_Financial__c();
        invoice.Subtotal__c = 2.00;
        invoice.Total__c = 2.50;
        invoice.Name = 'Test Invoice';
        invoice.Type__c = 'Invoice';
        invoice.Account__c = a.id;
        
        insert credit;
        insert invoice;
        
      system.debug('idd>>'+credit.id);
        NetSuite_Financial__c finCredit = [SELECT Id, Subtotal__c, Total__c 
                                           FROM NetSuite_Financial__c 
                                           WHERE ID = :credit.Id];
        NetSuite_Financial__c finInvoice = [SELECT Id, Subtotal__c, Total__c 
                                            FROM NetSuite_Financial__c 
                                            WHERE ID = :invoice.Id];
        
        System.assertEquals(finCredit.Subtotal__c, -1.25);
        System.assertEquals(finCredit.Total__c, -1.50);
        System.assertEquals(finInvoice.Subtotal__c, 2.00);
        System.assertEquals(finInvoice.Total__c, 2.50);
        
    }
}