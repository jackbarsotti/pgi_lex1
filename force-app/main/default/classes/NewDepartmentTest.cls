/*
 * Test class for NewDepartment apex class
*/
@isTest
public class NewDepartmentTest {

	@isTest
    public static void SystemAdminUnitTest() {
    	Department__c testDepartment = new Department__c();
     	PageReference pageRef = Page.NewDepartment;
        Test.setCurrentPage(pageRef);
     	ApexPages.StandardController sc = new ApexPages.StandardController(testDepartment);
     	NewDepartment controller = new NewDepartment(sc);
     	PageReference result = controller.doInit();

     	// ran as system admin
     	System.assert(result == null);
    }
}