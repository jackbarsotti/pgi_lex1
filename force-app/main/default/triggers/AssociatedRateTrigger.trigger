trigger AssociatedRateTrigger on Associated_Rate__c (after insert, after update) {
    // debugging puts information into a text field on the PGi Contract to know what was triggered
    boolean debug = false;

    // gather LicenseSet pricing and contract information
    Set<Id> licenseSetIds = new Set<Id>();
    Set<Id> rateIds = new Set<Id>();
    for (Associated_Rate__c newAssociatedRate : Trigger.new) {
        licenseSetIds.add(newAssociatedRate.LicenseSet__c);
        if (newAssociatedRate.Rate__c != null)
        	rateIds.add(newAssociatedRate.Rate__c);
    }
    Map<Id, LicenseSet__c> licenseSetMap = new Map<Id, LicenseSet__c>(
        [SELECT Id, PGi_Contract__c FROM LicenseSet__c WHERE Id IN :licenseSetIds]);
    Map<Id, Rate__c> rateMap = new Map<Id, Rate__c>(
        [SELECT Id, Description__c, Rate_Name__c, Recurrence__c, Type__c FROM Rate__c WHERE Id IN :rateIds]);

    // gather CONMAN_Contract__c status information
    Set<Id> contractIds = new Set<Id>();
    for (LicenseSet__c licenseSet : licenseSetMap.values()) {
        contractIds.add(licenseSet.PGi_Contract__c);
    }
    Map<Id, CONMAN_Contract__c> contractMap = new Map<Id, CONMAN_Contract__c>(
        [SELECT Id, Required_Approval_Billing__c, Quote_Additional_Notes__c FROM CONMAN_Contract__c
         WHERE Id IN :contractIds]);

    // might need to update some contracts
    Map<Id, CONMAN_Contract__c> contractToUpdate = new Map<Id, CONMAN_Contract__c>();

    for (Associated_Rate__c newAssociatedRate : Trigger.new) {
        String debugString = '';

        // skip discounts for licensed products
        if (newAssociatedRate.Rate_Name__c != null && newAssociatedRate.Rate_Name__c.contains('_discount_percentage'))
            continue;

        // fetch needed info early
        LicenseSet__c licenseSet;
        if (licenseSetMap.containsKey(newAssociatedRate.LicenseSet__c))
            licenseSet = licenseSetMap.get(newAssociatedRate.LicenseSet__c);
        else
            continue; // Master Detail, this is impossible but can cause errors anyway

        CONMAN_Contract__c contract;
        if (contractMap.containsKey(licenseSet.PGi_Contract__c))
            contract = contractMap.get(licenseSet.PGi_Contract__c);
        else
            continue; // No Contract to update, skip it

        Rate__c rate;
        if (rateMap.containsKey(newAssociatedRate.Rate__c))
            rate = rateMap.get(newAssociatedRate.Rate__c);

        // Custom Access Type Rates are not possible
        if (rate != null && rate.Type__c == 'Access')
            continue;

        // need to know if we changed the Contract
        boolean updated = false;

        // newly inserted without an existing Rate (custom)
        if (Trigger.isInsert && newAssociatedRate.Rate__c == null) {
            debugString += '\n ' + newAssociatedRate.Id + ' Inserting custom no-existing rate';
            contract.Required_Approval_Billing__c = true;
            updated = true;
        }

        // updating to no existing Rate
        if (Trigger.isUpdate && newAssociatedRate.Rate__c == null && Trigger.oldMap.get(newAssociatedRate.Id).Rate__c != null) {
            debugString += '\n ' + newAssociatedRate.Id + ' Updating to no-existing rate';
            contract.Required_Approval_Billing__c = true;
            updated = true;
        }

        // updating name no existing Rate
        if (Trigger.isUpdate && newAssociatedRate.Rate__c == null && Trigger.oldMap.get(newAssociatedRate.Id).Rate_Name__c != newAssociatedRate.Rate_Name__c) {
            debugString += '\n ' + newAssociatedRate.Id + ' Updating no-existing rate name';
            contract.Required_Approval_Billing__c = true;
            updated = true;
        }

        // updating description no existing Rate
        if (Trigger.isUpdate && newAssociatedRate.Rate__c == null && Trigger.oldMap.get(newAssociatedRate.Id).Description__c != newAssociatedRate.Description__c) {
            debugString += '\n ' + newAssociatedRate.Id + ' Updating no-existing rate description';
            contract.Required_Approval_Billing__c = true;
            updated = true;
        }

        // updating recurrence no existing Rate
        if (Trigger.isUpdate && newAssociatedRate.Rate__c == null && Trigger.oldMap.get(newAssociatedRate.Id).Recurrence__c != newAssociatedRate.Recurrence__c) {
            debugString += '\n ' + newAssociatedRate.Id + ' Updating no-existing rate recurrence';
            contract.Required_Approval_Billing__c = true;
            updated = true;
        }

        if (newAssociatedRate.Rate__c != null && rate != null) {
            // newly inserted with custom name
            /*if (Trigger.isInsert && newAssociatedRate.Rate_Name__c != rate.Rate_Name__c) {
            	debugString += '\n ' + newAssociatedRate.Id + ' Inserting rate custom name';
                contract.Required_Approval_Billing__c = true;
                updated = true;
            }*/

            // update with custom name
            if (Trigger.isUpdate && newAssociatedRate.Rate_Name__c != rate.Rate_Name__c && Trigger.oldMap.get(newAssociatedRate.Id).Rate_Name__c != newAssociatedRate.Rate_Name__c) {
            	debugString += '\n ' + newAssociatedRate.Id + ' Updating rate custom name';
                contract.Required_Approval_Billing__c = true;
                updated = true;
            }

            // newly inserted with custom description
            /*if (Trigger.isInsert && newAssociatedRate.Description__c != rate.Description__c) {
            	debugString += '\n ' + newAssociatedRate.Id + ' Inserting rate custom description';
                contract.Required_Approval_Billing__c = true;
                updated = true;
            }*/

            // update with custom description
            if (Trigger.isUpdate && newAssociatedRate.Description__c != rate.Description__c && Trigger.oldMap.get(newAssociatedRate.Id).Description__c != newAssociatedRate.Description__c) {
            	debugString += '\n ' + newAssociatedRate.Id + ' Updating rate custom name';
                contract.Required_Approval_Billing__c = true;
                updated = true;
            }

            // newly inserted with custom recurrence
            /*if (Trigger.isInsert && newAssociatedRate.Recurrence__c != rate.Recurrence__c && newAssociatedRate.Recurrence__c != 'Waived') {
            	debugString += '\n ' + newAssociatedRate.Id + ' Inserting rate custom recurrence';
                contract.Required_Approval_Billing__c = true;
                updated = true;
			}*/

            // update with custom recurrence
            if (Trigger.isUpdate && newAssociatedRate.Recurrence__c != rate.Recurrence__c && Trigger.oldMap.get(newAssociatedRate.Id).Recurrence__c != newAssociatedRate.Recurrence__c && newAssociatedRate.Recurrence__c != 'Waived') {
            	debugString += '\n ' + newAssociatedRate.Id + ' Updating rate custom recurrence';
                contract.Required_Approval_Billing__c = true;
                updated = true;
            }
        }

        // store the debug information
        if (updated && debug)
            contract.Quote_Additional_Notes__c += debugString;

        // update the contract if necessary
        if (updated)
            contractToUpdate.put(contract.Id, contract);
    }

    if (!contractToUpdate.isEmpty())
    	update contractToUpdate.values();
}