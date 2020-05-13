trigger PopulateRelatedAccountforLeads on Lead (after insert,after update) {

if(setrecursivevariable.firstRun)
{
    
setrecursivevariable.firstRun = false; 
Set<Id> leadIds = new Set<Id>();
Map<ID,Schema.RecordTypeInfo> rt_Map = Lead.sObjectType.getDescribe().getRecordTypeInfosById();
Map<ID,Schema.RecordTypeInfo> rt_Map_Account = Account.sObjectType.getDescribe().getRecordTypeInfosById();
Set<String> domainstoexclude = new Set<String>{'aol.com','bellsouth.net','charter.net','comast.net','comcast.net','cox.net','earthlink.net','gmail.com','hotmail.co.uk','hotmail.com','hotmail.fr','hotmail.','icloud.com','live.com','mac.com','mailinator.com','me.com','msn.com','outlook.com','sbcglobal.net','verizon.net','yahoo.','yahoo.co.id','yahoo.co.in','yahoo.co.jp','yahoo.com','yahoo.com.hk','yahoo.de','yahoo.fr','ymail.com'};
    
for (Lead ld : Trigger.new)
{
    if (rt_map.get(ld.recordTypeID).getName().containsIgnoreCase('PGi') && (ld.Company_for_Match_Logic__c <> null || ld.email <> null) && (ld.account__c == null || ld.Potential_Account_Matches__c == null) && ( ld.Country == 'United States' || ld.Country == 'Canada') && (ld.created_by_user_s_name__c.contains('Eloqua')|| ld.created_by_user_s_region__c == 'NA'))
    {
        leadIds.add(ld.Id);
    }
}
system.debug('ARC debug populaterelatedaccountforleads - lead Ids:' +leadIds);

if(!leadIds.isEmpty())
{
    List<Lead> leadstoconsider = new List<Lead>([Select Id,name,Company_for_Match_Logic__c,emaildomain__c from lead where id IN :leadIds]);
    Map<String,Set<Id>> domaintoaccountmap = new Map<String,Set<Id>>();
    Map<String,Set<Id>> nametoaccountmap = new Map<String,Set<Id>>();
    Map<String,Set<Account>> nametoaccountlistmap = new Map<String,Set<Account>>();
    Map<String,Set<Account>> domaintoaccountlistmap = new Map<String,Set<Account>>();
    Set<String> companynames = new Set<String>();
    Set<String> webdomains = new Set<String>();
    Set<String> emaildomains = new Set<String>();
    
    for(Lead ld : leadstoconsider)
    {
        if(String.isNotBlank(ld.Company_for_Match_Logic__c))
            companynames.add(ld.Company_for_Match_Logic__c);
        if(String.isNotBlank(ld.emaildomain__c))
            emaildomains.add('%'+ld.emaildomain__c+'%');           
    }    
    system.debug('ARC debug companynames:'+companynames);
    system.debug('ARC debug emaildomains:'+emaildomains);
    List<Account> AllMatchingaccountswithname = [Select Id, Name, Recordtypeid, Status__c from Account where name IN :companynames];
    List<Account> AllMatchingaccountswithdomain = [Select Id,Name,Webdomain__c,Recordtypeid,Status__c from Account where website != NULL and website LIKE :emaildomains];
    
    system.debug('ARC debug AllMatchingaccountswithname:'+AllMatchingaccountswithname);
    system.debug('ARC debug AllMatchingaccountswithdomain:'+AllMatchingaccountswithdomain);
   
    /***************** Building maps to use in the matching logic *******************************************************/   
         
     for (Account acct : Allmatchingaccountswithname)
     {
        if (rt_map_Account.get(acct.recordTypeID).getName().containsIgnoreCase('PGi'))
        {
            if (!nametoaccountmap.containsKey(acct.name)) 
            {
                nametoaccountmap.put(acct.name,new set<Id>());
                nametoaccountlistmap.put(acct.name,new set<Account>());
            }
            nametoaccountmap.get(acct.name).add(acct.id);
            nametoaccountlistmap.get(acct.name).add(acct);
        }
     }    
     
     for (Account acct : Allmatchingaccountswithdomain)
     {
        if (rt_map_Account.get(acct.recordTypeID).getName().containsIgnoreCase('PGi'))
        {
            if (!domaintoaccountmap.containsKey(acct.webdomain__c)) 
            {
                domaintoaccountmap.put(acct.webdomain__c,new set<Id>());
                domaintoaccountlistmap.put(acct.webdomain__c,new set<Account>());
            }
            domaintoaccountmap.get(acct.webdomain__c).add(acct.id);
            domaintoaccountlistmap.get(acct.webdomain__c).add(acct);
        }
     }   
     
     system.debug('ARC debug PopulateRelatedAccountforLeads domaintoaccountmap:'+domaintoaccountmap);
     system.debug('ARC debug PopulateRelatedAccountforLeads nametoaccountmap:'+nametoaccountmap);    
      
     List<Lead> Leadswithsingleemailmatch = new List<Lead>();
     List<Lead> Leadswithmultipleemailmatches = new List<Lead>(); 
     List<Lead> Leadswithnonamematch = new List<Lead>();
     List<Lead> Leadswithsinglenamematch = new List<Lead>();
     List<Lead> Leadswithmultiplenamematches = new List<Lead>();
     Map<Lead,Set<Id>> leadtoaccountmatcheswithnamemap = new Map<Lead,Set<Id>>();
     Map<Lead,Set<Account>> leadtoaccountmatcheswithnamelistmap = new Map<Lead,Set<Account>>();
     List<Lead> Leadswithnostatusmatch = new List<Lead>();
     List<Lead> Leadswithsinglestatusmatch = new List<Lead>();
     List<Lead> Leadswithmultiplestatusmatches = new List<Lead>();
     Map<Lead,Set<Id>> leadtoaccountmatcheswithstatusmap = new Map<Lead,Set<Id>>();
     Set<Id> relatedaccountid = new Set<Id>();
     Set<Account> multipleaccountmatchesfornamelist = new Set<Account>();
     Set<Id> relatedaccntids = new Set<Id>();
     
     
     if(!leadstoconsider.isEmpty()){
     for(Lead ld1 : leadstoconsider)
     {
         if(ld1.emaildomain__c <> NULL)
         {
             system.debug('ARC debug populaterelatedaccountforleads - leaddomain:'+ld1.emaildomain__c);
             if(!domainstoexclude.contains(ld1.emaildomain__c)){
             if(domaintoaccountmap.containskey(ld1.emaildomain__c))
             {
                 Set<Id> matchingacctids = new Set<Id>();
                 matchingacctids = domaintoaccountmap.get(ld1.emaildomain__c);
                 if(matchingacctids.size()==1)
                     Leadswithsingleemailmatch.add(ld1);
                 else
                     Leadswithmultipleemailmatches.add(ld1);
             } 
             }   
         } 
            
         else
         {
             if(ld1.emaildomain__c == NULL && ld1.Company_for_Match_Logic__c <> NULL && nametoaccountmap.containskey(ld1.Company_for_Match_Logic__c))
             {
                 Set<Id> matchingacctids = new Set<Id>();
                 matchingacctids = nametoaccountmap.get(ld1.Company_for_Match_Logic__c);     
                 if(matchingacctids.size()==1)
                     Leadswithsinglenamematch.add(ld1);
                 else
                     Leadswithmultiplenamematches.add(ld1);
             }
         }
     }
     }
     
     system.debug('ARC debug PopulateRelatedAccountforLeads Leadswithsingleemailmatch:'+Leadswithsingleemailmatch);
     system.debug('ARC debug PopulateRelatedAccountforLeads Leadswithmultipleemailmatches:'+Leadswithmultipleemailmatches);     
     system.debug('ARC debug PopulateRelatedAccountforLeads Leadswithsinglenamematch:'+Leadswithsinglenamematch);
     system.debug('ARC debug PopulateRelatedAccountforLeads Leadswithmultiplenamematches:'+Leadswithmultiplenamematches);    
     
     /**************************** Matching Logic for Leads with Single Match against Email ****************************/
     
     if(!Leadswithsingleemailmatch.isEmpty())
     {
        system.debug('ARC debug PopulateRelatedAccountforLeads entered Leadswithsingleemailmatch'); 
        for (Lead ldwithonematch : Leadswithsingleemailmatch)
        {
            relatedaccountid = domaintoaccountmap.get(ldwithonematch.emaildomain__c);     
            ldwithonematch.account__c = new List<Id> ( relatedaccountid )[0]; 
            ldwithonematch.Potential_Account_Matches__c = null;
        }  
     update Leadswithsingleemailmatch; 
     }
     
     /**************************** Matching Logic for Leads with Multiple Matches against Email ****************************/
     
    if(!Leadswithmultipleemailmatches.isEmpty())
    {
         system.debug('ARC debug PopulateRelatedAccountforLeads entered Leadswithmultipleemailmatches'); 
         for(Lead ldwithmultipleemailmatch : Leadswithmultipleemailmatches)
         {
             Set<Id> multipleaccountmatchesforemail = domaintoaccountmap.get(ldwithmultipleemailmatch.emaildomain__c); 
             if(ldwithmultipleemailmatch.Company_for_Match_Logic__c == NULL)
             {
                 Set<String> relatedaccountidsstring = (Set<String>)JSON.deserialize(JSON.serialize(multipleaccountmatchesforemail), Set<String>.class);
                 List<String> relatedaccountidslist = new List<String>(relatedaccountidsstring);
                 String collectionstring = '';
                 for (String s : relatedaccountidslist)
                 {
                     collectionstring += (collectionstring==''?'':',')+s;
                 } 
                 ldwithmultipleemailmatch.Potential_Account_Matches__c = collectionstring; 
                 ldwithmultipleemailmatch.account__c = null; 
             }
             else
             {
                
             Set<Account> multipleaccountmatchesforemaillist = domaintoaccountlistmap.get(ldwithmultipleemailmatch.emaildomain__c);   
             for (Account acc1 : multipleaccountmatchesforemaillist)
             {
                 if(acc1.name == ldwithmultipleemailmatch.Company_for_Match_Logic__c)
                 {
                     if (!leadtoaccountmatcheswithnamemap.containsKey(ldwithmultipleemailmatch)) 
                     {
                         leadtoaccountmatcheswithnamemap.put(ldwithmultipleemailmatch,new set<Id>());
                         leadtoaccountmatcheswithnamelistmap.put(ldwithmultipleemailmatch,new set<Account>());
                     }
                     leadtoaccountmatcheswithnamemap.get(ldwithmultipleemailmatch).add(acc1.id);  
                     leadtoaccountmatcheswithnamelistmap.get(ldwithmultipleemailmatch).add(acc1);       
                 }        
             }
             if(!leadtoaccountmatcheswithnamemap.containskey(ldwithmultipleemailmatch))
                 Leadswithnonamematch.add(ldwithmultipleemailmatch);
             else
             {
                 if(leadtoaccountmatcheswithnamemap.get(ldwithmultipleemailmatch).size()==1)
                     Leadswithsinglenamematch.add(ldwithmultipleemailmatch);
                 else
                     Leadswithmultiplenamematches.add(ldwithmultipleemailmatch);    
             } 
             }       
         }
     }
     
     /**************************** Matching Logic for Leads with No Match against Company Name ****************************/
     
     if(!Leadswithnonamematch.isEmpty())   
     {
     system.debug('ARC debug PopulateRelatedAccountforLeads entered Leadswithnonamematch'); 
     for (Lead ldwithnonamematch : Leadswithnonamematch)
     {
         Set<Id> relatedaccountids = domaintoaccountmap.get(ldwithnonamematch.emaildomain__c); 
         Set<String> relatedaccountidsstring = (Set<String>)JSON.deserialize(JSON.serialize(relatedaccountids), Set<String>.class);
         List<String> relatedaccountidslist = new List<String>(relatedaccountidsstring);
         String collectionstring = '';
         for (String s : relatedaccountidslist)
         {
             collectionstring += (collectionstring==''?'':',')+s;
         } 
         ldwithnonamematch.Potential_Account_Matches__c = collectionstring; 
     }
     update Leadswithnonamematch;   
     } 
      
     /**************************** Matching Logic for Leads with Single Match against Company Name ****************************/
     
     if(!Leadswithsinglenamematch.isEmpty())
     {
        system.debug('ARC debug PopulateRelatedAccountforLeads entered Leadswithsinglenamematch'); 
        for (Lead ldwithsinglenamematch : Leadswithsinglenamematch)
        {
            if(ldwithsinglenamematch.emaildomain__c <> NULL)
                relatedaccountid = leadtoaccountmatcheswithnamemap.get(ldwithsinglenamematch); 
            if(ldwithsinglenamematch.emaildomain__c == NULL && ldwithsinglenamematch.Company_for_Match_Logic__c <> NULL)
                relatedaccountid = nametoaccountmap.get(ldwithsinglenamematch.Company_for_Match_Logic__c);         
            ldwithsinglenamematch.account__c = new List<Id> ( relatedaccountid )[0]; 
            ldwithsinglenamematch.Potential_Account_Matches__c = null;
        }  
     update Leadswithsinglenamematch; 
     }   
     
     /**************************** Matching Logic for Leads with Multiple Matches against Company Name ****************************/
     
     if(!Leadswithmultiplenamematches.isEmpty())
     {
         system.debug('ARC debug PopulateRelatedAccountforLeads entered Leadswithmultiplenamematches'); 
         for(Lead ldwithmultiplenamematch : Leadswithmultiplenamematches)
         {
             if(ldwithmultiplenamematch.emaildomain__c <> NULL)
                 multipleaccountmatchesfornamelist = leadtoaccountmatcheswithnamelistmap.get(ldwithmultiplenamematch);  
             if(ldwithmultiplenamematch.emaildomain__c == NULL && ldwithmultiplenamematch.Company_for_Match_Logic__c <> NULL)
                 multipleaccountmatchesfornamelist = nametoaccountlistmap.get(ldwithmultiplenamematch.Company_for_Match_Logic__c);   
                          
             for (Account acc1 : multipleaccountmatchesfornamelist)
             {
                 if(acc1.status__c == 'Customer')
                 {
                     if (!leadtoaccountmatcheswithstatusmap.containsKey(ldwithmultiplenamematch)) 
                     {
                         leadtoaccountmatcheswithstatusmap.put(ldwithmultiplenamematch,new set<Id>());
                     }
                     leadtoaccountmatcheswithstatusmap.get(ldwithmultiplenamematch).add(acc1.id);       
                 }        
             }
             if(!leadtoaccountmatcheswithstatusmap.containskey(ldwithmultiplenamematch))
                 Leadswithnostatusmatch.add(ldwithmultiplenamematch);
             else
             {
                 if(leadtoaccountmatcheswithstatusmap.get(ldwithmultiplenamematch).size()==1)
                     Leadswithsinglestatusmatch.add(ldwithmultiplenamematch);
                 else
                     Leadswithmultiplestatusmatches.add(ldwithmultiplenamematch);    
             }        
         }
     }
     
     system.debug('ARC debug Leadswithnostatusmatch:'+Leadswithnostatusmatch);
     system.debug('ARC debug Leadswithsinglestatusmatch:'+Leadswithsinglestatusmatch);
     system.debug('ARC debug Leadswithmultiplestatusmatch:'+Leadswithmultiplestatusmatches);
     
     /**************************** Matching Logic for Leads with No Match against Account Status ****************************/
     
     if(!Leadswithnostatusmatch.isEmpty())
     {
     system.debug('ARC debug PopulateRelatedAccountforLeads entered Leadswithnostatusmatch'); 
     for (Lead ldwithnostatusmatch : Leadswithnostatusmatch)
     {
         if(ldwithnostatusmatch.emaildomain__c <> NULL)
             relatedaccntids = leadtoaccountmatcheswithnamemap.get(ldwithnostatusmatch); 
         else
             relatedaccntids = nametoaccountmap.get(ldwithnostatusmatch.Company_for_Match_Logic__c);         
         Set<String> relatedaccountidsstring = (Set<String>)JSON.deserialize(JSON.serialize(relatedaccntids), Set<String>.class);
         List<String> relatedaccountidslist = new List<String>(relatedaccountidsstring);
         String collectionstring = '';
         for (String s : relatedaccountidslist)
         {
             collectionstring += (collectionstring==''?'':',')+s;
         } 
         ldwithnostatusmatch.Potential_Account_Matches__c = collectionstring; 
         system.debug('ARC debug relatedaccountids:'+relatedaccntids);
         system.debug('ARC debug collectionstring:'+collectionstring);
     }
     update Leadswithnostatusmatch;   
     } 
      
     /**************************** Matching Logic for Leads with Single Match against Account Status ****************************/ 
     
     if(!Leadswithsinglestatusmatch.isEmpty())
     {
        system.debug('ARC debug PopulateRelatedAccountforLeads entered Leadswithsinglestatusmatch'); 
        for (Lead ldwithsinglestatusmatch : Leadswithsinglestatusmatch)
        {
            relatedaccountid = leadtoaccountmatcheswithstatusmap.get(ldwithsinglestatusmatch);     
            ldwithsinglestatusmatch.account__c = new List<Id> ( relatedaccountid )[0]; 
            ldwithsinglestatusmatch.Potential_Account_Matches__c = null;
        }  
     update Leadswithsinglestatusmatch; 
     } 
     
     /**************************** Matching Logic for Leads with Multiple Matches against Account Status **********************************/
     
     if(!Leadswithmultiplestatusmatches.isEmpty())
     {
     system.debug('ARC debug PopulateRelatedAccountforLeads entered Leadswithmultiplestatusmatches'); 
     for (Lead ldwithmultiplestatusmatch : Leadswithmultiplestatusmatches)
     {
         Set<Id> relatedaccountids = leadtoaccountmatcheswithstatusmap.get(ldwithmultiplestatusmatch); 
         Set<String> relatedaccountidsstring = (Set<String>)JSON.deserialize(JSON.serialize(relatedaccountids), Set<String>.class);
         List<String> relatedaccountidslist = new List<String>(relatedaccountidsstring);
         String collectionstring = '';
         for (String s : relatedaccountidslist)
         {
             collectionstring += (collectionstring==''?'':',')+s;
         } 
         ldwithmultiplestatusmatch.Potential_Account_Matches__c = collectionstring; 
         ldwithmultiplestatusmatch.account__c = null; 
     }
     update Leadswithmultiplestatusmatches;   
     }   
            
}
}
}