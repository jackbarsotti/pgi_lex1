public class AgileReviewController {
    @AuraEnabled
    public static List<String> getPickListValuesIntoList(String ObjectApi_name,String Field_name){ 
        
        List<String> lstPickvals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        lstPickvals.add('All');
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }
        System.debug('The Case'+lstPickvals);
        return lstPickvals;
    }
    /* @AuraEnabled
public static List<String> getPickListValuesIntoLi123st(sObject objectName , sObject FieldName){
List<String> pickListValuesList= new List<String>();
Schema.DescribeFieldResult fieldResult = objectName.FieldName.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
pickListValuesList.add('Select group');
for( Schema.PicklistEntry pickListVal : ple){
pickListValuesList.add(pickListVal.getLabel());
}     
return pickListValuesList;
}*/
    /*  @AuraEnabled
public static List < String > getPickListValuesIntoList(sObject objObject, string fld) {
system.debug('objObject --->' + objObject);
system.debug('fld --->' + fld);
List < String > allOpts = new list < String > ();
// Get the object type of the SObject.
Schema.sObjectType objType = objObject.getSObjectType();

// Describe the SObject using its object type.
Schema.DescribeSObjectResult objDescribe = objType.getDescribe();

// Get a map of fields for the SObject
map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();

// Get the list of picklist values for this field.
list < Schema.PicklistEntry > values =
fieldMap.get(fld).getDescribe().getPickListValues();

// Add these values to the selectoption list.
for (Schema.PicklistEntry a: values) {
allOpts.add(a.getValue());
}
system.debug('allOpts ---->' + allOpts);
allOpts.sort();
return allOpts;
}*/
    /* @AuraEnabled
public static wrapCaseAndSprint getRecords(String groupName){
Map<Id,AgileSprint__c> sprintMap = new Map<Id,AgileSprint__c>();
Map<Id,List<Case>> sprinttoCaseMap = new Map<Id,List<Case>>();  
Set<Id> agileSprintId = new Set<Id>();
for(AgileSprint__c sprintObj :[SELECT Id,Status__c,CountofIssuesAtClose__c,CountofIssuesAtStart__c,DifferentiatingVolume__c,EndDate__c,StartDate__c FROM AgileSprint__c WHERE AssociatedGroup__c =:groupName]){
agileSprintId.add(sprintObj.Id);
sprintMap.put(sprintObj.Id,sprintObj);
}
for(Case caseObj :[SELECT Id,Status,AgileStatus__c,Description,AgileSprint__c FROM Case WHERE AgileSprint__c =:agileSprintId]){
if(!sprinttoCaseMap.containskey(caseObj.AgileSprint__c)){
sprinttoCaseMap.put(caseObj.AgileSprint__c, new List<Case>{});
}
sprinttoCaseMap.get(caseObj.AgileSprint__c).add(caseObj);
}
wrapCaseAndSprint wrapper=new wrapCaseAndSprint(sprintMap,sprinttoCaseMap);
// return JSON.serialize(wrapper); 
return wrapper;
//return wrapCaseAndSprint.add(new wrapCaseAndSprint(sprintMap,sprinttoCaseMap));
}*/
    
    public class wrapCaseAndSprint {
        @AuraEnabled
        public List<Id> agileSprintId {get; set;}
        @AuraEnabled
        public Map<Id,AgileSprint__c> sprintMap {get; set;}
        @AuraEnabled
        public Map<Id,List<Case>> sprinttoCaseMap {get; set;}
        @AuraEnabled
        public Map<String,List<Id>> grouptoagileId {get; set;}
        public wrapCaseAndSprint(Map<Id,AgileSprint__c> sprintMap , Map<Id,List<Case>> sprinttoCaseMap , List<Id> agileSprintId , Map<String,List<Id>> grouptoagileId) {
            this.sprintMap = sprintMap;
            this.sprinttoCaseMap = sprinttoCaseMap;
            this.agileSprintId = agileSprintId;
            this.grouptoagileId = grouptoagileId;
        }
    }
    @AuraEnabled
    public static wrapCaseAndSprint fetchDetails(){
        Map<Id,AgileSprint__c> sprintMap = new Map<Id,AgileSprint__c>();
        Map<Id,List<Case>> sprinttoCaseMap = new Map<Id,List<Case>>();
        Map<String,List<Id>> grouptoagileId = new Map<String,List<Id>>();
        List<Id> agileSprintId = new List<Id>();
        Date presentDate = date.today();
        /* for(AgileSprint__c agileSprintObj :[SELECT Name,Status__c,StartDate__c,AssociatedGroup__c 
FROM AgileSprint__c 
ORDER BY StartDate__c ASC
]){
agileSprintId.add(agileSprintObj.Id);
sprintMap.put(agileSprintObj.Id,agileSprintObj); 
}*/
        for(AgileSprint__c agileSprintObj :[SELECT Name,Status__c,StartDate__c,AssociatedGroup__c,(SELECT Id,CaseNumber,Status,AgileStatus__c,Description,AgileSprint__c FROM Related_Cases__r) 
                                            FROM AgileSprint__c 
                                            ORDER BY StartDate__c ASC
                                           ]){
                                               agileSprintId.add(agileSprintObj.Id);
                                               sprintMap.put(agileSprintObj.Id,agileSprintObj); 
                                               if(!grouptoagileId.containskey(agileSprintObj.AssociatedGroup__c)){
                                                           grouptoagileId.put(agileSprintObj.AssociatedGroup__c, new List<Id>{});
                                                       }
                                                   grouptoagileId.get(agileSprintObj.AssociatedGroup__c).add(agileSprintObj.Id);
                                               if(agileSprintObj.Related_Cases__r.size() > 0){
                                                    
                                                   
                                                   for(case objCase : agileSprintObj.Related_Cases__r){
                                                       if(!sprinttoCaseMap.containskey(agileSprintObj.Id)){
                                                           sprinttoCaseMap.put(agileSprintObj.Id, new List<Case>{});
                                                       }
                                                       sprinttoCaseMap.get(agileSprintObj.Id).add(objCase); 
                                                      
                                                   }
                                               }
                                           }
        
        /*for(Case caseObj :[SELECT Id,CaseNumber,Status,AgileStatus__c,Description,AgileSprint__c 
FROM Case 
WHERE AgileSprint__c =:sprintMap.keySet()]){
if(!sprinttoCaseMap.containskey(caseObj.AgileSprint__c)){
sprinttoCaseMap.put(caseObj.AgileSprint__c, new List<Case>{});
}
sprinttoCaseMap.get(caseObj.AgileSprint__c).add(caseObj);
}*/  
        wrapCaseAndSprint wrapper=new wrapCaseAndSprint(sprintMap,sprinttoCaseMap ,agileSprintId , grouptoagileId);
        return wrapper;
    }
    @AuraEnabled
    public static List<Case> fetchBacklogCase(){
        List<Case> caseList =[Select Id,AgileSprint__c,CaseNumber FROM Case WHERE AgileSprint__c = null];
        return caseList;
    }
     @AuraEnabled
    public static void updateStatus(String sprintID , String name){
       AgileSprint__c  sprintObj = [Select Id,Status__c FROM AgileSprint__c WHERE Id =: sprintID];
        if(name == 'Start'){
          sprintObj.Status__c ='Active';  
        }
        else if(name == 'complete'){
          sprintObj.Status__c ='Completed';  
        }
        else{
          sprintObj.Status__c ='Canceled';  
        }
        Update sprintObj;
    }
}