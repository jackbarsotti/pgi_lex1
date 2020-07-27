global class iContract_NA_MasterLex_Controller {
    public String contractId {get;set;}
    public iContract_NA_MasterLex_Controller(ApexPages.StandardController controller) {
        contractId = ApexPages.CurrentPage().getparameters().get('id');
    }
}