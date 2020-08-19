public class TaskTriggerHandler extends triggerHandler {
	
	public override void beforeInsert() {
		assignPGiClientlookupField((List<Task>)trigger.new);
		setRecordType();
	}

    public override void beforeUpdate() {
		assignPGiClientlookupField((List<Task>)trigger.new);
		setRecordType();
	}
	public override void afterInsert() {
		createAttachmentQuote((List<Task>)trigger.new);
	}

	/**
	PGi Client lookup field on the Task object populated if the Task is set against the Case object and the Case field for PGi Client is populated.
	 */
	private void assignPGiClientlookupField(List<Task> taskList){
		Set<Id> whatIdSet = new Set<Id>(); // used to store case and Call_Log__c id's

		List<Task> taskToUpdate = new  List<Task>(); // loop through  this records to update PGi_Client__c
		
		Schema.DescribeSObjectResult callLog = Call_Log__c.sObjectType.getDescribe(); // get key prefix of Call_Log__c 
        String callLogKeyPrefix = callLog.getKeyPrefix();
 
		for(Task objTask : taskList){
			if(objTask.WhatId != null && ( String.valueOf(objTask.WhatId).startsWith('500') || 
											String.valueOf(objTask.WhatId).startsWith(callLogKeyPrefix))){  
				whatIdSet.add(objTask.WhatId);
				taskToUpdate.add(objTask);
			}
		}

		if(!whatIdSet.isEmpty()){
			
			Map<Id, Case> taskById = new Map<Id, Case>([SELECT Id, PGi_Client__c FROM Case WHERE Id =: whatIdSet ]);			 
			Map<Id, Call_Log__c> calLogById = new Map<Id, Call_Log__c>([SELECT Id, PGi_Client__c FROM Call_Log__c WHERE Id =: whatIdSet ]);			 
			
			for(Task objTask : taskToUpdate){
				if(taskById.containsKey(objTask.WhatId)){ // check with case 
					Case parentCase = taskById.get(objTask.WhatId);
					if(parentCase.PGi_Client__c != null){
						objTask.PGi_Client__c = parentCase.PGi_Client__c;
					}
				}else if(calLogById.containsKey(objTask.WhatId)){ //check with Call_Log__c
					Call_Log__c parentCallLog = calLogById.get(objTask.WhatId);
					if(parentCallLog.PGi_Client__c != null){
						objTask.PGi_Client__c = parentCallLog.PGi_Client__c; 
					}
				}
			}
		}
	}


	private void setRecordType() {
		String finReqKeyPrefix = Financial_Request__c.sObjectType.getDescribe().getKeyPrefix(); // get key prefix of Call_Log__c 
		Recordtype taskRecordType = [SELECT Id  FROM Recordtype WHERE sobjectType ='Task' AND Name = 'FinReq Emails'];
		for (Task objTask : (List<Task>)Trigger.new) {
			if (objTask.WhatId != null && String.valueOf(objTask.WhatId).startsWith(finReqKeyPrefix) && objTask.Type =='Email' ){  
				objTask.RecordTypeId = taskRecordType.Id;
			}
		}
	}
	private void createAttachmentQuote(List<Task> taskList){
		Map<Id,Id> activityIdByOppId = new Map<Id,Id>();
		for(Task taskObj : taskList){
			if(String.isNotBlank(taskObj.WhatId) && String.valueOf(taskObj.WhatId).startsWith('006')){
				activityIdByOppId.put(taskObj.WhatId, taskObj.id);
			}
		}
		Map<Id, Attachment> attachmentByParentId = new Map<Id,Attachment>();
		for(Attachment att : [SELECT Id, ParentId, Name, Body FROM Attachment WHERE ParentId IN: activityIdByOppId.keySet() LIMIT 1]){
			attachmentByParentId.put(att.ParentId, att);
		}
		List<Attachment> attachmentList = new List<Attachment>();
		for(Id key: attachmentByParentId.keySet()){
			Attachment attRec = attachmentByParentId.get(key);
			Attachment att = new Attachment();
			att.Name = attRec.Name;
			att.ParentId = activityIdByOppId.get(key);
			att.Body = attRec.Body;
			attachmentList.add(att);
		}
		if(!attachmentList.isEmpty()){
			INSERT attachmentList;
		}
	}
	
}