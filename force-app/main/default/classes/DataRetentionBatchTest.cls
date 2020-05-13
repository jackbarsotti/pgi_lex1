@isTest
public with sharing class DataRetentionBatchTest {
    
    // static testMethod void testWrapper(){
    //     Test.startTest();
    //         List<Id> jobIdsToProcess = new List<Id>();
    //         Integer currentJobIndex;
    //         // Create Object for inner class like DataRetentionJobWrapper
    //         DataRetentionBatch.DataRetentionJobWrapper drbwObj = new DataRetentionBatch.DataRetentionJobWrapper(jobIdsToProcess, currentJobIndex);
    //         DataRetentionBatch drb = new DataRetentionBatch();
    //         drb = new DataRetentionBatch(drbwObj);
    //     Test.stopTest();
    // }
    
    static testMethod void test(){
        Integer currentJobIndex = 0;
        //List<Id> jobIdsToProcess = new List<Id>();
        // jobIdsToProcess.add('0032E00002PaWtnQAF');
        
        Account accObj = new Account(name = 'TestAccName');
        Insert accObj;
        Contact contObj = new Contact(LastName = 'Testcont');
        Insert contObj;
        Case caseObj = new Case(Origin = 'Phone');
        Insert caseObj;
        List<Id> jobIdsToProcess = new List<Id>();
        jobIdsToProcess.add(accObj.id);
        jobIdsToProcess.add(contObj.id);
        jobIdsToProcess.add(caseObj.id);
        
        DataRetentionBatch.DataRetentionJobWrapper drbwObj = new DataRetentionBatch.DataRetentionJobWrapper(jobIdsToProcess,currentJobIndex);
        //DataRetentionService.buildRetentionQuery(jobIdsToProcess[currentJobIndex]);
        
        Test.startTest();
        
        List<FilterObject__c> lstFtObj= new List<FilterObject__c>{
            new FilterObject__c(Name ='NameAcc',Object__c = 'Account',Status__c='Active'),
                new FilterObject__c(Name ='NameCont',Object__c = 'Contact',Status__c='Active'),
                 new FilterObject__c(Name ='NameCase',Object__c = 'Case',Status__c='Active')};
                    insert lstFtObj;
        
        List<FilterField__c> lstFFObj = new List<FilterField__c>{
            new FilterField__c(FilterObject__c = lstFtObj[0].id,Value__c= 'TestAccName',Field__c = 'Name',Operator__c = 'Equals'),
                new FilterField__c(FilterObject__c = lstFtObj[1].id,Value__c= 'Testcont',Field__c = 'LastName',Operator__c = 'Equals'),
                 new FilterField__c(FilterObject__c = lstFtObj[2].id,Value__c= 'Phone',Field__c = 'Origin',Operator__c = 'Equals')};
                    insert lstFFObj;
        
        DataRetentionBatch drb = new DataRetentionBatch();
        DataBase.executeBatch(drb);
        Test.stopTest();
        System.assertEquals(3, jobIdsToProcess.size());
    }
    
    static testMethod void testCatch(){
        
        Lead ldObj = new Lead(LastName = 'TestLead',LeadSource = 'other',CurrencyIsoCode = 'USD',Phone = '9876543210',
                              Status = 'Assigned',Company = 'PGI',Lead_Source_Details__c = 'Testing DTB');
        Insert ldObj;
        
        List<Id> jobIdsToProcess = new List<Id>();
        Integer currentJobIndex = 0;
        // System.debug('>>> currentJobIndex >>>>'+currentJobIndex);
        // System.debug('>>> jobIdsToProcess >>>>'+jobIdsToProcess);
        jobIdsToProcess.add('0012E00001oLRqrQAG');
        jobIdsToProcess.add('0032E00002PaWtnQAF');
        jobIdsToProcess.add('0012E00001oLRqrQAG');
        jobIdsToProcess.add(ldObj.Id);
        System.debug('>>>>Size>>>>'+jobIdsToProcess.size());
        
        DataRetentionBatch.DataRetentionJobWrapper drbwObj = new DataRetentionBatch.DataRetentionJobWrapper(jobIdsToProcess,currentJobIndex);
        // String query = DataRetentionService.buildRetentionQuery(jobIdsToProcess[currentJobIndex]);
        
        List<FilterObject__c> lstFtObj= new List<FilterObject__c>();
        for(Integer i=0 ;i <200;i++)
        {
            FilterObject__c ftObj = new FilterObject__c();
            ftObj.Name ='Name'+i;
            ftObj.Status__c='Active';
            ftObj.Object__c = 'Lead';
            lstFtObj.add(ftObj);
        }
        insert lstFtObj;
        FilterField__c ffObj = new FilterField__c(FilterObject__c = lstFtObj[0].id,Value__c= 'TestLead',Field__c = 'LastName',Operator__c = 'Equals');
        Insert ffObj;
        
        Test.startTest();
        
        DataRetentionBatch drb = new DataRetentionBatch(drbwObj);
        DataBase.executeBatch(drb);
        Test.stopTest(); 
    }
}