@isTest
public without sharing class VersionTriggerHandlerTest {
    @testSetup static void setup() {
        Contract_Terms__c contractObject = new Contract_Terms__c(
            Language__c = 'en_US',
            Name = 'Test 001',
            Unique_ID__c = 'Test Unique'
        );
        Insert contractObject;
        Contract_Terms__c contractObject2 = new Contract_Terms__c(
            Language__c = 'en_UK',
            Name = 'Test 002',
            Unique_ID__c = 'Test Unique 1'
        );
        Insert contractObject2;
    }
    static  testmethod void testCreateNewAttachment(){
        Contract_Terms__c contractObject = [SELECT Language__c, Name, Version_History__c
                                            FROM Contract_Terms__c 
                                            WHERE name = 'Test 001' ];
        contractObject.Language__c = 'en_UK';
        UPDATE contractObject; 
        String verHistoryId = [SELECT  Version_History__c FROM Contract_Terms__c 
                                WHERE id =: contractObject.Id].Version_History__c;
        AggregateResult agregatedResults =[SELECT ParentId, COUNT(Id) size 
                                            FROM Attachment 
                                            WHERE ParentId =: verHistoryId
                                            GROUP BY ParentId ]; 
         System.assertEquals(2,agregatedResults.get('size'));       
    }
    static  testmethod void testExsitingAttachment(){
        Contract_Terms__c contractObject = [SELECT Language__c, Name,Version_History__c 
                                            FROM Contract_Terms__c
                                            WHERE name = 'Test 002' ];
        contractObject.Language__c = 'en_US';
        UPDATE contractObject;   
        contractObject.Name ='Test 003';
        UPDATE contractObject;   
        String verHistoryId = [SELECT  Version_History__c FROM Contract_Terms__c 
                                WHERE id =: contractObject.Id].Version_History__c;
        AggregateResult agregatedResults = [SELECT ParentId, COUNT(Id) size 
                                            FROM Attachment 
                                            WHERE ParentId =: verHistoryId
                                            GROUP BY ParentId ]; 
       System.assertEquals(3,agregatedResults.get('size'));  
    }
}