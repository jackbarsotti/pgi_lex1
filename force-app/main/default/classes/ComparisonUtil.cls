public class ComparisonUtil {
	public class ComparisonUtilException extends Exception {}

	//public enum EnumNumberDateFieldOperatorTypes {EQUALS, DOES_NOT_EQUAL, GREATER_THAN, GREATER_THAN_OR_EQUAL, LESS_THAN, LESS_THAN_OR_EQUAL, IS_NULL}
 	//public enum EnumStringFieldOperatorTypes {EQUALS, DOES_NOT_EQUAL, STARTS_WITH, ENDS_WITH, CONTAINS, IS_NULL}
 	//public enum EnumBooleanIdFieldOperatorTypes {EQUALS, DOES_NOT_EQUAL, IS_NULL}
    private static List<String> numberDateFieldOperatorTypes = new List<String>{'Equals', 'Does not equal', 'Greater than', 'Greater than or equal', 'Less than', 'Less than or equal'};
    private static List<String> stringFieldOperatorTypes = new List<String>{'Equals', 'Does not equal', 'Starts with', 'Ends with', 'Contains'};
    private static List<String> booleanIdFieldOperatorTypes = new List<String>{'Equals', 'Does not equal'};


    public static List<String> getFieldTypeOperatorValues(String objectName, String fieldName) {
        if(fieldName == 'field' && objectName == 'Object') {
            return stringFieldOperatorTypes;
        }
		if(!validField(objectName, fieldName)) {
			throw new ComparisonUtilException('bad field [' + fieldName + '] for object: ' + objectName);
		}

		String dataType = String.valueOf(globalDescribe.get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getType()).toUpperCase();

		System.debug(dataType);
		if(dataType == 'REFERENCE' ||  dataType == 'PICKLIST' ||
               dataType == 'STRING' || dataType == 'TEXTAREA' || dataType == 'MULTIPICKLIST' ||
               dataType == 'ID' || dataType == 'PHONE' || dataType == 'EMAIL' ||
               dataType == 'URL' || dataType == 'ADDRESS' || dataType == 'ENCRYPTEDSTRING'){
			return stringFieldOperatorTypes;
        } else if(dataType == 'BOOLEAN'){
       		return booleanIdFieldOperatorTypes;
       	} else if(dataType == 'DOUBLE' || dataType == 'CURRENCY' || dataType == 'PERCENT'){
        	return numberDateFieldOperatorTypes;
        } else if(dataType == 'INTEGER'){
        	return numberDateFieldOperatorTypes;
        } else if(dataType == 'DATE'){
        	//TODO - fix validation for "TODAY, LAST N MONTHS, ETC"
        	return numberDateFieldOperatorTypes;
        } else if(dataType == 'DATETIME'){
        	return numberDateFieldOperatorTypes;
        } else if(dataType == 'TIME') {
        	throw new ComparisonUtilException('Unsupported dataType' + dataType);
    	} else {
    		throw new ComparisonUtilException('Unsupported dataType' + dataType);
    	}

		return new List<String>();
	}

	public static Map<String, Schema.sObjectType> globalDescribe {get {
        if(globalDescribe == null) {
            globalDescribe = Schema.getGlobalDescribe();
        }
        return globalDescribe;
    }set;}


    public static boolean validObjectName(String objName) {
		if(globalDescribe.get(objName) == null) {
			return false;
		} else {
			return true;
		}
	}
	public static boolean validField(String objName, String fieldName) {
		if(!validObjectName(objName)) {
			return false;
		}
		return globalDescribe.get(objName).getDescribe().fields.getMap().containsKey(fieldName);
	}
}