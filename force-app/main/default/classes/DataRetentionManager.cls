global with sharing class DataRetentionManager {
	public DataRetentionManager() { }

	// TODO
	//
    // TODO - clicking "Activate" should run a full save and validate on the generated SOQL query
    // TODO - Unit Tests
    // 
    // TODO *low priority* - REMOVE - hour glass or enable to pull all fields OR change lookup fields to (combobox)?
    // 


    // DONE
    // 
	

    @RemoteAction 
    global static List<String> determineFieldTypeOperatorValues(String objectName, String fieldName) {
        return ComparisonUtil.getFieldTypeOperatorValues(objectName, fieldName); 
        //return new List<String>{'hello'};
    }

	@RemoteAction
	global static void deleteFilter(String filterObjectId) {
		delete new FilterObject__c(Id = filterObjectId);
	}

	@RemoteAction
	global static void deleteFilterField(String filterFieldId) {
		try {
			delete new FilterField__c(Id = filterFieldId);
		}
		catch(Exception ex) {

		}
	}


	@RemoteAction
	global static String saveConfigPanel(FilterObject__c filterObject, List<FilterField__c> filterFields) {
        System.debug(filterObject);
        System.debug(filterFields);
        // TODO move this logic to Trigger for full coverage validation
        String isValidQuery = 'true';

        for(Integer i = filterFields.size() -1; i >= 0; i--){
            if(String.isBlank(filterFields[i].Field__c)) {
                filterFields.remove(i);
            }
        }
        // check if just saving the object name
        if(filterFields != null && !filterFields.isEmpty()) {
            isValidQuery = DataRetentionService.validQuery(filterObject.Object__c, filterFields);
            if(isValidQuery != 'true') return isValidQuery; 
        }

        update filterObject;
		try { 
            List<FilterField__c> upsertFilterFields = new List<FilterField__c>();
            for(FilterField__c filterField : filterFields) {
                FilterField__c newFilterField = new FilterField__c(FilterObject__c = filterObject.Id);
                if(String.isNotBlank(filterField.Id)) {
                    newFilterField.Id = filterField.Id;
                }
                
                newFilterField.Field__c = String.valueOf(filterField.Field__c);
                newFilterField.Operator__c = filterField.Operator__c;
                newFilterField.Value__c = filterField.Value__c;
                upsertFilterFields.add(newFilterField);
            }

			upsert upsertFilterFields; 
		}
		catch(Exception ex) {
            return ex.getMessage() + filterFields;
			// something todo handle
			// input field validator goes here
		}
        return isValidQuery;
	}

	@RemoteAction
    global static DataRetentionManager_Settings__c querySettings() {
    	return DataRetentionManager_Settings__c.getInstance('default');
    }

    @RemoteAction
    global static void updateSettings(Boolean enableManager) { // , Boolean enableHardDeletes
    	DataRetentionManager_Settings__c settings = DataRetentionManager_Settings__c.getInstance('default');
    	settings.Enable_DataRetentionManager__c = enableManager;
    	// settings.Enable_Hard_Deletes__c = enableHardDeletes;
    	update settings;
    }

	@RemoteAction
    global static List<FilterObject__c> queryFilterObjects() {
        List<FilterObject__c> filterObjects = new List<FilterObject__c>();

        for(FilterObject__c filterObject : [SELECT Id, Name, Description__c, Status__c, 
        										LastModifiedDate, Object__c, Process_Order__c
                         					FROM FilterObject__c
                         					ORDER BY Name DESC]) {
            filterObjects.add(filterObject); 
        }  

        return filterObjects;
    }

    @RemoteAction
    global static FilterObject__c querySelectedFilterObject(String filterObjectId) {
    	return [SELECT Id, Name, Description__c, Status__c, LastModifiedDate, Object__c, Process_Order__c,
    				// Criteria_Name__c, Criteria_for_Executing_Filter_Action__c, Conditions__c, Logic__c,
    			 (SELECT Id, FilterObject__c, Field__c, 
    			 	Operator__c, Type__c, Value__c
    			  FROM FilterFields__r)
    			FROM FilterObject__c
    			WHERE Id = :filterObjectId
    			LIMIT 1];
    }

    @RemoteAction
    global static String insertNewFilter(String filterName, String filterProcessOrder, String filterDescription) {
        
    	FilterObject__c insertNewFilter = new FilterObject__c(Name = filterName, Process_Order__c = flattenProcessOrder(filterProcessOrder), Description__c = filterDescription);
    	insert insertNewFilter;
    	return insertNewFilter.Id;
    }

    @RemoteAction
    global static FilterObject__c updateFilter(String filterId, String filterName, String filterProcessOrder, String filterDescription) {
        Integer processOrder = 0;
    	FilterObject__c updateFilter = new FilterObject__c(Id = filterId, Name = filterName, Process_Order__c = flattenProcessOrder(filterProcessOrder), Description__c = filterDescription);
    	update updateFilter;
    	return updateFilter;
    }

    private static Integer flattenProcessOrder(String filterProcessOrder) {
        Integer processOrder = 0;
        try {
            processOrder = Integer.valueOf(filterProcessOrder);
        } catch(Exception ex) {
            //
        }
        return processOrder;
    }

    @RemoteAction
    global static FilterObject__c updateFilterStatus(String filterId, String currentStatus) {
    	FilterObject__c updateFilter = new FilterObject__c(Id = filterId, Status__c = currentStatus == 'Active' ? 'Inactive' : 'Active');
    	update updateFilter;
    	return updateFilter;
    }
    //FUTURE shows other filters on same object
    @RemoteAction
    global static List<FilterObject__c> queryActiveFilterObjectsByObject(Id filterObjectId, String objectName) {
    	List<FilterObject__c> filterObjects = new List<FilterObject__c>();

        for(FilterObject__c filterObject : [SELECT Id, Name, Status__c, Object__c
                         					FROM FilterObject__c
                         					WHERE Object__c = :objectName
                         					AND Status__c = 'Active'
                                            AND Id !=: filterObjectId
                         					ORDER BY Name DESC]) {
            filterObjects.add(filterObject); 
        }  

        return filterObjects;
    }

    @RemoteAction
    global static List<String> describeObjects() {

        List<String> objects = new List<String>();

        for(Schema.SObjectType item1 : Schema.getGlobalDescribe().values()) {
            String name = item1.getDescribe().getName();
            // Exclude all the unwanted Sobjects e.g. CustomSettings, History, Share, Feed, ApexClass, Pages etc..
            if(!item1.getDescribe().isCustomSetting() && item1.getDescribe().getRecordTypeInfos().size() > 0 && item1.getDescribe().isCreateable() &&
                !name.containsignorecase('history') && !name.containsignorecase('tag') && !name.containsignorecase('share') && !name.containsignorecase('feed')) {
                // Name == API name "__c"
                objects.add(item1.getDescribe().getName());
                //item1.getDescribe().getLabel());
            }
        }

        // Asset doesn't come-up, so explicitly add this
        objects.add('Asset');
        objects.sort();

        return objects;
    }

    @RemoteAction
    global static List<String> describeRelatedFields(String selectedObject) {
        // TODO: filter by numeric data type
        // sObjects types to describe
        String[] types = new String[]{selectedObject};
        // describe call
        Schema.DescribeSObjectResult[] results = Schema.describeSObjects(types);
        // list of fields
        List<String> relatedFields = new List<String>();
        // loop through fields
        // TODO: 2 loops needed? Store in Session? Cache? 
        for(Schema.DescribeSObjectResult res : results) {
            relatedFields.addAll(res.fields.getMap().keyset());

            //for(String fieldName : res.fields.getMap().keyset()) {
            //    Schema.DisplayType fieldDataType = res.fields.getMap().get(fieldName).getDescribe().getType();

            //    relatedFields.add(fieldName);

            //    // Schema.DisplayType.Integer
            //    // Schema.DisplayType.Currency
            //    // Schema.DisplayType.Double
            //    // Schema.DisplayType.Percent
            //}
        }

        return relatedFields;
    }

 //   @RemoteAction
	//global static List<String> describeRelatedFields(String sObjectName) {
	//	Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sObjectName);
 //       sObject obj = targetType.newSObject();
 //       Schema.sObjectType sobjectType = obj.getSObjectType(); //grab the sobject that was passed
 //       Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe(); //describe the sobject
 //       Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap(); //get a Map of fields for the passed sobject
 //       for(Schema.SObjectField Field: fieldMap.values()){
 //           Schema.DescribeFieldResult f = field.getDescribe();
 //           if(f.getReferenceTo().size()>0){
 //               system.debug('Lookup field name = ' + f.getName());
 //               String originalname = f.getName();
 //               String modifiedfieldname = '';
 //               if(originalname.endsWithIgnoreCase('Id') == true){
 //                   modifiedfieldname = originalname.left(originalname.lastIndexOfIgnoreCase('Id'));
 //               }else if(originalname.endsWith('__c')== true){
 //                   modifiedfieldname = originalname.removeEnd('__c') +'__r';
 //               }
 //               relatedObjectMap.put(modifiedfieldname,f.getReferenceTo()[0]);
 //               relatedLabelMap.put(modifiedfieldname,f.getLabel().removeEnd(' ID'));
 //               objectMap.put(f.getReferenceTo()[0], new list<Schema.DescribeFieldResult>());
 //           }

 //           aggregatedOptionsList.add(new SelectOption(f.getName(),sObjectName+': '+f.getLabel()));
            
 //           setObjName.add(sObjectName);
 //           system.debug('--->'+sObjectName);
 //       }
	//}
}