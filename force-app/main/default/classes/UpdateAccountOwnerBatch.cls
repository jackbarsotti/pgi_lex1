/*******************************************************************************************
Name : UpdateAccountOwnerBatch

Description : Batch Apex to update Account Owner based on Client Count and Billed Revenue 
********************************************************************************************/
global class UpdateAccountOwnerBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {   
        String query = 'Select Id, OwnerId ' +
                       ' from Account where Exclude_from_Integration__c = false AND Status__c = \'Customer\'';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> accountList) {   
		system.assert(accountList.size() == 1, 'Must run 1 at a time');
        //Omit the company record if the Primary Sales Rep field is related to an inactive user (don’t take into consideration)
        //Omit the Account from being updated if the Account field “Exclude from Integration” is marked TRUE
		List<Account> toUpdate = new List<Account>();
        
        for (Account acct : accountList) {
            List<PGi_Company__c> companyList = [SELECT Id, PrimarySalesRep__c, Add_Date__c, Active_Clients__c, Inactive_Date__c, Last_13_Months_Billed_Revenue__c FROM PGi_Company__c WHERE PrimarySalesRep__r.IsActive = true AND PrimarySalesRep__c != null AND Inactive_Date__c = null AND RelatedAccount__c  IN: accountList];
            PGi_Company__c useThisCompany = null;
            //a.      If just one company record then set ownership directly from it.
            if(companyList.size() == 1) {
                useThisCompany = companyList[0];
            } else if (companyList.size() > 1) { 
                Decimal maxRevenue = null;
                
            //If more than one company,
                //1) look at record with the highest “Billed Revenue - Past 13 Months” value and the “Inactive Date” is blank and set the owner
                //2) If the records have the same Billed Revenue - Past 13 Months, then select the one with the highest “Active Clients” value where “Inactive Date” is blank and set the owner. 
                //3) If the records have the same Billed Revenue - Past 13 Months and have the same number of Active Clients, then select the one with the oldest “Add Date” (ie: oldest Company) where “Inactive Date” is blank and set the owner. 
                Map<Decimal, List<PGi_Company__c>> revenueToPGICompany = new Map<Decimal, List<PGi_Company__c>>();
                
                for(PGi_Company__c comp : companyList) {
                    List<PGi_Company__c> revCompanyList = revenueToPGICompany.get(comp.Last_13_Months_Billed_Revenue__c) == null ? new List<PGi_Company__c>() : revenueToPGICompany.get(comp.Last_13_Months_Billed_Revenue__c);
                    revCompanyList.add(comp);
                    revenueToPGICompany.put(comp.Last_13_Months_Billed_Revenue__c, revCompanyList);
                    maxRevenue = (comp.Last_13_Months_Billed_Revenue__c > maxRevenue || maxRevenue == null) ? comp.Last_13_Months_Billed_Revenue__c : maxRevenue;
                }
                if(revenueToPGICompany.get(maxRevenue) != null && revenueToPGICompany.get(maxRevenue).size() == 1) {
                    useThisCompany = revenueToPGICompany.get(maxRevenue)[0];
                } else if(revenueToPGICompany.get(maxRevenue) != null && revenueToPGICompany.get(maxRevenue).size() > 1) {
                    //2) If the records have the same Billed Revenue - Past 13 Months, then select the one with the highest “Active Clients” value where “Inactive Date” is blank and set the owner. 
                    Decimal maxClient = null;
                    for(PGi_Company__c comp : revenueToPGICompany.get(maxRevenue)) {
                        if(comp.Active_Clients__c == maxClient && useThisCompany != null) {
                            if(comp.Add_Date__c < useThisCompany.Add_Date__c) {
                                useThisCompany = comp; //3) If the records have the same Billed Revenue - Past 13 Months and have the same number of Active Clients, then select the one with the oldest “Add Date” (ie: oldest Company) where “Inactive Date” is blank and set the owner. 
                            }
                        } else if (comp.Active_Clients__c > maxClient || maxClient == null) {
                            maxClient = comp.Active_Clients__c;
                            useThisCompany = comp;
                        }
                    }
                }
            }
            if(useThisCompany != null && acct.OwnerId != useThisCompany.PrimarySalesRep__c) {
                acct.OwnerId = useThisCompany.PrimarySalesRep__c;
                toUpdate.add(acct);
                System.debug(acct.OwnerId);
            }
        }
        update toUpdate;
    }       
    global void finish(Database.BatchableContext BC) {
        
    }    
}