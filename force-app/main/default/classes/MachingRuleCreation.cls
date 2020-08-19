/**  
ClassName        : MachingRuleCreation
CreatedOn        : 02/April/2019
CreatededBy      : Anup
Description      : 
LastModifiedOn   :
ModifiedBy       : 
*/

public class MachingRuleCreation {
    
    public with sharing class wrappField{
        @AuraEnabled
        public String  fieldApiName;
        @AuraEnabled
        public String fieldLabel;
        @AuraEnabled
        public String fieldType;
        
        public wrappField(String  fieldApiName, String fieldLabel,String fieldType){
            this.fieldApiName = fieldApiName;
            this.fieldLabel = fieldLabel;
            this.fieldType = fieldType;
            
        }
    }
    
    public with sharing class wrappObjects{
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String label;
        
        public wrappObjects(String  value, String label){
            this.value = value;
            this.label = label;
            
        }
    }
    
    public with sharing class wrappMatchingRuleObjects{
        @AuraEnabled
        public Matching_Rule__c matchingRule;
        @AuraEnabled
        public List<Matching_Rule_Criteria__c> matchigRuleCriteria;
        @AuraEnabled
        public List<Matching_Rule__c> childMatchingRulerelatedObjects;
        
        public wrappMatchingRuleObjects(Matching_Rule__c matchingRule, List<Matching_Rule_Criteria__c> matchigRuleCriteria, List<Matching_Rule__c> childMatchingRulerelatedObjects){
            this.matchingRule = matchingRule;
            this.matchigRuleCriteria = matchigRuleCriteria;
            this.childMatchingRulerelatedObjects = childMatchingRulerelatedObjects;
        }
    }
    
    public static Map<String, Schema.sObjectType> globalDescribe {get {
        if(globalDescribe == null) {
            globalDescribe = Schema.getGlobalDescribe();
        }
        return globalDescribe;
    }set;}
    
    /**
@MethodName     : getAllSobjects
@Param          : 
@return         : list<wrappersObjects>
@Description    : get all Sobject name which user has access.
**/
    @AuraEnabled
    public static String getallobjects(){
        List<wrappObjects> lstSobjects = new List<wrappObjects>();
        for(Schema.SObjectType obj : globalDescribe.values()){
            Schema.DescribeSObjectResult detail = obj.getDescribe();
            if(detail.isAccessible() && detail.isCreateable() && detail.isQueryable() && !detail.isCustomSetting() && detail.isSearchable() &&  detail.isUpdateable()) {
                lstSobjects.add(new wrappObjects(detail.getName(),detail.getLabel()));
            }   
        }
        return JSON.serialize(lstSobjects);
    }
    
    /**
@MethodName     : getSobjectFields
@Param          : 
@return         : list<wrappersObjects>
@Description    : get all Sobject name which user has access.
**/
    @AuraEnabled
    public static List<wrappField> getALLFields(String objName){
        List<wrappField> wrappfieldsList = new List<wrappField>();      
        Map<String, Schema.SObjectField> rootFldMap = globalDescribe.get(objName).getDescribe().fields.getMap();
        for(Schema.SObjectField sof : rootFldMap.values()){
            Schema.DescribeFieldResult dfr = sof.getDescribe();
            if(dfr.isAccessible() && dfr.getName() != 'Id' &&  dfr.getName() != 'IsDeleted' && dfr.getName() != 'RecordTypeId')
            {
                wrappfieldsList.add(new wrappField(dfr.getName(), dfr.label, String.valueOf(dfr.type)));                
            }
        }
        return wrappfieldsList;
    }
    
    @AuraEnabled 
    public static String createNewRecords(String matchingRule, String matchigRuleCriteria, List<Id> removeRowRecordIds){
        String msg = '';
        
        //if(!String.isBlank(recordId)){
        //    return(getMatchingrecordonload(recordId));
        //}
        //else{
            
            List<Matching_Rule__c> lstRelatedMRobjects = new List<Matching_Rule__c>();
            
            try {
                
                matchingRule = '[' + matchingRule+']';

                Type listType = Type.forName('List<Matching_Rule__c>'); 
                List<SObject> objs = (List<SObject>)JSON.deserialize(matchingRule, listType);
                
                UPSERT objs;

                //Error handling as per ticket RT-52
                //Map<String,String> statustoStatusMessageMap = MatchingService.validateRule(objs[0].Id);
                
                //to get parent matching rule Name separately 
                Matching_Rule__c objMRobj = [SELECT Id, Object_Name__c, Support_Text__c, Relationship_Name__c, Parent_Matching_Rule__r.Id,Parent_Matching_Rule__r.Name, Name 
                                             FROM Matching_Rule__c 
                                             Where Id = :objs[0].Id];
                
                //get related Matching records when MR inserted form parent MR 
                if(!String.isBlank(objMRobj.Parent_Matching_Rule__r.Id)){
                    lstRelatedMRobjects.addAll([SELECT Id,Name,IsActive__c,Evaluation_Order__c,Object_Name__c,Parent_Matching_Rule__r.Id,Parent_Matching_Rule__r.Name,Relationship_Name__c, Support_Text__c 
                                                FROM Matching_Rule__c Where Parent_Matching_Rule__c = :objMRobj.Parent_Matching_Rule__r.Id]);
                }
                
                //get related Matching records when Parent MR Edited 
                if(String.isBlank(objMRobj.Parent_Matching_Rule__r.Id) && !String.isBlank(objMRobj.Id)){
                    lstRelatedMRobjects.addAll([SELECT Id,Name,IsActive__c,Evaluation_Order__c,Object_Name__c,Parent_Matching_Rule__r.Id,Parent_Matching_Rule__r.Name,Relationship_Name__c, Support_Text__c 
                                                FROM Matching_Rule__c Where Parent_Matching_Rule__c = :objMRobj.Id]);
                }
                
                Type listType1 = Type.forName('List<Matching_Rule_Criteria__c>'); 
                List<SObject> objChilds = (List<SObject>)JSON.deserialize(matchigRuleCriteria, listType1);
                for(SObject o : objChilds){
                    if(String.isBlank(o.Id)){
                        o.put('Matching_Rule__c',objs[0].Id);
                    }
                }  
                UPSERT objChilds;
                
                if(!removeRowRecordIds.isEmpty()){
                    DELETE [SELECT Id 
                            FROM Matching_Rule_Criteria__c 
                            WHERE Id IN: removeRowRecordIds];
                }
                
                //Sorting for Matching Rule Creation
                Map<String, Matching_Rule_Criteria__c> matchingruleMap = new Map<String, Matching_Rule_Criteria__c>(); 
                List<String> sortThis = new List<String>();
                
                for(Matching_Rule_Criteria__c objMRCriteria : (List<Matching_Rule_Criteria__c>)objChilds)
                {
                    matchingruleMap.put(objMRCriteria.Field_API_Name__c, objMRCriteria); 
                    sortThis.add(objMRCriteria.Field_API_Name__c);
                }
                
                sortThis.sort(); 
                
                List<Matching_Rule_Criteria__c> nameSortedMatchingrule = new List<Matching_Rule_Criteria__c>();
                
                for(String s : sortThis)
                {
                    nameSortedMatchingrule.add(matchingruleMap.get(s));
                }
                
                List<Matching_Rule_Criteria__c> MatchingRuleCriteriaList = [SELECT Id, Field_API_Name__c, Field_Value__c
                                                                            FROM Matching_Rule_Criteria__c 
                                                                            Where Matching_Rule__c = :objs[0].Id ORDER by Field_API_Name__c ASC];
                
                wrappMatchingRuleObjects objWrappMRObj = new wrappMatchingRuleObjects(objMRobj,nameSortedMatchingrule,lstRelatedMRobjects);
                //String abc = JSON.serialize(objWrappMRObj);
                //wrappMatchingRuleObjects objWrappMRObj11 = (wrappMatchingRuleObjects)JSON.deserialize(abc, MachingRuleCreation.wrappMatchingRuleObjects.class);
                
                return JSON.serialize(objWrappMRObj);
                
            } catch(DmlException e){
                //Any type of Validation Rule error message, Required field missing error message, Trigger error message etc..
                //we can get from DmlException
                
                //Get All DML Messages
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    //Get Validation Rule & Trigger Error Messages
                    msg =+ e.getDmlMessage(i) +  '\n' ;
                }
                //throw DML exception message
                throw new AuraHandledException(msg);
                
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
                
            }
        //}
        
        
    }
    
    @AuraEnabled 
    public static String getMatchingrecordonload(String recordId){
        
        List<Matching_Rule_Criteria__c> lstMRCreterisobj = new List<Matching_Rule_Criteria__c>();
        List<Matching_Rule__c> lstRelatedMRobjects = new List<Matching_Rule__c>();

        Matching_Rule__c objMRobj = [SELECT Id,Name,IsActive__c,Evaluation_Order__c,Parent_Matching_Rule__c,Object_Name__c,Parent_Matching_Rule__r.Id,Parent_Matching_Rule__r.Name,Relationship_Name__c, Support_Text__c 
                                     FROM Matching_Rule__c 
                                     Where Id = :recordId];
        
        if(!String.isBlank(objMRobj.Id)){

            lstRelatedMRobjects.addAll([SELECT Id,Name,IsActive__c,Evaluation_Order__c,Object_Name__c,Parent_Matching_Rule__r.Id,Parent_Matching_Rule__r.Name,Relationship_Name__c, Support_Text__c 
                                        FROM Matching_Rule__c 
                                        Where Parent_Matching_Rule__c = :objMRobj.Id]);
        }
        
        lstMRCreterisobj.addAll([SELECT Id, Name, Field_API_Name__c, Field_Value__c, Field_Type__c, Matching_Rule__c, Line_Number__c, Field_Operator__c 
                                 FROM Matching_Rule_Criteria__c 
                                 Where Matching_Rule__c = :recordId 
                                 ORDER By Field_API_Name__c ASC]);
        
        wrappMatchingRuleObjects objWrappMRObj = new wrappMatchingRuleObjects(objMRobj,lstMRCreterisobj,lstRelatedMRobjects);
        return JSON.serialize(objWrappMRObj);
        
    }
    
    /**
@MethodName     : getRelatedChildObjects
@Param          : objName
@return         : List<Map<String,String>>
@Description    : Here we are getting child object Name with relationship name.
**/
    @AuraEnabled
    public static List<Map<String,String>> getRelatedChildObjects(String objName){

        List<Map<String,String>> childObjectsList = new List<Map<String,String>>();
        Schema.DescribeSObjectResult rootFldMap = Schema.getGlobalDescribe().get(objName).getDescribe();
        for (Schema.ChildRelationship childRel: rootFldMap.getChildRelationships()) {
            Schema.DescribeFieldResult FieldResult = childRel.getField().getDescribe();
            if(FieldResult.isAccessible() && FieldResult.isCreateable() && childRel.getRelationshipName() != null){
                Map<String, String> picklistValuesByLabel = new Map<String, String>();
                String label = childRel.getChildSObject().getDescribe().getLabel() +'('+ childRel.getRelationshipName() +')';
                picklistValuesByLabel.put('label',label);
                picklistValuesByLabel.put('value',childRel.getChildSObject().getDescribe().getName());
                picklistValuesByLabel.put('relationshipName',childRel.getRelationshipName());
                childObjectsList.add(picklistValuesByLabel);
            }
        }

        
        return childObjectsList;
    }
    
    
    /**
@MethodName     : deleteRecord
@Param          : recordId
@return         : Boolean
@Description    : 
**/
    @AuraEnabled //(cacheable=true)
    public static String deleteMatchingRuleRecord(String recordId){

        DELETE [SELECT Id,Name FROM Matching_Rule__c Where Id =: recordId];
        return getObjectKeyPrefix();
    }
    
    @AuraEnabled //(cacheable=true)
    public static String getObjectKeyPrefix(){
        
        Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
        Schema.SObjectType s = m.get('Matching_Rule__c') ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        String keyPrefix = r.getKeyPrefix();
        
        return keyPrefix;
    }
    
    /**
@MethodName     : getMatchingRuleCreteria
@Param          : recordId
@return         : List<Matching_Rule_Criteria__c>
@Description    : .
**/
    @AuraEnabled
    public static List<Matching_Rule_Criteria__c> getMatchingRuleCreteria(String recordId){

        return [SELECT Id, Name, Field_API_Name__c, Field_Value__c, Field_Type__c, Matching_Rule__c, Line_Number__c, Field_Operator__c 
                FROM Matching_Rule_Criteria__c 
                Where Matching_Rule__c = :recordId];
    }
    
}