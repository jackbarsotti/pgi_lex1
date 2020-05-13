@isTest
public class OutboundEmailMessagesController_Test {
@testSetup static void methodName() {
        Id outboundCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Outbound_Email_Support').getRecordTypeId();
        Profile p = [Select Id from Profile where Name='System Administrator'];
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ',
                         Email = 'testOutboundEmail@pgi.com', 
                         Username = 'testOutboundEmail@pgi.com', 
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
            Case objCse1 = new Case(
                Subject = 'EmailTest',
                OwnerId = uu.Id,
                RecordTypeId = outboundCaseRTId);
            INSERT objCse1;
            EmailMessage objEmailMsg = new EmailMessage();
            objEmailMsg.ParentId = objCse1.Id;
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
    }
    static testMethod void testoutBoundEmailMsg(){
      EmailMessage objEmailMsg=[SELECT Id,CreatedDate, LastModifiedDate,EmailTemplateId,MessageDate,ParentId,Status, CreatedById, LastModifiedById, FromAddress, FromName, ToAddress, CcAddress, BccAddress, Subject, HtmlBody, TextBody 
                      FROM EmailMessage 
                      Where Subject = 'subject'];  
        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=objEmailMsg.id;
        insert attach;
        PageReference pageRef = Page.OutboundEmailMessages;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(objEmailMsg);
        ApexPages.currentPage().getParameters().put('emailMsgId',objEmailMsg.id);
        ApexPages.currentPage().getParameters().put('ObjcaseId',objEmailMsg.ParentId);
        ApexPages.currentPage().getParameters().put('attachmentId',attach.id);
        OutboundEmailMessagesController obj = new OutboundEmailMessagesController(sc);
        List<Attachment> attachLst = obj.attachments;
        System.assert(attachLst.size()!=0); 
        obj.deleteAttachment();
        System.assertEquals(null, obj.attachments);
        
        
    }
    static testMethod void testEmailMsgForAttachmentNull(){
      EmailMessage objEmailMsg=[SELECT Id,CreatedDate, LastModifiedDate,EmailTemplateId,MessageDate,ParentId,Status, CreatedById, LastModifiedById, FromAddress, FromName, ToAddress, CcAddress, BccAddress, Subject, HtmlBody, TextBody 
                      FROM EmailMessage 
                      Where Subject = 'subject'];  
        PageReference pageRef = Page.OutboundEmailMessages;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('emailMsgId',objEmailMsg.id);
        ApexPages.StandardController sc = new ApexPages.standardController(objEmailMsg);
        OutboundEmailMessagesController obj = new OutboundEmailMessagesController(sc);
        obj.deleteAttachment(); 
        System.assertEquals(null, obj.attachments);
    }
}