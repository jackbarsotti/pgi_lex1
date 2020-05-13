public without sharing class PGi_ServiceCatalogValidatorUtility {
	public PGi_ServiceCatalogValidatorUtility() {

	}

	//Validate Category Option (Object Name)
	public boolean validObjectName(String objName) {
		if(gd.get(objName) == null) {
			return false;
		} else {
			return true;
		}
	}
	//Validate Section On Save (Field Set Name)
	public boolean validFieldSet(String objName, String fieldSet) {
		if(!validObjectName(objName)) {
			return false;
		} else {
			for(Schema.FieldSet fs : gd.get(objName).getDescribe().fieldsets.getMap().values()) {
				if(fs.getName() == fieldSet) {
					return true;
				}
			}
		}
		return false;
	}
	//Validate Hidden Input On Save (Validate Field Name && Value can be parsed)
	public boolean validField(String objName, String fieldName) {
		if(!validObjectName(objName)) {
			return false;
		}
		return gd.get(objName).getDescribe().fields.getMap().containsKey(fieldName);
	}
	//TODO - doesn't take into account all field inputs - just attempts parsing - 
	//TODO - validate inputs actually work correctly - e.g. could specify 'ABC' for recordtypeId
	public String validFieldInput(String objName, String fieldName, String inputValue) {
		if(validField(objName, fieldName)) {
			try {
				sObject s = gd.get(objName).newSObject();
				String fieldType = String.ValueOf(gd.get(objName).getDescribe().fields.getMap().get(fieldName).getDescribe().getType());
            	if(fieldType.toUpperCase() == 'REFERENCE' ||  fieldType.toUpperCase() == 'PICKLIST' ||
	               fieldType.toUpperCase() == 'STRING' || fieldType.toUpperCase() == 'TEXTAREA' || fieldType.toUpperCase() == 'MULTIPICKLIST' ||
	               fieldType.toUpperCase() == 'ID' || fieldType.toUpperCase() == 'PHONE' || fieldType.toUpperCase() == 'EMAIL' ||
	               fieldType.toUpperCase() == 'URL' || fieldType.toUpperCase() == 'ADDRESS' || fieldType.toUpperCase() == 'ENCRYPTEDSTRING'){
	                    s.put(fieldName, inputValue);
                } else if(fieldType.toUpperCase() == 'BOOLEAN'){
                    s.put(fieldName, Boolean.valueOf(inputValue));
                } else if(fieldType.toUpperCase() == 'DOUBLE' || fieldType.toUpperCase() == 'CURRENCY' || fieldType.toUpperCase() == 'PERCENT'){
                    s.put(fieldName, Decimal.valueOf(inputValue));
                } else if(fieldType.toUpperCase() == 'INTEGER'){
                    s.put(fieldName, Integer.valueOf(inputValue));
                } else if(fieldType.toUpperCase() == 'DATE'){
                    Datetime Currenttime = Datetime.valueOf(inputValue);
                    String convertedtimeStr = Currenttime.format('MM/dd/yyyy');
                    inputValue = convertedtimeStr;
                    s.put(fieldName, Date.valueOf(inputValue));
                } else if(fieldType.toUpperCase() == 'DATETIME'){
                	Datetime Currenttime;
                	try {
                		Currenttime = Datetime.valueOfGMT(inputValue);
                	} catch (exception e) {
                		Currenttime = (DateTime)Date.parse(inputValue);
                	}
                    //String convertedtimeStr = Currenttime.format('MM/dd/yyyy hh:mm a');
                    //inputValue = convertedtimeStr;
                    s.put(fieldName, Currenttime);
               }
			} catch (exception e) {
				return 'Failed to parse value for input field.' + e.getMessage();
			}
		} else {
			return 'Invalid field name ' + fieldName + ' for sObject ' + objName;
		}
		return 'true';
	}

	public Map<String, Schema.SObjectType> gd { 
		get {
			if(gd == null) {
			gd = Schema.getGlobalDescribe();
			} 
			return gd;
		} set;
	}
	//Only validates the Static resource exists - doesn't validate image name
	public boolean validateStaticResource(String resourceName, String resourceFile) {
		List<StaticResource> srList = [SELECT Id, NamespacePrefix, Body, SystemModStamp FROM StaticResource WHERE Name =: resourceName];
		if(srList.isEmpty()) {
			return false;
		} 
		return true;
	}
}