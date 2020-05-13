@isTest
public class SetSubjectIndexedForEmailMessage_Test {
    static testMethod void updateSubjectIndexed(){
        Profile p = [Select Id from Profile where Name='PGi Legal'];
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ',
                         Email = 'Example@pgi.com', 
                         Username = 'Example1@'+DateTime.now().getTime()+'pgi.com', 
                         EmailEncodingKey = 'UTF-8', 
                         Alias = 'Test', 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US',
                         EmployeeNumber='12345',
                         ProfileId = p.Id
                        ); 
        insert uu;
        System.runAs(uu){
            PGITestUtilities.disableSalesWings();
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
            caseObj1.IsUpdateFromCaseComment__c=true;
            caseObj1.SLA_Time_to_Complete__c=Date.today();   
            caseObj1.Most_Recent_SLA_Start__c=Date.today();    
            insert caseObj1;
            
            EmailMessage objEmailMsg = new EmailMessage();
            objEmailMsg.ParentId = caseObj1.Id;
            objEmailMsg.Subject = 'TestSub';
            objEmailMsg.ToAddress = 'Ecample@ex.com';
            objEmailMsg.BccAddress = 'Ecample1@ex.com';
            objEmailMsg.CcAddress = 'Ecample1@ex.com';
            objEmailMsg.FromAddress = 'noreply@pgi.com';
            objEmailMsg.htmlBody = 'This has body';
            objEmailMsg.TextBody = 'This has body of text';    
            objEmailMsg.MessageDate = datetime.now();
            objEmailMsg.CreatedById=uu.Id;
            insert objEmailMsg;
            Test.startTest();
            SetSubjectIndexedForEmailMessage batch = new SetSubjectIndexedForEmailMessage();
            Database.executeBatch(batch);
            Test.stopTest();
            EmailMessage em =[Select Id,Subject_Indexed__c from EmailMessage where Subject = 'TestSub'];
            System.assertEquals('TestSub', em.Subject_Indexed__c);
        }
    }
}