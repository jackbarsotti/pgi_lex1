public class OpportunitySelector {
    public Map<Id, Opportunity> getOppsWithRelated(Set<Id> oppIdSet) {
       
        Map<Id, Opportunity> returnMap = new Map<Id, Opportunity>();
        Set<Id> toQuery = new Set<Id>();
        for(Id oppId: oppIdSet){ 
            if(!queriedOppsWithRelated.keySet().contains(oppId)){
                toQuery.add(oppId);
            }
        }
        toQuery.remove(null);
        if(toQuery.size() > 0) {
            queryOppsWithRelated(toQuery);
        }
        for(Id oppId: oppIdSet){ 
            if(queriedOppsWithRelated.keySet().contains(oppId)){
                returnMap.put(oppId, queriedOppsWithRelated.get(oppId));
            } else {
                System.debug('failed to query record: ' + oppId);
            }
        }
        return returnMap;
    }

    private Map<Id, Opportunity> queriedOppsWithRelated = new Map<Id, Opportunity>();

    public Set<String> fieldsForObject(String objectName) {
        Set<String> returnSet = new Set<String>();
        if(validObjectName(objectName)) {
            for(String fieldName: gd.get(objectName).getDescribe().fields.getMap().keySet()) {
                returnSet.add(fieldName);
            }
        }
        return returnSet;
    }

    //Validate Category Option (Object Name)
    public boolean validObjectName(String objName) {
        if(gd.get(objName) == null) {
            return false;
        } else {
            return true;
        }
    }

    public Map<String, Schema.SObjectType> gd { 
        get {
            if(gd == null) {
            gd = Schema.getGlobalDescribe();
            } 
            return gd;
        } set;
    }

    public String buildAllQuery(String objectName, String relationshipName) {
        String query = 'SELECT Id';
        if(objectName == 'OpportunityLineItem') {
            query += ',Product2.Name, ' +
            'Product2.Family, ' +
            'Product2.Clone_for_PGi_Renewals_Renewal__c, ' +
            'Product2.Clone_for_PGi_Renewal__c, ' +
            'PricebookEntry.IsActive, Product2.IsActive ';
        }
        for(String field: fieldsForObject(objectName)) {
            if(field.toUpperCase() != 'ID' && field.toUpperCase() != 'SUBTOTAL') {
                query += ', ' + field;

            }
        }
        query += ' FROM ' + relationshipName;
        return query;
    }

    public String buildChildQueryAllFields(String baseQuery, String objectName, String relationshipName) {
        String query = ' ( ' + buildAllQuery(objectName, relationshipName) + ' ) ';

        return query;
    }

    private Map<Id, Opportunity> queryOppsWithRelated(Set<Id> oppIdSet) {
        if(oppIdSet == null || oppIdSet.isEmpty()) {
            return null;
        } else {
            oppIdSet.remove(null);
        }
        if(oppIdSet == null || oppIdSet.isEmpty()) {
            return null;
        }
        Map<Id, Opportunity> returnMap = new Map<Id, Opportunity>();
          // TODO - BUILD query dynamically - select ALL fields from OLI
          String queryString = 'SELECT Id, ';
                queryString += 'AccountId,';
                queryString += 'Account.Global_Account_MQA_Assignment_date__c,';
                queryString += 'Account.Global_Account_MQA__c,';
                queryString += 'CloseDate,';
                queryString += 'CurrencyIsoCode,';
                queryString += 'Owner.DefaultCurrencyIsoCode,';
                queryString += 'Owner.Company__c,';
                queryString += 'RecordTypeId,';
                queryString += 'RecordType.Name,';
                queryString += 'Opportunity_Deal_Type__c,';
                queryString += 'Primary_Contact__c,';
                queryString += 'Primary_Contact__r.Global_Contact_MQL_Assignment_date__c,';
                queryString += 'Primary_Contact__r.Global_Contact_MQL__c,';
                queryString += 'IsClosed,';
                queryString += ' (SELECT Id, Contract_Start_Date__c, ';
                queryString += ' Contract_Renewal_Date__c, ';
                queryString += ' Auto_Renewal__c ' ;
                queryString += ' FROM CONMAN_Contracts__r), ';
                queryString += buildChildQueryAllFields(queryString, 'OpportunityLineItem', 'OpportunityLineItems') + ',';
                queryString += ' (SELECT id, OpportunityId, ContactId, IsPrimary, Role,  Contact.Buyer_Persona__c';
                queryString += '  FROM OpportunityContactRoles),';
                queryString += '  (SELECT OpportunityId, OpportunityAccessLevel, Name, TeamMemberRole, UserId';
                queryString += '  FROM OpportunityTeamMembers)';
                queryString += '  FROM Opportunity WHERE Id IN: oppIdSet';
        //System.assert(False, queryString);
        //System.assert(false, queryString);
        queriedOppsWithRelated.putAll((List<Opportunity>)Database.query(queryString));

        return returnMap;
    }

    public Map<Id, List<Opportunity>> getOpenPGIRenewalOppsByAccountId(List<Opportunity> oppList) {
        if(oppList == null) {
            return null;
        }
        Map<Id, List<Opportunity>> returnMap = new Map<Id, List<Opportunity>>();
        Set<Id> toQuery = new Set<Id>(); //account Ids
        
        Set<Id> accountIdSet = new Set<Id>();
        for(Opportunity opp: oppList) {
            returnMap.put(opp.AccountId, new List<Opportunity>());
            accountIdSet.add(opp.AccountId);
        }

        for(Id accountId: accountIdSet){ 
            if(!queriedOpenPGIRenewalOppsByAccountId.keySet().contains(accountId)){
                toQuery.add(accountId);
            }
        }

        toQuery.remove(null);
        if(toQuery.size() > 0) {
            queryOpenPGIRenewalOpps(toQuery);
        }

        for(Id accountId: accountIdSet){ 
            if(queriedOpenPGIRenewalOppsByAccountId.keySet().contains(accountId)){
                returnMap.put(accountId, queriedOpenPGIRenewalOppsByAccountId.get(accountId));
            } else {
                System.debug('failed to query opp records for account: ' + accountId);
            }
        }
        return returnMap;
    }

    private Map<Id, List<Opportunity>> queriedOpenPGIRenewalOppsByAccountId = new Map<Id, List<Opportunity>>();
    private List<Opportunity> queryOpenPGIRenewalOpps(Set<Id> accountIds) {
        List<Opportunity> queriedRenewalOpps = [SELECT Id, 
        AccountId, 
        CloseDate, 
        CurrencyIsoCode, 
        Owner.DefaultCurrencyIsoCode, 
        Owner.Company__c, 
        RecordTypeId, 
        RecordType.Name,
        Opportunity_Deal_Type__c,
        IsClosed,
        Opportunity_Product_Families__c,
            (SELECT Id, 
                Product2Id, 
                PriceBookEntryId, 
                Product2.Name, 
                Product2.Clone_for_PGi_Renewals_Renewal__c,
                Product2.Family, 
                Product2.Clone_for_PGi_Renewal__c, 
                TotalPrice, 
                Product_Family__c, 
                Total_Margin__c, 
                Quantity,
                Billing_Frequency__c,
                Unit_Type__c,
                New_Sales_Price__c,
                Unit_Price_Create_Only__c,
                Contract_Term__c,
                OpportunityId,
                New_Quantity__c, 
                PricebookEntry.IsActive, 
                Product2.IsActive
            FROM OpportunityLineItems),
        (SELECT id, OpportunityId, ContactId, IsPrimary, Role, Contact.Buyer_Persona__c
        FROM OpportunityContactRoles),                
        (SELECT OpportunityId, OpportunityAccessLevel, Name, TeamMemberRole, UserId
        FROM OpportunityTeamMembers)
        FROM Opportunity WHERE AccountId IN: accountIds
        AND RecordType.Name = 'PGi Renewal Opportunity'
        AND IsClosed = false
        AND Opportunity_Product_Families__c LIKE '%Unified Communications%'];
        for(Opportunity opp: queriedRenewalOpps) {
            List<Opportunity> oppsForAccount = queriedOpenPGIRenewalOppsByAccountId.get(opp.AccountId);
            if(oppsForAccount == null) {
                oppsForAccount = new List<Opportunity>();
            }
            oppsForAccount.add(opp);
            queriedOpenPGIRenewalOppsByAccountId.put(opp.AccountId, oppsForAccount);
        }
        return queriedRenewalOpps;
    }

    public Map<Id, List<Opportunity_Line_Amendment__c>> getOppLineAmendmentsByOppId(List<Opportunity> amendedOppList) {
        Map<Id, List<Opportunity_Line_Amendment__c>> returnMap = new Map<Id, List<Opportunity_Line_Amendment__c>>();
        Set<Id> toQuery = new Set<Id>(); //account Ids
        
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity opp: amendedOppList) {
            oppIds.add(opp.Id);
        }

        for(Id oppId: oppIds){ 
            if(!queriedOppLineAmendmentsByOppId.keySet().contains(oppId)){
                toQuery.add(oppId);
            }
        }

        toQuery.remove(null);
        if(toQuery.size() > 0) {
            queryOppLineAmendmentsByOppId(toQuery);
        }

        for(Id oppId: oppIds){ 
            if(queriedOppLineAmendmentsByOppId.keySet().contains(oppId)){
                returnMap.put(oppId, queriedOppLineAmendmentsByOppId.get(oppId));
            } else {
                System.debug('failed to query opp records for account: ' + oppId);
            }
        }
        return returnMap;
    }

    private Map<Id, List<Opportunity_Line_Amendment__c>> queriedOppLineAmendmentsByOppId = new Map<Id, List<Opportunity_Line_Amendment__c>>();
    private List<Opportunity_Line_Amendment__c> queryOppLineAmendmentsByOppId(Set<Id> amendedOppIds) {
        List<Opportunity_Line_Amendment__c> queriedOppLineAmendments = [SELECT Id, Amendment_Line_Id__c, 
                                                                        Amendment_Opportunity__c, 
                                                                        Renewal_Line_Id__c, 
                                                                        Renewal_Opportunity__c,
                                                                        Previous_Quantity__c
                                                                    FROM Opportunity_Line_Amendment__c WHERE Amendment_Opportunity__c IN: amendedOppIds];
        
        for(Opportunity_Line_Amendment__c ola: queriedOppLineAmendments) {
            List<Opportunity_Line_Amendment__c> olaForAmendmentOpp = queriedOppLineAmendmentsByOppId.get(ola.Amendment_Opportunity__c);
            if(olaForAmendmentOpp == null) {
                olaForAmendmentOpp = new List<Opportunity_Line_Amendment__c>();
            }
            olaForAmendmentOpp.add(ola);
            queriedOppLineAmendmentsByOppId.put(ola.Amendment_Opportunity__c, olaForAmendmentOpp);
        }
        return queriedOppLineAmendments;
    }
}