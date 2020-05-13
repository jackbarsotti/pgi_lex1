public with sharing class EscalateCase {
	public Case record;
	public EscalateCase(ApexPages.StandardController sc) {
		this.record = (Case)sc.getRecord();
	}
	public PageReference init(){
		record = [SELECT Id, Escalated__c FROM Case WHERE Id =: record.Id];
		if(this.record.Escalated__c == false) {
			this.record.Escalated__c = true;
			try {
				update record;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your case was successfully escalated.'));
			} catch (exception e) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to escalate case. ' + e.getMessage()));
			}
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'This case has already been escalated.'));
		}
		return null;
	}
	public PageReference goBack() {
		PageReference pageRef = new ApexPages.StandardController(record).view();
        pageRef.setRedirect(true);
        return pageRef;
	}
}