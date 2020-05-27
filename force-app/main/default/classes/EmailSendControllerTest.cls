@isTest
public with sharing class EmailSendControllerTest {
    @TestSetup
    static void setData(){
        Financial_Request__c finreqObj = new Financial_Request__c();
        finreqObj.Subject__c = 'testSubject';
        insert finreqObj;

        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;

        Task tskObj = new Task();
        tskObj.WhatId = acc.Id;
        tskObj.Subject = 'test subject';
        insert tskObj;

        // EmailTemplate emailtemp = new EmailTemplate();
        // emailtemp.isActive = true;
        // emailtemp.Name = 'name';
        // emailtemp.DeveloperName = 'Single_Mail';
        // emailtemp.TemplateType = 'text';
        // emailtemp.FolderId = UserInfo.getUserId();
        // insert emailtemp;
    }
    static testMethod void testGetrecord(){
        Test.startTest();
        Financial_Request__c finreqObj = [SELECT Id, Subject__c FROM Financial_Request__c WHERE Subject__c = 'testSubject'];
    
        // Task tsk = [SELECT Id, WhatId FROM Task WHERE Subject = 'test subject'];
        EmailSendController.getrecord(finreqObj.Id);
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        Task tskObj = new Task();
        tskObj.WhatId = acc.Id;
        tskObj.Subject = 'test subject';
        insert tskObj;
        EmailSendController.getrecord(tskObj.Id);

        Test.stopTest();
    }
    static testMethod void testGetObjectName1(){
        Test.startTest();
        EmailSendController.getObjectName1();
        Test.stopTest();
    }
    static testMethod void testGetObjectName(){
        Test.startTest();
        EmailSendController.getObjectName();
        Test.stopTest();
    }
    static testMethod void testSendMailMethod(){
        Test.startTest();
        Financial_Request__c finreqObj = [SELECT Id, Subject__c FROM Financial_Request__c WHERE Subject__c = 'testSubject'];
        String relatedToRecord = finreqObj.Id;
        String addTo = '';
        String cc = 'vijay@cloudfastener.com';
        String bcc = 'vijay@cloudfastener.com';
        String toAddress = 'vijay@cloudfastener.com';
        String fromEmail = 'vijay@cloudfastener.com';
        String relatedToObject = finreqObj.Id;
        String mSubject = finreqObj.Subject__c;
        String mbody = 'Test Example template';
        String parentRecord = '';
        EmailSendController.sendMailMethod( relatedToRecord, addTo, cc, bcc, toAddress, fromEmail, relatedToObject, mSubject, mbody, parentRecord);
        Test.stopTest();
    }
    static testMethod void testGetEmailTemplateList(){
        Test.startTest();
        String folderId = UserInfo.getUserId();
        EmailSendController.getEmailTemplateList(folderId);
        Test.stopTest();
    }
    static testMethod void testGetUser(){
        Test.startTest();
       EmailSendController.getUser();
       Financial_Request__c finreqObj = [SELECT Id, Subject__c FROM Financial_Request__c WHERE Subject__c = 'testSubject'];
       EmailSendController.getContentDoc(finreqObj.Id);
        // EmailSendController.getEmailfromAdd();
        // EmailSendController.getEmailTempaltes1();
        // EmailSendController.getEmailTempaltes();
        // EmailSendController.getFolders();
        Test.stopTest();
    }
    static testMethod void testGetEmailfromAdd(){
        Test.startTest();
    //    EmailSendController.getUser();
    //    Financial_Request__c finreqObj = [SELECT Id, Subject__c FROM Financial_Request__c WHERE Subject__c = 'testSubject'];
    //    EmailSendController.getContentDoc(finreqObj.Id);
        EmailSendController.getEmailfromAdd();
        // EmailSendController.getEmailTempaltes1();
        // EmailSendController.getEmailTempaltes();
        // EmailSendController.getFolders();
        Test.stopTest();
    }
    static testMethod void testGetEmailTempaltes1(){
        Test.startTest();
        EmailSendController.getEmailTempaltes1();
        Test.stopTest();
    }
    static testMethod void testGetEmailTempaltes(){
        Test.startTest();
            EmailSendController.getEmailTempaltes();
        Test.stopTest();
    }
    static testMethod void testGetFolders(){
        Test.startTest();
            EmailSendController.getFolders();
        Test.stopTest();
    }
    static testMethod void testDelcontentDocument(){
        Test.startTest();
        Financial_Request__c finreqObj = [SELECT Id, Subject__c FROM Financial_Request__c WHERE Subject__c = 'testSubject'];
            EmailSendController.delcontentDocument(finreqObj.Id);
        Test.stopTest();
    }
}