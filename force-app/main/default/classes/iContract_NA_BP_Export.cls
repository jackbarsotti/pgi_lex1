//DEPRECATED 11-20-19 - Aaron Gaber
global class iContract_NA_BP_Export {
    
    // public static final Integer RATE_DECIMAL_PLACES = 4;
    
    // public CONMAN_Contract__c contract {get;set;}
    // public List<BPRate> lines {get;set;}
    
    // global class BPRate implements Comparable {
        
    //     public String iContractId {get;set;}
    //     public String iContractOffering {get;set;}
    //     public String iContractRateGroup {get;set;}
    //     public String iContractRate {get;set;}
        
    //     public boolean modified {get;set;}
        
    //     public String currencyCode {get;set;}
    //     public String rate {get;set;}
    //     public String intlRate {get;set;}
    //     public String bridgeCountry {get;set;}
    //     public String accessCountry {get;set;}
        
    //     public String billCode {get;set;}
    //     public String packageProductCode {get;set;}
        
    //     public BPRate(String id, String offr, String rg, String r) {
    //         iContractId = id;
    //         iContractOffering = offr;
    //         iContractRateGroup = rg;
    //         iContractRate = r;
    //     }
    
    //     public BPRate duplicate() {
    //         BPRate clone = new BPRate(iContractId, iContractOffering, iContractRateGroup, iContractRate);
    //         clone.modified = modified;
    //         clone.currencyCode = currencyCode;
    //         clone.rate = rate;
    //         clone.intlRate = intlRate;
    //         clone.bridgeCountry = bridgeCountry;
    //         clone.accessCountry = accessCountry;
    //         clone.billCode = billCode;
    //         clone.packageProductCode = packageProductCode;
    //         return clone;
    //     }
        
    //     // This is needed to sort the list of BPRates by their names
    //     global Integer compareTo(Object compareTo) {
    //         BPRate compareToLicense = (BPRate)compareTo;
            
    //         String thisOffr = this.iContractOffering;
    //         String thatOffr = compareToLicense.iContractOffering;
            
    //         String thisRG = this.iContractRateGroup;
    //         String thatRG = compareToLicense.iContractRateGroup;
            
    //         String thisRate = this.iContractRate;
    //         String thatRate = compareToLicense.iContractRate;
            
    //         Integer returnValue = 0; // equal
    //         if (thisOffr > thatOffr) {
    //             returnValue = 1;
    //         } else if (thisOffr < thatOffr) {
    //             returnValue = -1;
    //         } else { // try by Rate Group then
    //             if (thisRG > thatRG) {
    //                 returnValue = 1;
    //             } else if (thisRG < thatRG) {
    //                 returnValue = -1;
    //             } else { // try by Rate then
    //                 if (thisRate > thatRate) {
    //                     returnValue = 1;
    //                 } else if (thisRate < thatRate) {
    //                     returnValue = -1;
    //                 }
    //             }
    //         }
            
    //         return returnValue;
    //     }
    // }
    
    // public iContract_NA_BP_Export(ApexPages.StandardController stdController) {
    //     contract = getContractDetails(stdController.getRecord().Id);
    //     lines = getBPRates(contract.Id);
    // }
    
    // public static List<BPRate> getBPRates(Id contractId) {
    //     // Fetch all necessary data: LicenseSets and AssociatedRates
    //     Map<Id, LicenseSet__c> licenses = getLicenses(contractId);
    //     Map<Id, Associated_Rate__c> assoRates = getAssociatedRates(licenses.keySet());
        
    //     List<BPRate> bpRates = new List<BPRate>();
        
    //     for (Associated_Rate__c assoRate : assoRates.values()) {
    //         LicenseSet__c license = licenses.get(assoRate.LicenseSet__c);
            
    //         // Find the Unique ID if there's a Rate
    //         String uniqueId = 'DEAL_DESK_RATE';
    //         if (assoRate.Rate__c != null)
    //             uniqueId = assoRate.Rate__r.Unique_ID__c;
            
    //         // Find the Rate Group if there's a Rate with a Rate Group
    //         String rateGroup = '';
    //         if (assoRate.Rate__c != null && assoRate.Rate__r.Rate_Group__c != null)
    //             rateGroup = assoRate.Rate__r.Rate_Group__r.Name;
            
    //         // Create the BPRate with basic info
    //         BPRate bpRate = new BPRate(uniqueId, license.Product_Name__c,
    //                                    rateGroup, assoRate.Rate_Name__c);
            
    //         // Mark the BPRate as modified if it is
    //         bpRate.modified = isLicenseModified(license) || isAssociatedRateModified(assoRate);
            
    //         bpRate.currencyCode = assoRate.CurrencyIsoCode;
            
    //         // Different types of BPRates for Standard and International Grid Rates
    //         if (assoRate.Rate__c == null || assoRate.Rate__r.Type__c == null || assoRate.Rate__r.Type__c != 'Access') {
    //             // Simple Rate
    //             bpRate.rate = assoRate.Override__c.setScale(RATE_DECIMAL_PLACES).toPlainString();
                
    //             if (!hasBPFields(assoRate))
    //     			bpRates.add(bpRate);
    //             else
	// 				bpRates.addAll(createBPRates(bpRate, assoRate.Rate__r));
                
    //         } else {
    //             // International Rate
    //             bpRate.rate = '0';
    //             bpRate.bridgeCountry = assoRate.Rate__r.BP_Bridge_Country__c;
    //             bpRate.accessCountry = assoRate.Rate__r.BP_Access_Country__c;

    //             bpRate.iContractRate = assoRate.Name;
    //             bpRate.intlRate = assoRate.Override__c.setScale(RATE_DECIMAL_PLACES).toPlainString();
    //             if (!hasBPFields(assoRate))
    //                 bpRates.add(bpRate);
    //             else
    //                 bpRates.addAll(createBPRates(bpRate, assoRate.Rate__r));
    //         }
    //     }
        
    //     bpRates.sort();
    //     return bpRates;
    // }
    
    // public static CONMAN_Contract__c getContractDetails(Id contractId) {
    //     return [SELECT Id, Name FROM CONMAN_Contract__c WHERE Id = :contractId];
    // }
    
    // public static Map<Id, LicenseSet__c> getLicenses(Id contractId) {
    //     return new Map<Id, LicenseSet__c>([
    //         SELECT Id, Name,
    //         Product_Name__c,
    //         Enterprise_Name__c,
    //         Enterprise_Name__r.Product_Name__c
    //         FROM LicenseSet__c
    //         WHERE PGi_Contract__c = :contractId
    //     ]);
    // }
    
    // public static Map<Id, Associated_Rate__c> getAssociatedRates(Set<Id> licenseIds) {
    //     return new Map<Id, Associated_Rate__c>([
    //         SELECT Id, Name, CurrencyIsoCode,
    //         Rate_Name__c,
    //         Description__c,
    //         Recurrence__c,
    //         Override__c,
    //         Default__c,
    //         LicenseSet__c,
    //         Rate__c,
    //         Rate__r.Unique_ID__c,
    //         Rate__r.Rate_Name__c,
    //         Rate__r.Description__c,
    //         Rate__r.Recurrence__c,
    //         Rate__r.Type__c,
    //         Rate__r.BP_Bill_Code__c,
    //         Rate__r.BP_Package_Product_Code__c,
    //         Rate__r.BP_Access_Country__c,
    //         Rate__r.BP_Bridge_Country__c,
    //         Rate__r.Rate_Group__c,
    //         Rate__r.Rate_Group__r.Name
    //         FROM Associated_Rate__c
    //         WHERE LicenseSet__c IN :licenseIds
    //     ]);
    // }
    
    // public static boolean isLicenseModified(LicenseSet__c license) {
    //     // no name?
    //     if (license.Product_Name__c == null)
    //         return true;
        
    //     // no original Offering
    //     if (license.Enterprise_Name__c == null)
    //         return true;
        
    //     // modified Product Name
    //     if (license.Product_Name__c != license.Enterprise_Name__r.Product_Name__c)
    //     	return true;
        
    //     return false;
    // }
    
    // public static boolean isAssociatedRateModified(Associated_Rate__c rate) {
    //     // no name?
    //     if (rate.Rate_Name__c == null)
    //         return true;
        
    //     // no original Rate
    //     if (rate.Rate__c == null)
    //         return true;
        
    //     // modified Rate Name
    //     if (rate.Rate_Name__c != rate.Rate__r.Rate_Name__c && rate.Rate__r.Type__c != 'Access')
    //         return true;
        
    //     // modified Rate Description
    //     if (rate.Description__c != rate.Rate__r.Description__c)
    //         return true;
        
    //     // modified Rate Recurrence
    //     if (rate.Recurrence__c != rate.Rate__r.Recurrence__c && rate.Rate__r.Type__c == 'Usage')
    //         return true;
        
    //     return false;
    // }
    
    // public static boolean hasBPFields(Associated_Rate__c rate) {
    //     return rate.Rate__c != null &&
    //         (
    //             (rate.Rate__r.BP_Bill_Code__c != null && !String.isEmpty(rate.Rate__r.BP_Bill_Code__c))
    //             ||
    //             (rate.Rate__r.BP_Package_Product_Code__c != null && !String.isEmpty(rate.Rate__r.BP_Package_Product_Code__c))
    //         );
    // }
    
    // public static List<BPRate> createBPRates(BPRate baseBPRate, Rate__c rate) {
    //     List<BPRate> bpRates = new List<BPRate>();
        
    //     if (rate == null)
    //         return bpRates;
        
    //     // Check for single/multiple Bill Codes and/or Package Product Codes
    //     List<String> billCodes = new List<String>();
    //     List<String> packageProductCodes = new List<String>();
    //     if (rate.BP_Bill_Code__c != null && !String.isEmpty(rate.BP_Bill_Code__c))
    //         billCodes = rate.BP_Bill_Code__c.split('\\|\\|');
    //     if (rate.BP_Package_Product_Code__c != null && !String.isEmpty(rate.BP_Package_Product_Code__c))
    //         packageProductCodes = rate.BP_Package_Product_Code__c.split('\\|\\|');
        
    //     if (billCodes.isEmpty() || packageProductCodes.isEmpty())
    //         return bpRates;
        
    //     // Create a new BPRate for each Bill Code or Package Product Codes
    //     // Except, if the fields are different sizes, use the last item
    //     for (integer i = 0; i < Math.max(billCodes.size(), packageProductCodes.size()); i++) {
    //         BPRate newBPRate = baseBPRate.duplicate();
            
    //         if (!billCodes.isEmpty())
    //             newBPRate.billCode = billCodes.get(Math.min(i, billCodes.size() - 1));
            
    //         if (!packageProductCodes.isEmpty())
    //             newBPRate.packageProductCode = packageProductCodes.get(Math.min(i, packageProductCodes.size() - 1));
            
    //         bpRates.add(newBPRate);
    //     }
        
    //     return bpRates;
    // }
}