public with sharing class CaseTabViewerController {
    @AuraEnabled(cacheable=true)
    public static List<CaseTabViewer__c> getCaseTabViewRecords(){
        List<CaseTabViewer__c> caseTabViewerList = [SELECT Id, RecordType__c, Show_New_Comment__c, Tab_Count__c, Top_Count__c, Name 
                                                    FROM CaseTabViewer__c];
        System.debug('caseTabViewerList >>'+caseTabViewerList);
        return caseTabViewerList;
    }
    // public static CaseTabViewer__c getCaseTabViewRecords(String recordType,String objectName){
    //     System.debug('recordType>>'+recordType);
    //     System.debug('ObjectName>>'+ObjectName);
    //     System.debug('>> IN Side Apex >>>');
    //     RecordType caseRecordTypeName=new RecordType();
    //     caseRecordTypeName = [SELECT Name 
    //                           FROM RecordType 
    //                           WHERE Id =:recordType and sobjecttype =:objectName];
    //     System.debug('caseRecordTypeName>>'+caseRecordTypeName);

    //     CaseTabViewer__c caseTabViewerObj = [SELECT Tab_Count__c, Top_Count__c 
    //                                          FROM CaseTabViewer__c
    //                                          WHERE RecordType__c=:caseRecordTypeName.Name];
        
    //     System.debug('>> caseTabViewerObj >>'+caseTabViewerObj);
    //     if(caseTabViewerObj.Tab_Count__c!=null && caseTabViewerObj.Top_Count__c!=null){
    //         return caseTabViewerObj;
    //     }
    //     else{
    //         return null;
    //     }
        
    // }

   
       
    
}