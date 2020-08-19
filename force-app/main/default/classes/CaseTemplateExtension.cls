public with sharing class CaseTemplateExtension {
    
    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ApexPages.StandardController controller {get; set;}
    public CaseTemplateExtension(ApexPages.StandardController stdController) {
        this.controller = stdController;
    }
    
    public List<SelectOption> caseRecordTypes {get{
        if(caseRecordTypes == null) {
            caseRecordTypes = new List<SelectOption>();
            List<RecordType> rtList = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case' AND isActive = true ORDER BY Name];
            caseRecordTypes.add(new SelectOption('',''));
            for(RecordType rt: rtList) {
                caseRecordTypes.add(new SelectOption(rt.Id, rt.Name));
            }
            
        }
        return caseRecordTypes;
    }set;}
    public PageReference saveAndNew() {   
        //  String str = ApexPages.currentPage().getUrl().subStringAfter('/').substringBefore('?');
        //  return new PageReference('/apex/' + str).setRedirect(true);
        try {
            //  controller.save();
            String str = ApexPages.currentPage().getUrl().subStringAfter('/').substringBefore('?');
            return new PageReference('/apex/' + str).setRedirect(true);
        } catch (exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
         Case_Template__c ct = new Case_Template__c();
          return new ApexPages.StandardController(ct).edit();  
    }
}