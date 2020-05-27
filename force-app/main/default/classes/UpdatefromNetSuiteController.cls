public with sharing class UpdatefromNetSuiteController {
    @AuraEnabled
    public static Account getAccountRecords(String accId){
        Account acc = [select Id, NetSuite_Pull__c, NetSuite_Push__c from Account where Id =: accId];
        return acc;
    }
    @AuraEnabled
    public static void updateAccountRecord(String accId){
        Account acc = [select Id, Celigo_Update__c, NetSuite_Pull__c, NetSuite_Push__c from Account where Id =: accId];
        acc.NetSuite_Pull__c = true;
        acc.Celigo_Update__c = true;
        update acc;
        System.debug('>> acc updated >>'+acc);
    }
}