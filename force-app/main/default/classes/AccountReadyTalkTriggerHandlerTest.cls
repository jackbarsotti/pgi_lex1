@isTest
public class AccountReadyTalkTriggerHandlerTest {
    @testSetup static void setup(){
        RecordType accountRT = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'ReadyTalk_Account'];
        Account ReadyAccount = new Account(
            Name = 'Ready Account',
            RecordTypeId = accountRT.Id
        );
        INSERT ReadyAccount;
    }
    
    static testMethod void testActiveStatusUpdate(){
        
    }
}