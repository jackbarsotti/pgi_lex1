global class FinReqNASupportEmailService implements Messaging.InboundEmailHandler {
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope env) {
	  	// Create an InboundEmailResult object for returning the result of the Apex Email Service
	  	Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
	  	try {
	  		result.success = true;
	  		//Within the email header content, search for the "X-SFDC-LK" & "X-SFDC-User" values
	  		Id finReqId;
	  		//X-SFDC-EntityId: a8E1B000000fxjo
	  		if(email.headers != null && email.headers.size() > 0) {
		  		for(Messaging.InboundEmail.Header header: email.headers) {
		  			if(header.name == 'X-SFDC-EntityId') {
		  				finReqId = (Id)header.value;
		  			}
		  		}
		  	}
		  	String subject = email.subject;
		  	if(finReqId == null) {
		  		if(subject.contains('FinReq# ')) {
		  			String finreqNum = subject.right(8);
		  			try {
		  				finReqId = [SELECT Id FROM Financial_Request__c WHERE Name=: 'FinReq# ' + finreqNum].Id;
		  			} catch (Exception e) {
		  				System.debug(e);
		  			}
		  		}
		  	}

	  		Financial_Request__c fr;
	  		if(finReqId != null) {
	  			List<Financial_Request__c> frList = [SELECT Id FROM Financial_Request__c WHERE Id =: finReqId];
	  			if(frList.size() > 0) {
	  				fr = frList[0];
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
				Group q = [SELECT Id FROM GROUP WHERE Type = 'Queue' AND DeveloperName = 'PGi_FinReq_NA_Email_Support'];
  				if(fr == null) {
	  				fr = new Financial_Request__c();
	  				List<RecordType> rtList = [SELECT Id FROM RecordType WHERE sObjectType = 'Financial_Request__c' AND Name = 'PGi-Billing Support'];
                    
	  				if(!rtList.isEmpty()) {
	  					fr.RecordTypeId = rtList[0].Id;
	  				}
	  				fr.Region__c = 'NA';
  					fr.Subject__c = subject; 
  					fr.Description__c = body; 
  					// fr.Submitted_By_User__c = submittedBy != null ? submittedBy.Id : null;
  					fr.Origin__c = 'Email';
  					fr.Status__c = 'New';
  					fr.Priority__c = '4 - Low';
                    fr.Type__c = 'Email Support';
  					fr.Request_Type__c = 'Email Request';
                    fr.OwnerId = q.Id;
					fr.RequestorsEmail__c = emailSentFrom;
					fr.Requested_For__c = emailSentFrom;
  					insert fr;
  				}else{
					  fr.Status__c = 'Customer Replied';
					  update fr;
				  }
				Recordtype taskRecordType = [SELECT Id  FROM Recordtype WHERE sobjectType ='Task' AND Name = 'FinReq Emails'];
				Task newTask = new Task(
					Description = description,
					Priority = 'Normal',
					Subject = subject,
					Type = 'Email',
					Status = 'completed',
					RecordType = taskRecordType,
					IsReminderSet = false,
					ActivityDate = System.today(),
                    // OwnerId = q.Id,
					WhatId = fr.Id
				);
				insert newTask;
  				
  				List<Attachment> attachmentList = new List<Attachment>();
  				try {
  					if(textAttachments != null && textAttachments.size() > 0){
		  				for(Messaging.InboundEmail.TextAttachment ta: textAttachments) {
		  					 Attachment a = new Attachment(ParentId = fr.Id, 
		                                          Name = ta.filename, 
		                                          Body = Blob.valueOf(ta.body));
		            		attachmentList.add(a);
		  				}
		  			}
  				} catch (exception ae) {
  					system.debug(ae);
  					LoggerUtil.log(ae);
					if(Test.isRunningTest()) {
						System.assert(false, ae);
					}
  				}
  				try {
  					if(binaryAttachments != null && binaryAttachments.size() > 0){
	  					for(Messaging.InboundEmail.BinaryAttachment ba: binaryAttachments) {
	  						Attachment a = new Attachment(ParentId = fr.Id, 
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