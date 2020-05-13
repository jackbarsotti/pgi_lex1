@isTest
private class OverrideVRPluginTest {
	static testmethod void loopOpportunities(){
		Test.startTest();
		User u = PGITestUtilities.getTestUser();
        u.EmployeeNumber='12345';
		insert u;
		u.Override_Validation_Rules__c = false;
		update u;
		OverrideVRPlugin plugin = new OverrideVRPlugin();
		Map<String, Object> inputParams = new Map<String, Object>();
		inputParams.put('UserId', String.valueOf(u.Id));
		inputParams.put('Flag Value', true);
		
		Process.PluginRequest request = new Process.PluginRequest(inputParams);
		Process.PluginResult result = plugin.invoke(request);
		Boolean originalFlag = (Boolean)result.outputParameters.get('Original Flag Value');
		Process.PluginDescribeResult describe = plugin.describe();
		Test.stopTest();
		
		system.assertEquals(originalFlag, false);
		system.assertEquals(describe.OutputParameters.size(), 1);
	}
}