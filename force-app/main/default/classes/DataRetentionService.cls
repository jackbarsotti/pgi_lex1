public class DataRetentionService {
	
	public class DataRetentionServiceException extends Exception {}
	private static Map<Id, List<FilterField__c>> filterFieldsByFilterObject {get {
		if(filterFieldsByFilterObject == null) {
			filterFieldsByFilterObject = new Map<Id, List<FilterField__c>>();
			List<FilterObject__c> foList = [SELECT Id, Object__c, (SELECT Id, Object_Name__c, FilterObject__c, Value__c, Field__c, Operator__c FROM FilterFields__r) FROM FilterObject__c];
			for(FilterObject__c fo: foList) {
				filterFieldsByFilterObject.put(fo.Id, fo.FilterFields__r);
			}
		}
        System.debug('filterFieldsByFilterObject--'+filterFieldsByFilterObject);
		return filterFieldsByFilterObject;
	} set;}
	//private static Set<Id> filterObjectIds {get; set;}
	
	public static void disassociateAccountRelatedCases(List<Account> accounts) {
		List<Case> updateCases = new List<Case>();
		for(Case updateCase : [SELECT Id, AccountId
				   			   FROM Case
					   		   WHERE AccountId IN :accounts]) {
                                   System.debug('updateCase in acc'+updateCase);
	   		updateCase.AccountId = null;
	   		updateCases.add(updateCase);
	   	}
	   	if(!updateCases.isEmpty()) {
	   		List<Database.SaveResult> drList = Database.update(updateCases, false);
			LoggerUtil.handleSaveResults('Error during disassociateAccountRelatedCases', drList);
	   	}
	}

	public static void disassociateContactRelatedCases(List<Contact> contacts) {
		List<Case> updateCases = new List<Case>();
		for(Case updateCase : [SELECT Id, ContactId
				   			   FROM Case
					   		   WHERE ContactId IN :contacts]) {
	   		updateCase.ContactId = null;
	   		updateCases.add(updateCase);
	   	}
	   	if(!updateCases.isEmpty()) {
	   		List<Database.SaveResult> drList = Database.update(updateCases, false);
			LoggerUtil.handleSaveResults('Error during disassociateContactRelatedCases', drList);
	   	}
	}

	public static void disassociateCaseAccounts(List<Case> cases) {
		System.debug('disassociateCaseAccounts: ' + cases);
		// AccountId
		for(Case retCase : cases) {
			retCase.AccountId = null;
		}
		List<Database.SaveResult> drList = Database.update(cases, false);
		LoggerUtil.handleSaveResults('Error during disassociateCaseAccounts', drList);
	}

	public static void disassociateCaseContacts(List<Case> cases) {
		System.debug('disassociateCaseContacts: ' + cases);
		// ContactId
		for(Case retCase : cases) {
			retCase.ContactId = null;
		}
		List<Database.SaveResult> drList = Database.update(cases, false);
		LoggerUtil.handleSaveResults('Error during disassociateCaseContacts', drList);
	}

	public static String buildRetentionQuery(Id filterObjectId) {
		List<FilterField__c> filterFields = filterFieldsByFilterObject.get(filterObjectId);
		return validateRetentionQuery(filterFields[0].Object_Name__c, filterFields);
	}
	private static String validateRetentionQuery(String filterObjectName, List<FilterField__c> fields) {
		String query = buildRetentionQuery(filterObjectName, fields);
         System.debug('query-->'+query);
		validateQuery(query);
		return query;
	}
	private static String buildRetentionQuery(String filterObjectName, Set<FilterField__c> fieldSet) {
		return buildRetentionQuery(filterObjectName, null, fieldSet);
	}
	private static String buildRetentionQuery(String filterObjectName, List<FilterField__c> fieldSet) {
		return buildRetentionQuery(filterObjectName, null, new Set<FilterField__c>(fieldSet));
	}
	private static String buildRetentionQuery(String filterObjectName, Id filterObjectId) {
		return buildRetentionQuery(filterObjectName, filterObjectId, null);
	}
	private static String buildRetentionQuery(String filterObjectName, Id filterObjectId, Set<FilterField__c> fieldSet) {
		String query = 'SELECT Id FROM ';
		if(fieldSet == null) {
			fieldSet = new Set<FilterField__c>();
		}
		if(filterObjectId != null && filterFieldsByFilterObject != null && filterFieldsByFilterObject.get(filterObjectId) != null) {
			fieldSet.addAll(filterFieldsByFilterObject.get(filterObjectId));
		} 
		if(!validObjectName(filterObjectName)) {
			throw new DataRetentionServiceException('No valid filter object [' + filterObjectName + '] initialized for this ID');
		} else { 
			query += filterObjectName;
			//BUILD WHERE CLAUSE
			System.debug('fieldSet<><>'+fieldSet);
			List<FilterField__c> fieldList = new List<FilterField__c>(fieldSet);
			if(fieldList == null || fieldList.size() == 0) {
				throw new DataRetentionServiceException('Must have at least 1 field filter to process');
			} else {
				query += ' WHERE ';
				for(Integer i = 0; i < fieldList.size(); i++) {
					FilterField__c ff = fieldList[i];
					
					if(i > 0) {
						query += ' AND ';
					}
					query += ff.Field__c;
					//TODO test and assert each of the criteria for each data type
					//handle the criteria based upon the numeric / text / date / date time filters - only applies to less / great / equal
					//top section are string values only -- easy
					//TODO - DATE TIME / DATE FIELDS should support "THIS_WEEK / etc"
					if (ff.Operator__c == 'Includes') {
						query += ' INCLUDES \'' + ff.Value__c + '\'';
					} else if (ff.Operator__c == 'Excludes') {
						query += ' EXCLUDES \'' + ff.Value__c + '\'';
					} else if (ff.Operator__c == 'Contains') {
						query += ' LIKE \'%' + ff.Value__c + '%\'';
					} else if (ff.Operator__c == 'Starts With') {
						query += ' LIKE \'' + ff.Value__c + '%\'';
					} else if (ff.Operator__c == 'Ends With') {
						query += ' LIKE \'%' + ff.Value__c + '\'';
					//these could be date / date time / integer / numeric
					} else if(ff.Operator__c == 'Equals') {
						query += ' = ' + convertStringToObject(filterObjectName, ff);	
					} else if (ff.Operator__c == 'Does Not Equal') {
						query += ' != ' + convertStringToObject(filterObjectName, ff);
					} else if (ff.Operator__c == 'Less Than') {
						query += ' < ' + convertStringToObject(filterObjectName, ff);
					} else if (ff.Operator__c == 'Greater Than') {
						query += ' > ' + convertStringToObject(filterObjectName, ff);
					} else if (ff.Operator__c == 'Less Than Or Equal') {
						query += ' <= ' + convertStringToObject(filterObjectName, ff);
					} else if (ff.Operator__c == 'Greater Than Or Equal') {
						query += ' >= ' + convertStringToObject(filterObjectName, ff);
					}
				}
			}
		} 
		if(!System.isBatch()) {
			query += ' LIMIT 1 ';
		}
		return query;
	}
	private static Object convertStringToObject(String objectName, FilterField__c ff){
		return convertStringToObject(objectName, ff.Field__c, ff.Value__c);
	}
    public static Map<String, Schema.sObjectType> globalDescribe {get {
        if(globalDescribe == null) {
            globalDescribe = Schema.getGlobalDescribe();
        }
        return globalDescribe;
    }set;}
    public static boolean validObjectName(String objName) {
        System.debug('objName===='+objName);
		if(globalDescribe.get(objName) == null) {
			return false;
		} else {
			return true;
		}
	}
//Validate Hidden Input On Save (Validate Field Name && Value can be parsed)
	public static boolean validField(String objName, String fieldName) {
		if(!validObjectName(objName)) {
			return false;
		}
		return globalDescribe.get(objName).getDescribe().fields.getMap().containsKey(fieldName);
	}
	//input object name, field name, value and it returns the field wrapped in a string if needed or not if it is numeric or date / date time
	private static Object convertStringToObject(String objectName, String fieldName, String value){

		if(!validField(objectName, fieldName)) {
			throw new DataRetentionServiceException('bad field [' + fieldName + '] for object: ' + objectName);
		}
		if(value.toUpperCase() == 'NULL') {
			return null;
		}
		String dataType = String.valueOf(globalDescribe.get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getType()).toUpperCase();
		System.debug(dataType);
		if(dataType == 'REFERENCE' ||  dataType == 'PICKLIST' ||
               dataType == 'STRING' || dataType == 'TEXTAREA' || dataType == 'MULTIPICKLIST' ||
               dataType == 'ID' || dataType == 'PHONE' || dataType == 'EMAIL' ||
               dataType == 'URL' || dataType == 'ADDRESS' || dataType == 'ENCRYPTEDSTRING'){
			return '\'' + value + '\'';
        } else if(dataType == 'BOOLEAN'){
       		return Boolean.valueOf(value);
       	} else if(dataType == 'DOUBLE' || dataType == 'CURRENCY' || dataType == 'PERCENT'){
        	return Double.valueOf(value);
        } else if(dataType == 'INTEGER'){
        	return Integer.valueOf(value);
        } else if(dataType == 'DATE'){
        	//TODO - fix validation for "TODAY, LAST N MONTHS, ETC"
        	try {
        		object returnValue = Date.valueOf(value);
        		return returnValue;	
        	} catch (Exception e) {
        		return value;
        	}
        } else if(dataType == 'DATETIME'){
        	Datetime dateTimeVar;
        	try {
        		dateTimeVar = Datetime.valueOfGMT(value);
        		//return dateTimeVar;
        	} catch (Exception e) {
        		try {
        			dateTimeVar = (DateTime)Date.parse(value);
        			//return dateTimeVar;
    			} catch (Exception seconderror) {
					return value;
    			}
    		}
    		return dateTimeVar.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        	//}
        	//try {
        	//	object returnValue = DateTime.valueOf(value);
        	//	return returnValue;	

        	//} catch (Exception e) {
        	//	return value;
        	//}
        } else if(dataType == 'TIME') {
        	throw new DataRetentionServiceException('Unsupported dataType' + dataType);
    	} else {
    		throw new DataRetentionServiceException('Unsupported dataType' + dataType);
    	}
	}
	public static Boolean validateQuery(String query) {
		if(!query.contains('LIMIT 1')) {
			query += ' LIMIT 1';
		}
		try {
		    Database.Query(query);
		    return true;
		}
		catch(QueryException ex) {
		    //Error handling
		    return false;
		}

		return false;
	}
	public static String validQuery(String filterObjectName, List<FilterField__c> fields) {
		if(fields.size() == 0) { return 'true'; }

		String query = validateRetentionQuery(filterObjectName, fields);
		try {
		    Database.Query(query);
		    return 'true';
		}
		catch(QueryException ex) {
		    //Error handling
		    return ex.getMessage() + ' QUERY: ' + query;
		}
		return 'query exception';
	}
	public class FilterObjectWrapper {
		public Boolean validQuery {get; set;}
		public String queryMessage {get; set;}
		public FilterObject__c filterObject {get; set;}
		public List<FilterField__c> filterFields {get; set;}
		//public List<FilterFieldWrapper> filterFieldWrapper {get; set;}
		public String query {get; set;}
		public FilterObjectWrapper(FilterObject__c filterObject, List<FilterField__c> filterFields) {
			this.validQuery = false;
			this.filterObject = filterObject;
			this.filterFields = filterFields;
			this.query = buildRetentionQuery(filterObject.Id, filterFields);
			this.validQuery = validateQuery(query);
			this.queryMessage = '';
			if(!this.validQuery) {
				try {
					Database.query(query);
				} catch (Exception e) {
					queryMessage = e.getMessage();
				}
			}
		}
	}

	private static PGi_ServiceCatalogValidatorUtility validator = new PGi_ServiceCatalogValidatorUtility();
	public static void validateFields(List<FilterField__c> filterFields){
		for(FilterField__c ff: filterFields) {
			String inputValidation = validator.validFieldInput(ff.Object_Name__c, ff.Field__c, ff.Value__c);
			if(inputValidation != 'true') {
				ff.addError(inputValidation);
			}
		}
	}
	
	//public static Map<Id, FilterObjectWrapper> validateFilters(Set<Id> filterObjectIds) {
	//	//TODO
	//	return null;
	//}
}