@isTest
public without sharing class VersioningTriggerHandlerTest {
    @testSetup static void setup() {
        PGIServicesInformation__c cgcObj= new PGIServicesInformation__c();
        cgcObj.Name='Test';
        cgcObj.Agreement_Type__c='Service Agreement';
        cgcObj.Order__c=2;
        cgcObj.Unique_ID__c='Test';
        cgcObj.Section__c='Intro';
        Insert cgcObj;
    }
    // static  testmethod void testSaveVersionHistory(){
    //     Test.startTest();
    //    PGIServicesInformation__c  cgcObj = [Select Name,Agreement_Type__c,Order__c,Unique_ID__c,Section__c from PGIServicesInformation__c where Name='Test'];
    //     List<Version_History__c> verHisLst =[Select Name from Version_History__c];
    //     Attachment att = new Attachment();
    //     att.Name='Test';
    //     att.ParentId=verHisLst[0].Id;
    //     Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    //     att.Body=bodyBlob;
    //     Insert att;
        
    //     System.assertEquals(verHisLst.size(), 1);
    //     test.stopTest();
    // }
    
    static  testmethod void testSaveAttachment(){
        Test.startTest();
       PGIServicesInformation__c  cgcObj = [Select Name,Agreement_Type__c,Order__c,Unique_ID__c,Section__c from PGIServicesInformation__c where Name='Test'];
        List<Version_History__c> verHisLst =[Select Name from Version_History__c];
        Attachment att = new Attachment();
        att.Name='Test';
        att.ParentId=verHisLst[0].Id;
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        att.Body=bodyBlob;
        Insert att;
        cgcObj .Name='Test1';
        update cgcObj ;
        List<Attachment> cretedAttachment = [Select Id,Name From Attachment];
        System.assertEquals(cretedAttachment.size(), 3);
        System.assertEquals(verHisLst.size(), 1);
        test.stopTest();
    }
}