global class massupdateduns implements Database.Batchable<sObject> 
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {   
        String query = 'select id,dunsnumber,duns_number__c from account where dunsnumber <> null'; 
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope)
    {   
        for(Account a:scope)
        {    
            
         a.duns_number__c = a.dunsnumber;
        }
        update scope;
    }    
    global void finish(Database.BatchableContext BC)    
    {
        
    }    
}