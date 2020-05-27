@IsTest

public class ChatEscalatelandingPageControllerTest {
   
    static  testMethod void test1(){
        Test.startTest();
        
        Lead objLead = new Lead(
            FirstName='Test',
            LastName='Test',
            Email='test@pgi.com',
            CountryCode = 'US',
            LeadSource = 'Web Chat',
            Company = 'PGi',
            Status = 'Assigned',
            CurrencyISOCode = 'USD',
            RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('PGi Leads').getRecordTypeId());
        insert objLead;  
    
        LiveChatVisitor lcv = new LiveChatVisitor();
        INSERT lcv;
        
        LiveChatTranscript ctRecord = new LiveChatTranscript(LiveChatVisitorId = lcv.Id,
                                                             Email_Address__c='test@pgi.com',
                                                             Subject__c='Test',
                                                             First_Name__c='Test',
                                                             Last_Name__c='Test',
                                                             LeadId= objLead.Id,
                                                             Escalated_Lead__c = true,
                                                             Location_Country_Code__c = 'IE',
                                                             Location_Region__c = 'EMEA',
                                                             Company_Name__c = 'Test'
                                     );
        INSERT ctRecord;
        
        PageReference ref = new PageReference('/apex/ChatEscalateLandingPage'); 
        ref.getParameters().put('id', String.valueOf(ctRecord.Id));
        ref.getParameters().put('recordId', String.valueOf(ctRecord.LeadId));
        ref.getParameters().put('recordType', 'Lead');
        Test.setCurrentPage(ref);
                
                ChatEscalatelandingPageController con = new ChatEscalatelandingPageController();               
                con.viewRecord();
                Test.StopTest();
    }
    
}