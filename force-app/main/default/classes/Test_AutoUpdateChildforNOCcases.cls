@isTest
public class Test_AutoUpdateChildforNOCcases{
    static testMethod void autoupdatechild(){
        
        Id nOCRecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('PGi-Parent Ticket (NOC)').getRecordTypeId();
        Case parentcase = new Case();
        parentcase.Status = 'New';
        parentcase.Subject = 'Test NOC';
        parentcase.Description = 'test desc';
        parentcase.RecordtypeId = nOCRecordtypeIdCase;
        parentcase.Impact_Level__c = 'Low';
        parentcase.Urgency_Level__c = 'Low';
        parentcase.Origin = 'Case Submission';
        parentcase.X911_Bridge_Convened_Recorded__c = 'No';
        parentcase.X411_Bridge_Convened_Recorded__c = 'No';
        parentcase.How_was_Outage_Detected__c = 'Monitoring';
        parentcase.Does_Monitoring_Exist__c = 'No';
        parentcase.Temporary_Fix__c = 'No';
        parentcase.Caused_by_Change__c = 'No';  
        parentcase.Tracking_Root_Category__c = 'Billing';  
        
        insert parentcase;
        
        Id externalSupportRT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('PGi-Client External Support').getRecordTypeId();
        Case childcase = new Case();
        childcase.Status = 'New';
        childcase.Subject = 'Child NOC';
        childcase.Description = 'test desc';
        childcase.RecordtypeId = externalSupportRT;
        childcase.Impact_Level__c = 'Low';
        childcase.Urgency_Level__c = 'Low';
        childcase.Origin = 'Case Submission';
        childcase.X911_Bridge_Convened_Recorded__c = 'No';
        childcase.X411_Bridge_Convened_Recorded__c = 'No';
        childcase.How_was_Outage_Detected__c = 'Monitoring';
        childcase.Does_Monitoring_Exist__c = 'No';
        childcase.Temporary_Fix__c = 'No';
        childcase.Caused_by_Change__c = 'No';  
        childcase.Parentid = parentcase.id;  
        childcase.Tracking_Root_Category__c = null;
        
        insert childcase;
        
        Test.startTest();
        
        parentcase.Status = 'Closed';
        update parentcase;
        
        Case c = [SELECT id,Tracking_Root_Category__c FROM Case where id =: childcase.id];
        system.assertequals(c.Tracking_Root_Category__c,'Billing');
        
        Test.stopTest();
    }
}