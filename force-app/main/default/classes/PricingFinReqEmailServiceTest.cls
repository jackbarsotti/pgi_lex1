@isTest
public class PricingFinReqEmailServiceTest {
	@isTest
	public static void testWithAttachments() {
		PricingFinReqEmailService emailService = new PricingFinReqEmailService();

		Messaging.InboundEmail.BinaryAttachment[] binaryAttachments = new Messaging.InboundEmail.BinaryAttachment[1];  
        Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binaryAttachment.Filename = 'test.txt';
        String algorithmName = 'HMacSHA1';
        Blob b = Crypto.generateMac(algorithmName, Blob.valueOf('test'),
        Blob.valueOf('test_key'));
        binaryAttachment.body = b;
        binaryAttachments[0] =  binaryAttachment;

		Messaging.InboundEmail.TextAttachment[] textAttachments = new Messaging.InboundEmail.TextAttachment[1];  
        Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();
        textAttachment.filename = 'testText.txt';
		textAttachment.body = 'testeste';
		textAttachments[0] =  textAttachment;
		//test 1 - no fin req
		Messaging.InboundEmail email1 = new Messaging.InboundEmail();
		email1.subject = 'subject line';
        email1.fromName = 'test test';
        email1.plainTextBody = 'plainTextBody';
        email1.binaryAttachments = binaryAttachments;
        email1.textAttachments = textAttachments;

        Messaging.InboundEnvelope envelope1 = new Messaging.InboundEnvelope();
        envelope1.fromAddress = 'user@acme.com';
		Messaging.InboundEmailResult result1 = emailService.handleInboundEmail(email1, envelope1);
		System.assertEquals(result1.success, true);
        

		Id finReqId = [SELECT Id FROM Financial_Request__c].Id;
		Task t = [SELECT Id FROM Task WHERE WhatId =: finReqId];
		List<Attachment> aList = [SELECT Id FROM Attachment WHERE ParentId =: finReqId];
		System.assertEquals(aList.size(), 2);
		//test 2 - w fin req
		Messaging.InboundEmail email2 = new Messaging.InboundEmail();
		Messaging.InboundEmail.Header h = new Messaging.InboundEmail.Header();
		h.value = finReqId;
		h.name = 'X-SFDC-EntityId';
		email2.headers = new List<Messaging.InboundEmail.Header>();
		email2.headers.add(h);
		email2.subject = 'subject line';
        email2.fromName = 'test test';
        email2.plainTextBody = 'plainTextBody';
        email2.binaryAttachments = binaryAttachments ;
        email2.textAttachments = textAttachments ;

        Messaging.InboundEnvelope envelope2 = new Messaging.InboundEnvelope();
        envelope2.fromAddress = 'user@acme.com';
		Messaging.InboundEmailResult result2 = emailService.handleInboundEmail(email2, envelope2);
       	
       	System.assertEquals(result2.success, true);
       	finReqId = [SELECT Id FROM Financial_Request__c].Id;
		
		List<Task> taskList = [SELECT Id FROM Task WHERE WhatId =: finReqId];
		System.assertEquals(2, taskList.size());
		
		aList = [SELECT Id FROM Attachment WHERE ParentId =: finReqId];
       	System.assertEquals(4, aList.size());
        
	}
	@isTest
	public static void testWithoutAttachments() {
		PricingFinReqEmailService emailService = new PricingFinReqEmailService();

		//test 1 - no fin req
		Messaging.InboundEmail email1 = new Messaging.InboundEmail();
		email1.subject = 'subject line';
        email1.fromName = 'test test';
        email1.plainTextBody = 'plainTextBody';

        Messaging.InboundEnvelope envelope1 = new Messaging.InboundEnvelope();
        envelope1.fromAddress = 'user@acme.com';
		Messaging.InboundEmailResult result1 = emailService.handleInboundEmail(email1, envelope1);
		System.assertEquals(result1.success, true);
        

		Id finReqId = [SELECT Id FROM Financial_Request__c].Id;
		Task t = [SELECT Id FROM Task WHERE WhatId =: finReqId];

		//test 2 - w fin req
		Messaging.InboundEmail email2 = new Messaging.InboundEmail();
		Messaging.InboundEmail.Header h = new Messaging.InboundEmail.Header();
		h.value = finReqId;
		h.name = 'X-SFDC-EntityId';
		email2.headers = new List<Messaging.InboundEmail.Header>();
		email2.headers.add(h);
		email2.subject = 'subject line';
        email2.fromName = 'test test';
        email2.plainTextBody = 'plainTextBody';
        
        Messaging.InboundEnvelope envelope2 = new Messaging.InboundEnvelope();
        envelope2.fromAddress = 'user@acme.com';
		Messaging.InboundEmailResult result2 = emailService.handleInboundEmail(email2, envelope2);
       	System.assertEquals(result2.success, true);
       	System.assertEquals(result2.success, true);

       	finReqId = [SELECT Id FROM Financial_Request__c].Id;
		
		List<Task> taskList = [SELECT Id FROM Task WHERE WhatId =: finReqId];
		System.assertEquals(2, taskList.size());
		
		List<Attachment> aList = [SELECT Id FROM Attachment WHERE ParentId =: finReqId];
       	System.assertEquals(0, aList.size());

	}
}