@IsTest

public class SubmitLeadControllerTest {
   
    static  testMethod void sales_agent_test(){
        Test.startTest(); 
    
        LiveChatVisitor lcv = new LiveChatVisitor();
        INSERT lcv;
        
        LiveChatTranscript ctRecord = new LiveChatTranscript(LiveChatVisitorId = lcv.Id,
                                                             Email_Address__c='test@pgi.com',
                                                             Subject__c='Test',
                                                             First_Name__c='Test',
                                                             Last_Name__c='Test',
                                                             Escalated_Lead__c = false,
                                                             Location_Country_Code__c = 'IE',
                                                             Location_Region__c = 'EMEA',
                                                             Company_Name__c = 'Test'
                                     );
        INSERT ctRecord;
    
       // String FirstName;
       // String LastName;
       // String Company;
       // String Email;
      //  String Phone;
        
        PageReference ref = new PageReference('/apex/Chat_SubmitLead'); 
        ref.getParameters().put('id', String.valueOf(ctRecord.Id));
        Test.setCurrentPage(ref);    
            
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('PGi Leads').getRecordTypeId();
         
             Lead l = new Lead();
                
                SubmitLeadController con = new SubmitLeadController();               
                con.init();
                con.submitLead();
                Test.StopTest();
    }
    
   static  testMethod void care_agent_test(){
               Test.startTest(); 
    
        LiveChatVisitor lcv = new LiveChatVisitor();
        INSERT lcv;
        
        LiveChatTranscript ctRecord = new LiveChatTranscript(LiveChatVisitorId = lcv.Id,
                                                             Email_Address__c='test@pgi.com',
                                                             Subject__c='Test',
                                                             First_Name__c='Test',
                                                             Last_Name__c='Test',
                                                             Escalated_Lead__c = false,
                                                             Location_Country_Code__c = 'US',
                                                             Location_Region__c = 'NA',
                                                             Company_Name__c = 'Test'
                                     );
        INSERT ctRecord;
    
       // String FirstName;
       // String LastName;
       // String Company;
       // String Email;
      //  String Phone;
        
        PageReference ref = new PageReference('dev-pgi.cs26.force.com/chatcustompage/Chat_SubmitLead'); 
        ref.getParameters().put('id', String.valueOf(ctRecord.Id));
        Test.setCurrentPage(ref);    
            
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('PGi Leads').getRecordTypeId();
         
             Lead l = new Lead();
                
                SubmitLeadController con = new SubmitLeadController();               
                con.init();
                con.submitLead();
                Test.StopTest();
   
   }
}