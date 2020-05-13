@isTest
public class CreateCaseTest {
@testSetup static void setup() {
Case caseRecord = new Case(Escalated__c = false,
                                   Caller_Name__c = 'Test1',
                                   Origin = 'Email',
                                   Status = 'New',
                                   Subject = 'Test123'
                                  );
        INSERT caseRecord;
}
    static  testmethod void testCreateCase(){
        Id RecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Outbound_Email_Support').getRecordTypeId();
        Case caseRec = [Select Id,ParentId From Case Where Caller_Name__c = 'Test1'];
        PageReference pageRef = Page.CreateCase;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(caseRec);
        ApexPages.currentPage().getParameters().put('RecordType',RecordType);
        CreateCase Obj = new CreateCase(sc);
        Obj.inConsole();
        Obj.notInConsole();
    }
}