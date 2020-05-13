@isTest
global class BillingPlatform_Test {
    
    global class HttpMock implements HttpCalloutMock {
        Integer code = 200;
        String expected = '';
        
        global void setExpected(Integer code, String expected) {
            this.code = code;
            this.expected = expected;
        }
        
        global HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(this.code);
            response.setBody(this.expected);
            return response; 
        }
    }

    static testmethod void getEnterpriseIdByAccount_badIDs() {
        try {
            BillingPlatform.getEnterpriseIdByAccount(null);
            System.assert(false, 'No exception for null ID');
        } catch (BillingPlatform.InvalidException e) {
            System.assert(true, 'Exception for null ID');
        }

        Opportunity notAccount = PGITestUtilities.getOpportunityDetails();
        INSERT notAccount;

        try {
            BillingPlatform.getEnterpriseIdByAccount(notAccount.Id);
            System.assert(false, 'No exception for non-Account ID');
        } catch (BillingPlatform.InvalidException e) {
            System.assert(true, 'Exception for non-Account ID');
        }

        Account a = PGITestUtilities.getAccountDetails();
        INSERT a;

        Id deletedAccountId = a.Id;
        DELETE a;

        try {
            BillingPlatform.getEnterpriseIdByAccount(deletedAccountId);
            System.assert(false, 'No exception for deleted Account');
        } catch (BillingPlatform.InvalidException e) {
            System.assert(true, 'Exception for deleted Account');
        }
    }

    static testmethod void getEnterpriseIdByAccount_noCompanies() {
        Account a = PGITestUtilities.getAccountDetails();
        INSERT a;

        try {
            BillingPlatform.getEnterpriseIdByAccount(a.Id);
            System.assert(false, 'No exception for Account without Companies');
        } catch (BillingPlatform.CompanyLookupException e) {
            System.assert(true, 'Exception for Account without Companies');
        }
    }

    static testmethod void getEnterpriseIdByAccount_singleAccountSingleCompanyWithoutEnterprise() {
        Account a = PGITestUtilities.getAccountDetails();
        INSERT a;

        PGi_Company__c c = PGITestUtilities.getPGiCompany(a.Id);
        INSERT c;

        try {
            BillingPlatform.getEnterpriseIdByAccount(a.Id);
            System.assert(false, 'No exception for Account with Company without Enterprise ID');
        } catch (BillingPlatform.CompanyLookupException e) {
            System.assert(true, 'Exception for Account with Company without Enterprise ID');
        }
    }

    static testmethod void getEnterpriseIdByAccount_singleAccountSingleCompanyWithEnterprise() {
        Account a = PGITestUtilities.getAccountDetails();
        INSERT a;

        PGi_Company__c c = PGITestUtilities.getPGiCompany(a.Id);
        c.Enterprise_ID__c = 'test';
        INSERT c;

        System.assertEquals(c.Enterprise_ID__c, BillingPlatform.getEnterpriseIdByAccount(a.Id),
                           'Company\'s Enterprise ID is returned');
    }

    static testmethod void getEnterpriseIdByAccount_singleAccountMultiCompanyWithoutEnterprise() {
        Account a = PGITestUtilities.getAccountDetails();
        INSERT a;

        PGi_Company__c c1 = PGITestUtilities.getPGiCompany(a.Id);
        INSERT c1;
        PGi_Company__c c2 = PGITestUtilities.getPGiCompany(a.Id);
        INSERT c2;

        try {
            BillingPlatform.getEnterpriseIdByAccount(a.Id);
            System.assert(false, 'No exception for Account with multiple Companies without Enterprises');
        } catch (BillingPlatform.CompanyLookupException e) {
            System.assert(true, 'Exception for Account with multiple Companies without Enterprises');
        }
    }

    static testmethod void getEnterpriseIdByAccount_singleAccountMultiCompanySameEnterprise() {
        Account a = PGITestUtilities.getAccountDetails();
        INSERT a;

        PGi_Company__c c1 = PGITestUtilities.getPGiCompany(a.Id);
        c1.Enterprise_ID__c = 'test';
        INSERT c1;
        PGi_Company__c c2 = PGITestUtilities.getPGiCompany(a.Id);
        c2.Enterprise_ID__c = 'test';
        INSERT c2;

        System.assertEquals(c1.Enterprise_ID__c, BillingPlatform.getEnterpriseIdByAccount(a.Id),
                           'Company\'s Enterprise ID is returned');
    }

    static testmethod void getEnterpriseIdByAccount_singleAccountMultiCompanyDifferentEnterprise() {
        Account a = PGITestUtilities.getAccountDetails();
        a.Name = 'Parent Company';
        INSERT a;

        PGi_Company__c c1 = PGITestUtilities.getPGiCompany(a.Id);
        c1.Enterprise_ID__c = 'test_1';
        INSERT c1;
        PGi_Company__c c2 = PGITestUtilities.getPGiCompany(a.Id);
        c2.Enterprise_ID__c = 'test_2';
        INSERT c2;

        try {
            BillingPlatform.getEnterpriseIdByAccount(a.Id);
            System.assert(false, 'No exception for Account with multiple Companies with different Enterprises');
        } catch (BillingPlatform.CompanyLookupException e) {
            System.assert(true, 'Exception for Account with multiple Companies with different Enterprises');
        }
    }

    static testmethod void getEnterpriseIdByAccount_multiAccountSingleCompanySameEnterpriseInside() {
        Account a1 = PGITestUtilities.getAccountDetails();
        a1.Name = 'Parent Company';
        INSERT a1;

        PGi_Company__c c1 = PGITestUtilities.getPGiCompany(a1.Id);
        c1.Enterprise_ID__c = 'test';
        INSERT c1;

        Account a2 = PGITestUtilities.getAccountDetails();
        a2.ParentId = a1.Id;
        a2.Name = 'Child Company';
        INSERT a2;

        PGi_Company__c c2 = PGITestUtilities.getPGiCompany(a2.Id);
        c2.Enterprise_ID__c = 'test';
        INSERT c2;

        System.assertEquals(c1.Enterprise_ID__c, BillingPlatform.getEnterpriseIdByAccount(a1.Id),
                           'Company\'s Enterprise ID is returned');
    }

    static testmethod void getEnterpriseIdByAccount_multiAccountSingleCompanySameEnterpriseOutside() {
        Account a1 = PGITestUtilities.getAccountDetails();
        a1.Name = 'Parent Company';
        INSERT a1;

        PGi_Company__c c1 = PGITestUtilities.getPGiCompany(a1.Id);
        c1.Enterprise_ID__c = 'test';
        INSERT c1;

        Account a2 = PGITestUtilities.getAccountDetails();
        a2.Name = 'Another Company';
        INSERT a2;

        PGi_Company__c c2 = PGITestUtilities.getPGiCompany(a2.Id);
        c2.Enterprise_ID__c = 'test';
        INSERT c2;

        try {
            BillingPlatform.getEnterpriseIdByAccount(a1.Id);
            System.assert(false, 'No exception for Account with Companiy with Enterprise and Outside Account');
        } catch (BillingPlatform.CompanyLookupException e) {
            System.assert(true, 'Exception for Account with Companiy with Enterprise and Outside Account');
        }
    }

    static testmethod void getEnterpriseIdByAccount_multiAccountMultiCompanySameEnterpriseInside() {
        Account a1 = PGITestUtilities.getAccountDetails();
        a1.Name = 'Parent Company';
        INSERT a1;

        PGi_Company__c c1 = PGITestUtilities.getPGiCompany(a1.Id);
        c1.Enterprise_ID__c = 'test';
        INSERT c1;
        PGi_Company__c c2 = PGITestUtilities.getPGiCompany(a1.Id);
        c2.Enterprise_ID__c = 'test';
        INSERT c2;

        Account a2 = PGITestUtilities.getAccountDetails();
        a2.ParentId = a1.Id;
        a2.Name = 'Child Company';
        INSERT a2;

        PGi_Company__c c3 = PGITestUtilities.getPGiCompany(a2.Id);
        c3.Enterprise_ID__c = 'test';
        INSERT c3;

        System.assertEquals(c1.Enterprise_ID__c, BillingPlatform.getEnterpriseIdByAccount(a1.Id),
                           'Company\'s Enterprise ID is returned');
    }

    static testmethod void getEnterpriseIdByAccount_multiAccountMultiCompanySameEnterpriseOutside() {
        Account a1 = PGITestUtilities.getAccountDetails();
        a1.Name = 'Parent Company';
        INSERT a1;

        PGi_Company__c c1 = PGITestUtilities.getPGiCompany(a1.Id);
        c1.Enterprise_ID__c = 'test';
        INSERT c1;
        PGi_Company__c c2 = PGITestUtilities.getPGiCompany(a1.Id);
        c2.Enterprise_ID__c = 'test';
        INSERT c2;

        Account a2 = PGITestUtilities.getAccountDetails();
        a2.Name = 'Another Company';
        INSERT a2;

        PGi_Company__c c3 = PGITestUtilities.getPGiCompany(a2.Id);
        c3.Enterprise_ID__c = 'test';
        INSERT c3;

        try {
            BillingPlatform.getEnterpriseIdByAccount(a1.Id);
            System.assert(false, 'No exception for Account with multiple Companies with Enterprises and Outside Account');
        } catch (BillingPlatform.CompanyLookupException e) {
            System.assert(true, 'Exception for Account with multiple Companies with Enterprises and Outside Account');
        }
    }

    static testmethod void getContractsByEnterpriseId_badIDs() {
        try {
            BillingPlatform.getContractsByEnterpriseId(null);
            System.assert(false, 'No exception for null ID');
        } catch (BillingPlatform.InvalidException e) {
            System.assert(true, 'Exception for null ID');
        }
        
        try {
            BillingPlatform.getContractsByEnterpriseId('');
            System.assert(false, 'No exception for empty ID');
        } catch (BillingPlatform.InvalidException e) {
            System.assert(true, 'Exception for empty ID');
        }
    }

    static testmethod void getContractsByEnterpriseId_invalidResponses() {
        HttpMock mock = new HttpMock();
        Test.setMock(HttpCalloutMock.class, mock);

        mock.setExpected(404, 'Not found');
        try {
            BillingPlatform.getContractsByEnterpriseId('enterpriseId');
            System.assert(false, 'No exception for 404 Not Found');
        } catch (ESB_Interface.EndpointException e) {
            System.assert(true, 'Exception for 404 Not Found');
        }

        mock.setExpected(500, 'Server Error');
        try {
            BillingPlatform.getContractsByEnterpriseId('enterpriseId');
            System.assert(false, 'No exception for 500 Server Error');
        } catch (ESB_Interface.EndpointException e) {
            System.assert(true, 'Exception for 500 Server Error');
        }

        mock.setExpected(200, '{"ContractId: "1"}');
        try {
            BillingPlatform.getContractsByEnterpriseId('enterpriseId');
            System.assert(false, 'No exception for Single-Object response');
        } catch (ESB_Interface.ParsingException e) {
            System.assert(true, 'Exception for Single-Object response');
        }

        mock.setExpected(200, '[{"Missing": "All"}]');
        try {
            BillingPlatform.getContractsByEnterpriseId('enterpriseId');
            System.assert(false, 'No exception for missing ContractId key');
        } catch (ESB_Interface.ParsingException e) {
            System.assert(true, 'Exception for missing ContractId key');
        }

        mock.setExpected(200, '[{"ContractId": "3385"}]');
        try {
            BillingPlatform.getContractsByEnterpriseId('enterpriseId');
            System.assert(false, 'No exception for missing CurrencyId key');
        } catch (ESB_Interface.ParsingException e) {
            System.assert(true, 'Exception for missing CurrencyId key');
        }
    }

    static testmethod void getContractsByEnterpriseId_noContract() {
        HttpMock mock = new HttpMock();
        Test.setMock(HttpCalloutMock.class, mock);

        mock.setExpected(200, '[]');
        List<BillingPlatform.BPContract> contracts = BillingPlatform.getContractsByEnterpriseId('enterpriseId');
        System.assertEquals(0, contracts.size(), '0 Contract parsed correctly');
    }

    static testmethod void getContractsByEnterpriseId_singleContract() {
        HttpMock mock = new HttpMock();
        Test.setMock(HttpCalloutMock.class, mock);

        mock.setExpected(200, '[{"ContractId": "3385", "CurrencyId": "EUR"}]');
        List<BillingPlatform.BPContract> contracts = BillingPlatform.getContractsByEnterpriseId('enterpriseId');
        System.assertEquals(1, contracts.size(), '1 Contract parsed correctly');
        System.assertEquals('3385', contracts.get(0).Id, 'Contract 1 Id correct');
        System.assertEquals('EUR', contracts.get(0).CurrencyCode, 'Contract 1 CurrencyCode correct');
    }

    static testmethod void getContractsByEnterpriseId_multiContract() {
        HttpMock mock = new HttpMock();
        Test.setMock(HttpCalloutMock.class, mock);

        mock.setExpected(200, '[{"ContractId": "3385", "CurrencyId": "EUR"},{"ContractId": "3386", "CurrencyId": "USD"}]');
        List<BillingPlatform.BPContract> contracts = BillingPlatform.getContractsByEnterpriseId('enterpriseId');
        System.assertEquals(2, contracts.size(), '1 Contract parsed correctly');
        System.assertEquals('3385', contracts.get(0).Id, 'Contract 1 Id correct');
        System.assertEquals('EUR', contracts.get(0).CurrencyCode, 'Contract 1 CurrencyCode correct');
        System.assertEquals('3386', contracts.get(1).Id, 'Contract 2 Id correct');
        System.assertEquals('USD', contracts.get(1).CurrencyCode, 'Contract 2 CurrencyCode correct');
    }
}