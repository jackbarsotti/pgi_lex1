public class ProblemReviewTicketTriggerHandler extends TriggerHandler{
	public ProblemReviewTicketTriggerHandler() {
		super('ProblemReviewTicketTriggerHandler');
	}
    protected override void beforeInsert() {
        setOwnerFromAssignmentGroup();
    }
    protected override void beforeUpdate() {
        setOwnerFromAssignmentGroup();
    }
    private void setOwnerFromAssignmentGroup() {
		for(Problem_Review_Ticket__c rfc: (List<Problem_Review_Ticket__c>)Trigger.new) {
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
			for(QueueSobject q: [SELECT QueueId, Queue.DeveloperName, Queue.Name FROM QueueSobject WHERE SobjectType = 'Problem_Review_Ticket__c']){
				rfcQueueByName.put(q.Queue.Name, q.QueueId);
			}	
		}
		return rfcQueueByName;
	} set;}
}