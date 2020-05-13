global class RFPEmailService implements Messaging.InboundEmailHandler {
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope env) {
	  	// Create an InboundEmailResult object for returning the result of the Apex Email Service
	  	Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
	  	try {
	  		result.success = true;
	  		//Within the email header content, search for the "X-SFDC-LK" & "X-SFDC-User" values
	  		Id rfpId;
	  		//X-SFDC-EntityId: a8E1B000000fxjo
	  		if(email.headers != null && email.headers.size() > 0) {
		  		for(Messaging.InboundEmail.Header header: email.headers) {
		  			if(header.name == 'X-SFDC-EntityId') {
		  				rfpId = (Id)header.value;
		  			}
		  		}
		  	}
		  	String subject = email.subject;
		  	if(rfpId == null) {
		  		if(subject.contains('RFP-')) {
		  			String rfpNum = subject.right(6);
		  			try {
		  				rfpId = [SELECT Id FROM RFP_Request__c WHERE Name=: 'RFP-' + rfpNum].Id;
		  			} catch (Exception e) {
		  				System.debug(e);
		  			}
		  		}
		  	}

	  		RFP_Request__c rfp;
	  		if(rfpId != null) {
	  			List<RFP_Request__c> rfpList = [SELECT Id FROM RFP_Request__c WHERE Id =: rfpId];
	  			if(rfpList.size() > 0) {
	  				rfp = rfpList[0];
	  			}
	  		}
  			//String subject = email.subject;
  			String body = email.plainTextBody;
  			String description = 'From: ' + email.fromAddress + '\n' + 
  									'CC: ' + email.ccAddresses + '\n' + 
  									'Subject: ' + email.subject + '\n' + 
  									'Body: ' + body;
  			String emailSentFrom = email.fromAddress;
  			List<User> userList = [SELECT Id, Email FROM User WHERE isActive = true AND Email =: emailSentFrom LIMIT 1];
  			User submittedBy; 
  			List<Messaging.InboundEmail.TextAttachment> textAttachments = email.textAttachments;
  			List<Messaging.InboundEmail.BinaryAttachment> binaryAttachments = email.binaryAttachments;
  			if(userList.size() > 0) {
  				submittedBy = userList[0];
  			}
  			try {
  				if(rfp == null) {
  					SObjectType rfpType = RFP_Request__c.sObjectType;
					rfp = (RFP_Request__c)rfpType.newSObject('0121B000001hgTY', /*loadDefaults*/ true);
					rfp.Request_Type__c =  'Email Support';
					rfp.Submitted_By_User__c = submittedBy != null ? submittedBy.Id : null;
					rfp.Email_Subject__c = subject;
					rfp.Email_Body__c = body;
  					insert rfp;
  				}
				
				Task newTask = new Task(
					Description = description,
					Priority = 'Normal',
					Subject = subject,
					Type = 'Email',
					Status = 'Inbound Email',
					IsReminderSet = false,
					ActivityDate = System.today(),
					WhatId = rfp.Id
				);
				insert newTask;
  				
  				List<Attachment> attachmentList = new List<Attachment>();
  				try {
  					if(textAttachments != null && textAttachments.size() > 0){
		  				for(Messaging.InboundEmail.TextAttachment ta: textAttachments) {
		  					 Attachment a = new Attachment(ParentId = rfp.Id, 
		                                          Name = ta.filename, 
		                                          Body = Blob.valueOf(ta.body));
		            		attachmentList.add(a);
		  				}
		  			}
  				} catch (exception ae) {
  					system.debug(ae);
  					LoggerUtil.log(ae);
  				}
  				try {
  					if(binaryAttachments != null && binaryAttachments.size() > 0){
	  					for(Messaging.InboundEmail.BinaryAttachment ba: binaryAttachments) {
	  						Attachment a = new Attachment(ParentId = rfp.Id, 
	                                          Name = ba.filename, 
	                                          Body = ba.body);
	            			attachmentList.add(a);
	  					}
	  				}
				} catch (exception be) {
  					LoggerUtil.log(be);
  					system.debug(be);
  				}
  				insert attachmentList;
			} catch (exception e) {
				LoggerUtil.log(e);
				system.debug(e);
				result.success = false;
  			}
		} catch (Exception ex) {
			LoggerUtil.log(ex);
			System.debug('Exception : ' + ex);
			result.success = false;
		}
		LoggerUtil.commitLogs();
		return result;
	}
}