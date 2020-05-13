@IsTest
public with sharing class RequestForChangeRetractApprovalTest {
	@isTest
	public static void testFailureController() {
    	Request_For_Change__c testRelatedRFCRecord = PGITestUtilities.createRFC(false);
        insert testRelatedRFCRecord;

		//ApexPages.StandardController sc = new ApexPages.StandardController(testRelatedRFCRecord);
		//RequestForChangeRetractApproval ext = new RequestForChangeRetractApproval(sc);
		//ext.retractApproval();
		//System.assertEquals([SELECT Status__c FROM Request_For_Change__c].Status__c, 'Approved');

		//PageReference pr = Page.RequestForChangeRetractApproval;
		//pr.getParameters().put('id', testRelatedRFCRecord.Id);
		//Test.setCurrentPage(pr);
		//ext.recordId = testRelatedRFCRecord.Id;
		//ext.retractApproval();
		//System.assertEquals([SELECT Status__c FROM Request_For_Change__c].Status__c, 'New');
	}
}