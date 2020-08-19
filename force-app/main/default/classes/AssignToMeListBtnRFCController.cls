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
            List<Request_for_Change__c> rfcList = new List<Request_for_Change__c>();
            for(Request_for_Change__c rfcObj :[SELECT Id, Assigned_To__c 
                                               FROM Request_for_Change__c 
                                               WHERE Id =:selectedIds]){
                                                   rfcObj.Assigned_To__c = UserInfo.getUserId();    
                                                   rfcList.add(rfcObj);          
                                               }
            try{
                if(!rfcList.isEmpty()){
                UPDATE rfcList;
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