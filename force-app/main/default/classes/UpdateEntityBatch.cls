/*******************************************************************************************
Name : UpdateEntityBatch

Description : Batch Apex to update the number of companies per entity
********************************************************************************************/
public class UpdateEntityBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
	public Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'SELECT Id, PGI_Entity__c ' +
						' FROM PGi_Company__c ORDER BY PGI_Entity__c';
		return Database.getQueryLocator(query);
	}
 	public UpdateEntityBatch() {
		entityCountMap = new Map<Id, Integer>();
		processing = new Map<Id, PGi_Entity__c>();
	}
	public void execute(Database.BatchableContext BC, List<PGi_Company__c> companyList) {
		System.debug(entityCountMap.size());
		List<PGi_Entity__c> entityToUpdateImmediately = new List<PGi_Entity__c>();
		Set<Id> entitySet = new Set<Id>();
		for(PGi_Company__c company: companyList) {
			if(String.isNotBlank(company.PGi_Entity__c)){
				entitySet.add(company.PGi_Entity__c);
			}
			if(processing.containsKey(company.PGI_Entity__c)) {
				processing.remove(company.PGI_Entity__c);
			}
		}
		for(PGI_Entity__c entity: processing.values()) {
			entityToUpdateImmediately.add(entity);
			if(processing.containsKey(entity.Id)) {
				processing.remove(entity.Id);
			}
		}

		Map<Id, PGI_Entity__c> entityMap = new Map<Id, PGI_Entity__c>([SELECT Id, CountofCompanies__c FROM PGI_Entity__c WHERE Id IN: entitySet]);
		System.debug(entityMap);
		
		for(PGi_Company__c company: companyList) {
			if(String.isBlank(currentEntityId)) {
				if(String.isNotBlank(company.PGi_Entity__c)) {
					currentEntityId = company.PGi_Entity__c;
				}
			}
			system.debug('company: ' + company);
			system.debug('entity count: ' + entityCountMap.get(company.PGI_Entity__c));
			if(String.isNotBlank(company.PGI_Entity__c)) {
				Integer count = entityCountMap.get(company.PGI_Entity__c) == null ? 0 : entityCountMap.get(company.PGI_Entity__c);
				count++;
				entityCountMap.put(company.PGI_Entity__c, count);
			}
			system.debug('entity count: ' + entityCountMap.get(company.PGI_Entity__c));
			if(String.isNotBlank(currentEntityId) && String.isNotBlank(company.PGi_Entity__c) && company.PGi_Entity__c != currentEntityId) { //entity changed
				//if the value of the entity needs to change - update the entity
				if(entityMap.get(currentEntityId) != null && entityMap.get(currentEntityId).CountofCompanies__c != entityCountMap.get(currentEntityId)) {
					entityToUpdateImmediately.add(new PGI_Entity__c(Id = currentEntityId, CountofCompanies__c = entityCountMap.get(currentEntityId)));
				}
				currentEntityId = company.PGi_Entity__c;
			}
		}
		system.debug(currentEntityId);

		//possible we didn't change entity id in this iteration - so hang onto it for next go around
		if(currentEntityId != null && entityMap.get(currentEntityId).CountofCompanies__c != entityCountMap.get(currentEntityId)) {
			processing.put(currentEntityId, new PGI_Entity__c(Id = currentEntityId, CountofCompanies__c = entityCountMap.get(currentEntityId)));
		}
		system.debug(processing);
		update entityToUpdateImmediately;

	}
	public void finish(Database.BatchableContext BC) {
		system.debug('updating processing set' + processing);
		update processing.values();
	}
	public Map<Id, Integer> entityCountMap {get; set;}
	public Id currentEntityId {get; set;}
	public Map<Id, PGi_Entity__c> processing {get; set;}
	public void execute(SchedulableContext sc) {
		Database.executeBatch(new UpdateEntityBatch());
	}
}