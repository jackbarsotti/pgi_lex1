global with sharing class CaseCountdownTimer {
	
	public Case cse {get;set;}
	private ApexPages.StandardController controller {get; set;}

	public CaseCountdownTimer(ApexPages.StandardController controller) {
		List<String> fieldList = new List<String>(Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap().keyset());       
        if(!Test.isRunningTest()){ 
            // Add fields to controller. This is to avoid the SOQL error in visualforce page
            controller.addFields(fieldList);
        }
        cse = (Case)controller.getRecord();
	}

	public CaseCountdownTimer() { }

	@RemoteAction
    global static CaseTimerWrapper refreshTimers(String recordId) {
        System.debug(recordId);
        return new CaseTimerWrapper(recordId);
    }

    @RemoteAction
    global static CaseTimerWrapper queryCaseQueues() {
    	return new CaseTimerWrapper();
    }

    @RemoteAction
    global static List<Case> queryCasesByQueueId(String selectedQueueId) {
        // get 15 character value
        String queueId = selectedQueueId.length() == 18 ? selectedQueueId.substring(0,15) : selectedQueueId;
        List<Case> cases = new List<Case>();

	 	Map<String, Schema.FieldSet> caseFieldSetMap = Schema.sObjectType.Case.FieldSets.getMap();
		Set<String> caseListViewFields = new Set<String>();
		for(FieldSetMember field : caseFieldSetMap.get('PGi_Working_Views').getFields()) {
            caseListViewFields.add(field.getFieldPath());
        }
        String caseListViewQuery = 'SELECT ';
        for(String field : caseListViewFields) {
            caseListViewQuery += field + ',';
        }
        caseListViewQuery = caseListViewQuery.removeEnd(',');
        caseListViewQuery += ' FROM Case WHERE OwnerId = :queueId';
        
        System.debug(caseListViewQuery);
        cases = Database.query(caseListViewQuery);

        
        return cases;
    }

    @RemoteAction
    global static void saveAssignToMe(List<Id> caseIds) {
    	System.debug(caseIds);
    	System.debug(UserInfo.getUserId());
    	List<Case> updateCases = new List<Case>();
    	Id myId = UserInfo.getUserId();
    	for(Id caseId : caseIds) {
    		updateCases.add(new Case(Id = caseId, Assigned_To__c = myId));
    	}

    	if(!updateCases.isEmpty()) {
    		update updateCases;
    	}
    }

    global class CaseTimerWrapper {
    	public String timeToRestore {get;set;}
    	public String timeToResolve {get;set;}
    	public String resolveColor {get;set;}
    	public String restoreColor {get;set;}
    	public String status {get;set;}
    	public List<Case> cases {get;set;}
    	public List<Group> caseQueues {get;set;}

		// EMAIL SLA MGMT
		public String timeToSLA {get;set;}
		public String slaColor {get;set;}
    	
    	public CaseTimerWrapper(String recordId) {
    		
    		Case thisCase = [SELECT Id, Time_to_Resolve__c, Time_to_Restore__c,
    							Restore_Color_Field__c, Resolve_Color_Field__c, Status,
								SLA_Color__c, RecordTypeId, SLA_Time_Remaining2__c
    					     FROM Case
    					     WHERE Id = :recordId];
	     	// TODO: perform a record type check here to incorporate new SLA fields an multi purpose this apex class for a new VF component
			string caseRecordTypeName = Schema.SObjectType.Case.getRecordTypeInfosById().get(thisCase.RecordTypeId).getname();

			if(caseRecordTypeName == 'Inbound Email Support' || caseRecordTypeName == 'Outbound Email Support') {
				this.timeToSLA = thisCase.SLA_Time_Remaining2__c;
				this.slaColor = thisCase.SLA_Color__c;
				this.status = thisCase.Status;
			}
			else {
				this.timeToRestore = thisCase.Time_to_Restore__c;
				this.timeToResolve = thisCase.Time_to_Resolve__c;
				this.resolveColor = thisCase.Resolve_Color_Field__c;
				this.restoreColor = thisCase.Restore_Color_Field__c;
				this.status = thisCase.Status;
			}
    	}

    	public CaseTimerWrapper() {
    		this.caseQueues = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Id IN (SELECT QueueId FROM QueueSObject WHERE SObjectType = 'Case')];
    	}
    }
}