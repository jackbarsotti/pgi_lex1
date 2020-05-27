@IsTest
public class SubmitFinReqControllerTest {
    
    static testMethod void testController() {
        
        SubmitFinReqController objFinReqCtrl = new SubmitFinReqController();
        
        PageReference objPageRef = objFinReqCtrl.submitFinReq();
    }
    
    static  testMethod void submitEscalatedFinReqTest(){
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
                                                             Location_Region__c = 'EMEA'
                                     );
        INSERT ctRecord; 
        
        PageReference ref = new PageReference('/apex/Chat_SubmitEscalatedFinReq'); 
        ref.getParameters().put('id', String.valueOf(ctRecord.Id));
        Test.setCurrentPage(ref);    
            
        Id recordTypeId = Schema.SObjectType.Financial_Request__c.getRecordTypeInfosByName().get('PGi-Billing Support').getRecordTypeId();
                
                SubmitFinReqController con = new SubmitFinReqController();               
                con.init();
                con.submitEscalatedFinReq();
                Test.StopTest();
    }
    
}