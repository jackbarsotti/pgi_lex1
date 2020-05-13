public with sharing class CustomEmailTemplateLookupController {
    public CustomEmailTemplateLookupController(EmailComposer controller) {
        
    } 
    public List<SelectOption> folderList {get{
        if(folderList == null) {
            folderList = new List<SelectOption>();
            for(Folder f: [SELECT ID, Name FROM Folder WHERE Type = 'Email' ORDER BY Name]) {
                folderList.add(new SelectOption(f.Id, f.Name));
            }
        }
        return folderList;
    } set;}

    public Id folderId {get {
        if(folderId == null) {
            folderId = folderList[0].getValue();
        }
        return folderId;
    } set;}
    // run the search and return the records found. 
    public List<EmailTemplate> results {get {
        String soql = 'Select Id, Name, DeveloperName FROM EmailTemplate WHERE FolderId =: folderId ORDER BY Name';
        soql = soql + ' LIMIT 1000';
        System.debug(soql);
        return database.query(soql); 
    } set; 
    }
    public PageReference doNothing() {
        return null;
    }
    public Pagereference setFolderId() {
        folderId = ApexPages.CurrentPage().getParameters().get('folder');
        return null;
    } 
    
}