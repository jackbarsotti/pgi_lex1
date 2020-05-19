public with sharing class GenLookUpResult {
    @AuraEnabled public String SObjectLabel {get; set;}
    @AuraEnabled public String SObjectId {get; set;}
    
    public GenLookUpResult(String sObjectLabel, String sObjectId) {
        this.SObjectLabel = sObjectLabel;
        this.SObjectId = sObjectId;
    }
}