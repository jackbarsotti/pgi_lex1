public with sharing class AssignToMeListBtnRFCController {
    private ApexPages.StandardSetController standardController;
    public boolean noRecords{get; set;}
    
    public AssignToMeListBtnRFCController(ApexPages.StandardSetController standardController) {
        this.standardController = standardController;
        noRecords = false;
    }
  
    public void assignRecords(){
         Set<Id> selectedIds = new Map<Id, SObject>(standardController.getSelected()).keySet(); 
        if(!selectedIds.isEmpty()){
            Request_for_Change__c rfcObj = [SELECT Id, Assigned_To__c 
                                              FROM Request_for_Change__c 
                                              WHERE Id =:selectedIds];
            rfcObj.Assigned_To__c = UserInfo.getUserId();
            try{
                UPDATE rfcObj;
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