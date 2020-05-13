@isTest
public class EmailMessageTriggerHandlerTest {
    @testSetup static void setup()
    {
        
        Profile p = [Select Id from Profile where Name='PGi Legal'];
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZtest',
                         Email = 'Example@pgi.com', 
                         Username = 'Example1@pgi.com', 
                         EmailEncodingKey = 'UTF-8', 
                         Alias = 'Test', 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US',
                         EmployeeNumber='12345',
                         ProfileId = p.Id
                        ); 
        insert uu;
        List<case> objCase =[select Id,Most_Recent_SLA_Start__c,First_Response_Time__c,SLA_Time_to_Complete__c from case where Status='Working'];
        System.assertEquals(0, objCase.size());
        System.runAs(uu){
            PGITestUtilities.disableSalesWings();
            Account ac = new Account();
            ac.Name='Ac1';
            ac.BillingCountry='India';
            ac.BillingStreet='xyz';
            insert ac;
            objCase =[select Id,Most_Recent_SLA_Start__c,First_Response_Time__c,SLA_Time_to_Complete__c from case where Status='Working'];
            System.assertEquals(0, objCase.size());
            Contact con=new Contact();
            con.AccountId=ac.Id;
            con.LastName= 'test';
            con.FirstName='test';
            con.Phone= '9887678558';
            con.Email= 'hsk@test.com';
            insert con;
            objCase =[select Id,Most_Recent_SLA_Start__c,First_Response_Time__c,SLA_Time_to_Complete__c from case where Status='Working'];
            System.assertEquals(0, objCase.size());
            Case caseObj1 = new Case();
            caseObj1.ContactId = con.Id;
            caseObj1.AccountId = ac.Id;
            caseObj1.Status = 'Working';
            caseObj1.Origin = 'Phone';
            caseObj1.IsUpdateFromCaseComment__c=true;
            caseObj1.SLA_Time_to_Complete__c=Date.today();   
            caseObj1.Most_Recent_SLA_Start__c=Date.today();    
            insert caseObj1;
            objCase =[select Id,Most_Recent_SLA_Start__c,First_Response_Time__c,SLA_Time_to_Complete__c from case where Status='Working'];
            System.assertEquals(1, objCase.size());
            EmailMessage objEmailMsg = new EmailMessage();
            objEmailMsg.ParentId = caseObj1.Id;
            objEmailMsg.Subject = 'subject';
            objEmailMsg.ToAddress = 'Ecample@ex.com';
            objEmailMsg.BccAddress = 'Ecample1@ex.com';
            objEmailMsg.CcAddress = 'Ecample1@ex.com';
            objEmailMsg.FromAddress = 'noreply@pgi.com';
            objEmailMsg.htmlBody = 'This has body';
            objEmailMsg.TextBody = 'This has body of text';    
            objEmailMsg.MessageDate = datetime.now();
            objEmailMsg.CreatedById=uu.Id;
            insert objEmailMsg;
            objCase =[select Id,Most_Recent_SLA_Start__c,First_Response_Time__c,SLA_Time_to_Complete__c from case where Status='Working'];
            System.assertEquals(1, objCase.size());
            EmailMessage objEmailMsg1 = new EmailMessage();
            objEmailMsg1.ParentId = caseObj1.Id;
            objEmailMsg1.Subject = 'subject';
            objEmailMsg1.ToAddress = 'Ecample@ex.com';
            objEmailMsg1.BccAddress = 'Ecample1@ex.com';
            objEmailMsg1.CcAddress = 'Test@ex.com';
            objEmailMsg1.FromAddress = 'Ecampl123e@pgi.com';
            objEmailMsg1.htmlBody = 'This has body';
            objEmailMsg1.TextBody = 'This has body of text';    
            objEmailMsg1.MessageDate = datetime.now();
            objEmailMsg1.CreatedById=uu.Id;
            insert objEmailMsg1;
            objCase =[select Id,Most_Recent_SLA_Start__c,First_Response_Time__c,SLA_Time_to_Complete__c from case where Status='Working'];
            System.assertEquals(1, objCase.size());
        }
    }
  @isTest static void afterInsert(){
        user u =[Select Id from User where lastName='XYZtest'];
        System.runAs(u){
            case objCase =[select Id,Most_Recent_SLA_Start__c,First_Response_Time__c,SLA_Time_to_Complete__c from case where Status='Working'];
            datetime currentTime = datetime.now();
            EmailMessage emailMessageObj1 =[Select Id,ParentId,FromAddress,CreatedById from EmailMessage where CcAddress='Test@ex.com']; 
            EmailMessage emailMessageObj =[Select Id,ParentId,FromAddress,CreatedById from EmailMessage where CcAddress='Ecample1@ex.com']; 
            case objCase1 =[select Id,First_Response_SLA__c,First_Reply_Time__c,Most_Recent_SLA_Start__c,First_Response_Time__c,SLA_Time_to_Complete__c from case where Status='Working'];
            // try{ 
                // System.assertEquals(currentTime.format('HH:mm'), objCase1.First_Reply_Time__c);
            // } catch(Exception e) {
                // currentTime = currentTime.addMinutes(1);
                // System.assertEquals(currentTime.format('HH:mm'), objCase1.First_Reply_Time__c);
            // }
            // System.assertEquals(System.now().format(),objCase1.First_Response_Time__c);
        }
    }
   @isTest static void afterupdateIfTrue(){
        user u =[Select Id from User where lastName='XYZtest'];
        System.runAs(u){
            EmailMessage emailMessageObj =[Select Id,ParentId,FromAddress,CreatedById from EmailMessage where CcAddress='Ecample1@ex.com']; 
            emailMessageObj.CcAddress='Ecample@ex.com';
            Update emailMessageObj;
            case objCase =[select Id,Most_Recent_SLA_Start__c,IsUpdateFromCaseComment__c,First_Response_Time__c,SLA_Time_to_Complete__c from case where Status='Working'];
            // System.assertEquals(false, objCase.IsUpdateFromCaseComment__c);
        }
    }
   @isTest static void afterupdateIfFalse(){
        user u =[Select Id from User where lastName='XYZtest'];
        System.runAs(u){
            case objCase =[select Id,Most_Recent_SLA_Start__c,IsUpdateFromCaseComment__c,First_Response_Time__c,SLA_Time_to_Complete__c from case where Status='Working'];
            objCase.IsUpdateFromCaseComment__c=false;
            Update objCase;
            EmailMessage emailMessageObj =[Select Id,ParentId,FromAddress,CreatedById from EmailMessage where CcAddress='Ecample1@ex.com']; 
            emailMessageObj.CcAddress='Ecample@ex.com';
            Update emailMessageObj;
            case objCase1 =[select Id,IsUpdateFromCaseComment__c from case where Status='Working'];
            // System.assertEquals(true, objCase1.IsUpdateFromCaseComment__c);
        }
    }
    @isTest static void beforeDelete(){
         String errorMsg;
        user u =[Select Id from User where lastName='XYZtest'];
        System.runAs(u){
            EmailMessage emailMessageObj =[Select Id,ParentId,FromAddress,CreatedById from EmailMessage where CcAddress='Ecample1@ex.com']; 
            try{
                Delete emailMessageObj;
            }
            catch(DmlException e)
            {
                System.debug(e);
                
            }
            System.assert(emailMessageObj.Id != null);
        }
    }
    
}