public class AccountRevenueForecastSchedule implements Database.Batchable<sObject>, Schedulable{
	/*As Andrew Account Admin, 
	I need to create a new monthly batch trigger for ReadyTalk Accounts, 
	so that Revenue Category is updated on the 5th of each month.
		Only if Status = Active and Internal/Test Account = FALSE
	*/
	public Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator([SELECT Id, 
											Commission_Start_Date__c, 
											Revenue_Category__c 
										FROM Account 
										WHERE RecordTypeId IN: ReadyTalkRecordTypeHelper.readyTalkAccountRecordTypeIds
										AND Active_Account__c = true
										AND Test_Account__c = false]);
	}
	public void execute(Database.BatchableContext BC, List<Account> scope){
		/*
		Bulk Update of RT Account "Revenue Category" 
		Only if Status = Active and Internal/Test Account = FALSE

		If Commission Start Date is in "This year" - Mark Revenue Category Field as New 
		If Commission Start Date is in "Last year" - Mark Revenue Category Field as Transition 
		If Commission Start Date is anything else - Mark Revenue Category Field as Base
		*/
		List<Account> toUpdate = new List<Account>();
		Integer currentYear = System.today().year();
		for(Account a: scope) {
			if(a.Commission_Start_Date__c.year() == currentYear) {
				if(a.Revenue_Category__c != 'New') {
					a.Revenue_Category__c = 'New';
					toUpdate.add(a);
				}
			} else if (a.Commission_Start_Date__c.year() == (currentYear - 1)) {
				if(a.Revenue_Category__c != 'Transition') {
					a.Revenue_Category__c = 'Transition';
					toUpdate.add(a);
				}
			} else {
				if(a.Revenue_Category__c != 'Base') {
					a.Revenue_Category__c = 'Base';
					toUpdate.add(a);
				}
			}
		}
		Database.update(toUpdate, false);
	}
	public void finish(Database.BatchableContext BC){
		
	}
	public void execute(SchedulableContext SC){
		AccountRevenueForecastSchedule b = new AccountRevenueForecastSchedule();
		Database.executeBatch(b, 50);
	}
}