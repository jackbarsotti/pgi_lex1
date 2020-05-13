@RestResource(urlMapping='/iContractOppProducts/*')
global with sharing class iContractOppProductsEndpoint {
    @HttpPost
    global static String createRemoveProducts(List<OpportunityLineItem> productsToCreate, List<OpportunityLineItem> productsToRemove) {
        try {
            if (productsToCreate != null && productsToCreate.size() != 0) {
                insert productsToCreate;
            }
            if (productsToRemove != null && productsToRemove.size() != 0) {
                delete productsToRemove;
            }
            return iContract.SUCCESS;
        } catch (Exception e) {
            return iContract.formatException(e);
        }
    }
}