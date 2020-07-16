public with sharing class CaseCreateOverrideController {
    @AuraEnabled(cacheable=true)
    public static String getCaseFieldValues(String recordId, List<String> fieldAPINameList) {

        System.debug('fieldAPINameList: '+fieldAPINameList);
        System.debug('recordId: '+recordId);

        try{
            if(!fieldAPINameList.isEmpty() && !String.isBlank(recordId)){
                String querry ='SELECT '+String.join(fieldAPINameList,',')+' FROM Case WHERE Id = \''+recordId+'\'';
                System.debug('The Querry '+querry);
                Case currentRecord = Database.query('SELECT '+String.join(fieldAPINameList,',')+' FROM Case WHERE Id = \''+recordId+'\'');
                fieldInfoWrapper objWrapper = new fieldInfoWrapper(fieldAPINameList, currentRecord);
                return JSON.serialize(objWrapper);
            } else {
                return '[{"message":"There is no fields present in provided fieldset. Please add some fields","errorCode":"NO_FIELDS_EXIST"}]';
            }
        } catch(Exception e) {
            System.debug('The Exception '+e);
            return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
        }

    }
    
    public class fieldInfoWrapper {
        @AuraEnabled
        public List<String> fieldApiNames;
        @AuraEnabled
        public Case currentRecord;
        
        @TestVisible    
        public fieldInfoWrapper(List<String> fieldApiNames, Case currentRecord) {
            this.fieldApiNames = fieldApiNames;
            this.currentRecord = currentRecord;
        }
    }

    @AuraEnabled
    public static string createCase(String recordType){
        Set<String> ctvRtSet = new Set<String>();
        String recordTypeName;
        case caseObj = new Case();
        caseObj.RecordTypeId = recordType;
        List<CaseTabViewer__c> ctvList =  CaseTabViewer__c.getAll().values();
        for(CaseTabViewer__c c: ctvList) {
            ctvRtSet.add(c.RecordType__c);
        }
        if(recordType != null){
            recordTypeName =  Schema.SObjectType.Case.getRecordTypeInfosById().get(recordType).getName();
            if(ctvRtSet.contains(recordTypeName)){
                //caseObj.Auto_Generated_For_Case__c = true; 
            }
        }
        upsert caseObj;
        return caseObj.Id;
        
    }
    @AuraEnabled
    public static boolean updateCase(Case record){
         
        UPDATE record;
        return true;
    }
    @AuraEnabled
    public static List<Case_Template__c> getQuickCase(){
        // Map<String,String> apiNameToValueMAp = new Map<String,String>();
        List<Case_Template__c> caseTemplates = Database.query('SELECT Name, Name__c, (SELECT Field_API_Name__c, Value__c FROM Default_Values__r) FROM Case_Template__c');
        // if(!caseTemplates.isEmpty()){
        //     for(Case_Template__c ct: caseTemplates) { 
        //         for(Default_Value__c dv: ct.Default_Values__r) {
        //             String fieldName = dv.Field_API_Name__c;
        //             String inputValue = (String)dv.get('Value__c');
        //             apiNameToValueMAp.put(fieldName,inputValue);
        //         }
        //     }
        // }
        if(!caseTemplates.isEmpty()){
            return caseTemplates;
        }
        else{
            return null;
        }
        
    }

    @AuraEnabled(cacheable=true)
    public static List<RecordType> getRecordType() {
    return [SELECT Id, Name, DeveloperName, Description 
            FROM RecordType 
            WHERE SobjectType = 'Case'];   
    }
}