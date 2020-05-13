@isTest
public class testTriggers {

  static testMethod void testTrigger () {
    Account a = new Account();
    a.Name = 'test';
    a.Invoice_Types__c = 'Account Summary';
    a.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkAccountRecordTypes[0].Id;
    insert a;

    List<Event_Webcasting_Rates__c> rates = [SELECT Id FROM Event_Webcasting_Rates__c];
    System.assertEquals(rates.size(), 1);
    //Account actual = [SELECT id, Celigo_Update__c, NetSuite_Id__c, NetSuite_Locked__c, NS_Sync__c
                      //FROM Account where id = :a.id];
    
  }
}