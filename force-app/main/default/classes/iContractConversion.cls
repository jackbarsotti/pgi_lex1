@RestResource(urlMapping='/iContractConversion/*')
global class iContractConversion {

    /* Given a PGi Contract ID and contractType this will update the Type
    */
    /* Given a PGi Contract ID, this will remove all of the products
     * and reset the Terms and Conditions to the defaults
    */
    @HttpPost
    global static String convert(String contractType) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String contractIdRequest = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Id contractId;
        try { contractId = contractIdRequest; }
        catch (Exception e) {  return 'Invalid PGi Contract ID: ' + contractIdRequest; }

        /*try {*/
            CONMAN_Contract__c agreement =  [SELECT Id, Contract_Type__c FROM CONMAN_Contract__c WHERE Id = :contractId];
            boolean converting = agreement.Contract_Type__c != contractType;

            agreement.Contract_Type__c = contractType;
            if (converting) agreement.Title__c = 'PGi ' + contractType;
            if (contractType.equals('Amendment')) {
                agreement.Required_Approval_Legal__c = true;
                if (converting) agreement.Title__c += ' #X';
            } else if (contractType.equals('Subscription License Agreement')) {
                agreement.Required_Approval_Legal__c = true;
            } else {
                agreement.Required_Approval_Legal__c = false;
            }
            UPDATE agreement;

            if (converting) {
                iContract.handleTerms(contractId);
            }

            return iContract.SUCCESS;
        /*} catch (Exception e) {
            return iContract.formatException(e);
        }*/
    }
}