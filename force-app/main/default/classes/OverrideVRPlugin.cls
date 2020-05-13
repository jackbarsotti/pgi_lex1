public class OverrideVRPlugin implements Process.Plugin{
	public Process.PluginDescribeResult describe(){
		Process.PluginDescribeResult result = new Process.PluginDescribeResult();
		result.Name = 'OverrideVR';
		result.Description = 'Update Override Validation Rules Flag on system mode';
		result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>();
		result.inputParameters.add(new Process.PluginDescribeResult.InputParameter('UserId',Process.PluginDescribeResult.ParameterType.STRING, true));
		result.inputParameters.add(new Process.PluginDescribeResult.InputParameter('Flag Value',Process.PluginDescribeResult.ParameterType.BOOLEAN, true));
		result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>();
		result.outputParameters.add(new Process.PluginDescribeResult.OutputParameter('Original Flag Value',Process.PluginDescribeResult.ParameterType.BOOLEAN));
		return result;
	}
	
	public Process.PluginResult invoke(Process.PluginRequest request){
		String userId = (String) request.inputParameters.get('UserId');
		Boolean flag = (Boolean) request.inputParameters.get('Flag Value');
		Boolean oriFlag;
		
		List<User> userObj = [SELECT Override_Validation_Rules__c FROM User WHERE Id =: userId];
		if(userObj != null && userObj.size()>0){
			oriFlag = userObj[0].Override_Validation_Rules__c;
		}
		
		User userToUpdate = new User();
		userToUpdate.Id = userId;
		userToUpdate.Override_Validation_Rules__c = flag;
		update userToUpdate;	
      
		Map<String,Object> result = new Map<String,Object>();
		result.put('Original Flag Value', oriFlag);
		return new Process.PluginResult(result);
	}
}