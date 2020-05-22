@isTest
public with sharing class SendForESignatureControllerTest {
    @isTest
    static void test(){
        Test.startTest();
        Opportunity oppObj = new Opportunity();
        oppObj.Name = 'testOpp';
        // opp.Type = 'Cloud Authentication';
        oppObj.CloseDate = Date.today();
        oppObj.StageName = 'Prospect';
        insert oppObj;
        echosign_dev1__Agreement_Template__c agreeTempObj = new echosign_dev1__Agreement_Template__c();
        agreeTempObj.Name = 'EMEA';
        agreeTempObj.echosign_dev1__Master_Object_Type__c = 'Opportunity';
        insert agreeTempObj;
      
        Opportunity oppRecord= SendForESignatureController.getOpportunityData(oppObj.Id);
        System.assert(oppRecord!=null);
        List<echosign_dev1__SIGN_Agreement__c> signAgreeList=SendForESignatureController.getSignAgreementData(oppObj.Id);
        System.assert(signAgreeList!=null);
        echosign_dev1__Agreement_Template__c agreeTemplateObj=SendForESignatureController.getAgreementTemplateData();
        System.assert(agreeTemplateObj!=null);
        
        Test.stopTest();
    }
}