/**
 * @File Name          : TotangoPgiEntityController.cls
 * @Description        : 
 * @Author             : Anup Kage (anup@cloudfastener.com)
 * @Group              : 
 * @Last Modified By   : Anup Kage (anup@cloudfastener.com)
 * @Last Modified On   : 3/13/2020, 5:52:43 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/13/2020   Anup Kage (anup@cloudfastener.com)     Initial Version
**/
public without sharing class TotangoPgiEntityController {
	public class TotangoPgiEntityControllerException extends Exception {}
	public TotangoPgiEntityController(Set<String> companyIds) {
		pgiCompanyIdSet = companyIds;
	}
	public TotangoPgiEntityController(Set<String> companyIds, Set<String> pgiEntityIds) {
		pgiEntityIdSet = pgiEntityIds;
	}
	public Map<Id, Opportunity> opportunitiesById = new Map<Id, Opportunity>(); 
	public Map<Id, PGI_Company__c> companyById = new Map<Id, PGi_Company__c>();
	public Map<Id, PGi_Company__c> initializedCompanyValues = new Map<Id, PGi_Company__c>();
	public Map<Id, Financial_Request__c> finReqById = new Map<Id, Financial_Request__c>(); 
	public Map<Id, Case> caseById = new Map<Id, Case>();
	public Set<String> pgiCompanyIdSet = new Set<String>();
	public Set<String> pgiEntityIdSet = new Set<String>();

	public 	Boolean isCompanyQuery = true;
	public  Boolean isOpportunityQuery = false;
	public  Boolean isFinReqQuery = false;
	public  Boolean isCaseQuery = false;
	public  Boolean hasCompanyRecords = true;
	public Boolean reprocessCompanyDML = false;
	public Boolean reprocessEntityDML = false;
	public List<SObject> recordsToUpdate = new List<SObject>();
	/**
	* @description : Method to Insert Case, Opportunity and FinReq Details on PGI Company
	* @return void 
	**/
	private Integer dmlLimit {get {
		return (Limits.getLimitDmlRows() - Limits.getDmlRows() - 6000);
	} set;}
	public integer retryCount = 0;
	private Integer lastCompanyIndex = 0; 
	private Integer lastEntityIndex = 0;
	public void aggregateToPgiCompany(){
		recordsToUpdate = new List<SObject>();
		if(!opportunitiesById.isEmpty()){
			aggregateOpportunities();       
		}
		if(!finReqById.isEmpty()){
			aggregateFinanceRequests();
		}
		if(!caseById.isEmpty()){
			aggregateCases();
		}
		companyById.remove(null);
		if(companyById.size() > dmlLimit || reprocessCompanyDML) {
			List<PGi_Company__c> companyList = companyById.values();
			for(Integer i = lastCompanyIndex; i < companyById.size() && i < dmlLimit; i++ ) {
				recordsToUpdate.add(companyList[i]);
			}
			try {
				List<PGi_Company__c> toUpdate = [SELECT Id FROM PGi_Company__c WHERE Id IN: recordsToUpdate FOR UPDATE];
				update recordsToUpdate;
				lastCompanyIndex += dmlLimit;
				if(lastCompanyIndex < companyById.size()) {
					reprocessCompanyDML = true;
				} else {
					reprocessCompanyDML = false;
				}
			} catch (exception e) {
				if(retryCount < 10) {
					retryCount ++;
					reprocessCompanyDML = true;
				} else {
					throw new TotangoPgiEntityControllerException('Max retry reached' + e.getMessage() + e.getLineNumber());
				}
			}
			
			
		} else {
			try {
				List<PGi_Company__c> toUpdate = [SELECT Id FROM PGi_Company__c WHERE Id IN: companyById.keySet() FOR UPDATE];
				update companyById.values();
				reprocessCompanyDML = false;
			} catch (exception e) {
				if(retryCount < 10) {
					retryCount ++;
					reprocessCompanyDML = true;
				} else {
					throw new TotangoPgiEntityControllerException('Max retry reached' + e.getMessage() + e.getLineNumber());
				}
			}
		}
	}

	/**
	* @description : Calculating the aggregate values of Opportunity
	* @author Anup Kage (anup@cloudfastener.com) | 3/13/2020 
	* @param companyById 
	* @return Map<Id, PGi_Company__c> 
	**/
	public Map<Id, PGi_Company__c> aggregateOpportunities(){

		Date today = Date.today();
		for(Opportunity oppResult : opportunitiesById.values()){
			if(String.isBlank(oppResult.PGICompany__c)){
				continue;
			}
			if(!initializedCompanyValues.containsKey(oppResult.PGiCompany__c)){
				initializeCompanyValues(oppResult.PGiCompany__c);
			}

			PGi_Company__c pgiCompany = companyById.get(oppResult.PGiCompany__c);
			Date nextRenewalDate = pgiCompany.Next_Renewal_Date__c;
			String nextRenewalStage = pgiCompany.Next_Renewal_Deal_s_Stage__c;
			if(oppResult.isClosed && oppResult.isWon){
				pgiCompany.TCV_of_all_Closed_Won_Deals__c += oppResult.Amount__c;
			}else if(oppResult.isClosed && !oppResult.isWon){
				pgiCompany.TCV_of_all_Closed_Lost_Deals__c += oppResult.Amount__c;
			}else{
				pgiCompany.Count_of_Open_Opportunities__c += 1;
				if(oppResult.Amount__c != null){
					pgiCompany.Open_Opportunities_TCV__c += oppResult.Amount__c;
				}
				if(oppResult.Total_NRR_Formula__c != null){
					pgiCompany.Open_Opportunities_NRR__c += oppResult.Total_NRR_Formula__c;
				}
				if(oppResult.Total_MRR_Formula__c != null){
					pgiCompany.Open_Opportunities_MRR__c += oppResult.Total_MRR_Formula__c;
				}
				if(oppResult.Total_Annual_Value__c != null){
					pgiCompany.Open_Opportunities_ACV__c += oppResult.Total_Annual_Value__c;
				}
			}
			if(oppResult.Renewal_Contract_Date__c != null && oppResult.Renewal_Contract_Date__c > today){
				if(nextRenewalDate == null || (nextRenewalDate > oppResult.Renewal_Contract_Date__c)){
					pgiCompany.Next_Renewal_Date__c = oppResult.Renewal_Contract_Date__c;
					pgiCompany.Next_Renewal_Deal_s_Stage__c = oppResult.StageName;
				}
			}	
			pgiCompany.Next_Renewal_Date__c = nextRenewalDate;
			pgiCompany.Next_Renewal_Deal_s_Stage__c = nextRenewalStage;
			companyById.put(pgiCompany.Id, pgiCompany);
		}
		return companyById;
}
	/**
	* @description : Calculating the aggregate values of FinReq
	* @author Anup Kage (anup@cloudfastener.com) | 3/13/2020 
	* @param companyById 
	* @return MAp<Id, PGi_Company__c> 
	**/
	private Map<Id, PGi_Company__c> aggregateFinanceRequests(){
			Id recordTypeId =  Schema.SObjectType.Financial_Request__c.getRecordTypeInfosByName().get('PGi-Company Cancellation Request').getRecordTypeId();
			// Date recentCreatedDate = Date.today();
			Map<Id, Datetime> recentCreatedDateByCompanyId = new Map<Id,Datetime>();
			for(Financial_Request__c finReqResult : finReqById.Values()){
			// System.debug('finReqResult==>'+finReqResult.PGi_Company__c);
				if(String.isBlank(finReqResult.PGi_Company__c)){
					continue;
				}
				if(!initializedCompanyValues.containsKey(finReqResult.PGi_Company__c)){
					PGi_Company__c pgiCompany = initializeCompanyValues(finReqResult.PGi_Company__c);
				}
				PGi_Company__c pgiCompany = companyById.get(finReqResult.PGi_Company__c);
				if(finReqResult.Status__c == 'Closed'){
					pgiCompany.Total_Closed_FinReq_Count__c += 1;
				}else{
					pgiCompany.Total_Open_FinReq_Count__c += 1;
				}

				pgiCompany.Total_FinReq_Count__c = pgiCompany.Total_Open_FinReq_Count__c + pgiCompany.Total_Closed_FinReq_Count__c;
				
				if(recordTypeId == finReqResult.RecordTypeId){
					if(finReqResult.DateofCancellationNotice__c != null){ 

						if(!recentCreatedDateByCompanyId.containsKey(finReqResult.PGi_Company__c) ){
							recentCreatedDateByCompanyId.put(finReqResult.PGi_Company__c, finReqResult.createdDate);
							pgiCompany.Cancellation_of_Services_Received__c = finReqResult.DateofCancellationNotice__c;
						}else if(recentCreatedDateByCompanyId.get(finReqResult.PGi_Company__c) > finReqResult.createdDate){
							recentCreatedDateByCompanyId.put(finReqResult.PGi_Company__c, finReqResult.createdDate);
							pgiCompany.Cancellation_of_Services_Received__c = finReqResult.DateofCancellationNotice__c;
						}

						// if(finReqResult.createdDate < today && recentCreatedDate >  finReqResult.createdDate){
						// 	recentCreatedDate = finReqResult.createdDate;
						// 	pgiCompany.Cancellation_of_Services_Received__c = finReqResult.DateofCancellationNotice__c;
						// }else{
						// 	pgiCompany.Next_Renewal_Date__c = oppResult.Renewal_Contract_Date__c;
						// }
						// // if(finReqResult.DateofCancellationNotice__c <= toDay){

						// // }
						// date today = date.today();
						// if(finReqResult.DateofCancellationNotice__c <= toDay){
						// 	if(pgiCompany.Cancellation_of_Services_Received__c == null){
						// 		pgiCompany.Cancellation_of_Services_Received__c = finReqResult.DateofCancellationNotice__c;
						// 	}else if(pgiCompany.Cancellation_of_Services_Received__c <= finReqResult.DateofCancellationNotice__c){
						// 		pgiCompany.Cancellation_of_Services_Received__c = finReqResult.DateofCancellationNotice__c;
						// 	}
						// }
					}
					if(finReqResult.ServicePlanType__c != null && finReqResult.createdDate ==  recentCreatedDateByCompanyId.get(finReqResult.PGi_Company__c)){
						pgiCompany.Cancellation_Service_Plan_Type__c = finReqResult.ServicePlanType__c;
					}
				}
				
				companyById.put(pgiCompany.Id, pgiCompany);
				
				
			}
			return companyById;
	}
	/**
	* @description : Calculating the aggregate values of Cases
	* @author Anup Kage (anup@cloudfastener.com) | 3/16/2020 
	* @param companyById 
	* @return MAp<Id, PGi_Company__c> 
	**/
	private Map<Id, PGi_Company__c> aggregateCases(){
		Map<Id, wrapAvrageCaseAge> daysByCompanyId = new Map<Id,wrapAvrageCaseAge>();
		for(Case caseObj : caseById.values()){
			if(String.isBlank(caseObj.PGi_Company__c)){
				continue;
			}
			if(!initializedCompanyValues.containsKey(caseObj.PGi_Company__c)){
				PGi_Company__c pgiCompany = initializeCompanyValues(caseObj.PGi_Company__c);
			}   
			PGi_Company__c pgiCompany = companyById.get(caseObj.PGi_Company__c);
			DateTime caseCreatedDateTime = caseObj.CreatedDate;
			DateTime caseClosedDateTime = caseObj.CreatedDate;
			Date caseCreatedDate = Date.newinstance(caseCreatedDateTime.year(), caseCreatedDateTime.month(), caseCreatedDateTime.day());
			Date caseClosedDate = Date.newinstance(caseClosedDateTime.year(), caseClosedDateTime.month(), caseClosedDateTime.day());
			if(caseObj.isClosed){
				pgiCompany.Total_Closed_Case_Count__c += 1;
			}else{
				pgiCompany.Total_Open_Case_Count__c += 1;
			}
			if(!caseObj.isClosed && (caseCreatedDate.daysBetween(Date.today()))<90){
				pgiCompany.Total_Cases_Open_in_Past_90_Days_from_c__c += 1;
			}
			// pgiCompany.Total_Open_Case_Count__c += pgiCompany.Total_Cases_Open_in_Past_90_Days_from_c__c;
			if(caseObj.Area_of_Focus__c == 'Client Education/Request' && (caseCreatedDate.daysBetween(Date.today())<90)){
			pgiCompany.Total_Cases_for_Customer_Education_in_Pa__c += 1;
			}
			pgiCompany.Total_Case_Count__c = pgiCompany.Total_Closed_Case_Count__c + pgiCompany.Total_Open_Case_Count__c;
			
			if(daysByCompanyId.containsKey(pgiCompany.Id)){
				wrapAvrageCaseAge obj = daysByCompanyId.get(pgiCompany.Id);
				obj.caseCount += 1;
				obj.totalDays += caseCreatedDate.daysBetween(caseClosedDate);
				daysByCompanyId.put(pgiCompany.Id, obj);
			}else{
				wrapAvrageCaseAge obj = new wrapAvrageCaseAge();
				obj.caseCount = 1;
				obj.totalDays = caseCreatedDate.daysBetween(caseClosedDate);
				daysByCompanyId.put(pgiCompany.Id, obj);
			}
				
			// if(pgiCompany.Id != null){
			// 	companyById.put(pgiCompany.Id, pgiCompany);
			// }
			companyById.put(pgiCompany.Id,pgiCompany);
			
		}
		// Updating Avarage age of Cases on PGI Company
		for(Id companyId : daysByCompanyId.keySet()){
			wrapAvrageCaseAge obj = daysByCompanyId.get(companyId);
			PGi_Company__c companyObj = companyById.get(companyId);
			companyObj.Average_Age_of_Open_Cases__c = obj.totalDays / obj.caseCount;
			companyById.put(companyId, companyObj);
		}
		return companyById;
	}
	/**
	* @description : Updating the aggreageted details on PGI Entity
	* @return void 
	**/
	private Map<Id, PGi_Entity__c> initializedPgiEntityMap = new Map<Id, PGi_Entity__c>();
	public void aggregateToPGIEntity(){
		recordsToUpdate = new List<SObject>();
		
		if(!opportunitiesById.isEmpty()){
			initializedPgiEntityMap = aggregateOpportunitiesToEntity();       
		}
		Set<Id> pgiEntityIdSet = new Set<Id>();
		Map<Id, wrapAvrageCaseAge> daysByEntityId = new Map<Id,wrapAvrageCaseAge>();

		for(PGi_Company__c pgiCompanyObj : companyById.values()){
				system.debug('=pgiCompanyObj===>'+pgiCompanyObj);
			if(String.isBlank(pgiCompanyObj.PGi_Entity__c)){
				continue;
			}
			if(!initializedPgiEntityMap.containsKey(pgiCompanyObj.PGi_Entity__c)){
				PGi_Entity__c pgiEntityObject = initializeEntityValues(pgiCompanyObj.PGi_Entity__c);
				
			}
			PGi_Entity__c pgiEntityObject = initializedPgiEntityMap.get(pgiCompanyObj.PGi_Entity__c);
			pgiEntityObject.CountOfCompanies__c ++;
			if(pgiCompanyObj.Inactive_Date__c == null){
				pgiEntityObject.Count_of_Active_Companies__c +=1;
			}
			if(pgiCompanyObj.Total_Case_Count__c != null){
				pgiEntityObject.Total_Case_Count__c += pgiCompanyObj.Total_Case_Count__c ;
			}
			if(pgiCompanyObj.Total_Cases_for_Customer_Education_in_Pa__c != null){
				pgiEntityObject.Total_Cases_for_Customer_Education_in_Pa__c += pgiCompanyObj.Total_Cases_for_Customer_Education_in_Pa__c ;
			}
			if(pgiCompanyObj.Total_Cases_Open_in_Past_90_Days_from_c__c != null){
				pgiEntityObject.Total_Cases_Open_in_Past_90_Days_from_c__c += pgiCompanyObj.Total_Cases_Open_in_Past_90_Days_from_c__c ;
			}
			if(pgiCompanyObj.Total_Closed_Case_Count__c != null){
				pgiEntityObject.Total_Closed_Case_Count__c += pgiCompanyObj.Total_Closed_Case_Count__c ;
			}
			if(pgiCompanyObj.Total_Closed_FinReq_Count__c != null){
				pgiEntityObject.Total_Closed_FinReq_Count__c += pgiCompanyObj.Total_Closed_FinReq_Count__c ;
			}
			if(pgiCompanyObj.Total_Open_Case_Count__c != null){
				pgiEntityObject.Total_Open_Case_Count__c += pgiCompanyObj.Total_Open_Case_Count__c ;
			}
			if(pgiCompanyObj.Total_Open_FinReq_Count__c != null){
				pgiEntityObject.Total_Open_FinReq_Count__c += pgiCompanyObj.Total_Open_FinReq_Count__c ;
			}
			if(pgiCompanyObj.Total_FinReq_Count__c != null){
				pgiEntityObject.Total_FinReq_Count__c += pgiCompanyObj.Total_FinReq_Count__c;
			}
			if(daysByEntityId.containsKey(pgiEntityObject.Id)){
				wrapAvrageCaseAge obj = daysByEntityId.get(pgiEntityObject.Id);
				obj.caseCount += 1;
				obj.totalDays += pgiEntityObject.Average_Age_of_Open_Cases__c;
				daysByEntityId.put(pgiEntityObject.Id, obj);
			}else{
				wrapAvrageCaseAge obj = new wrapAvrageCaseAge();
				obj.caseCount = 1;
				obj.totalDays = pgiEntityObject.Average_Age_of_Open_Cases__c;
				daysByEntityId.put(pgiEntityObject.Id, obj);
			}
			initializedPgiEntityMap.put(pgiEntityObject.Id, pgiEntityObject);
		}
			// Updating Avarage age of Cases on PGI Company
			for(Id entityId : daysByEntityId.keySet()){
				wrapAvrageCaseAge obj = daysByEntityId.get(entityId);
				PGi_Entity__c entityObj = initializedPgiEntityMap.get(entityId);
				entityObj.Average_Age_of_Open_Cases__c = obj.totalDays / obj.caseCount;
				initializedPgiEntityMap.put(entityId, entityObj);
			}

		if(initializedPgiEntityMap.size() > dmlLimit || reprocessEntityDML) {
			List<PGI_Entity__c> pgiEntityList = initializedPgiEntityMap.values();
			for(Integer i = lastEntityIndex; i < initializedPgiEntityMap.size() && i < dmlLimit; i++ ) {
				recordsToUpdate.add(pgiEntityList[i]);
			}
			//place db lock
			try {
				List<PGI_Entity__c> toUpdate = [SELECT Id FROM PGI_Entity__c WHERE Id IN: recordsToUpdate FOR UPDATE];
				update recordsToUpdate;
				lastEntityIndex += dmlLimit;
				if(lastEntityIndex < initializedPgiEntityMap.size()) {
					reprocessEntityDML = true;
				} else {
					reprocessEntityDML = false;
				}
			} catch (exception e) {
				if(retryCount < 10) {
					retryCount ++;
					reprocessEntityDML = true;
				} else {
					throw new TotangoPgiEntityControllerException('Max retry reached' + e.getMessage() + e.getLineNumber());
				}
			}
			
		} else {
			try {
				List<PGI_Entity__c> toUpdate = [SELECT Id FROM PGI_Entity__c WHERE Id IN: recordsToUpdate FOR UPDATE];
				update initializedPgiEntityMap.values();
				reprocessEntityDML = false;
			} catch (exception e) {
				if(retryCount < 10) {
					retryCount ++;
					reprocessEntityDML = true;
				} else {
					throw new TotangoPgiEntityControllerException('Max retry reached' + e.getMessage() + e.getLineNumber());
				}
			}
		}
	}
	private Map<Id,PGi_Entity__c> aggregateOpportunitiesToEntity(){
		for(Opportunity oppResult : opportunitiesById.values()){
			if(String.isBlank(oppResult.PGiEntity__c)){
				continue;
			}
			if(!initializedPgiEntityMap.containsKey(oppResult.PGiEntity__c)){
				PGi_Entity__c pgiEntityObject = initializeEntityValues(oppResult.PGiEntity__c);
			}

			PGi_Entity__c pgiEntityObject = initializedPgiEntityMap.get(oppResult.PGiEntity__c);
			if(oppResult.isClosed && oppResult.isWon && oppResult.Amount__c != null){
				pgiEntityObject.TCV_of_all_Closed_Won_Deals__c += oppResult.Amount__c;
			}else if(oppResult.isClosed && !oppResult.isWon && oppResult.Amount__c != null){ //closed lost
				pgiEntityObject.TCV_of_all_Closed_Lost_Deals__c += oppResult.Amount__c;
			}else{
				pgiEntityObject.Count_of_Open_Opportunities__c += 1;
				if(oppResult.Amount__c != null){
					pgiEntityObject.Open_Opportunities_TCV__c += oppResult.Amount__c;
				}
				if(oppResult.Total_NRR_Formula__c != null){
					pgiEntityObject.Open_Opportunities_NRR__c += oppResult.Total_NRR_Formula__c;
				}
				if(oppResult.Total_MRR_Formula__c != null){
					pgiEntityObject.Open_Opportunities_MRR__c += oppResult.Total_MRR_Formula__c;
				}
				if(oppResult.Total_Annual_Value__c != null){
					pgiEntityObject.Open_Opportunities_ACV__c += oppResult.Total_Annual_Value__c;
				}
			}
			if(oppResult.Renewal_Contract_Date__c != null){
				Date today = Date.today();
				if( pgiEntityObject.Next_Renewal_Date__c != null && oppResult.Renewal_Contract_Date__c >= today &&  pgiEntityObject.Next_Renewal_Date__c >  oppResult.Renewal_Contract_Date__c){
					pgiEntityObject.Next_Renewal_Date__c = oppResult.Renewal_Contract_Date__c;
					pgiEntityObject.Next_Renewal_Deal_s_Stage__c = oppResult.StageName;
				}else if(pgiEntityObject.Next_Renewal_Date__c == null && oppResult.Renewal_Contract_Date__c >= today){
					pgiEntityObject.Next_Renewal_Date__c = oppResult.Renewal_Contract_Date__c;
					pgiEntityObject.Next_Renewal_Deal_s_Stage__c = oppResult.StageName;
				}
			}
		}
		return initializedPgiEntityMap;
	}
	/**
	* @description : To initialize all values of PGi entity
	* @author Anup Kage (anup@cloudfastener.com) | 3/24/2020 
	* @param entityId 
	* @return PGI_Entity__c 
	**/
	private PGI_Entity__c initializeEntityValues(Id entityId){
		PGi_Entity__c pgiEntityObject = new PGi_Entity__c(Id = entityId,
															CountofCompanies__c = 0,
															TCV_of_all_Closed_Lost_Deals__c = 0,
															TCV_of_all_Closed_Won_Deals__c = 0,
															Count_of_Active_Companies__c = 0,
															Count_of_Open_Opportunities__c = 0,
															Open_Opportunities_TCV__c = 0,
															Open_Opportunities_ACV__c = 0,
															Open_Opportunities_MRR__c = 0,
															Open_Opportunities_NRR__c = 0,
															Total_Case_Count__c = 0,
															Total_Cases_for_Customer_Education_in_Pa__c = 0,
															Total_Cases_Open_and_Past_90_Days_from__c = 0,
															Total_Cases_Open_in_Past_90_Days_from_c__c = 0,
															Total_Closed_Case_Count__c = 0,
															Total_Closed_FinReq_Count__c = 0,
															Total_FinReq_Count__c = 0,
															Total_Open_Case_Count__c = 0,
															Average_Age_of_Open_Cases__c = 0,
															Total_Open_FinReq_Count__c = 0);
		initializedPgiEntityMap.put(pgiEntityObject.Id,pgiEntityObject);
		return pgiEntityObject;
	}
	/**
	* @description : To initialize all values of PGi Company
	* @author Anup Kage (anup@cloudfastener.com) | 3/24/2020 
	* @param companyId 
	* @return PGi_Company__c 
	**/
	private PGi_Company__c initializeCompanyValues(Id companyId){
		PGi_Company__c pgiCompany = companyById.get(companyId);
		if(pgiCompany == null) {
			pgiCompany = new PGi_Company__c(Id = companyId);
		}
		pgiCompany.Next_Renewal_Date__c = null;
		pgiCompany.Next_Renewal_Deal_s_Stage__c = '';
		pgiCompany.TCV_of_all_Closed_Won_Deals__c = 0;
		pgiCompany.TCV_of_all_Closed_Lost_Deals__c = 0;
		pgiCompany.Count_of_Open_Opportunities__c = 0; 
		pgiCompany.Open_Opportunities_TCV__c = 0; 
		pgiCompany.Open_Opportunities_NRR__c = 0;
		pgiCompany.Open_Opportunities_MRR__c = 0;
		pgiCompany.Open_Opportunities_ACV__c = 0;
		pgiCompany.Total_Closed_FinReq_Count__c = 0;
		pgiCompany.Total_Open_FinReq_Count__c = 0;
		pgiCompany.Total_FinReq_Count__c = 0;
		pgiCompany.Total_Cases_for_Customer_Education_in_Pa__c = 0;
		pgiCompany.Total_Cases_Open_in_Past_90_Days_from_c__c = 0;
		pgiCompany.Total_Open_Case_Count__c = 0;
		pgiCompany.Total_Closed_Case_Count__c = 0;
		pgiCompany.Average_Age_of_Open_Cases__c = 0;
		pgiCompany.Total_Case_Count__c = 0;
		companyById.put(companyId, pgiCompany);
		initializedCompanyValues.put(pgiCompany.Id, pgiCompany);
		return pgiCompany;
	}
    public class wrapAvrageCaseAge {
        public Double totalDays {get; set;}
        public Double caseCount {get; set;}
 
        //This is the contructor method. When we create a new wrapAccount object we pass a Account that is set to the acc property. We also set the selected value to false
        public wrapAvrageCaseAge() {
            totalDays = 0;
            caseCount = 0;
        }
    }  
    
}