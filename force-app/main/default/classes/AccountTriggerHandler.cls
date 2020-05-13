public class AccountTriggerHandler extends TriggerHandler {
	public AccountTriggerHandler() {
		this.newList = (List<Account>)Trigger.new; 
		this.newMap = (Map<Id,Account>)Trigger.newMap;
		this.oldList = (List<Account>)Trigger.old; 
		this.oldMap = (Map<Id,Account>)Trigger.oldMap;
	}
	private List<Account> newList;
	private Map<Id,Account> newMap;
	private List<Account> oldList;
	private Map<Id,Account> oldMap;
	@TestVisible private static Map<Id, Schema.RecordTypeInfo> accountRtMap = Account.sObjectType.getDescribe().getRecordTypeInfosById();
	public static Id PGIRecordTypeId {get{
		if(PGIRecordTypeId == null) { 
			for(Schema.RecordTypeInfo rt : AccountTriggerHandler.accountRtMap.values()) {
				if(rt.getName() == 'PGi Account') {
					PGIRecordTypeId = rt.getRecordTypeId();
				}
			}
		}
		return PGIRecordTypeId;
	} set;}
	protected override void beforeUpdate() {
		checkUltimateParent();
		mapZoomCountries();
		setGlobalAccountMQAAssignDate();
	}
	protected override void beforeInsert() {
		checkUltimateParent();
		mapZoomCountries();
        setGlobalAccountMQAAssignDate();
	}
    protected override void afterInsert(){
    //    setConvertedMQAFieldOnOpportunity();
	}
	protected override void afterUpdate(){
    //    setConvertedMQAFieldOnOpportunity();
	}
	// map zoom country to standard country
	private void mapZoomCountries() {
		for(Account account : (List<Account>)Trigger.new) {
			if(CountryUtil.ZOOM_COUNTRY_MAP.get(account.ZoomInfo_Country__c) != null && String.isBlank(account.BillingCountry)) {
				account.BillingCountry = CountryUtil.ZOOM_COUNTRY_MAP.get(account.ZoomInfo_Country__c);	
			}
		}
	}
	//method to set the parent form the ultimate parent DUNS
	@TestVisible private static Set<Id> parentsChecked = new Set<Id>();
	private void checkUltimateParent() {
		Set<String> accountDunsToSetParent = new Set<String>(); 
		for(Account a : newList) {
			if(needsDunsParent(a)) {
				accountDunsToSetParent.add(a.Duns_Number__c);
			}
		}
		if(accountDunsToSetParent.isEmpty()) { return; }

		//query to get ultimate duns from account
		List<Account> accountsWithDandB = [SELECT Id, DandbCompany.GlobalUltimateDunsNumber, Potiential_Duplicate_via_DUNS__c, DuplicateDetectedforParentLookup__c, ParentId, Duns_Number__c 
										   	FROM Account 
										   WHERE DandbCompanyid <> null 
										   	AND DandbCompany.DUNSNumber IN :accountDunsToSetParent 
										   	AND RecordTypeId = :PGIRecordTypeId
									 	   	AND Owners_Channel_Formula__c != 'Partners' 
								   			AND Owners_Channel_Formula__c != 'Carrier'];
		Set<String> ultimateDunsSet = new Set<String>(); 
		Map<String,Integer> countByDunsNumber = new Map<String,Integer>();
		for(Account a: accountsWithDandB) {
			if(!String.isBlank(a.DandbCompany.GlobalUltimateDunsNumber)) {
				ultimateDunsSet.add(a.DandbCompany.GlobalUltimateDunsNumber);
			}
			Integer count = countByDunsNumber.get(a.Duns_Number__c) == null ? 1 : countByDunsNumber.get(a.Duns_Number__c) + 1;
			countByDunsNumber.put(a.Duns_Number__c, count);
		}
		if(ultimateDunsSet.isEmpty()) { return; }

		//query the accounts associated to the ultimate duns and populate map
		Map<String,List<Account>> accountListByUltimateDuns = new Map<String,List<Account>>();
		for(Account ultimateAccount : [SELECT Id, DandbCompany.DUNSNumber, Potiential_Duplicate_via_DUNS__c, DuplicateDetectedforParentLookup__c
									   FROM Account 
									   WHERE DandbCompany.DUNSNumber IN :ultimateDunsSet 
									   AND RecordTypeId = :PGIRecordTypeId 
									   AND Owners_Channel_Formula__c != 'Partners' 
									   AND Owners_Channel_Formula__c != 'Carrier']) {
			List<Account> accountList = new List<Account>();
			if(accountListByUltimateDuns.get(ultimateAccount.DandbCompany.DUNSNumber) != null) {
				accountList = accountListByUltimateDuns.get(ultimateAccount.DandbCompany.DUNSNumber);
			}
			accountList.add(ultimateAccount);
			accountListByUltimateDuns.put(ultimateAccount.DandbCompany.DUNSNumber, accountList);
		}
		
		//associate or flag parents to accounts
		for(Account a : accountsWithDandB) {
			Account newAcct = newMap.get(a.Id);
			if(newAcct == null) { continue; }
			String ultimateDuns = a.DandbCompany.GlobalUltimateDunsNumber;
			if(accountListByUltimateDuns.get(ultimateDuns) != null){
				if(accountListByUltimateDuns.get(ultimateDuns).size() > 1) { //flag for parent dupe
					newAcct.DuplicateDetectedforParentLookup__c = true;
				} 
				else if(accountListByUltimateDuns.get(ultimateDuns).size() == 1) {
					newAcct.DuplicateDetectedforParentLookup__c = false;
					Account parentAccount = accountListByUltimateDuns.get(ultimateDuns)[0];
					if(parentAccount.Id != newAcct.Id) { 
						newAcct.ParentId = parentAccount.Id;
					}
				}
				if(countByDunsNumber.get(newAcct.DUNS_Number__c) > 1) {
					newAcct.Potiential_Duplicate_via_DUNS__c = true;
				} 
				else {
					newAcct.Potiential_Duplicate_via_DUNS__c = false;
				}
			}
		}
	}
	private Boolean needsDunsParent(Account a){
		if(!parentsChecked.contains(a.ID)) {
			if(a.ParentId == null) {
				if(a.DandbCompanyId != null) {
					if(a.Owners_Channel_Formula__c <> 'Partners' && a.Owners_Channel_Formula__c <> 'Carrier') {
						if(!String.isBlank(a.Duns_Number__c)) {
							if(accountRtMap.get(a.RecordTypeId).getName().containsIgnoreCase('pgi')){
								parentsChecked.add(a.Id);
								return true;			
							}

						}
					}
				}
			}
		}
		return false;
	}

  	private void setGlobalAccountMQAAssignDate(){
    //    for(Account a:(List<Account>)Trigger.new){
	// 	if(Trigger.isInsert) {
	// 		a.Global_Account_MQA__c = true;
	// 		a.Global_Account_MQA_Assignment_date__c = System.today();
	// 	}
	// 	else {
	// 		if(a.Global_Account_MQA__c == true && isChanged('Global_Account_MQA__c',a)){
	// 			  a.Global_Account_MQA_Assignment_date__c = System.today();
	// 		   }
	// 		   else if(a.Global_Account_MQA__c==false){
	// 			 a.Global_Account_MQA_Assignment_date__c=null;
	// 		   }
	// 	}
		   
	//    }
	} 
   
 /*   private void setConvertedMQAFieldOnOpportunity(){
        set<Id> accountIdSet=new set<Id>();
        List<Opportunity> updateOpptyList=new  List<Opportunity>();
        
         for(Account a:(List<Account>)Trigger.new){
             System.debug('Hello');
                 accountIdSet.add(a.Id);
         }
        
          Map<Id,List<Opportunity>> accountTOppMap = new Map<Id,List<Opportunity>>();
         for(Opportunity oppObj : [SELECT Id, Name, AccountId, CreatedDate,CloseDate,Converted_from_MQL__c
                                                                     FROM Opportunity 
                                                                     WHERE AccountId =:accountIdSet] ){
               if (accountTOppMap.containsKey (oppObj.AccountId)) {
                accountTOppMap.get (oppObj.AccountId).add (oppObj);
            } else {
                accountTOppMap.put (oppObj.AccountId, new List< Opportunity> {oppObj});
            }           
         }
             
             for(Account a:(List<Account>)Trigger.new){
                 System.debug('Hai12');
                 if(!accountTOppMap.isEmpty() && accountTOppMap.containsKey(a.Id)){
                     System.debug('Hai13');
                     for(Opportunity oppObj :accountTOppMap.get(a.Id)){
                         if(oppObj.CreatedDate >= a.Global_Account_MQA_Assignment_date__c){
                             System.debug('Hai');
                          oppObj.Converted_from_MQA__c = true; 
                             updateOpptyList.add(oppObj);
                         }
                         else{
                           oppObj.Converted_from_MQA__c = false;
                             System.debug('Hai1');
                             updateOpptyList.add(oppObj);
                         }
                     } 
                 }
             }
         if(!updateOpptyList.isEmpty()){
              System.debug('Empty');
             UPDATE updateOpptyList;
         }
    } */
}