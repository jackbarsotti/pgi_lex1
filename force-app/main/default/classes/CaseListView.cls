public with sharing class CaseListView {
	

	public CaseListView() {
		if(ApexPages.currentPage().getParameters().get('queueId') != null) {
			queueId = (Id)ApexPages.currentPage().getParameters().get('queueId');
		}
		changeOwnerLookup = new Case();
	}
	public CaseListView(CaseCountdownTimer controller) {
		if(ApexPages.currentPage().getParameters().get('queueId') != null) {
			queueId = (Id)ApexPages.currentPage().getParameters().get('queueId');
		}
		changeOwnerLookup = new Case();
	}
	public PageReference doNothing() {
		return null;

	}
	public PageReference addParams(PageReference pr) {
		pr.getParameters().put('queueId', queueId);
		return pr;
	}
	public boolean displayPopup {get; set;}     
    
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {        
        displayPopup = true;    
    }
	public transient List<Case> caseList {get {
		List<Case> cases = new List<Case>();
		if(queueId != null) {
			Map<String, Schema.FieldSet> caseFieldSetMap = Schema.sObjectType.Case.FieldSets.getMap();
			Set<String> caseListViewFields = new Set<String>();
			for(FieldSetMember field : caseFieldSetMap.get('PGi_Working_Views').getFields()) {
	            caseListViewFields.add(field.getFieldPath().toLowerCase());
	        }
	        caseListViewFields.addAll(new Set<String>{'time_to_restore__c', 'restore_color_field__c', 'time_to_resolve__c', 'resolve_color_field__c'});
	        String caseListViewQuery = 'SELECT ';
	        for(String field : caseListViewFields) {
	            caseListViewQuery += field + ',';
	        }
	        caseListViewQuery = caseListViewQuery.removeEnd(',');
	        caseListViewQuery += ' FROM Case WHERE IsClosed = false AND OwnerId = :queueId LIMIT 500';
	        cases = Database.query(caseListViewQuery);
	    }
	    return cases;
        
	} set;}

	

	public Id queueId {get; set;}

	public PageReference refresh(){
		return addParams(new PageReference('/apex/CaseListView').setRedirect(true));
	}

	public PageReference addQueue(){
		return addParams(new PageReference('/apex/CaseListView').setRedirect(true));
	}

	public List<Group> caseQueues {get {
		if(caseQueues == null) {
			caseQueues = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Id IN (SELECT QueueId FROM QueueSObject WHERE SObjectType = 'Case') ORDER BY Name];
			
		}
		return caseQueues;
	} set;}

	public List<SelectOption> caseQueuesSelectionOptions { get {
		if(caseQueuesSelectionOptions == null) {
			caseQueuesSelectionOptions = new List<SelectOption>();
			for(Group q: caseQueues) {
				caseQueuesSelectionOptions.add(new SelectOption(q.Id, q.Name));
			}
		}
		return caseQueuesSelectionOptions;
	} set;}


	public List<CaseWrapper> caseWrapperList {get {
		
		if(caseWrapperList == null) {
			System.debug('constructing new list');
			caseWrapperList = new List<CaseWrapper>();
			for(Case c: caseList) {
				caseWrapperList.add(new CaseWrapper(c));
			}
		} 
		for(Case c: caseList) {
			Boolean hasCase = false;
			for(CaseWrapper cw: caseWrapperList) {
				if(cw.c.Id == c.Id) {
					System.debug('Found Match' + cw.selected);
					cw.c = c;
					hasCase = true;
					break;
				}
			}
			if(!hasCase) {
				System.debug('generating new case');
				caseWrapperList.add(new CaseWrapper(c));
			}
		}

		return caseWrapperList;
	} set;} 

	public Boolean showChangeOwner {get; set;}
	public PageReference changeOwner(){
		showChangeOwner = true;
		return null;
	}
	public Boolean notifyOwner {get; set;}
	public Case changeOwnerLookup {get; set;}
	public PageReference saveChangeOwner() {
		displayPopup = false;
		List<Case> updateCases = new List<Case>();
		for(CaseWrapper cw : caseWrapperList) {
			if(cw.selected != null && cw.selected == true) {
				updateCases.add(new Case(Id = cw.c.Id, OwnerId = changeOwnerLookup.OwnerId));
			}
		}
		if(!updateCases.isEmpty()) {
			Database.DMLOptions options = new Database.DMLOptions();
			options.EmailHeader.triggerUserEmail = true;
			options.optAllOrNone = true;
			//update updateCases;
			try {
				Boolean error = false;
				List<Database.SaveResult> srList = Database.update(updateCases, options);
				for(Database.SaveResult sr: srList) {
					if(!sr.isSuccess()) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to reassign owner.' + sr.getErrors()));
						error = true;
					}
				}
				if(error == true) {
					return null;
				}
			} catch (Exception e) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to reassign owner.' + e.getMessage()));
				return null;
			}
		}
		return addParams(new PageReference('/apex/CaseListView').setRedirect(true));
	}

	public PageReference assignToMe() {
		List<Case> updateCases = new List<Case>();
		for(CaseWrapper cw : caseWrapperList) {
			if(cw.selected != null && cw.selected == true) {
				updateCases.add(new Case(Id = cw.c.Id, Assigned_To__c = UserInfo.getUserId()));
			}
		}
		if(!updateCases.isEmpty()) {
			update updateCases;
		}
		return addParams(new PageReference('/apex/CaseListView').setRedirect(true));
	}
	
	//used for change owner
	public Case cse {get; set;}
	//used for change owner
	public Boolean sendNotification {get; set;}
	public class CaseWrapper {
		public Boolean selected {get; set;}
		public Case c {get; set;}
		public CaseWrapper(Case c) {
			this.c = c;
		}
	}
}