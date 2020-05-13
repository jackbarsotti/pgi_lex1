@RestResource(urlMapping='/iContractEmptyCart/*')
global class iContractEmptyCart {
    
    /* Given a PGi Contract ID, this will remove all of the products
     * and reset the Terms and Conditions to the defaults
	*/
	@HttpGet
    global static String emptyCartRequest() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String contractIdRequest = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Id contractId;
        try {
            contractId = contractIdRequest;
        } catch (Exception e) {
            return 'Invalid PGi Contract ID: ' + contractIdRequest;
        }
        try {
        	return emptyCart(contractId);
        } catch (Exception e) {
            return iContract.formatException(e);
        }
    }
    
    public static String emptyCart(Id contractId) {
        iContract.deleteLicensesAndRates(contractId);
        //iContract.deleteVerbiage(contractId);
        //iContract.addRemoveDefaultVerbiage(contractId);
        return iContract.SUCCESS;
    }
}