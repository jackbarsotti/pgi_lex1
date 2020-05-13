public with sharing class RequestForChangeRetractApproval {
	public Id recordId;
	public RequestForChangeRetractApproval(ApexPages.StandardController controller) {
		recordId = ApexPages.currentPage().getParameters().get('id');
	}
	public PageReference retractApproval() {
		
		Request_For_Change__c rfc = new Request_For_Change__c(Status__c = 'New', Id = recordId);
		try{	
			update rfc;
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to retract: '+ e.getMessage()));
			return null;
		}
		PageReference pr = new ApexPages.StandardController(rfc).view();
		return pr;
	}
}