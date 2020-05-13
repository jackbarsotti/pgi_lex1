@isTest
public with sharing class UpdateQuoteCEAPriorDateBatchTest {
    static testMethod void test(){
        Account accobj = new Account(Name = 'Test',Type = 'japan',website = 'http://google.com');
        Insert accobj;
        List<CONMAN_Contract__c > ccObjlist = new List<CONMAN_Contract__c > { new CONMAN_Contract__c(Account_Name__c = accobj.id,Contract_Document_Status__c = 'Active', Auto_Renewal_Interval_months__c = 12, CEA_Date_Prior_to_Renewal__c = Date.parse('11/20/2019'),
                                                                                                     CEA_Date_Active__c = Date.parse('11/10/2019')),
            new CONMAN_Contract__c(Account_Name__c = accobj.id,Contract_Document_Status__c = 'Active', Auto_Renewal_Interval_months__c = 0, CEA_Date_Prior_to_Renewal__c = Date.parse('10/18/2019'),
                                   CEA_Date_Active__c = Date.parse('11/10/2019'))};
                                       
                                       
                                       insert ccObjlist ;
        
        Test.startTest();
        UpdateQuoteCEAPriorDateScheduler sh1 = new UpdateQuoteCEAPriorDateScheduler ();
        String sch = '0 0 2 * * ?';
        system.schedule('UpdateQuoteCEAPriorDateBatch', sch, sh1);
        Test.stopTest();
        
         System.assertEquals(2, [SELECT COUNT() FROM CONMAN_Contract__c] );
       // System.assertEquals(Date.parse('11/10/2020'), [select id,CEA_Date_Active__c from CONMAN_Contract__c where Auto_Renewal_Interval_months__c =: 12].CEA_Date_Active__c );
    }
}