public class DataRetentionBatch implements Database.Batchable<sObject>, Database.Stateful {
	public class DataRetentionException extends Exception{}
	private List<Id> jobIdsToProcess;
	private Integer currentJobIndex;
	//private DataRetentionJobWrapper jobWrapper;
	//constructor used for initialization
	public DataRetentionBatch() {
		this.currentJobIndex = 0;
		Map<Id, FilterObject__c> filterObjectMap = new Map<Id, FilterObject__c>([SELECT Id, Object__c FROM FilterObject__c WHERE Status__c = 'Active' ORDER BY Process_Order__c]);
		this.jobIdsToProcess = new List<Id>(filterObjectMap.keySet());
	}
	//constructor used for continuation
	public DataRetentionBatch(DataRetentionJobWrapper drj) {
		this.jobIdsToProcess = drj.jobIdsToProcess;
		this.currentJobIndex = drj.lastJobProcessed + 1;
	}
	public class DataRetentionJobWrapper {
		public List<Id> jobIdsToProcess;
		public Integer lastJobProcessed;
		
		public DataRetentionJobWrapper(List<Id>jobIdsToProcess, Integer currentJobIndex) {
			this.jobIdsToProcess = jobIdsToProcess;
			this.lastJobProcessed = currentJobIndex;
		}
	}
	public Database.QueryLocator start(Database.BatchableContext BC) {
		try {
			if(currentJobIndex > jobIdsToProcess.size() - 1) {
				throw new DataRetentionException('Job index ['+currentJobIndex+'] is greater than jobs to process size['+jobIdsToProcess.size()+']');
			}
			System.debug('jobIdsToProcess-->'+jobIdsToProcess);
			System.debug('currentJobIndex--->'+currentJobIndex);
			String query = DataRetentionService.buildRetentionQuery(jobIdsToProcess[currentJobIndex]);
			System.debug('query-->'+query);
			return Database.getQueryLocator(query);

		} catch (Exception e) {
			LoggerUtil.log('Job failed to start', e);
		}
		LoggerUtil.commitLogs();
		//skip this bad query and move pass a bunk query that will return no results so we can continue processing other jobs
		return Database.getQueryLocator('SELECT Id FROM Account WHERE Id = null');
	}

   	public void execute(Database.BatchableContext BC, List<sObject> scope) {
   		try {
   			// check if deleting Cases, then run disassociate for related Accounts and Contacts prior to Delete
   			// check if deleting Contacts or Accounts then run disassociate for related Cases
   			String jobObject = scope[0].Id.getSObjectType().getDescribe().getName();
   			if(jobObject == 'Case') {
   				System.debug('Cases disassociate Accounts/Contacts');
   				DataRetentionService.disassociateCaseAccounts(scope);
   				DataRetentionService.disassociateCaseContacts(scope);
   			}
   			else if(jobObject == 'Account') {
   				System.debug('Accounts disassociate related Cases');
   				DataRetentionService.disassociateAccountRelatedCases(scope);
   			}
   			else if(jobObject == 'Contact') {
   				System.debug('Contact disassociate related Cases');
   				DataRetentionService.disassociateContactRelatedCases(scope);
   			}
   			System.debug(scope);
   			List<Database.DeleteResult> drList = Database.delete(scope, false);
   			LoggerUtil.handleDeleteResults(drList, 'Data Retention Batch:' + jobIdsToProcess[currentJobIndex] + ' process order: ' + currentJobIndex, false);
   		} catch (Exception e) {
   			LoggerUtil.log('Data Retention Batch failed to delete records', e);
   		}
   		LoggerUtil.commitLogs();
	}
	
	public void finish(Database.BatchableContext BC) {
		System.debug(jobIdsToProcess.size());
		System.debug(currentJobIndex);
		if(currentJobIndex >= jobIdsToProcess.size() - 1) {
			sendSummary();
		} else {
			//continue processing records
			DataRetentionJobWrapper continuationWrapper = new DataRetentionJobWrapper(this.jobIdsToProcess, this.currentJobIndex);
			DataRetentionBatch continuationBatch = new DataRetentionBatch(continuationWrapper);
			Id nextJobId = continuationWrapper.jobIdsToProcess[currentJobIndex + 1];
			
			List<FilterObject__c> fo = [SELECT Id, Object__c FROM FilterObject__c WHERE Status__c = 'Active' AND Id =: nextJobId];
			Integer batchSize = 50;
			try{
				if(fo.size() > 0) {
					if(fo[0].Object__c.toUpperCase() == 'EVENT') {
						batchSize = 1;
					}
				}
				Database.executeBatch(continuationBatch, batchSize);
			} catch (Exception e) {
				LoggerUtil.log('Dataretention batch', e);
			}
				
		}
	}
	public void sendSummary() {

	}
}