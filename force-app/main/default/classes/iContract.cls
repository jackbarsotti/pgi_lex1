/* Helper class containing common functions for use in iContract */
public class iContract {
    public static String SUCCESS = 'success';
    public static String UNNECESSARY = 'unnecessary';

    public static CONMAN_Contract__c getContract(Id contractId) {
        return [SELECT Contract_Type__c, PGi_Internal_Entity__c, Contract_Status__c, Account_Name__r.Name, Contract_URL__c, Language__c, Opportunity__c, Contracted_Commit_Frequency__c, Contracted_Term__c, Intl_Order_Type__c, CurrencyIsoCode, Is_Related_to_SLO_MSA__c
                FROM CONMAN_Contract__c 
                WHERE Id = :contractId];
    }
    public static Contact getContactData(String oppId) {
        OpportunityContactRole contactData;
        try{
            OpportunityContactRole oppContact = [SELECT ContactId FROM OpportunityContactRole
                                             where OpportunityId =:oppId and IsPrimary = true limit 1];
            contactData = oppContact;
        }catch(Exception e){

        }
        try{
            OpportunityContactRole agreementContact = [SELECT ContactId FROM OpportunityContactRole
                                             where OpportunityId =:oppId and Role = 'Agreement Signer' limit 1];
            contactData = agreementContact;
        }catch(Exception e){

        }
        if(contactData != null){
            return [SELECT id, Company_Name__c, Email, Title, FirstName, LastName, MailingCountry,
                MailingPostalCode, MailingState, MailingCity, MailingStreet, Phone, Fax, AccountId, Account.Name
                FROM Contact where id = :contactData.ContactId ];
        }else{
            return null;
        }

    }

    public static void addRemoveDefaultVerbiage(Id contractId) {
        CONMAN_Contract__c contractOppty = getContract(contractId);
        
        // Need Contact Info for Region
        Contact contactInfo;
        try { contactInfo = getContactData(contractOppty.Opportunity__c); }
        catch (Exception e) { System.debug(e.getMessage()); }
        if (contactInfo == null)
            return;

        String region  = CountryUtil.getCountryRegion(contactInfo.MailingCountry);
        System.debug('REGION -->' + region);
        if(region == '' ){
            region = 'US';
        }
        // Find Verbiage to add to the PGi Contract
        List<PGIServicesInformation__c> verbs =
            [SELECT Id, PGi_Internal_Entity__c, Name, Header__c, Show_Header__c, Content_RTF__c, Order__c, Unique_ID__c, Language__c, Intl_Order_Type__c, 
                        Auto_Add_Verbiage__c, Auto_Add_Region__c, Auto_Add_Product_Family__c, Specific_Product_Family_Usage__c
                    FROM PGIServicesInformation__c 
                    WHERE Active__c = TRUE 
                    AND For_SLO_MSA__c =: contractOppty.Is_Related_to_SLO_MSA__c
                    AND Agreement_Type__c INCLUDES(:contractOppty.Contract_Type__c) 
                    AND Region__c INCLUDES(:region) 
                    AND Name != 'Minimum Commitment' 
                    AND Language__c =: contractOppty.Language__c
                    
                    ORDER BY Order__c ASC];
        if (verbs.size() <= 0) {
            throw new iContractException('Could not query all of the required default Contract Verbiage: ' +
                                         verbs.size() + ' <= 0');
        }
        
        // Find the "extra" Verbiage that doesn't need to be there...
        // ...man, do I hate these quick+dirty workarounds for ASAP "emergencies"
        // boolean hasUCaaS = [SELECT Id 
        //                     FROM LicenseSet__c 
        //                     WHERE PGi_Contract__c = :contractId 
        //                     AND Enterprise_Name__r.Family__c INCLUDES ('UCaaS')].size() > 0;
        List<LicenseSet__c> licenseSets = [SELECT Id, Enterprise_Name__r.Family__c
                            FROM LicenseSet__c 
                            WHERE PGi_Contract__c = :contractId]; 
        Set<String> contractsProductFamilies = new Set<String>();
        for(LicenseSet__c ls: licenseSets) {
            contractsProductFamilies.add(ls.Enterprise_Name__r.Family__c);
        }
        Boolean hasUCaaS = contractsProductFamilies.contains('UCaaS');
        contractsProductFamilies.remove('');
        contractsProductFamilies.remove(null);

        boolean isNewAgreement = contractOppty.Contract_Type__c == 'Subscription License Order' || contractOppty.Contract_Type__c == 'Subscription License Agreement';
        PGIServicesInformation__c badVerb = null;
        for (PGIServicesInformation__c verb : verbs) {
            if (hasUCaaS && isNewAgreement) {
                if (verb.Unique_ID__c == 'SRT iContract SLO ENG' || verb.Unique_ID__c == 'SRT iContract SLA ENG') {
                    badVerb = verb;
                    break;
                }
            } else {
                if (verb.Unique_ID__c == 'SRT iContract SLO ENG UC' || verb.Unique_ID__c == 'SRT iContract SLA ENG UC') {
                    badVerb = verb;
                    break;
                }
            }
            
        }
        if (badVerb != null)
            verbs.remove(verbs.indexOf(badVerb));

        // Find Verbiage already added to the PGi Contract
        List<CONMAN_Contract_Verbiage__c> existingContVerbs = [SELECT Id, Name, Language__c, Contract_General_Content__c, Contract_General_Content__r.Specific_Product_Family_Usage__c
                                                                FROM CONMAN_Contract_Verbiage__c 
                                                                WHERE Contract_General_Content__c != NULL 
                                                                AND PGi_Contract__c = :contractId
                                                                ];
        // Find Existing Verbiage that should no longer exist
        List<CONMAN_Contract_Verbiage__c> deleteContVerbs = new List<CONMAN_Contract_Verbiage__c>();
        for (CONMAN_Contract_Verbiage__c contVerb : existingContVerbs) {
            if(contVerb.Id == 'a1BK0000006RcpO') {
                System.debug('THIS IS IT');
                // System.debug(contVerb);
            }
            System.debug('iterating and purging existing');
            boolean shouldDelete = true;
           
            if(contVerb.Language__c == contractOppty.Language__c) {
                for (PGIServicesInformation__c verb : verbs) {
                    
                    // Always replace Term SG since the Agreement Term is dynamically inside of it
                    if(contVerb.Contract_General_Content__c == verb.Id) {
                        Boolean familyMatch = matchesProductFamily(verb, contractsProductFamilies);
                        if(region == 'APAC' && contractOppty.PGi_Internal_Entity__c != verb.PGI_Internal_Entity__c) {
                            break; //non matching legal entity on PGI APAC contract
                        }
                        if(familyMatch && verb.Name != 'Term SG') {
                            shouldDelete = false;
                            break;
                        }
                        if(verb.Name == 'Term SG') {
                            break;
                        } else if (verb.Language__c != contVerb.Language__c) {
                            break;
                        } else if (verb.Auto_Add_Verbiage__c) {
                            shouldDelete = !shouldAutoAdd(verb, contractsProductFamilies, region);
                        } else {
                            shouldDelete = false;
                            break;
                        }
                        
                    }
                }
            }

            if (shouldDelete) {
                deleteContVerbs.add(contVerb);
            }
        }
        DELETE deleteContVerbs;

        // Create New Verbiage
        List<CONMAN_Contract_Verbiage__c> newContVerbs = new List<CONMAN_Contract_Verbiage__c>();
        for (PGIServicesInformation__c verb : verbs) {
            System.debug('adding net new' + verb.Id);
            boolean shouldInsert = true;
            if(region == 'APAC' && contractOppty.PGi_Internal_Entity__c != verb.PGI_Internal_Entity__c) {
                shouldInsert = false;
            } else {
                if (verb.Auto_Add_Verbiage__c) {
                    shouldInsert = shouldAutoAdd(verb, contractsProductFamilies, region);
                }
                if(shouldInsert) {
                    shouldInsert = matchesProductFamily(verb, contractsProductFamilies);
                    
                }
                for (CONMAN_Contract_Verbiage__c contVerb : existingContVerbs) {
                    if (contVerb.Name == verb.Name && verb.Name != 'Term SG') {
                        shouldInsert = false;
                        break;
                    } 
                    
                }
            }
            if (shouldInsert) {
                CONMAN_Contract_Verbiage__c contVerb = new CONMAN_Contract_Verbiage__c(PGi_Contract__c = contractId);
                contVerb.Name = verb.Name;
                contVerb.Intl_Order_Type__c = verb.Intl_Order_Type__c;
                contVerb.Approved__c = true;
                contVerb.Contract_General_Content__c = verb.Id;
                contVerb.Pricing_Team_Changes_Allowed__c = false;
                contVerb.Verbiage__c = verb.Content_RTF__c;
                contVerb.Order__c = verb.Order__c;
                contVerb.Show_Verbiage_Header__c = verb.show_Header__c;
                contVerb.Verbiage_Header__c = verb.Header__c;
                contVerb.Language__c = verb.Language__c;
                newContVerbs.add(contVerb);
            }
        }
        insert newContVerbs;
    }
    // method to check if the Product family matches or not
    public static Boolean matchesProductFamily(PGIServicesInformation__c verb, Set<String> contractsProductFamilies) {
        Boolean matches = true;
        String strcontractsProductFamilies ='';
        if(String.isNotBlank(verb.Specific_Product_Family_Usage__c)){
            
            for(String strFamily : contractsProductFamilies){
                strcontractsProductFamilies += strFamily+' ';
            }
            String familyUsageInVerb = verb.Specific_Product_Family_Usage__c;
            LIst<String> filterFamily = familyUsageInVerb.split(';');
            Boolean hasFamilyMatch = false;
            for(String str : filterFamily){
                if(strcontractsProductFamilies.Contains(str)){
                    hasFamilyMatch = true;
               } 
            } 
            if(!hasFamilyMatch) {
                matches = false;
            } else {
                matches = true;
            }
        }
        return matches;
    }
    public static Boolean shouldAutoAdd(PGIServicesInformation__c verb, Set<String> contractsProductFamilies, String region) {
        Boolean inScope = false;
        if (verb.Auto_Add_Verbiage__c) {
            if(String.isNotBlank(verb.Auto_Add_Region__c) && verb.Auto_Add_Region__c.contains(region)) {
                List<String> familiesInScope = new List<String>(); 
                if(String.isNotBlank(verb.Auto_Add_Product_Family__c) && verb.Auto_Add_Product_Family__c.contains(';')) {
                    familiesInScope = verb.Auto_Add_Product_Family__c.split(';');
                } else {
                    familiesInScope.add(verb.Auto_Add_Product_Family__c);
                }
                for(String family: familiesInScope) {
                    if(contractsProductFamilies.contains(family)) {
                        inScope = true;
                    }
                }
            }
        }
        return inScope;
    }
    public static void addRemoveMinCommitVerbiage(Id contractId, List<Associated_Rate__c> associatedRates) {
        Set<Id> rateIds = new Set<Id>();
        for (Associated_Rate__c ar : associatedRates) {
            if (ar.Rate__c != null)
                rateIds.add(ar.Rate__c);
        }

        Map<Id, Rate__c> rates = new Map<Id, Rate__c>([SELECT Id FROM Rate__c WHERE Id IN :rateIds AND Type__c = 'Commit']);
        CONMAN_Contract__c contract = getContract(contractId);

        String currencyLabel = '';
        Decimal commitAmount = 0.0;
        String recurrence = formatTimeRecurrence(contract.Contracted_Commit_Frequency__c);
        Boolean hasMinCommit = false;

        for (Associated_Rate__c ar : associatedRates) {
            if (ar.Rate__c == null || !rates.containsKey(ar.Rate__c)){
                continue;
            }

            hasMinCommit = true;
            if (String.isEmpty(currencyLabel)) {
                currencyLabel = ar.CurrencyIsoCode;
            }

            commitAmount += ar.Override__c;
        }

        DELETE [SELECT Id FROM CONMAN_Contract_Verbiage__c 
                WHERE PGi_Contract__c = :contractId 
                AND Name = 'Minimum Commitment'];

        if (hasMinCommit && recurrence != null && !String.isEmpty(recurrence) && commitAmount > 0.0) {
            PGIServicesInformation__c minCommit = [SELECT Id, Name, Content_RTF__c, Header__c, PGi_Internal_Entity__c, Language__c, Order__c, Intl_Order_Type__c
                                                    FROM PGIServicesInformation__c 
                                                    WHERE Name = 'Minimum Commitment'
                                                    AND Language__c =: contract.Language__c];
            minCommit.Content_RTF__c = minCommit.Content_RTF__c.replace('[CommitmentAmount]', currencyLabel + ' ' + commitAmount.setScale(2));
            minCommit.Content_RTF__c = minCommit.Content_RTF__c.replace('[Reoccurence]', recurrence);

            CONMAN_Contract_Verbiage__c thisMinCommit = new CONMAN_Contract_Verbiage__c(PGi_Contract__c = contractId);
            thisMinCommit.Name = minCommit.Name;
            thisMinCommit.Intl_Order_Type__c = minCommit.Intl_Order_Type__c;
            thisMinCommit.Approved__c = true;
            thisMinCommit.Pricing_Team_Changes_Allowed__c = true;
            thisMinCommit.Contract_General_Content__c = minCommit.Id;
            thisMinCommit.Verbiage__c = minCommit.Content_RTF__c;
            thisMinCommit.Verbiage_Header__c = minCommit.Header__c;
            thisMinCommit.Order__c = minCommit.Order__c;
            thisMinCommit.Language__c = minCommit.Language__c;
            INSERT thisMinCommit;

            contract.New_Minimum_Commitment__c = currencyLabel + ' ' + commitAmount.setScale(2) + ' / ' + recurrence + ' for ' + formatTimeRange(contract.Contracted_Term__c);
            if(String.isBlank(contract.Intl_Order_Type__c)) {
                contract.Intl_Order_Type__c = 'Long Form';
            }
            UPDATE contract;
        }
    }
    public static void handleTerms(Id contractId) {
        Set<Id> offeringIds = new Set<Id>();
        Set<Id> licenseSetIds = new Set<Id>();
        List<LicenseSet__c> LSs = [SELECT Id, Enterprise_Name__c, Enterprise_Name__r.Require_Rates_to_Add_Terms__c, (SELECT Id FROM Associated_Rates__r) FROM LicenseSet__c WHERE PGi_Contract__c = :contractId];
        for (LicenseSet__c ls : LSs) {
            if (ls.Enterprise_Name__c != null) {
                if(ls.Enterprise_Name__r.Require_Rates_to_Add_Terms__c && ls.Associated_Rates__r != null && ls.Associated_Rates__r.size() > 0) {
                    licenseSetIds.add(ls.Id);
                    offeringIds.add(ls.Enterprise_Name__c);
                } else if (!ls.Enterprise_Name__r.Require_Rates_To_Add_Terms__c) {
                    licenseSetIds.add(ls.Id);
                    offeringIds.add(ls.Enterprise_Name__c);
                }
            }
        }
        List<Associated_Rate__c> ARs = [SELECT Id, Override__c, Rate__c, CurrencyIsoCode FROM Associated_Rate__c WHERE LicenseSet__c IN :licenseSetIds];
        if (contractId != null) {
            iContract.addRemoveDefaultVerbiage(contractId);
            iContract.addRemoveVerbiageForOffering(contractId, offeringIds);
            iContract.addRemoveMinCommitVerbiage(contractId, ARs);
            iContract.addRemoveCGC(contractId);
        }
    }
    public static void addRemoveVerbiageForOffering(Id contractId, Set<Id> offeringIds) {
        CONMAN_Contract__c theContract = getContract(contractId);
        // Need Contact Info for Region
        Contact contactInfo;
        try { contactInfo = getContactData(theContract.Opportunity__c); }
        catch (Exception e) { System.debug(e.getMessage()); }
        if (contactInfo == null)
            return;

        String region  = CountryUtil.getCountryRegion(contactInfo.MailingCountry);
        if(region == '' ){
            region = 'US';
        }
        
        // Find Verbiage to add
        List<Offerings_Contract_Term__c> verbs =
            [SELECT Id, Contract_General_Content__r.Name, Contract_General_Content__r.PGI_Internal_Entity__c, Contract_General_Content__r.Terms_and_Conditions_RTF__c, Contract_General_Content__r.Language__c, Offerings__r.Require_Rates_To_Add_Terms__c, Contract_General_Content__r.CurrencyIsoCode, Require_Currency_Match__c
             FROM Offerings_Contract_Term__c
             WHERE Offerings__c IN :offeringIds 
             AND Agreement_Type__c INCLUDES(:theContract.Contract_Type__c)
             AND Contract_General_Content__r.Language__c =: theContract.Language__c
             ORDER BY Offerings__r.Order__c ASC NULLS FIRST, Offerings__r.Product_Name__c ASC NULLS FIRST,
             Order__c ASC NULLS FIRST];
        // Find Existing Verbiage and add them afterwards in order
        Decimal currentOrder = 0;
        Set<String> existingVerbNames = new Set<String>();
        List<CONMAN_Contract_Verbiage__c> existingVerbs = [SELECT Name, Order__c, Language__c, Contract_General_Content__r.PGI_Internal_Entity__c
                                                            FROM CONMAN_Contract_Verbiage__c 
                                                            WHERE Contract_Product_Verbiage__c != null 
                                                            AND PGi_Contract__c = :contractId 
                                                            AND Name != 'Minimum Commitment'];
        for (CONMAN_Contract_Verbiage__c existingVerb : existingVerbs) {
            existingVerbNames.add(existingVerb.Name);
            if (existingVerb.Order__c >= currentOrder)
                currentOrder = existingVerb.Order__c + 1;
        }

        // Find Existing Verbiage that should no longer exist
        List<CONMAN_Contract_Verbiage__c> deleteVerbs = new List<CONMAN_Contract_Verbiage__c>();
        for (CONMAN_Contract_Verbiage__c contVerb : existingVerbs) {
            boolean shouldDelete = true;
            if(contVerb.Language__c == theContract.Language__c) {
                for (Offerings_Contract_Term__c verb : verbs) {
                    System.debug('verb  --> '+ verb.Id);
                    if(region == 'APAC' && theContract.PGi_Internal_Entity__c != contVerb.Contract_General_Content__r.PGI_Internal_Entity__c) {
                        break;
                    } 
                    if (contVerb.Name == verb.Contract_General_Content__r.Name &&
                        contVerb.Language__c == theContract.Language__c) {
                        shouldDelete = false;
                        break;
                    }
                }
            }

            if (shouldDelete) {
                deleteVerbs.add(contVerb);
            	existingVerbNames.remove(contVerb.Name);
            }
        }
        delete deleteVerbs;

        // Find New Verbiage to add
        List<CONMAN_Contract_Verbiage__c> insertVerbs = new List<CONMAN_Contract_Verbiage__c>();
        for (Offerings_Contract_Term__c verb : verbs) {
            System.debug(verb.Contract_General_Content__c);
            if(region == 'APAC' && theContract.PGi_Internal_Entity__c != verb.Contract_General_Content__r.PGI_Internal_Entity__c) {
                continue;
            } 
            if (existingVerbNames.contains(verb.Contract_General_Content__r.Name)){ 
                continue;
            }
            if(verb.Require_Currency_Match__c && verb.Contract_General_Content__r.CurrencyIsoCode != theContract.CurrencyIsoCode) {
                continue;
            }
            if(verb.Contract_General_Content__r.Language__c != theContract.Language__c) {
                continue;
            }
            CONMAN_Contract_Verbiage__c contVerb = new CONMAN_Contract_Verbiage__c(PGi_Contract__c = contractId);
            contVerb.Name = verb.Contract_General_Content__r.Name;
            contVerb.Intl_Order_Type__c = 'Long Form; Short Form';
            contVerb.Approved__c = true;
            contVerb.Pricing_Team_Changes_Allowed__c = true;
            contVerb.Contract_Product_Verbiage__c = verb.Contract_General_Content__c;
            contVerb.Verbiage__c = verb.Contract_General_Content__r.Terms_and_Conditions_RTF__c;
            contVerb.Order__c = currentOrder;
            contVerb.Language__c = verb.Contract_General_Content__r.Language__c;
            insertVerbs.add(contVerb);

            currentOrder += 1;
            existingVerbNames.add(verb.Contract_General_Content__r.Name);
        }
        insert insertVerbs;
    }

    public static void deleteLicensesAndRates(Id contractId) {
        List<LicenseSet__c> licSets =
            [SELECT Id FROM LicenseSet__c WHERE PGi_Contract__c = :contractId];
        if (licSets.size() > 0) {
            List<Id> licSetIds = new List<Id>();
            for (LicenseSet__c licSet : licSets)
                licSetIds.add(licSet.Id);
            List<Associated_Rate__c> assoRates =
                [SELECT Id FROM Associated_Rate__c WHERE LicenseSet__c IN :licSetIds];
            if (assoRates.size() > 0)
                DELETE assoRates;
            DELETE licSets;
        }
    }

    public static void deleteVerbiage(Id contractId) {
        List<CONMAN_Contract_Verbiage__c> verbs =
            [SELECT Id FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :contractId];
        if (verbs.size() > 0) DELETE verbs;
    }

    public static String startApproval(Id ContractId, Id OwnerId) {
        // Create an approval request for the contract
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(ContractId);

        // Submit on behalf of a specific submitter
        req1.setSubmitterId(OwnerId);

        // Submit the record to specific process
        // req1.setProcessDefinitionNameOrId('iContract_NA_Approvals_v9');

        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        return SUCCESS;
    }

    public static void dealDeskUpdatedFloors(Set<Id> contracts) {
        // Retrieve all of the LicenseSets and AssociatedRates for PGi Contract that are Deal Desk Approved
        Map<Id, LicenseSet__c> licenseSets = new Map<Id, LicenseSet__c>([
            SELECT Id, Name, Number_of_Licensed_Named_Users__c FROM LicenseSet__c WHERE PGi_Contract__c IN :contracts
        ]);
        Map<Id, Associated_Rate__c> associatedRates = new Map<Id, Associated_Rate__c>([
            SELECT Id, Name, Override__c, Sales_Rep__c, RVP__c, SVP__c, LicenseSet__c
            FROM Associated_Rate__c WHERE LicenseSet__c IN :licenseSets.keySet()
        ]);
        Set<Associated_Rate__c> associatedRatesWithNewFloors = new Set<Associated_Rate__c>();
        Set<LicenseSet__c> licenseSetsApproved = new Set<LicenseSet__c>();

        // Check all Associated Rates for an updated floor
        for (Associated_Rate__c associatedRate : associatedRates.values()) {
            boolean shouldAdd = false;

            if (associatedRate.Override__c < associatedRate.SVP__c ) {
                associatedRate.SVP__c = associatedRate.Override__c;
                associatedRate.RVP__c = associatedRate.Override__c;
                associatedRate.Sales_Rep__c = associatedRate.Override__c;
                shouldAdd = true;
            } else if (associatedRate.Override__c < associatedRate.RVP__c ) {
                associatedRate.RVP__c = associatedRate.Override__c;
                associatedRate.Sales_Rep__c = associatedRate.Override__c;
                shouldAdd = true;
            } else if (associatedRate.Override__c < associatedRate.Sales_Rep__c) {
                associatedRate.Sales_Rep__c = associatedRate.Override__c;
                shouldAdd = true;
            }
            if (shouldAdd) {
                licenseSetsApproved.add(licenseSets.get(associatedRate.LicenseSet__c));
                associatedRatesWithNewFloors.add(associatedRate);
            }
        }
        for (LicenseSet__c licenseSet : licenseSetsApproved) {
            licenseSet.Deal_Desk_Approved__c = true;
            licenseSet.Deal_Desk_Approved_Users__c = licenseSet.Number_of_Licensed_Named_Users__c;
        }

        update new List<LicenseSet__c>(licenseSetsApproved);
        update new List<Associated_Rate__c>(associatedRatesWithNewFloors);
    }

    public static String getPageUserIPAddress() {
        string ReturnValue = '';

        // True-Client-IP has the value when the request is coming via the caching integration.
        ReturnValue = ApexPages.currentPage().getHeaders().get('True-Client-IP');

        // X-Salesforce-SIP has the value when no caching integration or via secure URL.
        if (ReturnValue == '' || ReturnValue == null) {
            ReturnValue = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        } // get IP address when no caching (sandbox, dev, secure urls)

        if (ReturnValue == '' || ReturnValue == null) {
            ReturnValue = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
        } // get IP address from standard header if proxy in use

        return ReturnValue;
    }

    public static String formatTimeRecurrence(Decimal numberOfMonths) {
        if (numberOfMonths == null) return 'null';
        if (numberOfMonths <= 0) return numberOfMonths.toPlainString();

        if (numberOfMonths == 1) {
            return 'month';
        } else if (numberOfMonths == 4) {
            return 'quarter';
        } else if (numberOfMonths == 12) {
            return 'year';
        } else if (Math.mod(Math.Round(numberOfMonths), 12) == 0) {
            return String.valueOf(Math.round(numberOfMonths / 12)) + ' years';
        } else {
            return String.valueOf(numberOfMonths) + ' months';
        }
    }

    public static String formatTimeRange(Decimal numberOfMonths) {
        if (numberOfMonths == null) return 'null';
        if (numberOfMonths <= 0) return numberOfMonths.toPlainString();

        if (numberOfMonths == 1) {
            return '1 month';
        } else if (numberOfMonths == 4) {
            return '1 quarter';
        } else if (numberOfMonths == 12) {
            return '1 year';
        } else if (Math.mod(Math.Round(numberOfMonths), 12) == 0) {
            return String.valueOf(Math.round(numberOfMonths / 12)) + ' years';
        } else {
            return String.valueOf(numberOfMonths) + ' months';
        }
    }

    public static String formatException(Exception e) {
        return e.getTypeName() + ' (Line ' + e.getLineNumber() + ')' + ': ' + e.getMessage();
    }

    public class iContractException extends Exception {}

    public static void addRemoveCGC(Id contractId) {

        // Map<Id,Id> contractVerbiageToCGCMap = new Map<Id,Id>();
        // Map<Id,PGIServicesInformation__c> CGCMap = new Map<Id,PGIServicesInformation__c>();
        // Map<Id,List<PGIServicesInformation__c>> CGCParentMap = new Map<Id,List<PGIServicesInformation__c>>();
        Set<Id> contractTermIds = new Set<Id>();
        List<CONMAN_Contract_Verbiage__c> contractVerbs = [Select Id, Contract_General_Content__c FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c=:contractId];
        
        for(CONMAN_Contract_Verbiage__c verb : contractVerbs){
                // contractVerbiageToCGCMap.put(verb.Id, verb.Contract_General_Content__c);  
                contractTermIds.add(verb.Contract_General_Content__c);
        }
        Map<Id, PGIServicesInformation__c> contractTermById = new Map<Id, PGIServicesInformation__c>([SELECT Id, Contract_General_Content__c FROM PGIServicesInformation__c WHERE Id=: contractTermIds]);
        //loop thorugh contract verbs and determine if parent exists
        List<CONMAN_Contract_Verbiage__c> toDelete = new List<CONMAN_Contract_Verbiage__c>();
        for(CONMAN_Contract_Verbiage__c verb: contractVerbs) {
            if(verb.Contract_General_Content__c != null) {
                PGIServicesInformation__c term = contractTermById.get(verb.Contract_General_Content__c);
                if(term != null 
                    && term.Contract_General_Content__c != null //term has a parent
                    && contractTermIds.contains(term.Contract_General_Content__c)) { //contract has the parent on contract
                    toDelete.add(verb); //--> delete child
                }
            }
        }
        Delete toDelete;
        // for(PGIServicesInformation__c cgcObj: [SELECT Id, Contract_General_Content__c FROM PGIServicesInformation__c WHERE Id=: contractTermIds]){
        //         CGCMap.put(cgcObj.Id,cgcObj);  
        // }
        // for(PGIServicesInformation__c cgcObj: [SELECT Id,Contract_General_Content__c FROM PGIServicesInformation__c WHERE Contract_General_Content__c=:contractVerbiageToCGCMap.values()]){
        //     if(CGCParentMap.containsKey(cgcObj.Contract_General_Content__c)){
        //         CGCParentMap.get(cgcObj.Contract_General_Content__c).add(cgcObj);
        //     }else{
        //         CGCParentMap.put(cgcObj.Contract_General_Content__c, new List<PGIServicesInformation__c>{});  
        //     }
                
        // }
        // System.debug('The Map is'+contractVerbiageToCGCMap.keySet());
        // for(Id conVerbageId: contractVerbiageToCGCMap.keySet()){
        //     if(contractVerbiageToCGCMap.containsKey(conVerbageId) && contractVerbiageToCGCMap.get(conVerbageId) != null){
        //         // If Current CGC is a Child Record
        //         if(CGCMap.get(contractVerbiageToCGCMap.get(conVerbageId)).Contract_General_Content__c != null){

        //         }
        //         else{
        //            // If Current CGC record is Parent Record
        //             List<PGIServicesInformation__c> CGCrelatedList = CGCParentMap.get(contractVerbiageToCGCMap.get(conVerbageId));
        //             if(CGCrelatedList.isEmpty()) {
        //                 // This is a single record
        //             }else{

        //                 // this record is parent to Other CGC records
        //             }  
        //         }
        //     }
        // }
    }
    
}