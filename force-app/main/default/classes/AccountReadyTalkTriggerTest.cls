@isTest
public with sharing class AccountReadyTalkTriggerTest {
    static testMethod void test() {
        Account acc = new Account();
        acc.Name = 'Test Trigger';
        insert acc;
    }
}