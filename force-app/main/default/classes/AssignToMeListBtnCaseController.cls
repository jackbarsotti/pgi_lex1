public with sharing class AssignToMeListBtnCaseController {
    private ApexPages.StandardSetController standardController;
    public boolean noRecords{get; set;}
    
    public AssignToMeListBtnCaseController(ApexPages.StandardSetController standardController) {
        this.standardController = standardController;
        noRecords = false;
    }
    
    public void assignRecords(){
        Set<Id> selectedIds = new Map<Id, SObject>(standardController.getSelected()).keySet(); 
        if(!selectedIds.isEmpty()){
            List<Case> caseList = new List<Case>();
            for(Case caseObj : [SELECT Id, Assigned_To__c 
                                FROM Case 
                                WHERE Id =:selectedIds]){
                                    caseObj.Assigned_To__c = UserInfo.getUserId(); 
                                    caseList.add(caseObj);
                                }
            
            try{
                if(!caseList.isEmpty()){
                  UPDATE caseList;  
                }
                
            }
            catch(Exception e){
            } 
        } else{
            noRecords = true;   
        } 
        
    }
    public Pagereference returnToHomepage(){ 
        return standardController.cancel();
    }
}