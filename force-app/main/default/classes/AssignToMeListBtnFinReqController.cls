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
             List<Financial_Request__c> finReqList = new List<Financial_Request__c>();
            for(Financial_Request__c finObj :[SELECT Id, Assigned_To__c 
                                              FROM Financial_Request__c 
                                              WHERE Id =:selectedIds]){
                                 finObj.Assigned_To__c = UserInfo.getUserId();    
                                        finReqList.add(finObj);          
                                              }
            try{
                if(!finReqList.isEmpty()){
                  UPDATE finReqList;  
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