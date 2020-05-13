public without sharing class RequestForChangeTriggerHandler extends TriggerHandler {
	public RequestForChangeTriggerHandler() {
		super('RequestForChangeTriggerHandler');
	}
	protected override void beforeInsert() {
		setOwnerFromAssignmentGroup(); //KEEP

		setApprovalManager();
	}
	protected override void beforeUpdate() {
		setOwnerFromAssignmentGroup();

		setApprovalManager();
		
	}
	protected override void afterUpdate() {
		
	}


	private void setApprovalManager() {
		for(Request_For_Change__c rfc: (List<Request_For_Change__c>)Trigger.new) {
			if(!String.isBlank(rfc.Assignment_Group__c)) {
				if(!String.isBlank(approvalManagerByAssignmentGroup.get(rfc.Assignment_Group__c))) {
					//TODO - rfc.Assignment_Group_Manager__c
					rfc.Product_Manager__c = approvalManagerByAssignmentGroup.get(rfc.Assignment_Group__c);
				}
			}
		}
	}

	private static Map<String, Id> approvalManagerByAssignmentGroup {get{
		if(approvalManagerByAssignmentGroup == null) {
			approvalManagerByAssignmentGroup = new Map<String, Id>();
			for(RFC_Settings__mdt setting: [SELECT Id, Product__c, Product_Manager_Id__c, Assignment_Group_Name__c FROM RFC_Settings__mdt]) {
				if(String.isNotBlank(setting.Assignment_Group_Name__c)) {
					approvalManagerByAssignmentGroup.put(setting.Assignment_Group_Name__c, setting.Product_Manager_ID__c);
				}
			}
		}
		return approvalManagerByAssignmentGroup;
	}set;}
	private void setOwnerFromAssignmentGroup() {
		for(Request_For_Change__c rfc: (List<Request_For_Change__c>)Trigger.new) {
			if(isChanged('Assignment_Group__c', rfc) && !String.isBlank(rfc.Assignment_Group__c)) {
				if(rfcQueueByName.get(rfc.Assignment_Group__c) != null) {
					rfc.OwnerId = rfcQueueByName.get(rfc.Assignment_Group__c);
				}
			}
		}
	}

	private static Map<String, Id> rfcQueueByName {get {
		if(rfcQueueByName == null) {
			rfcQueueByName = new Map<String, Id>();
			for(QueueSobject q: [SELECT QueueId, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE SobjectType = 'Request_For_Change__c']){
				rfcQueueByName.put(q.Queue.Name, q.QueueId);
			}	
		}
		return rfcQueueByName;
	} set;}
}