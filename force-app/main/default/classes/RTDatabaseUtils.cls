public with sharing class RTDatabaseUtils {
    
    /**
     * Returns a comma separated list of all fields for the provided object
     * 
     */
    public static String getFieldListString(SObject o){
        String commaSeparatedFields = '';
        Schema.DescribeSObjectResult R = o.getSObjectType().getDescribe();
        Map<String, Schema.SObjectField> m = R.fields.getMap();
        for(String s : m.KeySet()){
            commaSeparatedFields+=s;
            commaSeparatedFields+=',';
        }
        if(commaSeparatedFields.length() > 1)
            commaSeparatedFields = commaSeparatedFields.substring(0, commaSeparatedFields.length()-1);
            
        return commaSeparatedFields;
    }
    
    /**
     * Returns a populated SObject
     */
    public static SObject getEntireSObject(SObject o, String id) {
        return getEntireSObject(o, id, '');
    }

    public static SObject getEntireSObject(SObject o, String id, String additionalFields) {
        return Database.query('select '+RTDatabaseUtils.getFieldListString(o)+additionalFields+' from '+o.getSObjectType().getDescribe().getName()+' where id = \''+id+'\'');
    }
    
    /**
     * Returns a list of populated SObjects
     * Careful: In combination with the getFieldList method, this may perform too many getDescribe calls
     */
    public static List<SObject> getSObjectList(SObject o, String whereClause) {
        return Database.query('select '+RTDatabaseUtils.getFieldListString(o)+' from '+o.getSObjectType().getDescribe().getName()+' '+whereClause); 
    }
    
    /**
     * Returns a list of populated SObjects
     * Safe to use when getDescribe calls are a concern
     */
    public static List<SObject> getSObjectList(String objectName, String fields, String whereClause) {
        return Database.query('select '+fields+' from '+objectName+' '+whereClause); 
    }
    
    /**
     * Returns a Map<String, SObject> that can be used to minimize queries
     */
    public static Map<String, SObject> getIdObjectMap(Map<String, SObject> m, List<SObject> objects) {
        for(SObject o : objects) {
            m.put(o.id, o);
        } 
        
        return m;
    }
        
    /**
     * Returns the respective object type name from the page id
     */
    public static String getObjectNameFromPageID(){        
        SObject sobj;
        for(String t : RTConfig.OBJECT_TO_CONTROLLER_MAPPING.keySet()) {
            try{
                sobj = Database.query('select id,name from '+t+' where id = \''+ApexPages.currentPage().getParameters().get('id')+'\'');
                return sobj.getSObjectType().getDescribe().getName();
            }
            catch(Exception e) {
                //Do nothing, this is not the correct object
                continue;
            }
        }
        
        return null;
    }
    
    /**
     * Returns true if the current user's role is System Administrator
     */
    public static boolean isAdministrator() {
        try {
            if(PGI_Utility.Profile != null && PGI_Utility.Profile.Name != null 
                && (PGI_Utility.Profile.Name.equals('ReadyTalk Business Admin')
                    || PGI_Utility.Profile.Name.equals('System Administrator')
                    || PGI_Utility.Profile.Name.equals('System Admin API Only')
                    || PGI_Utility.Profile.Name.equals('PGi Marketing User')
                    || PGI_Utility.Profile.Name.equals('PGi Sales Operations'))) {
                return true;
            }
        } catch(Exception e) {
            return false;
        }
      return false;
    }    
}