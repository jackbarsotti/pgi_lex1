/**
 * This is helper class for PGIAccountTrigger. It contains the helper methods to implement the business requirement
 * on the Account object on trigger execution.
 *
 * @author Amit M.
 * @version 1.0
 */
public with sharing class PGIAccountTriggerHelper {
    
    private static Set<Id> mergedAccountIds = new Set<Id>();
    private static Boolean firstTriggerExecution = true;
    
    public void onBeforeUpdate()
    {
        Map<Id,Account> accountMap = this.collectMasterMergedAccounts((List<Account>)Trigger.new);
        List<Account> SubAgentVARDuplicateAccnts = new List<Account>();
        List<Account> TopLevelDuplicateAccnts = new List<Account>();
        List<Account> Otheraccounts = new List<Account>();
        Map<ID,Schema.RecordTypeInfo> rt_Map = Account.sObjectType.getDescribe().getRecordTypeInfosById();
        for(Account acc : (List<Account>)Trigger.New)
        {
            if (rt_map.get(acc.recordTypeID).getName().containsIgnoreCase('PGi'))
            {
            if(acc.type == 'Sub Agent' || acc.type == 'VAR')
                SubAgentVARDuplicateAccnts.add(acc);
            else if (acc.type == 'Affinity' || acc.type == 'Budget' || acc.type == 'Carrier' || acc.type == 'Direct' || acc.type == 'Distributor' || acc.type == 'Field Sales' || acc.type == 'Commercial Accounts' || acc.type == 'Marketing Alliance' || acc.type == 'Master Agent' || acc.type == 'Partner Direct' || acc.type == 'Referral Partner' || acc.type == 'Reseller' || acc.type == 'Soundpath' || acc.type == 'Tier 1')
                TopLevelDuplicateAccnts.add(acc);
            else
                Otheraccounts.add(acc);   
            }    
        }
        
        if(!SubAgentVARDuplicateAccnts.isEmpty())
        {
            for(Account acc1 : SubAgentVARDuplicateAccnts)
            {
                acc1.Account_Type_for_Match__c = 'Sub-Agent and VAR Duplicates';
            }
        }
        if(!TopLevelDuplicateAccnts.isEmpty())
        {
            for(Account acc2 : TopLevelDuplicateAccnts)
            {
                acc2.Account_Type_for_Match__c = 'Top Level Duplicates';
            }
        }
        if(!Otheraccounts.isEmpty())
        {
            for(Account acc3 : Otheraccounts)
            {
                acc3.Account_Type_for_Match__c = 'Other';
            }
        }

    }
    
    public void onBeforeInsert()
    {
        Set<Id> Accountids = new Set<Id>();
        Set<Id> Leadids = new Set<Id>();
        List<Account> AccountstoUpdate = new List<Account>();
        List<Account> SubAgentVARDuplicateAccnts = new List<Account>();
        List<Account> TopLevelDuplicateAccnts = new List<Account>();
        List<Account> Otheraccounts = new List<Account>();
        
        Map<ID,Schema.RecordTypeInfo> rt_Map = Account.sObjectType.getDescribe().getRecordTypeInfosById();

        for(Account acc : (List<Account>)Trigger.New)
        {
            if (rt_map.get(acc.recordTypeID).getName().containsIgnoreCase('PGi'))
            {
            if(acc.waslead__c == True && acc.Lead_ID__c <> Null)
            {
                Leadids.add(acc.lead_id__c);
                AccountstoUpdate.add(acc);
            }
            if(acc.type == 'Sub Agent' || acc.type == 'VAR')
                SubAgentVARDuplicateAccnts.add(acc);
            else if (acc.type == 'Affinity' || acc.type == 'Budget' || acc.type == 'Carrier' || acc.type == 'Direct' || acc.type == 'Distributor' || acc.type == 'Field Sales' || acc.type == 'Commercial Accounts' || acc.type == 'Marketing Alliance' || acc.type == 'Master Agent' || acc.type == 'Partner Direct' || acc.type == 'Referral Partner' || acc.type == 'Reseller' || acc.type == 'Soundpath' || acc.type == 'Tier 1')
                TopLevelDuplicateAccnts.add(acc);
            else
                Otheraccounts.add(acc); 
            }      
        }
        if(!AccountstoUpdate.isEmpty())
        {
            Map<Id, Lead> LeadAccountType = new Map<Id, Lead>([select Id, Account_Type__c from Lead where Id IN :Leadids]);
            for(Account accnt : AccountstoUpdate)
            {
                accnt.type = LeadAccountType.get(accnt.lead_id__c).account_type__c;
            }
        }
        if(!SubAgentVARDuplicateAccnts.isEmpty())
        {
            for(Account acc1 : SubAgentVARDuplicateAccnts)
            {
                acc1.Account_Type_for_Match__c = 'Sub-Agent and VAR Duplicates';
            }
        }
        if(!TopLevelDuplicateAccnts.isEmpty())
        {
            for(Account acc2 : TopLevelDuplicateAccnts)
            {
                acc2.Account_Type_for_Match__c = 'Top Level Duplicates';
            }
        }
        if(!Otheraccounts.isEmpty())
        {
            for(Account acc3 : Otheraccounts)
            {
                acc3.Account_Type_for_Match__c = 'Other';
            }
        }
    }
    public void onAfterDelete()
    {
        this.collectMergedAccounts((List<Account>)Trigger.old);
    }
    
    public void onAfterInsert()
    {
        
    }
    
    public void onAfterUpdate()
    {
        setGlobalRegion((Map<Id,Account>)Trigger.oldMap, (List<Account>)Trigger.new);
    }
    
    private void collectMergedAccounts(List<Account> oldAccountList)
    {
        for (Account account : oldAccountList)
        {
            if (account.MasterRecordId != null)
            {
                mergedAccountIds.add(account.MasterRecordId);
            }
        }
    }
    
    private Map<Id, Account> collectMasterMergedAccounts(List<Account> newAccountList)
    {
        Map<Id, Account> masterMergedAccountMap = new Map<Id, Account>();
        for (Account account : newAccountList)
        {
            if (mergedAccountIds.contains(account.Id))
            {
                masterMergedAccountMap.put(account.Id, account);
            }
        }
        return masterMergedAccountMap;
    }

    private void setGlobalRegion(Map<Id,Account> oldMap, List<Account> accountList)
    {
        Map<String, RegionTable__c> regionTable = RegionTable__c.getAll();
        Set<Id> accountIds = new Set<Id>();
        if(regionTable != null) 
            {
            for(Account account : accountList){
                if(oldMap == null || (account.BillingCountry != null && account.BillingCountry != oldMap.get(account.Id).BillingCountry)){
                    accountIds.add(account.Id);
                }
            }
         List<Account> accToUpdate = [SELECT Id, BillingCountry FROM Account WHERE Id IN :accountIds];
         System.debug('accToUpdate in loop?' + accToUpdate);    
            for(Account account : accToUpdate){
                if(regionTable.containsKey(account.BillingCountry)){
                    account.Global_Region__c = regionTable.get(account.BillingCountry).Region__c;
                }
            }
            update accToUpdate;
        }
    }  
}