public class AssignToMeLEXController {
    
    @AuraEnabled
    public static void updateRecord(String recordId, String objectName){
        
        // Case: AssignToMe QuickAction 
        if(objectName == 'Case'){
            Case caseObj = [SELECT Id, Assigned_To__c FROM Case WHERE Id =:recordId];
            caseObj.Assigned_To__c =userinfo.getuserid();
            UPDATE caseObj;
        }
        // Financial Request: AssignToMe QuickAction 
        else if(objectName == 'Financial_Request__c'){
            Financial_Request__c finReqObj = [SELECT Id, Assigned_To__c FROM Financial_Request__c WHERE Id =:recordId];
            finReqObj.Assigned_To__c =userinfo.getuserid();
            UPDATE finReqObj; 
        }
        // Request for Change: AssignToMe QuickAction 
        else if(objectName == 'Request_for_Change__c'){
            Request_for_Change__c objRFC = [SELECT Id, Assigned_To__c FROM Request_for_Change__c WHERE Id =:recordId];
            objRFC.Assigned_To__c =userinfo.getuserid();
            UPDATE objRFC; 
        }
    }
}