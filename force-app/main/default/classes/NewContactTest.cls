/*
 * Test class for NewContact apex class
*/
@isTest
public class NewContactTest {

	@isTest
    public static void NewContactUnitTest() {
    	Contact testContact = new Contact();
     	PageReference pageRef = Page.NewContact;
        Test.setCurrentPage(pageRef);
     	ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
     	NewContact controller = new NewContact(sc);
     	PageReference result = controller.doInit();

     	// ran as system admin, confirm redirect to new contact standard page
     	System.assert(result.getUrl().contains('/003/e?nooverride=1'));
    }

    @isTest
    public static void ReadyTalkProfileUnitTest() {

    	// setup 'ReadyTalk Support' profile user
    	Id readyTalkSupportProfileId = [SELECT Id FROM Profile WHERE Name = 'ReadyTalk Support'].Id;
    	User readyTalkUser = PGITestUtilities.readyTalkUser;
        
    	
    	Test.startTest();
    	// run test as ReadyTalk profile
    	System.runAs(readyTalkUser) {
    		Contact testContact = new Contact();
	     	PageReference pageRef = Page.NewContact;
	        Test.setCurrentPage(pageRef);
	     	ApexPages.StandardController sc = new ApexPages.StandardController(testContact);
	     	NewContact controller = new NewContact(sc);
	     	PageReference result = controller.doInit();

    		// ran as ReadyTalk profile user, confirm redirect returned null
    		System.assert(result == null);
    	}
    	Test.stopTest();
    }
}