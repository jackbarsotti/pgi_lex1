/*******************************************************************************************
Name : PopulatePrimaryContactonOpportunityBatch
Created On : Sep 13, 2016
Created By : Archana Rajendran
Description : Batch Apex to update primary contact on opportunity
********************************************************************************************/
global class PopulatePrimaryContactonOpportunityBatch implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {   
        String query = 'select contactid from opportunitycontactrole where isprimary = true';
        //System.debug('ARC debug statement for query' +query); //debugging
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        List <opportunitycontactrole> oppcontactrolelist = (List<opportunitycontactrole>) scope;  
        Set <ID> contactIds = new Set <ID> (); // Contact id 
        List<Contact> contactlisttobeupdated = new List<Contact>();
        for (opportunitycontactrole getcontactIds : oppcontactrolelist) 
        {
            contactIds.add(getcontactIds.contactid); 
        }
        //system.debug('ARC debug contactids' +contactids);
        contactlisttobeupdated = [Select id from contact where recordtype.name like '%PGi%' and id IN :contactids]; 
        //system.debug('ARC debug contactlisttobeupdated' +contactlisttobeupdated);
        for(Contact con : contactlisttobeupdated)
        {
        con.Primary_Contact_on_Opp__c = true;
        }  
        update contactlisttobeupdated;
    }   
 global void finish(Database.BatchableContext BC)    
    {
        
    }       
     
}