@isTest
private class RFPEmailServiceTest {
	
	static testMethod void myUnitTest() {

		Init();

		Test.startTest();

		RFPEmailService emailService = new RFPEmailService();

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
		email1.subject = 'RFP- subject line';
        email1.fromName = 'test test';
        email1.plainTextBody = 'plainTextBody';
        email1.binaryAttachments = binaryAttachments;
        email1.textAttachments = textAttachments;

        Messaging.InboundEnvelope envelope1 = new Messaging.InboundEnvelope();
        envelope1.fromAddress = 'user@acme.com';
		Messaging.InboundEmailResult result1 = emailService.handleInboundEmail(email1, envelope1);
		
		System.assertEquals(result1.success, true);
        


		Id rfpRequestId = [SELECT Id FROM RFP_Request__c].Id;
		Task t = [SELECT Id FROM Task WHERE WhatId = :rfpRequestId];
		List<Attachment> aList = [SELECT Id FROM Attachment WHERE ParentId = :rfpRequestId];
		System.assertEquals(aList.size(), 2);
		//test 2 - w fin req
		Messaging.InboundEmail email2 = new Messaging.InboundEmail();
		Messaging.InboundEmail.Header h = new Messaging.InboundEmail.Header();
		h.value = rfpRequestId;
		h.name = 'X-SFDC-EntityId';
		email2.headers = new List<Messaging.InboundEmail.Header>();
		email2.headers.add(h);
		email2.subject = 'RFP- subject line';
        email2.fromName = 'test test';
        email2.plainTextBody = 'plainTextBody';
        email2.binaryAttachments = binaryAttachments ;
        email2.textAttachments = textAttachments ;

        Messaging.InboundEnvelope envelope2 = new Messaging.InboundEnvelope();
        envelope2.fromAddress = 'user@acme.com';
		Messaging.InboundEmailResult result2 = emailService.handleInboundEmail(email2, envelope2);
       	
       	System.assertEquals(result2.success, true);
       	rfpRequestId = [SELECT Id FROM RFP_Request__c].Id;
		
		List<Task> taskList = [SELECT Id FROM Task WHERE WhatId = :rfpRequestId];
		System.assertEquals(2, taskList.size());
		
		aList = [SELECT Id FROM Attachment WHERE ParentId = :rfpRequestId];
       	System.assertEquals(4, aList.size());
       	

		Test.stopTest();
	}

	static void Init() {

	}
}