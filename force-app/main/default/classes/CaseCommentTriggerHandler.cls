public without sharing class CaseCommentTriggerHandler extends TriggerHandler {
    public CaseCommentTriggerHandler() {
        super('CaseCommentTriggerHandler');
    }
    protected override void afterInsert(){
        updateCase();
    }
    protected override void afterUpdate(){
        updateCase();
    }
    private void updateCase(){
        Set<Id> caseIds = new set<Id>();
        List<Case> upCase = new List<Case>();
        for(CaseComment cc : (List<CaseComment>)Trigger.new){
            caseIds.add(cc.ParentId);
        }
        Map<Id, Case> relatedCases = new Map<Id, Case>([SELECT Id, IsUpdateFromCaseComment__c FROM Case WHERE Id IN : caseIds FOR UPDATE]);
        if(!relatedCases.isEmpty()) {
            for(CaseComment cc: (List<CaseComment>)Trigger.new) {
                Case cse = relatedCases.get(cc.ParentId);
                cse.Latest_Case_Comment__c = cc.CommentBody;
                if(cse.IsUpdateFromCaseComment__c){
                    cse.IsUpdateFromCaseComment__c = false;
                }else{
                    cse.IsUpdateFromCaseComment__c = true;
                }
                upCase.add(cse);
            }
        }
        if(!upCase.isEmpty()){
            database.update(upCase, false);
        }
    }
}