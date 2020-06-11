@isTest
public class AssignToMeListBtnCaseControllerTest {
static testmethod void testupdateRecord(){
            Case caseObj = new Case();
            caseObj.Status = 'New';
            caseObj.Origin = 'Phone';
            INSERT caseObj;
        List<Case> caseList = New List<Case>();
        caseList.add(caseObj);
        Test.StartTest(); 

			ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(caseList);
        ssc.setSelected(caseList);
			AssignToMeListBtnCaseController obj = New AssignToMeListBtnCaseController(ssc);
        obj.assignRecords();
        obj.returnToHomepage();
		Test.StopTest();
        Case ObjCase =[SELECT Id,Assigned_To__c FROM Case WHERE ID =:caseObj.Id];
        System.assertEquals(ObjCase.Assigned_To__c, UserInfo.getUserId());
    }
}