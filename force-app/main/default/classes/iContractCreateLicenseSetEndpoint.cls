@RestResource(urlMapping='/iContractCreateLicenseSet/*')
global with sharing class iContractCreateLicenseSetEndpoint {
    @HttpPost
    global static String createLicenseSet(Id contractId, List<LicenseSet__c> LicenseSets, List<List<Associated_Rate__c>> AssociatedRates) {
        try {
            List<LicenseSet__c> licenseSetsToCreate = new List<LicenseSet__c>();
            List<Associated_Rate__c> associatedRatesToCreate = new List<Associated_Rate__c>();

            Set<Id> offeringIds = new Set<Id>();
            for (LicenseSet__c lc : LicenseSets) {
                offeringIds.add(lc.Enterprise_Name__c);
            }

            for (Integer index = 0; index < LicenseSets.size(); index++) {
                LicenseSet__c lc = LicenseSets.get(index);
                List<Associated_Rate__c> ars = AssociatedRates.get(index);

                licenseSetsToCreate.add(lc);

                if (ars != null) {
                    for(Associated_Rate__c ar : ars)
                        ar.LicenseSet__r = lc;
                    associatedRatesToCreate.addAll(ars);
                }
            }

           INSERT licenseSetsToCreate;

            // retrieve the inserted IDs before adding ARs
            for (Associated_Rate__c ar : associatedRatesToCreate) {
                ar.LicenseSet__c = ar.LicenseSet__r.Id;
            }
            INSERT associatedRatesToCreate;

            iContract.handleTerms(contractId);

            return iContract.SUCCESS;
        } catch(Exception e){
            return iContract.formatException(e);
        }
    }
}