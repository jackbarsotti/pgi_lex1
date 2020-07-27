public with sharing class SalesLoftImportLeadLstController {
 private ApexPages.StandardSetController standardController;
    
    public SalesLoftImportLeadLstController(ApexPages.StandardSetController standardController) {
        this.standardController = standardController;
    }
    
     public PageReference getRecords(){
         Set<Id> selectedIds = new Map<Id, SObject>(standardController.getSelected()).keySet(); 
         PageReference custPage = new PageReference('https://app.salesloft.com/app/import/crm?lead='+selectedIds);
        custPage.setRedirect(true);
        return custPage;
     }
}