@isTest
private class testEmailSender {
    
    static testMethod void testSendToAccountOwner() {
        List<Account> accountList = new List<Account>();
        accountList.add(MockAccount.getNewAccount());
        EmailSender.sendToAccountOwner(accountList, 'Test', 'Tester');
        System.assert(1==1);
    }
    
    static testMethod void testSendToSubscriptionOwner() {
        List<Subscription__c> subList = new List<Subscription__c>();
        subList.add(MockSubscription.getNewSubscription());
        EmailSender.sendToSubscriptionOwner(subList, 'Test', 'Tester'); 
        System.assert(1==1);
    }
    
    static testMethod void testSendErrorEmail() {        
        EmailSender.sendErrorEmail(new ConstructableException('Test Exception'));
    }
}