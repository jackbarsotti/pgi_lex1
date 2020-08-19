@isTest
public class EscalateChatControllerTest {
    @testSetup static void setup() {
    
        LiveChatVisitor lcv = new LiveChatVisitor();
        INSERT lcv;
    
        LiveChatTranscript ctRecord = new LiveChatTranscript(Escalated__c = false,
                                   Name__c = 'Test1',
                                   Email_Address__c = 'test@pgi.com',
                                   Location_Country_Code__c = 'IE',
                                   Company_Name__c = 'Test',
                                   First_Name__c = 'Test',
                                   Last_Name__c = 'Test',
                                   LiveChatVisitorId = lcv.Id
                                  );
        INSERT ctRecord;
        ApexPages.StandardController sc = new ApexPages.StandardController(ctRecord);
    }
    @istest
    static  void escalateChatTest1(){
        
        LiveChatTranscript ctRecord =[Select Id, Escalated__c 
                            From LiveChatTranscript 
                            Where Escalated__c = false Limit 1];
        escalateChatController escalateChat = new escalateChatController(new ApexPages.StandardController (ctRecord));
        escalateChat.selectedEscalationType ='Case';
        escalateChat.selectedEscalationRecordType = 'PGi-Client External Support';
        escalateChat.currentRecordId = ctRecord.Id;
        escalateChat.init();
        escalateChat.getEscalationType();
        escalateChat.handleRecord();
        escalateChat.getEscalationRecordType();
        escalateChat.handleRecordButton();
        Case newEscalatedCase = [Select Id From Case where Id=:escalateChat.returnId];
    }
    
    @istest
    static  void escalateChatTest2(){
        
        LiveChatTranscript ctRecord =[Select Id, Escalated__c 
                            From LiveChatTranscript 
                            Where Escalated__c = false Limit 1];
        escalateChatController escalateChat = new escalateChatController(new ApexPages.StandardController (ctRecord));
        escalateChat.selectedEscalationType ='Financial_Request__c';
        escalateChat.selectedEscalationRecordType = 'PGi-Billing Support';
        escalateChat.currentRecordId = ctRecord.Id;
        escalateChat.init();
        escalateChat.getEscalationType();
        escalateChat.handleRecord();
        escalateChat.getEscalationRecordType();
        escalateChat.handleRecordButton();
        Financial_Request__c newEscalatedFinReq = [Select Id From Financial_Request__c where Id=:escalateChat.returnId];
    }
    
        @istest
        static  void escalateChatTest3(){
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        INSERT lcv;
    
        LiveChatTranscript ctRecord = new LiveChatTranscript(Escalated__c = false,
                                   Name__c = 'Test1',
                                   Email_Address__c = 'test@pgi.com',
                                   Location_Country_Code__c = 'IE',
                                   Company_Name__c = 'Test',
                                   First_Name__c = 'Test',
                                   Last_Name__c = 'Test',
                                   LiveChatVisitorId = lcv.Id
                                  );
        INSERT ctRecord;
        escalateChatController escalateChat = new escalateChatController(new ApexPages.StandardController (ctRecord));
        escalateChat.selectedEscalationType ='Lead';
        escalateChat.selectedEscalationRecordType = 'PGi Lead';
        escalateChat.currentRecordId = ctRecord.Id;
        escalateChat.init();
        escalateChat.getEscalationType();
        escalateChat.handleRecord();
        escalateChat.getEscalationRecordType();
        escalateChat.handleRecordButton();
    }
}