@IsTest
public with sharing class ChatTranscriptDetailControllerTest {

    static testMethod void test1() {
        Test.startTest();
    
        LiveChatVisitor lcv = new LiveChatVisitor();
        INSERT lcv;

        List<RecordType> lstRecordType = [select id from recordType where SobjectType='Case' and Name ='PGi_Client_External_Support' ];        
        Case c = new Case();
        if(lstRecordType.size() > 0)
            {
                c.recordTypeId =lstRecordType[0].id;
            }
        INSERT c;
        
        
        List<RecordType> lstRecordTypeFinReq = [select Id from recordType where SobjectType='FinReq' and Name ='Billing_Support' ];          
        Financial_Request__c f = new financial_Request__c();
        if(lstRecordTypeFinReq.size() > 0)
            {
                f.recordTypeId =lstRecordTypeFinReq[0].id;
            }
        INSERT f;
        
        List<RecordType> lstRecordTypeLead = [select Id from recordType where SobjectType='Lead' and Name ='PGi_Leads' ];
        Lead l = new Lead(FirstName = 'Test',
                          LastName = 'Test',
                          Company = 'Test',
                          Email = 'test@pgi.com'
                          );
        if(lstRecordTypeLead.size() > 0)
            {
                l.recordTypeId =lstRecordTypeLead[0].id;
            }                  
        INSERT l;
        
        LiveChatTranscript ctRecord = new LiveChatTranscript(Name__c = 'Test1',
                                      CaseId = c.Id,
                                      Financial_Request__c = f.Id,
                                      LeadId = l.Id,
                                      LiveChatVisitorId = lcv.Id,
                                      Escalated__c = false,
                                      Escalated_FinReq__c = false,
                                      Escalated_Lead__c = false 
                                      );
        INSERT ctRecord;
        
        PageReference ref = new PageReference('/apex/vfpage'); 
        ref.getParameters().put('id', String.valueOf(ctRecord.Id));
        Test.setCurrentPage(ref);
        
        Id currentRecordId  = ApexPages.CurrentPage().getparameters().get('id'); 
        
        LiveChatTranscript temp = [SELECT CaseId, Financial_Request__c, LeadId, Escalated__c, Escalated_FinReq__c, Escalated_Lead__c
        FROM LiveChatTranscript
        WHERE Id =:currentRecordId];

        ctRecord.CaseId = temp.CaseId;
        ctRecord.Financial_Request__c = temp.Financial_Request__c;
        ctRecord.LeadId = temp.LeadId;    
        ctRecord.Escalated__c = temp.Escalated__c;
        ctRecord.Escalated_FinReq__c = temp.Escalated_FinReq__c;
        ctRecord.Escalated_Lead__c = temp.Escalated_Lead__c;
        update ctRecord;

        ApexPages.StandardController sc = new ApexPages.StandardController(ctRecord);
        ChatTranscriptDetailController ext = new ChatTranscriptDetailController(sc);
        System.assertNotEquals(null, ext.Redirecttocase());        
        
        System.assertEquals(ctRecord.CaseId,temp.CaseId);
        ext.updatePage();
        Test.StopTest();   
    } 
}