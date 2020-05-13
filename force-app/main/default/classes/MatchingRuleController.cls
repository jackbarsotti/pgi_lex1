public class MatchingRuleController {
	
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

    public with sharing class wrappMatchingRuleObjects{
        @AuraEnabled
        public Matching_Rule__c matchingRule;
        @AuraEnabled
        public List<Matching_Rule_Criteria__c> matchigRuleCriteria;
        @AuraEnabled
        public List<Matching_Rule__c> childMatchingRuleRelatedRecords;
        
        public wrappMatchingRuleObjects(Matching_Rule__c matchingRule, List<Matching_Rule_Criteria__c> matchigRuleCriteria, List<Matching_Rule__c> childMatchingRuleRelatedRecords){
            this.matchingRule = matchingRule;
            this.matchigRuleCriteria = matchigRuleCriteria;
            this.childMatchingRuleRelatedRecords = childMatchingRuleRelatedRecords;
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
    @AuraEnabled(cacheable=true)
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
    @AuraEnabled(cacheable=true)
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

    /**
    @MethodName     : getRelatedChildObjects
    @Param          : objName
    @return         : List<Map<String,String>>
    @Description    : Here we are getting child object Name with relationship name.
    **/
    @AuraEnabled(cacheable=true)
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
    @MethodName     : saveMatchingRecords
    @Param          : MatchingRule and MatchingRuleCretiria object as a String
    @return         : 
    @Description    : Updating and Saveing records.
    **/
    @AuraEnabled 
    public static String saveMatchingRecords(String matchingRule, String matchigRuleCriteria, List<Id> removedRowMRIds){
        String msg;

        try { 
            matchingRule = '[' + matchingRule+']';
            Type listType = Type.forName('List<Matching_Rule__c>'); 
            List<Matching_Rule__c> objs = (List<Matching_Rule__c>)JSON.deserialize(matchingRule, listType);
            UPSERT objs;

            Type listType1 = Type.forName('List<Matching_Rule_Criteria__c>'); 
            List<Matching_Rule_Criteria__c> objChilds = (List<Matching_Rule_Criteria__c>)JSON.deserialize(matchigRuleCriteria, listType1);
            for(Matching_Rule_Criteria__c o : objChilds){
                if(String.isBlank(o.Id)){
                    o.put('Matching_Rule__c',objs[0].Id);
                }
            }  
            UPSERT objChilds;

            //Error handling as per ticket RT-52
            Map<String,String> statustoStatusMessageMap = MatchingService.validateRule(objs[0].Id);

            if(!removedRowMRIds.isEmpty()){
                DELETE [SELECT Id 
                        FROM Matching_Rule_Criteria__c 
                        WHERE Id IN: removedRowMRIds];
            }

            wrappMatchingRuleObjects objWrappMRObj = new wrappMatchingRuleObjects(objs[0],objChilds,getRelatedRecords(objs[0].Parent_Matching_Rule__c));
            return JSON.serialize(objWrappMRObj);
        }
        //catch block
        catch(DmlException e){
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
    }

    /**
    @MethodName     : getRecords
    @Param          : recordId
    @return         : 
    @Description    : get record details.
    **/
    @AuraEnabled 
    public static String getRecords(String recordId){
        
        List<Matching_Rule_Criteria__c> lstMRCreterisobj = new List<Matching_Rule_Criteria__c>();

        Matching_Rule__c objMRobj = [SELECT Id,Name,Evaluation_Order__c,Parent_Matching_Rule__c,Object_Name__c,Parent_Matching_Rule__r.Id,Parent_Matching_Rule__r.Name,Relationship_Name__c, Support_Text__c 
                                     FROM Matching_Rule__c 
                                     Where Id = :recordId];
        
        
        lstMRCreterisobj.addAll([SELECT Id, Name, Field_API_Name__c, Field_Value__c, Field_Type__c, Matching_Rule__c, Line_Number__c, Field_Operator__c 
                                 FROM Matching_Rule_Criteria__c 
                                 Where Matching_Rule__c = :recordId 
                                 ORDER By Field_API_Name__c ASC]);
        
        wrappMatchingRuleObjects objWrappMRObj = new wrappMatchingRuleObjects(objMRobj,lstMRCreterisobj,getRelatedRecords(objMRobj.Id));
        return JSON.serialize(objWrappMRObj);
        
    }

    /**
    @MethodName     : getRelatedRecords
    @Param          : recordId
    @return         : List<Matching_Rule__c>
    @Description    : get Related records.
    **/
    @AuraEnabled 
    public static List<Matching_Rule__c> getRelatedRecords(String recordId){
        return([SELECT Id,Name,Evaluation_Order__c,Object_Name__c,Parent_Matching_Rule__r.Id,Parent_Matching_Rule__r.Name,Relationship_Name__c, Support_Text__c 
                                    FROM Matching_Rule__c 
                                    Where Parent_Matching_Rule__c = :recordId]);
    }

    /**
    @MethodName     : saveMatchingRecords
    @Param          : MatchingRule and MatchingRuleCretiria object as a String
    @return         : 
    @Description    : Updating and Saveing records.
    **/
    @AuraEnabled 
    public static String getObjectKeyPrefix(){
        
        Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
        Schema.SObjectType s = m.get('Matching_Rule__c') ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        String keyPrefix = r.getKeyPrefix();
        
        return keyPrefix;
    }

    /**
    @MethodName     : deleteRecord
    @Param          : recordId
    @return         : 
    @Description    : Delete record.
    **/
    @AuraEnabled 
    public static void deleteRecord(String recordId){
        DELETE [SELECT Id,Name FROM Matching_Rule__c Where Id =: recordId];
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