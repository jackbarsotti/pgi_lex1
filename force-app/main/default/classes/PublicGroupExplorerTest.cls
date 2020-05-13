@isTest
private class PublicGroupExplorerTest {
	static User testUser {get;set;}
	static Group testGroup {get;set;}
	static GroupMember testGroupMember {get;set;}
	
	@isTest static void test_method_one() {
		// setup test data
		Init();

		// start
		Test.startTest();

		// Setup the page and conroller
		PageReference pr = Page.PublicGroupExplorer;
        Test.setCurrentPage(pr);
        PublicGroupExplorer controller = new PublicGroupExplorer();

		List<User> users = PublicGroupExplorer.queryUsers();
		System.assert(!users.isEmpty());
		List<Group> groups = PublicGroupExplorer.queryAllRegularPublicGroups();
		System.assert(!groups.isEmpty());
		List<PublicGroupExplorer.UserGroupWrapper> usersByGroupId = PublicGroupExplorer.queryUsersByGroupId(testGroup.Id);
		System.assert(!usersByGroupId.isEmpty());
		List<Group> groupsByUserId = PublicGroupExplorer.queryGroupsByUserId(usersByGroupId[0].userId);

		// stop
		Test.stopTest();
	}

	static void Init() {
		testUser = PGITestUtilities.getTestUser();
		insert testUser;

    	testGroup = PGITestUtilities.getPGINABilling();
    	insert testGroup;

    	testGroupMember = PGITestUtilities.getPGINABillingmembers(testGroup, testUser);
    	insert testGroupMember;
    }
}