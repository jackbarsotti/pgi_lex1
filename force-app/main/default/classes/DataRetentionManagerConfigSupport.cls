public without sharing class DataRetentionManagerConfigSupport {
	private static DataRetentionManager_Settings__c testConfig = null;
    
    public static DataRetentionManager_Settings__c getDataRetentionManagerConfig() {
        
        if(Test.isRunningTest() && testConfig != null) return testConfig;
        
        DataRetentionManager_Settings__c theObject = DataRetentionManager_Settings__c.getInstance('default');
        
        if(theObject == null || Test.isRunningTest()) {
            
            theObject = new DataRetentionManager_Settings__c();
			theObject.Name = 'default'; 
            theObject.Enable_DataRetentionManager__c = true;
            theObject.Enable_Hard_Deletes__c = true; 
            
            if(!Test.isRunningTest()) Database.Insert(theObject);
            else testConfig = theObject;
        }
        return theObject;
    }
    
    public static Boolean dataRetentionManagerEnabled {
        get {
            return GetDataRetentionManagerConfig().Enable_DataRetentionManager__c;
        }
    }

    public static Boolean hardDeletesEnabled {
        get {
            return GetDataRetentionManagerConfig().Enable_Hard_Deletes__c;
        }
    }
}