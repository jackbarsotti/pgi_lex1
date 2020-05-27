@isTest
public class AssignToMeLEXControllerTest {
    
    static testmethod void testupdateRecord(){
        Test.startTest();
        
        Profile profile = [SELECT Id FROM Profile WHERE name = 'System Administrator'];
        UserRole portalRole = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
        
        User u = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile.Id,
            Username = 'bradBellick321@pgi.com',
            Alias = 'batman',
            Email='bradBellick321@pgi.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            EmployeeNumber='12345',
            TimeZoneSidKey='America/Chicago');
        INSERT u;
        System.debug('User: '+u);
        
        User objUser = [SELECT Id FROM User WHERE Id =: u.Id LIMIT 1];
        
        System.runas(objUser) {
            
            Case c = new Case();
            C.Status = 'New';
            C.Origin = 'Phone';
            INSERT c;
            
            PGi_Client__c objPgiClient = new PGi_Client__c();
            objPgiClient.Client_ID__c = 'PGITest12';
            INSERT objPgiClient;
            
            Financial_Request__c objFinReq = new Financial_Request__c();
            objFinReq.Status__c = 'New';
            objFinReq.Type__c = 'Other';
            objFinReq.Reason__c = 'NA';
            objFinReq.Bill_To_Client__c = objPgiClient.Id;
            INSERT objFinReq;
            
            Request_for_Change__c objRFC = new Request_for_Change__c();
            objRFC.Assignment_Group__c = 'PGi-RFC-GL-Audio Projects';
            objRFC.Type__c = 'Normal';
            objRFC.Risk__c = 'Low';
            objRFC.Planned_Start_Date_Time__c = System.today();
            objRFC.Planned_End_Date_Time__c = System.today().addDays(2);
            INSERT objRFC;
            
            AssignToMeLEXController.updateRecord(objFinReq.Id,'Financial_Request__c');
            AssignToMeLEXController.updateRecord(c.Id,'Case');
            AssignToMeLEXController.updateRecord(objRFC.Id,'Request_for_Change__c'); 
            
            Financial_Request__c finReqObject = [SELECT Assigned_To__c FROM Financial_Request__c WHERE Id =: objFinReq.Id];
            System.assertEquals(finReqObject.Assigned_To__c, objUser.Id);
            
            Case caseObject = [SELECT Assigned_To__c FROM Case WHERE Id =:c.Id];
            System.assertEquals(caseObject.Assigned_To__c, objUser.Id);
            
            Request_for_Change__c reqForChangeObj = [SELECT Assigned_To__c FROM Request_for_Change__c WHERE Id =:objRFC.Id]; 
            System.assertEquals(reqForChangeObj.Assigned_To__c, objUser.Id); 
            
        }
        Test.stopTest();
    }
    
}