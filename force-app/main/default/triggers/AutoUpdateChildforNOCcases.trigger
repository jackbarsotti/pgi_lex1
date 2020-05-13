trigger AutoUpdateChildforNOCcases on Case (after update) {

Set<Id> ParentCaseids = new Set<Id>();
List<Case> Childcases = new List<Case>();
Map<ID,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosById();

for(Case cs : Trigger.new){
    if(cs.Status != Trigger.oldMap.get(cs.Id).Status && cs.Status == 'Closed' && rt_map.get(cs.recordTypeID).getName() == 'PGi-Parent Ticket (NOC)'){
        ParentCaseids.add(cs.id);
    }
}
system.debug('ARC debug ParentCaseids:'+Parentcaseids);
if(!ParentCaseids.isEmpty()){

Childcases = [SELECT Id,ParentId,Tracking_Root_Category__c,Tracking_Root_Cause__c,Tracking_Root_Issue__c,Actual_Restore_Time__c,Impact_Level__c,Urgency_Level__c FROM Case WHERE ParentId IN :ParentCaseids];

system.debug('ARC debug Childcases:'+Childcases);

if(!Childcases.isEmpty()){    
Map<Id,Case> parentMap = new Map<ID,Case>([SELECT Id,ParentId,Tracking_Root_Category__c,Tracking_Root_Cause__c,Tracking_Root_Issue__c,Actual_Restore_Time__c,Impact_Level__c,Urgency_Level__c FROM Case WHERE Id IN :ParentCaseids]);
  
for(Case childcs : Childcases){
    childcs.Tracking_Root_Category__c = parentMap.get(childcs.parentid).Tracking_Root_Category__c;
    childcs.Tracking_Root_Cause__c = parentMap.get(childcs.parentid).Tracking_Root_Cause__c;
    childcs.Tracking_Root_Issue__c = parentMap.get(childcs.parentid).Tracking_Root_Issue__c;
    childcs.Actual_Restore_Time__c = parentMap.get(childcs.parentid).Actual_Restore_Time__c;
    childcs.Impact_Level__c = parentMap.get(childcs.parentid).Impact_Level__c;
    childcs.Urgency_Level__c = parentMap.get(childcs.parentid).Urgency_Level__c;
}
update Childcases;
}    
}
}