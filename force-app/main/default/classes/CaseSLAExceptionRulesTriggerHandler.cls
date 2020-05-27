/*
* Author : Anup
*/
public without sharing class CaseSLAExceptionRulesTriggerHandler {
    public void onBeforeDelete()
    {
        this.deleteChildRecords((List<Case_SLA_Exception_Rules__c>)Trigger.old);
    }
    // RT-586
    // it will delete all the Child object records related to Case_SLA_Exception_Rules__c object
    private void deleteChildRecords(List<Case_SLA_Exception_Rules__c> oldCaseSLAExpRuleRecords){
       List<Id> caseSLAExpRuleIds = new List<Id>();
        for(Case_SLA_Exception_Rules__c caseSLAExpRule : oldCaseSLAExpRuleRecords){
            caseSLAExpRuleIds.add(caseSLAExpRule.ID);
        }
        List<Case_SLA_Exception_Rule_Conditions__c> caseSLAExpRuleCondList = [SELECT Id, Case_SLA_Exception_Rules__c FROM Case_SLA_Exception_Rule_Conditions__c WHERE Case_SLA_Exception_Rules__c in : caseSLAExpRuleIds];
        delete caseSLAExpRuleCondList;
    }
}