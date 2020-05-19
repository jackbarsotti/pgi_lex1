public with sharing class AssignToMeQuickActionController {
    @AuraEnabled
    public static void updateRecord(String recordId){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        String objectAPIName = '';
        String keyPrefix = recordId.substring(0,3);
        for( Schema.SObjectType obj : schemaMap.Values() ){
            String prefix = obj.getDescribe().getKeyPrefix();
            if(prefix == keyPrefix){
                objectAPIName = obj.getDescribe().getName();
                break;
            }
        }
       
        if(objectAPIName == 'Financial_Request__c'){
           Financial_Request__c FinReqObj = [Select Id,Assigned_To__c from Financial_Request__c Where Id =:recordId];
            FinReqObj.Assigned_To__c =userinfo.getuserid();
            UPDATE FinReqObj; 
        }
        
    }
}