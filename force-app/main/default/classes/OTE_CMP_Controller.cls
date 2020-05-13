/**  
ClassName        : OTE_CMP_Controller
CreatedOn        : 17/July/2019
CreatededBy      : Vijay
Description      : 
LastModifiedOn   :
ModifiedBy       : 
*/
public class OTE_CMP_Controller {

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

    public with sharing class wrappOTERuleObjects{
        @AuraEnabled
        public OT_Member__c oteMember;
        @AuraEnabled
        public List<OT_Rule__c> oteRule;
        @AuraEnabled
        public List<Team_Member__c> teamMembers;
        
        public wrappOTERuleObjects(OT_Member__c oteMember , List<OT_Rule__c> oteRule, List<Team_Member__c> teamMembers){
            this.oteMember = oteMember;
            this.oteRule = oteRule;
            this.teamMembers = teamMembers;
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
    public static String saveOppyTeamEngineRecords(String OTMember, String oppyTeamRule, String teamMember, List<Id> removedOTRuleIds, List<Id> removedMemberIds){
        String msg;

        try { 
            OTMember = '[' + OTMember+']';
            Type listType = Type.forName('List<OT_Member__c>'); 
            List<OT_Member__c> objs = (List<OT_Member__c>)JSON.deserialize(OTMember, listType);
            UPSERT objs;
            
            System.debug('objs>>>>>> '+objs);

            Type ruleList = Type.forName('List<OT_Rule__c>'); 
            List<OT_Rule__c> objChilds = (List<OT_Rule__c>)JSON.deserialize(oppyTeamRule, ruleList);
            for(OT_Rule__c o : objChilds){
                if(String.isBlank(o.Id)){
                    o.put('OT_Member__c',objs[0].Id);
                }
            }  
            UPSERT objChilds;
            
            System.debug('objChilds>>>>>> '+objChilds);

            Type teamMemberList = Type.forName('List<Team_Member__c>'); 
            List<Team_Member__c> teamMembers = (List<Team_Member__c>)JSON.deserialize(teamMember, teamMemberList);
            for(Team_Member__c o : teamMembers){
                if(String.isBlank(o.Id)){
                    o.put('OT_Member__c',objs[0].Id);
                }
            }  

            if(!teamMembers.isEmpty()){
                UPSERT teamMembers;
            }
            
            System.debug('teamMembers>>>>>> '+teamMembers);
            
            if(!removedOTRuleIds.isEmpty()){
                DELETE [SELECT Id 
                        FROM OT_Rule__c 
                        WHERE Id IN: removedOTRuleIds];
            }
            
            if(!removedMemberIds.isEmpty()){
                DELETE [SELECT Id 
                        FROM Team_Member__c 
                        WHERE Id IN: removedMemberIds];
            }

            wrappOTERuleObjects objWrappOTEObj = new wrappOTERuleObjects(objs[0], objChilds, teamMembers);
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
            //throw DML exception message
            throw new AuraHandledException(msg);
            
        } catch (Exception e) {
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
        
        OT_Member__c otMember = [SELECT Id,Name,Evaluation_Order__c,Rule_Order__c,
                                (SELECT Id,Name,Object_Name__c,Field_API_Name__c,Field_Label__c,Field_Name__c,Field_Operator__c,Field_Type__c,Field_Value__c,Line_Number__c
                                FROM Opportunity_Team_Rules__r),
                                (SELECT Id,Name,User__c,Role__c,User__r.Name
                                FROM Team_Members__r)
                                FROM OT_Member__c
                                Where Id = :recordId];

        wrappOTERuleObjects objWrappOTEObj = new wrappOTERuleObjects(otMember, otMember.Opportunity_Team_Rules__r, otMember.Team_Members__r);
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
        Schema.SObjectType s = m.get('OT_Member__c') ;
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
        DELETE [SELECT Id,Name FROM OT_Member__c Where Id =: recordId];
    }

}