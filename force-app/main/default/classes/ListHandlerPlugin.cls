public class ListHandlerPlugin implements Process.Plugin {
	public Process.PluginDescribeResult describe(){
		Process.PluginDescribeResult result = new Process.PluginDescribeResult();
		result.Name = 'ListHandler';
		result.Description = 'Creates list functionality from strings delimited by commas and return each item at a time with incremental index';
		result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>();
		result.inputParameters.add(new Process.PluginDescribeResult.InputParameter('List',Process.PluginDescribeResult.ParameterType.STRING, true));
		result.inputParameters.add(new Process.PluginDescribeResult.InputParameter('Index',Process.PluginDescribeResult.ParameterType.INTEGER, true));
		result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>();
		result.outputParameters.add(new Process.PluginDescribeResult.OutputParameter('ListItem',Process.PluginDescribeResult.ParameterType.STRING));
		result.outputParameters.add(new Process.PluginDescribeResult.OutputParameter('HasNext',Process.PluginDescribeResult.ParameterType.BOOLEAN));
		return result;
	}
	
	public Process.PluginResult invoke(Process.PluginRequest request){
		List<String> listItems = new List<String>();
		String listString = '';
		String lst = (String) request.inputParameters.get('List');
		Decimal idxDecimal = (Decimal) request.inputParameters.get('Index');
		Integer idx = Integer.valueOf(idxDecimal);
		Map<String,Object> result = new Map<String,Object>();
		if(!listString.equals(lst)){
			listItems = lst.split(',');
			listString = lst;
		}

		String item = null;
		Boolean hasNext = true;
		if(idx < listItems.size()){
			if(listItems.size() > 0){
				item = listItems[idx];
			}
			idx++;
			if(idx == listItems.size()){
				hasNext = false;
			}
		}
		else{
			hasNext = false;
		}
		
		result.put('ListItem', item);
		result.put('HasNext', hasNext);
		return new Process.PluginResult(result);
	}
}