/**
*    Opportunity trigger logic for Before/After Insert/Update/Delete Events
*
*    Modification Log
*
*    Deepthi        PGI    11/06/2014      Opportunity trigger logic for Before/After Insert/Update/Delete 
**/
trigger OpportunityEvents on Opportunity (before insert, before update, before delete, after update) {
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            OpportunityEventHandler.validateRampDates(trigger.new);
        }
        else if(Trigger.isUpdate){
            OpportunityEventHandler.validateRampDates(trigger.new);
        }
    }
    
    Set<Id> opptyIds = new Set<Id>();
    Set<Id> contractIds = new Set<Id>();
    
    /*
    else if (Trigger.isAfter){
        if(Trigger.isUpdate){
            OpportunityEventHandler.setOpportunityScorecardFields(trigger.oldMap, trigger.newMap);
        }
    }*/
    
    //if(UserInfo.getName() == 'eCommerce Customer'){
    // || Opptydata.Z_Source__c == 'Salesgateway'
    if(Trigger.new != null){
        for(Opportunity Opptydata : trigger.new){
            if (Trigger.isAfter && Trigger.isUpdate) {
                if (Trigger.newMap.get(Opptydata.Id).StageName == 'Closed Won' && Trigger.oldMap.get(Opptydata.Id).StageName != 'Closed Won') {
                    opptyIds.add(Opptydata.Id);
                }
            }     
            if(Opptydata.Z_Source__c == 'eCommerce'){ 
                System.debug('z source test for salesgateway');
                if(!OpportunityEventHandler.skipExecution){
                    /* logic to update Opportunity on Before Insert events */
                    if(Trigger.isBefore && Trigger.isInsert){
                        OpportunityEventHandler.updateOpportunity(Trigger.new);
                        /* logic to createContracts on Opportunity updates */
                        OpportunityEventHandler.skipExecution = true;
                    }
                    /* logic for Opportunity on Before Delete events*/
                    if(Trigger.isBefore && Trigger.isDelete){
                        // Logic to delete License/Assets on opportunity deletion
                        OpportunityEventHandler.deleteOpporLicenses(Trigger.old);
                        
                        // Logic to delete LicenseSets on opportunity deletion
                        OpportunityEventHandler.deleteOpporLicenseSets(Trigger.old);
                        /* logic to createContracts on Opportunity updates */
                        OpportunityEventHandler.skipExecution = true;
                    }
                    /* logic to createContracts on Opportunity updates */
                    if(Trigger.isAfter && Trigger.isUpdate){
                       OpportunityEventHandler.createContracts(trigger.newMap, trigger.oldMap);
                       OpportunityEventHandler.mirrorOpportunityLineItemLicenseSet(trigger.oldMap, trigger.newMap);
                       /* logic to createContracts on Opportunity updates */
                       OpportunityEventHandler.skipExecution = true;
                    }
                    /* logic to createContracts on Opportunity updates */
                    //OpportunityEventHandler.skipExecution = true;
               }
            }
         }
        
        if(!opptyIds.isEmpty()){
            List<CONMAN_Contract__c> contractList = [SELECT Id, Opportunity__c, Contract_Source__c, OwnerId, Account_s_Agreement_Name__c, Service_Commencement_Date__c, Contracted_Term__c, Account_Name__r.Name, Related_Agreement__c FROM CONMAN_Contract__c WHERE Opportunity__c IN :opptyIds];
         
            Map<Id, CONMAN_Contract__c> contractMap = new Map<Id, CONMAN_Contract__c>();
            for (CONMAN_Contract__c contract : contractList) {
               contractMap.put(contract.Opportunity__c,contract);
            }
            // might need to update some contracts
            Map<Id, CONMAN_Contract__c> contractToUpdate = new Map<Id, CONMAN_Contract__c>();
                
            for (Opportunity newOpportunity : Trigger.new) {
                CONMAN_Contract__c contract;
                if (contractMap.containsKey(newOpportunity.Id))
                    contract = contractMap.get(newOpportunity.Id);
                else
                    continue; // No Contract to update, skip it
                if (Trigger.isAfter && Trigger.isUpdate) {
                    // Opportunities from iContract that are closed/Won
                    if(contract.Contract_Source__c == 'iContract'){
                        contract.Contract_Document_Status__c = 'Active';
                        contract.Sales_Ops_Status__c = 'Draft';
                        contract.Agreement_Sales_Rep__c = contract.OwnerId;
                        if(contract.Account_s_Agreement_Name__c != null && contract.Account_s_Agreement_Name__c != ''){
                            contract.Company_s_Name__c = contract.Account_s_Agreement_Name__c;
                        }else {
                            contract.Company_s_Name__c  = contract.Account_Name__r.Name;
                        }
                        contract.Auto_Renewal__c = true;
                        if (contract.Contracted_Term__c == null)
                            contract.Contracted_Term__c = 0;
                        contract.Auto_Renewal_Interval_months__c = contract.Contracted_Term__c;
                        if(contract.Related_Agreement__c != null){
                            contract.Final_Sign_Date__c = Date.today();
                            if(contract.Service_Commencement_Date__c == null){
                                contract.Service_Commencement_Date__c  = Date.today();
                            }    
                            contract.CEA_Date_Original__c = contract.Service_Commencement_Date__c.addMonths((Integer) contract.Contracted_Term__c).addDays(-1);
                        }  
                        contractToUpdate.put(contract.Id, contract);
                    }
                }
            }
            
            try {
                if (!contractToUpdate.isEmpty())
                    update contractToUpdate.values(); 
            } catch(Exception e) {
                String errormsg = iContract.formatException(e);
            }
        }
    }
}