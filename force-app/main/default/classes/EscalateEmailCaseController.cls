/*********************************************************************
Name : EscalateEmailCase
Created On : Oct 10, 2019
Created By : Anup
Description :  
**********************************************************************/
public class EscalateEmailCaseController {

	// public String currentRecordId {get;set;}
 
    // public EscalateEmailCaseController(ApexPages.StandardController controller) {
    //     currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
    // }
	// public Case record;

	// public EscalateEmailCaseController(ApexPages.StandardController sc) {
	// 	this.record = (Case)sc.getRecord();
	// }
	// public Case caseDetailsRecord {get; set;}
	// public PageReference init(){
	// 	caseDetailsRecord = [SELECT Id, Escalated__c, PGi_Client__c, PGi_Company__c FROM Case WHERE Id =: record.Id];
	// 	system.debug('==>'+caseDetailsRecord);
	// 	// if(this.record.Escalated__c == false) {
	// 	// 	//this.record.Escalated__c = true;
	// 	// 	try {
	// 	// 		update record;
	// 	// 		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Your case was successfully escalated.'));
	// 	// 	} catch (exception e) {
	// 	// 		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to escalate case. ' + e.getMessage()));
	// 	// 	}
	// 	// } else {
	// 	// 	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'This case has already been escalated.'));
	// 	// }
	// 	 return null;
	// }
	@AuraEnabled
	public static Case getCaseRecord(String recordId){
		return [SELECT Id, IsEscalated, PGi_Client__c, PGi_Company__c, Caller_Name__c, Origin, Subject, Status FROM Case WHERE Id =: recordId];
	}
	@AuraEnabled
	public static Boolean getIsEscalated(String recordId){
		// system.debug('====>'+recTypeName);
		// String recName = '%'+recTypeName+'%';
		// String query = 'SELECT Id, Name FROM RecordType WHERE name LIKE \'PGi-' + recTypeName + '\' and SobjectType =\''+ObjectName+'\'';
		// system.debug('query==>'+query);
		// 	system.debug('=query=====>'+Database.query(query));
		//  system.debug('====aaaa=='+[SELECT Id FROM RecordType WHERE name LIKE :('PGi-' + recTypeName + '') and SobjectType =: ObjectName]);
		//system.debug('-[SELECT Id FROM RecordType WHERE name LIKE'+ '%recTypeName%'+'and SobjectType=Case]->'+[SELECT Id FROM RecordType WHERE name LIKE recName and SobjectType ='Case']);
		return [SELECT Escalated__c FROM Case where id=:recordId].Escalated__c;
	}
	@AuraEnabled
	public static Id createCase(String recordId, Id recTypeId){
		List<String> fields = new List<String>(Case.SObjectType.getDescribe().fields.getMap().keySet());
		String soql = ''
       			 + ' select ' + String.join(fields, ',')
       			 + ' from Case '
				 + ' WHERE Id =: recordId ';
		Case caseRecord = Database.query(soql);	
				System.debug('===>'+caseRecord);
		Case escalatedRecord = caseRecord.clone();
		escalatedRecord.RecordTypeId = recTypeId;
		escalatedRecord.IsEscalated = true;
		Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            escalatedRecord.setOptions(dmo);
		INSERT escalatedRecord;
		system.debug('cloned=>'+escalatedRecord);
		return escalatedRecord.Id;
	}
	/**
	get current recordId , “Escalation Type” picklist of “Case” or “Financial Request” and dependent values.
	 */
	@AuraEnabled
	public static String createEscalationRecord(String recordId, String escalationType, String escalationRecordType ){

		Id recordTypeId = [SELECT Id FROM RecordType WHERE name LIKE :('%' + escalationRecordType + '%') and SobjectType =: escalationType limit 1].Id;
		Case currentCase = [SELECT ID, PGi_Client__c, Escalated__c,Email_address__c, PGi_Company__c, Subject, Caller_Name__c, ParentId, Follow_Up_Email_Address__c  
							FROM Case 
							WHERE Id =: recordId];
		String returnId ='';
		if(escalationType == 'Case'){
			Case escalatedCase = new Case(Origin = 'Email', 
									recordTypeId = recordTypeId,
									PGi_Client__c = currentCase.PGi_Client__c,
									PGi_Company__c = currentCase.PGi_Company__c,
									Follow_Up_Email_Address__c = currentCase.Email_address__c,
									Subject = currentCase.Subject,
									Caller_Name__c = currentCase.Caller_Name__c);
			INSERT escalatedCase;
			currentCase.ParentId = escalatedCase.Id;
			currentCase.Escalated__c = true;
			UPDATE currentCase;
			returnId = escalatedCase.Id;
		}else{
			
			Financial_Request__c finReq = new Financial_Request__c(
									recordTypeId = recordTypeId,
									PGi_Client__c = currentCase.PGi_Client__c,
									PGi_Company__c = currentCase.PGi_Company__c,
									SuppliedEmail__c = currentCase.Email_address__c, 
									Subject__c = currentCase.Subject,
									Origin__c = 'Email',
									Related_Case__c = currentCase.Id);			
			INSERT finReq;
			currentCase.Escalated__c = true;
			UPDATE currentCase;
			returnId = finReq.Id;
		}
		return returnId;
	}
}