public with sharing class AssignToMeListBtnFinReqController {
    private ApexPages.StandardSetController standardController;
    public boolean noRecords{get; set;}
    
    public AssignToMeListBtnFinReqController(ApexPages.StandardSetController standardController) {
        this.standardController = standardController;
        noRecords = false;
    }
  
    public void assignRecords(){
         Set<Id> selectedIds = new Map<Id, SObject>(standardController.getSelected()).keySet(); 
        if(!selectedIds.isEmpty()){
             Financial_Request__c finReqObj = [SELECT Id, Assigned_To__c 
                                              FROM Financial_Request__c 
                                              WHERE Id =:selectedIds];
            finReqObj.Assigned_To__c = UserInfo.getUserId();
            try{
                UPDATE finReqObj;
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