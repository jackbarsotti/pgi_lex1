@isTest
public class CallLogExtensionTest {
    
   
    @testSetup static void setup(){
        
    }
    
    @isTest static void recordCalllog(){
        
        Id RecordTypeIdFinReq = Schema.SObjectType.Financial_Request__c.getRecordTypeInfosByName().get('PGi-Billing Support').getRecordTypeId();
        //RecordType RecordtypecallLog = [SELECT Id,Name FROM RecordType WHERE Id = :RecordTypeIdCase];
        
        PGi_Entity__c ent = new PGi_Entity__c(Name = 'ent1000');
        PGi_Company__c comp1 = new PGi_Company__c(Name = 'comp1000', PGi_Entity__c = ent.Id);
        INSERT comp1;
        PGi_Client__c pgiClit = new PGi_Client__c(Name = 'cli1000', PGi_Company_ID__c = 'comp10000');
        INSERT pgiClit;
        PGi_Client__c pgiClit2 = new PGi_Client__c(Name = 'cli1000', PGi_Company_ID__c = comp1.ID);
        INSERT pgiClit2;
        
        Financial_Request__c finanReq = new Financial_Request__c();
        finanReq.Type__c = 'Other';
        finanReq.Status__c = 'New';
        finanReq.Region__c = 'NA';
        finanReq.Bill_To_Client__c = pgiClit.Id;
        finanReq.RecordTypeId = RecordTypeIdFinReq;
        INSERT finanReq;
        
        List<Call_Log__c> callLogList = new List<Call_Log__c>{new Call_Log__c(Call_Status__c = 'Escalation Needed', Escalation_Type__c = 'Case',Escalation_Record_Type__c = 'NOC'),
            new Call_Log__c(Call_Status__c = 'Escalation Needed', Escalation_Type__c = 'Case',Escalation_Record_Type__c = 'Internal Support'),
            new Call_Log__c(Call_Status__c = 'Escalation Needed', Escalation_Type__c = 'FinReq',Escalation_Record_Type__c = 'Billing Support'),
            new Call_Log__c(Call_Status__c = 'Escalation Needed', Escalation_Type__c = 'FinReq',Escalation_Record_Type__c = 'Billing Support',PGi_Client__c = pgiClit.Id , PGi_Company__c = comp1.Id ),
            new Call_Log__c(Call_Status__c = 'Escalation Needed', Escalation_Type__c = 'FinReq',Escalation_Record_Type__c = 'Billing Support', Related_FinReq__c = finanReq.Id)};
                INSERT callLogList;
        
        Apexpages.StandardController stdController1 = new Apexpages.StandardController(callLogList[0]); // here t is the contact instance//rectypeid null
        CallLogExtension controller1 = new CallLogExtension(stdController1);
        controller1.createCallLog();
        Apexpages.StandardController stdController2 = new Apexpages.StandardController(callLogList[1]); // here t is the contact instance
        CallLogExtension controller2 = new CallLogExtension(StdController2);
        controller2.createCallLog();
        //Apexpages.StandardController stdController3 = new Apexpages.StandardController(callLogList[5]); // here t is the contact instance
        //CallLogExtension controller3 = new CallLogExtension(StdController3);
        //controller3.createCallLog();
        Apexpages.StandardController stdController4 = new Apexpages.StandardController(callLogList[3]); // here t is the contact instance
        CallLogExtension controller4 = new CallLogExtension(StdController4);
        controller4.createCallLog();
        Apexpages.StandardController stdController5 = new Apexpages.StandardController(callLogList[4]); // here t is the contact instance
        CallLogExtension controller5 = new CallLogExtension(StdController5);
        controller5.createCallLog();
        Case objCase =[Select Id from Case];
        //(checking)List<RecordType> rtList = [SELECT Id FROM RecordType WHERE sObjectType =: 'Case' AND (Name =: 'Internal Support' OR Name =: 'PGi-Internal Support')];
        Call_Log__c objCallog =[Select Related_Case__c from Call_Log__c Where Escalation_Record_Type__c = 'Internal Support'];
        System.assertEquals(objCase.Id, objCallog.Related_Case__c);
        Financial_Request__c objFinRequest = [Select Id from Financial_Request__c Where PGi_Client__c != null  AND PGi_Company__c != null]; 
        Call_Log__c objCallog1 =[Select Related_FinReq__c from Call_Log__c Where PGi_Client__c != null  AND PGi_Company__c != null];    
        System.assertEquals(objFinRequest.Id, objCallog1.Related_FinReq__c);
    }
    
    @isTest static void nullrecordCalllog(){
        
        
        List<Call_Log__c> callLogList = new List<Call_Log__c>{new Call_Log__c(Call_Status__c = 'Escalation Needed', Escalation_Type__c = 'Case',Escalation_Record_Type__c = 'NOC'),
            new Call_Log__c(Call_Status__c = 'Escalation Needed', Escalation_Type__c = 'Case',Escalation_Record_Type__c = 'Internal Support'),
            new Call_Log__c(Call_Status__c = 'Escalation Needed', Escalation_Type__c = 'FinReq',Escalation_Record_Type__c = 'Internal Support'),
            new Call_Log__c(Call_Status__c = 'Escalation Needed', Escalation_Type__c = 'FinReq',Escalation_Record_Type__c = 'Billing Support'),
            new Call_Log__c(Call_Status__c = 'Wrong Number', Escalation_Type__c = 'FinReq',Escalation_Record_Type__c = 'Billing Support'),
            new Call_Log__c(Call_Status__c = 'Escalation Needed', Escalation_Record_Type__c = 'Billing Support')};
                //INSERT callLog;
                System.debug('hai'+callLogList[0].Id);
        Apexpages.StandardController stdController1 = new Apexpages.StandardController(callLogList[0]); // here t is the contact instance//recordty null
        CallLogExtension controller1 = new CallLogExtension(StdController1);
        controller1.createCallLog();
        
        Apexpages.StandardController stdController2 = new Apexpages.StandardController(callLogList[1]); // here t is the contact instance//notnull
        CallLogExtension controller2 = new CallLogExtension(stdController2);
        controller2.createCallLog();
        Apexpages.StandardController stdController3 = new Apexpages.StandardController(callLogList[2]); // here t is the contact instance//null
        CallLogExtension controller3 = new CallLogExtension(stdController3);
        controller3.createCallLog();
        Apexpages.StandardController stdController4 = new Apexpages.StandardController(callLogList[3]); // here t is the contact instance
        CallLogExtension controller4 = new CallLogExtension(StdController4);
        controller4.createCallLog();
        Apexpages.StandardController stdController5 = new Apexpages.StandardController(callLogList[4]); // here t is the contact instance
        CallLogExtension controller5 = new CallLogExtension(stdController5);
        controller5.createCallLog();
        Apexpages.StandardController stdController6 = new Apexpages.StandardController(callLogList[5]); // here t is the contact instance
        CallLogExtension controller6 = new CallLogExtension(stdController6);
        controller6.createCallLog();        
        Case objCase =[Select Id from Case];
        Call_Log__c objCallog =[Select Related_Case__c from Call_Log__c Where Escalation_Record_Type__c = 'Internal Support'];      
        System.assertEquals(objCase.Id, objCallog.Related_Case__c);
        Financial_Request__c objFinRequest =[Select Id from Financial_Request__c];        
        Call_Log__c objCallog1 =[Select Related_FinReq__c from Call_Log__c Where Escalation_Record_Type__c = 'Billing Support' AND Call_Status__c = 'Escalation Needed'];      
        System.assertEquals(objFinRequest.Id, objCallog1.Related_FinReq__c);
        Call_Log__c objCallog2 =[Select Call_Status__c from Call_Log__c Where Call_Status__c = 'Wrong Number'];
        System.assertEquals('Wrong Number', objCallog2.Call_Status__c);
    }  
}