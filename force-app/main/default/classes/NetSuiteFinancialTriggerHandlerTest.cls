/*
 * Test class for NetSuiteFinancialTriggerHandler
*/
@isTest
public class NetSuiteFinancialTriggerHandlerTest {

	@isTest
    public static void SystemAdminUnitTest() {
    	Account testAccount = new Account();
    	testAccount.Name = 'Acme';
    	insert testAccount;

    	NetSuite_Financial__c testNetSuiteFinancial = new NetSuite_Financial__c();
    	testNetSuiteFinancial.Account__c = testAccount.Id;
    	insert testNetSuiteFinancial;

    	update testNetSuiteFinancial;
    }
}