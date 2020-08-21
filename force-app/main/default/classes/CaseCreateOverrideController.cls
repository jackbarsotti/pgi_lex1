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
    public static boolean updateCase(Case record , boolean isAssignmentRule){
        if(isAssignmentRule){
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            record.setOptions(dmo);   
            System.debug('Testing123');
        }
        UPDATE record;
        return true;
    }
    @AuraEnabled
    public static void insertCaseComment(String caseCommentBody,String recordId){
            CaseComment caseComment = new CaseComment(CommentBody = caseCommentBody, ParentId = recordId);
            //caseComment.ParentId = cse.Id;                
            caseComment.CommentBody = caseCommentBody;
            insert caseComment;
    }
    // @AuraEnabled
    // public static List<AssignmentModel> describeAssignment(Id recordTypeId, string objectType){
    //     sobjectType = objectType;
    //    // system.debug('record type id ===>'+ recordTypeId);
    //     List<AssignmentModel> assignmentSections = new List<AssignmentModel>();
    //     string theRespBody = GetLayoutSchema(recordTypeId, objectType);
    //     Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(theRespBody);
    //     if(m.containsKey('saveOptions')){
    //        List<object > targetLayout = (List<object>) m.get('saveOptions');
    //         for(object sectionObject: targetLayout){
                
    //             Map<String,object> section = (Map<String,object>) sectionObject;
                
    //             AssignmentModel am = new AssignmentModel();
    //             am.isDisplayed = (boolean)section.get('isDisplayed');
    //             am.soapHeaderName = (string)section.get('soapHeaderName'); 
    //             am.label = (string)section.get('label'); 
    //             am.name = (string)section.get('name'); 
    //             am.defaultValue = (boolean)section.get('defaultValue'); 
    //             assignmentSections.add(am); 
    //         }
    //     }
         
    //     return assignmentSections;
    // }
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
    
    @AuraEnabled(cacheable=true)
    public static List<String> getRecordTypeDetail(string recordId) {
        System.debug('The Value Is');
        List<String> recTypeList = new List<String>();
        case objcase =[SELECT Id, RecordtypeId, RecordType.name FROM Case where Id =: recordId];
        recTypeList.add(objcase.RecordtypeId);
        recTypeList.add(objcase.RecordType.name);
        return recTypeList;
    }
    // public class AssignmentModel{
    //     @AuraEnabled
    //     public boolean isDisplayed {get; set;}
    //     @AuraEnabled
    //     public string soapHeaderName {get;set;}  
    //     @AuraEnabled      
    //     public string label {get;set;}
    //     @AuraEnabled
    //     public string name {get;set;}
    //     @AuraEnabled
    //     public boolean defaultValue {get; set;}
    //     @TestVisible    
    //     public AssignmentModel(boolean isDisplayed, string soapHeaderName, string label,string name,boolean defaultValue) {
    //         this.isDisplayed = isDisplayed;
    //         this.soapHeaderName = soapHeaderName;
    //         this.label = label;
    //         this.name = name;
    //         this.defaultValue = defaultValue;
    //     }
    // } 
}