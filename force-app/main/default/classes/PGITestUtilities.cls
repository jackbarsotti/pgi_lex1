@isTest
public with sharing class PGITestUtilities {
    public static void disableSalesWings() {
        /*** Disable Saleswings Callouts START ***/ 
        List<saleswings__SalesWings_Trigger_Option__c> optLst = new List<saleswings__SalesWings_Trigger_Option__c>();
        
        optLst.add(
	        new saleswings__SalesWings_Trigger_Option__c(saleswings__Enabled__c = false, Name = 'PUBLISH_CONTACT_TO_SW'));
        optLst.add(
            new saleswings__SalesWings_Trigger_Option__c(saleswings__Enabled__c = false, Name = 'PUBLISH_LEAD_TO_SW'));
        
        insert optLst;
        /*** Disable Saleswings Callouts END ***/
    }
    public static Country__c createCountry(String countryName, Boolean doInsert) {
        Country__c obj = new Country__c();
        obj.Name = countryName;
        obj.Zoom_Info_Pro_Name__c = countryName;
        //obj.Country_Territory_Code__c = countryName;
        obj.Available_States_Provinces__c = 50;
        if(doInsert) {
            insert obj;
        }
        return obj;
    }
    public static Lead createLead(Boolean doInsert) {
        Lead obj = new Lead(LastName = 'Test Lead', Phone = '1231231235', Company = 'tasdfn');
        if(doInsert) {
            insert obj;
        }
        return obj;
    }
    public static Request_For_Change__c createRFC(Boolean doInsert) {
        Request_For_Change__c obj = new Request_For_Change__c(BackoutDuration__c = 1, MOP_details_will_be_attached__c = true);
        if(doInsert) {
            insert obj;
        }
        return obj;
    }
    public static Case createRFCCase(Request_For_Change__c rfc, Boolean doInsert) {
        Case c = new Case(Related_RFC__c = rfc.Id, Subject = 'Test Case');
        if(doInsert) {
            insert c;
        }
        return c;
    }
    public static PGi_Entity__c  createEntity(Boolean doInsert){
        PGi_Entity__c sobj = new PGi_Entity__c(); 

        if(doInsert) {
            insert sobj;
        }
        return sobj;
    }
    public static ConMan_Contract__c createConManContract(Account account, Opportunity opportunity, boolean doInsert){
        ConMan_Contract__c contract = new ConMan_Contract__c();
        contract.Account_Name__c = Account.Id;
        contract.Opportunity__c = Opportunity.Id;
        if(doInsert) {
            insert contract;
        }
        return contract;
    }
    public static PGi_Company__c createCompany(PGi_Entity__c entity, Boolean doInsert){
        PGi_Company__c sobj = new PGi_Company__c();
        sobj.PGi_Entity__c = entity.Id;
        if(doInsert) {
            insert sobj;
        }
        return sobj;
    }
    public static Contact createContact(Account acct, Boolean doInsert) {
        Contact obj = getContactDetails(acct.Id);
        if(doInsert) {
            insert obj;
        }
        return obj;
    }
    public static Account createAccount(Boolean doInsert) {
        Account account = new Account();
        account.Name = 'Test Account for the Ages';
        account.BillingCity = 'Oxnard';
        account.BillingCountryCode = 'US';
        account.BillingPostalCode = '93030'; 
        account.BillingStateCode = 'CA';
        account.BillingStreet = '121 North G Street';
        account.ShippingCity = 'Los Angeles';
        account.ShippingCountryCode = 'US';
        account.ShippingPostalCode = '90033';
        account.ShippingStateCode = 'CA';
        account.ShippingStreet = '1600 Pennsylvania Avenue';
        if (doInsert) {
            insert account;
        }
        return account;
    }
    public static DandBCompany createDandBCompany(String duns, String ultimateDuns, Boolean doInsert) {
        DandBCompany obj = new DandBCompany();
        obj.Name = 'Test Duns';
        obj.DunsNumber = duns;
        obj.GlobalUltimateDunsNumber = ultimateDuns;
        if(doInsert) {
            insert obj;
        }
        return obj;
    }

    public static Opportunity createOpportunity(Account acct, Boolean doInsert) {
        Opportunity obj = new Opportunity();
        obj.Name = 'test';
        obj.Type = 'Cloud Authentication';
        obj.CloseDate = Date.today();
        obj.StageName = 'Prospect';
        obj.Probability = 50;
        obj.AccountId = acct.Id;
        obj.CurrencyIsoCode = 'USD'; // Uncomment for multi-currency orgs
        //obj.pricebook2Id = [SELECT Id FROM PRicebook2 WHERE IsStandard = true].Id;
        obj.Pricebook2Id = Test.getStandardPricebookId();
        obj.Products_of_Interest__c = 'Foxden';

        if (doInsert) { insert obj; }
        return obj;
    }

    public static Opportunity createClosedWonValidOpportunity(Account acct, Boolean doInsert) {

        Opportunity testOpp = new Opportunity();
        testOpp.RecordTypeId = PGI_Utility.getRecordTypes('Opportunity').get(OpportunityTriggerHandler.PGI_RT);
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Awareness';
        testOpp.CloseDate = System.Today();
        testOpp.AccountId = acct.Id;
        testOpp.Products_of_Interest__c = 'Foxden';
        testOpp.Int_l_Audio_Rates_Discussed__c = 'Yes';
        testOpp.Service_Term__c = 'Month to Month';
        testOpp.Prospect_Status__c = 'Event Sourced';
        testOpp.Acct_Admin_Decison_Maker_Checked__c = 'Yes';
        testOpp.Account_Assigned_To__c = UserInfo.getUserId();
        testOpp.Rates_set_at_Account_Level__c = 'Yes';
        testOpp.Product__c = 'Web: GlobalMeet';
        testOpp.Opportunity_Deal_Type__c = 'New Business';
        testOpp.Channel__c = 'Cloud';

        if (doInsert) { insert testOpp; }
        return testOpp;
    }

    public static CONMAN_Contract__c createPGiContract(Opportunity opp, Boolean doInsert) {

        CONMAN_Contract__c testPGiContract = new CONMAN_Contract__c();
        testPGiContract.Opportunity__c = opp.Id;
        testPGiContract.CEA_Date_Active__c = System.today().addDays(-1);
        testPGiContract.Auto_Renewal_Interval_months__c = 1;
        testPGiContract.Contract_Document_Status__c = 'Active';
        testPGiContract.Contract_Start_Date__c = System.Today();
        testPGiContract.Contract_Renewal_Date__c = System.Today();
        testPGiContract.Has_Attachment__c = true;
        testPGiContract.Account_Name__c = opp.AccountId;
        
        if (doInsert) { insert testPGiContract; }
        return testPGiContract;
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    public static Pricebook2 standardPriceBook
    {
        get
        {
            if (standardPriceBook == null)
            {
                standardPriceBook = [SELECT Id, Name FROM Pricebook2 WHERE IsActive = true And IsStandard = true];
            }
            return standardPriceBook;
        }
        set;
    }
    public static Case createCase() {
        Case obj = new Case(
            subject = 'Testing123'
        );
        return obj;
    }

    //public static Attachment createAttachment(sobject sobj) {
    //    Attachment obj = new Attachment(
    //        name = 'testing',
    //        parentId = (Id)sobj.get('Id')
    //    );
    //    return obj;
    //}
    /**
     * Creates price book entries for the product.
     */
    public static PricebookEntry CreatePriceBookEntryForProduct(Product2 product)
    {
        //return CreatePriceBookEntryForProduct(product, null);
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbEntry = new PricebookEntry(UnitPrice=10.0, Pricebook2Id=pricebookId, product2Id=product.Id, isActive=true, UseStandardPrice=false);
        return pbEntry;
    }
    
    /**
     * Creates price book entries for the product and given pricebook.
     */
    public static PricebookEntry CreatePriceBookEntryForProduct(Product2 product, Pricebook2 pricebook)
    {
        PricebookEntry pbEntry = null;
        if (pricebook == null)
        {
            pricebook = standardPriceBook;
        }
        if (product != null)
        {
            pbEntry = new PricebookEntry(UnitPrice=10.0, Pricebook2Id=pricebook.Id, product2Id=product.Id, isActive=true, UseStandardPrice=false);
        }
        return pbEntry;
    }
    

    public static User getTestUser(){
        return getTestUser(getAdminProfile());
    }
    public static User getTestUser(Profile testProfile) {
        return new User(Alias='TSTUSER',Email='TEST.USER@pgi.com',
            EmailEncodingKey='UTF-8',FirstName='First_TEST',LastName='TEST_LAST_NAME', LanguageLocaleKey='en_US',
            LocaleSidKey='en_GB',ProfileId=testProfile.Id,timezonesidkey='Europe/London',Title='TEST TITLE',
            username='TEST.USERTEMP@pgi.com',EmployeeNumber='12345');
    }
    public static User getTestUser2(Profile testProfile) {
        return new User(Alias='TSTUSER2',Email='TEST2.USER@pgi.com',
            EmailEncodingKey='UTF-8',FirstName='Second_TEST2',LastName='TEST_LAST_NAME2', LanguageLocaleKey='en_US',
            LocaleSidKey='en_GB',ProfileId=testProfile.Id,timezonesidkey='Europe/London',Title='TEST TITLE',
            username='TEST2.USERTEMP@pgi.com');
    }
    
    public static Profile getAdminProfile() {
        return [Select Id, Name, UserLicense.LicenseDefinitionKey From Profile Where Name = 'System Administrator'];
    }
    public static User getUser(Profile testProfile) {
        return [Select ProfileId, Id From User  where ProfileId=:testProfile.Id and IsActive=true limit 1];
    }
    public static Group getPGINABilling (){
        return new Group(Name='PGI NA BILLING',type='Regular');
    }
    public static Group getPGINAProvisioing (){
        return new Group (Name='PGI NA PROVISIONING',type='Regular');
    }
    public static GroupMember getPGINABillingmembers (Group PGINABilling,User  TestUser){
        return new GroupMember (GroupId=PGINABilling.Id,UserOrGroupId=TestUser.Id);
    }
    public static GroupMember getPGINAProvisioingmembers (Group getPGINAProvisioing,User  TestUser){
        return new GroupMember (GroupId=getPGINAProvisioing.Id,UserOrGroupId=TestUser.Id);
    }
    
    
    public static Product2 getStdProduct(){     
        Product2 stdPro= new Product2();
        stdPro.IsActive = true;
        stdPro.Name='StandardProduct';
        stdPro.Edit_Sales_Price__c = true;
        return stdPro;
    }
    /*******************************************************************
    Purpose:    Setting parameter in the currentPageUrl       
    Parameters: key,Value
    Returns:    void
    *******************************************************************/
    public static void setTestParameter(String key, String value){
        Apexpages.currentPage().getParameters().put(key,value);
    }


    /*******************************************************************
    Purpose:    Get Account Details        
    Parameters: -
    Returns:    Account
    *******************************************************************/
    public static Account getAccountDetails(){
    
    RecordType accntRecordtype = [SELECT Id,Name FROM RecordType WHERE sObjectType = 'Account' AND Name LIKE '%PGi%' LIMIT 1];

        Account acc=new Account();
        acc.Name=generateRandomString(18);
        acc.BillingCountry = 'United States';
        acc.BillingState = 'Alabama';
        acc.BillingPostalCode = '35630';
        acc.BillingStreet = generateRandomString(18);
        acc.AnnualRevenue = 1000;
        acc.NumberOfEmployees = 5;
        acc.recordtypeid = accntrecordtype.id;
        return acc;
    }
    
    /*******************************************************************
    Purpose:    Get Contact Details        
    Parameters: - AccId
    Returns:    Contact
    *******************************************************************/
    private static RecordType conRecordtype {get {
        if(conRecordType == null) {
            conRecordType = [SELECT Id,Name FROM RecordType WHERE sObjectType = 'Contact' AND Name LIKE '%PGi%' LIMIT 1];
        }
        return conRecordtype;
    } set;}

    public static OpportunityTeamMember createOpportunityTeamMember(Opportunity opp, String userId, Boolean doInsert) {
        OpportunityTeamMember otm = new OpportunityTeamMember(
            OpportunityId = opp.Id,
            UserId = userId
            );
        if(doInsert) {
            insert otm;
        }
        return otm;
    }
    public static Contact getContactDetails(Id AccId){
        Contact cont=new Contact();
        cont.firstName=generateRandomString(12);
        cont.lastName =generateRandomString(12);
        cont.title = 'test guy';
        cont.email = generateRandomString(12) + '@test.com';
        cont.AccountId=AccId;
        cont.MailingCountry = 'United States';
        cont.recordtypeid = conRecordtype.id;
        return cont;
    }
    
    /*******************************************************************
    Purpose:    Get Opportunity Details        
    Parameters: -
    Returns:    Opportunity
    *******************************************************************/
    public static Opportunity getOpportunityDetails(){
    
        RecordType oppRecordtype = [SELECT Id,Name FROM RecordType WHERE sObjectType = 'Opportunity' AND Name LIKE '%PGi%' LIMIT 1];

        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpportunity';
        opp.StageName = 'Awareness';
        opp.CloseDate = date.today() + 10;
        opp.Opportunity_Source_Open__c = 'None';
        opp.recordtypeid = oppRecordtype.id;
        return opp;
    }
    
    /*******************************************************************
    Purpose:    Get Opportunity Line Item Details        
    Parameters: -
    Returns:    Opportunity Line Item
    *******************************************************************/
    public static OpportunityLineItem getOpportunityLineItemDetails(Id opportunityId, Id pricebookEntryId){
        OpportunityLineItem oli=new OpportunityLineItem();
        oli.UnitPrice = 100;
        oli.Quantity = 10;
        oli.New_Quantity__c = 10;
        oli.OpportunityId = opportunityId;
        oli.PricebookEntryId = pricebookEntryId;
        return oli;
    }
    
    /*******************************************************************
    Purpose:    Get Quote Details        
    Parameters: -
    Returns:    Quote
    *******************************************************************/
    public static Quote getQuoteDetails(Id accId,Id ConId, Id oppId){
        Quote quote=new quote();
        quote.Name='Test quote';
        //quote.Account__c=accId;
        quote.ContactId=conId;
        quote.OpportunityId=oppId;
        //quote.ContractType__c='Subcription License Order';
        quote.Status='Quote InProgress';
        
        
        return quote;
    }
    
    /*******************************************************************
    Purpose:    Get Quote Details        
    Parameters: - PGI Contract added
    Returns:    Quote
    *******************************************************************/
    public static Quote getQuoteDetails(Id accId,Id ConId, Id oppId,Id PGICOntract){
        Quote quote=new quote();
        quote.Name='Test quote';
        //quote.Account__c=accId;
        quote.ContactId=conId;
        quote.OpportunityId=oppId;
        quote.Status='Quote InProgress';
        
        return quote;
    }
    
    /*******************************************************************
    Purpose:   getStandardController      
    Parameters: -
    Returns:    ApexPages.StandardController
    *******************************************************************/
    
    public static ApexPages.StandardController getStandardController(SObject s){
       return (new ApexPages.StandardController(s));
    }
    
    /*******************************************************************
    Purpose:   getQuoteLineItem      
    Parameters: -
    Returns:    QuoteLineItem
    *******************************************************************/
    public static QuoteLineItem getServiceQuoteLineItem(Id product,Id service,Id quoteId,PricebookEntry pbe){
     QuoteLineItem quoteItem=new QuoteLineItem();
     quoteItem.QuoteId=quoteId; 
     quoteItem.Quantity=1;
     quoteItem.UnitPrice=56;
     quoteItem.PricebookEntryId=pbe.id;
    
     return quoteItem;
    }
     /*******************************************************************
    Purpose:   getQuoteLineItem      
    Parameters: -
    Returns:    QuoteLineItem
    *******************************************************************/
    public static QuoteLineItem getTestQuoteLineItem(Id product,Id service,Id quoteId,PricebookEntry pbe,Id masterQuoteId){ 
     QuoteLineItem quoteItem=new QuoteLineItem();
     quoteItem.QuoteId=quoteId; 
     quoteItem.Quantity=1;
     quoteItem.UnitPrice=56;
     quoteItem.PricebookEntryId=pbe.id;  
     return quoteItem;
    }


    public static PGi_Company__c getPGiCompany(Id AccId){
        PGi_Company__c com = new PGi_Company__c();
        com.RelatedAccount__c = AccId;
        return com;
    }
    
    /*******************************************************************
    Purpose:   getContractTerms     
    Parameters: -
    Returns:    Contract_Terms__c
    *******************************************************************/ 
    public static Contract_Terms__c getContractTerms(string name ,string terms){
            Contract_Terms__c testConterms= new Contract_Terms__c();
            testConterms.name=name;
            testConterms.Terms_and_Conditions__c=terms;
            testConterms.Unique_ID__c=generateRandomString(24);
            return testConterms;
    }

    /*******************************************************************
    Purpose:   getFinancialRequests     
    Parameters: -
    Returns:    Financial_Request__c
    *******************************************************************/ 
    public static Financial_Request__c getFinancialRequests(string caseId ,string userId){
            Financial_Request__c testFinalcialReq= new Financial_Request__c();
            testFinalcialReq.Historical_Case_Id__c = caseId;
            testFinalcialReq.Subject__c = 'Unit test subject';
            testFinalcialReq.Status__c = 'New';
            testFinalcialReq.Origin__c = 'Email';
            testFinalcialReq.Region__c = 'NA';
            testFinalcialReq.Request_Type__c = 'Email Request';
            testFinalcialReq.Description__c = 'Test_Descript';
            testFinalcialReq.Sales_Rep__c = userId;
            return testFinalcialReq;
    }
    

    
    /**
     * Creates test attachment object.
     */
    public static Attachment createAttachment(Id parentId)
    {
        Attachment attach=new Attachment();       
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=parentId;
        return attach;
    }

    /**
     * Creates test CaseComment object.
     */
    public static CaseComment createCaseComment(Id parentId)
    {
        CaseComment casecommentobj=new CaseComment();
        casecommentobj.parentId=parentId;
        casecommentobj.CommentBody = 'Unit test body';
        return casecommentobj;
    }
    
    /**
     * Creates note object.
     */
    public static Note createNote(Id parentId)
    {
        Note note = new Note();
        note.Title = 'Test Note';
        note.Body = 'Test Body Note';
        note.ParentId = parentId;
        return note;
    }
    
    /**
     * Creates Region wise approval level custom setting.
     */
    public static void createRegionWiseAppLevNameSetting()
    {
        RegionWiseApprovalLevels__c approvalLevels = new RegionWiseApprovalLevels__c();
        approvalLevels.Name = PGIAppConstants.REGION_WISE_APPROVAL_LEVEL_CUSTOM_SETTING_NAME;
        approvalLevels.NARegion__c = 'Rep;Mgr, RVP, VP;SVP;Pricing Team;EVP;CFO';
        approvalLevels.EMEARegion__c = 'Level 1;Level 2;Level 3;Level 4;Level 5; Level 6';
        approvalLevels.APACRegion__c = 'Level 1;Level 2;Level 3;Level 4;Level 5; Level 6';
        insert approvalLevels;
    }
    
    /**
     * Creates Region wise approval level custom setting.
     */
    public static void createQCStatusValuesCustomSetting()
    {
        Map<String, QCStatusValues__c> allValues = QCStatusValues__c.getAll();
        if (allValues == null || allValues.isEmpty())
        {
            List<QCStatusValues__c> statusValueList = new List<QCStatusValues__c>();
            QCStatusValues__c qcStatusValue = new QCStatusValues__c();
            qcStatusValue.Name = PGIQuoteStatusEnum.Accepted.name();
            qcStatusValue.StatusValue__c = 'Accepted';
            statusValueList.add(qcStatusValue);
            qcStatusValue = new QCStatusValues__c();
            qcStatusValue.Name = PGIQuoteStatusEnum.Approved.name();
            qcStatusValue.StatusValue__c = 'Approved';
            statusValueList.add(qcStatusValue);
            qcStatusValue = new QCStatusValues__c();
            qcStatusValue.Name = PGIQuoteStatusEnum.Closed.name();
            qcStatusValue.StatusValue__c = 'Closed';
            statusValueList.add(qcStatusValue);
            qcStatusValue = new QCStatusValues__c();
            qcStatusValue.Name = PGIQuoteStatusEnum.ContractDocumentGenerated.name();
            qcStatusValue.StatusValue__c = 'Contract Document Generated';
            statusValueList.add(qcStatusValue);
            qcStatusValue = new QCStatusValues__c();
            qcStatusValue.Name = PGIQuoteStatusEnum.ContractDocumentGeneratedDoc.name();
            qcStatusValue.StatusValue__c = 'Contract Document Generated - Doc';
            statusValueList.add(qcStatusValue);
            qcStatusValue = new QCStatusValues__c();
            qcStatusValue.Name = PGIQuoteStatusEnum.ContractSignedbyCustomer.name();
            qcStatusValue.StatusValue__c = 'Contract Signed by Customer';
            statusValueList.add(qcStatusValue);
            qcStatusValue = new QCStatusValues__c();
            qcStatusValue.Name = PGIQuoteStatusEnum.Denied.name();
            qcStatusValue.StatusValue__c = 'Denied';
            statusValueList.add(qcStatusValue);
            qcStatusValue = new QCStatusValues__c();
            qcStatusValue.Name = PGIQuoteStatusEnum.Draft.name();
            qcStatusValue.StatusValue__c = 'Draft';
            statusValueList.add(qcStatusValue);
            qcStatusValue = new QCStatusValues__c();
            qcStatusValue.Name = PGIQuoteStatusEnum.FullyProvisioned.name();
            qcStatusValue.StatusValue__c = 'Fully Provisioned';
            statusValueList.add(qcStatusValue);
            qcStatusValue = new QCStatusValues__c();
            qcStatusValue.Name = PGIQuoteStatusEnum.InReview.name();
            qcStatusValue.StatusValue__c = 'In Review';
            statusValueList.add(qcStatusValue);
            qcStatusValue = new QCStatusValues__c();
            qcStatusValue.Name = PGIQuoteStatusEnum.NeedsReview.name();
            qcStatusValue.StatusValue__c = 'Needs Review';
            statusValueList.add(qcStatusValue);
            qcStatusValue = new QCStatusValues__c();
            qcStatusValue.Name = PGIQuoteStatusEnum.Presented.name();
            qcStatusValue.StatusValue__c = 'Presented';
            statusValueList.add(qcStatusValue);
            qcStatusValue = new QCStatusValues__c();
            qcStatusValue.Name = PGIQuoteStatusEnum.PricingApproved.name();
            qcStatusValue.StatusValue__c = 'Pricing Approved- Internally Signed';
            statusValueList.add(qcStatusValue);
            qcStatusValue = new QCStatusValues__c();
            qcStatusValue.Name = PGIQuoteStatusEnum.QuoteInProgress.name();
            qcStatusValue.StatusValue__c = 'Quote- In Progress';
            statusValueList.add(qcStatusValue);
            qcStatusValue = new QCStatusValues__c();
            qcStatusValue.Name = PGIQuoteStatusEnum.ReadyforClosedWon.name();
            qcStatusValue.StatusValue__c = 'Ready for Closed Won';
            statusValueList.add(qcStatusValue);
            qcStatusValue = new QCStatusValues__c();
            qcStatusValue.Name = PGIQuoteStatusEnum.ReadyforContract.name();
            qcStatusValue.StatusValue__c = 'Ready for Contract';
            statusValueList.add(qcStatusValue);
            qcStatusValue = new QCStatusValues__c();
            qcStatusValue.Name = PGIQuoteStatusEnum.ReadyForProvisioning.name();
            qcStatusValue.StatusValue__c = 'Ready For Provisioning';
            statusValueList.add(qcStatusValue);
            qcStatusValue = new QCStatusValues__c();
            qcStatusValue.Name = PGIQuoteStatusEnum.Rejected.name();
            qcStatusValue.StatusValue__c = 'Rejected';
            statusValueList.add(qcStatusValue);
            qcStatusValue = new QCStatusValues__c();
            qcStatusValue.Name = PGIQuoteStatusEnum.SubmittedContractCustomerApproval.name();
            qcStatusValue.StatusValue__c = 'Submitted Contract- Customer Approval';
            statusValueList.add(qcStatusValue);
            qcStatusValue = new QCStatusValues__c();
            qcStatusValue.Name = PGIQuoteStatusEnum.SubmittedContractInternalApproval.name();
            qcStatusValue.StatusValue__c = 'Submitted Contract-Internal Approval';
            statusValueList.add(qcStatusValue);
            qcStatusValue = new QCStatusValues__c();
            qcStatusValue.Name = PGIQuoteStatusEnum.SubmittedPriceApproval.name();
            qcStatusValue.StatusValue__c = 'Submitted - Price Approval';
            statusValueList.add(qcStatusValue);
            insert statusValueList;
        }
    }
    
    /**
     * Creates Company Revenue object.
     */
     /*
    public static Company_Revenue__c createCompanyRevenue(Id accountId, Id companyId)
    {
        Company_Revenue__c companyRevenue = new Company_Revenue__c();
        companyRevenue.Company_Name__c = companyId;
        companyRevenue.Revenue__c = 10;
        return companyRevenue;
    }
    */
    /*******************************************************************
    Purpose:    Get Implementation Services Details        
    Parameters: -
    Returns:    Implementation_Services__c
    *******************************************************************/
    public static Implementation_Services__c getImplementationServices(Id opportunityId){
        Implementation_Services__c impServices= new Implementation_Services__c();
        impServices.Related_Opportunity__c = opportunityId;
        return impServices;
    }
    
    /*******************************************************************
    Purpose:    Get Lead Details        
    Parameters: -
    Returns:    Lead
    *******************************************************************/
    public static Lead getLeadDetails(){
    
        RecordType ldRecordtype = [SELECT Id,Name FROM RecordType WHERE sObjectType = 'Lead' AND Name LIKE '%PGi%' LIMIT 1];
        
        Lead lead = new Lead();
        lead.FirstName = generateRandomString(18);
        lead.LastName = generateRandomString(18);
        lead.Email = generateRandomString(12) + '@lead.com';
        lead.company = generateRandomString(18);  
        lead.country='United States';
        lead.state='Alabama';
        lead.city=generateRandomString(12);
        lead.street='street';
        lead.phone='2359823412';
        lead.postalcode='123456';
        lead.recordtypeid = ldRecordType.Id; 
        return lead;
    }
    public static User readyTalkUser {get {
        if(readyTalkUser == null) {
            List<User> userList = [SELECT Id FROM USer WHERE UserName =: 'testreadytalkuser123@readytalk.com'];
            if(!userList.isEmpty()){
                readyTalkUser = userList[0];
            } else {
                Id readyTalkSupportProfileId = [SELECT Id FROM Profile WHERE Name = 'ReadyTalk Support'].Id;
                readyTalkUser = new User();
                readyTalkUser.Username = 'testreadytalkuser123@readytalk.com';
                readyTalkUser.LastName = 'test';
                readyTalkUser.Email = 'testuseremail@readytalk.com';
                readyTalkUser.Alias = 'testuser';
                readyTalkUser.CommunityNickname = 'test';
                readyTalkUser.TimeZoneSidKey = 'America/Los_Angeles';
                readyTalkUser.LocaleSidKey = 'en_US';
                readyTalkUser.EmailEncodingKey = 'UTF-8';
                readyTalkUser.LanguageLocaleKey = 'en_US';
                readyTalkUser.EmployeeNumber='12345';
                readyTalkUser.ProfileId = readyTalkSupportProfileId;
                insert readyTalkUser;
            }
        } 
        return readyTalkUser;
        } set;}
            

    public static Campaign getCampaignDetails(){
        Campaign campaign = new Campaign();
        campaign.Name = 'testCampaign';
        return campaign;
    }
    
    public static CampaignMember getCampaignMemberDetails(Id campaignId, Id leadId){
        CampaignMember campaignMember = new CampaignMember();
        campaignMember.CampaignId = campaignId;
        campaignMember.LeadId = leadId;
        return campaignMember;
    }
    
    /*******************************************************************
    Purpose:    Get Account Team Member Details        
    Parameters: -
    Returns:    AccountTeamMember
    *******************************************************************/
    public static AccountTeamMember getAccountTeamMember(Id accountId, Id userId){
        AccountTeamMember accTeamMember = new AccountTeamMember();
        accTeamMember.AccountId = accountId;
        accTeamMember.UserId = userId;
        return accTeamMember;
    }
    
    /*******************************************************************
    Purpose:    Get Task Details        
    Parameters: -
    Returns:    Task
    *******************************************************************/
    public static Task getTaskDetails(Id whatId){
        Task tsk = new Task();
        tsk.Subject = 'Call';
        tsk.ActivityDate = Date.today();
        tsk.Status = 'In Progress';
        tsk.Priority = 'High'; 
        tsk.WhatId = whatId;
        tsk.recordtypeid = '01213000001WHUV';
        return tsk;
    }
    
    /*******************************************************************
    Purpose:    Get Event Details        
    Parameters: -
    Returns:    Event
    *******************************************************************/
    public static Event getEventDetails(Id whatId){
        Event evnt = new Event();
        evnt.Subject = 'Call';
        evnt.ActivityDate = Date.today();
        evnt.StartDateTime = Date.today();
        evnt.EndDateTime = Date.today().AddDays(5); 
        evnt.whatid = whatId;
        evnt.recordtypeid = '01230000001F8zIAAS';
        return evnt;
    }
    
    /*******************************************************************
    Purpose:    Get ConMan_Contract__c Details        
    Parameters: -
    Returns:    ConMan_Contract__c
    *******************************************************************/
    public static ConMan_Contract__c getConManContractDetails(Id accountId, Id oppId){
        ConMan_Contract__c contract = new ConMan_Contract__c();
        contract.Account_Name__c = accountId;
        contract.Opportunity__c = oppId;
        contract.Company_s_Name__c='TestCompany';
        contract.Language__c = 'en_US';
        return contract;
    }
    
  
   
}