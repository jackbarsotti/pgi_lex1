@isTest
public with sharing class AssignToMeQuickActionControllerTest {
    
    @testSetup static void setup(){
        
        PGi_Client__c pgiClientObj=new PGi_Client__c();
        pgiClientObj.Client_ID__c='PGITest12';
        INSERT pgiClientObj;
        
        Financial_Request__c FinReqObj=new Financial_Request__c();
        FinReqObj.Status__c='New';
        FinReqObj.Type__c='Other';
        FinReqObj.Reason__c='NA';
        FinReqObj.Bill_To_Client__c=pgiClientObj.Id;
        INSERT FinReqObj;
        
        AssignToMeQuickActionController.updateRecord(FinReqObj.Id);
    }
    
}