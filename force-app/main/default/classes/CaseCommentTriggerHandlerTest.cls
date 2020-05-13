@isTest
private class CaseCommentTriggerHandlerTest {
    static testMethod void myUnitTest() {
        Account ac = new Account();
        ac.Name='Ac1';
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
        insert caseObj1;
        
        Casecomment cc = new Casecomment();
        cc.CommentBody ='Test.....';
        cc.ParentId = caseObj1.Id;
        insert cc;
        
        List<CaseComment> lstCM = [Select Id from CaseComment Where parentId =:caseObj1.Id];
        
        System.assertEquals(caseObj1.IsUpdateFromCaseComment__c,false);
        System.assertEquals(lstCM.size(),1);
        
        cc = new Casecomment();
        cc.CommentBody ='Test.....';
        cc.ParentId = caseObj1.Id;
        insert cc;
        
        lstCM = [Select Id from CaseComment Where parentId =:caseObj1.Id];
        
        System.assertEquals(caseObj1.IsUpdateFromCaseComment__c,false);
        System.assertEquals(lstCM.size(),2);
        
        EmailMessage[] newEmail = new EmailMessage[0];
        newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = caseObj1.Id)); 
        insert newEmail;

        List<EmailMessage> lstEM = [Select Id from EmailMessage Where parentId =:caseObj1.Id];
        
        System.assertEquals(caseObj1.IsUpdateFromCaseComment__c,false);
        System.assertEquals(lstEM.size(),1);

        
        newEmail.clear();
        newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = '23456 ', ParentId = caseObj1.Id)); 
        insert newEmail;

        lstEM = [Select Id from EmailMessage Where parentId =:caseObj1.Id];
        
        System.assertEquals(caseObj1.IsUpdateFromCaseComment__c,false);
        System.assertEquals(lstEM.size(),2);

        
    }
}