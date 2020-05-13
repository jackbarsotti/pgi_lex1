public with sharing class CountryUtil {

	public static Map<String, String> ZOOM_COUNTRY_MAP { get {
		if(ZOOM_COUNTRY_MAP == null) {
			ZOOM_COUNTRY_MAP = new Map<String, String>();
			for(Country__c country : [SELECT Id, Name, Zoom_Info_Pro_Name__c, Country_Territory_Code__c, Available_States_Provinces__c, Region__c
									  FROM Country__c]) {
				if(country.Zoom_Info_Pro_Name__c != null && country.Zoom_Info_Pro_Name__c != 'N/A') {
					ZOOM_COUNTRY_MAP.put(country.Zoom_Info_Pro_Name__c, country.Name);
					countryByName.put( country.Name, country);
				}
			}
		}
		return ZOOM_COUNTRY_MAP;
	} private set;}
	public static Map<String, Country__c> countryByName {get {
		if(countryByName == null) {
			countryByName = new Map<String, Country__c>();
			Map<String, String> zoomMap = ZOOM_COUNTRY_MAP;
		}
		return countryByName;
	} set;}
	public static String getCountryRegion(String Country) {
		// List<Country__c> countryList = [SELECT Id, Region__c, Name FROM Country__c WHERE Name =: country];
		Country__c c = countryByName.get(Country);
		if(c != null) {
			return c.Region__c;
		} 
		return '';
	}
}