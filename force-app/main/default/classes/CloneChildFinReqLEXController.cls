public class CloneChildFinReqLEXController {
    @AuraEnabled
   public static String cloneAnySobjet(String recordId, String objectName){
        
       Set <String> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().keySet();
        String soqlQuery = 'SELECT ' ; 
        for (String s :fieldMap ){
            if(schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(s).getDescribe().isAccessible()){
                soqlQuery +=  + s+',';
            }
        }
        soqlQuery =  soqlQuery.removeEnd(',');
        soqlQuery += ' FROM ' +objectName +' WHERE ID = \'' + recordId +'\'' ;
        System.debug('soqlQuery'+soqlQuery);
        Financial_Request__c parentFinReqRec= Database.query(soqlQuery);
        Financial_Request__c clondedFinReqRec= parentFinReqRec.clone(false, false, false, false);
        clondedFinReqRec.Related_FinReq__c=recordId;
        try{
            insert clondedFinReqRec ;
            return clondedFinReqRec.id ;
        }catch(Exception e){
            return '' ;
        }
        
    }

}