/******************************************************************************
Name : PopulateParentAccount
Created On : Oct 12, 2016
Created By : Archana Rajendran
Description : Trigger to populate parent account for Accounts
******************************************************************************/
//DEPRECATE
trigger PopulateParentAccount on Account (after insert,after update) {

    //if(setrecursivevariable.firstRun) {

    //    setrecursivevariable.firstRun = false; 
    //    Set<Id> accountIds = new Set<Id>();
    //    Map<ID,Schema.RecordTypeInfo> rt_Map = Account.sObjectType.getDescribe().getRecordTypeInfosById();
  
    //    for(Account acc : Trigger.new) {
    //        if(rt_map.get(acc.recordTypeID).getName().containsIgnoreCase('PGi') && acc.channel__c <> 'Partners') {
    //            system.debug('ARC debug of accountid :' + ACC.ID);
    //            system.debug('ARC debug of accountids owners CHANNEL :' + acc.channel__c);
    //            accountIds.add(acc.Id);
    //        }
    //    }

    //    system.debug('ARC debug of accountids :' + accountids);
    //    if(!accountIds.isEmpty()) {
    //        List<Account> AccountswithDandB = [SELECT Id, DandbCompany.ParentOrHqDunsNumber, ParentId, duns_number__c FROM Account WHERE DandbCompanyid <> null AND Id IN :accountIds];
    //        List<Account> AccountswithoutDandB = [SELECT Id, DandbCompany.ParentOrHqDunsNumber, ParentId, duns_number__c FROM Account WHERE DandbCompanyid = null AND Id IN :accountIds];
    //        system.debug('ARC debug AccountswithDandB:' + AccountswithDandB);
    //        Set<String> ParentDUNSNumber = new Set<String>(); 
      
    //        if(!AccountswithDandB.isEmpty()) {
              
    //            for(Account getdunsnum : AccountswithDandB) {
    //                ParentDUNSNumber.add(getdunsnum.DandbCompany.ParentOrHqDunsNumber);         
    //            }
    //            List<Account> ParentAccountmatchesforDUNS = [SELECT Id, DUNSNumber, DUNS_Number__c, channel__c FROM Account WHERE channel__c <> 'Partners' AND Duns_Number__c IN :ParentDUNSNumber];
    //            Map<String,Set<Id>> dunstoparentaccountmatches = new Map<String,Set<Id>>();
    
    //            for(Account acct : ParentAccountmatchesforDUNS) {
    //                if(!dunstoparentaccountmatches.containsKey(acct.DUNS_Number__c)) {
    //                    dunstoparentaccountmatches.put(acct.DUNS_Number__c, new set<Id>());
    //                }
    //                dunstoparentaccountmatches.get(acct.DUNS_Number__c).add(acct.id);
    //            } 
    
    //            Map<Account,Set<Id>> accounttoparentaccountmatch = new Map<Account,Set<Id>>();
    //            List<Account> AccountwithNoMatchList1 = new List<Account>();
    //            List<Account> AccountwithSingleMatch1 = new List<Account>();
    //            List<Account> AccountwithMultipleMatch1 = new List<Account>();
    //            List<Account> Accountasmultiplematches = new List<Account>();
    //            Set<Id> Accountasmultiplematchesid = new Set<Id>();
    
    //            for(Account acctrec : AccountswithDandB) {
    //                if(!dunstoparentaccountmatches.containskey(acctrec.DandbCompany.ParentOrHqDunsNumber)) {
    //                    AccountwithNoMatchList1.add(acctrec); 
    //                }
    //                else {
    //                    Set<Id> Accountmatchesids = new Set<Id>();
    //                    Accountmatchesids = dunstoparentaccountmatches.get(acctrec.DandbCompany.ParentOrHqDunsNumber);
    //                    for (Id everymatch : Accountmatchesids) {
    //                        if(everymatch == acctrec.Id) {
    //                            Accountmatchesids.remove(acctrec.Id);
    //                        }
    //                    }
    //                    if(Accountmatchesids.isEmpty()) {
    //                        AccountwithNoMatchList1.add(acctrec);
    //                    }
    //                    else {
    //                        accounttoparentaccountmatch.put(acctrec,Accountmatchesids);
    //                        if(accounttoparentaccountmatch.get(acctrec).size() == 1) {
    //                            AccountwithSingleMatch1.add(acctrec);
    //                        }
    //                        else {
    //                            AccountwithMultipleMatch1.add(acctrec);
    //                        }  
    //                    }
    //                }            
    //            } 
    //            if(!AccountwithNoMatchList1.isEmpty()) {
    //                for (Account originalnomatchacc : AccountwithNoMatchList1) {
    //                    originalnomatchacc.DuplicateDetectedforParentLookup__c = false;
    //                    originalnomatchacc.ParentId = null;
    //                }  
    //                update AccountwithNoMatchList1;
    //            }
    //            if(!AccountwithSingleMatch1.isEmpty()) {
    //                for (Account originalsingleacc : AccountwithSingleMatch1) {
    //                    Set<Id> parentaccntid = accounttoparentaccountmatch.get(originalsingleacc);     
    //                    originalsingleacc.parentid = new List<Id>(parentaccntid)[0];  
    //                    originalsingleacc.DuplicateDetectedforParentLookup__c = false;
    //                }  
    //                update AccountwithSingleMatch1; 
    //            }   
    //            if(!AccountwithMultipleMatch1.isEmpty()) {
    //                for(Account multiplematchacc : AccountwithMultipleMatch1) {
    //                    accountasmultiplematchesid.addall(accounttoparentaccountmatch.get(multiplematchacc));
    //                    multiplematchacc.DuplicateDetectedforParentLookup__c = true;
    //                    multiplematchacc.parentid = null;
    //                }
    //                update AccountwithMultipleMatch1;
    //            }
    //            Accountasmultiplematches = [SELECT Id, Potiential_Duplicate_via_DUNS__c FROM Account WHERE Id IN :accountasmultiplematchesid];
    //            if(!Accountasmultiplematches.isEmpty()) {
    //                for (Account accntmatch : Accountasmultiplematches) {
    //                    accntmatch.Potiential_Duplicate_via_DUNS__c = true;
    //                }
    //                update Accountasmultiplematches; 
    //            }               
    //        }
    //        if(!AccountswithoutDandB.isEmpty()) {
    //            for(Account accwithoutdandb : AccountswithoutDandB) {
    //                accwithoutdandb.DuplicateDetectedforParentLookup__c = false;   
    //            }  
    //            update AccountswithoutDandB;
    //        }
    //    }
    //}//if setrecursive
}