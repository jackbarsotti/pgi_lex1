public with sharing class UpdatefromNetSuiteController {
    @AuraEnabled
    public static Account getAccountRecords(String accId){
        Account acc = [select Id, NetSuite_Pull__c, NetSuite_Push__c from Account where Id =: accId];
        System.debug('>> acc from update From Netsuite >>'+acc);
        return acc;
    }
}