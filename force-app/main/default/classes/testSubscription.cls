@isTest
private class testSubscription {
	
	@isTest static void test_method_one() {
    Test.startTest();
    PGITestUtilities.disableSalesWings();
    Test.stopTest();
    Subscription__c sub = MockSubscription.getNewSubscription();

    Subscription subscriptionRepo = new Subscription();
    Subscription__c queriedSub = subscriptionRepo.findById(sub.Id);
    System.assert(queriedSub != null);
	}
}