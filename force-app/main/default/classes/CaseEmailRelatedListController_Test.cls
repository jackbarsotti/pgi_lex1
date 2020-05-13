@isTest
public class CaseEmailRelatedListController_Test {
    @testSetup static void setup() {
        Case caseRecord = new Case(Escalated__c = false,
                                   Caller_Name__c = 'Test1',
                                   Origin = 'Email',
                                   Status = 'New',
                                   Subject = 'Test123'
                                  );
        INSERT caseRecord;
        Id recTypeId = [Select Id From Recordtype Where Name = 'OutBound Email Support' ].Id;
        Case caseRecord1 = new Case(Escalated__c = false,
                                    Caller_Name__c = 'Test123',
                                    Origin = 'Email',
                                    Status = 'New',
                                    Subject = 'Test123',
                                    ParentId = caseRecord.Id,
                                    RecordTypeId = recTypeId
                                   );
        INSERT caseRecord1;
         EmailMessage objEmailMsg = new EmailMessage();
            objEmailMsg.ParentId = caseRecord1.Id;
            objEmailMsg.Subject = 'subject';
            objEmailMsg.ToAddress = 'Ecample@ex.com';
            objEmailMsg.BccAddress = 'Ecample1@ex.com';
            objEmailMsg.CcAddress = 'Ecample1@ex.com';
            objEmailMsg.FromAddress = 'Ecampl123e@ex.com';
            objEmailMsg.htmlBody = 'This has body';
            objEmailMsg.TextBody = 'This has body of text';    
            objEmailMsg.MessageDate = datetime.now();
            insert objEmailMsg;
    }
    static  testmethod void testValidation(){
        EmailMessage objEmailMsg = [SELECT Id, ParentId, Status, ToAddress, CreatedDate, Subject, FromName, FromAddress FROM EmailMessage where Subject='subject'];
        Case caseRec = [Select Id,ParentId, RecordTypeId From Case Where Caller_Name__c = 'Test123'];
        PageReference pageRef = Page.CaseEmailRelatedList;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(caseRec);
        
        ApexPages.currentPage().getParameters().put('id',caseRec.id);
        CaseEmailRelatedListController obj = new CaseEmailRelatedListController(sc);
        obj.sendMail();
        obj.sendTolightning();
        obj.deleteEmail();
        obj.redirectToEmailMessage();
        System.assertEquals(1, obj.emailMsgLst.size());
        System.assertEquals('ecampl123e@ex.com', obj.emailMsgLst[0].FromAddress);
    }

}