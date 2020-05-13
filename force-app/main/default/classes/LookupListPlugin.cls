public class LookupListPlugin implements Process.Plugin {
	public Process.PluginDescribeResult describe(){
		Process.PluginDescribeResult result = new Process.PluginDescribeResult();
		result.Name = 'LookupList';
		result.Description = 'Query a collection of Ids';
		result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>();
		result.inputParameters.add(new Process.PluginDescribeResult.InputParameter('Object',Process.PluginDescribeResult.ParameterType.STRING, true));
		result.inputParameters.add(new Process.PluginDescribeResult.InputParameter('List',Process.PluginDescribeResult.ParameterType.STRING, true));
		result.inputParameters.add(new Process.PluginDescribeResult.InputParameter('Field Criteria',Process.PluginDescribeResult.ParameterType.STRING, true));
		result.inputParameters.add(new Process.PluginDescribeResult.InputParameter('Add Criteria',Process.PluginDescribeResult.ParameterType.STRING, false));
		result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>();
		result.outputParameters.add(new Process.PluginDescribeResult.OutputParameter('List',Process.PluginDescribeResult.ParameterType.STRING));
		result.outputParameters.add(new Process.PluginDescribeResult.OutputParameter('Count',Process.PluginDescribeResult.ParameterType.INTEGER));

		return result;
	}
	
	private List<String> listItems = new List<String>();
	private String listString = '';
	private Integer idx = 0;
	
	public Process.PluginResult invoke(Process.PluginRequest request){
		String ids = (String) request.inputParameters.get('List');
		String[] idList = ids.split(',');
		String criteria = (String) request.inputParameters.get('Add Criteria');

        String query;
        if(criteria != null){
        	query = 'SELECT Id FROM ' + request.inputParameters.get('Object') + ' WHERE ' + request.inputParameters.get('Field Criteria') + ' IN :idList AND '+ criteria;
        }
        else{
        	query = 'SELECT Id FROM ' + request.inputParameters.get('Object') + ' WHERE ' + request.inputParameters.get('Field Criteria') + ' IN :idList';
        }
        system.debug('###query='+query);
        
        map<Id,SObject> recordMap = new map<Id,SObject>(Database.query(query));
        system.debug('###recordMap='+recordMap);

        //map results to source request order and return
        String results = '';
        for(Id recordId : recordMap.keySet()){
        	results += String.valueOf(recordId) + ',';
        }
      
		Map<String,Object> result = new Map<String,Object>();
		result.put('List', results);
		result.put('Count', recordMap.size());
		return new Process.PluginResult(result);
	}
}