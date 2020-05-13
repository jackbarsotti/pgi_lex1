@isTest
private class ListHandlerPluginTest {
	static testmethod void loopOpportunities(){
		Test.startTest();
		Opportunity testOpp = PGITestUtilities.getOpportunityDetails();
		insert testOpp;
		Opportunity testOpp2 = PGITestUtilities.getOpportunityDetails();
		insert testOpp2;
		ListHandlerPlugin plugin = new ListHandlerPlugin();
		Map<String, Object> inputParams = new Map<String, Object>();
		inputParams.put('Index', 0);
		inputParams.put('List', testOpp.Id + ',' + testOpp2.Id);
		
		Process.PluginRequest request = new Process.PluginRequest(inputParams);
		Process.PluginResult result = plugin.invoke(request);
		String listItem = (String)result.outputParameters.get('ListItem');
		Boolean hasNext = (Boolean)result.outputParameters.get('HasNext');
		Process.PluginDescribeResult describe = plugin.describe();
		Test.stopTest();
		
		system.assertEquals(listItem, String.valueOf(testOpp.Id));
		system.assertEquals(hasNext, true);
		system.assertEquals(describe.OutputParameters.size(), 2);
	}
}