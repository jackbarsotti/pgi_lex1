@isTest
public with sharing class VersioningProcessControllerTest {
    @testSetup static void setup() {
        Contract_Terms__c contractObject = new Contract_Terms__c(
            Language__c = 'en_US',
            Name = 'Test 001',
            Unique_ID__c = 'Test Unique'
        );
        Insert contractObject;
        contractObject.Language__c = 'en_UK';
        UPDATE contractObject;
        contractObject.Language__c = 'en_US';
        UPDATE contractObject;
        contractObject.Language__c = 'en_UK';
        UPDATE contractObject;
        // PGIServicesInformation__c verbiage = new PGIServicesInformation__c(
        //                                     Name='Testing', 
        //                                     Agreement_Type__c='Subscription License Order', 
        //                                     Section__c='Intro', 
        //                                     Order__c=1, Content_RTF__c='Original General Terms', 
        //                                     Unique_ID__c='1');
        // insert verbiage;
    }
    static  testmethod void testCompareVersions(){
        Attachment attachObject = [SELECT Id, Name, ParentId From Attachment LIMIT 1];
        
        Test.StartTest(); 
        Version_History__c vh = [SELECT Id FROM Version_History__c LIMIT 1];
        PageReference pageRef = Page.VersioningProcess;
        pageRef.getParameters().put('Id', vh.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(vh); 
        VersioningProcessController controller = new VersioningProcessController(sc);
        List<SelectOption> versionOption = controller.versionOption;
        // controller.getValuestocompare();
        // Test.StopTest();
        // List<Attachment> attachmentList = [SELECT id, ParentId, Name 
        //                                     FROM Attachment Where ParentId =: vh.Id];
        // system.assertEquals(4, attachmentList.size());
    }
    static  testmethod void testreturnToSobject(){
        Version_History__c vh = [SELECT Id FROM Version_History__c LIMIT 1];
        PageReference pageRef = Page.VersioningProcess;
        pageRef.getParameters().put('Id', vh.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(vh); 
        VersioningProcessController controller = new VersioningProcessController(sc);
        controller.returnSobject =true;

        controller.returnToSobject();
        system.assertEquals('Contract_Terms__c', controller.sObjectName);

    }

    // static  testmethod void testSaveVersionHistory(){
    //     Attachment attachObject = [SELECT Id, Name, ParentId From Attachment LIMIT 1];
    //     Contract_Terms__c objContract = [Select Language__c,Name,Unique_Id__c from Contract_Terms__c Where Name ='Test 001'];
    //     Version_History__c vh = [SELECT Id FROM Version_History__c LIMIT 1];
    //     Test.StartTest(); 
    //     PageReference pageRef = Page.ContractTermsAttachmentList;
    //     pageRef.getParameters().put('Id', vh.Id);
    //     // pageRef.getParameters().put('ParentId', objContract.Id);
    //     Test.setCurrentPage(pageRef);
    //     ApexPages.StandardController sc = new ApexPages.standardController(attachObject); 
    //     VersioningProcessController controller = new VersioningProcessController(sc);
        
    //     controller.saveVersionHistory();
    //     Id verHistoryId = [SELECT Version_History__c FROM Contract_Terms__c WHERE Name ='Test 001'].Version_History__c;
    //     AggregateResult agregatedResults = [SELECT ParentId, COUNT(Id) size 
    //                                         FROM Attachment 
    //                                         WHERE ParentId =: verHistoryId
    //                                         GROUP BY ParentId ]; 
    //     System.assertEquals(4,agregatedResults.get('size'));
    //     Test.StopTest();
    // }
    // static  testmethod void testSaveVersionHistory1(){
        
    //     Contract_Terms__c contractObject = new Contract_Terms__c(
    //         Language__c = 'en_US',
    //         Name = 'Test 0011',
    //         Unique_ID__c = 'Test Unique1'
    //     );
    //     Insert contractObject;
    //     Attachment attachObject = [SELECT Id, Name, ParentId From Attachment LIMIT 1];
    //     Version_History__c vh = [SELECT Id FROM Version_History__c LIMIT 1];
    //     Test.StartTest(); 
    //     PageReference pageRef = Page.ContractTermsAttachmentList;
    //     pageRef.getParameters().put('Id', vh.Id);
    //     // pageRef.getParameters().put('ParentId', contractObject.Id);
    //     Test.setCurrentPage(pageRef);
    //     ApexPages.StandardController sc = new ApexPages.standardController(attachObject); 
    //     VersioningProcessController controller = new VersioningProcessController(sc);
        
    //     controller.saveVersionHistory();
    //     Id verHistoryId = [SELECT Version_History__c FROM Contract_Terms__c WHERE Name ='Test 0011'].Version_History__c;
    //     AggregateResult agregatedResults = [SELECT ParentId, COUNT(Id) size 
    //                                         FROM Attachment 
    //                                         WHERE ParentId =: verHistoryId
    //                                         GROUP BY ParentId ]; 
    //     System.assertEquals(2,agregatedResults.get('size'));
    //     Test.StopTest();
    // }

}