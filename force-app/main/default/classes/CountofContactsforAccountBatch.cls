/*******************************************************************************************
Name : CountofContactsforAccountBatch
Created On : Jul 11, 2016
Created By : Archana Rajendran
Description : Batch Apex to count the number of contacts associated to an Account
********************************************************************************************/
global class CountofContactsforAccountBatch implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {   
        String query = 'select id from account where lastmodifieddate = TODAY and recordtype.name like \'%PGi%\'';
        //System.debug('ARC debug statement for query' +query); //debugging
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope)
    {   
        List <Account> acclist = (List<Account>) scope;
        //System.debug('ARC debug statement for scope' +scope); //debugging
        Set <ID> accountIds = new Set <ID> (); // Setting Account id
                       
        for (Account getAccIds : acclist) 
        {
            accountIds.add(getAccIds.id); 
        }
        //System.debug('ARC debug statement for accountids:' +accountIds); 
        Map<Id,Integer> countmap = new Map<Id,Integer>();
        AggregateResult[] groupedResults = [select accountid,count(id) concount from contact group by accountid having accountid in :accountids];
        
        for (AggregateResult ar : groupedResults) 
            {
                //System.debug('ARC debug Account Id' + ar.get('accountid'));
                //System.debug('ARC debug No of contacts' + ar.get('concount'));
                countmap.put(string.valueof(ar.get('accountid')), integer.valueof(ar.get('concount')));
            }

        //System.debug('ARC debug map' +countmap); 
        
        for (Account acc : acclist)
        {
            if (countmap.containskey(acc.id))
            acc.No_of_contacts__c = countmap.get(acc.id);
            else
            acc.No_of_contacts__c = 0;    
        }    
        update acclist;
    }       
    global void finish(Database.BatchableContext BC)    
    {
        
    }    
}