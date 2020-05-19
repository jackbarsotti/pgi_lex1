@isTest
public with sharing class SendForESignatureControllerTest {
    @isTest
    static void test(){
        Test.startTest();
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        // opp.Type = 'Cloud Authentication';
        opp.CloseDate = Date.today();
        opp.StageName = 'Prospect';
        insert opp;
        echosign_dev1__Agreement_Template__c obj = new echosign_dev1__Agreement_Template__c();
        obj.Name = 'EMEA';
        obj.echosign_dev1__Master_Object_Type__c = 'Opportunity';
        insert obj;
        SendForESignatureController.getOpportunityData(opp.Id);
        SendForESignatureController.getAgreementTemplateData();
        Test.stopTest();
    }
}