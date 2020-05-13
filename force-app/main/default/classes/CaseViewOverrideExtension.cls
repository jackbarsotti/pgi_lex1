public without sharing class CaseViewOverrideExtension {
	public CaseViewOverrideExtension(ApexPages.StandardController controller) {
		
	}
    public String ProductSymptoms {get; set; }
	// public String ProductSymptoms {get {
    //     if(ProductSymptoms == null) {
    //         system.debug('Calling Productsymptoms');
    //        ProductSymptoms = JSON.serialize(new ProductSymptoms());
    //     }
    //     return ProductSymptoms;
    // } set;}
    /* RT-306---------Start--*/
    @RemoteAction
    public static Object fetchProductSymptoms(){
        return new ProductSymptoms();
    }
    /* -- end --*/
}