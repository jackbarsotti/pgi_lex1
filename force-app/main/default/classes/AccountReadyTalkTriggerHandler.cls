public with sharing class AccountReadyTalkTriggerHandler extends TriggerHandler {
	public AccountReadyTalkTriggerHandler() {
		super('AccountReadyTalkTriggerHandler');
	}
	protected override void beforeInsert() {
		celigoUpdateAccount();
		addressChecks();
	}

	protected override void beforeUpdate() {		
		celigoUpdateAccount();
		addressChecks();
	}
	protected override void afterInsert() {
		acctOwnerChanged();
		createRates();
	}
	protected override void afterUpdate() {
		acctOwnerChanged();
	}
	private static Set<Id> accountsWithRatesCreated = new Set<Id>();
	private void createRates() {
		List<Event_Webcasting_Rates__c> ratesToInsert = new List<Event_Webcasting_Rates__c>();
		for(Account a: qualifiedReadyTalkAccounts) {
			SObjectType rateType = Event_Webcasting_Rates__c.sObjectType;
			if(!accountsWithRatesCreated.contains(a.Id)) {
				accountsWithRatesCreated.add(a.Id);
				Event_Webcasting_Rates__c rate = (Event_Webcasting_Rates__c)rateType.newSObject(/*recordTypeId*/ null, /*loadDefaults*/ true);
				rate.Related_Account__c = a.Id;
				ratesToInsert.add(rate);
			}
		}
		insert ratesToInsert;
	}
	//replaces the AccountAfterInsertAfterUpdate trigger
	private void acctOwnerChanged(){
			// and don't do anything more if it's the data.com process
		if(UserInfo.getUserName().startsWith('automatedclean')
			|| UserInfo.getUserName().startsWith('autoproc'))
		return;

		//Ensure we are not the System Admin API Only user (we don't want the e-mail to be generated if we are)
		if(!Test.isRunningTest()){
			if (profile != null && String.isNotBlank(profile.Name) && (profile.Name.equals('System Admin API Only') || profile.Name.equals('System Administrator'))) {
				return;
			}
		}
		if(qualifiedReadyTalkAccounts.size() > 0) {
			AccountActions.onAccountOwnerChanged(qualifiedReadyTalkAccounts, trigger.old);
		}
	}

	//replaces the celigoUpdateAccount trigger
	private void celigoUpdateAccount() {
		for(Account a: qualifiedReadyTalkAccounts) {
			//if(a.Celigo_Update__c) {
			//	a.Celigo_Update__c = false;
			//	continue;
			//}
			if(Trigger.isInsert) {
				a.NetSuite_Id__c = null;
				a.NetSuite_Locked__c = false;
				a.NS_Sync__c = null;
			}
			if(a.Provisioned__c == false) {
				continue;
			}
			a.NetSuite_Push__c = true;
			a.NetSuite_Pull__c = true;
		}
	}
	private List<Account> qualifiedReadyTalkAccounts { get {
		if(qualifiedReadyTalkAccounts == null) {
			qualifiedReadyTalkAccounts = new List<Account>();
			for(Account a: (List<Account>)trigger.new) {
				if(ReadyTalkRecordTypeHelper.readyTalkAccountRecordTypeIds.contains(a.RecordTypeId)) {
					qualifiedReadyTalkAccounts.add(a);
				}
			}
		}
		return qualifiedReadyTalkAccounts;
	} set;}
	private static Profile profile {get {
		return PGI_Utility.profile;
	} set; }
	//replaces the AccountBeforeInsertBeforeUpdate trigger
	private void addressChecks() {
		// Sync the standard and custom address fields prior to validation.
		AccountActions.syncAddressFields(Trigger.new, Trigger.old);
		//AccountActions.copyBillingAddressToShippingAddress(Trigger.new, Trigger.old);
		//Ensure we are not the System Admin API Only user (we don't want the e-mail to be generated if we are)
		if(profile != null && profile.Name != null && (
			profile.Name.equals('System Admin API Only') || profile.Name.equals('System Administrator')))
			return;	
		//Data.com validate	
		if(!ValidateAccountFields.validateAccountSource(Trigger.new)) return;
		//Validate Account fields
		if(!ValidateAccountFields.validateInvoiceFormat(Trigger.new,Trigger.old)) return;
		if(!ValidateAccountFields.validateInvoiceTypes(Trigger.new, Trigger.old)) return;
		if(!ValidateAccountFields.validateBillingCountry(Trigger.new)) return;
		if(!ValidateAccountFields.validateAccessCodeCount(Trigger.new, Trigger.old)) return;
	}
}