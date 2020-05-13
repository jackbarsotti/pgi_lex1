@isTest
public class SetAverageSlaInMinutesForCase_Test {
    static testMethod void updateAvgSlaInMinutes(){
        Account ac = new Account();
        ac.Name='Ac1';
        ac.BillingCountry='India';
        ac.BillingStreet='xyz';
        insert ac;
        
        Contact con=new Contact();
        con.AccountId=ac.Id;
        con.LastName= 'test';
        con.FirstName='test';
        con.Phone= '9887678558';
        con.Email= 'hsk@test.com';
        insert con;
        
        Case caseObj1 = new Case();
        caseObj1.ContactId = con.Id;
        caseObj1.AccountId = ac.Id;
        caseObj1.Status = 'Working';
        caseObj1.Origin = 'Phone';
        caseObj1.Average_SLA_Time__c='12:00';
        caseObj1.Average_SLA_In_Minutes__c=null;   
        insert caseObj1;
        
        System.debug('The Id'+caseObj1.Id);
        Test.startTest();
        SetAverageSlaInMinutesForCase batch = new SetAverageSlaInMinutesForCase();
		Database.executeBatch(batch);
        Test.stopTest();
        Case objCase =[Select Id,Average_SLA_In_Minutes__c from Case Where Status = 'Working' AND Average_SLA_Time__c='12:00'];
       System.assertEquals(720, objCase.Average_SLA_In_Minutes__c);
    }
}