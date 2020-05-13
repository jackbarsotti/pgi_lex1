@isTest
private class LookupListPluginTest {
	static testmethod void findOpportunities(){
		Test.startTest();
		Account testAccount = PGITestUtilities.getAccountDetails();
		insert testAccount;
		Account testAccount2 = PGITestUtilities.getAccountDetails();
		insert testAccount2;
		Opportunity testOpp = PGITestUtilities.getOpportunityDetails();
		testOpp.AccountId = testAccount.Id;
		insert testOpp;
		Opportunity testOpp2 = PGITestUtilities.getOpportunityDetails();
		testOpp2.AccountId = testAccount2.Id;
		insert testOpp2;
		LookupListPlugin plugin = new LookupListPlugin();
		Map<String, Object> inputParams = new Map<String, Object>();
		inputParams.put('Object', 'Opportunity');
		inputParams.put('List', testAccount.Id + ',' + testAccount2.Id);
		inputParams.put('Field Criteria', 'AccountId');
		inputParams.put('Add Criteria','IsClosed = False');
		
		Process.PluginRequest request = new Process.PluginRequest(inputParams);
		Process.PluginResult result = plugin.invoke(request);
		String resList = (String)result.outputParameters.get('List');
		Integer resCount = (Integer)result.outputParameters.get('Count');
		Process.PluginDescribeResult describe = plugin.describe();
		Test.stopTest();
		
		system.assert(resList != null);
		system.assert(resCount == 2);
		system.assertEquals(describe.OutputParameters.size(), 2);
	}
}