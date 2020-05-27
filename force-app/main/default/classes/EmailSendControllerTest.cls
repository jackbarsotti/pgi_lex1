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
        Contact con = new Contact(LastName= 'Test', Email='vijay@cloudfastener.com');
        insert con;

        Task tskObj = new Task();
        tskObj.WhatId = acc.Id;
        tskObj.Subject = 'test subject';
        insert tskObj;

        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = finreqObj.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;

        EmailTemplate emailtemp = new EmailTemplate();
        emailtemp.isActive = true;
        emailtemp.Name = 'testName';
        emailtemp.DeveloperName = 'Test_Send_Mail';
        emailtemp.Subject = 'test Email Subject';
        emailtemp.Body = 'Test Email Body';
        emailtemp.TemplateType = 'text';
        emailtemp.FolderId = UserInfo.getUserId();
        insert emailtemp;
    }
    static testMethod void testGetrecord(){
        Test.startTest();
        Financial_Request__c finreqObj = [SELECT Id, Subject__c FROM Financial_Request__c WHERE Subject__c = 'testSubject'];
        Contact con = new Contact(LastName= 'Test', Email='vijay@cloudfastener.com');
        insert con;
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
        System.assertEquals(finreqObj, EmailSendController.getrecord(tskObj.Id));
        Test.stopTest();
    }
    static testMethod void testGetObjectName1(){
        Test.startTest();
        EmailSendController.getObjectName1();
        System.assertNotEquals(null, EmailSendController.getObjectName1());
        Test.stopTest();
    }
    static testMethod void testGetObjectName(){
        Test.startTest();
        EmailSendController.getObjectName();
        System.assertNotEquals(null, EmailSendController.getObjectName());
        Test.stopTest();
    }
    static testMethod void testSendMailMethod(){
        Test.startTest();
        Financial_Request__c finreqObj = [SELECT Id, Subject__c FROM Financial_Request__c WHERE Subject__c = 'testSubject'];
         //Create Document
         ContentVersion cv = new ContentVersion();
         cv.Title = 'Test Document';
         cv.PathOnClient = 'TestDocument.pdf';
         cv.VersionData = Blob.valueOf('Test Content');
         cv.IsMajorVersion = true;
         Insert cv;
         
         //Get Content Documents
         Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
         
         //Create ContentDocumentLink 
         ContentDocumentLink cdl = New ContentDocumentLink();
         cdl.LinkedEntityId = finreqObj.Id;
         cdl.ContentDocumentId = conDocId;
         cdl.shareType = 'V';
         Insert cdl;
        Contact con = new Contact(LastName= 'Test', Email='vijay@cloudfastener.com');
        insert con;
        
        String relatedToRecord = finreqObj.Id;
        String addTo = '';
        String cc = 'vijay@cloudfastener.com';
        String bcc = 'vijay@cloudfastener.com';
        String toAddress = con.Id;
        String fromEmail = 'vijay@cloudfastener.com';
        String relatedToObject = finreqObj.Id;
        String mSubject = finreqObj.Subject__c;
        String mbody = 'Test Example template';
        String parentRecord = finreqObj.Id;
        EmailSendController.sendMailMethod( relatedToRecord, addTo, cc, bcc, toAddress, fromEmail, relatedToObject, mSubject, mbody, parentRecord);
        System.assertNotEquals(null, fromEmail);
        Test.stopTest();
    }
    static testMethod void testGetEmailTemplateList(){
        Test.startTest();
        String folderId = UserInfo.getUserId();
        EmailSendController.getEmailTemplateList(folderId);
        System.assertEquals([SELECT Id,Name,TemplateType, Description FROM EmailTemplate where FolderId =:folderId], EmailSendController.getEmailTemplateList(folderId));
        Test.stopTest();
    }
    static testMethod void testGetUser(){
        Test.startTest();
       EmailSendController.getUser();
       Financial_Request__c finreqObj = [SELECT Id, Subject__c FROM Financial_Request__c WHERE Subject__c = 'testSubject'];
       ContentVersion cv = new ContentVersion();
         cv.Title = 'Test Document';
         cv.PathOnClient = 'TestDocument.pdf';
         cv.VersionData = Blob.valueOf('Test Content');
         cv.IsMajorVersion = true;
         Insert cv;
         
         //Get Content Documents
         Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
         
         //Create ContentDocumentLink 
         ContentDocumentLink cdl = New ContentDocumentLink();
         cdl.LinkedEntityId = finreqObj.Id;
         cdl.ContentDocumentId = conDocId;
         cdl.shareType = 'V';
         Insert cdl;
        EmailSendController.getContentDoc(finreqObj.Id);
        // System.assertEquals([SELECT id,Title,FileType,CreatedBy.Name,ContentSize From contentDocument],  EmailSendController.getContentDoc(finreqObj.Id));
        Test.stopTest();
    }
    static testMethod void testGetEmailfromAdd(){
        Test.startTest();
            EmailSendController.getEmailfromAdd();
            System.assertNotEquals(null, EmailSendController.getEmailfromAdd());
        Test.stopTest();
    }
    static testMethod void testGetEmailTempaltes1(){
        Test.startTest();
        try{
        EmailSendController.getEmailTempaltes1();
        }catch(Exception e){
        }
        Test.stopTest();
    }
    static testMethod void testGetEmailTempaltes(){
        Test.startTest();
        try{
            EmailSendController.getEmailTempaltes();
        }catch(Exception e){
        }
        Test.stopTest();
    }
    static testMethod void testGetFolders(){
        Test.startTest();
            EmailSendController.getFolders();
            System.assertEquals(550, [SELECT Id FROM Folder].size());
        Test.stopTest();
    }
    static testMethod void testDelcontentDocument(){
        Test.startTest();
        Financial_Request__c finreqObj = [SELECT Id, Subject__c FROM Financial_Request__c WHERE Subject__c = 'testSubject'];
            EmailSendController.delcontentDocument(finreqObj.Id);
            System.assertEquals(1, [SELECT Id, Subject__c FROM Financial_Request__c WHERE Subject__c = 'testSubject'].size());
        Test.stopTest();
    }
    static testMethod void testSaveChunk(){
        Test.startTest();
        String fileId = [ SELECT Id, Title, VersionData,ContentDocumentId FROM ContentVersion WHERE Title = 'Test Document'].Id;
        Financial_Request__c finreqObj = [SELECT Id, Subject__c FROM Financial_Request__c WHERE Subject__c = 'testSubject'];
        Blob b = Blob.valueOf('Test Content');    
        // string s = b.tostring();
        string base64Data = Blob.valueOf('Test Content').tostring();
        base64Data = EncodingUtil.base64Decode(EncodingUtil.base64Encode(b)).toString();

        EmailSendController.saveChunk(finreqObj.Id, 'Test', base64Data, 'TextFile', '');
            EmailSendController.saveChunk(finreqObj.Id, 'Test', base64Data, 'TextFile', fileId);
            System.assertEquals(fileId, EmailSendController.saveChunk(finreqObj.Id, 'Test', base64Data, 'TextFile', fileId));
        Test.stopTest();
    }
       static testMethod void testgetTempletemergeData(){
        Test.startTest();
        Contact con = [SELECT Id, LastName, Email FROM Contact WHERE LastName= 'Test'];
        Financial_Request__c finreqObj = [SELECT Id, Subject__c FROM Financial_Request__c WHERE Subject__c = 'testSubject'];

        EmailTemplate emailtemp = new EmailTemplate();
        emailtemp.isActive = true;
        emailtemp.Name = 'testName';
        emailtemp.DeveloperName = 'Test_Send_Mail';
        emailtemp.Subject = 'test Email Subject';
        emailtemp.Body = 'Test Email Body';
        emailtemp.TemplateType = 'text';
        emailtemp.FolderId = UserInfo.getUserId();
        insert emailtemp;
       // EmailTemplate emailtemp = [SELECT Id, Name, DeveloperName, Subject, Body, TemplateType, isActive, FolderId FROM EmailTemplate WHERE DeveloperName = 'Test_Send_Mail'];
        EmailSendController.getTempletemergeData('', '', '');
        EmailSendController.getTempletemergeData(emailtemp.Id, con.Id, finreqObj.Id);
        System.assertNotEquals(null, emailtemp.Body);
        // String folderId = UserInfo.getUserId();
        // List<EmailTemplate> emailTempList = EmailSendController.getEmailTemplateList(folderId);

        // EmailTemplate emailTemp1 = [SELECT Id,Name,TemplateType, Description  
        //                             FROM EmailTemplate  
        //                             WHERE FolderId =: UserInfo.getUserId() LIMIT 1];
        // EmailSendController.getTempletemergeData(emailTemp1.Id, '', '');
        // // EmailSendController.getTempletemergeData(emailTempList[0].Id, '', '');
        // EmailSendController.getEmailTempaltes1();
        Test.stopTest();
    }
}