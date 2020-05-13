public without sharing class PGi_ServiceCatalog_TriggerHandler {
	public String sObjectType;
	public List<sObject> newList;
	public PGi_ServiceCatalog_TriggerHandler(List<sObject> triggerNewList) {
		if(!triggerNewList.isEmpty()) {
			this.sObjectType = String.ValueOf(triggerNewList[0].getSObjectType());
			this.newList = triggerNewList;
		}
		validateRecords();
	}
	public void validateRecords() {
		PGi_ServiceCatalogValidatorUtility util = new PGi_ServiceCatalogValidatorUtility();
		if(sObjectType == 'PGi_ServiceCatalog_Category__c') {
			for(PGi_ServiceCatalog_Category__c record: (List<PGi_ServiceCatalog_Category__c>)newList) {
				if(!util.validateStaticResource('PGi_ServiceCatalogCategoryImages', record.Static_Resource_Image__c)) {
					record.addError('Unable to find static resource PGi_ServiceCatalogCategoryImages. Please ensure the zip file exists.');
				}
			}
		} else if (sObjectType == 'PGi_ServiceCatalog_Category_Option__c') {
			for(PGi_ServiceCatalog_Category_Option__c record: (List<PGi_ServiceCatalog_Category_Option__c>)newList) {
				if(!util.validObjectName(record.Object_API_Name__c)) {
					record.addError('Invalid sObject API ('+record.Object_API_Name__c+') name. Please ensure value is correct.');	
				}
			}
		} else if (sObjectType == 'PGi_ServiceCatalog_Section__c') {
			for(PGi_ServiceCatalog_Section__c record: (List<PGi_ServiceCatalog_Section__c>)newList) {
				if(!util.validFieldSet(record.Object_API_Name__c, record.Field_Set_API_Name__c)) {
					record.addError('Invalid field set API name. Please ensure the field set has been created on this object ' + record.Object_API_Name__c + '.');
				}
			}
		} else if (sObjectType == 'PGi_ServiceCatalog_Hidden_Input_Value__c') {
			for(PGi_ServiceCatalog_Hidden_Input_Value__c record: (List<PGi_ServiceCatalog_Hidden_Input_Value__c>)newList) {
				String validatorResponse = util.validFieldInput(record.Object_API_Name__c, record.Field_API_Name__c, record.Set_Value__c);
				if(validatorResponse != 'true') {
					record.addError(validatorResponse + ' --  Please Note: Only text values are supported for Hidden Input at this time. ');
				}
			}
		} else if (sObjectType == 'Default_Value__c') {
			for(Default_Value__c record: (List<Default_Value__c>)newList) {
				String validatorResponse = util.validFieldInput('Case', record.Field_API_Name__c, (String)record.get('Value__c'));
				if(validatorResponse != 'true') {
					record.addError(validatorResponse);
				}
			}
		}
	}
}