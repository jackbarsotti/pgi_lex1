/*
 * Test class for SubscriptionTriggerHandler
*/
@isTest
public class SubscriptionTriggerHandlerTest {

	@isTest
    public static void SystemAdminUnitTest() {
    	Subscription__c testSubscription = new Subscription__c();
    	testSubscription.Name = '1234567';
    	testSubscription.Passcode__c = '847653291';
    	testSubscription.Security_Passcode__c = 'No security';
    	testSubscription.Card_Name__c = 'Test Card Name';
    	testSubscription.Subscription_Email__c = 'test@test.test';
    	testSubscription.Address_Line_1__c = '3rd Test Street';
    	testSubscription.City__c = 'test city';
    	insert testSubscription;

    	update testSubscription;
    }
    @isTest
    public static void testAudioPortChange(){ 
        Subscription__c testSubscription = new Subscription__c();
        testSubscription.Name = '1234567';
        testSubscription.Passcode__c = '847653291';
        testSubscription.Security_Passcode__c = 'No security';
        testSubscription.Card_Name__c = 'Test Card Name';
        testSubscription.Subscription_Email__c = 'test@test.test';
        testSubscription.Address_Line_1__c = '3rd Test Street';
        testSubscription.City__c = 'test city';
        testSubscription.Audio_subscription_size__c = 'Meeting 10';
        insert testSubscription;

        testSubscription.Audio_subscription_size__c = 'Meeting 25';
        update testSubscription;
        System.assertEquals('Meeting 10', [SELECT Last_Number_of_Audio_Ports__c FROM Subscription__c].Last_Number_of_Audio_Ports__c);
        System.assertEquals(System.today(), [SELECT Last_Change_Date_for_Audio_Ports__c FROM Subscription__c].Last_Change_Date_for_Audio_Ports__c);
        

        testSubscription.Revert_Last_Subscription_Values__c = true;
        update testSubscription;
        System.assertEquals(null, [SELECT Last_Number_of_Audio_Ports__c FROM Subscription__c].Last_Number_of_Audio_Ports__c);
        System.assertEquals(null, [SELECT Last_Change_Date_for_Audio_Ports__c FROM Subscription__c].Last_Change_Date_for_Audio_Ports__c);

        testSubscription.Revert_Last_Subscription_Values__c = false;
        testSubscription.Audio_subscription_size__c = 'Meeting 25';        
        update testSubscription;
        System.assertEquals('Meeting 10', [SELECT Last_Number_of_Audio_Ports__c FROM Subscription__c].Last_Number_of_Audio_Ports__c);
        System.assertEquals(System.today(), [SELECT Last_Change_Date_for_Audio_Ports__c FROM Subscription__c].Last_Change_Date_for_Audio_Ports__c);
        
        testSubscription.Audio_subscription_size__c = 'Meeting 10';
        update testSubscription;
        System.assertEquals(null, [SELECT Last_Number_of_Audio_Ports__c FROM Subscription__c].Last_Number_of_Audio_Ports__c);
        System.assertEquals(null, [SELECT Last_Change_Date_for_Audio_Ports__c FROM Subscription__c].Last_Change_Date_for_Audio_Ports__c);
    }
}