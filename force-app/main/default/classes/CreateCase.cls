public with sharing class CreateCase {
    public CreateCase() {
        
    }
    public CreateCase(ApexPages.StandardController controller) {
        this.controller = controller;
    }
    public PageReference inConsole() {
        System.debug('>>>>>>>>>In');
        return populateCaseNumber();
    }
    public PageReference notInConsole() {
        PageReference pr = Page.CaseTabViewer;
        pr.getParameters().put('isClassic', 'true');
        passForwardParams(pr);
        return pr;
    }
    public void passForwardParams(PageReference pr) {
        Set<String> passForwardParams = new Set<String>{'retURL', LABEL.Related_SCA_Id + '_lkid', 'isClassic', 'isNew', 'saveUrl', 'Id', 'RecordType', 'RecordTypeId', 'QuickCase', 'cas4', 'cas4_lkid'};
        PageReference cp = ApexPages.currentPage();
        for(String s: cp.getParameters().keySet()){
            if(passForwardParams.contains(s)){
                pr.getParameters().put(s, cp.getParameters().get(s));
            } else if (s.startsWith('CF0')) {
                pr.getParameters().put(s, cp.getParameters().get(s));
            }
        }
    }
    public List<CaseTabViewer__c> ctvList {get{
        if(ctvList == null) {
            ctvList = CaseTabViewer__c.getAll().values();
        }
        return ctvList;
    } set;}
    private Set<String> ctvRtSet { get{
        if(ctvRtSet == null){
            ctvRtSet = new Set<String>();
            for(CaseTabViewer__c c: ctvList) {
                ctvRtSet.add(c.RecordType__c);
            }
        }
        return ctvRtSet;
    } set;}
    private Id rtId {get {
        if(rtId == null) {
            rtId = (Id)controller.getRecord().get('RecordTypeId');
        }
        return rtId;
    } set;}
    private ApexPages.StandardController controller {get; set;}
    public PageReference populateCaseNumber() {
        Case cse = (Case)controller.getRecord();
        try {
            Id recordTyId = ApexPages.currentPage().getParameters().get('RecordType');
            String rtName ='';
            if(recordTyId != null){
                rtName =  Schema.SObjectType.Case.getRecordTypeInfosById().get(recordTyId).getName();
                rtId = recordTyId;
            }
            if(rtName == '' && rtId != null){
                rtName =  Schema.SObjectType.Case.getRecordTypeInfosById().get(rtId).getName();
            }
            if(rtId != null){ //prepopulate case number iif we are using VF override
                if(ctvRtSet.contains(rtName)) {
                    if(cse.Id == null){
                        cse.Auto_Generated_For_Case__c = true;
                        upsert cse;
                    }
                    PageReference pr = Page.CaseTabViewer;
                    passForwardParams(pr);
                    pr.getParameters().put('isNew', 'true');
                    pr.getParameters().put('Id', cse.Id);
                    pr.setRedirect(true);   
                    return pr;
                }
            }
            PageReference pr = Page.CaseTabViewer;
            passForwardParams(pr);
            pr.getParameters().put('isNew', 'true');
            pr.setRedirect(true);   
            return pr;
        } catch (DmlException e) {
            if(e.getDmlMessage(0) != null){
                cse.addError(e.getDmlMessage(0));
            } 
            return null;
        } catch (Exception e) {
            if(e.getMessage() != null){
                cse.addError(e.getMessage());
            } 
            return null;
        }
    }
}