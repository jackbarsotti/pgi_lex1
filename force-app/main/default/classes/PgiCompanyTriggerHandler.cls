public without sharing class PgiCompanyTriggerHandler extends TriggerHandler {
	public PgiCompanyTriggerHandler() {
		super('PgiCompanyTriggerHandler');
	}
	protected override void afterUpdate(){ 
		checkOpportunities();
		setAccountSalesTeam();
		//RT-92
		updatePGiContractfromPGiCompany();
		aggregate();
	}
	protected override void afterInsert(){ 
		checkOpportunities();
		setAccountSalesTeam();
		//RT-92
		updatePGiContractfromPGiCompany();
		aggregate();
	}
	/*protected override void afterDelete(){ 
	
	}
	protected override void beforeDelete() {
		
	}*/
	protected override void beforeUpdate() {
		matchOnEntityId();
		setAccounts();
		matchSalesRep();
		updateUltimateParentAccount();
		//RT-92
		populateRelatedAccountCorpCrust();
	}
	protected override void beforeInsert() {
		matchOnEntityId();
		setAccounts();
		matchSalesRep();
		updateUltimateParentAccount();
		//RT-92
		populateRelatedAccountCorpCrust();
	}
	// Set PGi_Company__c.Ultimate_Parent_Account__c
	// PGi_Company__c.Related_Ultimate_Parent_Account__c
	// PGi_Company__c.Related_Account_Name__c
	private void updateUltimateParentAccount() {
		for(PGi_Company__c pgiCompany : (List<PGi_Company__c>)Trigger.new) {
			if(pgiCompany.Ultimate_Parent_Account__c != pgiCompany.Related_Ultimate_Parent_Account__c && pgiCompany.RelatedAccount__c != null && !pgiCompany.Related_Account_Name__c.contains('unmatch')) {
				pgiCompany.Ultimate_Parent_Account__c = pgiCompany.Related_Ultimate_Parent_Account__c;
			}
		}
	}
	private void aggregate() {
		if(Trigger_Settings__c.getInstance().Bypass_Totango__c) { return; }
		List<Aggregate_Calculation_Event__e> listOfagregateEvents = new List<Aggregate_Calculation_Event__e>();
		for(PGI_Company__c comp :(List<PGI_Company__c>)Trigger.new){
            if(comp.Id != null || comp.PGI_Entity__c != null){
                Aggregate_Calculation_Event__e obj = new Aggregate_Calculation_Event__e() ;   
                obj.PGI_Company_Id__c   = comp.Id;
                obj.PGI_Entity__c       = comp.PGI_Entity__c;
                listOfagregateEvents.add(obj);
            }
		}
		if(!listOfagregateEvents.isEmpty()){
            List<Database.SaveResult> results = EventBus.publish(listOfagregateEvents);
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                   //
                }
                
            }
        }
	}

	/* COD-1244
			NOTE:
			*When a PGi Company record is first created (and SF Opportunity ID is not blank) ...OR...

			When a PGi Company record is edited (and the SF Opportunity ID is changed)
			Then fire a trigger to look against all Opportunity records
			Where the field value of "SF Opportunity ID" from the PGi Company record is an EXACT MATCH OR CONTAINS VALUE to the field "Opportunity Number" from the Opportunity object
			**Note: if no match is found then do nothing, if multiple matches are found do nothing
			
			If a single match is found, then look to see if the Opportunity record has a single PGi Contract
			**Note: if the Opportunity record has no PGi Contract or multiple PGi Contracts then do nothing
			If a single PGi Contract record exists, then update that PGi Contract record, you will update the "PGi Company" lookup field with the Company ID that originated the trigger to begin with */ 
	private void checkOpportunities() {
		Map<Id, CONMAN_Contract__c> contractsToUpdate = new Map<Id, CONMAN_Contract__c>();
		for(PGI_Company__c comp:  (List<PGi_Company__c>)Trigger.new) {
			if(String.isNotBlank(comp.SF_Opportunity_ID__c) && isChanged('SF_Opportunity_ID__c', comp)) {
				Opportunity relatedOpportunity = relatedOpportunitiesByNumber.get(comp.SF_Opportunity_ID__c);
                
               
				if(relatedOpportunity != null && relatedOpportunity.CONMAN_Contracts__r != null && relatedOpportunity.CONMAN_Contracts__r.size() == 1) {
					if(relatedContracts.get(relatedOpportunity.CONMAN_Contracts__r[0].Id) != null && 
					String.isBlank(relatedContracts.get(relatedOpportunity.CONMAN_Contracts__r[0].Id).PGiCompany__c)) { // skip record if already associated company
						if(relatedOpportunity.CONMAN_Contracts__r[0].PGiCompany__c != comp.Id) {
							CONMAN_Contract__c cc = new CONMAN_Contract__c(Id = relatedOpportunity.CONMAN_Contracts__r[0].Id, PGiCompany__c = comp.Id);
							contractsToUpdate.put(cc.Id, cc);
						}
					}
				}
			}
		}
		if(contractsToUpdate.size() > 0) {
			database.update(new List<CONMAN_Contract__c>(contractsToUpdate.values()), false);
		}
	}
	private Map<Id, CONMAN_Contract__c> relatedContracts { get { 
		if(relatedContracts == null) {
			Set<Id> contractSet = new Set<Id>(); 
			for(Opportunity opp: relatedOpportunitiesByNumber.values()) {
				if(opp.CONMAN_Contracts__r != null && opp.CONMAN_Contracts__r.size() > 0){
					contractSet.add(opp.CONMAN_Contracts__r[0].Id);	
				}
			}
			relatedContracts = new Map<Id, CONMAN_Contract__c>([SELECT Id, PGiCompany__c FROM CONMAN_Contract__c WHERE Id IN: contractSet]);
		}
		return relatedContracts;
	} set;}
	private Map<String, Opportunity> relatedOpportunitiesByNumber {	get {
		if(relatedOpportunitiesByNumber == null) {
			Set<String> oppNumbers = new Set<String>();
			for(PGi_Company__c comp: (List<PGi_Company__c>)Trigger.new) {
				if(String.isNotBlank(comp.SF_Opportunity_ID__c)) {
					oppNumbers.add(comp.SF_Opportunity_ID__c);
				}
			}
			relatedOpportunitiesByNumber = new Map<String, Opportunity>();
            
			for(Opportunity o: [SELECT Id, Opportunity_Number__c, (SELECT Id, PGiCompany__c FROM CONMAN_Contracts__r) FROM Opportunity WHERE Opportunity_Number__c IN: oppNumbers]) {
				relatedOpportunitiesByNumber.put(o.Opportunity_Number__c, o);
			}
		}
		return relatedOpportunitiesByNumber;
	} set; }
	//regional accounts for parent shells
	private static Map<Id, Account> regionalAccounts {get {
		if(regionalAccounts == null) {
			Set<Id> regionSet = new Set<Id>{'001300000106U1c', '001300000106U2C', '001300000106U2G'};
			regionalAccounts = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN: regionSet]);
		}
		return regionalAccounts;
	} set;}
	private static Map<String, Account> relatedTeslaAccounts {get {
		if(relatedTeslaAccounts == null) {
			relatedTeslaAccounts = new Map<String, Account>();
			Set<String> sfAccts = new Set<String>();
			for(PGI_Company__c comp: (List<PGI_Company__c>)Trigger.new) {
				if(!String.isBlank(comp.SF_Account_ID__c)) {
					sfAccts.add(comp.SF_Account_ID__c);	
				}
			}
			for(Account a: [SELECT Id, Sfdc_account_id__c FROM Account WHERE sfdc_account_id__c IN: sfAccts]) {
				relatedTeslaAccounts.put(a.Sfdc_Account_id__c, a);
			}
		}
		return relatedTeslaAccounts;
	} set;} 

	private void setAccounts() {
		for(PGI_Company__c comp: (List<PGI_Company__c>)Trigger.new){
			if(comp.SF_Account_ID__c != null && relatedTeslaAccounts.get(comp.SF_Account_ID__c) != null) {
				comp.RelatedAccount__c = relatedTeslaAccounts.get(comp.SF_Account_ID__c).Id;
			} else if(comp.SF_Account_ID__c == null && comp.Region__c <> NULL) {
				if(regionalAccounts.size() == 3) {
			        if(comp.Region__c == 'USA') {
			            comp.RelatedAccount__c = '001300000106U1c' ;
			        } else if(comp.Region__c == 'EMEA') {
			            comp.RelatedAccount__c = '001300000106U2C';
			        } else if(comp.Region__c == 'AP') {
			            comp.RelatedAccount__c = '001300000106U2G' ;      
			        }
			    }
		    }
		}
	}
	private Map<String, User> relatedUsers {get {
		if(relatedUsers == null) {
			relatedUsers = new Map<String, User>();
			Set<String> emailAddresses = new Set<String>();
			for(PGI_Company__c comp: (List<PGI_Company__c>)Trigger.new) {
				if(!String.isBlank(comp.Sales_Rep_s_Email__c)) {
					emailAddresses.add(comp.Sales_Rep_s_Email__c);
				}
			}
            
			for(User u: [SELECT Id, Email FROM User WHERE Email IN:emailAddresses AND IsActive = true]) {
                relatedUsers.put(u.Email, u);
			}
		}
		return relatedUsers;
	} set;}
	private void matchSalesRep() {
		for(PGI_Company__c comp: (List<PGI_Company__c>)Trigger.new) {
			if(!String.isBlank(comp.Sales_Rep_s_Email__c) && relatedUsers.get(comp.Sales_Rep_s_Email__c) != null) {
				comp.PrimarySalesRep__c = relatedUsers.get(comp.Sales_Rep_s_Email__c).Id;
			}
		}
	}
	//set up account shares and account team membership
	private void setAccountSalesTeam() {
		List<AccountTeamMember> accntmember = new List<AccountTeamMember>();
		List<AccountShare> accntShare = new List<AccountShare>();
		for(PGI_Company__c comp: (List<PGI_Company__c>)Trigger.new) {
			//TODO - query acct
			if(comp.PrimarySalesRep__c != null && 
				relatedAccount.get(comp.RelatedAccount__c) != null && 
				relatedAccount.get(comp.RelatedAccount__c).OwnerId <> comp.PrimarySalesRep__c) {
				List<AccountTeamMember> relatedTeamMembers = acctTeamMembersByAccount.get(comp.RelatedAccount__c);
				Set<Id> teamMemberIds = new Set<Id>();
				if(relatedTeamMembers != null && relatedTeamMembers.size() > 0) {
					for(AccountTeamMember atm: relatedTeamMembers) {
						teamMemberIds.add(atm.UserId);
					}
				}
				if ((relatedTeamMembers == null || !relatedTeamMembers.isEmpty() || !acctTeamMembersByAccount.containsKey(comp.RelatedAccount__c))
					&& !teamMemberIds.contains(comp.PrimarySalesRep__c) && relatedUsers.get(comp.Sales_Rep_s_Email__c) != null &&  relatedUsers.get(comp.Sales_Rep_s_Email__c).Id == comp.PrimarySalesRep__c) {
						accntmember.add(new AccountTeamMember(
	                                        accountid=comp.RelatedAccount__c,
	                                        userid = comp.PrimarySalesRep__c,
	                                        TeamMemberRole = 'Sales Rep'));
	                    accntshare.add(new AccountShare(
	                                        accountid=comp.RelatedAccount__c,
	                                        UserOrGroupId = comp.PrimarySalesRep__c,
	                                        AccountAccessLevel = 'Edit',
	                                        OpportunityAccessLevel = 'Edit',
	                                        CaseAccessLevel = 'Edit',
	                                        ContactAccessLevel = 'Edit'));
	            }
            }
        }
		insert accntmember;
		insert accntshare;
	}
	//map of accounts related to the PGI_Company__c.RelatedAccount__c
	private Map<Id, Account> relatedAccount {get { 
		if(relatedAccount == null) {
			relatedAccount = new Map<Id, Account>([SELECT Id, OwnerId FROM Account WHERE Id IN: companyAccts]);
		}
		return relatedAccount;
	}set;}

	private Set<Id> companyAccts {get {
		if(companyAccts == null) {
			companyAccts = new Set<Id>();
			for(PGI_Company__c comp: (List<PGI_Company__c>)Trigger.new) {
				if(comp.RelatedAccount__c != null) {
					companyAccts.add(comp.RelatedAccount__c);
				}
			}
		}
		return companyAccts;
	} set;}
	//Map that returns a list of account team members by the account id
	private Map<Id, List<AccountTeamMember>> acctTeamMembersByAccount {get {
		if(acctTeamMembersByAccount == null) {
			acctTeamMembersByAccount = new Map<Id, List<AccountTeamMember>>();
			List<AccountTeamMember> acctTeamMembers = new List<AccountTeamMember>();
			Set<Id> userIds = new Set<Id>();
			for(PGI_Company__c comp: (List<PGI_Company__c>)Trigger.new) {
				if(comp.PrimarySalesRep__c != null) {
					userIds.add(comp.PrimarySalesRep__c);
					userIds.add(comp.OwnerId);
				}
			}
			//SYstem.debug('companyAccts: '+companyAccts+ '  ::userIds:: '+userIds);
            //SYstem.debug('AccountTeamMember:: '+[SELECT Id, UserId, AccountId FROM AccountTeamMember]);
			acctTeamMembers = [SELECT Id, UserId, AccountId FROM AccountTeamMember WHERE AccountId IN: companyAccts AND UserId IN: userIds];
             SYstem.debug('acctTeamMembers------------->>>>.: '+acctTeamMembers);
           //SYstem.debug('UserUIdsI: '+[SELECT Id FROM AccountTeamMember WHERE UserId IN: userIds]);
			for(AccountTeamMember atm: acctTeamMembers) {
                sYSTEM.debug('^^^^^^^^^^^6^^^^^^^^^'+atM.AccountId);
				List<AccountTeamMember> acctTeam = new List<AccountTeamMember>();
				if(acctTeamMembersByAccount.get(atm.AccountId) != null) {
					acctTeam = acctTeamMembersByAccount.get(atm.AccountId);
				}
				acctTeam.add(atm);
				acctTeamMembersByAccount.put(atm.AccountId, acctTeam);
			}
		}	
		return acctTeamMembersByAccount;
	} set;}
	private void matchOnEntityId() {
		for(PGi_Company__c company: (List<PGi_Company__c>)Trigger.new){
			if(String.isNotBlank(company.PGi_Entity_ID__c)) {
				if(relatedEntityByEntityName.get(company.PGi_Entity_ID__c) != null) {
					if(relatedEntityByEntityName.get(company.PGi_Entity_ID__c).size() == 1){
						//one match
						company.PGI_Entity__c = relatedEntityByEntityName.get(company.PGi_Entity_ID__c)[0].Id;
					} else {
						//multiple matches
					}
					
				} else {
					//no match
				}
			}
		}
	}

	private Map<String, List<PGI_Entity__c>> relatedEntityByEntityName {
		get {
			if(relatedEntityByEntityName == null) {
				relatedEntityByEntityName = new Map<String, List<PGI_Entity__c>>();
				for(PGI_Entity__c entity: [SELECT Id, Name FROM PGI_Entity__c WHERE Name IN: entityNameSet]) {
                    
					List<PGI_Entity__c> entitiesForName = new List<PGI_Entity__c>();
                    System.debug('relatedEntityByEntityName'+relatedEntityByEntityName);
					if(relatedEntityByEntityName.get(entity.Name) != null) {
						entitiesForName = relatedEntityByEntityName.get(entity.Name);
					}
					entitiesForName.add(entity);
					relatedEntityByEntityName.put(entity.Name, entitiesForName);
				}
			}
			return relatedEntityByEntityName;
	} set;}
	
	private Set<String> entityNameSet {get{	
		entityNameSet = new Set<String>();
		for(PGi_Company__c company: (List<PGi_Company__c>)Trigger.new){
			if(String.isNotBlank(company.PGi_Entity_ID__c)) {
				entityNameSet.add(company.PGi_Entity_ID__c);
			}
		}
		return entityNameSet;
	}set;}

	//Added as part of RT-92
	private void populateRelatedAccountCorpCrust(){

		Set<Id> accountIds = new Set<Id>();
		Map<String,Id> sfdcAcountIdMap = new Map<String,Id>();
		Set<String> queryFilter = new Set<String>();
		for(PGi_Company__c pgiCompany : (List<PGI_Company__c>)Trigger.new){
			queryFilter.add(pgiCompany.CorpCustSFAccountID__c);
			queryFilter.add(pgiCompany.SF_Account_ID__c);
		}
		queryFilter.remove(null);
		for(Account account : [SELECT Id, Name, SFDC_Account_ID__c
								FROM Account WHERE ID IN: queryFilter]){
			accountIds.add(account.Id);
			if(!String.isBlank(account.SFDC_Account_ID__c)) {
				sfdcAcountIdMap.put(account.SFDC_Account_ID__c, account.Id);
			}

		}

		for(PGi_Company__c pgiCompany : (List<PGI_Company__c>) Trigger.new){
			if(!String.isBlank(pgiCompany.CorpCustSFAccountID__c) && pgiCompany.CorpCustSFAccountID__c.startsWith('001') && accountIds.contains(pgiCompany.CorpCustSFAccountID__c)) {
				pgiCompany.RelatedAccount__c = pgiCompany.CorpCustSFAccountID__c; 
			}else if(!String.isBlank(pgiCompany.SF_Account_ID__c) && sfdcAcountIdMap.containsKey(pgiCompany.SF_Account_ID__c) && String.isBlank(pgiCompany.CorpCustSFAccountID__c)){
				pgiCompany.RelatedAccount__c = sfdcAcountIdMap.get(pgiCompany.SF_Account_ID__c);
			}

		}

	}

	//Added as part of RT-92
	private Map<Id, Opportunity> relatedOpportunitiesByDirectSFOpportId {	get {
		if(relatedOpportunitiesByDirectSFOpportId == null) {
			Set<String> oppIds = new Set<String>();
			for(PGi_Company__c comp: (List<PGi_Company__c>)Trigger.new) {
				if(String.isNotBlank(comp.DirectSFOpptyID__c)) {
					oppIds.add(comp.DirectSFOpptyID__c);
				}
			}
			relatedOpportunitiesByDirectSFOpportId = new Map<Id, Opportunity>();
            
			for(Opportunity o: [SELECT Id, (SELECT Id, PGiCompany__c FROM CONMAN_Contracts__r) FROM Opportunity WHERE Id IN: oppIds]) {
				relatedOpportunitiesByDirectSFOpportId.put(o.Id, o);
			}
		}
		return relatedOpportunitiesByDirectSFOpportId;
	} set; }

	//Added as part of RT-92
	private void updatePGiContractfromPGiCompany() {

		List<CONMAN_Contract__c> pgiContractList;
		Map<String,Opportunity> numbertoOpportunityMap = relatedOpportunitiesByNumber;
		Map<Id,Opportunity> idtoOpportunityMap = relatedOpportunitiesByDirectSFOpportId;
        System.debug('idtoOpportunityMapidssssss'+idtoOpportunityMap);
        System.debug('idtoOpportunityMapstring'+numbertoOpportunityMap);        
		Map<Id, CONMAN_Contract__c> pgiContractUpdateMap = new Map<Id, CONMAN_Contract__c>();
		for(PGi_Company__c pgiCompany : (List<PGI_Company__c>) Trigger.new){

			if(!String.isBlank(pgiCompany.DirectSFOpptyID__c) && pgiCompany.DirectSFOpptyID__c.startsWith('006')){
                System.debug('pgiCompany.DirectSFOpptyID__c'+pgiCompany.DirectSFOpptyID__c);
                System.debug('pgiCompany.DirectSFOpptyID__c-----'+pgiCompany.DirectSFOpptyID__c.startsWith('006'));
				pgiContractList = new List<CONMAN_Contract__c>( (Set<CONMAN_Contract__c>)JSON.deserialize(JSON.serialize(idtoOpportunityMap.get(pgiCompany.DirectSFOpptyID__c).CONMAN_Contracts__r), Set<CONMAN_Contract__c>.class) );
				System.debug('pgiContractList'+pgiContractList);
                if(pgiContractList.size() == 1){
						pgiContractList[0].PGiCompany__c = pgiCompany.Id;
						pgiContractUpdateMap.put(pgiContractList[0].Id, pgiContractList[0]);

				}
			}else if(!String.isBlank(pgiCompany.SF_Opportunity_ID__c) && numbertoOpportunityMap.containsKey(pgiCompany.SF_Opportunity_ID__c)){
						pgiContractList = new List<CONMAN_Contract__c>( (Set<CONMAN_Contract__c>)JSON.deserialize(JSON.serialize(numbertoOpportunityMap.get(pgiCompany.SF_Opportunity_ID__c).CONMAN_Contracts__r), Set<CONMAN_Contract__c>.class) );
						if(pgiContractList.size() == 1){
							pgiContractList[0].PGiCompany__c = pgiCompany.Id;
							pgiContractUpdateMap.put(pgiContractList[0].Id, pgiContractList[0]);
						}
						
			}
		}

		if(!pgiContractUpdateMap.isEmpty())
		UPDATE pgiContractUpdateMap.values();
	}
}