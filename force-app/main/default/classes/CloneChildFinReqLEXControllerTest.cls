@isTest
public class CloneChildFinReqLEXControllerTest {

    static testMethod void testCloneAnySobjet(){
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
           
            PGi_Client__c objPgiClient = new PGi_Client__c();
            objPgiClient.Client_ID__c = 'PGITest12';
            INSERT objPgiClient;
            
            Financial_Request__c objFinReq = new Financial_Request__c();
            objFinReq.Status__c = 'New';
            objFinReq.Type__c = 'Other';
            objFinReq.Reason__c = 'NA';
            objFinReq.Bill_To_Client__c = objPgiClient.Id;
            INSERT objFinReq;
            
            String cloneChildRecId=CloneChildFinReqLEXController.cloneAnySobjet(objFinReq.Id,'Financial_Request__c');
            System.assert(cloneChildRecId!=null);
        }
        
        Test.stopTest();
        
    }
}