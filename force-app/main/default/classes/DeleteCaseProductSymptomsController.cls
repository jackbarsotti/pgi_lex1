public with sharing class DeleteCaseProductSymptomsController {
	private ApexPages.StandardSetController standardController;
    
    public DeleteCaseProductSymptomsController(ApexPages.StandardSetController standardController) {
        this.standardController = standardController;
    }
    
    public PageReference deleteRecords() {
        Set<Id> selected = new Map<Id, SObject>(standardController.getSelected()).keySet();        
        delete [select Id from Case_Product_Focus_Symptom__c where Id in :selected];    
        return standardController.cancel();
    }
}