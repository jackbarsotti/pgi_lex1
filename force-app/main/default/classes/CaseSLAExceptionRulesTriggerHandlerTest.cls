@isTest
public with sharing class CaseSLAExceptionRulesTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        Case_SLA_Exception_Rules__c caseSLAExpRule = new Case_SLA_Exception_Rules__c();
        caseSLAExpRule.Name = 'Test SLARule';
        caseSLAExpRule.Rule_Order__c = 1;
        caseSLAExpRule.Evaluation_Order__c = '1';
        insert caseSLAExpRule;
    }

    @isTest
    static void testDeleteRecord(){
        Case_SLA_Exception_Rules__c obj = [SELECT Id, Name, Rule_Order__c, Evaluation_Order__c FROM Case_SLA_Exception_Rules__c WHERE Name = 'Test SLARule'];
        delete obj;
    }
}