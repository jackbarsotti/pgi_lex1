@isTest
public class AssignToMeDetailControllerTest {
    
    static testmethod void testupdateRecord(){
        Case c = new Case();
        C.Status = 'New';
        C.Origin = 'Phone';
        insert c;
        
        PGi_Client__c pgiClientObj=new PGi_Client__c();
        pgiClientObj.Client_ID__c='PGITest12';
        insert pgiClientObj;
        
        Financial_Request__c FinReqObj=new Financial_Request__c();
        FinReqObj.Status__c='New';
        FinReqObj.Type__c='Other';
        FinReqObj.Reason__c='NA';
        FinReqObj.Bill_To_Client__c=pgiClientObj.Id;
        insert FinReqObj;
        
        Request_for_Change__c objRFC=new Request_for_Change__c();
        objRFC.Assignment_Group__c='PGi-RFC-GL-Audio Projects';
        objRFC.Type__c='Normal';
        objRFC.Risk__c='Low';
        objRFC.Planned_Start_Date_Time__c=System.today();
        objRFC.Planned_End_Date_Time__c=System.today().addDays(2);
        insert objRFC;
        
        AssignToMeDetailController.updateRecord(FinReqObj.Id);
        AssignToMeDetailController.updateRecord(c.Id);
        AssignToMeDetailController.updateRecord(objRFC.Id);
        
        System.assertEquals('Other', FinReqObj.Type__c);
    }
    
}