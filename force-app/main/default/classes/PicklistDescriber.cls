public class PicklistDescriber {
    
	static final Pattern OPTION_PATTERN = Pattern.compile('<option.+?>(.+?)</option>'); 
	
	/**
		Describe a picklist field for a SobjectType, its given record type ID and the picklist field
		example usage : 
		Id recType1Id = [Select Id from RecordType Where SobjectType = 'Account' 
                                            AND DeveloperName like 'Record_Type_2'].Id;
		System.assertEquals(REC_TYPE_1_OPTIONS, PicklistDescriber.describe('Account', recType2Id, 'Industry'));
	*/
	public static Set<String> describe(String sobjectType, Id recordTypeId, String pickListFieldAPIName) {
		return parseOptions(
							new Map<String, String>	{
													 'sobjectType' => sobjectType,
													 'recordTypeId' => recordTypeId,
													 'pickListFieldName'=> pickListFieldAPIName
													}
							);
	}
	
	/*
		Internal method to parse the OPTIONS
	*/
	static Set<String> parseOptions(Map<String, String> params) {
		
		System.debug('params<>>>>>>>> '+params);
		Pagereference pr = Page.PicklistValuesforRT;
		
		// to handle development mode, if ON
		pr.getParameters().put('core.apexpages.devmode.url', '1');
		
		for (String key : params.keySet()) {
			pr.getParameters().put(key, params.get(key));	
		}
		
       
       String xmlContent;
        
       if (Test.IsRunningTest())
            xmlContent='UNIT.TEST';
       else
		 xmlContent = pr.getContent().toString();
       
		Matcher mchr = OPTION_PATTERN.matcher(xmlContent);
       
		Set<String> options = new Set<String>();
		
		while(mchr.find()) {
			options.add(mchr.group(1));
		}
      
		return options;
	}
}