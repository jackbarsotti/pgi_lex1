/******************************************************************************
Name : AutopopulateAccountonCompanies
Description : Trigger to autopopulate Account and Company Owner for PGi Companies
******************************************************************************/
trigger AutopopulateAccountonCompanies on PGi_Company__c (after insert,after update) {
     
     if(setrecursivevariable.firstRun)
     {
     setrecursivevariable.firstRun = false;    
     Set<Id> companyIds = new Set<Id>(); 
     Set<Id> compIds = new Set<Id>(); 
     Set<Id> compidswithregion = new Set<Id>();
     List<PGi_Company__c> companytoupdate = new List<PGi_Company__c>();
     List<PGi_Company__c> companyemailupdate = new List<PGi_Company__c>();
     List<AccountTeamMember> accntmember = new List<AccountTeamMember>();
     List<AccountShare> accntshare = new List<AccountShare>();
        
     for (PGi_Company__c comp : Trigger.new)
     {
         if (comp.SF_Account_ID__c <> null)
         {
            companyIds.add(comp.Id);
         }
         if (comp.Sales_Rep_s_Email__c <> null)
         {
            compIds.add(comp.Id);
         }
         if(comp.SF_Account_ID__c == null && comp.Region__c <> NULL)
         {
             compidswithregion.add(comp.Id);
         }    
     }
     if (!compIdswithregion.isEmpty())
     {
         List<PGi_Company__c> compwithregion = [select id, SF_Account_ID__c,Region__c,RelatedAccount__c from PGi_Company__c where id IN :compidswithregion];
         for(PGi_Company__c comp : compwithregion)
         {
         if(comp.Region__c == 'USA')
                 comp.RelatedAccount__c = '001300000106U1c' ;
         if(comp.Region__c == 'EMEA')
                 comp.RelatedAccount__c = '001300000106U2C';
         if(comp.Region__c == 'AP')
                 comp.RelatedAccount__c = '001300000106U2G' ;      
         }
         update compwithregion;
     }    
     if (!companyIds.isEmpty()) 
     {
         List<PGi_Company__c> c = [select id, SF_Account_ID__c,Region__c,RelatedAccount__c from PGi_Company__c where id IN :companyids];
         List<String> teslaIds = new List<String>();
         for (PGi_Company__c cToCheckTeslaIds : c) {
             system.debug('ARC debug statement - Company Id before update- '+cToCheckTeslaIds.id);
             system.debug('ARC debug statement - Company TESLA Account Id before update- '+cToCheckTeslaIds.SF_Account_ID__c);
             teslaIds.add(cToCheckTeslaIds.SF_Account_ID__c);
         }
         List<Account> foundTeslaAccounts = [select id, sfdc_account_id__c from account where sfdc_account_id__c in :teslaIds];
         Map<String, Id> teslaAccounts = new Map<String, Id>();
         for (Account teslaAccount : foundTeslaAccounts) {
             teslaAccounts.put(teslaAccount.sfdc_account_id__c, teslaAccount.id);
         }
         List<PGi_Company__c> csToUpdateAccount = new List<PGi_Company__c>();
         for (PGi_Company__c cToUpdateAccount : c) {
             if (teslaAccounts.containsKey(cToUpdateAccount.SF_Account_ID__c)) {
                 cToUpdateAccount.RelatedAccount__c = teslaAccounts.get(cToUpdateAccount.SF_Account_ID__c);
                 csToUpdateAccount.add(cToUpdateAccount);
                 system.debug('ARC debug statement - Company Id after update- '+cToUpdateAccount.id);
                 system.debug('ARC debug statement - Company TESLA Account Id after update- '+cToUpdateAccount.RelatedAccount__c);
             
             }
             else{
             if(cToUpdateAccount.Region__c == 'USA')
                 cToUpdateAccount.RelatedAccount__c = '001300000106U1c' ;
             if(cToUpdateAccount.Region__c == 'EMEA')
                 cToUpdateAccount.RelatedAccount__c = '001300000106U2C';
             if(cToUpdateAccount.Region__c == 'AP')
                 cToUpdateAccount.RelatedAccount__c = '001300000106U2G' ;          
             }
             
         }
         update c;

     }
     if (!compIds.isEmpty()) 
     {
           List<PGi_Company__c> companiesFound = [select id,Sales_Rep_s_Email__c,RelatedAccount__c,PrimarySalesRep__c from PGi_Company__c where id IN :compIds];
           Map<String, List<PGi_Company__c>> emailToCompanies = new Map<String, List<PGi_Company__c>>();
           for (PGi_Company__c comp : companiesFound)
           {
              String userEmail = comp.Sales_Rep_s_Email__c.tolowercase();
              if (!emailToCompanies.containsKey(userEmail)) 
              {
                  emailToCompanies.put(userEmail, new List<PGi_Company__c>());
              }
              emailToCompanies.get(userEmail).add(comp);
           }
           Map<Id, PGi_Company__c> companiesToUpdate1 = new Map<Id, PGi_Company__c>();
           List<Id> companiesThatWereUpdated = new List<Id>();
           List<User> usersWithEmailsForTheseCompanies = [select Id, Email, IsActive from User where Email in :emailToCompanies.keySet()];
           For (User matchedUser : usersWithEmailsForTheseCompanies)
           {
               if(matcheduser.IsActive == True)
               {
                if (emailToCompanies.get(matchedUser.Email) != null ) 
                {
                    for (PGi_Company__c companyToUpdate1 : emailToCompanies.get(matchedUser.Email))
                    {
                        companyToUpdate1.PrimarySalesRep__c = matchedUser.Id;
                        companiesToUpdate1.put(companyToUpdate1.id, companyToUpdate1);
                        companiesThatWereUpdated.add(companyToUpdate1.Id);
                    }
                }
              }
           }
           Update companiesToUpdate1.values();
      
             List<PGi_Company__c> c2 = [select id, RelatedAccount__c, RelatedAccount__r.OwnerId, PrimarySalesRep__c from PGi_Company__c where RelatedAccount__c <> NULL AND id IN :companiesThatWereUpdated];
             List<Id> compOwners = new List<Id>();
             List<Id> accts = new List<Id>();
             for (PGi_Company__c companyToAddOwner : c2) {
                compOwners.add(companyToAddOwner.PrimarySalesRep__c);
                accts.add(companyToAddOwner.RelatedAccount__c);
             }

             List<AccountTeamMember> allAcctTeamMembers = [select Id, UserId, AccountId from AccountTeamMember where AccountId in :accts or UserId in :compOwners];
            
            Map<Id, Set<Id>> acctTeamMembers = new Map<Id, Set<Id>>();
             for (AccountTeamMember acctTeamMember : allAcctTeamMembers)
             {
                 if (!acctTeamMembers.containsKey(acctTeamMember.AccountId)) 
                 {
                     acctTeamMembers.put(acctTeamMember.AccountId, new Set<Id>());
                 }
                 acctTeamMembers.get(acctTeamMember.AccountId).add(acctTeamMember.UserId);
             }
         

             for (PGi_Company__c companyToCheck : c2) 
                
             {
                 
                 if (companyToCheck.RelatedAccount__r.OwnerId <> companyToCheck.PrimarySalesRep__c) 
                 {
                    
                     if (acctTeamMembers.size() < 1 || !acctTeamMembers.containsKey(companyToCheck.RelatedAccount__c) || acctTeamMembers.get(companyToCheck.RelatedAccount__c) ==null) 
                     {
                         
                        accntmember.add(new AccountTeamMember(
                                        accountid=companyToCheck.RelatedAccount__c,
                                        userid = companyToCheck.PrimarySalesRep__c,
                                        TeamMemberRole = 'Sales Rep'));
                        accntshare.add(new AccountShare(
                                        accountid=companyToCheck.RelatedAccount__c,
                                        UserOrGroupId = companyToCheck.PrimarySalesRep__c,
                                        AccountAccessLevel = 'Edit',
                                        OpportunityAccessLevel = 'Edit',
                                        CaseAccessLevel = 'Edit',
                                        ContactAccessLevel = 'Edit'));
                    }
                    else
                    {
                        if (!acctTeamMembers.get(companyToCheck.RelatedAccount__c).contains(companyToCheck.PrimarySalesRep__c))
                        {
                                 accntmember.add(new AccountTeamMember(
                                        accountid=companyToCheck.RelatedAccount__c,
                                        userid = companyToCheck.PrimarySalesRep__c,
                                        TeamMemberRole = 'Sales Rep'));
                                accntshare.add(new AccountShare(
                                        accountid=companyToCheck.RelatedAccount__c,
                                        UserOrGroupId = companyToCheck.PrimarySalesRep__c,
                                        AccountAccessLevel = 'Edit',
                                        OpportunityAccessLevel = 'Edit',
                                        CaseAccessLevel = 'Edit',
                                        ContactAccessLevel = 'Edit'));
                            }    
                        
                     }
                 }           
             }
              
           insert accntmember;
           insert accntshare;
      }
     
      }
      
}