/*Class Name        : EmployeePrfmMgmtTriggerHandlerTest
  Description       : Test class for EmployeePerformanceMgmtTriggerHandler.cls
  Developed By      : 
  Created On        : 
  Last Modified On  : 
*/
@isTest
public with sharing class EmployeePrfmMgmtTriggerHandlerTest {
    public EmployeePrfmMgmtTriggerHandlerTest() {

    }
    @testSetup static void setup() {
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User user1 = new User(
            ProfileId = pf.Id,
            LastName = 'testCF1',
            Email = 'testCF1@salesforce.com',
            Username = 'testCF01@salesforce.com' ,
            CompanyName = 'RT',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            EmployeeNumber = 'one'
       );
       insert user1;
       User user2 = new User(
            ProfileId = pf.Id,
            LastName = 'testCF2',
            Email = 'testCF2@salesforce.com',
            Username = 'testCF02@salesforce.com' ,
            CompanyName = 'RT',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            EmployeeNumber = 'two',
            ManagerId = user1.Id
       );
       insert user2;
       User user3 = new User(
        ProfileId = pf.Id,
        LastName = 'testCF3',
        Email = 'testCF3@salesforce.com',
        Username = 'testCF03@salesforce.com' ,
        CompanyName = 'RT',
        Title = 'title',
        Alias = 'alias',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        EmployeeNumber = 'one',
        ManagerId = user2.Id
    );
    insert user3;
    User user4 = new User(
            ProfileId = pf.Id,
            LastName = 'testCF4',
            Email = 'testCF4@salesforce.com',
            Username = 'testCF04@salesforce.com' ,
            CompanyName = 'RT',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            EmployeeNumber = 'two',
            ManagerId = user3.Id
        );
        insert user4;
    }
    @isTest
    public static void testUserInsert(){
        User usr = [SELECT Id, Username, LastName FROM User WHERE Username = 'testCF04@salesforce.com' AND IsActive = true];
        System.runAs(usr){
            Employee_Performance_Management__c obj = new Employee_Performance_Management__c();
            obj.OwnerId = usr.Id;
            insert obj;
            Integer countOfempperMgt = [SELECT count() FROM Employee_Performance_Management__Share];
            System.assertEquals(4, countOfempperMgt);
            // Employee_Performance_Management__Share empperMgt = [Select Id,ParentId,UserOrGroupId,AccessLevel from Employee_Performance_Management__Share where UserOrGroupId=:usr.Id];
            // System.assertEquals(obj.Id, empperMgt.ParentId);
       }
    }
    @isTest
    public static void testUserUpdate(){
        User usr3 = [SELECT Id, Username, LastName FROM User WHERE Username = 'testCF03@salesforce.com' AND IsActive = true];
        User usr4 = [SELECT Id, Username, LastName FROM User WHERE Username = 'testCF04@salesforce.com' AND IsActive = true];
        System.runAs(usr4){
            Employee_Performance_Management__c obj = new Employee_Performance_Management__c();
            obj.OwnerId = usr4.Id;
            Insert obj;
            obj.OwnerId = usr3.Id;
            update obj;
            Integer countOfempperMgt = [SELECT count() FROM Employee_Performance_Management__Share];
            System.assertEquals(3, countOfempperMgt);
            // Employee_Performance_Management__Share empperMgt= [Select Id,ParentId,UserOrGroupId,AccessLevel from Employee_Performance_Management__Share where UserOrGroupId=:usr3.Id];
            // System.assertEquals(obj.Id, empperMgt.ParentId);
       }
    }
    @isTest
    public static void testManagerChanged(){
        User usr = [SELECT Id, Username, LastName, IsActive FROM User WHERE Username = 'testCF04@salesforce.com' AND IsActive = true];
        User usr2 = [SELECT Id, Username, LastName FROM User WHERE Username = 'testCF02@salesforce.com' AND IsActive = true];

        System.runAs(usr){
            Employee_Performance_Management__c obj = new Employee_Performance_Management__c();
            obj.OwnerId = usr.Id;
            Insert obj;
            Integer countOfempperMgt = [SELECT count() FROM Employee_Performance_Management__Share];
            System.assertEquals(4, countOfempperMgt);
            // usr.IsActive = false;
            usr.ManagerId = usr2.Id;
            UPDATE usr;
            Integer countOfempperMgtafterRemovalOfShare = [SELECT count() FROM Employee_Performance_Management__Share];
            System.assertEquals(3, countOfempperMgtafterRemovalOfShare);
        }
    }
    @isTest
    public static void testUserInactive(){
        User usr = [SELECT Id, Username, LastName, IsActive FROM User WHERE Username = 'testCF04@salesforce.com' AND IsActive = true];
        User usr2 = [SELECT Id, Username, LastName FROM User WHERE Username = 'testCF02@salesforce.com' AND IsActive = true];
        System.runAs(usr){
            Employee_Performance_Management__c obj = new Employee_Performance_Management__c();
            obj.OwnerId = usr.Id;
            Insert obj;
            Integer countOfempperMgt = [SELECT count() FROM Employee_Performance_Management__Share];
            System.assertEquals(4, countOfempperMgt);
            usr2.LastName = 'x-TestCF2';
            usr2.IsActive = false;
            UPDATE usr2;
            Integer countOfempperMgtafterRemovalOfShare = [SELECT count() FROM Employee_Performance_Management__Share];
            System.assertEquals(2, countOfempperMgtafterRemovalOfShare);
        }
    }
}