@isTest
public class ContactActionsTest {
    static testMethod void testonContactDelete(){
        Id pgiRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('PGi_Contact').getRecordTypeId();
        Account acc = new Account();
        acc.Name='test';
        Insert acc;
        Contact contactObj = new Contact(Lastname = 'testcon',AccountId = acc.Id,RecordTypeId = pgiRT,Account_Admin__c=true,Email='test@Contact.com',Status__c='Delete');
		Insert contactObj;  
    }
    static testMethod void testonContactDeleteInactive(){
        Id readyTalkRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ReadyTalk_Contact').getRecordTypeId();
        Account acc = new Account();
        acc.Name='test';
        Insert acc;
        Contact contactObj = new Contact(Lastname = 'testcon',Celigo_Update__c=true,AccountId = acc.Id,RecordTypeId = readyTalkRT,Account_Admin__c=true,Email='test@Contact.com');
		Insert contactObj;  
        contact conObj=[Select Id,NetSuite_Id__c,NetSuite_Locked__c,NS_Sync__c,NetSuite_Push__c,NetSuite_Pull__c from contact];
        System.assertEquals(false, conObj.NetSuite_Locked__c);
        System.assertEquals(false, conObj.NetSuite_Push__c);
        System.assertEquals(false, conObj.NetSuite_Pull__c);
    }
    static testMethod void testonContactDeleteStatus(){
        Id readyTalkRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ReadyTalk_Contact').getRecordTypeId();
        Account acc = new Account();
        acc.Name='test';
        Insert acc;
        Contact contactObj = new Contact(Lastname = 'testcon',Inactive__c=true,Status__c='Delete',AccountId = acc.Id,RecordTypeId = readyTalkRT,Account_Admin__c=true,Email='test@Contact.com');
		Insert contactObj;  
        contact conObj=[Select Id,NetSuite_Id__c,NetSuite_Locked__c,NS_Sync__c,NetSuite_Push__c,NetSuite_Pull__c from contact];
        System.assertEquals(false, conObj.NetSuite_Locked__c);
        System.assertEquals(false, conObj.NetSuite_Push__c);
        System.assertEquals(false, conObj.NetSuite_Pull__c);
    }
    static testMethod void testonContactDeleteSameStatus(){
        Id readyTalkRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ReadyTalk_Contact').getRecordTypeId();
        Account acc = new Account();
        acc.Name='test';
        Insert acc;
        Contact contactObj = new Contact(Lastname = 'testcon',Inactive__c=true,AccountId = acc.Id,RecordTypeId = readyTalkRT,Account_Admin__c=true,Email='test@Contact.com');
		Insert contactObj; 
        contact conObj=[Select Id,NetSuite_Id__c,NetSuite_Locked__c,NS_Sync__c,NetSuite_Push__c,NetSuite_Pull__c from contact];
        System.assertEquals(false, conObj.NetSuite_Locked__c);
        System.assertEquals(false, conObj.NetSuite_Push__c);
        System.assertEquals(false, conObj.NetSuite_Pull__c);
    }
    static testMethod void testonContactDeleteAllFalse(){
        Id readyTalkRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ReadyTalk_Contact').getRecordTypeId();
        Account acc = new Account();
        acc.Name='test';
        Insert acc;
        Contact contactObj = new Contact(Lastname = 'testcon',Inactive__c=true,AccountId = acc.Id,RecordTypeId = readyTalkRT,Account_Admin__c=true,Email='test@Contact.com');
		Insert contactObj; 
        contactObj.Status__c='Pending';
        Update contactObj;
        contact conObj=[Select Id,NetSuite_Id__c,NetSuite_Locked__c,NS_Sync__c,NetSuite_Push__c,NetSuite_Pull__c from contact];
        System.assertEquals(false, conObj.NetSuite_Locked__c);
        System.assertEquals(false, conObj.NetSuite_Push__c);
        System.assertEquals(false, conObj.NetSuite_Pull__c);
    }
}