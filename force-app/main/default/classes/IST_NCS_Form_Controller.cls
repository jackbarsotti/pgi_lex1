public class IST_NCS_Form_Controller {

    public class CSVException extends Exception {}
    public class EndpointException extends Exception {}

    public static String getStateLabel(String country, String state) {
        if (country == null || state == null || country == '' || state == '')
            return '';
        String label = AddressValidation.getSubdivisionName(country + '-' + state);
        if (label == null || label == '' || label.startsWith('INVALID'))
            label = state;
        return label.toUpperCase();
    }

    public static String getCountryLabel(String country) {
        if (country == null || country == '')
            return '';
        String label = AddressValidation.getCountryName(country);
        if (label == null || label == '' || label.startsWith('INVALID'))
            label = country;
        return label.toUpperCase();
    }

/*   public class Address {
       public Address__c address {get; set;}

        public Address(Address__c address) {
            this.address = address;
        }  

        public string getStateLabel() {
            return getStateLabel(address.Country__c, address.State__c);
        }

        public string getCountryLabel() {
            return getCountryLabel(address.Country__c);
        }
    }  */
    
    public class SOTS {
        public String productName {get; set;}
        public Decimal length {get; set;}
        public Decimal frequency {get; set;}
        public String code {get; set;}
        public Boolean required {get; set;}

        public SOTS(LicenseSet__c license, Decimal length, Decimal frequency, String agreementType, List<CPQ_SOTS__c> sotsToCheck, String contactRegion) {
            this.productName = license.Product_Name__c;
            this.length = length;
            this.frequency = frequency;
            this.required = True;

            if (license.Enterprise_Name__c != null) {
                this.required = license.Enterprise_Name__r.SOTS__c;
                /*if (frequency == 1) {
                    this.code = license.Enterprise_Name__r.SOTS_Monthly__c;
                } else if (frequency == 12) {
                    this.code = license.Enterprise_Name__r.SOTS_Annual__c;
                }*/
                for (CPQ_SOTS__c s : sotsToCheck){
                    if (license.Enterprise_Name__c == s.CPQ_Offering__c && s.Frequency__c == frequency && s.Agreement_Type__c.Contains(agreementType) && s.Region__c.Contains(contactRegion)){
                        // System.debug('SOTS code match: ' + s.SOTS_Code__c);
                        this.code = s.SOTS_Code__c;
                        break;
                    }                                        
                }                
            }
        }

        public String termText {
            get {
                return iContract.formatTimeRange(length);
            } private set;
        }

        public String frequencyText {
            get {
                return iContract.formatTimeRecurrence(frequency);
            } private set;
        }

        public String requiredText {
            get {
                String r = 'Unknown!';
                if (required) {
                    if (code != null && code != '') {
                        r = 'Automatic';
                    } else {
                        r = 'Required but Missing - Manual';
                    }
                } else {
                    r = 'N/A';
                }
                return r;
            } private set;
        }

        public String statusStyle {
            get {
                String s = '';
                if (required) {
                    if (code != null && code != '') {
                        s = 'color:#aaf;';
                    } else {
                        s = 'color:#f55;';
                    }
                } else {
                    s = 'color:#999;';
                }
                return s;
            } private set;
        }
    }

    public class FlowableVariable {
        public String name;
        public Object value;

        public FlowableVariable(String name, Object value) {
            this.name = name;
            this.value = value;
        }
    }

    public static final String AGREEMENT_FROM_NCS {
        get {
            return 'SIGNED: Uploaded to NCS.pdf';
        }
        private set;
    }

    public static final String AGREEMENT_FROM_ICONTRACT {
        get {
            return 'SIGNED: iContract.pdf';
        }
        private set;
    }

    public static final String AGREEMENT_FROM_ESIG {
        get {
            return 'SIGNED: eSignature.pdf';
        }
        private set;
    }

    public final Implementation_Services__c ISRecord {get; private set;}
    public final List<Implementation_Services__c> ISRecords {get; private set;}

    public final CONMAN_Contract__c iContract {get; private set;}
    public final List<Rate__c> iContractCPEs {get; private set;}
    public final List<LicenseSet__c> licenseSets {get; private set;}
    public final List<LicenseSet__c> licenseSetsUCaaS {get; private set;}
    public final Set<String> iContractFamilies {get; private set;}
    public final Set<Id> offerings {get; private set;}

    public List<SelectOption> countries {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for (String countryCode : ISO3166_Countries.countryCodes.keySet())
                options.add(new SelectOption(countryCode, ISO3166_Countries.countryCodes.get(countryCode)));
            return options;
        }
        private set;
    }

    public List<SelectOption> companyStates {
        get {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--Select a State--'));
            Map<String, String> subdivisions = AddressValidation.getCountrySubdivisions(this.ISRecord.NCS_Company_Country__c);
            for (String subdivisionCode : subdivisions.keySet())
                options.add(new SelectOption(subdivisionCode, subdivisions.get(subdivisionCode)));
            return options;
        }
        private set;
    }

    public String companyCountryLabel {
        get {
            return getCountryLabel(this.ISRecord.NCS_Company_Country__c);
        }
        private set;
    }

    public String companyStateLabel {
        get {
            return getStateLabel(this.ISRecord.NCS_Company_Country__c, this.ISRecord.NCS_Company_State__c);
        }
        private set;
    }

    public List<SelectOption> billToStates {
        get {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--Select a State--'));
            Map<String, String> subdivisions = AddressValidation.getCountrySubdivisions(this.ISRecord.NCS_BillTo_Country__c);
            for (String subdivisionCode : subdivisions.keySet())
                options.add(new SelectOption(subdivisionCode, subdivisions.get(subdivisionCode)));
            return options;
        }
        private set;
    }

    public String billToCountryLabel {
        get {
            return getCountryLabel(this.ISRecord.NCS_BillTo_Country__c);
        }
        private set;
    }

    public String billToStateLabel {
        get {
            return getStateLabel(this.ISRecord.NCS_BillTo_Country__c, this.ISRecord.NCS_BillTo_State__c);
        }
        private set;
    }

    public List<SelectOption> adminStates {
        get {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--Select a State--'));
            Map<String, String> subdivisions = AddressValidation.getCountrySubdivisions(this.ISRecord.NCS_Admin_Country__c);
            for (String subdivisionCode : subdivisions.keySet())
                options.add(new SelectOption(subdivisionCode, subdivisions.get(subdivisionCode)));
            return options;
        }
        private set;
    }

    public String adminCountryLabel {
        get {
            return getCountryLabel(this.ISRecord.NCS_Admin_Country__c);
        }
        private set;
    }

    public String adminStateLabel {
        get {
            return getStateLabel(this.ISRecord.NCS_Admin_Country__c, this.ISRecord.NCS_Admin_State__c);
        }
        private set;
    }

   /* public List<SelectOption> addressStates {
        get {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--Select a State--'));
            Map<String, String> subdivisions = AddressValidation.getCountrySubdivisions(this.newAddress.Country__c);
            for (String subdivisionCode : subdivisions.keySet())
                options.add(new SelectOption(subdivisionCode, subdivisions.get(subdivisionCode))); 
            return options;
        }
        private set;
    } */

    public Map<String, String> billToTypeLabels {
        get {
            Schema.DescribeFieldResult fieldResult = Implementation_Services__c.NCS_BillTo_Type__c.getDescribe();
            List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
            Map<String, String> billToTypes = new Map<String, String>();
            billToTypes.put(null, 'Unknown');
            billToTypes.put('', 'Unknown');
            for( Schema.PicklistEntry v : values) {
                billToTypes.put(v.getValue(), v.getLabel());
            }
            return billToTypes;
        }
        private set;
    }

    public Blob importCSV {get;set;}

    public String addressId {get; set;}
    public String cpeId {get; set;}

//    public List<Address> addresses {get; set;}

    public Integer offsetCPE = 0;
    public Integer offsetAddress = 0;
    public Integer offsetAmount = 20;

    public String searchAddressRecipient {get; set;}
    public String searchCPEMake {get; set;}
    public String searchCPEModel {get; set;}

 /*   public List<String> allAddressRecipients {
        get {
            Set<String> recipients = new Set<String>();
            if (this.addresses == null || this.addresses.size() <= 0)
                return new List<String>(recipients);
            for (Address addr : this.addresses)
                recipients.add(addr.address.Recipient_Name__c);  
            return new List<String>(recipients);
        }
        private set;
    }  */

    public List<SelectOption> iContractCPEMakes {
        get {
            Set<String> makesSet = new Set<String>();
            List<SelectOption> makes = new List<SelectOption>();
            if (this.iContractCPEs == null || this.iContractCPEs.size() <= 0)
                return makes;
            for (Rate__c cpe : this.iContractCPEs)
                makesSet.add(cpe.CPE_Make__c);
            for (String cpe : makesSet)
                makes.add(new SelectOption(cpe, cpe));
            return makes;
        }
        private set;
    }

    public Map<String, List<SelectOption>> iContractCPEModels {
        get {
            Map<String, Set<String>> modelSet = new Map<String, Set<String>>();
            Map<String, List<SelectOption>> models = new Map<String, List<SelectOption>>();
            models.put(null, new List<SelectOption>());
            models.put('', new List<SelectOption>());
            if (this.iContractCPEs == null || this.iContractCPEs.size() <= 0)
                return models;
            for (Rate__c cpe : this.iContractCPEs) {
                if (!modelSet.containsKey(cpe.CPE_Make__c))
                    modelSet.put(cpe.CPE_Make__c, new Set<String>());
                modelSet.get(cpe.CPE_Make__c).add(cpe.CPE_Model__c);
            }
            for (String make : modelSet.keySet()) {
                models.put(make, new List<SelectOption>());
                for (String model : modelSet.get(make))
                    models.get(make).add(new SelectOption(model, model));
            }
            return models;
        }
        private set;
    }

    public boolean renderable {get; private set;}
    public string unrenderableReason {get; private set;}

    public boolean choosingNCS {get; private set;}
    public boolean viewingNCS {get; private set;}

    public List<PermissionSetAssignment> permissions {get; private set;}

    public boolean hasProvisionPermission {
        get {
            if (permissions == null || permissions.size() <= 0)
                return false;
            for (PermissionSetAssignment p : permissions)
                if (p.PermissionSet.Name == 'IST_Allow_Provisioning_from_NCS')
                    return true;
            return false;
        } private set;
    }

    static public Map<String, String> sectionNames {
        get {
            Map<String, String> results = new Map<String, String>();
            Schema.DescribeFieldResult fieldResult = Implementation_Services__c.NCS_Progress__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f : ple)
                results.put(f.getValue(), f.getLabel());
            return results;
        }
        private set;
    }

    static public Map<String, Integer> fieldSetLengths {
        get {
            Map<String, Integer> results = new Map<String, Integer>();
            results.put('sc1_1', SObjectType.Implementation_Services__c.FieldSets.sc1_1.getFields().size());
            results.put('sc1_p', SObjectType.Implementation_Services__c.FieldSets.sc1_p.getFields().size());
            results.put('sc1_2_bt', SObjectType.Implementation_Services__c.FieldSets.sc1_2_bt.getFields().size());
            results.put('sc1_2_end', SObjectType.Implementation_Services__c.FieldSets.sc1_2_end.getFields().size());
            results.put('sc1_3_admin', SObjectType.Implementation_Services__c.FieldSets.sc1_3_admin.getFields().size());
            results.put('sc1_3_end', SObjectType.Implementation_Services__c.FieldSets.sc1_3_end.getFields().size());
            results.put('sc1_4', SObjectType.Implementation_Services__c.FieldSets.sc1_4.getFields().size());
            results.put('sc1_7', SObjectType.Implementation_Services__c.FieldSets.sc1_7.getFields().size());
            results.put('sc1_8', SObjectType.Implementation_Services__c.FieldSets.sc1_8.getFields().size());
            results.put('sc2_1', SObjectType.Implementation_Services__c.FieldSets.sc2_1.getFields().size());
            results.put('sc3_1', SObjectType.Implementation_Services__c.FieldSets.sc3_1.getFields().size());
            results.put('sc4_1', SObjectType.Implementation_Services__c.FieldSets.sc4_1.getFields().size());
            return results;
        }
        private set;
    }

    public Map<String, String> nextSections {
        get {
            Map<String, String> results = new Map<String, String>();

            if (this.isReseller)
                results.put('sc1_1', 'sc1_p');
            else
                results.put('sc1_1', 'sc1_2');

            results.put('sc1_p', 'sc1_2');
            results.put('sc1_2', 'sc1_3');
            results.put('sc1_3', 'sc1_4');
            results.put('sc1_4', 'sc1_7');

            if (this.hasUCaaSLicenses) {
                results.put('sc1_7', 'sc1_8');
                results.put('sc1_8', 'sc1_8cpe');
                results.put('sc1_8cpe', 'sc2_1');
            } else {
                results.put('sc1_7', 'sc2_1');
            }

            results.put('sc2_1', 'sc3_1');
            results.put('sc3_1', 'sc4_1');
            results.put('sc4_1', 'scA');
            results.put('scA', 'Ready');
            results.put('Ready', 'Ready');
            return results;
        }
        private set;
    }

    public Map<String, boolean> existingAttachments {get; private set;}
    public Map<String, Attachment> providedAttachments {get; private set;}

    public List<Provisioning_Log__c> provisioningLogs {get; private set;}
    public List<Note> notes {get; private set;}
    public Note newNote {get; private set;}

    public boolean hasProvisioningLogs {
        get {
            return this.provisioningLogs != null && this.provisioningLogs.size() > 0;
        }
        private set;
    }

//   public Address__c newAddress {get; private set;}
    public Boolean newAddressValidated {get; set;}
    public AddressValidation.AddressValidationResult newAddressValidation {get; private set;}

    public Boolean companyValidated {get; set;}
    public AddressValidation.AddressValidationResult companyValidation {get; private set;}

    public Boolean billToValidated {get; set;}
    public AddressValidation.AddressValidationResult billToValidation {get; private set;}

    public Boolean adminValidated {get; set;}
    public AddressValidation.AddressValidationResult adminValidation {get; private set;}

    public boolean hasRelatedForms {
        get {
            return this.ISRecords != null && this.ISRecords.size() > 1;
        }
        private set;
    }

    public String currentStatus {
        get {
            return this.ISRecord.NCS_Progress__c;
        }
        private set;
    }

    public boolean validStatus {
        get {
            return this.currentStatus != null && this.currentStatus != '';
        }
        private set;
    }
    private Opportunity opp {get {
        if(this.ISRecord == null) {
            return null;
        } else {
            if(opp == null) {
                opp = [SELECT AccountId, Account.Type, JointSellingInitiative__c, Agreement_Status__c FROM Opportunity WHERE Id = :this.ISRecord.Related_Opportunity__c];
            }
            return opp;
        }
    } set;}
    public boolean isReseller {
        get {
            // simple check to avoid errors when a specific ISRecord is not found,
            // when this check doesn't even matter
            if (this.ISRecord == null)
                return false;
            return opp != null && opp.AccountId != null && opp.Account.Type == 'End User - Reseller';
        }
        private set;
    }

    public boolean isJointSeller {
        get {
            // simple check to avoid errors when a specific ISRecord is not found,
            // when this check doesn't even matter
            if (this.ISRecord == null)
                return false;

            return opp.JointSellingInitiative__c;
        }
        private set;
    }
    public PageReference BillToAdminSet() {
        if(ISRecord.NCS_Is_BillTo_Admin__c) {
            ISRecord.Admin_Is_Licensed_User__c = true;
        }
        return null;
    }
    public Map<String, Boolean> isVisible {
        get {
            Map<String, Boolean> iv = new Map<String, Boolean>();
            iv.put('sc1_1', isVisible('sc1_1'));
            iv.put('sc1_p', isVisible('sc1_p'));
            iv.put('sc1_2', isVisible('sc1_2'));
            iv.put('sc1_3', isVisible('sc1_3'));
            iv.put('sc1_4', isVisible('sc1_4'));
            iv.put('sc1_7', isVisible('sc1_7'));
            iv.put('sc1_8', isVisible('sc1_8'));
            iv.put('sc1_8cpe', isVisible('sc1_8cpe'));
            iv.put('sc2_1', isVisible('sc2_1'));
            iv.put('sc3_1', isVisible('sc3_1'));
            iv.put('sc4_1', isVisible('sc4_1'));
            iv.put('scA', isVisible('scA'));
            return iv;
        }
        private set;
    }

    public Map<String, Boolean> isOpen {
        get {
            Map<String, Boolean> io = new Map<String, Boolean>();
            io.put('sc1_1', isOpen('sc1_1'));
            io.put('sc1_p', isOpen('sc1_p'));
            io.put('sc1_2', isOpen('sc1_2'));
            io.put('sc1_3', isOpen('sc1_3'));
            io.put('sc1_4', isOpen('sc1_4'));
            io.put('sc1_7', isOpen('sc1_7'));
            io.put('sc1_8', isOpen('sc1_8'));
            io.put('sc1_8cpe', isOpen('sc1_8cpe'));
            io.put('sc2_1', isOpen('sc2_1'));
            io.put('sc3_1', isOpen('sc3_1'));
            io.put('sc4_1', isOpen('sc4_1'));
            io.put('scA', isOpen('scA'));
            return io;
        }
        private set;
    }

    public boolean submittable {
        get {
            return (currentStatus == 'Ready' || currentStatus == 'Submitted')
                && this.checkFields('sc1_1')
                && this.checkFields('sc1_p')
                && this.checkFields('sc1_2')
                && this.checkFields('sc1_3')
                && this.checkFields('sc1_4')
                && this.checkFields('sc1_7')
                && this.checkFields('sc1_8')
                && this.checkFields('sc1_8cpe')
                && this.checkFields('sc2_1')
                && this.checkFields('sc3_1')
                && this.checkFields('sc4_1')
                && this.checkFields('scA');
        }
        private set;
    }

    public boolean provisionable {
        get {
            return submittable && hasProvisionPermission && hasSOTS && iContractExists && !iContract.Word_File_In_Use__c;
        }
        private set;
    }

    public boolean submittedEmail {
        get {
            return currentStatus == 'Submitted';
        }
        private set;
    }

    public boolean submittedProvisioning {
        get {
            return currentStatus == 'Pending Provisioning';
        }
        private set;
    }

    public boolean provisioningComplete {
        get {
            return currentStatus == 'Provisioning: Success' || currentStatus == 'Provisioning: Failure';
        }
        private set;
    }

    public boolean isVideo {
        get {
            for (Schema.FieldSetMember field : SObjectType.Implementation_Services__c.FieldSets.sc1_7.getFields()) {
                if (fieldIsString(field.getType()) && this.ISRecord.get(field.getFieldPath()) != null && !String.isEmpty((String)this.ISRecord.get(field.getFieldPath()))) {
                    return true;
                }
            }
            return false;
        } private set;
    }

    public boolean agreementRequired {
        get {
            //01935035 
            //RT-537
            if(!Test.isRunningTest() && (opp != null && opp.Agreement_Status__c == 'Signed' || iContract.Contract_Status__c == 'Customer Accepted')) {
                return false;
            }
            return !checkField(this.ISRecord.NCS_Provider_Name__c) && !this.ISRecord.NCS_Inherit_Rates_of_Parent__c;
        }
        private set;
    }

    public boolean alternativeAgreement {
        get {
            return existingAttachments.get(AGREEMENT_FROM_ICONTRACT) || existingAttachments.get(AGREEMENT_FROM_ESIG);
        }
        private set;
    }

    public boolean iContractExists {
        get {
            return this.iContract != null;
        }
        private set;
    }

    public boolean hasUCaaSLicenses {
        get {
            return this.licenseSetsUCaaS != null && this.licenseSetsUCaaS.size() > 0;
        } private set;
    }

    public boolean hasiContractFamilies {
        get {
            return this.iContractFamilies != null && this.iContractFamilies.size() > 0;
        } private set;
    }

    public boolean hasSOTS {
        get {
            return this.licenseSets != null && this.licenseSets.size() > 0;
        } private set;
    }

    public final List<CPQ_SOTS__c> possibleSOTS {
        get {
            if(possibleSOTS == null){
            possibleSOTS = [SELECT Id, CPQ_Offering__c, Frequency__c, Agreement_Type__c, Region__c, SOTS_Code__c FROM CPQ_SOTS__c WHERE CPQ_Offering__c IN: offerings ORDER BY CPQ_Offering__c ASC];
            }  return possibleSOTS;  
        } private set;
    }
    
    public String opptyContactRegion {
        get {
            if(opptyContactRegion == null){
            Contact opptyContact = iContract_NA_Master_Controller.getContactData(this.ISRecord.Related_Opportunity__c); 
            if (opptyContact == null || opptyContact.MailingCountry == null){
                opptyContactRegion = 'US';
            } else {
                String region = CountryUtil.getCountryRegion(opptyContact.MailingCountry);
                if(region == '' ){
                    opptyContactRegion = 'US';
                } else {
                    opptyContactRegion = region;
                }
            }
        }
        return opptyContactRegion;
    }private set;
    }

    public List<SOTS> allSOTS {
        get {
            List<SOTS> s = new List<SOTS>();
            if (this.licenseSets == null) return s;
            for (LicenseSet__c ls : this.licenseSets){
                s.add(new SOTS(ls, iContract.Contracted_Term__c, iContract.Contracted_Frequency__c, iContract.Contract_Type__c, possibleSOTS, opptyContactRegion));
            }
            return s;
        } private set;
    }

    public boolean checkSOTS {
        get {
            Boolean check = True;
            for (SOTS s : allSOTS) {
                if (s.required) {
                    if (s.code == null || s.code == '') {
                        check = False;
                        break;
                    }
                }
            }
            return check;
        } private set;
    }

    /* CONSTRUCTOR */
    public IST_NCS_Form_Controller(ApexPages.StandardController stdController) {
        List<String> extraFields = new List<String>();
        extraFields.add('NCS_Progress__c');
        // extraFields.add('Account__c');
        extraFields.add('Related_Opportunity__c');
        extraFields.add('NCS_Existing_BillTo_Client__r.Name');
        extraFields.add('NCS_Parent_Company__r.Name');
        extraFields.add('Master_Implementation__c');
        extraFields.add('Master_Implementation__r.Name');
        extraFields.add('Master_Implementation_Record__c');
        if (!Test.isRunningTest()) stdController.addFields(extraFields);

        this.renderable = false;
        this.unrenderableReason = 'Failed to load Controller Record';
        this.choosingNCS = false;
        this.viewingNCS = false;

        permissions = [SELECT PermissionSet.Name
                       FROM PermissionSetAssignment
                       WHERE AssigneeId = :Userinfo.getUserId()
                       AND PermissionSet.Name = 'IST_Allow_Provisioning_from_NCS'];

        Id oppId;

        Map<String, String> pageParams = ApexPages.currentPage().getParameters();
        if (pageParams.containsKey('opp')) {
            oppId = pageParams.get('opp');
        } else if (pageParams.containsKey('id')) { // looking at an existing NCS Form
            this.ISRecord = (Implementation_Services__c)stdController.getRecord();

            if (this.ISRecord.Related_Opportunity__c == null) {
                this.unrenderableReason = 'This IST Record is not related to an Opportunity.';
                return;
            }

            oppId = this.ISRecord.Related_Opportunity__c;

            try { this.iContract = checkPGiContracts(this.ISRecord.Related_Opportunity__c); }
            // do nothing if we could not find a record
            catch (Exception e) {}

            try { this.licenseSets = checkLicenseSets(this.ISRecord.Related_Opportunity__c); }
            // do nothing if we could not find a record
            catch (Exception e) {}
            
            this.iContractFamilies = new Set<String>();
            this.offerings = new Set<Id>();

            if (this.licenseSets != null && this.licenseSets.size() > 0) {
                for (LicenseSet__c ls : this.licenseSets) {
                    if (ls.Enterprise_Name__c != null && ls.Enterprise_Name__r != null && ls.Enterprise_Name__r.Family__c != null) {
                        this.offerings.add(ls.Enterprise_Name__c);
                        List<String> families = ls.Enterprise_Name__r.Family__c.split(';');
                        for (String family : families) {
                            this.iContractFamilies.add(family.trim());
                        }
                    }
                }
            }

            try { this.licenseSetsUCaaS = checkLicenseSetsUCaaS(this.ISRecord.Related_Opportunity__c); }
            // do nothing if we could not find a record
            catch (Exception e) {}

            try { this.iContractCPEs = checkiContractCPEs(); }
            // do nothing if we could not find a record
            catch (Exception e) {}

            try { populateFields(); }
            // simply add messages if populations fail
            catch (Exception e) { exceptionHandler(e); }

        //   this.newAddress = new Address__c();

      //      try { this.addresses = checkAddresses(); }
            // simply add messages if checks fail
      //      catch (Exception e) { exceptionHandler(e); }

            try { checkAttachments(); }
            // simply add messages if checks fail
            catch (Exception e) { exceptionHandler(e); }

            this.newNote = new Note(ParentId = this.ISRecord.Id);
            try { this.notes = checkNotes(); }
            // do nothing if we could not find a record
            catch (Exception e) { this.notes = new List<Note>(); }

            try { this.provisioningLogs = checkProvisioningLogs(); }
            // do nothing if we could not find a record
            catch (Exception e) { this.provisioningLogs = new List<Provisioning_Log__c>(); }

            this.unrenderableReason = '';
            this.renderable = true;
            this.viewingNCS = true;
        } else {
            this.unrenderableReason = 'No New Company Setup (NCS) Form to work with.';
        }

        this.ISRecords = [
            SELECT Id, Name, toLabel(NCS_Progress__c), NCS_Company_Name__c, Master_Implementation__r.Name, CreatedDate, CreatedBy.Name
            FROM Implementation_Services__c
            WHERE Related_Opportunity__c = :oppId
            ORDER BY CreatedDate ASC
        ];
    }

    private CONMAN_Contract__c checkPGiContracts(Id oppId) {
        return [SELECT Id, Contract_Status__c, Word_File_In_Use__c, Contracted_Term__c, Contracted_Frequency__c, Contract_Type__c FROM CONMAN_Contract__c WHERE Opportunity__c = :oppId ORDER BY CreatedDate DESC LIMIT 1];
    }

    private List<Rate__c> checkiContractCPEs() {
        return [SELECT Id, Name, CPE_Make__c, CPE_Model__c FROM Rate__c WHERE CPE_Make__c != '' AND CPE_Model__c != '' ORDER BY Order__c ASC, CPE_Make__c ASC, CPE_Model__c ASC];
    }

    private List<LicenseSet__c> checkLicenseSets(Id oppId) {
        return [SELECT Id, Name, Product_Name__c, Enterprise_Name__c, Enterprise_Name__r.SOTS__c, Enterprise_Name__r.SOTS_Monthly__c, Enterprise_Name__r.SOTS_Annual__c, Enterprise_Name__r.Family__c FROM LicenseSet__c WHERE Opportunity__c = :oppId ORDER BY Enterprise_Name__r.Order__c ASC];
    }

    private List<LicenseSet__c> checkLicenseSetsUCaaS(Id oppId) {
        return [SELECT Id, Name FROM LicenseSet__c WHERE Opportunity__c = :oppId AND Enterprise_Name__r.Family__c INCLUDES ('UCaaS') ORDER BY CreatedDate DESC];
    }

    public static echosign_dev1__SIGN_Agreement__c checkAdobeAgreements(Id oppId) {
        return [SELECT Id, Name FROM echosign_dev1__SIGN_Agreement__c WHERE echosign_dev1__Opportunity__c = :oppId AND echosign_dev1__StatusVisible__c = 'Signed' ORDER BY CreatedDate DESC LIMIT 1];
    }

 /*   public List<Address> checkAddresses() {
        String searchRecipient = '%';
        if (this.searchAddressRecipient != null)
            searchRecipient = '%' + this.searchAddressRecipient + '%';

       List<Address> addrs = new List<Address>();
        for (Address__c addr : [SELECT Id, Name, Recipient_Name__c, Street_Address_1__c, Street_Address_2__c, City__c, Postal_Code__c, State__c, Country__c FROM Address__c WHERE Recipient_Name__c LIKE :searchRecipient ORDER BY CreatedDate DESC LIMIT :this.offsetAmount OFFSET :this.offsetAddress])
            addrs.add(new Address(addr)); 
        return addrs; 
    } */

    private Implementation_Services__c insertISRecord(Id oppId, Id accId) {
        Implementation_Services__c newISRecord = new Implementation_Services__c();
        newISRecord.Master_Implementation_Record__c = true;
        newISRecord.Related_Opportunity__c = oppId;
        // newISRecord.Account__c = accId;
        newISRecord.NCS_Progress__c = 'sc1_1';
        INSERT newISRecord;
        return newISRecord;
    }

    private PageReference getNCSFormPage(Id implId) {
        PageReference ncsPage = Page.IST_NCS_Form;
        ncsPage.getParameters().put('id', implId);
        ncsPage.setRedirect(true);
        return ncsPage;
    }

    public PageReference checkRedirect() {
        Map<String, String> pageParams = ApexPages.currentPage().getParameters();
        if (pageParams.containsKey('opp')) { // came here from an Opportunity link
            Id oppId = pageParams.get('opp');
            // go-to existing NCS if only 1, or choose
            try {
                if (this.ISRecords == null) {
                    this.unrenderableReason = 'Invalid response for NCS Form Query';
                    this.renderable = false;
                    return null;
                }

                if (this.ISRecords.size() == 1)
                    return getNCSFormPage(this.ISRecords.get(0).Id);

                if (this.ISRecords.size() > 1) {
                    this.renderable = true;
                    this.choosingNCS = true;
                    return null;
                }

                // size() == 0 will continue to the next block

            } catch (Exception e) { exceptionHandler(e); }

            // create a new one if none exist
            try {
                Opportunity o = [SELECT AccountId FROM Opportunity WHERE Id = :oppId];
                Implementation_Services__c ncsRecord = insertISRecord(oppId, o.AccountId);
                return getNCSFormPage(ncsRecord.Id);
            } catch (Exception e) { exceptionHandler(e); }
        }
        return null;
    }

    public void save() {
        // for proper cloning, always ensure the Master fields are setup correctly
        this.ISRecord.Master_Implementation_Record__c = this.ISRecord.Master_Implementation__c == null;

        // reset Bill-to fields if Moderator
        if (this.ISRecord.NCS_BillTo_Type__c == '2') {
            this.ISRecord.NCS_Use_Existing_BillTo_Client_ID__c = False;
            this.ISRecord.NCS_Is_BillTo_Licensed_User__c = False;
            this.ISRecord.NCS_Existing_BillTo_Client__c = null;
            this.ISRecord.NCS_BillTo_First_Name__c = null;
            this.ISRecord.NCS_BillTo_Last_Name__c = null;
            this.ISRecord.NCS_BillTo_Phone__c = null;
            this.ISRecord.NCS_BillTo_Address__c = null;
            this.ISRecord.NCS_BillTo_Email__c = null;
            this.ISRecord.NCS_BillTo_City__c = null;
            this.ISRecord.NCS_BillTo_State__c = null;
            this.ISRecord.NCS_BillTo_PostalCode__c = null;
            this.ISRecord.NCS_BillTo_Country__c = null;
        }

        // reset Bill-to fields if using existing Bill-to
        if (this.ISRecord.NCS_Use_Existing_BillTo_Client_ID__c) {
            this.ISRecord.NCS_BillTo_First_Name__c = null;
            this.ISRecord.NCS_BillTo_Last_Name__c = null;
            this.ISRecord.NCS_BillTo_Phone__c = null;
            this.ISRecord.NCS_BillTo_Address__c = null;
            this.ISRecord.NCS_BillTo_Email__c = null;
            this.ISRecord.NCS_BillTo_City__c = null;
            this.ISRecord.NCS_BillTo_State__c = null;
            this.ISRecord.NCS_BillTo_PostalCode__c = null;
            this.ISRecord.NCS_BillTo_Country__c = null;
        } else {
            this.ISRecord.NCS_Existing_BillTo_Client__c = null;
        }

        // always reset Admin fields if same as Bill-to
        if (this.ISRecord.NCS_Is_BillTo_Admin__c) {
            this.ISRecord.NCS_Admin_First_Name__c = null;
            this.ISRecord.NCS_Admin_Last_Name__c = null;
            this.ISRecord.NCS_Admin_Phone__c = null;
            this.ISRecord.NCS_Admin_Address__c = null;
            this.ISRecord.NCS_Admin_Email__c = null;
            this.ISRecord.NCS_Admin_City__c = null;
            this.ISRecord.NCS_Admin_State__c = null;
            this.ISRecord.NCS_Admin_PostalCode__c = null;
            this.ISRecord.NCS_Admin_Country__c = null;
        }

        // always reset Parent Company if not using it
        if (!this.ISRecord.NCS_Inherit_Rates_of_Parent__c) {
            this.ISRecord.NCS_Parent_Company__c = null;
        }

        // always reset Affiliate Company if not using it
        if (!this.ISRecord.NCS_Rate_Change_to_Affiliates__c) {
            this.ISRecord.NCS_Affiliate_Company_IDs__c = null;
        }

        // remove the Affiliate IDs attachment if it's not selected
        if (!this.ISRecord.NCS_Rate_Change_to_Affiliates__c)
            DELETE [SELECT Id FROM Attachment WHERE ParentId = :this.ISRecord.Id AND Name = 'AffiliateCompanyIDs.csv'];

        // remove the Letter of Authorization attachment if it's not selected
        if (!this.ISRecord.NCS_Port_Numbers__c)
            DELETE [SELECT Id FROM Attachment WHERE ParentId = :this.ISRecord.Id AND Name = 'LetterOfAuthorization.pdf'];

        // check attachments for updates and delete/insert as necessary
        for (String fileName : providedAttachments.keySet()) {
            if (providedAttachments.get(fileName).Body == null)
                continue;

            if (existingAttachments.containsKey(fileName) && existingAttachments.get(fileName))
                DELETE [SELECT Id FROM Attachment WHERE ParentId = :providedAttachments.get(fileName).ParentId AND Name = :fileName];

            INSERT providedAttachments.get(fileName);
        }

        // do this 'init' step again so that these checks can use it
        // and since the controller won't re-construct on the basic refresh
        checkAttachments();

        UPDATE this.ISRecord;

        resetValidation();
    }

    public PageReference saveForm() {
        try { save(); }
        catch (Exception e) { exceptionHandler(e); }
        return null;
    }

    public PageReference continueForm() {
        try {
            save();

            // move to the next section if validated
            if (!this.validStatus || !this.nextSections.containsKey(this.currentStatus)) {
                this.ISRecord.NCS_Progress__c = 'sc1_1';
            } else if (this.checkFields(this.currentStatus)) {
                this.ISRecord.NCS_Progress__c = this.nextSections.get(this.currentStatus);
            }
            UPDATE this.ISRecord;

            // do this 'init' step again because we're not reloading the page fully
            populateFields();
        }
        catch (Exception e) { exceptionHandler(e); }
        return null;
    }

    public PageReference resetValidation() {
        this.newAddressValidated = false;
        this.newAddressValidation = null;
        return null;
    }

    public PageReference createNote() {
        try {
            if (checkField(this.newNote.Title) && checkField(this.newNote.Body)) {
                INSERT this.newNote;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Incomplete Note'));
                return null;
            }
        }
        catch (Exception e) { exceptionHandler(e); }

        return getNCSFormPage(this.ISRecord.Id);
    }

 /*   public PageReference createAddress() {
        try {
           if (checkField(this.newAddress.Recipient_Name__c) && checkField(this.newAddress.City__c) && checkField(this.newAddress.Country__c) && newAddressValidated) {
                INSERT this.newAddress;  
                this.addresses = checkAddresses();  
                this.resetValidation();
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Incomplete Address: Recipient\'s Name, City, and Country are required'));
                return null;
            }
        }
        catch (Exception e) { exceptionHandler(e); } 

        return getNCSFormPage(this.ISRecord.Id); 
    } */

    public PageReference validateCompany() {
        try {
            AddressValidation.Address addr = new AddressValidation.Address(
                this.ISRecord.NCS_Company_Address1__c,
                this.ISRecord.NCS_Company_Address2__c,
                this.ISRecord.NCS_Company_City__c,
                this.ISRecord.NCS_Company_State__c,
                this.ISRecord.NCS_Company_PostalCode__c,
                this.ISRecord.NCS_Company_Country__c
            );
            this.companyValidation = AddressValidation.validateAddress_ScanSource(addr);
            this.companyValidated = this.companyValidation.isValid();

            AddressValidation.Address newAddr = this.companyValidation.getAddress();
            this.ISRecord.NCS_Company_Address1__c = newAddr.Street1;
            this.ISRecord.NCS_Company_Address2__c = newAddr.Street2;
            this.ISRecord.NCS_Company_City__c = newAddr.City;
            this.ISRecord.NCS_Company_State__c = newAddr.StateProvince;
            this.ISRecord.NCS_Company_PostalCode__c = newAddr.PostalCode;
            this.ISRecord.NCS_Company_Country__c = newAddr.CountryCode;
        }
        catch (Exception e) { exceptionHandler(e); } 

        return null;
    }

    public PageReference validateBillTo() {
        try {
            AddressValidation.Address addr = new AddressValidation.Address(
                this.ISRecord.NCS_BillTo_Address__c,
                '',
                this.ISRecord.NCS_BillTo_City__c,
                this.ISRecord.NCS_BillTo_State__c,
                this.ISRecord.NCS_BillTo_PostalCode__c,
                this.ISRecord.NCS_BillTo_Country__c
            );
            this.billToValidation = AddressValidation.validateAddress_ScanSource(addr);
            this.billToValidated = this.billToValidation.isValid();

            AddressValidation.Address newAddr = this.billToValidation.getAddress();
            this.ISRecord.NCS_BillTo_Address__c = newAddr.Street1;
            if (newAddr.Street2 != null && newAddr.Street2 != '')
                this.ISRecord.NCS_BillTo_Address__c += ' ' + newAddr.Street2;
            this.ISRecord.NCS_BillTo_City__c = newAddr.City;
            this.ISRecord.NCS_BillTo_State__c = newAddr.StateProvince;
            this.ISRecord.NCS_BillTo_PostalCode__c = newAddr.PostalCode;
            this.ISRecord.NCS_BillTo_Country__c = newAddr.CountryCode;
        }
        catch (Exception e) { exceptionHandler(e); } 

        return null;
    }

    public PageReference validateAdmin() {
        try {
            AddressValidation.Address addr = new AddressValidation.Address(
                this.ISRecord.NCS_Admin_Address__c,
                '',
                this.ISRecord.NCS_Admin_City__c,
                this.ISRecord.NCS_Admin_State__c,
                this.ISRecord.NCS_Admin_PostalCode__c,
                this.ISRecord.NCS_Admin_Country__c
            );
            this.adminValidation = AddressValidation.validateAddress_ScanSource(addr);
            this.adminValidated = this.adminValidation.isValid();

            AddressValidation.Address newAddr = this.adminValidation.getAddress();
            this.ISRecord.NCS_Admin_Address__c = newAddr.Street1;
            if (newAddr.Street2 != null && newAddr.Street2 != '')
                this.ISRecord.NCS_Admin_Address__c += ' ' + newAddr.Street2;
            this.ISRecord.NCS_Admin_City__c = newAddr.City;
            this.ISRecord.NCS_Admin_State__c = newAddr.StateProvince;
            this.ISRecord.NCS_Admin_PostalCode__c = newAddr.PostalCode;
            this.ISRecord.NCS_Admin_Country__c = newAddr.CountryCode;
        }
        catch (Exception e) { exceptionHandler(e); }   

        return null;
    }

  /*  public PageReference validateAddress() {
        try {
            if (checkField(this.newAddress.Recipient_Name__c) && checkField(this.newAddress.City__c) && checkField(this.newAddress.Country__c)) {
                String recipient = this.newAddress.Recipient_Name__c;
                AddressValidation.Address addr = new AddressValidation.Address(this.newAddress);
                this.newAddressValidation = AddressValidation.validateAddress_ScanSource(addr);
                this.newAddressValidated = this.newAddressValidation.isValid();
          //      this.newAddress = newAddressValidation.getAddress().toObject();
                this.newAddress.Recipient_Name__c = recipient;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Incomplete Address: Recipient\'s Name, City, and Country are required'));
                this.newAddressValidation = null;
                this.newAddressValidated = false;
                return null;
            }
        }
        catch (Exception e) { exceptionHandler(e); }  

        return null; 
    }  */

    public PageReference beginningCPE() {
        this.offsetCPE = 0;
        return null;
    }

    public PageReference nextCPE() {
        this.offsetCPE += this.offsetAmount;
        return null;
    }

    public PageReference prevCPE() {
        this.offsetCPE -= this.offsetAmount;
        this.offsetCPE = Math.max(0, this.offsetCPE);
        return null;
    }

  /*  public PageReference beginningAddress() {
        this.offsetAddress = 0;
        this.addresses = checkAddresses();
        return null;
    } */

  /*  public PageReference nextAddress() {
        this.offsetAddress += this.offsetAmount;
        this.addresses = checkAddresses();
        return null;
    }  */

  /*  public PageReference prevAddress() {
        this.offsetAddress -= this.offsetAmount;
        this.offsetAddress = Math.max(0, this.offsetAddress);
        this.addresses = checkAddresses();
        return null;
    }  */

 /*   public PageReference searchAddresses() {
        this.addresses = checkAddresses();
        return null;
    } */

    @Future(callout=true)
    public static void sendEmail(Id recordId, Id oppId, String companyName, Boolean isMaster, Id masterId, Boolean isVideo) {
        Opportunity opp = [SELECT Owner_Region__c FROM Opportunity WHERE Id =: oppId];
        iContract_Custom_Settings__c settings = iContract_Custom_Settings__c.getInstance();
        String recipientEmail = opp.Owner_Region__c == 'EMEA' ? settings.NCS_Default_Email_EMEA__c : settings.NCS_Default_Email__c;
        try {
            Messaging.reserveSingleEmailCapacity(2);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            if (isVideo)
                mail.setToAddresses(new String[] {recipientEmail, settings.NCS_Video_Email__c});
            else
                mail.setToAddresses(new String[] {recipientEmail});
            mail.setCcAddresses(new String[] {UserInfo.getUserEmail()});

            mail.setReplyTo(UserInfo.getUserEmail());
            mail.setSenderDisplayName(UserInfo.getFirstName() + ' ' + UserInfo.getLastName());
            mail.setUseSignature(false);

            mail.setSubject('New Company Setup: ' + companyName);
            if (!isMaster)
                mail.setSubject('New Company Setup: (follow-up)' + companyName);

            PageReference ncsEmail = Page.IST_NCS_Form_Email;
            ncsEmail.getParameters().put('id', (String)recordId);
            ncsEmail.setRedirect(true);

            Blob body;
            if (!Test.isRunningTest()) body = ncsEmail.getContent();
            else body = Blob.valueOf('test');

            mail.setHtmlBody(body.toString());

            List<String> attachmentIds = createEmailAttachments(recordId, masterId, oppId);
            mail.setEntityAttachments(attachmentIds);

            Messaging.sendEmail(new Messaging.Email[]{mail});

            INSERT new Provisioning_Log__c(Implementation_Services__c=recordId, Type__c='INFO', Log__c='Email sent to: ' + recipientEmail);
        } catch(Exception e) {
            INSERT new Provisioning_Log__c(Implementation_Services__c=recordId, Type__c='ERROR', Log__c='Unable to send email to: ' + recipientEmail + '\n' + exceptionText(e));
        }
    }

    public PageReference submitForm() {
        try {
            this.ISRecord.NCS_Progress__c = 'Submitted';
            UPDATE this.ISRecord;

            sendEmail(this.ISRecord.Id, this.ISRecord.Related_Opportunity__c, this.ISRecord.NCS_Company_Name__c, this.ISRecord.Master_Implementation_Record__c, this.ISRecord.Master_Implementation__c, this.isVideo);
        }
        catch (Exception e) { exceptionHandler(e); }
        return null;
    }

    public Map<String, Object> createFlowablePayload() {
        Implementation_Services__c ncs = [
        SELECT
            Id,
            Account_s_SFDC_18_Digit_Id__c,
            Admin_is_Licensed_User__c,
            Company_VAT_Number__c,
            Invoice_Language__c,
            Related_Opportunity__c,
            NCS_Company_Name__c,
            NCS_Company_Address1__c,
            NCS_Company_Address2__c,
            NCS_Company_City__c,
            NCS_Company_PostalCode__c,
            NCS_Company_State__c,
            NCS_Company_Country__c,
            NCS_Company_Region__c,
            NCS_Company_Currency__c,
            NCS_Is_Existing_Corporate_Customer__c,
            NCS_Existing_Corporate_Customer_Name__c,
            NCS_Existing_Enterprise__c,
            NCS_Use_Existing_BillTo_Client_ID__c,
            NCS_Existing_BillTo_Client__c,
            NCS_Is_BillTo_Licensed_User__c,
            NCS_BillTo_Type__c,
            NCS_BillTo_First_Name__c,
            NCS_BillTo_Last_Name__c,
            NCS_BillTo_Address__c,
            NCS_BillTo_City__c,
            NCS_BillTo_Email__c,
            NCS_BillTo_Phone__c,
            NCS_BillTo_PostalCode__c,
            NCS_BillTo_State__c,
            NCS_BillTo_Country__c,
            NCS_Is_BillTo_Admin__c,
            NCS_Admin_First_Name__c,
            NCS_Admin_Last_Name__c,
            NCS_Admin_Address__c,
            NCS_Admin_City__c,
            NCS_Admin_Email__c,
            NCS_Admin_Phone__c,
            NCS_Admin_PostalCode__c,
            NCS_Admin_State__c,
            NCS_Admin_Country__c,
            NCS_Invoice_Delivery__c,
            NCS_Invoice_Layout__c,
            NCS_Video_Invoice_Delivery__c,
            NCS_Rate_Change_to_Affiliates__c,
            NCS_Affiliate_Company_IDs__c,
            NCS_Inherit_Rates_of_Parent__c,
            NCS_Parent_Company__c,
            NCS_Provider_ID__c,
            NCS_Provider_Name__c,
            NCS_Sales_Channel__c,
            NCS_Sales_Person__c,
            NCS_Sales_Region__c,
            NCS_Territory_Code__c,
            NCS_Campaign__c,
            NCS_Video_Services__c,
            NCS_Service_Contact_Email__c,
            NCS_Service_Contact_Name__c,
            NCS_Service_Contact_Phone__c,
            NCS_Requested_URL_GM__c,
            NCS_Do_Not_Solicit__c,
            NCS_Is_HD_Audio_Required__c,
            NCS_Number_Presentment__c,
            NCS_GM_Skype_Server__c,
            NCS_GM_Version__c,
            NCS_Block_GM_Web_Per_Minute__c,
            NCS_Bridge_Group__c,
            NCS_Standalone_Automated_Conferencing__c,
            NCS_New_Numbers__c,
            NCS_Port_Numbers__c,
            // Promo_SOTS_Codes_applied_for_Admin__c,
            // Promo_SOTS_Codes_applied_for_Bill_To__c,
            Subsidiary_Name__c
        FROM Implementation_Services__c
        WHERE Id = :this.ISRecord.Id];

        String countryAlpha3 = '';
        Map<String, Object> payload = new Map<String, Object>();
        payload.put('message', 'New NCS Form Submission');
        List<FlowableVariable> variables = new List<FlowableVariable>();

        variables.add(new FlowableVariable('ncs_id', ncs.Id));
        // variables.add(new FlowableVariable('account_id', ncs.Account__c));
        variables.add(new FlowableVariable('opportunity_id', ncs.Related_Opportunity__c));
        variables.add(new FlowableVariable('account_id', ncs.Account_s_SFDC_18_Digit_Id__c));
        variables.add(new FlowableVariable('Admin_is_Licensed_User', ncs.Admin_is_Licensed_User__c));
        variables.add(new FlowableVariable('Company_VAT_Number',  ncs.Company_VAT_Number__c));
        variables.add(new FlowableVariable('Invoice_Language', ncs.Invoice_Language__c));
        variables.add(new FlowableVariable('Company_Name', ncs.NCS_Company_Name__c));
        variables.add(new FlowableVariable('Company_Address1', ncs.NCS_Company_Address1__c));
        variables.add(new FlowableVariable('Company_Address2', ncs.NCS_Company_Address2__c));
        variables.add(new FlowableVariable('Company_City', ncs.NCS_Company_City__c));
        variables.add(new FlowableVariable('Company_PostalCode', ncs.NCS_Company_PostalCode__c));
        countryAlpha3 = AddressValidation.getAlpha3(ncs.NCS_Company_Country__c);
        if (countryAlpha3.length() != 3) countryAlpha3 = ncs.NCS_Company_Country__c;
        if(countryAlpha3 == 'US' || countryAlpha3 == 'USA'){
            variables.add(new FlowableVariable('Company_State', ncs.NCS_Company_State__c));
        }else{
            variables.add(new FlowableVariable('Company_Province', ncs.NCS_Company_State__c));
        }
        variables.add(new FlowableVariable('Company_Country', countryAlpha3));
        variables.add(new FlowableVariable('Company_Region', ncs.NCS_Company_Region__c));
        variables.add(new FlowableVariable('Company_Currency', ncs.NCS_Company_Currency__c));

        variables.add(new FlowableVariable('Is_Existing_Corporate_Customer', ncs.NCS_Is_Existing_Corporate_Customer__c));
        variables.add(new FlowableVariable('Existing_Corporate_Customer', ncs.NCS_Existing_Corporate_Customer_Name__c));

        variables.add(new FlowableVariable('Existing_Enterprise', ncs.NCS_Existing_Enterprise__c));

        variables.add(new FlowableVariable('Use_Existing_BillTo_Client_ID', ncs.NCS_Use_Existing_BillTo_Client_ID__c));
        variables.add(new FlowableVariable('Existing_BillTo_Client', ncs.NCS_Existing_BillTo_Client__c));

        variables.add(new FlowableVariable('Is_BillTo_Licensed_User', ncs.NCS_Is_BillTo_Licensed_User__c));
        variables.add(new FlowableVariable('BillTo_Type', ncs.NCS_BillTo_Type__c));
        variables.add(new FlowableVariable('BillTo_First_Name', ncs.NCS_BillTo_First_Name__c));
        variables.add(new FlowableVariable('BillTo_Last_Name', ncs.NCS_BillTo_Last_Name__c));
        variables.add(new FlowableVariable('BillTo_Address', ncs.NCS_BillTo_Address__c));
        variables.add(new FlowableVariable('BillTo_City', ncs.NCS_BillTo_City__c));
        variables.add(new FlowableVariable('BillTo_Email', ncs.NCS_BillTo_Email__c));
        variables.add(new FlowableVariable('BillTo_Phone', ncs.NCS_BillTo_Phone__c));
        variables.add(new FlowableVariable('BillTo_PostalCode', ncs.NCS_BillTo_PostalCode__c));
        countryAlpha3 = AddressValidation.getAlpha3(ncs.NCS_BillTo_Country__c);
        if (countryAlpha3.length() != 3) countryAlpha3 = ncs.NCS_BillTo_Country__c;
        variables.add(new FlowableVariable('BillTo_Country', countryAlpha3));
        if(countryAlpha3 == 'US' || countryAlpha3 == 'USA'){
            variables.add(new FlowableVariable('BillTo_State', ncs.NCS_BillTo_State__c));
        }else{
            variables.add(new FlowableVariable('BillTo_Province', ncs.NCS_BillTo_State__c));
        }
        variables.add(new FlowableVariable('Is_BillTo_Admin', ncs.NCS_Is_BillTo_Admin__c));
        variables.add(new FlowableVariable('Admin_First_Name', ncs.NCS_Admin_First_Name__c));
        variables.add(new FlowableVariable('Admin_Last_Name', ncs.NCS_Admin_Last_Name__c));
        variables.add(new FlowableVariable('Admin_Address', ncs.NCS_Admin_Address__c));
        variables.add(new FlowableVariable('Admin_City', ncs.NCS_Admin_City__c));
        variables.add(new FlowableVariable('Admin_Email', ncs.NCS_Admin_Email__c));
        variables.add(new FlowableVariable('Admin_Phone', ncs.NCS_Admin_Phone__c));
        variables.add(new FlowableVariable('Admin_PostalCode', ncs.NCS_Admin_PostalCode__c));
        countryAlpha3 = AddressValidation.getAlpha3(ncs.NCS_Admin_Country__c);
        if (countryAlpha3.length() != 3) countryAlpha3 = ncs.NCS_Admin_Country__c;
        variables.add(new FlowableVariable('Admin_Country', countryAlpha3));
        if(countryAlpha3 == 'US' || countryAlpha3 == 'USA'){
            variables.add(new FlowableVariable('Admin_State', ncs.NCS_Admin_State__c));
        }else{
            variables.add(new FlowableVariable('Admin_Province', ncs.NCS_Admin_State__c));
        }
        variables.add(new FlowableVariable('Invoice_Delivery', ncs.NCS_Invoice_Delivery__c));
        variables.add(new FlowableVariable('Invoice_Layout', ncs.NCS_Invoice_Layout__c));
        variables.add(new FlowableVariable('Video_Invoice_Delivery', ncs.NCS_Video_Invoice_Delivery__c));

        variables.add(new FlowableVariable('Rate_Change_to_Affiliates', ncs.NCS_Rate_Change_to_Affiliates__c));
        variables.add(new FlowableVariable('Affiliate_Company_IDs', ncs.NCS_Affiliate_Company_IDs__c));

        variables.add(new FlowableVariable('Inherit_Rates_of_Parent', ncs.NCS_Inherit_Rates_of_Parent__c));
        variables.add(new FlowableVariable('Parent_Company', ncs.NCS_Parent_Company__c));

        variables.add(new FlowableVariable('Provider_ID', ncs.NCS_Provider_ID__c));
        variables.add(new FlowableVariable('Provider_Name', ncs.NCS_Provider_Name__c));

        variables.add(new FlowableVariable('Sales_Channel', ncs.NCS_Sales_Channel__c));
        variables.add(new FlowableVariable('Sales_Person', ncs.NCS_Sales_Person__c));
        variables.add(new FlowableVariable('Sales_Region', ncs.NCS_Sales_Region__c));
        variables.add(new FlowableVariable('Sales_Territory_Code', ncs.NCS_Territory_Code__c));
        variables.add(new FlowableVariable('Sales_Campaign', ncs.NCS_Campaign__c));

        variables.add(new FlowableVariable('Video_Services', ncs.NCS_Video_Services__c));
        variables.add(new FlowableVariable('Video_Services_Contact_Email', ncs.NCS_Service_Contact_Email__c));
        variables.add(new FlowableVariable('Video_Services_Contact_Name', ncs.NCS_Service_Contact_Name__c));
        variables.add(new FlowableVariable('Video_Services_Contact_Phone', ncs.NCS_Service_Contact_Phone__c));

        variables.add(new FlowableVariable('Requested_URL_GM', ncs.NCS_Requested_URL_GM__c));
        variables.add(new FlowableVariable('Do_Not_Solicit', ncs.NCS_Do_Not_Solicit__c));
        variables.add(new FlowableVariable('Is_HD_Audio_Required', ncs.NCS_Is_HD_Audio_Required__c));
        variables.add(new FlowableVariable('Number_Presentment', ncs.NCS_Number_Presentment__c));
        variables.add(new FlowableVariable('GM_Skype_Server', ncs.NCS_GM_Skype_Server__c));
        variables.add(new FlowableVariable('GM_Version', ncs.NCS_GM_Version__c));
        variables.add(new FlowableVariable('Block_GM_Web_Per_Minute', ncs.NCS_Block_GM_Web_Per_Minute__c));
        variables.add(new FlowableVariable('Bridge_Group', ncs.NCS_Bridge_Group__c));
        variables.add(new FlowableVariable('Standalone_Automated_Conferencing', ncs.NCS_Standalone_Automated_Conferencing__c));

        variables.add(new FlowableVariable('UC_New_Numbers', ncs.NCS_New_Numbers__c));
        variables.add(new FlowableVariable('UC_Port_Numbers', ncs.NCS_Port_Numbers__c));

        variables.add(new FlowableVariable('iContract', this.iContractExists));
        variables.add(new FlowableVariable('iContract_SOTS_Codes_Completed', this.checkSOTS));

        // Compute iContract Product Families
        if (this.hasiContractFamilies) {
            variables.add(new FlowableVariable('iContract_Product_Families', String.join(new List<String>(this.iContractFamilies), ';')));
        } else {
            variables.add(new FlowableVariable('iContract_Product_Families', ''));
        }
        // variables.add(new FlowableVariable('Admin_Promo_Codes', ncs.Promo_SOTS_Codes_applied_for_Admin__c));
        // variables.add(new FlowableVariable('BillTo_Promo_Codes', ncs.Promo_SOTS_Codes_applied_for_Bill_To__c));
        variables.add(new FlowableVariable('Subsidiary_Name', ncs.Subsidiary_Name__c));
        // Compute iContract SOTS Codes
        if (this.hasSOTS) {
            Set<String> codes = new Set<String>();
            for (SOTS sots : allSOTS)
                if (sots.required && sots.code != null && sots.code != '')
                    codes.add(sots.code);
            variables.add(new FlowableVariable('iContract_SOTS_Codes', String.join(new List<String>(codes), ';')));
        } else {
            variables.add(new FlowableVariable('iContract_SOTS_Codes', ''));
        }

        // Compute GlobalMeteringID
        Integer gmid = 0;
        Map<String, Integer> gmid_map = new Map<String, Integer>();
        gmid_map.put('NABPUSD', 13);
        gmid_map.put('NABPCAD', 14);
        gmid_map.put('EUBPCHF', 15);
        gmid_map.put('EUBPDKK', 16);
        gmid_map.put('EUBPEUR', 17);
        gmid_map.put('EUBPGBP', 18);
        gmid_map.put('APBPINR', 19);
        gmid_map.put('EUBPNOK', 20);
        gmid_map.put('EUBPSEK', 21);
        gmid_map.put('EUBPUSD', 22);
        gmid_map.put('APBPAUD', 23);
        gmid_map.put('APBPHKD', 24);
        gmid_map.put('APBPSGD', 25);
        gmid_map.put('APBPNZD', 26);
        gmid_map.put('APBPUSD', 27);
        String possible_gmid = ncs.NCS_Company_Region__c + 'BP' + ncs.NCS_Company_Currency__c;
        if (gmid_map.containsKey(possible_gmid))
            gmid = gmid_map.get(possible_gmid);
        variables.add(new FlowableVariable('Company_GlobalMeteringID', gmid));

        payload.put('variables', variables);

        return payload;
    }

    public PageReference provisionForm() {
        Map<String, Object> payload = createFlowablePayload();
        String jsonPayload = JSON.serialize(payload);

        iContract_Custom_Settings__c settings = iContract_Custom_Settings__c.getInstance();
        HttpRequest request = new HttpRequest();
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(settings.Flowable_User__c + ':' + settings.Flowable_Password__c));
        request.setHeader('Authorization', authorizationHeader);
        request.setEndpoint(settings.Flowable_URL__c + '/engine/customers/ucaas');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(jsonPayload);

        // I'd like to store this now, but we cannot do it before the callout
        //INSERT new Provisioning_Log__c(Implementation_Services__c=this.ISRecord.Id, Type__c='INFO', Log__c=jsonPayload);

        try {
            HttpResponse response = new Http().send(request);
            if (response.getStatusCode() != 201)
                throw new EndpointException(response.getStatusCode() + ': ' + response.getBody());

            // So, we do it afterwards
            INSERT new Provisioning_Log__c(Implementation_Services__c=this.ISRecord.Id, Type__c='INFO', Log__c=jsonPayload);

            this.ISRecord.NCS_Progress__c = 'Pending Provisioning';
            UPDATE this.ISRecord;

            INSERT new Provisioning_Log__c(Implementation_Services__c=this.ISRecord.Id, Type__c='INFO', Log__c='Successful callout to: ' + request.getEndpoint());

            sendEmail(this.ISRecord.Id, this.ISRecord.Related_Opportunity__c, this.ISRecord.NCS_Company_Name__c, this.ISRecord.Master_Implementation_Record__c, this.ISRecord.Master_Implementation__c, this.isVideo);
        } catch (Exception e) {
            exceptionHandler(e);
            INSERT new Provisioning_Log__c(Implementation_Services__c=this.ISRecord.Id, Type__c='ERROR', Log__c='Unsuccessful callout to: ' + request.getEndpoint() + '\n' + exceptionText(e));
        }

        /*
        HttpRequest request = ESB_Interface.httpESB('dev-provisioner-start-service', 'api/accounts');
        try {
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody('{"ncsId":"' + this.ISRecord.Id + '"}');

            HttpResponse response = new Http().send(request);
            if (response.getStatusCode() != 200)
                throw new ESB_Interface.EndpointException(response.getStatusCode() + ': ' + response.getBody());

            this.ISRecord.NCS_Progress__c = 'Pending Provisioning';
            UPDATE this.ISRecord;

            INSERT new Provisioning_Log__c(Implementation_Services__c=this.ISRecord.Id, Type__c='INFO', Log__c='Successful callout to: ' + request.getEndpoint());

            sendEmail(this.ISRecord.Id, this.ISRecord.Related_Opportunity__c, this.ISRecord.NCS_Company_Name__c, this.ISRecord.Master_Implementation_Record__c, this.ISRecord.Master_Implementation__c, this.isVideo);
        }
        catch (Exception e) {
            exceptionHandler(e);
            INSERT new Provisioning_Log__c(Implementation_Services__c=this.ISRecord.Id, Type__c='ERROR', Log__c='Unsuccessful callout to: ' + request.getEndpoint() + '\n' + exceptionText(e));
        }
        */

        return null;
    }

    public PageReference cloneParentForChild() {
        String newId = null;

        try {
            String fields = null;

            // Create SOQL list of all fields for this object
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Implementation_Services__c.fields.getMap();
            for (Schema.SObjectField field : fieldMap.values()) {
                Schema.DescribeFieldResult f = field.getDescribe();
                if (f.isCreateable()) {
                    if (fields == null)
                        fields = f.getName();
                    else
                        fields += ',' + f.getName();
                }
            }

            // Determine if linking to the current record or the parent of this record
            String relatedId = this.ISRecord.Id;
            if (this.ISRecord.Master_Implementation__c != null)
                relatedId = this.ISRecord.Master_Implementation__c;

            // Query all fields, clone the record
            Implementation_Services__c original = (Implementation_Services__c)Database.query(
                'SELECT ' + fields + ' FROM Implementation_Services__c WHERE Id = \'' + relatedId + '\''
            );
            Implementation_Services__c clone = original.clone();

            // Reset some fields, insert
            clone.NCS_Progress__c = 'sc1_1';
            clone.Master_Implementation_Record__c = false;
            clone.Master_Implementation__c = relatedId;
            INSERT clone;
            newId = clone.Id;
        }
        catch (Exception e) { exceptionHandler(e); }

        if (newId == null)
            return null;
        else
            return getNCSFormPage(newId);
    }

    public void populateFields() {
        if (!this.validStatus || this.currentStatus == 'sc1_1') { // populate Section 1 Company info
            Opportunity opp = [
                SELECT
                Account.Name,
                Account.BillingStreet,
                Account.BillingCity,
                Account.BillingStateCode,
                Account.BillingPostalCode,
                Account.BillingCountryCode
                FROM Opportunity
                WHERE Id = :this.ISRecord.Related_Opportunity__c
            ];

            if (!checkField(this.ISRecord.NCS_Company_Name__c))
                this.ISRecord.NCS_Company_Name__c = opp.Account.Name;
            if (!checkField(this.ISRecord.NCS_Company_Address1__c))
                this.ISRecord.NCS_Company_Address1__c = opp.Account.BillingStreet;
            if (!checkField(this.ISRecord.NCS_Company_City__c))
                this.ISRecord.NCS_Company_City__c = opp.Account.BillingCity;
            if (!checkField(this.ISRecord.NCS_Company_State__c))
                this.ISRecord.NCS_Company_State__c = opp.Account.BillingStateCode;
            if (!checkField(this.ISRecord.NCS_Company_PostalCode__c))
                this.ISRecord.NCS_Company_PostalCode__c = opp.Account.BillingPostalCode;
            if (!checkField(this.ISRecord.NCS_Company_Country__c))
                this.ISRecord.NCS_Company_Country__c = opp.Account.BillingCountryCode;
        } else if (this.validStatus && this.currentStatus == 'sc1_p') {
            // nope
        } else if (this.validStatus && this.currentStatus == 'sc1_2') { // Populate Section 1 Bill-to info
            List<OpportunityContactRole> contacts = [
                SELECT
                IsPrimary,
                Role,
                Contact.FirstName,
                Contact.LastName,
                Contact.Phone,
                Contact.Email,
                Contact.MailingStreet,
                Contact.MailingCity,
                Contact.MailingStateCode,
                Contact.MailingPostalCode,
                Contact.MailingCountryCode
                FROM OpportunityContactRole
                WHERE OpportunityId = :this.ISRecord.Related_Opportunity__c
                AND (IsPrimary = true OR Role = 'Agreement Signer')
            ];

            Contact contact = null;
            for (OpportunityContactRole c : contacts) {
                if (c.IsPrimary && contact == null) contact = c.Contact;
                if (c.Role == 'Agreement Signer') contact = c.Contact;
            }

            if (contact != null) {
                if (!checkField(this.ISRecord.NCS_BillTo_First_Name__c)) {
                    this.ISRecord.NCS_BillTo_First_Name__c = contact.FirstName;
                    this.ISRecord.NCS_BillTo_Last_Name__c = contact.LastName;
                }
                if (!checkField(this.ISRecord.NCS_BillTo_Phone__c))
                    this.ISRecord.NCS_BillTo_Phone__c = contact.Phone;
                if (!checkField(this.ISRecord.NCS_BillTo_Email__c))
                    this.ISRecord.NCS_BillTo_Email__c = contact.Email;
                if (!checkField(this.ISRecord.NCS_BillTo_Address__c))
                    this.ISRecord.NCS_BillTo_Address__c = contact.MailingStreet;
                if (!checkField(this.ISRecord.NCS_BillTo_City__c))
                    this.ISRecord.NCS_BillTo_City__c = contact.MailingCity;
                if (!checkField(this.ISRecord.NCS_BillTo_State__c))
                    this.ISRecord.NCS_BillTo_State__c = contact.MailingStateCode;
                if (!checkField(this.ISRecord.NCS_BillTo_PostalCode__c))
                    this.ISRecord.NCS_BillTo_PostalCode__c = contact.MailingPostalCode;
                if (!checkField(this.ISRecord.NCS_BillTo_Country__c))
                    this.ISRecord.NCS_BillTo_Country__c = contact.MailingCountryCode;
            }
        } else if (this.validStatus && this.currentStatus == 'sc1_3') {
            // nope
        } else if (this.validStatus && this.currentStatus == 'sc1_4') { // Populate Section 1 GM info
            Opportunity opp = [
                SELECT
                GM_Version__c
                FROM Opportunity
                WHERE Id = :this.ISRecord.Related_Opportunity__c
            ];

            if (!checkField(this.ISRecord.NCS_GM_Version__c)) {
                if (opp.GM_Version__c == 'GM5')
                    this.ISRecord.NCS_GM_Version__c = '5.0';
                else if (opp.GM_Version__c == 'GM4')
                    this.ISRecord.NCS_GM_Version__c = '4.0';
            }
        } else if (this.validStatus && this.currentStatus == 'sc1_7') {
            // nope
        } else if (this.validStatus && this.currentStatus == 'sc1_8') {
            // TODO
        } else if (this.validStatus && this.currentStatus == 'sc1_8cpe') {
            // TODO
        } else if (this.validStatus && this.currentStatus == 'sc2_1') {
            // nope
        } else if (this.validStatus && this.currentStatus == 'sc3_1') {
            // nope
        } else if (this.validStatus && this.currentStatus == 'sc4_1') { // Populate Section 4 Sales Rep info
            Opportunity opp = [
                SELECT
                Owner.FirstName,
                Owner.LastName,
                Territory_Code__c,
                Owner_Region__c,
                Omniture_Campaign_Code__c,
                Channel__c
                FROM Opportunity
                WHERE Id = :this.ISRecord.Related_Opportunity__c
            ];

            if (!checkField(this.ISRecord.NCS_Sales_Person__c))
                this.ISRecord.NCS_Sales_Person__c = opp.Owner.FirstName + ' ' + opp.Owner.LastName;
            if (!checkField(this.ISRecord.NCS_Territory_Code__c))
                this.ISRecord.NCS_Territory_Code__c = opp.Territory_Code__c;
            if (!checkField(this.ISRecord.NCS_Sales_Region__c))
                this.ISRecord.NCS_Sales_Region__c = opp.Owner_Region__c;
            if (!checkField(this.ISRecord.NCS_Campaign__c))
                this.ISRecord.NCS_Campaign__c = opp.Omniture_Campaign_Code__c;
            if (!checkField(this.ISRecord.NCS_Sales_Channel__c))
                this.ISRecord.NCS_Sales_Channel__c = opp.Channel__c;
        } else if (this.validStatus && this.currentStatus == 'scA') { // Populate SOTS Codes pre-emptively
            this.ISRecord.NCS_SOTS_Codes__c = '';
            if (hasSOTS) {
                Set<String> codes = new Set<String>();
                for (SOTS sots : allSOTS)
                    if (sots.required && sots.code != null && sots.code != '')
                        codes.add(sots.code);
                this.ISRecord.NCS_SOTS_Codes__c = String.join(new List<String>(codes), '\n');
            }
        }
    }

    public void checkAttachments() {
        this.existingAttachments = new Map<String, boolean>();
        this.providedAttachments = new Map<String, Attachment>();
        for (String fileName : new List<String>{ 'AffiliateCompanyIDs.csv', 'BandwidthNumberRequest.xlsx', 'LetterOfAuthorization.pdf' }) {
            this.providedAttachments.put(fileName, new Attachment(ParentId = this.ISRecord.Id, Name = fileName));
            this.existingAttachments.put(fileName, false);
        }
        for (String fileName : new List<String>{ AGREEMENT_FROM_NCS, AGREEMENT_FROM_ICONTRACT, AGREEMENT_FROM_ESIG }) {
            this.providedAttachments.put(fileName, new Attachment(ParentId = this.ISRecord.Related_Opportunity__c, Name = fileName));
            this.existingAttachments.put(fileName, false);
        }

        List<Attachment> files;

        if (this.ISRecord.Master_Implementation__c != null) {
            files = [SELECT Id, Name FROM Attachment WHERE ParentId = :this.ISRecord.Master_Implementation__c];
            for (Attachment file : files) this.existingAttachments.put(file.Name, true);
        }

        files = [SELECT Id, Name FROM Attachment WHERE ParentId = :this.ISRecord.Id OR (ParentId = :this.ISRecord.Related_Opportunity__c AND Name LIKE 'SIGNED: %')];
        for (Attachment file : files) this.existingAttachments.put(file.Name, true);
    }

    public static List<String> createEmailAttachments(Id recordId, Id masterId, Id oppId) {
        List<String> attachments = new List<String>();

        List<String> ISTAttachmentNames = new List<String>{ 'AffiliateCompanyIDs.csv', 'BandwidthNumberRequest.xlsx', 'LetterOfAuthorization.pdf' };

        List<Attachment> files;

        if (masterId != null) {
            files = [SELECT Id, Name FROM Attachment WHERE ParentId = :masterId AND Name IN :ISTAttachmentNames];
            for (Attachment attachment : files) attachments.add(attachment.Id);
        }

        files = [SELECT Id, Name FROM Attachment WHERE (ParentId = :recordId AND Name IN :ISTAttachmentNames) OR (ParentId = :oppId)];
        for (Attachment attachment : files) attachments.add(attachment.Id);

        return attachments;
    }

    public List<Note> checkNotes() {
        if (this.ISRecord.Master_Implementation__c != null) {
            return [SELECT Id, Title, Body, CreatedBy.Name FROM Note WHERE (ParentId = :this.ISRecord.Id OR ParentId = :this.ISRecord.Master_Implementation__c) AND IsDeleted = false AND IsPrivate = false ORDER BY CreatedDate DESC];
        } else {
            return [SELECT Id, Title, Body, CreatedBy.Name FROM Note WHERE ParentId = :this.ISRecord.Id AND IsDeleted = false AND IsPrivate = false ORDER BY CreatedDate DESC];
        }
    }

    public List<Provisioning_Log__c> checkProvisioningLogs() {
        return [SELECT Id, Type__c, Log__c, Correlation_ID__c, CreatedDate FROM Provisioning_Log__c WHERE Implementation_Services__c = :this.ISRecord.Id ORDER BY CreatedDate DESC];
    }

    public PageReference refreshProvisioningLogs() {
        try { this.provisioningLogs = checkProvisioningLogs(); }
        catch (Exception e) { exceptionHandler(e); }
        return null;
    }

    public boolean fieldIsString(Schema.DisplayType t) {
        if (t == Schema.DisplayType.Combobox ||
            t == Schema.DisplayType.Currency ||
            t == Schema.DisplayType.Email ||
            t == Schema.DisplayType.ID ||
            t == Schema.DisplayType.MultiPicklist ||
            t == Schema.DisplayType.Phone ||
            t == Schema.DisplayType.Picklist ||
            t == Schema.DisplayType.Reference ||
            t == Schema.DisplayType.String ||
            t == Schema.DisplayType.TextArea ||
            t == Schema.DisplayType.URL)
            return true;
        return false;
    }

    public boolean checkField(String field) {
        return field != null && !String.isEmpty(field);
    }

    public boolean checkFields(List<Schema.FieldSetMember> fields) {
        for (Schema.FieldSetMember field : fields) {
            // System.debug('field---====>'+field);
            if (fieldIsString(field.getType()) && (field.getDbRequired() || field.getRequired()) && !checkField((String)this.ISRecord.get(field.getFieldPath())))
                return false;
        }
        return true;
    }

    public boolean checkFields(String section) {
    // System.debug('Section-in-Ck==>'+section);
        if (section == 'sc1_1') {
            return checkFields(SObjectType.Implementation_Services__c.FieldSets.sc1_1.getFields())
                && checkField(this.ISRecord.NCS_Company_Address1__c)
                && checkField(this.ISRecord.NCS_Company_City__c)
                && checkField(this.ISRecord.NCS_Company_Country__c);
                // && checkField(this.ISRecord.NCS_Company_Region__c)
                // && checkField(this.ISRecord.NCS_Company_Currency__c);


        } else if (section == 'sc1_p') {
            return checkFields(SObjectType.Implementation_Services__c.FieldSets.sc1_p.getFields());


        } else if (section == 'sc1_2') {
            if (!checkFields(SObjectType.Implementation_Services__c.FieldSets.sc1_2_end.getFields()))
                return false;

            if (!checkField(this.ISRecord.NCS_BillTo_Type__c))
                return false;

            if (this.ISRecord.NCS_BillTo_Type__c == '2') // Moderator
                return true;

            if (this.ISRecord.NCS_Use_Existing_BillTo_Client_ID__c)
                return checkField(this.ISRecord.NCS_Existing_BillTo_Client__c);
            else
                return checkFields(SObjectType.Implementation_Services__c.FieldSets.sc1_2_bt.getFields())
                    && checkField(this.ISRecord.NCS_BillTo_Address__c)
                    && checkField(this.ISRecord.NCS_BillTo_City__c)
                    && checkField(this.ISRecord.NCS_BillTo_Country__c);


        } else if (section == 'sc1_3') {
            return this.ISRecord.NCS_Is_BillTo_Admin__c
                || (checkField(this.ISRecord.NCS_Admin_First_Name__c)
                    && checkField(this.ISRecord.NCS_Admin_Last_Name__c)
                    && checkField(this.ISRecord.NCS_Admin_Phone__c)
                    && checkField(this.ISRecord.NCS_Admin_Address__c)
                    && checkField(this.ISRecord.NCS_Admin_Email__c)
                    && checkField(this.ISRecord.NCS_Admin_City__c)
                    && checkField(this.ISRecord.NCS_Admin_Country__c));


        } else if (section == 'sc1_4') {
            return checkFields(SObjectType.Implementation_Services__c.FieldSets.sc1_4.getFields());


        } else if (section == 'sc1_7') {
            return checkFields(SObjectType.Implementation_Services__c.FieldSets.sc1_7.getFields());


        } else if (section == 'sc1_8') {
            if (!this.hasUCaaSLicenses)
                return true;
            if (!checkFields(SObjectType.Implementation_Services__c.FieldSets.sc1_8.getFields()))
                return false;
            if (!this.existingAttachments.get('BandwidthNumberRequest.xlsx'))
                return false;
            if (this.ISRecord.NCS_Port_Numbers__c && !this.existingAttachments.get('LetterOfAuthorization.pdf'))
                return false;
            return true;


        } else if (section == 'sc1_8cpe') {
            
            return true;


        } else if (section == 'sc2_1' && section != null) {
           // System.debug('sec-sc2------>'+checkFields(SObjectType.Implementation_Services__c.FieldSets.sc2_1.getFields()));
            return checkFields(SObjectType.Implementation_Services__c.FieldSets.sc2_1.getFields());


        } else if (section == 'sc3_1') {
            if (!checkFields(SObjectType.Implementation_Services__c.FieldSets.sc3_1.getFields()))
                return false;
            if (this.ISRecord.NCS_Rate_Change_to_Affiliates__c)
                return checkField(this.ISRecord.NCS_Affiliate_Company_IDs__c) || this.existingAttachments.get('AffiliateCompanyIDs.csv');
            else if (this.ISRecord.NCS_Inherit_Rates_of_Parent__c)
                return checkField(this.ISRecord.NCS_Parent_Company__c);
            return true;


        } else if (section == 'sc4_1') {
            return checkFields(SObjectType.Implementation_Services__c.FieldSets.sc4_1.getFields());


        } else if (section == 'scA') {
            if (this.agreementRequired)
                return this.existingAttachments.get(AGREEMENT_FROM_NCS) || this.alternativeAgreement;
            return true;


        } else {
            return false;
        }
    }

    public boolean isOpen(String section) {
    // System.debug('section--in--IO===>'+section);
        if (section == 'sc1_1') {
            return !this.validStatus || this.currentStatus == 'sc1_1' || (this.isVisible('sc1_1') && !this.checkFields('sc1_1'));
        } else if (section == 'sc1_p') {
            return (this.isReseller && this.currentStatus == 'sc1_p') || (this.isVisible('sc1_p') && !this.checkFields('sc1_p'));
        } else if (section == 'sc1_2') {
            return this.currentStatus == 'sc1_2' || (this.isVisible('sc1_2') && !this.checkFields('sc1_2'));
        } else if (section == 'sc1_3') {
            return this.currentStatus == 'sc1_3' || (this.isVisible('sc1_3') && !this.checkFields('sc1_3'));
        } else if (section == 'sc1_4') {
            return this.currentStatus == 'sc1_4' || (this.isVisible('sc1_4') && !this.checkFields('sc1_4'));
        } else if (section == 'sc1_7') {
            return this.currentStatus == 'sc1_7' || (this.isVisible('sc1_7') && !this.checkFields('sc1_7'));
        } else if (section == 'sc1_8') {
            return this.currentStatus == 'sc1_8' || (this.isVisible('sc1_8') && !this.checkFields('sc1_8'));
        } else if (section == 'sc1_8cpe') {
            return this.currentStatus == 'sc1_8cpe' || (this.isVisible('sc1_8cpe') && !this.checkFields('sc1_8cpe'));
        } else if (section == 'sc2_1') {
            // System.debug('currentStatus123'+this.currentStatus);
            // System.debug('isVisible123'+this.isVisible('sc2_1'));
           // System.debug('checkFields123'+this.checkFields('sc2_1'));
            return this.currentStatus == 'sc2_1' || (this.isVisible('sc2_1') && !this.checkFields('sc2_1'));
        } else if (section == 'sc3_1') {
            return this.currentStatus == 'sc3_1' || (this.isVisible('sc3_1') && !this.checkFields('sc3_1'));
        } else if (section == 'sc4_1') {
            return this.currentStatus == 'sc4_1' || (this.isVisible('sc4_1') && !this.checkFields('sc4_1'));
        } else if (section == 'scA') {
            return this.currentStatus == 'scA' || (this.isVisible('scA') && !this.checkFields('scA'));
        }
        return true;
    }

    public boolean isVisible(String section) {
        if (section == 'sc1_1') {
            return true;

        } else if (section == 'sc1_p') {
            return this.validStatus
                && this.isReseller
                && this.currentStatus != 'sc1_1';

        } else if (section == 'sc1_2') {
            return this.validStatus
                && this.currentStatus != 'sc1_1'
                && this.currentStatus != 'sc1_p';

        } else if (section == 'sc1_3') {
            return this.validStatus
                && this.currentStatus != 'sc1_1'
                && this.currentStatus != 'sc1_p'
                && this.currentStatus != 'sc1_2';

        } else if (section == 'sc1_4') {
            return this.validStatus
                && this.currentStatus != 'sc1_1'
                && this.currentStatus != 'sc1_p'
                && this.currentStatus != 'sc1_2'
                && this.currentStatus != 'sc1_3';

        } else if (section == 'sc1_7') {
            return this.validStatus
                && this.currentStatus != 'sc1_1'
                && this.currentStatus != 'sc1_p'
                && this.currentStatus != 'sc1_2'
                && this.currentStatus != 'sc1_3'
                && this.currentStatus != 'sc1_4';

        } else if (section == 'sc1_8') {
            return this.hasUCaaSLicenses
                && this.validStatus
                && this.currentStatus != 'sc1_1'
                && this.currentStatus != 'sc1_p'
                && this.currentStatus != 'sc1_2'
                && this.currentStatus != 'sc1_3'
                && this.currentStatus != 'sc1_4'
                && this.currentStatus != 'sc1_7';

        } else if (section == 'sc1_8cpe') {
            return this.hasUCaaSLicenses
                && this.validStatus
                && this.currentStatus != 'sc1_1'
                && this.currentStatus != 'sc1_p'
                && this.currentStatus != 'sc1_2'
                && this.currentStatus != 'sc1_3'
                && this.currentStatus != 'sc1_4'
                && this.currentStatus != 'sc1_7'
                && this.currentStatus != 'sc1_8';

        } else if (section == 'sc2_1') {
            return this.validStatus
                && this.currentStatus != 'sc1_1'
                && this.currentStatus != 'sc1_p'
                && this.currentStatus != 'sc1_2'
                && this.currentStatus != 'sc1_3'
                && this.currentStatus != 'sc1_4'
                && this.currentStatus != 'sc1_7'
                && this.currentStatus != 'sc1_8'
                && this.currentStatus != 'sc1_8cpe';

        } else if (section == 'sc3_1') {
            return this.validStatus
                && this.currentStatus != 'sc1_1'
                && this.currentStatus != 'sc1_p'
                && this.currentStatus != 'sc1_2'
                && this.currentStatus != 'sc1_3'
                && this.currentStatus != 'sc1_4'
                && this.currentStatus != 'sc1_7'
                && this.currentStatus != 'sc1_8'
                && this.currentStatus != 'sc1_8cpe'
                && this.currentStatus != 'sc2_1';

        } else if (section == 'sc4_1') {
            return this.validStatus
                && this.currentStatus != 'sc1_1'
                && this.currentStatus != 'sc1_p'
                && this.currentStatus != 'sc1_2'
                && this.currentStatus != 'sc1_3'
                && this.currentStatus != 'sc1_4'
                && this.currentStatus != 'sc1_7'
                && this.currentStatus != 'sc1_8'
                && this.currentStatus != 'sc1_8cpe'
                && this.currentStatus != 'sc2_1'
                && this.currentStatus != 'sc3_1';

        } else if (section == 'scA') {
            return this.validStatus
                && this.currentStatus != 'sc1_1'
                && this.currentStatus != 'sc1_p'
                && this.currentStatus != 'sc1_2'
                && this.currentStatus != 'sc1_3'
                && this.currentStatus != 'sc1_4'
                && this.currentStatus != 'sc1_7'
                && this.currentStatus != 'sc1_8'
                && this.currentStatus != 'sc1_8cpe'
                && this.currentStatus != 'sc2_1'
                && this.currentStatus != 'sc3_1'
                && this.currentStatus != 'sc4_1';
        }

        return true;
    }

    public static String exceptionText(Exception e) {
        return e.getTypeName() + ' (' +e.getLineNumber() + '): ' + e.getMessage();
    }

    public void exceptionHandler(Exception e) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, exceptionText(e)));
    }
}