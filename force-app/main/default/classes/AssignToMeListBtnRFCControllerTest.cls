@isTest
public class AssignToMeListBtnRFCControllerTest {
static testmethod void testupdateRecord(){
            Request_for_Change__c objRFC = new Request_for_Change__c();
            objRFC.Assignment_Group__c = 'PGi-RFC-GL-Audio Projects';
            objRFC.Type__c = 'Normal';
            objRFC.Risk__c = 'Low';
            objRFC.Planned_Start_Date_Time__c = System.today();
            objRFC.Planned_End_Date_Time__c = System.today().addDays(2);
            INSERT objRFC;
        List<Request_for_Change__c> rfcList = New List<Request_for_Change__c>();
        rfcList.add(objRFC);
        Test.StartTest(); 

			ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(rfcList);
        ssc.setSelected(rfcList);
			AssignToMeListBtnRFCController obj = New AssignToMeListBtnRFCController(ssc);
        obj.assignRecords();
        obj.returnToHomepage();
		Test.StopTest();
        Request_for_Change__c rfcObj =[SELECT Id,Assigned_To__c FROM Request_for_Change__c WHERE ID =:objRFC.Id];
        System.assertEquals(rfcObj.Assigned_To__c, UserInfo.getUserId());
    }
}