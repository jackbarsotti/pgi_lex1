public with sharing class CallLogExtension {
	private ApexPages.StandardController controller {get; set;}
	private Call_Log__c record { get {
		if(record == null) {
			record = (Call_Log__c)controller.getRecord();
		}
		return record;
	} set;}
	private class CallLogExtensionException extends Exception {}

	 //RT-228
	@RemoteAction
    public static PGI_Client__c getClientInfo(String clientName, Id clientId) {
        List<PGI_Client__c> clients = new List<PGi_Client__c>();
        try {
            if(!String.isBlank(clientId)) {
                clients = [SELECT Id, PGI_Company__c, PGI_Company__r.Name FROM PGI_Client__c WHERE Id =: clientId]; 
            } 
			if(clients.size() == 0) {
                clients = [SELECT Id, PGI_Company__c, PGI_Company__r.Name FROM PGI_Client__c WHERE Name =: clientName]; 
            }
			if(clients.size() > 0) {
				return clients[0];
			}
        } catch (exception e) {
            System.debug(e);
        }
        return null;
    }
	
	private String i {get {
		i = (Id)ApexPages.currentPage().getParameters().get('Id');
		if(String.isBlank(i)) {
			i = (Id)ApexPages.currentPage().getParameters().get('Call_Log__c.Id');
		}
		return i;
	} set;}
	public static List<String> fieldList = new List<String>(Schema.getGlobalDescribe().get('Call_Log__c').getDescribe().fields.getMap().keyset()); 
	public CallLogExtension (ApexPages.StandardController controller) {
        if(String.isNotBlank(i)) {
			ApexPages.currentPage().getParameters().put('Id', i);
		}
		if(!Test.isRunningTest()){ 
            // Add fields to controller. This is to avoid the SOQL error in visualforce page
            controller.addFields(fieldList);
        }
		
		this.controller = controller;
		if(!Test.isRunningTest()){
			//id theRecordTypeIdToDescribe = LayoutDescriberHelper.LayoutDescriberHelper.getDefaultRecordType(record);
			//get the layout section items
			layoutSections = LayoutDescriberHelper.describeSectionWithFields(LayoutDescriberHelper.getDefaultRecordType(record), 'Call_Log__c');
			//get the assignment section for displaying 
			assignmentSections = LayoutDescriberHelper.describeAssignment(LayoutDescriberHelper.getDefaultRecordType(record), 'Call_Log__c');
		}
	}
	private Id getRecordType(String objectName, String rtName) {
		String pgiRtName = 'PGi-' + rtName;
		List<RecordType> rtList = [SELECT Id FROM RecordType WHERE sObjectType =: objectName AND (Name =: rtName OR Name =: pgiRtName)];
		if(rtList.size() > 0) {
			return rtList[0].Id;
		} else {
			return null;
		}
	}
	public PageReference createCallLog() {
		try {
			if(record.Id == null) {
				if(record.Call_Status__c == 'Escalation Needed') {
					String recordType = record.Escalation_Record_Type__c;
					String escalationType = record.Escalation_Type__c;
					if (escalationType == 'Case') {
						escalationType = record.Escalation_Type__c;
						String recordTypeId = getRecordType('Case', recordType);
						if(String.isBlank(recordTypeId)) {
							throw new CallLogExtensionException('No valid record type named ' + recordType);
						}
						Case c = (Case)Case.sObjectType.newSObject(recordTypeId, true);
						c.PGi_Client__c = record.PGi_Client__c;
						c.PGi_Company__c = record.PGi_Company__c;
						c.IsEscalated = true;
						// STRAT RT-431: Automatically run assignment rules for the new Case created.
						Database.DMLOptions dmo = new Database.DMLOptions();
						dmo.assignmentRuleHeader.useDefaultRule = true;
						c.setOptions(dmo);

						insert c;
						System.debug('The id Is'+c.Id);
						record.Related_Case__c = c.Id;
						insert record;
						PageReference p = new PageReference('/apex/CaseTabViewer');
						// p.getParameters().put('email', emailMsgLst);
						p.getParameters().put('id', c.Id);
						p.getParameters().put('isNew', 'true');
						p.getParameters().put('RecordType', recordTypeId);
						p.setRedirect(true);
						return p;
						//return new PageReference('/'+ c.Id + '/e');
					} else if (escalationType == 'FinReq') {
						String recordTypeId = getRecordType('Financial_Request__c', recordType);
						if(String.isBlank(recordTypeId)) {
							throw new CallLogExtensionException('No valid record type named ' + recordType);
						}
						Financial_Request__c f = (Financial_Request__c)Financial_Request__c.sObjectType.newSObject(recordTypeId, true);
						f.PGi_Client__c = record.PGi_Client__c;
						f.PGi_Company__c = record.PGi_Company__c;
						insert f;
						record.Related_FinReq__c = f.Id;
						insert record;
						return new PageReference('/'+ f.Id + '/e');
	 				} else if (String.isBlank(recordType) || String.isBlank(escalationType)) {
	 					throw new CallLogExtensionException('For Status = Escalation Needed, must populate Escalation Type and Record Type');
	 				}
				} else {
					insert record;
				}
			} else {
				if(record.Call_Status__c == 'Escalation Needed' && String.isBlank(record.Related_Case__c)) {
					String recordType = record.Escalation_Record_Type__c;
					String escalationType = record.Escalation_Type__c;
					if (escalationType == 'Case') {
						escalationType = record.Escalation_Type__c;
						String recordTypeId = getRecordType('Case', recordType);
						if(String.isBlank(recordTypeId)) {
							throw new CallLogExtensionException('No valid record type named ' + recordType);
						}
						Case c = (Case)Case.sObjectType.newSObject(recordTypeId, true);
						c.PGi_Client__c = record.PGi_Client__c;
						c.PGi_Company__c = record.PGi_Company__c;
						c.Auto_Generated_For_Case__c = true;
						// STRAT RT-431: Automatically run assignment rules for the new Case created.
						Database.DMLOptions dmo = new Database.DMLOptions();
						dmo.assignmentRuleHeader.useDefaultRule = true;
						c.setOptions(dmo);

						insert c;
						System.debug('The id Is'+c.Id);
						record.Related_Case__c = c.Id;
						update record;

						// related RT-431: users dont have to set default on the page layouts,remember to check the box and can't uncheck the box
						PageReference p = new PageReference('/apex/CaseTabViewer');
						// p.getParameters().put('email', emailMsgLst);
						p.getParameters().put('id', c.Id);
						p.getParameters().put('isNew', 'true');
						p.getParameters().put('RecordType', recordTypeId);
						p.setRedirect(true);
        				return p;
						//return new PageReference('/'+ c.Id + '/e');
					} else if (escalationType == 'FinReq' && String.isBlank(record.Related_FinReq__c)) {
						String recordTypeId = getRecordType('Financial_Request__c', recordType);
						if(String.isBlank(recordTypeId)) {
							throw new CallLogExtensionException('No valid record type named ' + recordType);
						}
						Financial_Request__c f = (Financial_Request__c)Financial_Request__c.sObjectType.newSObject(recordTypeId, true);
						f.PGi_Client__c = record.PGi_Client__c;
						f.PGi_Company__c = record.PGi_Company__c;
						insert f;
						record.Related_FinReq__c = f.Id;
						update record;
						return new PageReference('/'+ f.Id + '/e');
	 				} else if (String.isBlank(recordType) || String.isBlank(escalationType)) {
	 					throw new CallLogExtensionException('For Status = Escalation Needed, must populate Escalation Type and Record Type');
	 				}
	 			}
	 			update record;
			}

		//	Upon saving, IF a user selected the Call Status of "Escalation Needed" they must pick which object (Case or FinReq) and which Record Type. 
		// Based off what they select, we want the user experience to be that they then select SAVE it should automatically take them into the new record that needs creating so they can begin creating that escalation record:
		//When going into the escalation record the PGi Client and PGi Company fields should carry forward IF they were populated on the Call Log
		//	IF creating a Case from the escalation process, please set the Case Origin value to "Direct Dial" if we can
		//	Once that record is saved, it should populate the "Related Case #" or the "Related FinReq #" back on the original Call Log so that the records are associated to each other.
		} catch (exception ex) {
			System.debug(ex);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
			return null;
		}
		return new PageReference('/' + record.Id);
	}
	public List<LayoutDescriberHelper.LayoutSection> 	layoutSections {get; set; }
	public List<LayoutDescriberHelper.AssignmentModel> 	assignmentSections {get; set; }
}