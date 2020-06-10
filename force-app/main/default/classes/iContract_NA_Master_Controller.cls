global class iContract_NA_Master_Controller {
    public static final Integer LICENSE_DECIMAL_PLACES = 2;
    public static final Integer RATE_DECIMAL_PLACES = 4;

    // Bad practice, but we're not sending/receiving anything sensitive except for external non-salesforce users
    private static final String PARTNER_SITE_AES_KEY = 'fVaW7Bt72aHmkG70fXF59WfK4w8biL+Dn/NXc5LzWbE=';
    public Static Boolean isUSA {get; set;} 
    public Static String dateFormatOutput{get; set;} 
    //Added by Anup :RT-281
    public Boolean isServiceOrder{get; set;}
    public Boolean isAssociated{get; set;}
    /* End RT-281*/
    //Added by Anup :RT-335}
    public String termsManuallyChanged{get;set;} 
    /* End RT-335*/
    public static String country {get;set;}
    public static boolean isExcel {get;set;}
    // RT-524 iContract Signature Block Labels needs to support multiple languages (French or Greman)
    public static String testString {get;set;}
    public List<String> headerValueForForm {
        get {
            headerValueForForm = new List<String>();
            String headerValue;
            if(contract.Language__c == 'fr_FR'){
                headerValue = [SELECT Id,Header__c
                                                FROM Get_Header_BasedOnLang__mdt
                                                WHERE MasterLabel = 'French'].Header__c;
                
            }
            else if(contract.Language__c == 'de_DE'){
                headerValue = [SELECT Id,Header__c
                                                FROM Get_Header_BasedOnLang__mdt
                                                WHERE MasterLabel = 'German'].Header__c; 
            }
            else{
                headerValue = [SELECT Id,Header__c
                                                FROM Get_Header_BasedOnLang__mdt
                                                WHERE MasterLabel = 'English'].Header__c;
            }
            return headerValue.split(',');
        }
        private set;
    }

     //RT-518 iContract users in India (not contacts) should only be allowed to use “short form” .(Vijay)
     public Boolean isUserIndia {
        get {
            System.debug('The List'+headerValueForForm);
            String loginUserCountry = [SELECT Id, Country 
                                        FROM User 
                                        WHERE Id =: userInfo.getUserId()].Country;
            if(loginUserCountry == 'India'){
                return true;
            }
            else{
                return false;
            }
        }
        private set;
    }
    // RT-561 
    public Map<String,Id> docNametoIdMap {
        get {
            docNametoIdMap = new Map<String,Id>();
            Set<String> docNameSet = new Set<String>{'TPXAvailability','TPXGreenBox','TPXHdVideoCalling','TPXHdVoiceCalling',
                                                     'TPXImChat','TPXIntegration','TPXIntroductionDoc','TPXIntroductionPdf',
                                                     'TPXlandline','TPXLandlineLapMobile','TPXScreenSharing','TPXUcxlogo','TPXVideo',
                                                     'TPXVideoLapMObile','TPXVirtualMeeting','TPXWorkFrmAnyWhere'};
            for(Document doc : [SELECT Id,Name,Url FROM Document WHERE Name =:docNameSet])
                {
                    docNametoIdMap.put(doc.Name,doc.Id); 
                }
            return docNametoIdMap;
        }
        private set;
    }
    // RT-573
    public Boolean isProfileMatch {
        get{
            Boolean isprofile = false;
            List<String> profileNameList = new List<String>{'System Administrator','PGi Implementation Services','PGi Contract Manager'};
            
            String profileName = [Select Name from Profile Where Id =:userinfo.getProfileId()].Name;
            for(string str : profileNameList){
                if(str == profileName ){
                    isprofile = true;
                }
            }
            return isprofile;
        }
        private set;
    }
    // RT-573
    public Boolean isCompetitorOther {
        get{
            if(oppData != null && String.isNotBlank(oppData.Competitor_s__c) && !oppData.Competitor_s__c.contains('Other')){
                return true;
            }
            else if(oppData != null && oppData.Competitor_s__c != null && oppData.Competitor_s__c != '' && oppData.Competitor_s__c.contains('Other') && oppData.Competitor_Other_Product__c != null){
                return true;
            }
            else{
                return false;
            }
        }
        private set;
    }
    // RT-573
    public Boolean isIncumbentOther {
        get{
            
            if(oppData != null && String.isNotBlank(oppData.Incumbent__c) && oppData.Incumbent__c.contains('Other') && oppData.Incumbent_Other_Product__c != null){
                return true;
            }
            else{
                return false;
            }
        }
        private set;
    }
    // RT-567 Related
    public User opportunityOwner {
        get {
            return [SELECT Id, Phone, Name,Email,Title ,Username FROM User Where Id =:oppData.ownerId];
        }
        private set;
    }
    // RT-567 AccountName
    // Determines Account Agreement Name
    public String agreementAccountName {
        get {
            if (contract.Account_s_Agreement_Name__c != null && !String.isEmpty(contract.Account_s_Agreement_Name__c)){
                return contract.Account_s_Agreement_Name__c;
            }else{
                return contract.Account_Name__r.Name;
            }
        }
        private set;
    }
    global class LicenseData implements Comparable {
        public LicenseSet__c licenseSet {get;set;}

        public List<String> rateGroupOrder {get;set;}
        public Map<String, RateGroupData> rateGroups {get;set;}

        public List<String> accessTypeOrder {get;set;}
        public Map<String, AccessTypeData> accessTypes {get;set;}

        public List<RateData> subscriptions {get;set;}
        public List<RateData> bundleDetails {get;set;}
        public List<RateData> oneTimeCharges {get;set;}
        public List<RateData> commitments {get;set;}

        public LicenseData(LicenseSet__c licenseSet, List<Associated_Rate__c> associatedRates, CONMAN_Contract__c agreement) {
            this.licenseSet = licenseSet;

            this.rateGroupOrder = new List<String>();
            this.rateGroupOrder.add('');
            this.rateGroups = new Map<String, RateGroupData>();
            this.rateGroups.put('', new RateGroupData(null));

            this.accessTypeOrder = new List<String>();
            this.accessTypes = new Map<String, AccessTypeData>();

            this.subscriptions = new List<RateData>();
            this.bundleDetails = new List<RateData>();
            this.oneTimeCharges = new List<RateData>();
            this.commitments = new List<RateData>();

            for (Associated_Rate__c assoRate : associatedRates)
                this.addAssociatedRate(assoRate, agreement);

            this.sort();
        }

        public void addAssociatedRate(Associated_Rate__c associatedRate, CONMAN_Contract__c agreement) {
            System.debug('associatedRate.Rate__r.Type__c'+associatedRate.Rate__r.Type__c);
           
            Boolean hasRate = associatedRate.Rate__c != null && associatedRate.Rate__r != null;
            System.debug('hasRate'+hasRate);
            if (hasRate && associatedRate.Rate__r.Type__c == 'Sub')
                this.subscriptions.add(new RateData(associatedRate, agreement));
            else if (hasRate && associatedRate.Rate__r.Type__c == 'Bundle')
                this.bundleDetails.add(new RateData(associatedRate, agreement));
            else if (hasRate && associatedRate.Rate__r.Type__c == 'Once')
                this.oneTimeCharges.add(new RateData(associatedRate, agreement));
            else if (hasRate && associatedRate.Rate__r.Type__c == 'Commit')
                this.commitments.add(new RateData(associatedRate, agreement));
            else if (hasRate && associatedRate.Rate__r.Type__c == 'Access' && associatedRate.Rate__r.Rate_Group__c != null) {
                String rateGroupId = associatedRate.Rate__r.Rate_Group__c;

                if (!this.accessTypes.containsKey(rateGroupId)) {
                    this.accessTypes.put(rateGroupId, new AccessTypeData(associatedRate.Rate__r.Rate_Group__r));
                    this.accessTypeOrder.add(rateGroupId);
                }

                this.accessTypes.get(rateGroupId).addAssociatedRate(associatedRate, agreement);
            } else {
                String rateGroupId = '';
                if (associatedRate.Rate__r.Rate_Group__c != null)
                    rateGroupId = associatedRate.Rate__r.Rate_Group__c;

                if (!this.rateGroups.containsKey(rateGroupId)) {
                    this.rateGroups.put(rateGroupId, new RateGroupData(associatedRate.Rate__r.Rate_Group__r));
                    this.rateGroupOrder.add(rateGroupId);
                }
                this.rateGroups.get(rateGroupId).addAssociatedRate(associatedRate, agreement);
            }
        }

        public Boolean hasSubscriptions {
            get {
                return this.subscriptions != null && this.subscriptions.size() > 0;
            }
            set;
        }

        public Boolean hasBundleDetails {
            get {
                return this.bundleDetails != null && this.bundleDetails.size() > 0;
            }
            set;
        }

        public Boolean hasOneTimeCharges {
            get {
                return this.oneTimeCharges != null && this.oneTimeCharges.size() > 0;
            }
            set;
        }

        public Boolean hasCommitments {
            get {
                return this.commitments != null && this.commitments.size() > 0;
            }
            set;
        }

        public Boolean hasAccessTypes {
            get {
                return this.accessTypes != null && this.accessTypes.size() > 0;
            }
            set;
        }

        public Boolean hasRates {
            get {
                if (this.rateGroups == null) {
                    return false;
                } else {
                    for (RateGroupData rateGroup : rateGroups.values()) {
                        if (rateGroup.hasRates)
                            return true;
                    }
                    return false;
                }
            }
            set;
        }

        public String id {
            get { return this.licenseSet.Id; } set;
        }

        public String name {
            get { return this.licenseSet.Product_Name__c; } set;
        }

        public Boolean isCustomName {
            get {
                return this.licenseSet.Enterprise_Name__r == null || this.licenseSet.Product_Name__c != this.licenseSet.Enterprise_Name__r.Product_Name__c;
            }
            set;
        }

        public Boolean isDisabled {
            get {
                return this.licenseSet.Disabled__c != null && this.licenseSet.Disabled__c == true;
            }
            set;
        }

       

        public void sort() {
            subscriptions.sort();
            oneTimeCharges.sort();
            bundleDetails.sort();

            List<RateGroupData> rateGroupsSorted = rateGroups.values();
            rateGroupsSorted.sort();
            rateGroupOrder.clear();
            rateGroupOrder.add('');
            for (RateGroupData rateGroup : rateGroupsSorted) {
                rateGroup.sort();
                if (String.isEmpty(rateGroup.header))
                    continue;
                if (rateGroup.rateGroup != null)
                    rateGroupOrder.add(rateGroup.rateGroup.Id);
            }

            List<AccessTypeData> accessTypesSorted = accessTypes.values();
            accessTypesSorted.sort();
            accessTypeOrder.clear();
            for (AccessTypeData accessType : accessTypesSorted) {
                accessType.sort();
                accessTypeOrder.add(accessType.rateGroup.Id);
            }
        }

        // This is needed to sort the list of Licenses by their name
        global Integer compareTo(Object compareTo) {
            LicenseData compareToLicense = (LicenseData)compareTo;

            // Start with a very small Order for those that don't have one (custom ones)
            Double thisOrder = -999999.9;
            Double thatOrder = -999999.9;

            // Try to get the Order from the Offering
            if (this.licenseSet.Enterprise_Name__r != null && this.licenseSet.Enterprise_Name__r.Order__c != null)
                thisOrder = this.licenseSet.Enterprise_Name__r.Order__c;
            if (compareToLicense.licenseSet.Enterprise_Name__r != null && compareToLicense.licenseSet.Enterprise_Name__r.Order__c != null)
                thatOrder = compareToLicense.licenseSet.Enterprise_Name__r.Order__c;

            Integer returnValue = 0; // equal
            if (thisOrder > thatOrder) {
                returnValue = 1;
            } else if (thisOrder < thatOrder) {
                returnValue = -1;
            } else {
                // equal, fall to alphabetical ordering
                String thisName = this.name;
                String thatName = compareToLicense.name;
                if (thisName > thatName) {
                    returnValue = 1;
                } else if (thisName < thatName) {
                    returnValue = -1;
                }
            }
            return returnValue;
        }
    }

/* RT-335 ---------Start----------------Anup-----*/
    
    public Boolean isPdfDownloadCapability {get {
        // if the Account Owner's channel is Partners and the Account Type contains 'Agent' should they be allowed to download. Any other partner type accounts need to facilitate us sending for eSignature.
        return contract.Account_Name__r != null && contract.Account_Name__r.Owners_Channel_Formula__c == 'Partners' && String.isNotBlank(contract.Account_Name__r.Type) &&  contract.Account_Name__r.Type.contains('Agent');
    }}
    public void updateTerms(){
        System.debug(LoggingLevel.DEBUG, '=='+termsManuallyChanged);
        contract.T_Cs_Were_Manually_Changed__c = termsManuallyChanged;
        System.assertEquals(contract.T_Cs_Were_Manually_Changed__c, 'No');
        Update contract;    
    }
    public void updateProductdetails(){
        contract.T_Cs_Were_Manually_Changed__c = termsManuallyChanged;
        // system.debug('==>'+contract.T_Cs_Were_Manually_Changed__c);
        Update contract;    
    }
    /* RT-335--------------end------------------*/
    global class RateData implements Comparable {
        public Associated_Rate__c associatedRate {get;set;}
        public Decimal termLength {get;set;}
        public Decimal termFrequency {get;set;}

        public RateData(Associated_Rate__c associatedRate, CONMAN_Contract__c agreement) {
            this.associatedRate = associatedRate;
            this.termLength = agreement.Contracted_Term__c;
            this.termFrequency = agreement.Contracted_Frequency__c;
        }

        public String id {
            get { return associatedRate.Id; } set;
        }

        public String name {
            get {
                if (associatedRate.Rate_Name__c != null && !String.isEmpty(associatedRate.Rate_Name__c)) {
                    return associatedRate.Rate_Name__c;
                } else {
                    return '';
                }
            } set;
        }

        public Boolean isCustomName {
            get {
                return associatedRate.Rate__c == null || (associatedRate.Rate_Name__c != associatedRate.Rate__r.Rate_Name__c && associatedRate.Rate__r.Type__c != 'Access');
            }
            set;
        }

        public String description {
            get {
                if (associatedRate.Description__c != null && !String.isEmpty(associatedRate.Description__c)) {
                    return associatedRate.Description__c;
                } else {
                    return '';
                }
            }
            set;
        }

        public Boolean isCustomDescription {
            get {
                return associatedRate.Rate__c == null || associatedRate.Description__c != associatedRate.Rate__r.Description__c;
            }
            set;
        }

        public Boolean hasQuantity {
            get {
                return associatedRate.Quantity__c != null;
            }
            set;
        }

        public String quantity {
            get {
                if (this.hasQuantity) {
                    if (associatedRate.Quantity__c < 0)
                        return 'Unlimited';
                    if (associatedRate.Quantity__c == Math.floor(associatedRate.Quantity__c))
                        return associatedRate.Quantity__c.setScale(0).toPlainString();
                    else
                        return associatedRate.Quantity__c.setScale(2).toPlainString();
                } else {
                    return '1';
                }
            }
            set;
        }

        public Boolean isTiered {
            get {
                return associatedRate.Tier_Bundling__c != null && associatedRate.Tier_Bundling__c > 1;
            }
            set;
        }

        public Boolean isOverridden {
            get {
                return associatedRate.Override__c != null && associatedRate.Override__c != associatedRate.Default__c;
            }
            set;
        }

        public String originalRate {
            get {
                return formatRate(associatedRate.Default__c);
            }
            set;
        }

        public String plainRate {
            get {
                Decimal rate;
                if (isOverridden) {
                    rate = associatedRate.Override__c;
                } else if (associatedRate.Default__c == null) {
                    rate = 0.0;
                } else {
                    rate = associatedRate.Default__c;
                }
                return formatRate(rate);
            }
            set;
        }

        public String totc {
            get {
                Decimal rate;
                if (isOverridden) {
                    rate = associatedRate.Override__c;
                } else if (associatedRate.Default__c == null) {
                    rate = 0.0;
                } else {
                    rate = associatedRate.Default__c;
                }

                Decimal qty = 1;
                if (this.hasQuantity)
                    qty = associatedRate.Quantity__c;
                if (this.isTiered)
                    qty = Math.ceil(qty / associatedRate.Tier_Bundling__c);

                return formatRate(qty * rate);
            }
            set;
        }

        public String ppu {
            get {
                String ppu = '';

                if (termFrequency == null) return ppu;
                if (associatedRate.Override__c == null) return ppu;
                if (associatedRate.Rate__c == null) return ppu;
                if (associatedRate.Override__c == 0) return 'Included';
                if (this.isTiered) return ppu;

                if (associatedRate.Rate__r.Type__c == 'Sub' || associatedRate.Rate__r.Type__c == 'Bundle') {
                    ppu = associatedRate.CurrencyIsoCode;
                    ppu += ' ';
                    ppu += (associatedRate.Override__c * termFrequency).setScale(LICENSE_DECIMAL_PLACES);
                    ppu += ' / ' + iContract.formatTimeRecurrence(termFrequency);
                } else if (associatedRate.Rate__r.Type__c == 'Commit') {
                    ppu = associatedRate.CurrencyIsoCode + ' ' + associatedRate.Override__c.setScale(LICENSE_DECIMAL_PLACES) + ' / ' + iContract.formatTimeRecurrence(termFrequency);
                } else if (associatedRate.Rate__r.Type__c == 'Once') {
                    ppu = associatedRate.CurrencyIsoCode + ' ' + associatedRate.Override__c.setScale(LICENSE_DECIMAL_PLACES);
                }

                return ppu;
            }
            set;
        }

        public String mip {
            get {
                String mip = '';

                if (termFrequency == null) return ppu;
                if (associatedRate.Override__c == null) return mip;
                if (associatedRate.Rate__c == null) return mip;
                if (associatedRate.Override__c == 0) return '';

                Decimal qty = associatedRate.Quantity__c;
                if (qty < 0) qty = 1;
                if (this.isTiered)
                    qty = Math.ceil(qty / associatedRate.Tier_Bundling__c);

                if ((associatedRate.Rate__r.Type__c == 'Sub' || associatedRate.Rate__r.Type__c == 'Bundle') && qty != null) {
                    mip = associatedRate.CurrencyIsoCode;
                    mip += ' ';
                    mip += (qty * associatedRate.Override__c * termFrequency).setScale(LICENSE_DECIMAL_PLACES);
                    mip += ' / ' + iContract.formatTimeRecurrence(termFrequency);
                } else if (associatedRate.Rate__r.Type__c == 'Commit') {
                    mip = associatedRate.CurrencyIsoCode + ' ' + associatedRate.Override__c.setScale(LICENSE_DECIMAL_PLACES) + ' / ' + iContract.formatTimeRecurrence(termFrequency);
                }

                return mip;
            }
            set;
        }

        public String tsf {
            get {
                String tsfs = '';

                if (termFrequency == null) return ppu;
                if (termLength == null) return ppu;
                if (associatedRate.Override__c == null) return tsfs;
                if (associatedRate.Rate__c == null) return tsfs;
                if (associatedRate.Override__c == 0) return '';

                Decimal qty = associatedRate.Quantity__c;
                if (qty == null || qty < 0) qty = 1;
                if (this.isTiered && associatedRate.Tier_Bundling__c != null && associatedRate.Tier_Bundling__c != 0)
                    qty = Math.ceil(qty / associatedRate.Tier_Bundling__c);

                if ((associatedRate.Rate__r.Type__c == 'Sub' || associatedRate.Rate__r.Type__c == 'Bundle') && qty != null) {
                    tsfs = associatedRate.CurrencyIsoCode + ' ' + (qty * associatedRate.Override__c * termFrequency * (termLength / termFrequency)).setScale(LICENSE_DECIMAL_PLACES);
                } else if (associatedRate.Rate__r.Type__c == 'Commit') {
                    tsfs = associatedRate.CurrencyIsoCode + ' ' + (associatedRate.Override__c * (termLength / termFrequency)).setScale(LICENSE_DECIMAL_PLACES);
                }

                return tsfs;
            }
            set;
        }

        public String rate {
            get {
                Decimal qty = associatedRate.Quantity__c;
                if (this.isTiered)
                    qty = Math.ceil(qty / associatedRate.Tier_Bundling__c);

                String rateRecurrence = this.recurrence;
                if (rateRecurrence.equals('No Charge') || rateRecurrence.equals('Billable and will show as participant line')) {
                    if (this.hasQuantity) {
                        return String.valueOf(qty) + ' @ ' + rateRecurrence;
                    } else {
                        return rateRecurrence;
                    }
                }

                String result = '';
                if (this.hasQuantity) {
                    result += String.valueOf(qty) + ' * ';
                }

                result += this.plainRate;

                if (!rateRecurrence.equals('')) {
                    result += ' / ' + rateRecurrence;
                }
                return result;
            }
            set;
        }

        public String formatRate(Decimal rateToFormat) {
            if (rateToFormat == null)
                return '';
            String rateString = rateToFormat.setScale(RATE_DECIMAL_PLACES).toPlainString();
            // Try to only show 2 decimal places
            if (rateString.endsWith('00')) {
                rateString = this.currencyCode + ' ' + rateToFormat.setScale(2).toPlainString();
            } else {
                rateString = this.currencyCode + ' ' + rateString;
            }
            return rateString;
        }

        public String currencyCode {
            get { return associatedRate.CurrencyIsoCode; } set;
        }

        public String recurrence {
            get {
                if (associatedRate.Recurrence__c != null && !String.isEmpty(associatedRate.Recurrence__c)) {
                    return associatedRate.Recurrence__c;
                } else {
                    return '';
                }
            }
            set;
        }

        public Boolean isCustomRecurrence {
            get {
                return associatedRate.Rate__c == null || (associatedRate.Recurrence__c != associatedRate.Rate__r.Recurrence__c && associatedRate.Rate__r.Type__c != 'Access');
            }
            set;
        }

        public Boolean isDisabled {
            get {
                return this.associatedRate.Disabled__c != null && this.associatedRate.Disabled__c == true;
            }
            set;
        }

        // This is needed to sort the list of Rates by their name
        global Integer compareTo(Object compareTo) {
            RateData compareToRate = (RateData)compareTo;

            // Start with a very small Order for those that don't have one (custom ones)
            Double thisOrder = -999999.9;
            Double thatOrder = -999999.9;

            // Try to get the Order from the Rate
            if (this.associatedRate.Rate__c != null && this.associatedRate.Rate__r.Order__c != null)
                thisOrder = this.associatedRate.Rate__r.Order__c;
            if (compareToRate.associatedRate.Rate__c != null && compareToRate.associatedRate.Rate__r.Order__c != null)
                thatOrder = compareToRate.associatedRate.Rate__r.Order__c;

            // Ensure Access Type modifications come first
            if (this.associatedRate.Rate__r != null && this.associatedRate.Rate__r.Type__c == 'Access' && this.isOverridden)
                thisOrder = -999999999.9;
            if (compareToRate.associatedRate.Rate__r != null && compareToRate.associatedRate.Rate__r.Type__c == 'Access' && compareToRate.isOverridden)
                thatOrder = -999999999.9;

            Integer returnValue = 0; // equal
            if (thisOrder > thatOrder) {
                returnValue = 1;
            } else if (thisOrder < thatOrder) {
                returnValue = -1;
            } else {
                // equal, fall to alphabetical ordering
                String thisName = this.name;
                String thatName = compareToRate.name;
                if (thisName > thatName) {
                    returnValue = 1;
                } else if (thisName < thatName) {
                    returnValue = -1;
                }
            }
            return returnValue;
        }
    }

    global class RateGroupData implements Comparable {
        public Rate_Group__c rateGroup {get;set;}
        public List<RateData> rates {get;set;}

        public RateGroupData(Rate_Group__c rateGroup) {
            this.rateGroup = rateGroup;
            this.rates = new List<RateData>();
        }

        public void addAssociatedRate(Associated_Rate__c associatedRate, CONMAN_Contract__c agreement) {
            this.rates.add(new RateData(associatedRate, agreement));
        }

        public boolean hasRates {
            get {
                if (rates == null || rates.size() == 0)
                    return false;
                for (RateData rateData : rates)
                    if (!rateData.isDisabled)
                        return true;
                return false;
            }
            set;
        }

        public String header {
            get {
                if (rateGroup == null || rateGroup.Name == null)
                    return '';
                return rateGroup.Name;
            }
            set;
        }

        public boolean hasDescription {
            get {
                return rateGroup != null && rateGroup.Description__c != null && rateGroup.Description__c.equals('') == false;
            }
            set;
        }

        public String description {
            get {
                if (!hasDescription)
                    return '';
                return rateGroup.Description__c;
            }
            set;
        }

        public boolean hasFooter {
            get {
                return rateGroup != null && rateGroup.Footer__c != null && rateGroup.Footer__c.equals('') == false;
            }
            set;
        }

        public String footer {
            get {
                if (!hasFooter)
                    return '';
                return rateGroup.Footer__c;
            }
            set;
        }

        public boolean createNewPage {
            get {
                return rates.size() > 40;
            }
            set;
        }

        public void sort() {
            this.rates.sort();
        }

        // This is needed to sort the list of Rate Groups by their name
        global Integer compareTo(Object compareTo) {
            RateGroupData compareToRateGroup = (RateGroupData)compareTo;

            // Start with a very small Order for those that don't have one (custom ones)
            Double thisOrder = -999999.9;
            Double thatOrder = -999999.9;

            // Try to get the Order from the Rate Group
            if (this.rateGroup != null && this.rateGroup.Order__c != null)
                thisOrder = this.rateGroup.Order__c;
            if (compareToRateGroup.rateGroup != null && compareToRateGroup.rateGroup.Order__c != null)
                thatOrder = compareToRateGroup.rateGroup.Order__c;

            Integer returnValue = 0; // equal
            if (thisOrder > thatOrder) {
                returnValue = 1;
            } else if (thisOrder < thatOrder) {
                returnValue = -1;
            } else {
                // equal, fall to alphabetical ordering
                String thisName = this.header;
                String thatName = compareToRateGroup.header;
                if (thisName > thatName) {
                    returnValue = 1;
                } else if (thisName < thatName) {
                    returnValue = -1;
                }
            }
            return returnValue;
        }
    }

    global class AccessTypeData implements Comparable {
        public Rate_Group__c rateGroup {get;set;}
        public List<String> locationOrders {get;set;}
        public Map<String, List<RateData>> locations {get;set;}
        public List<SingleGridData> gridData {get;set;}

        public AccessTypeData(Rate_Group__c rateGroup) {
            this.rateGroup = rateGroup;
            this.locationOrders = new List<String>();
            this.locations = new Map<String, List<RateData>>();
            this.gridData = new List<SingleGridData>();
        }

        public void addAssociatedRate(Associated_Rate__c associatedRate, CONMAN_Contract__c agreement) {
            if (!this.locations.containsKey(associatedRate.Rate_Name__c))
                this.locations.put(associatedRate.Rate_Name__c, new List<RateData>());
            this.locations.get(associatedRate.Rate_Name__c).add(new RateData(associatedRate, agreement));
        }

        public String header {
            get {
                if (rateGroup == null || rateGroup.Name == null)
                    return '';
                return rateGroup.Name;
            }
            set;
        }

        public boolean hasDescription {
            get {
                return rateGroup != null && rateGroup.Description__c != null && rateGroup.Description__c.equals('') == false;
            }
            set;
        }

        public String description {
            get {
                if (!hasDescription)
                    return '';
                return rateGroup.Description__c;
            }
            set;
        }

        public boolean hasFooter {
            get {
                return rateGroup != null && rateGroup.Footer__c != null && rateGroup.Footer__c.equals('') == false;
            }
            set;
        }

        public String footer {
            get {
                if (!hasFooter)
                    return '';
                return rateGroup.Footer__c;
            }
            set;
        }

        public integer grids {
            get {
                return rateGroup == null || rateGroup.Multi_Grid__c == null ? 1 : Math.round(rateGroup.Multi_Grid__c);
            }
            set;
        }

        public integer locationCount {
            get {
                return this.locations.size();
            }
            set;
        }
        
        public integer visibleGrids {
            get {
                integer vGrids = Math.round(grids);

                // Split grids only if there's enough to fill them out with 2+ rates in each
                if (locationCount < 4)
                    vGrids = 1;
                if (locationCount < 8)
                    vGrids = Math.min(vGrids, 2);
                if (locationCount < 12)
                    vGrids = Math.min(vGrids, 3);
                if (locationCount < 16)
                    vGrids = Math.min(vGrids, 4);
                if (locationCount < 20)
                    vGrids = Math.min(vGrids, 5);

                return vGrids;
            }
            set;
        }

        public integer gridPercentWidth {
            get { return Math.round(1.0 / visibleGrids * 100.0); } set;
        }

        public boolean createNewPage {
            get {
                return (locationCount / visibleGrids) > 60;
            }
            set;
        }

        public void sort() {
            Map<String, String> foundLocations = new Map<String, String>();

            this.locationOrders.clear();
            this.gridData.clear();

            if (locationCount <= 0) return;

            for (String location : this.locations.keySet()) {
                boolean overridden = false;
                for (RateData rate : this.locations.get(location)) {
                    if (overridden)
                        break;
                    else if (rate.isOverridden)
                        overridden = true;
                }

                if (overridden)
                    foundLocations.put('000 - ' + location, location);
                else
                    foundLocations.put(location, location);
            }

            List<String> foundLocationRates = new List<String>(foundLocations.keySet());
            foundLocationRates.sort();
            for (String rate : foundLocationRates)
                this.locationOrders.add(foundLocations.get(rate));

            // Could be too few (i.e. 11 = 23 / 2; (11 + 11) vs (12 + 11))
            integer ratesPerGrid = locationCount / visibleGrids;
            integer extraRates = Math.mod(locationCount, ratesPerGrid);

            // Clone elements so we can delete from them
            List<String> gridLocations = new List<String>(this.locationOrders);

            // Create a new list of RateData for each grid
            for (integer indexGrid = 0; indexGrid < visibleGrids; indexGrid++) {
                SingleGridData singleGrid = new SingleGridData();

                // Ensure correct amount of rates in each grid
                integer ratesThisGrid = ratesPerGrid;
                if (extraRates >= 1) {
                    ratesThisGrid += 1;
                    extraRates -= 1;
                }

                // Add all extra rates on last grid (shouldn't happen)
                if (extraRates >= 1 && indexGrid == visibleGrids-1) {
                    ratesThisGrid += extraRates;
                    extraRates = 0;
                }

                for (integer rateInGrid = 0; rateInGrid < ratesThisGrid; rateInGrid++) {
                    String location = gridLocations.get(0);

                    List<RateData> locationData = this.locations.get(gridLocations.get(0));
                    for (RateData rate : locationData)
                        singleGrid.addRate(rate);

                    gridLocations.remove(0);
                }

                singleGrid.sort();
                gridData.add(singleGrid);
            }
        }

        // This is needed to sort the list of Rate Groups by their name
        global Integer compareTo(Object compareTo) {
            AccessTypeData compareToAccessType = (AccessTypeData)compareTo;

            // Start with a very small Order for those that don't have one (custom ones)
            Double thisOrder = -999999.9;
            Double thatOrder = -999999.9;

            // Try to get the Order from the Rate Group
            if (this.rateGroup != null && this.rateGroup.Order__c != null)
                thisOrder = this.rateGroup.Order__c;
            if (compareToAccessType.rateGroup != null && compareToAccessType.rateGroup.Order__c != null)
                thatOrder = compareToAccessType.rateGroup.Order__c;

            Integer returnValue = 0; // equal
            if (thisOrder > thatOrder) {
                returnValue = 1;
            } else if (thisOrder < thatOrder) {
                returnValue = -1;
            } else {
                // equal, fall to alphabetical ordering
                String thisName = this.header;
                String thatName = compareToAccessType.header;
                if (thisName > thatName) {
                    returnValue = 1;
                } else if (thisName < thatName) {
                    returnValue = -1;
                }
            }
            return returnValue;
        }
    }

    global class SingleGridData {
        public List<String> accessTypes {get;set;}
        public List<String> locationOrders {get;set;}
        public Map<String, Boolean> locationsOverridden {get;set;}
        public Map<String, Map<String, RateData>> locations {get;set;}
        public Map<String, Map<String, Boolean>> hasGridData {get;set;}

        public SingleGridData() {
            this.accessTypes = new List<String>();
            this.locationOrders = new List<String>();
            this.locationsOverridden = new Map<String, Boolean>();
            this.locations = new Map<String, Map<String, RateData>>();
            this.hasGridData = new Map<String, Map<String, Boolean>>();
        }

        public void addRate(RateData rate) {
            if (!this.locations.containsKey(rate.associatedRate.Rate_Name__c))
                this.locations.put(rate.associatedRate.Rate_Name__c, new Map<String, RateData>());
            this.locations.get(rate.associatedRate.Rate_Name__c).put(rate.associatedRate.Rate__r.Rate_Name__c, rate);
        }

        public integer gridLocationColumnPercentWidth {
            get {
                integer columns = this.accessTypes.size();
                if (columns == 1) return 70;
                if (columns == 2) return 40;
                if (columns == 3) return 40;
                if (columns == 4) return 32;
                if (columns == 5) return 30;
                return 20;
            } set;
        }

        public integer gridColumnPercentWidth {
            get {
                integer columns = this.accessTypes.size();
                if (columns == 1) return 30;
                if (columns == 2) return 30;
                if (columns == 3) return 20;
                if (columns == 4) return 17;
                if (columns == 5) return 14;
                return 12;
            } set;
        }

        public void sort() {
            Map<String, RateData> foundAccessTypes = new Map<String, RateData>();
            Map<String, String> foundLocations = new Map<String, String>();

            this.locationsOverridden.clear();
            this.accessTypes.clear();
            this.locationOrders.clear();
            this.hasGridData.clear();

            Integer locationCount = this.locations.size();

            if (locationCount <= 0) return;

            for (String location : this.locations.keySet()) {
                Map<String, RateData> locationRates = this.locations.get(location);
                boolean overridden = false;
                for (String accessType : locationRates.keySet()) {
                    RateData rate = locationRates.get(accessType);
                    foundAccessTypes.put(accessType, rate);
                    if (rate.isOverridden)
                        overridden = true;
                }

                if (overridden)
                    foundLocations.put('000 - ' + location, location);
                else
                    foundLocations.put(location, location);
                this.locationsOverridden.put(location, overridden);
            }

            List<RateData> foundAccessTypeRates = foundAccessTypes.values();
            foundAccessTypeRates.sort();
            for (RateData rate : foundAccessTypeRates)
                this.accessTypes.add(rate.associatedRate.Rate__r.Rate_Name__c);

            List<String> foundLocationRates = new List<String>(foundLocations.keySet());
            foundLocationRates.sort();
            for (String rate : foundLocationRates)
                this.locationOrders.add(foundLocations.get(rate));

            for (String location : this.locations.keySet()) {
                if (!hasGridData.containsKey(location))
                    hasGridData.put(location, new Map<String, Boolean>());

                Map<String, RateData> locationData = this.locations.get(location);
                for (String accessType : this.accessTypes)
                    hasGridData.get(location).put(accessType, locationData.containsKey(accessType));
            }
        }
    }

    global class VerbiageData implements Comparable {
        public CONMAN_Contract_Verbiage__c contractVerbiage {get;set;}

        public VerbiageData(CONMAN_Contract_Verbiage__c contractVerbiage) {
            this.contractVerbiage = contractVerbiage;
        }

        public String id {
            get { return contractVerbiage.Id; } set;
        }

        public String originalId {
            get {
                if (contractVerbiage.Contract_General_Content__c != null)
                    return contractVerbiage.Contract_General_Content__c;
                if (contractVerbiage.Contract_Product_Verbiage__c != null)
                    return contractVerbiage.Contract_Product_Verbiage__c;
                return '';
            } set;
        }

        public String name {
            get {
                if (contractVerbiage.Name != null && !String.isEmpty(contractVerbiage.Name)) {
                    return contractVerbiage.Name;
                } else {
                    return '';
                }
            } set;
        }

        public Boolean isCustomName {
            get {
                if (contractVerbiage.Contract_Product_Verbiage__c == null && contractVerbiage.Contract_General_Content__c == null)
                    return true;
                if (contractVerbiage.Contract_General_Content__c != null)
                    return contractVerbiage.Name != contractVerbiage.Contract_General_Content__r.Name;
                if (contractVerbiage.Contract_Product_Verbiage__c != null)
                    return contractVerbiage.Name != contractVerbiage.Contract_Product_Verbiage__r.Name;
                return true;
            }
            set;
        }

        public String verbiage {
            get {
                if (contractVerbiage.Verbiage__c != null && !String.isEmpty(contractVerbiage.Verbiage__c)) {
                    return contractVerbiage.Verbiage__c;
                } else {
                    return '';
                }
            }
            set;
        }

        public Boolean isCustomVerbiage {
            get {
                if (contractVerbiage.Contract_Product_Verbiage__c == null && contractVerbiage.Contract_General_Content__c == null){
                    return true;
                }
                if (contractVerbiage.Contract_General_Content__c != null) {
                    return contractVerbiage.Verbiage__c != contractVerbiage.Contract_General_Content__r.Content_RTF__c;
                }
                if (contractVerbiage.Contract_Product_Verbiage__c != null){
                    return contractVerbiage.Verbiage__c != contractVerbiage.Contract_Product_Verbiage__r.Terms_and_Conditions_RTF__c;
                }
                return false;
            }
            set;
        }

        // This is needed to sort the list of Verbiage by their order
        global Integer compareTo(Object compareTo) {
            VerbiageData compareToVerbiage = (VerbiageData)compareTo;

            Integer returnValue = 0; // equal
            if (this.contractVerbiage.Order__c > compareToVerbiage.contractVerbiage.Order__c) {
                returnValue = 1;
            } else if (this.contractVerbiage.Order__c < compareToVerbiage.contractVerbiage.Order__c) {
                returnValue = -1;
            }

            return returnValue;
        }
    }
    // RT-567
    public string xmlheader {get;set;}

    public string endfile{get;set;}

    public List<string> listString{get;set;}
    
    // Determines what kind of rendering to use for the page request
    public String renderingService {
        get {
            Map<String, String> params = ApexPages.currentPage().getParameters();
            if (params.containsKey('pdfShow') || params.containsKey('pdfDownload')) {
                return 'pdf';
            } else if (params.containsKey('wordShow') || params.containsKey('wordDownload')) {
                isExcel=false;
                return '';
            } 
            // RT-567 excelll
            else if (params.containsKey('excelShow') || params.containsKey('excelDownload') ){
                isExcel=true;
                return '';
            }
            else {
                isExcel=false;
                return 'html';
            }
        }
        private set;
    }

    // Rendered content MIME type, used to affect HTTP response
    public String renderedContentType {
        get {
            String renderedContentType = 'text/html'; // the default text/html

            if( this.renderingAsPDF ) {
                // Provides a MIME type for a PDF document
                renderedContentType = 'application/pdf';

                // Add a file name for the PDF file
                // This is supposed to set the file name, but it doesn't work
                renderedContentType += '#contract.pdf';

                // This is a work-around to set the file name
                ApexPages.currentPage().getHeaders().put(
                    'content-disposition', 'attachment; filename=contract.pdf');
            } else if(this.renderingAsWord) {

                 // Provides a MIME type for a Word document
                renderedContentType = 'application/msword';

                // Add a file name for the Word file
                // This is supposed to set the file name
                renderedContentType += '#contract.doc';

            }
            else if(this.renderingAsExcel) {

                // Provides a MIME type for a excel document
               renderedContentType = 'application/vnd.ms-excel';

               // Add a file name for the Excel file
               // This is supposed to set the file name
               renderedContentType += '#contract.xls';

           }
           System.debug('The content Type is'+renderedContentType);
            return renderedContentType;
        }
    }

    // Determines how big the font should be for either mode
    public String fontSize {
        get {
            if (this.renderingAsHtml) {
                return '13';
            } else {
                return '9';
            }
        }
        private set;
    }

    // Determines the background Color
    public String backgroundColor {
        get {
            if (this.renderingAsHtml && contract != null && contract.Word_File_In_Use__c) {
                return '#808080';
            } else {
                return '';
            }
        }
        private set;
    }

    // Determines the text Color
    public String textColor {
        get {
            if (this.renderingAsHtml && contract != null && contract.Word_File_In_Use__c) {
                return '#FFFFFF';
            } else {
                return '';
            }
        }
        private set;
    }

    // Determines the background Color
    public String tableHeaderBackgroundColor {
        get {
            if (this.renderingAsHtml && contract != null && contract.Word_File_In_Use__c) {
                return '#808080';
            } else {
                return '#F8F8F8';
            }
        }
        private set;
    }

    // Determines the text Color
    public String tableHeaderTextColor {
        get {
            if (this.renderingAsHtml && contract != null && contract.Word_File_In_Use__c) {
                return '#FFFFFF';
            } else {
                return '#000000';
            }
        }
        private set;
    }

    

    // Determines whether or not eSignature can be used because of Closed Won fields
    public Boolean canSubmitEsignature {
        get {
            // commented due to RT-573 if Competitor_s__c.contains('Other') or .Incumbent__c.contains('Other') and if Competitor_Other_Product__c or Incumbent_Other_Product__c null then have to update
            // return oppData.Primary_Won_Reason__c != null && oppData.Competitor_s__c != null && oppData.Incumbent__c != null &&
            // oppData.Differentiating_Win_Factors__c != null  && oppData.Primary_Won_Reason__c != '' && 
            // oppData.Competitor_s__c != '' && oppData.Incumbent__c != '' && oppData.Differentiating_Win_Factors__c != '';

            if(oppData.Primary_Won_Reason__c != null && oppData.Competitor_s__c != null && oppData.Incumbent__c != null &&
            oppData.Differentiating_Win_Factors__c != null  && oppData.Primary_Won_Reason__c != '' && 
            oppData.Competitor_s__c != '' && oppData.Incumbent__c != '' && oppData.Differentiating_Win_Factors__c != ''){
                // RT-573 Added if contains others
                if(oppData.Competitor_s__c.contains('Other') && oppData.Competitor_Other_Product__c == null){
                    return false;
                }
                else if(oppData.Incumbent__c.contains('Other') && oppData.Incumbent_Other_Product__c == null){
                    return false;
                }
                else{
                    return true;
                }
            }
           return false;
        }
        private set;
    }

    // Determines whether or not the download button should be enabled
    public Boolean canDownloadPDF {
        get {
            return this.cannotDownloadPDFReason == '';
        }
        private set;
    }
    public Boolean canDownloadQuotePDF {
        get {
            return this.cannotDownloadQuotePDFReason == '';
        }
        private set;
    }
    public Pagereference toggleLongForm() {
        CONMAN_Contract__c contractUpdate = new CONMAN_Contract__c(Id = this.Contract.Id);
        if(this.contract.Intl_Order_Type__c == 'Long Form' || String.isBlank(this.contract.Intl_Order_Type__c)) {
            contractUpdate.Intl_Order_Type__c = 'Short Form';
        } else {
            contractUpdate.Intl_Order_Type__c = 'Long Form';
        }
        this.contract.Intl_Order_Type__c = contractUpdate.Intl_Order_Type__c; 
        update contract;
        iContract_NA_Master_Controller_init();
        return null;
    }
    public Boolean longForm {get {
        //RT-518 iContract users in India (not contacts) should only be allowed to use “short form” .(Vijay),also default to sort form
        if(isUserIndia){
            return false;
        }
        else{
            return String.isBlank(this.contract.Intl_Order_Type__c) ||  this.contract.Intl_Order_Type__c == 'Long Form';
        }
        
    } set;}

    // Message to show if the download button should be disabled
    public String cannotDownloadPDFReason {
        get {
            if (contract == null || contract.Contract_Status__c == null) {
                return 'Unknown Contract Status';
            } else if (approvalStep != null && !String.isEmpty(approvalStep)) {
                return 'Pending Approval: ' + approvalStep;
            } else if (contract.Contract_Status__c == 'Contract Pricing Rejected' ||
                       contract.Contract_Status__c == 'Awaiting Approval' ||
                       contract.Contract_Status__c == 'Awaiting Manager Approval' ||
                       contract.Contract_Status__c == 'Awaiting RVP Approval' ||
                       contract.Contract_Status__c == 'Awaiting SVP Approval' ||
                       contract.Contract_Status__c == 'Pending Pricing Approval' ||
                       contract.Contract_Status__c == 'Pending Legal Approval' ||
                       contract.Contract_Status__c == 'Legal Rejected' ||
                       contract.Contract_Status__c == 'Pending Approval' ||
                       contract.Contract_Status__c == 'Rejected') {
                return contract.Contract_Status__c;
            } else if (contract.Required_Approval_ARG__c) {
                return 'Will need Pricing Approval from the ARG Channel Managers, please continue in iContract to start it.';
            } else if (contract.Required_Approval_Deal_Desk__c) {
                return 'Will need Pricing Approval from the Deal Desk, please continue in iContract to start it.';
            } else if (contract.Required_Approval_Pricing_Manager__c) {
                return 'Will need Pricing Approval from ' + contract.Submitters_Manager__c + ', please continue in iContract to start it.';
            } else if (contract.Required_Approval_Pricing_RVP__c) {
                return 'Will need Pricing Approval from your RVP, please continue in iContract to start it.';
            } else if (contract.Required_Approval_Pricing_SVP__c) {
                return 'Will need Pricing Approval from your SVP, please continue in iContract to start it.';
            } else if (contract.Required_Approval_Legal__c) {
                return 'Will need Legal Approval, please continue in iContract to start it.';
            } else if (contract.Required_Approval_Billing__c) {
                return 'Will need Billing Approval, please continue in iContract to start it.';
            } else if (contract.Word_File_In_Use__c) {
                return 'Deal Desk or Legal has converted this into a Word Document, ' +
                    'so this preview is no longer accurate. Please look ' +
                    'for the PDF generated by Legal in the Notes & Attachments ' +
                    'area of the PGi Contract in Salesforce.';
            } else if (errormsg != null && errormsg != '') {
                return 'See error mesage above.';
            }
            return '';
        }
        private set;
    }

    // Message to show if the download button should be disabled (quotes)
    public String cannotDownloadQuotePDFReason {
        get {
            if (contract == null || contract.Contract_Status__c == null) {
                return 'Unknown Contract Status';
            } else if (approvalStep != null && !String.isEmpty(approvalStep)) {
                if (approvalStep == 'Legal')
                    return ''; // Quotes can be downloaded during Legal Approval
                else
                    return 'Pending Approval: ' + approvalStep;
            } else if (contract.Contract_Status__c == 'Contract Pricing Rejected' ||
                       contract.Contract_Status__c == 'Awaiting Approval' ||
                       contract.Contract_Status__c == 'Awaiting Manager Approval' ||
                       contract.Contract_Status__c == 'Awaiting RVP Approval' ||
                       contract.Contract_Status__c == 'Awaiting SVP Approval' ||
                       contract.Contract_Status__c == 'Pending Pricing Approval' ||
                       contract.Contract_Status__c == 'Legal Rejected' ||
                       contract.Contract_Status__c == 'Pending Approval' ||
                       contract.Contract_Status__c == 'Rejected') {
                return contract.Contract_Status__c;
            } else if (contract.Required_Approval_ARG__c) {
                return 'Will need Pricing Approval from the ARG Channel Managers, please continue in iContract to start it.';
            } else if (contract.Required_Approval_Deal_Desk__c) {
                return 'Will need Pricing Approval from the Deal Desk, please continue in iContract to start it.';
            } else if (contract.Required_Approval_Pricing_Manager__c) {
                return 'Will need Pricing Approval from ' + contract.Submitters_Manager__c + ', please continue in iContract to start it.';
            } else if (contract.Required_Approval_Pricing_RVP__c) {
                return 'Will need Pricing Approval from your RVP, please continue in iContract to start it.';
            } else if (contract.Required_Approval_Pricing_SVP__c) {
                return 'Will need Pricing Approval from your SVP, please continue in iContract to start it.';
            } else if (contract.Required_Approval_Billing__c) {
                return 'Will need Billing Approval, please continue in iContract to start it.';
            } else if (contract.Word_File_In_Use__c) {
                return 'Legal has converted this into a Word Document, ' +
                    'so this preview is no longer accurate. Please look ' +
                    'for the PDF generated by Legal in the attachments ' +
                    'area at the bottom of the page';
            } else if (errormsg != null && errormsg != '') {
                return 'See error mesage above.';
            }
            return '';
        }
        private set;
    }

    public boolean isAddressValid {
        get {
            return contactData != null && contactData.MailingCountry != null;
        }
        private set;
    }

    public boolean isAddressNAM {
        get {
            return isAddressValid; /*&& (contactData.MailingCountry.equalsIgnoreCase('United States') || contactData.MailingCountry.equalsIgnoreCase('Canada'));*/
        }
        private set;
    }

    // Exemptions
    public boolean isExemptTelecomSurcharge {
        get {
            return contract.Exempt_Telecom_Surcharge__c;
        }
        private set;
    }
    public boolean isExemptServiceFee {
        get {
            return contract.Exempt_Service_Fee__c;
        }
        private set;
    }

    // Are we rendering to HTML or PDF?
    public Boolean renderingAsHtml {
        get {
            return ( (renderingService == null) ||
                     ( renderingService.equals('html')) );
        }
        private set;
    }

     // Are we rendering to PDF?
    public Boolean renderingAsPDF {
        get {
            return ( ( renderingService.equals('pdf')) );
        }
        private set;
    }

     // Are we rendering to word doc?
    public Boolean renderingAsWord {
        get {
            return ( ( renderingService.equals('') && !isExcel) );
        }
        private set;
    }
    //Excel RT567
    public Boolean renderingAsExcel {
        get {
            return ( ( renderingService.equals('') && isExcel) );
        }
        private set;
    }

   
    // Determines whether or not to allow exporting as a Word File
    public Boolean canExportWord {
        get {
            if (hasLegalPermission() || hasPricingPermission() || (this.userProfile != null && this.userProfile == 'System Administrator')) {
                return true;
            } else {
                return false;
            }
        }
        private set;
    }

    // Determines whether or not to allow inline editing of all T&Cs
    public Boolean canEditVerbiage {
        get {
            if (hasLegalPermission() || (this.userProfile != null && this.userProfile == 'System Administrator')) {
                return true;
            } else {
                return false;
            }
        }
        private set;
    }

    // Determines whether or not to allow inline editing of product T&Cs and pricing
    public Boolean canEditPricing {
        get {
            if (hasPricingPermission() || (this.userProfile != null && this.userProfile == 'System Administrator')) {
                return true;
            } else {
                return false;
            }
        }
        private set;
    }

    // What Region the agreement is for
    public String agreementRegion {
        get {
            if (contactData == null || contactData.MailingCountry == null){
                return 'US';
            }
            System.debug('country>>>'+contactData.MailingCountry);
            String region  = CountryUtil.getCountryRegion(contactData.MailingCountry);
            if(region == '' ){
                return 'US';
            } else {
                return region;
            }
        }
        private set;
    }
    // Get PGi Internal Entity Name RT-440
    public PGi_Internal_Entity__c pgiInternalEntity {
        get {
            if (contract.PGi_Internal_Entity__c != null){
                return [SELECT Id,Name,Legal_Entity_Name__c,Address_1__c,Address_2__c,Business_Registration__c,City__c,Country__c,State__c,Zip_Postal_Code__c 
                FROM PGi_Internal_Entity__c 
                WHERE Id=: contract.PGi_Internal_Entity__c];
            }
            else{
                return new PGi_Internal_Entity__c();
            }
        }
        private set;

    }
    // What type of Contract is this
    public String contractTitle {
        get {
            if (oppData == null || oppData.Type == null) {
                return 'Unknown Opportunity';
            }
            if (oppData.Type == 'Existing Cust- Existing Svc') {
                return 'PGi Amendment';
            }
            return 'PGi Subscription License Order';
        }
        private set;
    }

    // Address information
    public String pgiAddress {
        get {
            if (agreementRegion.equals('CAN'))
                return '3250 Bloor St. W, East Tower Suite 400, Toronto, ON  M8X 2X9';
            return '2300 Lakeview Parkway, Suite 300, Alpharetta, GA 30009';
        }
        private set;
    }

    // Company information
    public String pgiName {
        get {
            //PGi Legal Entity name on the contracts to be replaced with the PGi Internal Entity Name that is set on the PGi Contract.
            //RT-473 (Tim told to add Pgi Internal Entity Name)
            if(contract.PGi_Internal_Entity__c != null){
                return pgiInternalEntity.Legal_Entity_Name__c;
            }
            if (hasUCaaS){
                return 'Premiere Conferencing Networks, Inc. d/b/a Premiere Global Services';
            }
            
            if (agreementRegion.equals('CAN')) {
                return 'Premiere Conferencing (Canada) Limited d/b/a Premiere Global Services';
            }
            if (agreementRegion.equals('EMEA')) {
                return 'Premiere Conferencing (Ireland) Limited d/b/a PGi';
            }
            
            return 'American Teleconferencing Services, Ltd. d/b/a Premiere Global Services';
        }
        private set;
    }

    // Agreement Currency
    public String agreementCurrencyCode {
        get {
            String currencyCode = '';
            if (this.hasLicenseData) {
                for (LicenseData ld : this.licenseData) {
                    currencyCode = ld.licenseSet.CurrencyIsoCode;
                    break;
                }
            }
            return currencyCode;
        }
        private set;
    }

    public String termLength {
        get {
            Decimal term = this.contract.Contracted_Term__c;
            if (term == null) return 'N/A';
            return iContract.formatTimeRange(this.contract.Contracted_Term__c);
        }
        set;
    }

    //whether or not the contract has Product Verbiage
    public Boolean hasProductVerbiage {
        get {
            if (sortedContractVerbiage != null && sortedContractVerbiage.size() > 0) {
                return true;
            } else {
                return false;
            }
        }
        private set;
    }

    // whether or not the contract has licensesets
    public Boolean hasLicenseData {
        get {
            return licenseData != null && licenseData.size() > 0;
        }
        private set;
    }

    // whether or not the contract has subscriptions
    public Boolean hasSubscriptions {
        get {
            if (hasLicenseData) {
                boolean subs = false;
                for (LicenseData ld : licenseData) {
                    if (ld.subscriptions != null && ld.subscriptions.size() > 0) {
                        subs = true;
                        break;
                    }
                }
                return subs;
            } else {
                return false;
            }
        }
        private set;
    }

    // whether or not the contract has one time charges
    public Boolean hasOneTimeCharges {
        get {
            if (hasLicenseData) {
                boolean charges = false;
                for (LicenseData ld : licenseData) {
                    if (ld.oneTimeCharges != null && ld.oneTimeCharges.size() > 0) {
                        charges = true;
                        break;
                    }
                }
                return charges;
            } else {
                return false;
            }
        }
        private set;
    }
    // whether or not the contract has UCaaS
    public Boolean hasUCaaS {
        get {
            if (hasLicenseData) {
                boolean uc = false;
                for (LicenseData ld : licenseData) {
                    if (ld.licenseSet != null && ld.licenseSet.Enterprise_Name__c != null && ld.licenseSet.Enterprise_Name__r.Family__c != null && ld.licenseSet.Enterprise_Name__r.Family__c.contains('UCaaS')) {
                        uc = true;
                        break;
                    }
                }
                return uc;
            } else {
                return false;
            }
        }
        private set;
    }

    // whether or not to show a Quote
    public Boolean isQuote {
        get {
            //RT-561
            if(isTPX){
                return true;
            }
            else{
            Map<String, String> params = ApexPages.currentPage().getParameters();
            return params.containsKey('showQuote');
            }
            
        }
        private set;
    }
    public Boolean isCSA {
        get {
            System.debug('The ID>>>123>>>>'+this.contract.Language__c);
            return contract.Contract_Type__c != null && contract.Contract_Type__c == 'Service Agreement';
        }
        private set;
    }
    public Boolean isTPX {
        get {
            System.debug('The Incubents'+isIncumbentOther);
            System.debug('The Profile'+isProfileMatch);
            System.debug('The competetors'+isCompetitorOther);
            return contract.Contract_Type__c != null && contract.Contract_Type__c == 'TPx Service Agreement';
        }
        private set;
    }
    // document type
    public Boolean isSLO {
        get {
            return contract.Contract_Type__c != null && contract.Contract_Type__c == 'Subscription License Order';
        }
        private set;
    }

    // document type
    public Boolean isSLA {
        get {
            return contract.Contract_Type__c != null && contract.Contract_Type__c == 'Subscription License Agreement';
        }
        private set;
    }
    public String baseUrl {
        get {
            string baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            
            return baseUrl;
        }
        private set;
    }
    public Id orgId {
        get {
            return [SELECT id FROM Organization].Id;
        }
        private set;
    }
    public String expirationDate {
        get {
            String dateFormat ='MMMM dd, YYYY';
            List<Country__c> countryDateFormatList = [SELECT Date_Format__c FROM Country__c WHERE Name =: country];
            if(!countryDateFormatList.isEmpty() && String.isNotBlank(countryDateFormatList[0].Date_Format__c)){
               dateFormat = countryDateFormatList[0].Date_Format__c;
            }
            Integer d = System.today().day();
            Integer mo = System.today().month(); 
            Integer yr = System.today().year();
            if(contract.Expiration_Date__c != null) {
                d = contract.Expiration_Date__c.day();
                mo = contract.Expiration_Date__c.month();
                yr = contract.Expiration_Date__c.year();
            }

            DateTime DT = DateTime.newInstance(yr, mo, d);
            String dateStr = DT.format(dateFormat);
        return dateStr;
        }
        set;
    }

    // document type
    public Boolean isAmendment {
        get {
            return contract.Contract_Type__c != null && contract.Contract_Type__c == 'Amendment';
        }
        private set;
    }

    // document type
    public Boolean isRateChange {
        get {
            return contract.Contract_Type__c != null && contract.Contract_Type__c == 'Rate Modification Amendment';
        }
        private set;
    }

    // PDF filename input on the page for saving the attachment
    public String pdfFilename {
        get {
            if (pdfFilename == null || String.isEmpty(pdfFilename)) {
                if (contract.Title__c == null || String.isEmpty(contract.Title__c)) {
                    return contractTitle;
                } else {
                    return contract.Title__c;
                }
            } else {
                return pdfFilename;
            }
        }
        set;
    }

    // Whether this is accessed from SF or through the public Site
    public boolean isPartnerSite {
        get {
            String siteUrl = Site.getBaseUrl();
            return siteUrl != null & !String.isEmpty(siteUrl);
        }
        set;
    }

    // Whether this is created by a Partner or PGi Sales user
    public boolean isPartnerAgreement {
        get {
            return contract.Owner_Type__c == 'ARG Partner Connect';
        }
        set;
    }

    // Stuff that goes in the URL after the hostname part
    public String endpointName {
        get {
            String path = '';
            if (this.isPartnerSite) {
                path += '/icontractpartners/icontract_na_master?pk=' + EncodingUtil.urlencode(ApexPages.currentPage().getParameters().get('pk'), 'UTF-8');
            } else {
                path += '/apex/iContract_NA_Master?id=' + contract.Id;
            }
            if (this.isQuote)
                path += '&showQuote=true';
            return path;
        }
        set;
    }


    // Sales Rep (or Partner) info to show on Agreements
    public String salesRepName {get; private set;}
    public String salesRepPhone {get; private set;}
    public String salesRepFax {get; private set;}
    public String salesRepTerritoryCode {
        get {
            if (oppData.Territory_Code__c != null)
                return '(' + oppData.Territory_Code__c + ')';
            else
                return '';
        }
        set;
    }

    // any error messages to show on the page
    public String errormsg {get; private set;}
    public Boolean isPageRenderable {get; private set;}

    // approval info
    public String approvalStep {get; private set;}

    // all products for simpler rate logic
    public List<LicenseData> licenseData {get; private set;}

    // quote-related items
    public String quoteTotal {get;private set;}
    public String openPopupURL {
        get {
            Map<String, String> params = ApexPages.currentPage().getParameters();
            if(  params.containsKey('openPopupURL')){return params.get('openPopupURL');}
            else{return null;}
        }
        private set;}

    // need to store which item on the page was activated with a button
    public String actOnLicenseSetId {get; set;}
    public String actOnAssociatedRateId {get; set;}
    public String actOnRateGroup {get; set;}

    // separated verbiage for placing in the proper areas
    public List<VerbiageData> sortedTableContractVerbiage {get; private set;}
    public List<VerbiageData> sortedContractVerbiage {get; private set;}
    public List<VerbiageData> firstPageVerbiage {get; private set;}
    public List<VerbiageData> signingVerbiage {get; private set;}
    //RT-561
    public List<VerbiageData> tpxVerbiage {get; private set;}

    // eSign
    public Map<Id, String> eSignTemplates {get; private set;}
    public String eSignTemplate {get; set;}
    public List<echosign_dev1__SIGN_Agreement__c> eSigns {get; set;}
    public boolean hasESigns {
        get {
            return eSigns != null && eSigns.size() > 0;
        }
        private set;
    }

    public String userProfile {get; private set;}
    public CONMAN_Contract__c contract {get; set;}
    public User repData {get; private set;}
    public Contact contactData {get; private set;}
    public Opportunity oppData {get; private set;}

    // Two Contructors to work as Controller or Extension 

    public iContract_NA_Master_Controller() {

        iContract_NA_Master_Controller_init();
        System.debug('The'+hasESigns);
    }
    public iContract_NA_Master_Controller(ApexPages.StandardController stdController) {
        iContract_NA_Master_Controller_init(); // don't use StandardController
        System.debug('The'+hasESigns);

    }
    // Contructor (basically) 
    
    public void iContract_NA_Master_Controller_init() {
        // RT-567 for Excel
        xmlheader ='<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';

        endfile = '</Workbook>';

        listString = new List<string>();

        listString.add('1');

        listString.add('2');
        // End RT-567
        System.debug('The Document Map'+docNametoIdMap);
        System.debug('The Document Map123'+baseUrl);
        
        isPageRenderable = false;
        errormsg = '';
        Decimal total = 0;  
        quoteTotal = '';
        Map<String, String> pageParams = ApexPages.currentPage().getParameters();
        String urlErrors = pageParams.get('errorMsg');
        if (!String.isEmpty(urlErrors)) {
            errormsg += EncodingUtil.urlDecode(urlErrors, 'UTF-8');
        }

        String contractId;

        // check partner information and fail if necessary
        if (this.isPartnerSite) {
            if (!pageParams.containsKey('pk')) {
                System.debug('No pk');
                errormsg += 'Invalid request.';
                return;
            }

            String partnerIP = '';
            try {
                Blob decryptedPK = Crypto.decryptWithManagedIV('AES256', EncodingUtil.base64decode(PARTNER_SITE_AES_KEY), EncodingUtil.base64decode(pageParams.get('pk')));
                String decryptedString = EncodingUtil.urlDecode(decryptedPK.toString(), 'UTF-8');
                String[] decryptedStrings = decryptedString.split('#');
                contractId = decryptedStrings[0];
                partnerIP = decryptedStrings[1];
                System.debug('Contract Id: ' + contractId);
                System.debug('Partner IP: ' + partnerIP);
            } catch (Exception e) {
                System.debug(e.getMessage());
                errormsg += 'Invalid request data.';
                return;
            }

            String viewerIP = iContract.getPageUserIPAddress();
            System.debug('Expected IP: ' + viewerIP);
            /*if (viewerIP != partnerIP) {
                errormsg += 'Invalid request.';
                return;
            }*/
        }
        if (pageParams.containsKey('id'))
            contractId = pageParams.get('id');

        if (contractId == null || String.isEmpty(contractId)) {
            System.debug('Invalid Contract Id');
            errormsg += 'Invalid Contract Id';
            return;
        }

        // get essential information for the contract
        try {
            this.contract = getContractData(contractId);
            System.debug('The Value'+contract.Account_Name__r.BillingAddress);
            if(String.isNotBlank(this.contract.Associated_SLO_Name__c) && this.contract.Associated_SLO_Date__c != null){
                isAssociated = true;
            } else{
                isAssociated = false;
            }
            if(this.contract.Contract_Type__c == 'Service Order'){
                isServiceOrder = true;
            }else{
                isServiceOrder = false;
            }
        }
        catch(Exception e){
            errormsg += iContract.formatException(e) + '<br />';
            System.debug(e.getMessage());
        }

        // get opp info
        try{
            this.oppData = getOpportunityData(this.contract.Opportunity__c);
        }
        catch(Exception e){
            errormsg += iContract.formatException(e) + '<br />';
            System.debug(e.getMessage());
        }

        try{
            this.eSigns = getESignData(this.contract.Opportunity__c);
        }
        catch(Exception e){
            errormsg += iContract.formatException(e) + '<br />';
            System.debug(e.getMessage());
        }

        // get creator information
        try {
            this.repData = getRepData(this.contract.OwnerId);
        }
        catch(Exception e){
            errormsg += iContract.formatException(e) + '<br />';
            System.debug(e.getMessage());
        }
        salesRepName = this.repData.FirstName + ' ' + this.repData.LastName;
        salesRepPhone = this.repData.Phone;
        salesRepFax = this.repData.Fax;
        if (salesRepPhone == null || String.isEmpty(salesRepPhone))
            salesRepPhone = 'Not Provided';
        if (salesRepFax == null || String.isEmpty(salesRepFax))
            salesRepFax = 'Not Provided';

        // get back to the rest of the data
        approvalStep = '';
        try{
            List<ProcessInstanceNode> approvalSteps = [SELECT NodeStatus, ProcessNodeName FROM ProcessInstanceNode WHERE NodeStatus = 'Pending' AND ProcessInstance.TargetObjectId = :contractId ORDER BY LastModifiedDate DESC NULLS FIRST LIMIT 1];
            if (!approvalSteps.isEmpty())
                approvalStep = approvalSteps.get(0).ProcessNodeName;
        }catch(Exception e){
            errormsg += iContract.formatException(e) + '<br />';
            System.debug(e.getMessage());
        }
        try{
            this.contactData = getContactData(this.contract.Opportunity__c);
        }
        catch(Exception e){
            errormsg += iContract.formatException(e) + '<br />';
            System.debug(e.getMessage());
        }
        try{
            this.userProfile = getProfile();
        }
        catch(Exception e){
            errormsg += iContract.formatException(e) + '<br />';
            System.debug(e.getMessage());
        }
        try{
            this.eSignTemplates = getESignTemplates(agreementRegion, contract);
        }
        catch(Exception e){
            errormsg += iContract.formatException(e) + '<br />';
            System.debug(e.getMessage());
        }

        //get terms and conditions for the contract
        List<CONMAN_Contract_Verbiage__c> contractVerbiage = new List<CONMAN_Contract_Verbiage__c>();
        try{
            contractVerbiage = getContractVerbiage(contract.Id, contract.Language__c);
            System.debug('The vSize() '+contractVerbiage.size());
            if (contractVerbiage != null && contractVerbiage.size() > 0 && !isQuote)
                isPageRenderable = true;
        }
        catch(Exception e){
            errormsg += iContract.formatException(e) + '<br />';
            System.debug(e);
        }
        sortedContractVerbiage = new List<VerbiageData>();
        firstPageVerbiage = new List<VerbiageData>();
        signingVerbiage = new List<VerbiageData>();
        tpxVerbiage = new List<VerbiageData>();
        // RT-561
        if(isTPX){
            for (CONMAN_Contract_Verbiage__c cVerb : contractVerbiage) {
                if (cVerb.Contract_General_Content__r != null) {
                    tpxVerbiage.add(new VerbiageData(cVerb));
                }
            } 
        }

        for (CONMAN_Contract_Verbiage__c cVerb : contractVerbiage) {
            if (cVerb.Contract_General_Content__r != null && cVerb.Contract_General_Content__r.Section__c == 'Intro') {
                firstPageVerbiage.add(new VerbiageData(cVerb));
            }
        }

        for (CONMAN_Contract_Verbiage__c cVerb : contractVerbiage) {
            if (cVerb.Contract_General_Content__r != null && cVerb.Contract_General_Content__r.Section__c == 'Signature') {
                signingVerbiage.add(new VerbiageData(cVerb));
            }
        }

        for (CONMAN_Contract_Verbiage__c cVerb : contractVerbiage) {
            if (cVerb.Contract_General_Content__r == null || cVerb.Contract_General_Content__r.Section__c == 'Services and Pricing Schedule') {
                sortedContractVerbiage.add(new VerbiageData(cVerb)); 
            }
        }

        // contruct the table of terms near the top
        sortedTableContractVerbiage = new List<VerbiageData>();

        for (CONMAN_Contract_Verbiage__c cVerb : contractVerbiage) {
            if (cVerb.Contract_General_Content__r != null && cVerb.Contract_General_Content__r.Section__c == 'Pre-Intro Table') {
                sortedTableContractVerbiage.add(new VerbiageData(cVerb));
                if (cVerb.Verbiage_Header__c != null && cVerb.Verbiage_Header__c.equals('Term')) {
                    cVerb.Verbiage__c = calculateTerm(cVerb.Verbiage__c, contract.Contracted_Term__c);
                }
            }
        }

        // get license and rate information
        this.licenseData = new List<LicenseData>();
        Map<LicenseSet__c, List<Associated_Rate__c>> licenseSets = new Map<LicenseSet__c, List<Associated_Rate__c>>();
        try{
            licenseSets = getProductData(contract.id, this.isQuote, this.canEditPricing);
            if (licenseSets != null && licenseSets.size() > 0 && isQuote) {
                isPageRenderable = true;
            }
        }
        catch(Exception e){
            errormsg += iContract.formatException(e) + '<br />';
            System.debug(e.getMessage());
        }

        for (LicenseSet__c licenseSet : licenseSets.keySet())
            this.licenseData.add(new LicenseData(licenseSet, licenseSets.get(licenseSet), this.contract));
        this.licenseData.sort();

        // Get Total Amount for Quotes
        for (LicenseData ld : this.licenseData) {
            for (RateData rd : ld.oneTimeCharges) {
                if (rd.associatedRate.Rate__c != null && rd.associatedRate.Rate__r != null && rd.associatedRate.Rate__r.Type__c == 'Once') {
                    Decimal qty = rd.associatedRate.Quantity__c;
                    if (qty == null || qty < 0) qty = 1;
                    total += (qty * rd.associatedRate.Override__c).setScale(2);
                }
            }
            for (RateData rd : ld.commitments) {
                if (rd.associatedRate.Rate__c != null && rd.associatedRate.Rate__r != null && rd.associatedRate.Rate__r.Type__c == 'Commit') {
                    total += (rd.associatedRate.Override__c * (contract.Contracted_Term__c / contract.Contracted_Frequency__c)).setScale(2);
                }
            }
            for (RateData rd : ld.subscriptions) {
                if (rd.associatedRate.Override__c != null && rd.associatedRate.Quantity__c != null && contract.Contracted_Frequency__c != null && contract.Contracted_Term__c != null) {
                    Decimal qty = rd.associatedRate.Quantity__c;
                    if (qty < 0) qty = 1;
                    total += (qty * rd.associatedRate.Override__c * contract.Contracted_Frequency__c * (contract.Contracted_Term__c / contract.Contracted_Frequency__c)).setScale(2);
                }
            }
        }

        // Finish Quote total
        quoteTotal = agreementCurrencyCode + ' ' + total.setScale(LICENSE_DECIMAL_PLACES).toPlainString();
    }

    // Page Actions 
    public PageReference getMasterUrl() {
        PageReference contractPdf = Page.iContract_NA_Master;
        if (this.isPartnerSite) {
            contractPdf.getParameters().put('pk', ApexPages.currentPage().getParameters().get('pk'));
        } else {
            contractPdf.getParameters().put('id', contract.id);
        }
        contractPdf.setRedirect(true);
        return contractPdf;
    }
    // public PageReference saveSO(){
    //     System.debug('Inside Save---------SO--------');
    //     return null;
    // }

    public PageReference save() {
        System.debug('The incubents123'+testString);
        String errors = '';

        // Update the Contract Title
        try {
            update contract;
        } catch (Exception e) {
            errors += 'Unable to save Contract: <br />' + iContract.formatException(e) + '<br />';
            System.debug('Exception saving contract:' + iContract.formatException(e));
        }

        // Different profiles can only edit certain verbiage
        List<CONMAN_Contract_Verbiage__c> verbiageToUpdate = new List<CONMAN_Contract_Verbiage__c>();

        for (VerbiageData verb : sortedTableContractVerbiage)
            if (this.canEditVerbiage || (this.canEditPricing && verb.contractVerbiage.Pricing_Team_Changes_Allowed__c))
                verbiageToUpdate.add(verb.contractVerbiage);
        for (VerbiageData verb : sortedContractVerbiage)
            if (this.canEditVerbiage || (this.canEditPricing && verb.contractVerbiage.Pricing_Team_Changes_Allowed__c))
                verbiageToUpdate.add(verb.contractVerbiage);
        for (VerbiageData verb : firstPageVerbiage)
            if (this.canEditVerbiage || (this.canEditPricing && verb.contractVerbiage.Pricing_Team_Changes_Allowed__c))
                verbiageToUpdate.add(verb.contractVerbiage);
        for (VerbiageData verb : signingVerbiage)
            if (this.canEditVerbiage || (this.canEditPricing && verb.contractVerbiage.Pricing_Team_Changes_Allowed__c))
                verbiageToUpdate.add(verb.contractVerbiage);

        // Update the Contract Verbiage
        try {
            update verbiageToUpdate;
        } catch (Exception e) {
            errors += 'Unable to save Verbiage: <br />' + iContract.formatException(e) + '<br />';
            System.debug('Exception saving verbiageToUpdate:' + iContract.formatException(e));
        }

        // Update the License Sets
        try{
            Map<Id, LicenseSet__c> licenseSets = new Map<Id, LicenseSet__c>();
            List<Associated_Rate__c> rates = new List<Associated_Rate__c>();
            for (LicenseData license : licenseData) {
                licenseSets.put(license.licenseSet.Id, license.licenseSet);
            }

            List<LicenseSet__c> updatedLicenseSets = new List<LicenseSet__c>();
            List<LicenseSet__c> oldLicenseSets = [SELECT Id, Name, Product_Name__c, Disabled__c
                                                     FROM LicenseSet__c WHERE Id IN :licenseSets.keySet()];

            for (LicenseSet__c oldLicenseSet : oldLicenseSets) {
                LicenseSet__c newLicenseSet = licenseSets.get(oldLicenseSet.Id);
                if (isLicenseChanged(oldLicenseSet, newLicenseSet)){
                    updatedLicenseSets.add(newLicenseSet);
                }
            }

            if (!updatedLicenseSets.isEmpty()) {
                update updatedLicenseSets;
            }
        } catch (Exception e) {
            errors += 'Unable to save License Sets: <br />' + iContract.formatException(e) + '<br />';
            System.debug('Exception saving License Sets:' + iContract.formatException(e));
        }

        // Update the Associated Rates
        try{
            Map<Id, Associated_Rate__c> assoRates = new Map<Id, Associated_Rate__c>();
            List<Associated_Rate__c> updatedAssoRates = new List<Associated_Rate__c>();

            for (LicenseData license : licenseData) {
                for (RateGroupData rateGroup : license.rateGroups.values()) {
                    for (RateData rateData : rateGroup.rates) {
                        assoRates.put(rateData.associatedRate.Id, rateData.associatedRate);
                    }
                }
                for (AccessTypeData accessTypeData : license.accessTypes.values()) {
                    for (List<RateData> rates : accessTypeData.locations.values()) {
                        for (RateData rateData : rates) {
                            assoRates.put(rateData.associatedRate.Id, rateData.associatedRate);
                        }
                    }
                }
            }

            List<Associated_Rate__c> oldAssoRates = [SELECT Id, Name, Rate_Name__c, Description__c, Recurrence__c, Override__c, Disabled__c FROM Associated_Rate__c WHERE Id IN :assoRates.keySet()];

            for (Associated_Rate__c oldAssoRate : oldAssoRates) {
                Associated_Rate__c newAssoRate = assoRates.get(oldAssoRate.Id);
                if (isRateChanged(oldAssoRate, newAssoRate))
                    updatedAssoRates.add(newAssoRate);
            }

            if (!updatedAssoRates.isEmpty())
                update updatedAssoRates;

        } catch (Exception e) {
            errors += 'Unable to save Rates: <br />' + iContract.formatException(e) + '<br />';
            System.debug('Exception saving Rates:' + iContract.formatException(e));
        }

        // Generate the URL to goto next
        PageReference contractPdf = getMasterUrl();
        if (this.isQuote)
            contractPdf.getParameters().put('showQuote', 'true');
        if (!String.isEmpty(errors)) {
            contractPdf.getParameters().put('errorMsg', EncodingUtil.urlEncode(errors, 'UTF-8'));
        }
        contractPdf.setRedirect(true);
        return contractPdf;
    }

    public PageReference addLicenseSet() {
        System.debug('Adding License Set');

        LicenseSet__c newLicenseSet = new LicenseSet__c(CurrencyIsoCode=agreementCurrencyCode, Name='New Section', Product_Name__c='New Section',
                                                        Opportunity__c=oppData.Id, PGi_Contract__c=contract.Id);
        insert newLicenseSet;
        LicenseData newLicenseSetData = new LicenseData(newLicenseSet, new List<Associated_Rate__c>(), this.contract);
        if (licenseData.isEmpty())
            licenseData.add(newLicenseSetData);
        else
            licenseData.add(0, newLicenseSetData);

        Associated_Rate__c newAssociatedRate = new Associated_Rate__c(CurrencyIsoCode=agreementCurrencyCode, Name='New Rate', Rate_Name__c='New Rate',
                                                                      Default__c=0.00, Recurrence__c='Minute',
                                                                      LicenseSet__c=newLicenseSet.Id, Show_On_Quote__c=true);
        insert newAssociatedRate;
        newLicenseSetData.addAssociatedRate(newAssociatedRate, this.contract);
        newLicenseSetData.sort();

        return null;
    }

    public PageReference addRateToLicenseSet() {
        System.debug('Adding Rate to License Set');

        if (actOnLicenseSetId == null || String.isEmpty(actOnLicenseSetId)) {
            System.debug('Cannot do anything with a null ID though...');
            return null;
        }

        LicenseData matchedLicenseData = null;
        for (LicenseData possibleLicenseData : licenseData) {
            if (possibleLicenseData.licenseSet.Id == actOnLicenseSetId) {
                matchedLicenseData = possibleLicenseData;
                break;
            }
        }

        if (matchedLicenseData == null) {
            System.debug('Did not find that License Set ID...');
            return null;
        }

        Associated_Rate__c newAssociatedRate = new Associated_Rate__c(CurrencyIsoCode=agreementCurrencyCode, Name='New Rate', Rate_Name__c='New Rate',
                                                                      Default__c=0.00, Recurrence__c='Minute',
                                                                      LicenseSet__c=actOnLicenseSetId, Show_On_Quote__c=true);
        insert newAssociatedRate;
        matchedLicenseData.addAssociatedRate(newAssociatedRate, this.contract);
        matchedLicenseData.sort();

        return null;
    }

    public PageReference deleteRateFromLicenseSet() {
        System.debug('Toggling Rate from License Set');

        if (actOnAssociatedRateId == null || String.isEmpty(actOnAssociatedRateId) || actOnLicenseSetId == null || String.isEmpty(actOnLicenseSetId)) {
            System.debug('Cannot do anything with a null ID though...');
            return null;
        }

        RateData matchedRateData = null;
        for (LicenseData possibleLicenseData : licenseData) {
            if (possibleLicenseData.licenseSet.Id == actOnLicenseSetId) {
                for (RateGroupData rateGroup : possibleLicenseData.rateGroups.values()) {
                    for (RateData possibleRateData : rateGroup.rates) {
                        if (possibleRateData.associatedRate.Id == actOnAssociatedRateId) {
                            matchedRateData = possibleRateData;
                            break;
                        }
                    }
                }
                break;
            }
        }

        if (matchedRateData == null) {
            System.debug('Did not find that Associated Rate ID...');
            return null;
        }

        matchedRateData.associatedRate.Disabled__c = !matchedRateData.associatedRate.Disabled__c;

        return null;
    }

    public PageReference deleteLicenseSet() {
        System.debug('Toggling License Set');

        if (actOnLicenseSetId == null || String.isEmpty(actOnLicenseSetId)) {
            System.debug('Cannot do anything with a null ID though...');
            return null;
        }

        LicenseData matchedLicenseData = null;
        integer index = 0;
        for (LicenseData possibleLicenseData : licenseData) {
            if (possibleLicenseData.licenseSet.Id == actOnLicenseSetId) {
                matchedLicenseData = possibleLicenseData;
                break;
            }
            index++;
        }

        if (matchedLicenseData == null) {
            System.debug('Did not find that License Set ID...');
            return null;
        }

        matchedLicenseData.licenseSet.Disabled__c = !matchedLicenseData.licenseSet.Disabled__c;

        return null;
    }

    public PageReference deleteRateGroup() {
        System.debug('Toggling Rate Group from License Set');

        if (actOnRateGroup == null || String.isEmpty(actOnRateGroup) || actOnLicenseSetId == null || String.isEmpty(actOnLicenseSetId)) {
            System.debug('Cannot do anything with a null ID though...');
            return null;
        }

        for (LicenseData possibleLicenseData : licenseData) {
            if (possibleLicenseData.licenseSet.Id == actOnLicenseSetId) {
                if (possibleLicenseData.rateGroups == null || !possibleLicenseData.rateGroups.containsKey(actOnRateGroup)) {
                    System.debug('Did not find that Rate Group...');
                    return null;
                }
                for (RateData matchedRateData : possibleLicenseData.rateGroups.get(actOnRateGroup).rates) {
                    matchedRateData.associatedRate.Disabled__c = !matchedRateData.associatedRate.Disabled__c;
                }
                break;
            }
        }

        return null;
    }

    public void submit() {

    }
    public PageReference saveOpp() {
        System.debug('The Value Is');
        String errors = '';

        // Update the Opportunity
        try {
            update oppData;
        } catch (DmlException e) {
            if(e.getMessage().toLowerCase().contains('field_custom_validation_exception, ')){
                errors += e.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION, ');
            } else if(e.getMessage().toLowerCase().contains('please change the close date to a future date when the opportunity stage is not closed won/lost.: [closedate]')){
                errors += 'Please change the Close Date to a Future Date when the Opportunity Stage is not Closed Won/Lost.';
            } else{
                errors += e.getMessage();
            }
            System.debug('Exception saving opp:' + iContract.formatException(e));
        } catch (Exception e) {
            errors += 'Unable to save Opportunity: \n' + iContract.formatException(e) + '\n';
            System.debug('Exception saving opp:' + iContract.formatException(e));
        }

        // Generate the URL to goto next
        PageReference contractPdf = getMasterUrl();
        if (!String.isEmpty(errors))
            contractPdf.getParameters().put('errorMsg', EncodingUtil.urlEncode(errors, 'UTF-8'));
        return contractPdf;
    }

    public PageReference cancel() {
        PageReference contractPdf = getMasterUrl();
        if (this.isQuote)
            contractPdf.getParameters().put('showQuote', 'true');
        return contractPdf;
    }

    public PageReference showAgreement() {
        return getMasterUrl();
    }

    public PageReference showQuote() {
        PageReference contractPdf = getMasterUrl();
        contractPdf.getParameters().put('showQuote', 'true');
        return contractPdf;
    }
     public PageReference emailDelRegidtration() {
        System.debug('The OIPP is>>>>>'+this.contract.Opportunity__c);

        if(this.contract.Opportunity__c != null){
            Opportunity oppObj =[Select Id,TPxDealRegistrationSent__c from Opportunity where Id =: this.contract.Opportunity__c FOR UPDATE];
            if(!oppObj.TPxDealRegistrationSent__c){
                oppObj.TPxDealRegistrationSent__c=true;
                update oppObj;
            }
        }
        PageReference contractPdf = getMasterUrl();
         Document doc = new Document();
         contractPdf.getParameters().put('showQuote', 'true');
         contractPdf.getParameters().put('excelShow', 'true');
         doc.Name = 'PGi Deal Registration -'+oppData.Opportunity_Number__c+'.xls';
         doc.FolderId = UserInfo.getUserId();
         doc.Description = 'PGi Quote';
         doc.Body = contractPdf.getContent();
         insert(doc);

         contractPdf.getParameters().remove('excelShow');
        
         String templateId = [SELECT id from emailTemplate WHERE DeveloperName = 'Deal_Reg_TPx'].Id;
         PageReference emailTemplate= new PageReference('/_ui/core/email/author/EmailAuthor');
    
         emailTemplate.getParameters().put('template_id',templateId);
         emailTemplate.getParameters().put('doc_id', doc.Id); 
         emailTemplate.getParameters().put('p3_lkid', this.contract.Opportunity__c);
         emailTemplate.getParameters().put('p24', 'pgiquotes@tpx.com');
         emailTemplate.getParameters().put('p23', 'Attached is a Quote from PGi.');
        
         emailTemplate.getParameters().put('retURL',contractPdf.getUrl());
        
    

         contractPdf.getParameters().put('openPopupURL', emailTemplate.getUrl());
         return contractPdf;
    }

    public PageReference emailQuoteEvent() {
        System.debug('The OIPP is>>>>>'+this.contract.Opportunity__c);

        // added by Vijay
        // RT-429: Oppty "Quote was Sent" that is a checkbox and auto gets checked if a quote was sent to the customer via iContract.
        if(this.contract.Opportunity__c != null){
            Opportunity oppObj =[Select Id,Quote_was_Sent__c from Opportunity where Id =: this.contract.Opportunity__c FOR UPDATE];
            if(!oppObj.Quote_was_Sent__c){
                oppObj.Quote_was_Sent__c=true;
                update oppObj;
            }
        }
        PageReference contractPdf = getMasterUrl();
        Document doc = new Document();
        // RT-561
        contractPdf.getParameters().put('showQuote', 'true');
        contractPdf.getParameters().put('pdfDownload', 'true');
        doc.Name = 'PGi Quote - '+this.contract.Name+'.pdf';
        // Document doc = new Document(Name = 'PGiQuote'+'.pdf');
        // Document doc = new Document(Name = 'PGiQuote-#'+'.pdf');
        doc.FolderId = UserInfo.getUserId();
        doc.Description = 'PGi Quote';
        doc.Body = contractPdf.getContent();
        insert(doc);

         contractPdf.getParameters().remove('pdfDownload');
        
        
        String templateId;
        String tpxTemplate;
         PageReference emailTemplate= new PageReference('/_ui/core/email/author/EmailAuthor');
        //  Rt-561
         if(isTPX){
            tpxTemplate = [SELECT id from emailTemplate WHERE DeveloperName = 'Quote_TPx'].Id;
            emailTemplate.getParameters().put('template_id', tpxTemplate);
         }else{
            templateId = [SELECT id from emailTemplate WHERE DeveloperName = 'Quote_PGi'].Id;
            emailTemplate.getParameters().put('template_id',templateId); //RT-562
         }
         emailTemplate.getParameters().put('doc_id', doc.Id); 
         emailTemplate.getParameters().put('p2_lkid', this.contactData.Id);
         emailTemplate.getParameters().put('p3_lkid', this.contract.Opportunity__c);
         emailTemplate.getParameters().put('p23', 'Attached is a Quote from PGi.');
         //this may be word or pdf
         emailTemplate.getParameters().put('retURL',contractPdf.getUrl());
         
         Attachment att = new Attachment();
         att.Name = doc.Name;
         att.ParentId = this.contract.Opportunity__c;
         att.Body = contractPdf.getContent();
         insert att;
         
        

         contractPdf.getParameters().put('openPopupURL', emailTemplate.getUrl());
         return contractPdf;
    }

    public PageReference downloadPDFEvent() {
        PageReference contractPdf = getMasterUrl();
        contractPdf.getParameters().put('pdfDownload', 'true');

        Attachment att = new Attachment(name=pdfFilename + '.pdf');
        if (Test.isRunningTest())
            att.body = Blob.valueOf('testing');
        else
            att.body = contractPdf.getContent();
        att.parentid = contract.id;
        insert att;

        if (contract.Contract_Status__c != 'Pending Approval') {
            contract.Contract_Status__c = 'Downloaded';
            update contract;
        }

        if (this.isQuote)
            contractPdf.getParameters().put('showQuote', 'true');
        contractPdf.getParameters().remove('pdfDownload');
        return contractPdf;
    }
 
    public PageReference downloadWordEvent() {
        PageReference contractWord = getMasterUrl();
        if (this.isQuote)
            contractWord.getParameters().put('showQuote', 'true');

        contract.Word_File_In_Use__c = true;
        update contract;
        return contractWord;
    }

    public PageReference resetWordEvent() {
        PageReference contractWord = getMasterUrl();
        if (this.isQuote)
            contractWord.getParameters().put('showQuote', 'true');

        contract.Word_File_In_Use__c = false;
        //RT-335    on click of "Discard Word, Use Salesforce" these fields will be set to 'NO'
        contract.Product_Details_Were_Manually_Changed__c = '';
        contract.T_Cs_Were_Manually_Changed__c = '';
        //RT-335 end
        update contract;
        return contractWord;
    }
    public PageReference startESignEvent() {
        PageReference contractPdf = getMasterUrl();
        try {
            if (eSignTemplate == null || String.isEmpty(eSignTemplate)) {
                contractPdf = getMasterUrl();
                contractPdf.getParameters().put('errorMsg',
                                                EncodingUtil.urlEncode('You must pick an Agreement Template.', 'UTF-8'));
                return contractPdf;
            }

            Id agreementId = echosign_dev1.AgreementTemplateService.load(eSignTemplate, oppdata.Id);
            System.debug('The value is'+agreementId);
            // Create the PDF attachment
            Attachment att = new Attachment();
            if(contract.Account_s_Agreement_Name__c != '' && contract.Account_s_Agreement_Name__c != null ){
                att.name=contract.Account_s_Agreement_Name__c + ' - ' + pdfFilename + '.pdf';
            }
            else{
                att.name=contract.Account_Name__r.Name + ' - ' + pdfFilename + '.pdf';
            }
            contractPdf.getParameters().put('pdfDownload', 'true');
            if (!System.Test.isRunningTest())
                att.body = contractPdf.getContent();
            else
                att.body = EncodingUtil.convertFromHex('00000000000000000000000000000000');
            att.parentid = agreementId;
            insert att;


            // Update the Agreement
            echosign_dev1__SIGN_Agreement__c updatedAgreement = new echosign_dev1__SIGN_Agreement__c(Id=agreementId);
            updatedAgreement.Created_by_iContract__c = true;
            if(contract.Account_s_Agreement_Name__c != '' && contract.Account_s_Agreement_Name__c != null ){
                system.debug('bvv>>>>'+contract.Account_s_Agreement_Name__c);
                updatedAgreement.name = contract.Account_s_Agreement_Name__c + ' - ' + pdfFilename ;
            }
            update updatedAgreement;

            // Update the Recepient to Agreement Signer Contact
            List<echosign_dev1__SIGN_Recipients__c> updateRecipient = [SELECT Id FROM echosign_dev1__SIGN_Recipients__c WHERE echosign_dev1__Agreement__c = :agreementId AND echosign_dev1__Contact__c != null];
            if (updateRecipient.size() > 0){
                updateRecipient.get(0).echosign_dev1__Contact__c = contactData.Id;
                update updateRecipient;
            }

            // Update the Contract
            contract.Related_Agreement__c = agreementId;
            update contract;

            PageReference esignPage = new PageReference('/' + agreementId);
            return esignPage;
        } catch (Exception e) {
            contractPdf = getMasterUrl();
            contractPdf.getParameters().put('errorMsg',
                                            EncodingUtil.urlEncode('Unable to attach Contract to Agreement: <br />' + iContract.formatException(e) + '<br />', 'UTF-8'));
            System.debug('Exception attach Contract to Agreement:' + iContract.formatException(e));
            return contractPdf;
        }
    }

    // SOQL Functions 
    public static String getProfile() {
        Profile p = [Select Name from Profile where Id = :UserInfo.getProfileId()];
        return p.Name;
    }

    public static boolean hasLegalPermission() {
        List<PermissionSetAssignment> p = [SELECT PermissionSet.Name
                                           FROM PermissionSetAssignment
                                           WHERE AssigneeId = :Userinfo.getUserId()
                                           AND PermissionSet.Name = 'PGi_Contracts_Legal'];
        return p != null && !p.isEmpty();
    }

    public static boolean hasPricingPermission() {
        List<PermissionSetAssignment> p = [SELECT PermissionSet.Name
                                           FROM PermissionSetAssignment
                                           WHERE AssigneeId = :Userinfo.getUserId()
                                           AND PermissionSet.Name = 'PGi_Contracts_Pricing'];
        return p != null && !p.isEmpty();
    }
//RT-561 Added expiration date
    public static CONMAN_Contract__c getContractData(String contractId) {
        return [SELECT Id, Name, Title__c,PGi_Internal_Entity__c,Related_Agreement__c,Language__c, OwnerId, Contract_Status__c, Existing_Account_Numbers__c,
                Intl_Order_Type__c,Company_s_Name__c, Customer_s_Business_Registration_Number__c,
                Exempt_Telecom_Surcharge__c, Exempt_Service_Fee__c,
                Account_Name__c, Account_Name__r.Name, Account_s_Agreement_Name__c, Opportunity__c,Opportunity__r.Incumbent_Other_Product__c,Opportunity__r.Competitor_Other_Product__c,
                // ACCountRelated
                Account_Name__r.BillingAddress,Account_Name__r.BillingState,Account_Name__r.BillingCity,Account_Name__r.BillingCountry,Account_Name__r.BillingPostalCode,

                Word_File_In_Use__c, Owner_Type__c, Required_Approval_ARG__c,Expiration_Date__c,
                Required_Approval_Billing__c,T_Cs_Were_Manually_Changed__c, Product_Details_Were_Manually_Changed__c,
                Required_Approval_Pricing_Manager__c, Required_Approval_Pricing_RVP__c,
                Required_Approval_Pricing_SVP__c, Required_Approval_Legal__c, Required_Approval_Deal_Desk__c,
                Submitters_Manager__c, Contracted_Term__c, Contracted_Frequency__c, Quote_Additional_Notes__c,
                customHeader__c, Contract_Type__c, Associated_SLO_Date__c, Associated_SLO_Name__c,
                Account_Name__r.Owners_Channel_Formula__c, Account_Name__r.Type
                FROM CONMAN_Contract__c
                WHERE Id = :contractId];
    }

    public  List<CONMAN_Contract_Verbiage__c> getContractVerbiage(String contractId, String Language) {
        // RT-561 for tpxservice Agreemennt
        if(isTPX){
            System.debug('TPX IS RENDERING');
            List<CONMAN_Contract_Verbiage__c> verbs = [SELECT Id, Name, Verbiage__c, Contract_General_Content__c, Language__c, Contract_Product_Verbiage__c,
            Contract_General_Content__r.Name, Contract_Product_Verbiage__r.Name,Contract_General_Content__r.Header__c,Contract_General_Content__r.Show_Header__c,
            Contract_General_Content__r.Content_RTF__c, Contract_Product_Verbiage__r.Terms_and_Conditions_RTF__c,
            Contract_General_Content__r.Section__c, Contract_General_Content__r.Order__c,
            Contract_General_Content__r.Intl_Order_Type__c,
            Pricing_Team_Changes_Allowed__c, Comments__c, Order__c, Verbiage_Header__c, Show_Verbiage_Header__c
                FROM CONMAN_Contract_Verbiage__c
                WHERE PGi_Contract__c = :contractId 
                AND Contract_General_Content__r.Agreement_Type__c includes (:this.contract.Contract_Type__c	) 
                ORDER BY Contract_General_Content__r.Order__c ASC];
            return handleMergeFields(verbs);
        }
       
          
        // commented Due to RT-520 CGC headers are not displaying since They are displaying CONMAN_Contract_Verbiage__c Header.
        // Now trying to display CGC Header with condition.
       /* if(agreementRegion.equals('EMEA') || agreementRegion.equals('APAC') ) {
            String contractType = this.contract.Intl_Order_Type__c;
            System.debug(contractType);
            if(String.isBlank(contractType)) {
                contractType = 'Long Form';
            }
            List<CONMAN_Contract_Verbiage__c> verbs = [SELECT Id, Name, Verbiage__c, Contract_General_Content__c, Language__c, Contract_Product_Verbiage__c,
                Contract_General_Content__r.Name, Contract_Product_Verbiage__r.Name,
                Contract_General_Content__r.Content_RTF__c, Contract_Product_Verbiage__r.Terms_and_Conditions_RTF__c,
                Contract_General_Content__r.Section__c, Contract_General_Content__r.Order__c,
                Contract_General_Content__r.Intl_Order_Type__c,
                Pricing_Team_Changes_Allowed__c, Comments__c, Order__c, Verbiage_Header__c, Show_Verbiage_Header__c
                FROM CONMAN_Contract_Verbiage__c
                WHERE PGi_Contract__c = :contractId AND Language__c =: Language
                AND Intl_Order_Type__c includes (:contractType)
                ORDER BY Order__c ASC];
            return handleMergeFields(verbs);
                
        }*/
        //Insted of above to display CGC Header.
        if(agreementRegion.equals('EMEA') || agreementRegion.equals('APAC') ) {
            //RT-518 iContract users in India (not contacts) should only be allowed to use “short form” .(Vijay).And that it does infact default to "Short Form" for them.
            String contractType;
            if(isUserIndia){
                contractType = 'Short Form';  
            }
            else{
                contractType = this.contract.Intl_Order_Type__c;
                System.debug(contractType);
                if(String.isBlank(contractType)) {
                    contractType = 'Long Form';
                }
            }
            List<CONMAN_Contract_Verbiage__c> verbs = [SELECT Id, Name, Verbiage__c, Contract_General_Content__c, Language__c, Contract_Product_Verbiage__c,
                Contract_General_Content__r.Name, Contract_Product_Verbiage__r.Name,Contract_General_Content__r.Header__c,Contract_General_Content__r.Show_Header__c,
                Contract_General_Content__r.Content_RTF__c, Contract_Product_Verbiage__r.Terms_and_Conditions_RTF__c,
                Contract_General_Content__r.Section__c, Contract_General_Content__r.Order__c,
                Contract_General_Content__r.Intl_Order_Type__c,
                Pricing_Team_Changes_Allowed__c, Comments__c, Order__c, Verbiage_Header__c, Show_Verbiage_Header__c
                FROM CONMAN_Contract_Verbiage__c
                WHERE PGi_Contract__c = :contractId AND Contract_General_Content__r.Language__c =: Language  
                AND Contract_General_Content__r.Active__c = true 
                AND Contract_General_Content__r.Region__c includes (:agreementRegion)
                AND Contract_General_Content__r.Intl_Order_Type__c includes (:contractType)
                AND Contract_General_Content__r.Agreement_Type__c includes (:this.contract.Contract_Type__c	)
                ORDER BY Order__c ASC];
            verbs.addAll([SELECT Id, Name, Verbiage__c, Contract_General_Content__c, Language__c, Contract_Product_Verbiage__c,
                            Contract_General_Content__r.Name, Contract_Product_Verbiage__r.Name,Contract_General_Content__r.Header__c,Contract_General_Content__r.Show_Header__c,
                            Contract_General_Content__r.Content_RTF__c, Contract_Product_Verbiage__r.Terms_and_Conditions_RTF__c,
                            Contract_General_Content__r.Section__c, Contract_General_Content__r.Order__c,
                            Contract_General_Content__r.Intl_Order_Type__c,
                            Pricing_Team_Changes_Allowed__c, Comments__c, Order__c, Verbiage_Header__c, Show_Verbiage_Header__c
                            FROM CONMAN_Contract_Verbiage__c
                            WHERE PGi_Contract__c = :contractId AND Contract_General_Content__c = null AND Language__c =: Language
                            ORDER BY Order__c ASC]);
            return handleMergeFields(verbs);
                
        } 
        List<CONMAN_Contract_Verbiage__c> verbs = [SELECT Id, Name, Verbiage__c, Contract_General_Content__c, Language__c, Contract_Product_Verbiage__c,
            Contract_General_Content__r.Name, Contract_Product_Verbiage__r.Name,Contract_General_Content__r.Header__c,
            Contract_General_Content__r.Content_RTF__c, Contract_Product_Verbiage__r.Terms_and_Conditions_RTF__c,
            Contract_General_Content__r.Section__c, Contract_General_Content__r.Order__c,
            Contract_General_Content__r.Intl_Order_Type__c,
            Pricing_Team_Changes_Allowed__c, Comments__c, Order__c, Verbiage_Header__c, Show_Verbiage_Header__c
            FROM CONMAN_Contract_Verbiage__c
            WHERE PGi_Contract__c = :contractId AND Language__c =: Language
            ORDER BY Order__c ASC];
        return handleMergeFields(verbs);
                // // for(CONMAN_Contract_Verbiage__c conmanRec : conmanObjList){
                //  //     MergeText(conmanRec.Verbiage__c, conmanRec);
                //   MergeText(conmanObjList[8].Verbiage__c, conmanObjList[8]);
                // // }
                // return conmanObjList;
    }
    public static Map<String, Schema.SobjectField> getvalidField{ get {
        if(getvalidField == null){
            getvalidField = CONMAN_Contract__c.getSobjectType().getDescribe().fields.getMap();
        }
        return getvalidField;
        } set;
    }
    public static Set<String> findMatchingContractFields(String verbBody) {
        Set<String> contractFields = new Set<String>();
        try {
            if(String.isBlank(verbBody)) {return new Set<String>();}
            Integer curPos = 0;
            Set<String> mergeFieldSet = new Set<String>();
            // Set<String> contractFields = new Set<String>();
            Pattern mergeField = Pattern.compile('\\{!*[a-zA-Z0-9_\\. ]*\\}'); // Pattern to get Merge field from Verbiage
            Matcher matchFld = mergeField.matcher(verbBody);
            //find all merge fields
            while(matchFld.find()){   
                String fieldName = verbBody.substring(matchFld.start()+2,matchFld.end()-1);
                mergeFieldSet.add(fieldName.trim());
                curPos = matchFld.end(); 
            }

            for(String fieldName : mergeFieldSet){
                System.debug('The value is Test'+fieldName);
                List<String> fieldsList = fieldName.split('\\.');
                System.debug('The value is'+fieldsList[1].trim());
                if(getvalidField.containsKey(fieldsList[1].trim())){
                    System.debug('The value is Test'+fieldsList[1]);
                    contractFields.add(fieldsList[1]);
                }
            }
        } catch (exception e) {
            system.debug(e);
        }
        return contractFields;
    }
   

    public List<CONMAN_Contract_Verbiage__c> handleMergeFields(List<CONMAN_Contract_Verbiage__c> verbs) {
        String dateFormat ='MMMM dd, YYYY';
        Set<String> allFieldsToQuery = new Set<String>();
        for(CONMAN_Contract_Verbiage__c verb: verbs) {
            allFieldsToQuery.addAll(findMatchingContractFields(verb.Verbiage__c));
        }
        System.debug(allFieldsToQuery);
        if(allFieldsToQuery.size() == 0) {
            return verbs;
        }
            String fieldsToQuery = String.join(new List<String>(allFieldsToQuery), ',');        
            String query = 'SELECT ' + fieldsToQuery + ' FROM CONMAN_Contract__c WHERE Id = \'' + contract.Id + '\'';

           List<Country__c> countryDateFormatList = [SELECT Date_Format__c FROM Country__c WHERE Name =: country];
            if(!countryDateFormatList.isEmpty() && String.isNotBlank(countryDateFormatList[0].Date_Format__c)){
               dateFormat = countryDateFormatList[0].Date_Format__c;
            }
            CONMAN_Contract__c contractWithMergeFields = Database.query(query);
            return mergeText(allFieldsToQuery, verbs, contractWithMergeFields, dateFormat);
    }
    public static List<CONMAN_Contract_Verbiage__c> mergeText(Set<String> fieldsToReplace, List<CONMAN_Contract_Verbiage__c> verbs, CONMAN_Contract__c contractWithMergeFields, String countryDateFormat){
        try {
        String baseObject = 'Contract';
        String startCharRegEx = '\\{!';
        String startChar = '{!';
        String endChar = '}';
        String periodRegEx = '\\.';
        String period = '.';
        String objType='CONMAN_Contract__c';
        // Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        // Schema.SObjectType countrySchema = schemaMap.get(objType);
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.CONMAN_Contract__c.fields.getMap();
        for(CONMAN_Contract_Verbiage__c verb: verbs) {
            for(String field: fieldsToReplace) {
                
                String mergeField = startChar + baseObject + period + field + endChar;
                String mergeFieldRegEx = startCharRegEx + baseObject + periodRegEx + field + endChar;
                
                try {
                    if(verb.Verbiage__c.contains(mergeField)) {
                        String replacementValue = '';
                        try {
                            replacementValue = (String)contractWithMergeFields.get(field);
                            System.debug(replacementValue );
                        } catch (Exception ex) {
                            replacementValue = String.valueOf(contractWithMergeFields.get(field));
                            System.debug(replacementValue );
                        }

                        Schema.DisplayType fielddataType = fieldMap.get(field).getDescribe().getType();
                        if(fielddataType == Schema.DisplayType.Date || fielddataType == Schema.DisplayType.DateTime){
                            DateTime convertedDate = DateTime.valueOf(replacementValue);
                            System.debug('repla123'+replacementValue );
                            String dateStr = convertedDate.format(countryDateFormat);
                            replacementValue = dateStr;
                            System.debug('repla123'+replacementValue );
                        }
                        System.debug(verb.Verbiage__c);
                        verb.Verbiage__c = verb.Verbiage__c.replaceAll(mergeFieldRegEx, replacementValue);
                        System.debug(verb.Verbiage__c);
                    } else {
                        System.debug(verb.Id);
                        if(verb.Id == 'a1Y21000002IpzD'){
                        System.debug(mergeField);
                        System.debug('doesnt contain');
                        System.debug(verb.Verbiage__c);
                        }
                    }
                } catch (Exception e) {
                    System.debug(e);
                    System.debug('Failed to replace merge field: ' + mergeField);
                }
            }
        }
        } catch (exception ex) {
            System.debug(ex);
        }
        
        return verbs;
    }
    // public static void MergeText(Set<String> fieldsToReplace, List<CONMAN_Contract_Verbiage__c> verbs, CONMAN_Contract__c contract){
    //    String strToReplace = ''; 
    //    if (source != null && obj != null) {
    //         Integer curPos = 0;
    //         List<String> fieldNames = new List<String>();
    //         Pattern mergeField = Pattern.compile('\\{!*[a-zA-Z0-9_\\. ]*\\}'); // Pattern to get Merge field from Verbiage
    //         Matcher matchFld = mergeField.matcher(source);
    //         List<String> fieldsList = new List<String>();;
    //         while(matchFld.find()){
    //             strToReplace += source.substring(curPos, matchFld.start());
    //             String fieldName = source.substring(matchFld.start()+2,matchFld.end()-1);
    //             fieldNames.add(fieldName.trim());
    //             curPos = matchFld.end(); 
    //         }
    //             Map<String, List<String>> objectFieldMap = new Map<String, List<String>>();
    //             for(String fieldName : fieldNames){
    //                 fieldsList = fieldName.split('\\.');
    //                 if(!objectFieldMap.containsKey('Contract')){
    //                     objectFieldMap.put('Contract', new List<string>());
    //                 }
    //                 objectFieldMap.get('Contract').add(fieldsList[1]);
    //             }
    //             String allFlds;
                
    //         // SObject temp = obj ;
    //         // String childRelation;
    //         // Schema.SObjectType ctype = temp.getSObjectType();
    //         // Map<String, Schema.SobjectField> fmap = ctype.getDescribe().fields.getMap(); 
    //         // for(String fName: fmap.keySet()) {
    //         //     if(String.valueOf(fmap.get(fName).getDescribe().getreferenceTo()).contains('CONMAN_Contract__c')){
    //         //             childRelation = fmap.get(fName).getDescribe().getRelationshipName();
    //         //     }
    //         // }
    //         // String fieldsToQuery;
    //         // List<string> fieldsToQueryList = allFlds.split(',');
    //         // for(String recField :fieldsToQueryList){
    //         //     if(fieldsToQuery <> null)
    //         //         fieldsToQuery += ', '+childRelation+'.'+recField;
    //         //     else
    //         //        fieldsToQuery = childRelation+'.'+recField; 
    //         // }
    //         // try {
    //         //     String query ='SELECT '+fieldsToQuery+' FROM '+temp.getSObjectType()+' WHERE id =\''+obj.id+'\' LIMIT 1 ';
    //         //     temp = Database.query(query);
    //         // } catch(Exception ex) {
    //         //     fieldsToQueryList.clear();
    //         //     fieldsToQueryList.add('[Invalid merge field: ' + matchFld.group() + ']');
    //         // }            
    //         // SObject acc = temp.getSObject(childRelation);
    //         for(String strField : fieldsToQueryList){
    //             String regExp = '{!'+fieldsList[0]+'.'+strField+'}';
    //             String replaceValue =String.valueOf(contract.get(strField.trim()));
    //             source = source.replace(regExp, replaceValue);
    //             strToReplace = source;
    //         }
    //             CONMAN_Contract_Verbiage__c conVerbObj = obj;
    //             conVerbObj.Verbiage__c = strToReplace;
    //     }
    
    // }
    /* RT-299 Anup ----End----*/
    public static Map<LicenseSet__c, List<Associated_Rate__c>> getProductData(String contractId, boolean isQuote, boolean isPricingTeam) {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        // Query AR separately from LC, because larger numbers of ARs under LCs can generate invalid query locator errors
        Map<Id, LicenseSet__c> licenseSets = new Map<Id, LicenseSet__c>([SELECT
                                                                         Id, Name, Disabled__c,
                                                                         Product_Name__c,
                                                                         Enterprise_Name__c,
                                                                         Enterprise_Name__r.Name,
                                                                         Enterprise_Name__r.Family__c,
                                                                         Enterprise_Name__r.Product_Name__c,
                                                                         Enterprise_Name__r.Order__c,
                                                                         CurrencyIsoCode
                                                                         FROM LicenseSet__c
                                                                         WHERE PGi_Contract__c = :contractId
                                                                         ORDER BY Enterprise_Name__r.Order__c ASC NULLS FIRST,
                                                                         Product_Name__c ASC NULLS FIRST]);
        List<Associated_Rate__c> associatedRates = [SELECT
                                                    Id, Name,
                                                    LicenseSet__c,
                                                    Default__c,
                                                    Disabled__c,
                                                    Override__c,
                                                    Rate_Name__c,
                                                    Quantity__c,
                                                    Tier_Bundling__c,
                                                    Description__c,
                                                    Recurrence__c,
                                                    Rate__c,
                                                    Rate__r.Rate_Name__c,
                                                    Rate__r.Description__c,
                                                    Rate__r.Recurrence__c,
                                                    Rate__r.Order__c,
                                                    Rate__r.Type__c,
                                                    Rate__r.Rate_Group__c,
                                                    Rate__r.Rate_Group__r.Id,
                                                    Rate__r.Rate_Group__r.Name,
                                                    Rate__r.Rate_Group__r.Description__c,
                                                    Rate__r.Rate_Group__r.Footer__c,
                                                    Rate__r.Rate_Group__r.Order__c,
                                                    Rate__r.Rate_Group__r.Multi_Grid__c,
                                                    CurrencyIsoCode,
                                                    Show_on_Quote__c
                                                    FROM Associated_Rate__c
                                                     WHERE LicenseSet__c IN :licenseSets.keySet()
                                                    ORDER BY Rate__r.Rate_Group__r.Order__c ASC NULLS FIRST,
                                                    Rate__r.Order__c ASC NULLS FIRST,
                                                    Rate_Name__c ASC NULLS FIRST];
        Map<LicenseSet__c, List<Associated_Rate__c>> result = new Map<LicenseSet__c, List<Associated_Rate__c>>();
        for (LicenseSet__c lc : licenseSets.values())
            result.put(lc, new List<Associated_Rate__c>());
        for (Associated_Rate__c ar : associatedRates) {
            //RT-522 We need to ensure when a user selects Quotes that they see all products/pricing line items (ie: Rates) that were on the Agreement page.
            /*// skip if it's a Quote and it shouldn't appear on the Quote,
            // if (isQuote) {
            //     if (!ar.Show_on_Quote__c && !(ar.Override__c != null && ar.Override__c != ar.Default__c && isPricingTeam))
            //         continue;
            // }*/
            // RT-567
            if (isQuote){
                    System.debug('Rendering');
                    if (!ar.Show_on_Quote__c && !(ar.Override__c != null && ar.Override__c != ar.Default__c && isPricingTeam))
                        continue;
                }
             result.get(licenseSets.get(ar.LicenseSet__c)).add(ar);
        }
        return result;
    }

    public static User getRepData(String repId) {
        return [SELECT FirstName, LastName, Fax, Phone, User_Region__c, Email FROM User WHERE id = :repId];
    }

    public static Contact getContactData(String oppId) {
       OpportunityContactRole contactData;
       Contact contactObjData;

        try{
            OpportunityContactRole oppContact = [SELECT ContactId FROM OpportunityContactRole
                                             WHERE OpportunityId = :oppId AND IsPrimary = true LIMIT 1];
            contactData = oppContact;
        } catch(Exception e){} // No worries we're trying the next one
        try{
            OpportunityContactRole agreementContact = [SELECT ContactId FROM OpportunityContactRole
                                             WHERE OpportunityId = :oppId AND Role = 'Agreement Signer' LIMIT 1];
            contactData = agreementContact;
        } catch(Exception e){} // Oh well there's nothing to show I guess

        if (contactData != null) {
            contactObjData = [SELECT id, Company_Name__c, Email, Title, FirstName, LastName, MailingCountry,
                MailingPostalCode, MailingState, MailingCity, MailingStreet, Phone, Fax, AccountId, Account.Name
                FROM Contact WHERE id = :contactData.ContactId ];
         country = contactObjData.MailingCountry;
             System.debug('contactData: '+contactData.ContactId);
         if(contactObjData.MailingCountry != 'United States' && contactObjData.MailingCountry != 'Canada'){
                dateFormatOutput = '0,date,dd/mm/yy';
                isUSA = false;

         }else{
            //    dateFormatOutput = '0,date,MM/dd/yy';
                isUSA = true;
         }
System.debug('The ID>>>>>>>'+contactData.ContactId);

            return [SELECT id, Company_Name__c, Email, Title, FirstName, LastName, MailingCountry,
                MailingPostalCode, MailingState, MailingCity, MailingStreet, Phone, Fax, AccountId, Account.Name
                FROM Contact WHERE id = :contactData.ContactId ];
            } else {
            return null;
        }
    }

    public static Opportunity getOpportunityData(String oppId) {
        return [SELECT Name, Type, Billing_Method__c, Invoice_Delivery__c, Invoice_Layout__c, Territory_Code__c,
                Primary_Won_Reason__c, Secondary_Won_Reason__c, Tertiary_Won_Reason__c, Differentiating_Win_Factors__c,
                Competitor_s__c, Incumbent__c, Competitor_Other_Product__c,Incumbent_Other_Product__c, OwnerId,Billing_Email__c,Primary_Contact__c,Primary_Contact_Title__c,Primary_Contact__r.Name,
                Primary_Contact_Email_Address__c,Primary_Contact_Phone__c,Opportunity_Number__c,TPx_Rep__c,
                 Account.Name, (Select ContactId, Contact.FirstName, Contact.LastName, Contact.Title,
                                                 Contact.Email, Contact.Phone, Contact.MailingStreet, Contact.MailingCity,
                                                 Contact.MailingState, Contact.MailingCountry, Contact.MailingPostalCode
                                                 From OpportunityContactRoles where IsPrimary = true)
                FROM Opportunity WHERE id = :oppId];
    }

    public static Map<Id, String> getESignTemplates(String region, CONMAN_Contract__c contract) {
        Map<Id, String> templates = new Map<Id, String>();
        String regionMatch = region;
        //RT-518 iContract users in India (not contacts) should only be allowed to use “short form” .(Vijay),also default to sort form
        String loginUserCountry = [SELECT Id, Country 
                                        FROM User 
                                        WHERE Id =: userInfo.getUserId()].Country;
        if(loginUserCountry == 'India'){
            regionMatch += ': Short Form';
        }
        else{
        //RT-519 we are checking for apac and emea both. 
            if(region == 'EMEA' || region == 'APAC') {
                if(String.isBlank(contract.Intl_Order_Type__C)) {
                    regionMatch += ': Long Form';
                } else {
                    regionMatch += ': ' +  contract.Intl_Order_Type__C;
                }
            } else if (region == 'US' || region == 'CAN') {
                regionMatch = 'NA';
            }
        }
        regionMatch += '%';
        List<echosign_dev1__Agreement_Template__c> templatesQ = [SELECT Id, Name
                                                                 FROM echosign_dev1__Agreement_Template__c
                                                                 WHERE Name LIKE :regionMatch
                                                                 AND echosign_dev1__Master_Object_Type__c = 'Opportunity'];
        for (echosign_dev1__Agreement_Template__c template : templatesQ) {
            templates.put(template.Id, template.Name);
        }
        return templates;
    }


    public static List<echosign_dev1__SIGN_Agreement__c> getESignData(Id oppId) {
        return [SELECT Id, Name, echosign_dev1__StatusVisible__c
                FROM echosign_dev1__SIGN_Agreement__c
                WHERE echosign_dev1__Opportunity__c = :oppId
                AND echosign_dev1__StatusVisible__c != 'Signed'
                AND echosign_dev1__StatusVisible__c != 'Cancelled / Declined'
                AND echosign_dev1__StatusVisible__c != 'Expired'
                AND echosign_dev1__StatusVisible__c != 'Approved'];
    }

    // Helper Functions 
    public static String calculateTerm(String terms, Decimal termLength) {
        return terms.replace('[termLength]', iContract.formatTimeRange(termLength) + ' ');
    }

    public static boolean isStringEqual(String first, String second) {
        if (first == null && second == null)
            return true;
        if (first == null && second != null)
            return false;
        else if (first != null && second == null)
            return false;
        else
            return first.equals(second);
    }

    public static boolean isRateChanged(Associated_Rate__c oldAR, Associated_Rate__c newAR) {
        if (oldAR.Override__c != newAR.Override__c)
            return true;

        if (!isStringEqual(oldAR.Description__c, newAR.Description__c))
            return true;

        if (!isStringEqual(oldAR.Recurrence__c, newAR.Recurrence__c))
            return true;

        if (!isStringEqual(oldAR.Rate_Name__c, newAR.Rate_Name__c))
            return true;

        if (oldAR.Disabled__c != newAR.Disabled__c)
            return true;

        return false;
    }

    public static boolean isLicenseChanged(LicenseSet__c oldLS, LicenseSet__c newLS) {
        if (!isStringEqual(oldLS.Product_Name__c, newLS.Product_Name__c))
            return true;

        if (oldLS.Disabled__c != newLS.Disabled__c)
            return true;

        return false;
    }
   
}