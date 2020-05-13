public without sharing class ProductSymptoms {

	public ProductSymptoms() {
		init();
	}

	public void init() {
		productFocusSymptomsMap = new Map<String, Case_Product_Focus_Symptom__c>();
		productToAreaOfFocusMap = new Map<String, Set<String>>();
		areaOfFocusToSymptomMap = new Map<String, Set<String>>();
		subSymptomMap = new Map<String, Set<String>>();
		productFocusSymptomsMap = new Map<String, Case_Product_Focus_Symptom__c>();
        for(Case_Product_Focus_Symptom__c cpfs: [SELECT Id, Area_of_Focus__c, Product__c, Sub_Symptom__c, Symptom__c FROM Case_Product_Focus_Symptom__c]) {
      		
            //The field of Area of Focus is dependent on Product 
            if(cpfs.Product__c != null) {
            	Set<String> areaOfFocusSet = productToAreaOfFocusMap.get(cpfs.Product__c) == null ? new Set<String>() : productToAreaOfFocusMap.get(cpfs.Product__c);
            	if(cpfs.Area_of_Focus__c != null) {
            		areaOfFocusSet.add(cpfs.Area_of_Focus__c);
            	}
            	productToAreaOfFocusMap.put(cpfs.Product__c, areaOfFocusSet);

            	Set<String> symptomSet = areaOfFocusToSymptomMap.get(cpfs.Product__c + cpfs.Area_of_Focus__c) == null ? new Set<String>() : areaOfFocusToSymptomMap.get(cpfs.Product__c + cpfs.Area_of_Focus__c);
            	if(cpfs.Symptom__c != null) {
		            symptomSet.add(cpfs.Symptom__c);
		        }
	            areaOfFocusToSymptomMap.put(cpfs.Product__c + cpfs.Area_of_Focus__c, symptomSet);
			            //The field of  Sub Symptom values to be unique based off of the entire selection not just the previous controlling field,
	            if(cpfs.Sub_Symptom__c != null) {
		            String subSymptomKey = cpfs.Product__c + cpfs.Symptom__c + cpfs.Area_of_Focus__c;
		            Set<String> subSymptomSet = subSymptomMap.get(subSymptomKey) == null ? new Set<String>() : subSymptomMap.get(subSymptomKey);
		            subSymptomSet.add(cpfs.Sub_Symptom__c);
		            subSymptomMap.put(subSymptomKey, subSymptomSet);
		            productFocusSymptomsMap.put(cpfs.Product__c, cpfs);
			    }
            }
            //The field of Main Symptom is dependent on Area of Focus 
        }
	}
	public Map<String, Object> getProducts() {
		return productFocusSymptomsMap;
	}
	public Map<String, Object> getAreaOfFocus() {
		return productToAreaOfFocusMap;
	}
	public Map<String, Object> getSymptoms() {
		return areaOfFocusToSymptomMap;
	}
	public Map<String, Object> getSubSymptoms() {
		return areaOfFocusToSymptomMap;
	}

    //The field of Area of Focus is dependent on Product 
    
    //The field of Main Symptom is dependent on Area of Focus 
    
    //The field of  Sub Symptom values to be unique based off of the entire selection not just the previous controlling field,
    
    
    private Map<String, Case_Product_Focus_Symptom__c> productFocusSymptomsMap {get; set;}
    private Map<String, Set<String>> productToAreaOfFocusMap {get; set;}
    private Map<String, Set<String>> areaOfFocusToSymptomMap {get; set;}
    private Map<String, Set<String>> subSymptomMap {get; set;}
	   
}