@isTest
public class CaseCreateOverrideControllerTest {
    static testMethod void test() {
        
        RecordType rc=[Select Name, IsActive, Id From RecordType where SobjectType = 'Case' and Name = 'PGi-Client External Support' and IsActive = true limit 1];
        
        Case caseObj = new Case();
        caseObj.Status = 'Working';
        caseObj.Origin = 'Phone';
        caseObj.recordTypeId = rc.Id;
        caseObj.Auto_Generated_For_Case__c = true;
        List<String> fieldAPINameList = new List<String>();
        fieldAPINameList.add('Status');
        fieldAPINameList.add('Origin');
        List<String> emptyFieldAPINameList = new List<String>();
        List<RecordType> rtList = [SELECT Id, Name, DeveloperName, Description 
                                    FROM RecordType 
                                    WHERE SobjectType = 'Case'];
       
        Test.startTest();
        	insert caseObj;
        	CaseCreateOverrideController.createCase(rc.Id);
        	CaseCreateOverrideController.updateCase(caseObj);
        	CaseCreateOverrideController.getQuickCase();
        	CaseCreateOverrideController.getCaseFieldValues(caseObj.Id, fieldAPINameList);
        	CaseCreateOverrideController.getRecordType();
        	System.assertEquals(true, CaseCreateOverrideController.updateCase(caseObj));
        	//System.assertEquals(new case().id, CaseCreateOverrideController.createCase(rc.Id));
        	System.assertEquals('[{"message":"There is no fields present in provided fieldset. Please add some fields","errorCode":"NO_FIELDS_EXIST"}]', CaseCreateOverrideController.getCaseFieldValues(caseObj.Id, emptyFieldAPINameList));
        	System.assertEquals(rtList, CaseCreateOverrideController.getRecordType());
        Test.stopTest();
    }
}