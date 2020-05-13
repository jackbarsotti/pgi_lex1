public without sharing class AccountUltimateParentBilledRevenueBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

	public void execute(SchedulableContext sc) {
		Database.ExecuteBatch(new AccountUltimateParentBilledRevenueBatch(), 200);
	}
	private boolean firstIteration {get; set;}
    private Set<Id> parentIdSet {get; set;}
    public AccountUltimateParentBilledRevenueBatch(Set<Id> parentIdSet) {
        firstIteration = false;
        this.parentIdSet = parentIdSet;
    }
    public AccountUltimateParentBilledRevenueBatch() {
    	parentIdSet = new Set<Id>();
        firstIteration = true;
    }
	public Database.QueryLocator start(Database.BatchableContext bc){
    	String query = 'SELECT Id, Billed_Revenue_Last_13_Months__c, ParentId FROM Account WHERE RecordType.Name = \'PGi Account\' AND (NOT Name LIKE \'%unmatch%\')';
    	if(firstIteration) {
    		//first iteration - query records with parents
    		query += ' AND ParentId != null ';
    	} else  {
    		//second iteration - query records without parents (ultimate parents)
    		query += ' AND ParentId = null AND Id IN: parentIdSet';
    	}
    	return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Account> scope){
    	if(firstIteration) {
    		for(Account a: scope) {
    			parentIdSet.add(a.ParentId);
    		}
    		parentIdSet.remove(null);
		} else {
			System.assert(scope.size() == 1, 'batch size must be 1 for second iteration');
        	//Map<Id, Account> accountMap = new Map<Id, Account>();
        
            // ASSUME batch size of 1 ultimate parent iterate in scope at a time
            Set<Id> hierarchyAcctIds = new Set<Id>();
            hierarchyAcctIds.add(scope[0].id);//(new Map<Id,SObject>(scope[i])).keySet();
    		
            List<Account> allChildrenInHierarchy = new List<Account>();
            Boolean hasChildren;
    
            do {
                hasChildren = false;
                Set<Id> nextAccountIds = new Set<Id>();
               
                for(Account acct : [SELECT Id, Billed_Revenue_Last_13_Months__c FROM Account WHERE ParentId IN :hierarchyAcctIds]) {
                    allChildrenInHierarchy.add(acct);
                    nextAccountIds.add(acct.Id);
                    hasChildren = true;
                }
    
                hierarchyAcctIds = new Set<Id>();
                if(!nextAccountIds.isEmpty()) {
                    hierarchyAcctIds.addAll(nextAccountIds);	
                }
            } while (hasChildren);
            
    
            if(!allChildrenInHierarchy.isEmpty()) {
                Account ultimateParent = scope[0];
                Decimal totalRevenue = ultimateParent.Billed_Revenue_Last_13_Months__c;
                // aggregate all children account revenue 
                // TODO: perform this in the do while loop above?
                for(Account childAccount : allChildrenInHierarchy) {
                    if(childAccount.Billed_Revenue_Last_13_Months__c != null) {
                        totalRevenue += childAccount.Billed_Revenue_Last_13_Months__c;	
                    }
                    childAccount.Ultimate_Parent_Account__c = scope[0].Id;
                }
    
                // update Ultimate Parent with total revenue
                ultimateParent.Ultimate_Parent_Billed_Revenue__c = totalRevenue;
                //accountMap.put(ultimateParent.Id, ultimateParent);
                TriggerHandler.bypass('AccountTriggerHandler');
                List<Account> toUpdate = new List<Account>();
                toUpdate.add(ultimateParent);
                toUpdate.addAll(allChildrenInHierarchy);

                LoggerUtil.handleSaveResults('Failed to update Accounts Ultimate Parent Revenue', Database.update(toUpdate, false));
                
                // update all children with Ultimate Parent lookup

                //LoggerUtil.handleSaveResults('Failed to update Children Ultimate Parent Lookup', Database.update(allChildrenInHierarchy, false));
                //accountMap.putAll(allChildrenInHierarchy);//ultimateParent.Id, ultimateParent);
            }
            //LoggerUtil.handleSaveResults('Failed to update Children Ultimate Parent Lookup', Database.update(accountMap.values(), false));
            LoggerUtil.commitLogs();
        }
   }
    public void finish(Database.BatchableContext bc){
    	if(firstIteration) {
    		//first iteration - query records with parents
    		Database.ExecuteBatch(new AccountUltimateParentBilledRevenueBatch(parentIdSet), 1);
    	} else {
    		//cascade down
    		Database.executeBatch(new PGiCompanyAccountUltimateParentBatch());
    		Database.executeBatch(new PGiContractAccountUltimateParentBatch());
    	}
    }
}