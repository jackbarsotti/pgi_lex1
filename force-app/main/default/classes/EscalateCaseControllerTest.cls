@isTest
public class EscalateCaseControllerTest {
    @testSetup static void setup() {
        Case caseRecord = new Case(Escalated__c = false,
                                   Caller_Name__c = 'Test1',
                                   Origin = 'Email',
                                   Status = 'New'
                                  );
        INSERT caseRecord;
        ApexPages.StandardController sc = new ApexPages.StandardController(caseRecord);
    }
    @istest
    static  void escalateCaseTest1(){
        
        Case caseRecord =[Select Id, Escalated__c 
                            From Case 
                            Where Escalated__c = false AND Origin='Email' Limit 1];
        EscalateCaseController escalateCase = new EscalateCaseController(new ApexPages.StandardController (caseRecord));
        escalateCase.selectedEscalationType ='Case';
        escalateCase.selectedEscalationRecordType = 'PGi-Client External Support';
        escalateCase.currentRecordId = caseRecord.Id;
        escalateCase.init();
        escalateCase.getEscalationType();
        escalateCase.handleRecord();
        escalateCase.getEscalationRecordType();
        escalateCase.handleRecordButton();
        case newEscalatedCase = [Select Id,ParentId From Case where id =: caseRecord.Id];
        system.assertEquals(escalateCase.returnId, newEscalatedCase.ParentId);
    }
     @istest
    static  void escalateCaseTest2(){
        Case caseRecord =[Select Id, Escalated__c 
                            From Case 
                            Where Escalated__c = false AND Origin='Email' Limit 1];
        EscalateCaseController escalateCase = new EscalateCaseController(new ApexPages.StandardController (caseRecord));
        escalateCase.selectedEscalationType ='Financial_Request__c';
        escalateCase.selectedEscalationRecordType = 'PGi-Credit Request';
        escalateCase.currentRecordId = caseRecord.Id;
        escalateCase.init();
        escalateCase.getEscalationType();
        escalateCase.handleRecord();
        escalateCase.getEscalationRecordType();
        escalateCase.handleRecordButton();
        Financial_Request__c newEscalatedFinReq = [Select Id, Related_Case__c From Financial_Request__c where Id=:escalateCase.returnId];
        system.assertEquals(newEscalatedFinReq.Related_Case__c , caseRecord.Id);
    }
}