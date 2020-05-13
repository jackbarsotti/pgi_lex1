/**  
ClassName        : MatchingService
CreatedOn        : 02/April/2019
CreatededBy      : Anup
Description      : 3/Aril/ 2019
LastModifiedOn   :
ModifiedBy       : 
*/

public class MatchingService {
    private static List<Matching_Rule__c> updateMatchingRuleOnErrorList; // it will store matching rule records  which has error.
    //private static map<String, String> ErrorInQueryFormation = new map<String, String>();
    @AuraEnabled
    public static String processRecord(String objName, String recordId){
        
        updateMatchingRuleOnErrorList = new List<Matching_Rule__c>();
        
        List<Matching_Rule__c> MachingRulesList = [SELECT ID, Name, Evaluation_Order__c, Object_Name__c, Parent_Matching_Rule__c, Relationship_Name__c, Support_Text__c, Status__c, Status_Message__c,
                                                   (SELECT ID, Field_API_Name__c, Field_Type__c, Field_Value__c, Line_Number__c, Field_Operator__c
                                                    FROM Matching_Rule_Criterias__r),
                                                   (SELECT ID, Name, Evaluation_Order__c, Object_Name__c, Parent_Matching_Rule__c, Relationship_Name__c, Support_Text__c, Status__c, Status_Message__c
                                                    FROM Matching_Rules__r)
                                                   FROM Matching_Rule__c
                                                   WHERE Object_Name__c =: objName];
        //query matching rule inside the new object
        Map<String, List<String>> fieldsListByObject = new Map<String, List<String>>();
        
        Map<Id, Id> parentIdByChildId = new  Map<Id, ID>();
        for(Matching_Rule__c oMR : MachingRulesList){
            for(Matching_Rule__c childMatchingRule : oMR.Matching_Rules__r){
                parentIdByChildId.put( childMatchingRule.Id , oMR.Id);
                System.debug('child rule-->'+childMatchingRule.Id);
            }
        }
        Map<Id, List<Matching_Rule_Criteria__c>> childRuleCriteriaByMachingRuleID  = new Map<Id, List<Matching_Rule_Criteria__c>>();
        for(Matching_Rule__c childMatchingRule : [SELECT ID, Name, Evaluation_Order__c, Object_Name__c, Parent_Matching_Rule__c, Relationship_Name__c, Support_Text__c, Status__c, Status_Message__c,
                                                  (SELECT ID, Field_API_Name__c, Field_Type__c, Field_Value__c, Line_Number__c, Field_Operator__c
                                                   FROM Matching_Rule_Criterias__r)                                                   
                                                  FROM Matching_Rule__c
                                                  WHERE ID =: parentIdByChildId.keySet() ])
        {
            for(Matching_Rule_Criteria__c rule : childMatchingRule.Matching_Rule_Criterias__r){
                if(!childRuleCriteriaByMachingRuleID.containsKey(childMatchingRule.Id)){
                    childRuleCriteriaByMachingRuleID.put(childMatchingRule.Id, new List<Matching_Rule_Criteria__c>());
                }
                childRuleCriteriaByMachingRuleID.get(childMatchingRule.Id).add(rule);
                
            }            
        }
        //ChildMatching Rules 
        String QueryStrng = formQueryString(MachingRulesList, objName, childRuleCriteriaByMachingRuleID);
         System.debug('inside matching  service '+QueryStrng);
        List<Sobject> sobjectList = new List<Sobject>();
        try{ 
            sobjectList = Database.query(QueryStrng);
        }catch(Exception e){
            
            for(Matching_Rule__c objMatchingRule : MachingRulesList){
                objMatchingRule.Status__c = 'ERROR';
                objMatchingRule.Status_Message__c = e.getMessage();
                updateMatchingRuleOnErrorList.add(objMatchingRule);
            }
            //UPDATE updateMatchingRuleOnErrorList;
        }
        System.debug('sobjectList>>>>>>>>>>>>>>>>>>>> '+sobjectList);
        System.debug('MachingRulesList>>>>>>>>>>>>>>>>>>>> '+MachingRulesList);
        System.debug('childRuleCriteriaByMachingRuleID>>>>>>>>>>>>>>>>>>>> '+childRuleCriteriaByMachingRuleID);
        // using this query we will get those records which match the Rule.
        Map<Id, List<WrapperResult>> MatchedRuleByRecordId = matchRecordsWithRules(sobjectList, MachingRulesList, childRuleCriteriaByMachingRuleID);
       // Map<ID,List<Matching_Rule__c>> matchingRuleListByRecId = matchRecordsWithRules(sobjectList, MachingRulesList, childRuleCriteriaByMachingRuleID);
        System.debug('MatchedRuleByRecordId>>>>>>>>>>>>>>>>>>>> '+MatchedRuleByRecordId);
        return prepareRichTExtValue(MatchedRuleByRecordId);
        
        
    }
    public class WrapperResult{
        Matching_Rule__c parentMatchingRule;
        List<wrapperChildMatch> matchedChildRecList;
        
        public WrapperResult(Matching_Rule__c parentMatchingRule, List<wrapperChildMatch> matchedChildRecList){
            this.parentMatchingRule = parentMatchingRule;
            this.matchedChildRecList = matchedChildRecList; 
        }
    }

    public class WrapperChildMatch{
        public Matching_Rule__c childMatchingRule;
        public List<Sobject> recordsMatchedList;
        public List<Sobject> recordsNotMatchedList;
        
        public WrapperChildMatch(Matching_Rule__c childMatchingRule, List<Sobject> recordsMatchedList, List<Sobject> recordsNotMatchedList){
            this.childMatchingRule = childMatchingRule;
            this.recordsMatchedList = recordsMatchedList;
            this.recordsNotMatchedList = recordsNotMatchedList;
        }
    }
   
    private static String prepareRichTExtValue( Map<Id, List<WrapperResult>> MatchedRuleByRecordId){
        Persona_Helper_Settings__c personaHelper = Persona_Helper_Settings__c.getInstance(UserInfo.getuserid()); 
        Boolean isDebugOn = personaHelper.Debug_Mode__c;
        String text = '';
        for(ID recID : MatchedRuleByRecordId.keySet()){
            for(WrapperResult objWrapRes : MatchedRuleByRecordId.get(recID)){
                Matching_Rule__c matchingRule = objWrapRes.parentMatchingRule;
                String childSupportText = '';
                if(!objWrapRes.matchedChildRecList.isEmpty()){
                    childSupportText = getChildMachingRuleSupportText(objWrapRes.matchedChildRecList);
                }
                if(childSupportText != null){
                    String supporttext = matchingRule.Support_Text__c == null ? '' : matchingRule.Support_Text__c;
                    text += isDebugOn ? recID +' '+ supporttext : supporttext + '<br/>';
                    text += childSupportText;
                }
            }
        }
        return text; 
    }
    private static String getChildMachingRuleSupportText(List<wrapperChildMatch> matchedChildRecList){
        // need to show only support text when all child records are matched 
        // to display the parent rules / child rules text, it should match all of the matching rules in the hierarchy.
        // If the contact matching rule does not match the contacts on an account, none of the help text should display.
        Boolean dispalyHelpText = true;
        String childSupportText = '';
        for(WrapperChildMatch objChildRule : matchedChildRecList){
            if(dispalyHelpText && !objChildRule.recordsNotMatchedList.isEmpty()){
                dispalyHelpText = false;
                childSupportText = null;
            }
            if(!objChildRule.recordsMatchedList.isEmpty() && dispalyHelpText){
                String childRulesupporttext = objChildRule.childMatchingRule.Support_Text__c == null ? '' : objChildRule.childMatchingRule.Support_Text__c;
                childSupportText += childRulesupporttext + '<br/>';
            }
        }
        return childSupportText;
    }
    /**
@MethodName     : formQueryString
@Param          : List<Matching_Rule__c>
@return         : list<wrappersObjects>
@Description    : form Query string and only those fileds are required.
**/
    private static String formQueryString(List<Matching_Rule__c> MachingRulesList, String objName,  Map<Id, List<Matching_Rule_Criteria__c>> childRuleCriteriaByMachingRuleID){
        
        
        set<String> fieldsSet = new Set<String>();
        Map<String, List<String>> FieldsByrelationShipName = new Map<String, List<String>>();
        List<String> eachMatchingRuleString = new List<String>(); // it contains the conditions for each maching rule record.
        
        Map<String,Set<String>> childObjectFieldsByRelationshipName = new Map<String,Set<String>>();
        for(Matching_Rule__c oMR : MachingRulesList){
            //eachMatchingRuleString.add(formWhereConditionQuery(oMR.Matching_Rule_Criterias__r, oMR.Evaluation_Order__c));
            try{
                for(Matching_Rule_Criteria__c oMRC :  oMR.Matching_Rule_Criterias__r ){
                    if(String.isNotEmpty(oMRC.Field_API_Name__c) && !oMRC.Field_API_Name__c.equalsIgnoreCase('Master Record Id')) {
                        fieldsSet.add(oMRC.Field_API_Name__c.toLowerCase());
                    }                 
                }
                // add childQuery to fieldSet so we can get child records
                for(Matching_Rule__c childMatchingRule : oMR.Matching_Rules__r){
                    //Set<String> ChildFieldsSet = new Set<String>();
                    if(String.isNotBlank(childMatchingRule.Relationship_Name__c)){
                        for(Matching_Rule_Criteria__c ChildMatchRuleCriteria :  childRuleCriteriaByMachingRuleID.get(childMatchingRule.Id)){
                            if(String.isNotBlank(ChildMatchRuleCriteria.Field_API_Name__c) && !ChildMatchRuleCriteria.Field_API_Name__c.equalsIgnoreCase('Master Record Id')){
                                if(!childObjectFieldsByRelationshipName.containsKey(childMatchingRule.Relationship_Name__c)){
                                    childObjectFieldsByRelationshipName.put(childMatchingRule.Relationship_Name__c, new Set<String>());
                                }
                                childObjectFieldsByRelationshipName.get(childMatchingRule.Relationship_Name__c).add(ChildMatchRuleCriteria.Field_API_Name__c.toLowerCase());
                            }
                        }
                    }
                    // // System.debug('childMatchingRule.Relationship_Name__c------>'+childMatchingRule.Relationship_Name__c);
                    // List<String> uniqueFieldsList = new List<String>(ChildFieldsSet);
                    // if(!uniqueFieldsList.isEmpty() && String.isNotBlank(childMatchingRule.Relationship_Name__c)) {
                    //     String ChildQuery = '( SELECT ID, '+String.join(uniqueFieldsList, ',') +' FROM ' + childMatchingRule.Relationship_Name__c+' )';
                    //     fieldsSet.add(ChildQuery);
                    // }
                }
            }catch(Exception e){
                oMR.Status__c = 'ERROR';
                oMR.Status_Message__c = e.getMessage();
                updateMatchingRuleOnErrorList.add(oMR);
                // ErrorInQueryFormation.put('status', 'ERROR');
                // ErrorInQueryFormation.put('message', e.getMessage());
            }
        }
        if(!childObjectFieldsByRelationshipName.isEmpty()){
            
            for(String RelationshipName : childObjectFieldsByRelationshipName.keySet()){
                List<String> uniqueFieldsList = new List<String>(childObjectFieldsByRelationshipName.get(RelationshipName));
                if(!uniqueFieldsList.isEmpty()){
                    String ChildQuery = '( SELECT ID, '+String.join(uniqueFieldsList, ',') +' FROM ' +RelationshipName+' )';
                    fieldsSet.add(ChildQuery); 
                }                
            }
        }
        List<String> fieldsString = new List<String>(fieldsSet);
        //fieldsString.addAll(fieldsSet);       
        String  queryString = 'SELECT ID, ';
        queryString += String.join(fieldsString, ',');
        queryString = queryString.removeEnd(',');
        queryString += ' FROM '+ objName + ' WHERE Id =: recordId ' + ' Limit 1';
        System.debug('queryString>>>>>>>>>> '+queryString);
        return queryString;
    }
    
    /**
@MethodName     : formWhereConditionQuery
@Param          : List<Matching_Rule__c>, String
@return         : String
@Description    : form Query string and only those fileds are required.
**/
    // public static String formWhereConditionQuery(List<Matching_Rule_Criteria__c> oMRCList, String EvaluationOrder ){
    //     String strWhereQuery = '';
    //     Map<Integer, String> conditionsByLineNum = new Map<Integer, String>();
    //     for(Matching_Rule_Criteria__c oMRC : oMRCList )
    //     {
    //         conditionsByLineNum.put(Integer.valueOf(oMRC.Line_Number__c), convertSOQLToString(oMRC));
    //     }
    //     return makeFilterQuery(conditionsByLineNum, EvaluationOrder);
    // }
    /**
@MethodName     : makeFilterQuery
@Param          : Map<Integer, String>, String
@return         : String
@Description    : convert EvaluationOrder to SOQL query.
**//* START comment by Vijay
public static String makeFilterQuery(Map<Integer, String> conditionsByLineNum, String EvaluationOrder){
for(Integer o : conditionsByLineNum.keySet()){
EvaluationOrder = EvaluationOrder.replace(String.valueOf(o), conditionsByLineNum.get(o));
}
// need to work on this if filter rules has more then 9 records, like 10 , replace function will replace 1 for "1" other for 0 
return '( ' + EvaluationOrder + ' )';
} END */
    /**
@MethodName     : convertSOQLToString
@Param          : Matching_Rule_Criteria__c
@return         : String
@Description    : replace string to soql keywords
**/
    // public static String convertSOQLToString(Matching_Rule_Criteria__c oMRC){
    
    //     String FieldApi  = oMRC.Field_API_Name__c;
    //     String ruleValue = oMRC.Field_Value__c.toLowerCase();
    //     String fieldOperator =  oMRC.Field_Operator__c;
    
    //     String condString = '';
    //     if(fieldOperator.equals('equals') ){
    //         condString = FieldApi +' = \''+ ruleValue+ '\'';
    
    //     } else if(fieldOperator.equals('notEqual')){
    //         condString = FieldApi +' <> \''+ ruleValue+ '\'';
    
    //     } else if(fieldOperator.equals('lessThan')){
    //         condString = FieldApi +' < \''+ ruleValue+ '\'';
    
    //     } else if(fieldOperator.equals('greaterThan')){
    //         condString = FieldApi +' > \''+ ruleValue+ '\'';
    
    //     } else if(fieldOperator.equals('lessOrEqual')){
    //         condString = FieldApi +' <= \''+ ruleValue+ '\'';
    
    //     } else if(fieldOperator.equals('greaterOrEqual')){
    //         condString = FieldApi +' >= \''+ ruleValue+ '\'';
    
    //     } else if(fieldOperator.equals('contains')){
    //         condString = FieldApi +' Like \'%'+ ruleValue+ '%\'';
    
    //     } else if(fieldOperator.equals('notContain')){
    //         condString =  ' ( NOT '+FieldApi +' Like \'%'+ ruleValue+ '%\' ) ';
    
    //     } else if(fieldOperator.equals('startsWith')){
    //         condString = FieldApi +'<= \''+ ruleValue+ '\'';
    
    //     } else if(fieldOperator.equals('includes')){
    //         condString = FieldApi +' INCLUDES (\''+ ruleValue+ '\')';
    
    //     } else if(fieldOperator.equals('excludes')){
    //         condString = FieldApi +' EXCLUDES (\''+ ruleValue+ '\')';            
    //     }
    
    //     return condString;
    // } 
    
    /**
@MethodName     : matchRecordsWithRules
@Param          : List<Matching_Rule__c>
@return         : list<wrappersObjects>
@Description    : form Query string and only those fileds are required.
**/
    private static Map<Id, List<WrapperResult>> matchRecordsWithRules(List<Sobject> recordsList, List<Matching_Rule__c> MachingRulesList, Map<Id, List<Matching_Rule_Criteria__c>> childRuleCriteriaByMachingRuleID){
       
        Map<Id, List<WrapperResult>> MatchedRuleByRecordId = new Map<Id, List<WrapperResult>>();
        for(Sobject oRec : recordsList){
            for(Matching_Rule__c oMR : MachingRulesList){
                Boolean IsMatched = isMatchiesWithRules(oRec, oMR.Matching_Rule_Criterias__r, oMR);
                if(IsMatched && !MatchedRuleByRecordId.containsKey(oRec.Id)){
                    MatchedRuleByRecordId.put(oRec.Id, new List<WrapperResult>());
                }
                Persona_Helper_Settings__c personaHelper = Persona_Helper_Settings__c.getInstance(UserInfo.getuserid());
                List<wrapperChildMatch> matchedChildRecList = new List<wrapperChildMatch>();
                 
                if(IsMatched && oMR.Matching_Rules__r != null && !personaHelper.Stop_at_First__c){
                    // match Child records 
                    //String childMatchingRuleString = '';
                    for(Matching_Rule__c childMatchRule : oMR.Matching_Rules__r ){
                        if(String.isNotBlank(childMatchRule.Relationship_Name__c)) {
                            if(oRec.getSObjects(childMatchRule.Relationship_Name__c) != null){
                                matchedChildRecList.add(matchChildRecords(oRec.getSObjects(childMatchRule.Relationship_Name__c), childRuleCriteriaByMachingRuleID.get(childMatchRule.Id), childMatchRule));
                            }
                        }
                    }
                    //MatchedRuleByRecordId.get(oRec.Id).add(new WrapperResult(oMR, matchedChildRecList));                   
                }
                if(IsMatched){
                    MatchedRuleByRecordId.get(oRec.Id).add(new WrapperResult(oMR, matchedChildRecList)); 
                } 
            }
        }
        return MatchedRuleByRecordId;
    }
    
    private static WrapperChildMatch matchChildRecords(List<Sobject> recordsList, List<Matching_Rule_Criteria__c> childMachingRuleCriteria, Matching_Rule__c childMatchRule  ){
        List<Sobject> matchedRecordsList =  new List<Sobject>();
        List<Sobject> notMatchedRecordsList =  new List<Sobject>();
        for(Sobject rec : recordsList){
            if(isMatchiesWithRules(rec, childMachingRuleCriteria, childMatchRule)){
                matchedRecordsList.add(rec);               
            }else{
                notMatchedRecordsList.add(rec);
            }
        }
        return new wrapperChildMatch(childMatchRule, matchedRecordsList, notMatchedRecordsList);
    }
    /**
    @MethodName     : isMatchiesWithRules
    @Param          : Sobject oRec, Matching_Rule__c oMR
    @return         : list<wrappersObjects>
    @Description    : match record with  the Matching rule 
    **/
    private static Boolean isMatchiesWithRules(Sobject oRec, List<Matching_Rule_Criteria__c> childMachingRule, Matching_Rule__c oMR){
        try{
            String EvaluationOrder = oMR.Evaluation_Order__c;
            for(Matching_Rule_Criteria__c oMRC : childMachingRule){
                EvaluationOrder = EvaluationOrder.replace(String.valueOf(oMRC.Line_Number__c), String.valueOf(covertStringtoExpression(oRec , oMRC)));
            }
            EvaluationOrder = EvaluationOrder.toUpperCase();  
            System.debug('MR Name?>>>>>>>>> '+oMR.Name+'<<<<<<<<EvaluationOrder>>>>>>>>>>> '+EvaluationOrder); 
            return BooleanExpression.eval(EvaluationOrder);
        }catch(Exception e){
            oMR.Status__c = 'ERROR';
            oMR.Status_Message__c = e.getMessage();
            updateMatchingRuleOnErrorList.add(oMR);
        }
        return false;
    }
    
    private static Boolean covertStringtoExpression(Sobject oRec ,Matching_Rule_Criteria__c oMRC){
        return ConditionCheck.checkCondition(oRec, oMRC);
        /*
String recordValue  = String.valueOf(oRec.get(oMRC.Field_API_Name__c)).toLowerCase();
String ruleValue = oMRC.Field_Value__c.toLowerCase();
String fieldOperator =  oMRC.Field_Operator__c;
System.debug(recordValue+' '+fieldOperator+' '+ruleValue);
if(fieldOperator.equals('equals') ){
System.debug(recordValue+' '+fieldOperator+' '+ruleValue);
if(recordValue == ruleValue || recordValue.equals(ruleValue)){
return true;
}

} else if(fieldOperator.equals('notEqual')){
if(recordValue <> ruleValue ||  !recordValue.equals(ruleValue)){
return true;
}

} else if(fieldOperator.equals('lessThan')){
if(recordValue < ruleValue){
return true;
}

} else if(fieldOperator.equals('greaterThan')){
if(recordValue > ruleValue){
return true;
} 

} else if(fieldOperator.equals('lessOrEqual')){
if(recordValue <= ruleValue){
return true;
}
// Test it for date Fieldtype
} else if(fieldOperator.equals('greaterOrEqual')){
if(recordValue >= ruleValue){
System.debug('greaterOrEqual inside true');
return true;
}
System.debug(' greaterOrEqual outside  false');
// Test it for date Fieldtype
} else if(fieldOperator.equals('contains')){
if(recordValue.containsIgnoreCase(ruleValue)){
return true;
}

} else if(fieldOperator.equals('notContain')){
if(!recordValue.containsIgnoreCase(ruleValue)){
return true;
}

} else if(fieldOperator.equals('startsWith')){
if(recordValue.startsWithIgnoreCase(ruleValue)){
return true;
}
} else if(fieldOperator.equals('includes')){
if(recordValue.containsIgnoreCase(ruleValue)){
return true;
}
} else if(fieldOperator.equals('excludes')){
if(!recordValue.containsIgnoreCase(ruleValue)){
return true;
}          
}

return false;
*/
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
    private static Map<String, Schema.sObjectType> globalDescribe {get {
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
@MethodName     : validateRule
@Param          : 
@return         : Map<String,String>
@Description    : When new matching rule is created this method will called 
MachingRuleCreation.cls will call this method.
**/
    public static Map<String,String> validateRule(String ruleId){
        System.debug('validateRule>>>>>>> method');
        updateMatchingRuleOnErrorList = new List<Matching_Rule__c>();
        map<String, String> valueByLabel = new map<String, String>(); // to store error
        try{
            List<Matching_Rule__c> MachingRulesList = [SELECT ID, Name, Evaluation_Order__c, Object_Name__c, Parent_Matching_Rule__c, Relationship_Name__c, Support_Text__c, Status__c, Status_Message__c,
                                                       (SELECT ID, Field_API_Name__c, Field_Type__c, Field_Value__c, Line_Number__c, Field_Operator__c
                                                        FROM Matching_Rule_Criterias__r),
                                                       (SELECT ID, Name, Evaluation_Order__c, Object_Name__c, Parent_Matching_Rule__c, Relationship_Name__c, Support_Text__c, Status__c, Status_Message__c
                                                        FROM Matching_Rules__r)
                                                       FROM Matching_Rule__c
                                                       WHERE Id =: ruleId ];        
            String objName = MachingRulesList[0].Object_Name__c;
            Map<String, List<String>> fieldsListByObject = new Map<String, List<String>>();
            
            Map<Id, Id> parentIdByChildId = new  Map<Id, ID>();
            for(Matching_Rule__c oMR : MachingRulesList){
System.debug('oMR><>>>>>>>>>>>>>>>>>>>>>>>>>> '+oMR);
                for(Matching_Rule__c childMatchingRule : oMR.Matching_Rules__r){
                    parentIdByChildId.put( childMatchingRule.Id , oMR.Id);
                }
            }
            Map<Id, List<Matching_Rule_Criteria__c>> childRuleCriteriaByMachingRuleID  = new Map<Id, List<Matching_Rule_Criteria__c>>();
            for(Matching_Rule__c childMatchingRule : [SELECT ID, Name, Evaluation_Order__c, Object_Name__c, Parent_Matching_Rule__c, Relationship_Name__c, Support_Text__c, Status__c, Status_Message__c,
                                                      (SELECT ID, Field_API_Name__c, Field_Type__c, Field_Value__c, Line_Number__c, Field_Operator__c
                                                       FROM Matching_Rule_Criterias__r)                                                   
                                                      FROM Matching_Rule__c
                                                      WHERE ID =: parentIdByChildId.keySet() ])
            {
                for(Matching_Rule_Criteria__c rule : childMatchingRule.Matching_Rule_Criterias__r){
                    if(!childRuleCriteriaByMachingRuleID.containsKey(childMatchingRule.Id)){
                        childRuleCriteriaByMachingRuleID.put(childMatchingRule.Id, new List<Matching_Rule_Criteria__c>());
                    }
                    childRuleCriteriaByMachingRuleID.get(childMatchingRule.Id).add(rule);
                    
                }            
            }
            
            String QueryStrng = formQueryString(MachingRulesList, objName, childRuleCriteriaByMachingRuleID);
            List<Sobject> sobjectRecList = Database.query('SELECT Id FROM '+objName+ ' LIMIT 1');
            String recordId;
            List<Sobject> sobjectList;
            if(sobjectRecList.size() > 0){
                recordId = String.valueOf(sobjectRecList[0].get('Id'));
            }if(recordId != null){
                sobjectList = Database.query(QueryStrng);
                matchRecordsWithRules(sobjectList, MachingRulesList, childRuleCriteriaByMachingRuleID); 
            }            
            
        }catch(Exception e){
            System.debug(e.getMessage()+e.getLineNumber());
            valueByLabel.put('ERROR', e.getMessage());
        }finally{
            if(updateMatchingRuleOnErrorList.size() > 0){
                // Error 
                valueByLabel.put(updateMatchingRuleOnErrorList[0].Status__c, updateMatchingRuleOnErrorList[0].Status_Message__c);
            }
            if(valueByLabel.size() == 0){
                valueByLabel.put('success','success');
            }
        }
        System.debug('validation----->'+valueByLabel);
        return valueByLabel;
    }
}