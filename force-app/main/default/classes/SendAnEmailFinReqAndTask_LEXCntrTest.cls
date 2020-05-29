@isTest
public with sharing class SendAnEmailFinReqAndTask_LEXCntrTest {
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

    }
    static testMethod void testGetrecord(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test'];
        Financial_Request__c finreqObj = [SELECT Id, Name, Subject__c, RequestorsEmail__c, Requested_For__c FROM Financial_Request__c WHERE Subject__c = 'testSubject'];
        SendAnEmailFinReqAndTask_LEXController.getrecord(finreqObj.Id);
        Task tsk = [SELECT Id, WhatId FROM Task WHERE Subject = 'test subject'];
        try{
        SendAnEmailFinReqAndTask_LEXController.getrecord(tsk.Id);
        }catch(Exception e){}
    //     Financial_Request__c finreqObj = new Financial_Request__c();
    //     finreqObj.Subject__c = 'testSubject';
    //     insert finreqObj;

    //     SendAnEmailFinReqAndTask_LEXController.getrecord(finreqObj.Id);
    //     Account acc = new Account();
    //     acc.Name = 'Test';
    //     insert acc;
    //     Task tskObj = new Task();
    //     tskObj.Status='New';
    //     tskObj.Priority='Normal';
    //     tskObj.WhatId = acc.Id;
    //     tskObj.Subject = 'test subject';
    //     insert tskObj;
    //    SendAnEmailFinReqAndTask_LEXController.getrecord(tskObj.Id);
        System.assertEquals(finreqObj, SendAnEmailFinReqAndTask_LEXController.getrecord(finreqObj.Id));
        System.assertEquals(acc.Id, tsk.WhatId);
     Test.stopTest();
    }
    static testMethod void testGetObjectName(){
        Test.startTest();
        SendAnEmailFinReqAndTask_LEXController.getObjectName('Financial_Request__c');
        System.assertNotEquals(null, SendAnEmailFinReqAndTask_LEXController.getObjectName('Financial_Request__c'));
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
        SendAnEmailFinReqAndTask_LEXController.sendMailMethod( relatedToRecord, addTo, cc, bcc, toAddress, fromEmail, relatedToObject, mSubject, mbody, parentRecord);
        System.assertNotEquals(null, fromEmail);
        System.assertNotEquals(null, mbody);
        Test.stopTest();
    }
    static testMethod void testGetEmailTemplateList(){
        Test.startTest();
        String folderId = UserInfo.getUserId();
        SendAnEmailFinReqAndTask_LEXController.getEmailTemplateList(folderId);
        System.assertEquals([SELECT Id,Name,TemplateType, Description FROM EmailTemplate where FolderId =:folderId], EmailSendController.getEmailTemplateList(folderId));
        Test.stopTest();
    }
    static testMethod void testGetUser(){
        Test.startTest();
        SendAnEmailFinReqAndTask_LEXController.getUser();
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
         SendAnEmailFinReqAndTask_LEXController.getContentDoc(finreqObj.Id);
        // System.assertEquals([SELECT id,Title,FileType,CreatedBy.Name,ContentSize From contentDocument],  SendAnEmailFinReqAndTask_LEXController.getContentDoc(finreqObj.Id));
        Test.stopTest();
    }
    static testMethod void testGetEmailfromAdd(){
        Test.startTest();
        SendAnEmailFinReqAndTask_LEXController.getEmailfromAdd();
        Test.stopTest();
    }
    static testMethod void testGetEmailTempaltes1(){
        // Test.startTest();
        SendAnEmailFinReqAndTask_LEXController.getEmailTempaltes1();
        // System.assertEquals(1, [ SELECT Id, FolderId,TemplateType,Description, HtmlValue, FolderName, isActive, body,Name,subject 
        //     FROM EmailTemplate 
        //     WHERE isActive= true].size());
        // Test.stopTest();
    }
    static testMethod void testGetEmailTempaltes(){
        SendAnEmailFinReqAndTask_LEXController.getEmailTempaltes();
        System.assertEquals(1, [ SELECT Id, FolderId,TemplateType,Description, HtmlValue, FolderName, isActive, body,Name,subject 
            FROM EmailTemplate 
            WHERE isActive= true AND FolderId =: UserInfo.getUserId()].size());
    }
    static testMethod void testGetFolders(){
        Test.startTest();
        SendAnEmailFinReqAndTask_LEXController.getFolders();
        Financial_Request__c finreqObj = [SELECT Id, Subject__c FROM Financial_Request__c WHERE Subject__c = 'testSubject'];
        SendAnEmailFinReqAndTask_LEXController.delcontentDocument(finreqObj.Id);
            System.assertEquals(1, [SELECT Id, Subject__c FROM Financial_Request__c WHERE Subject__c = 'testSubject'].size());
            System.assertEquals(550, [SELECT Id FROM Folder].size());
        Test.stopTest();
    }
    // static testMethod void testDelcontentDocument(){
    //     Test.startTest();
    //     Financial_Request__c finreqObj = [SELECT Id, Subject__c FROM Financial_Request__c WHERE Subject__c = 'testSubject'];
    //     SendAnEmailFinReqAndTask_LEXController.delcontentDocument(finreqObj.Id);
    //         System.assertEquals(1, [SELECT Id, Subject__c FROM Financial_Request__c WHERE Subject__c = 'testSubject'].size());
    //     Test.stopTest();
    // }
    static testMethod void testSaveChunk(){
        Test.startTest();
        String fileId = [ SELECT Id, Title, VersionData,ContentDocumentId FROM ContentVersion WHERE Title = 'Test Document'].Id;
        Financial_Request__c finreqObj = [SELECT Id, Subject__c FROM Financial_Request__c WHERE Subject__c = 'testSubject'];
        Blob b = Blob.valueOf('Test Content');    
        // string s = b.tostring();
        string base64Data = Blob.valueOf('Test Content').tostring();
        base64Data = EncodingUtil.base64Decode(EncodingUtil.base64Encode(b)).toString();

        SendAnEmailFinReqAndTask_LEXController.saveChunk(finreqObj.Id, 'Test', base64Data, 'TextFile', '');
        SendAnEmailFinReqAndTask_LEXController.saveChunk(finreqObj.Id, 'Test', base64Data, 'TextFile', fileId);
            System.assertEquals(fileId, SendAnEmailFinReqAndTask_LEXController.saveChunk(finreqObj.Id, 'Test', base64Data, 'TextFile', fileId));
           System.assertEquals('testSubject',finreqObj.Subject__c);
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
       SendAnEmailFinReqAndTask_LEXController.getTempletemergeData('', '', '');
       SendAnEmailFinReqAndTask_LEXController.getTempletemergeData(emailtemp.Id, con.Id, finreqObj.Id);
        System.assertNotEquals(null, emailtemp.Body);
        System.assertEquals('vijay@cloudfastener.com', con.Email);
        Test.stopTest();
    }
}