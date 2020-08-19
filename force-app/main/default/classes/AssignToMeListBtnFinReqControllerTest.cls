@isTest
public class AssignToMeListBtnFinReqControllerTest {
    static testmethod void testupdateRecord(){
        PGi_Client__c objPgiClient = new PGi_Client__c();
            objPgiClient.Client_ID__c = 'PGITest12';
            INSERT objPgiClient;
            
            Financial_Request__c objFinReq = new Financial_Request__c();
            objFinReq.Status__c = 'New';
            objFinReq.Type__c = 'Other';
            objFinReq.Reason__c = 'NA';
            objFinReq.Bill_To_Client__c = objPgiClient.Id;
            INSERT objFinReq;
        List<Financial_Request__c> finReqList = New List<Financial_Request__c>();
        finReqList.add(objFinReq);
        Test.StartTest(); 

			ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(finReqList);
        ssc.setSelected(finReqList);
			AssignToMeListBtnFinReqController obj = New AssignToMeListBtnFinReqController(ssc);
        obj.assignRecords();
        obj.returnToHomepage();
		Test.StopTest();
        Financial_Request__c finObj =[SELECT Id,Assigned_To__c FROM Financial_Request__c WHERE ID =:objFinReq.Id];
        System.assertEquals(finObj.Assigned_To__c, UserInfo.getUserId());
    }
}