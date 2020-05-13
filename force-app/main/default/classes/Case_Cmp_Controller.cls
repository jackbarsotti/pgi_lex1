public class Case_Cmp_Controller {

    public without sharing class wrappField{
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

    public without sharing class wrappOTERuleObjects{
        @AuraEnabled
        public Case_SLA_Exception_Rules__c oteMember;
        @AuraEnabled
        public List<Case_SLA_Exception_Rule_Conditions__c> oteRule;
        public wrappOTERuleObjects(Case_SLA_Exception_Rules__c oteMember , List<Case_SLA_Exception_Rule_Conditions__c> oteRule){
            this.oteMember = oteMember;
            this.oteRule = oteRule;
        }
    }
    
    public static Map<String, Schema.sObjectType> globalDescribe {get {
        if(globalDescribe == null) {
            globalDescribe = Schema.getGlobalDescribe();
        }
        return globalDescribe;
    }set;}

    /**
    @MethodName     : getSobjectFields
    @Param          : 
    @return         : list<wrappField>
    @Description    : get all Sobject name which user has access.
    **/
    @AuraEnabled(cacheable=true)
    public static List<wrappField> getALLFields(String objName){
        
        System.debug('objName>>>>>>>>>>>>> '+objName);
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
    @MethodName     : getRoleValues
    @Param          : 
    @return         : list<wrappField>
    @Description    : get all Sobject name which user has access.
    **/
    @AuraEnabled(cacheable=true)
    public static List<String> getRoleValues( ){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = OpportunityTeamMember.TeamMemberRole.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        options.add('--None--');
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;

    }

    /**
    @MethodName     : saveOppyTeamEngineRecords
    @Param          : oppyTeamEngine object as a String
    @return         : 
    @Description    : Updating and Saveing records.
    **/
    @AuraEnabled 
    public static String saveOppyTeamEngineRecords(String OTMember, String oppyTeamRule, List<Id> removedOTRuleIds){
        String msg;

        try { 
            OTMember = '[' + OTMember+']';
            Type listType = Type.forName('List<Case_SLA_Exception_Rules__c>'); 
            List<Case_SLA_Exception_Rules__c> objs = (List<Case_SLA_Exception_Rules__c>)JSON.deserialize(OTMember, listType);
            UPSERT objs;
            System.debug(OTMember);
            System.debug(oppyTeamRule);
            System.debug(removedOTRuleIds);
            System.debug(OTMember);

            List<Case_SLA_Exception_Rule_Conditions__c> objChilds = (List<Case_SLA_Exception_Rule_Conditions__c>)JSON.deserialize(oppyTeamRule, List<Case_SLA_Exception_Rule_Conditions__c>.class);
            for(Case_SLA_Exception_Rule_Conditions__c o : objChilds){
                if(String.isBlank(o.Id)){
                    o.put('Case_SLA_Exception_Rules__c',objs[0].Id);
                }
            }  
            UPSERT objChilds;
            
            System.debug('objChilds>>>>>> '+objChilds);

            
            if(!removedOTRuleIds.isEmpty()){
                DELETE [SELECT Id 
                        FROM Case_SLA_Exception_Rule_Conditions__c 
                        WHERE Id IN: removedOTRuleIds];
            }
            
          

            wrappOTERuleObjects objWrappOTEObj = new wrappOTERuleObjects(objs[0], objChilds);
            // System.debug('objWrappOTEObj>>>>>> '+objWrappOTEObj);
            return JSON.serialize(objWrappOTEObj);
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
            System.debug(e);
            //throw DML exception message
            throw new AuraHandledException(msg);
            
        } catch (Exception e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    @MethodName     : getOTERecords
    @Param          : recordId
    @return         : 
    @Description    : get record details.
    **/
    @AuraEnabled 
    public static String getOTERecords(String recordId){
        
        Case_SLA_Exception_Rules__c otMember = [SELECT Id,Name,Evaluation_Order__c,Rule_Order__c,
                                (SELECT Id,Name,Object_Name__c,Field_API_Name__c,Field_Label__c,Field_Name__c,Field_Operator__c,Field_Type__c,Field_Value__c,Line_Number__c
                                FROM Case_SLA_Exception_Rule_Conditions__r)
                                FROM Case_SLA_Exception_Rules__c
                                Where Id = :recordId];

        wrappOTERuleObjects objWrappOTEObj = new wrappOTERuleObjects(otMember, otMember.Case_SLA_Exception_Rule_Conditions__r);
        return JSON.serialize(objWrappOTEObj);
        
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
        Schema.SObjectType s = m.get('Case_SLA_Exception_Rules__c') ;
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
        DELETE [SELECT Id,Name FROM Case_SLA_Exception_Rules__c Where Id =: recordId];
    }
}