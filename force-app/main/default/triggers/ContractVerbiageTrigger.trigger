trigger ContractVerbiageTrigger on CONMAN_Contract_Verbiage__c (before insert, before update) {
    // debugging puts information into a text field on the PGi Contract to know what was triggered
    boolean debug = false;
    
    // gather verbiage and contract information
    Set<Id> generalVerbiageIds = new Set<Id>();
    Set<Id> productVerbiageIds = new Set<Id>();
    Set<Id> contractIds = new Set<Id>();
    for (CONMAN_Contract_Verbiage__c newVerbiage : Trigger.new) {
        contractIds.add(newVerbiage.PGi_Contract__c);
        if (newVerbiage.Contract_General_Content__c != null)
        	generalVerbiageIds.add(newVerbiage.Contract_General_Content__c);
        if (newVerbiage.Contract_Product_Verbiage__c != null)
        	productVerbiageIds.add(newVerbiage.Contract_Product_Verbiage__c);
    }
    Map<Id, PGIServicesInformation__c> generalVerbiageMap = new Map<Id, PGIServicesInformation__c>(
        [SELECT Id, Content_RTF__c FROM PGIServicesInformation__c WHERE Id IN :generalVerbiageIds]);
    Map<Id, Contract_Terms__c> productVerbiageMap = new Map<Id, Contract_Terms__c>(
        [SELECT Id, Terms_and_Conditions_RTF__c FROM Contract_Terms__c WHERE Id IN :productVerbiageIds]);
    Map<Id, CONMAN_Contract__c> contractMap = new Map<Id, CONMAN_Contract__c>(
        [SELECT Id, Required_Approval_Billing__c, Quote_Additional_Notes__c FROM CONMAN_Contract__c
         WHERE Id IN :contractIds]);

    // might need to update some contracts
    Map<Id, CONMAN_Contract__c> contractToUpdate = new Map<Id, CONMAN_Contract__c>();
    Map<Id, CONMAN_Contract_Verbiage__c> contractVerbiageToUpdate = new Map<Id, CONMAN_Contract_Verbiage__c>();

    for (CONMAN_Contract_Verbiage__c newVerbiage : Trigger.new) {
        String debugString = '';
        
        CONMAN_Contract__c contract;
        if (contractMap.containsKey(newVerbiage.PGi_Contract__c))
            contract = contractMap.get(newVerbiage.PGi_Contract__c);
        else
            continue; // Master Detail, this is impossible but can cause errors anyway
        
        PGIServicesInformation__c generalVerbiage;
        if (generalVerbiageMap.containsKey(newVerbiage.Contract_General_Content__c))
            generalVerbiage = generalVerbiageMap.get(newVerbiage.Contract_General_Content__c);
        
        Contract_Terms__c productVerbiage;
        if (productVerbiageMap.containsKey(newVerbiage.Contract_Product_Verbiage__c))
            productVerbiage = productVerbiageMap.get(newVerbiage.Contract_Product_Verbiage__c);
        
        // need to know if we changed the Contract
        boolean updated = false;
        
        // newly inserted without an existing verbiage (custom)
        if (Trigger.isInsert && newVerbiage.Contract_General_Content__c == null && newVerbiage.Contract_Product_Verbiage__c == null) {
            debugString += '\n ' + newVerbiage.Id + ' Inserting custom no-existing verbiage';
            contract.Required_Approval_Billing__c = true;
            newVerbiage.Modified__c = true;
            updated = true;
        }
        
        // updating to no existing verbiage
        if (Trigger.isUpdate &&
            ((newVerbiage.Contract_General_Content__c == null && Trigger.oldMap.get(newVerbiage.Id).Contract_General_Content__c != null) ||
             (newVerbiage.Contract_Product_Verbiage__c == null && Trigger.oldMap.get(newVerbiage.Id).Contract_Product_Verbiage__c != null))) {
                 debugString += '\n ' + newVerbiage.Id + ' Updating to no-existing verbiage';
                 contract.Required_Approval_Billing__c = true;
                 newVerbiage.Modified__c = true;
                 updated = true;
             }
        
        // updating without an existing verbiage (custom)
        if (Trigger.isUpdate && newVerbiage.Contract_General_Content__c == null && newVerbiage.Contract_Product_Verbiage__c == null &&
            newVerbiage.Verbiage__c != Trigger.oldMap.get(newVerbiage.Id).Verbiage__c) {
                debugString += '\n ' + newVerbiage.Id + ' Updating custom no-existing verbiage';
                contract.Required_Approval_Billing__c = true;
                newVerbiage.Modified__c = true;
                updated = true;
            }
        
        // Services & Pricing Schedule Billing Footnotes
        if (Trigger.isUpdate && newVerbiage.Name != null && newVerbiage.Name.contains('Services & Pricing Schedule Billing Footnotes') &&
            newVerbiage.Verbiage__c != Trigger.oldMap.get(newVerbiage.Id).Verbiage__c &&
            newVerbiage.Contract_General_Content__c == null) {
                debugString += '\n ' + newVerbiage.Id + ' Updating Billing Footnotes verbiage';
                contract.Required_Approval_Billing__c = true;
                newVerbiage.Modified__c = true;
                updated = true;    
            }
        if (Trigger.isUpdate && newVerbiage.Name != null && newVerbiage.Name.contains('Services & Pricing Schedule Billing Footnotes') &&
            newVerbiage.Verbiage__c != Trigger.oldMap.get(newVerbiage.Id).Verbiage__c &&
            newVerbiage.Contract_General_Content__c != null &&
            newVerbiage.Verbiage__c != generalVerbiage.Content_RTF__c) {
                debugString += '\n ' + newVerbiage.Id + ' Updating Billing Footnotes verbiage';
                contract.Required_Approval_Billing__c = true;
                newVerbiage.Modified__c = true;
                updated = true;    
            }
        
        // General Content for Pricing Team
        if (newVerbiage.Contract_General_Content__c != null && generalVerbiage != null && newVerbiage.Pricing_Team_Changes_Allowed__c == true) {
            // newly inserted with custom verbiage (min commit inserts as custom)
            if (Trigger.isInsert && newVerbiage.Verbiage__c != generalVerbiage.Content_RTF__c && newVerbiage.Name != 'Minimum Commitment') {
                debugString += '\n ' + newVerbiage.Id + ' Inserting general verbiage Pricing-capable custom verbiage';
                //contract.Required_Approval_Billing__c = true;
                newVerbiage.Modified__c = true;
                updated = true;
            }
            
            // updated with custom verbiage
            if (Trigger.isUpdate && newVerbiage.Verbiage__c != generalVerbiage.Content_RTF__c && newVerbiage.Verbiage__c != Trigger.oldMap.get(newVerbiage.Id).Verbiage__c) {
                debugString += '\n ' + newVerbiage.Id + ' Updating general verbiage Pricing-capable custom verbiage';
                contract.Required_Approval_Billing__c = true;
                newVerbiage.Modified__c = true;
                updated = true;
            }
        }
        
        // Product Verbiage for Pricing Team
        if (newVerbiage.Contract_Product_Verbiage__c != null && productVerbiage != null && newVerbiage.Pricing_Team_Changes_Allowed__c == true) {
            // newly inserted with custom verbiage
            if (Trigger.isInsert && newVerbiage.Verbiage__c != productVerbiage.Terms_and_Conditions_RTF__c) {
                debugString += '\n ' + newVerbiage.Id + ' Inserting product verbiage Pricing-capable custom verbiage';
                //contract.Required_Approval_Billing__c = true;
                newVerbiage.Modified__c = true;
                updated = true;
            }
            
            // updated with custom verbiage
            if (Trigger.isUpdate && newVerbiage.Verbiage__c != productVerbiage.Terms_and_Conditions_RTF__c && newVerbiage.Verbiage__c != Trigger.oldMap.get(newVerbiage.Id).Verbiage__c) {
                debugString += '\n ' + newVerbiage.Id + ' Updating product verbiage Pricing-capable custom verbiage';
                contract.Required_Approval_Billing__c = true;
                newVerbiage.Modified__c = true;
                updated = true;
            }
        }
        
        // General Content for Legal Team (flags modified, but not billing)
        if (newVerbiage.Contract_General_Content__c != null && generalVerbiage != null && newVerbiage.Pricing_Team_Changes_Allowed__c == false) {
            // newly inserted with custom verbiage
            if (Trigger.isInsert && newVerbiage.Verbiage__c != generalVerbiage.Content_RTF__c) {
                debugString += '\n ' + newVerbiage.Id + ' Inserting general verbiage non-Pricing-capable custom verbiage (no billing)';
                newVerbiage.Modified__c = true;
            }
            
            // updated with custom verbiage
            if (Trigger.isUpdate && newVerbiage.Verbiage__c != generalVerbiage.Content_RTF__c && newVerbiage.Verbiage__c != Trigger.oldMap.get(newVerbiage.Id).Verbiage__c) {
                debugString += '\n ' + newVerbiage.Id + ' Updating general verbiage non-Pricing-capable custom verbiage (no billing)';
                newVerbiage.Modified__c = true;
            }
        }
        
        // Product Verbiage for Legal Team (flags modified, but not billing)
        if (newVerbiage.Contract_Product_Verbiage__c != null && productVerbiage != null && newVerbiage.Pricing_Team_Changes_Allowed__c == false) {
            // newly inserted with custom verbiage
            if (Trigger.isInsert && newVerbiage.Verbiage__c != productVerbiage.Terms_and_Conditions_RTF__c) {
                debugString += '\n ' + newVerbiage.Id + ' Inserting product verbiage non-Pricing-capable custom verbiage (no billing)';
                newVerbiage.Modified__c = true;
            }
            
            // updated with custom verbiage
            if (Trigger.isUpdate && newVerbiage.Verbiage__c != productVerbiage.Terms_and_Conditions_RTF__c && newVerbiage.Verbiage__c != Trigger.oldMap.get(newVerbiage.Id).Verbiage__c) {
                debugString += '\n ' + newVerbiage.Id + ' Updating product verbiage non-Pricing-capable custom verbiage (no billing)';
                newVerbiage.Modified__c = true;
            }
        }
        
        // store the debug information
        if (updated && debug)
            contract.Quote_Additional_Notes__c += debugString;
        
        // update the contract if necessary
        if (updated && contract.Required_Approval_Billing__c == true)
            contractToUpdate.put(contract.Id, contract);
    }

    if (!contractToUpdate.isEmpty())
    	update contractToUpdate.values();
}