/*
 * Test class for NewSubscription apex class
*/
@isTest
public class NewSubscriptionTest {

	@isTest
    public static void SystemAdminUnitTest() {
    	Subscription__c testSubscription = new Subscription__c();
     	PageReference pageRef = Page.NewSubscription;
        Test.setCurrentPage(pageRef);
     	ApexPages.StandardController sc = new ApexPages.StandardController(testSubscription);
     	NewSubscription controller = new NewSubscription(sc);
     	PageReference result = controller.doInit();

     	// ran as system admin
     	System.assert(result == null);
    }
}