/*
 * Test class for NewAccount apex class
*/
@isTest
public class NewAccountTest {

	@isTest
    public static void SystemAdminUnitTest() {
    	Account testAccount = new Account();
     	PageReference pageRef = Page.NewAccount;
        Test.setCurrentPage(pageRef);
     	ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
     	NewAccount controller = new NewAccount(sc);
     	PageReference result = controller.doInit();

     	// ran as system admin, confirm redirect to new Account standard page
     	System.assert(result.getUrl().contains('/001/e?nooverride=1'));
    }

    @isTest
    public static void ReadyTalkProfileUnitTest() {

    	// setup 'ReadyTalk Support' profile user
    	
    	User readyTalkUser = PGITestUtilities.readyTalkUser;
    	Test.startTest();
    	// run test as ReadyTalk profile
    	System.runAs(readyTalkUser) {
    		Account testAccount = new Account();
	     	PageReference pageRef = Page.NewAccount;
	        Test.setCurrentPage(pageRef);
	     	ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
	     	NewAccount controller = new NewAccount(sc);
	     	PageReference result = controller.doInit();

    		// ran as ReadyTalk profile user, confirm redirect returned null
    		System.assert(result == null);
    	}
    	Test.stopTest();
    }
}