@RestResource(urlMapping='/iContractLicenseSetMapping/*')
global with sharing class iContractLicenseSetMappingEndpoint {
    @HttpPost
    global static List<OpportunityLineItem> mapOppLicenseSetsToProducts(List<Id> opportunityIds) {
        List<OpportunityLineItem> mappedProducts = new List<OpportunityLineItem>();
        
        /* TODO UPDATE
        Map<Id, LicenseSet__c> licenseSets = new Map<Id, LicenseSet__c>([SELECT Id, Name,
                                                                         Opportunity__c, Opportunity__r.CurrencyIsoCode, Opportunity__r.Pricebook2Id,
                                                                         Enterprise_Name__c,
                                                                         Product_Name__c, Payment_Plan__c,
                                                                         Number_of_Licensed_Named_Users__c, Price__c,
                                                                         Subscription_License_Term_Months__c,
                                                                         Estimated_Minutes__c, Committed_Minutes__c,
                                                                         Committed_Rate__c, Estimated_Rate__c, Commitment_Reoccurence__c, 
                                                                         LicenseSet__c.Enterprise_Name__r.Product__c
                                                                         FROM LicenseSet__c
                                                                         WHERE Opportunity__c IN :opportunityIds]);
        
        mappedProducts.addAll(iContract.mapLicenseSetToProducts(licenseSets));
		*/
        
        // TODO: Move this loop to the function.
        // Difficulty being keeping the separately provided Opps mapped correctly
        //for (Id opportunityId : opportunityIds) {
        //    mappedProducts.addAll(iContract.mapExistingProductLineItems(opportunityId));
        //}
        
        return mappedProducts;
    }
}