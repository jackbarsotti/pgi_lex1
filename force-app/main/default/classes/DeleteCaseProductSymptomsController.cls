public with sharing class DeleteCaseProductSymptomsController {
    private ApexPages.StandardSetController standardController;
    public boolean noRecords{get; set;}
    
    public DeleteCaseProductSymptomsController(ApexPages.StandardSetController standardController) {
        this.standardController = standardController;
        noRecords = false;
    }
    public void deleteRecords() {
        Set<Id> selected = new Map<Id, SObject>(standardController.getSelected()).keySet(); 
        if(!selected.isEmpty()){
            delete [select Id from Case_Product_Focus_Symptom__c where Id in :selected];  
        } else{
            noRecords = true;   
        } 
    }
    public Pagereference returnToHomepage(){ 
        return standardController.cancel();
    }
}