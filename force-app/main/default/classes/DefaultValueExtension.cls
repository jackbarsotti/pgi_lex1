public without sharing class DefaultValueExtension {
	public ApexPages.StandardController controller {get; set;}
    public static Map<String, Schema.sObjectType> gd {get {
        if(gd == null) {
            gd = Schema.getGlobalDescribe();
        }
        return gd;
    }set;}
    public static Schema.DescribeSObjectResult describeResult {get {
        if(describeResult == null) {
            describeResult = gd.get('Case').getDescribe();
        } 
        return describeResult;
    } set;}
    public static Map<String, Schema.SObjectField> fieldMap {get {
       if(fieldMap == null) {
        fieldMap =  describeResult.fields.getMap();
        }
        return fieldMap;
    } set;}
    public String ProductSymptoms {get {
        if(ProductSymptoms == null) {
           ProductSymptoms = JSON.serialize(new ProductSymptoms());
        }
        return ProductSymptoms;
    } set;}
	public List<String> requiredFields { get {
		requiredFields = new List<String>();
		Default_Value__c dv = (Default_Value__c)controller.getRecord();
    	String fieldName = dv.Field_API_Name__c;
		if(fieldMap.get(fieldName) != null && fieldMap.get(fieldName).getDescribe() != null && fieldMap.get(fieldName).getDescribe().getController() != null) {
			fieldName = fieldMap.get(fieldName).getDescribe().getController().getDescribe().getName();
			requiredFields.add(fieldName);
		}
		if(fieldMap.get(fieldName) != null && fieldMap.get(fieldName).getDescribe() != null && fieldMap.get(fieldName).getDescribe().getController() != null) {
			fieldName = fieldMap.get(fieldName).getDescribe().getController().getDescribe().getName();
			requiredFields.add(fieldName);
		}
		if(fieldMap.get(fieldName) != null && fieldMap.get(fieldName).getDescribe() != null && fieldMap.get(fieldName).getDescribe().getController() != null) {
			fieldName = fieldMap.get(fieldName).getDescribe().getController().getDescribe().getName();
			requiredFields.add(fieldName);
		}
		if(fieldMap.get(fieldName) != null && fieldMap.get(fieldName).getDescribe() != null && fieldMap.get(fieldName).getDescribe().getController() != null) {
			fieldName = fieldMap.get(fieldName).getDescribe().getController().getDescribe().getName();
			requiredFields.add(fieldName);
		}
		if(fieldMap.get(fieldName) != null && fieldMap.get(fieldName).getDescribe() != null && fieldMap.get(fieldName).getDescribe().getController() != null) {
			fieldName = fieldMap.get(fieldName).getDescribe().getController().getDescribe().getName();
			requiredFields.add(fieldName);
		}
		if(fieldMap.get(fieldName) != null && fieldMap.get(fieldName).getDescribe() != null && fieldMap.get(fieldName).getDescribe().getController() != null) {
			fieldName = fieldMap.get(fieldName).getDescribe().getController().getDescribe().getName();
			requiredFields.add(fieldName);
		}
		return reverseList(requiredFields);
	} set;}
	public List<String> reverseList(List<String> myList) {
		List<String> reversedList = new List<String>();
		if(myList.size() > 0) {
			for(integer i = myList.size() - 1; i > -1; i--) {
				reversedList.add(myList[i]);
			}
			return reversedList;
		} else {
			return myList;
		}
		
	}
	public DefaultValueExtension() {
	}
	public Case_Template__c ct {get; set;}
	public DefaultValueExtension(ApexPages.StandardController controller) {
		caseRecord = new Case();
		Id caseTemplateId = ApexPages.CurrentPage().getParameters().get('CF00N1B00000AxTaB_lkid');
		//Id caseTemplateId = 'a0O29000006FGaf';
        System.debug('The Value is'+caseTemplateId);
		Id dvId = ApexPages.CurrentPage().getParameters().get('Id');
		if(dvId != null) {
            System.debug('The DivId'+dvId);
			Default_Value__c dv = [SELECT Id, Case_Template__c, Case_Template__r.RecordType__c FROM Default_Value__c WHERE Id =: dvId];
			caseRecord.recordTypeId = dv.Case_Template__r.RecordType__c;
			caseTemplateId = dv.Case_Template__c;
		}
		System.debug(caseTemplateId);
		System.debug(caseRecord.recordTypeId);
		if(caseRecord.recordTypeId == null) {
			caseRecord.recordTypeId = '0121B000001hgNa';
		}
		if(caseTemplateId != null && caseRecord.recordTypeId != null) {
			ct = [SELECT Id, RecordType__c FROM Case_Template__c WHERE Id =: caseTemplateId];
			if(ct.RecordType__c != null) {
				caseRecord.recordTypeId = ct.RecordType__c;
			}
		} 
		
		this.controller = controller;
	}
	public List<SelectOption> caseFields {get{
		if(caseFields == null) {
			caseFields = new List<SelectOption>();
			Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap();
			for(String caseField: fieldMap.keyset()) {
				if(fieldMap.get(caseField).getDescribe().isCreateable()){
					caseFields.add(new SelectOption(caseField, fieldMap.get(caseField).getDescribe().getLabel() + ' - ' + caseField));
				}
			}
			caseFields = SortOptionList(caseFields);
		}
		return caseFields;
	} set;}
	public PageReference save() {
		saveRelatedRecords();
		Default_Value__c dv = (Default_Value__c)controller.getRecord();
		if(defaultValueByFieldName.get(dv.Field_API_Name__c) != null) {
			dv.put('Id', defaultValueByFieldName.get(dv.Field_API_Name__c).get('Id'));
		}
		try {
			dv.put('Value__c',(String)caseRecord.get(dv.Field_API_Name__c));
		} catch (exception e) {
			dv.put('Value__c',String.valueOf(caseRecord.get(dv.Field_API_Name__c)));
		}
		return controller.save();

	}
	public Map<String, Default_Value__c> defaultValueByFieldName { get{ 
		List<Default_Value__c> existingDefaultValues = Database.query('SELECT Id, Case_Template__c, Value__c, Field_API_Name__c, Case_Template__r.RecordType__c FROM Default_Value__c WHERE Case_Template__c =\'' + ct.Id + '\'');
		defaultValueByFieldName = new Map<String, Default_Value__c>();
		for(Default_Value__c dv: existingDefaultValues) {
			defaultValueByFieldName.put(dv.Field_API_Name__c, dv);
		}
		return defaultValueByFieldName;
	}set;}
	public void saveRelatedRecords() {
		List<Default_Value__c> defaultValuesToUpsert = new List<Default_Value__c>();
		
		Default_Value__c controllerDv = (Default_Value__c)controller.getRecord();
		for(String fieldName: caseRecord.getPopulatedFieldsAsMap().keySet()) {
			if(fieldName == 'RecordTypeId') {continue;}
			fieldName = fieldName.toLowerCase();
			Default_Value__c dv;
			object fieldValue = caseRecord.get(fieldName);

			if(fieldName == controllerDv.Field_API_Name__c) {
				dv = (Default_Value__c)controller.getRecord();
			}

			if(defaultValueByFieldName.get(fieldName) != null) {
				if(fieldName == controllerDv.Field_API_Name__c) {
					dv = (Default_Value__c)controller.getRecord();
					dv.put('Id', defaultValueByFieldName.get(fieldName).get('Id'));
				}
				dv = defaultValueByFieldName.get(fieldName);
			} else {
				dv = new Default_Value__c(Case_Template__c = ct.Id, Field_API_Name__c = fieldName);
			}

			try {
				dv.put('Value__c',(String)fieldValue);
			} catch (exception e) {
				dv.put('Value__c',String.valueOf(fieldValue));
			}
			defaultValuesToUpsert.add(dv);
		}
		upsert defaultValuesToUpsert;
	}
	public Case caseRecord {get; set;}

	public PageReference saveAndNew() {
		saveRelatedRecords();
		PageReference pr = ApexPages.CurrentPage();
		
		try {
			Default_Value__c dv = (Default_Value__c)controller.getRecord();
			if(defaultValueByFieldName.get(dv.Field_API_Name__c) != null) {
				dv.put('Id', defaultValueByFieldName.get(dv.Field_API_Name__c).get('Id'));
			}
			try {
				dv.put('Value__c',(String)caseRecord.get(dv.Field_API_Name__c));
			} catch (exception e) {
				dv.put('Value__c',String.valueOf(caseRecord.get(dv.Field_API_Name__c)));
			}
			upsert dv;
		} catch (exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
			return null;
		}
		pr.getParameters().put('Id', null);
		pr.setRedirect(true);
		return pr;
	}
	private static List<SelectOption> SortOptionList(List<SelectOption> ListToSort) {
        if(ListToSort == null || ListToSort.size() <= 1)
            return ListToSort;
            
        List<SelectOption> Less = new List<SelectOption>();
        List<SelectOption> Greater = new List<SelectOption>();
        integer pivot = ListToSort.size() / 2;
          
        // save the pivot and remove it from the list
        SelectOption pivotValue = ListToSort[pivot];
        ListToSort.remove(pivot);
        
        for(SelectOption x : ListToSort) {
            if(x.getLabel() <= pivotValue.getLabel())
            	Less.add(x);
            else if(x.getLabel() > pivotValue.getLabel()) 
            	Greater.add(x);   
        }
        List<SelectOption> returnList = new List<SelectOption> ();
        returnList.addAll(SortOptionList(Less));
        returnList.add(pivotValue);
        returnList.addAll(SortOptionList(Greater));
        return returnList; 
    }  
}