global class BillingPlatform {
    /* Strings for use as status messages */
    public static String SUCCESS = 'success';
    public static String ERROR = 'error';

    /* Base class to use for REST responses */
    abstract global class SalesforceResponse {
        global String status;
        global String errorMessage;
    }

    /* Exception to throw when expectations are invalid */
    public class InvalidException extends Exception {}
    /* Exception to throw when the restrictions on lookups have been hit */
    public class CompanyLookupException extends Exception {}

    /* Using an Account ID, lookup Companies and return their Enterprise ID */
    public static String getEnterpriseIdByAccount(Id accountId) {
        if (accountId == null)
            throw new InvalidException('Account ID is null');
        if (Schema.Account.SobjectType != accountId.getSobjectType())
            throw new InvalidException('ID is not of an Account');

        String ultimateParentName = null;
        List<Account> accounts = [SELECT Id, Ultimate_Parent__c FROM Account WHERE Id = :accountId LIMIT 1];
        if (accounts == null || accounts.size() != 1)
            throw new InvalidException('Account not found');
        ultimateParentName = accounts.get(0).Ultimate_Parent__c;

        String enterpriseId = null;

        List<PGi_Company__c> companies = [SELECT Id, Enterprise_ID__c FROM PGi_Company__c WHERE RelatedAccount__c = :accountId];

        if (companies == null || companies.size() <= 0) {
            throw new CompanyLookupException('Account without Company');
        } else if (companies.size() == 1) {
            enterpriseId = companies.get(0).Enterprise_ID__c;
        } else { // " > 1
            String possibleEnterpriseId = null;

            for (PGi_Company__c company : companies) {
                if (possibleEnterpriseId == null) {
                    possibleEnterpriseId = company.Enterprise_ID__c;
                    continue;
                }

                if (possibleEnterpriseId != company.Enterprise_ID__c)
                    throw new CompanyLookupException('Account\'s Companies have multiple Enterprises');
            }

            enterpriseId = possibleEnterpriseId;
        }

        if (enterpriseId == null || String.isEmpty(enterpriseId))
            throw new CompanyLookupException('Account\'s Companies without Enterprise');

        List<PGi_Company__c> companiesOnOtherAccounts = [SELECT Id FROM PGi_Company__c WHERE RelatedAccount__r.Ultimate_Parent__c != :ultimateParentName AND Enterprise_ID__c = :enterpriseId LIMIT 1];
        if (companiesOnOtherAccounts != null && companiesOnOtherAccounts.size() > 0)
            throw new CompanyLookupException('Enterprise shared across Account hierarchies');

        return enterpriseId;
    }
    
    /* POJO for Contract data from Billing Platform */
    global class BPContract {
        global String Id;
        global String CurrencyCode;
        global String StartDate;
        global String EndDate;
    }

    /* Using an Enterprise ID, lookup Contracts from the Billing Platform System */
    public static List<BPContract> getContractsByEnterpriseId(String enterpriseId) {
        if (enterpriseId == null)
            throw new InvalidException('Enterprise ID is null');
        if (String.isEmpty(enterpriseId))
            throw new InvalidException('Enterprise ID is empty');
        
        HttpRequest request = ESB_Interface.httpESB('contractsbyenterprise/' + enterpriseId);
        request.setMethod('GET');
        
        HttpResponse response = new Http().send(request);
        if (response.getStatusCode() != 200)
            throw new ESB_Interface.EndpointException(response.getStatusCode() + ': ' + response.getBody());
        
        List<Object> results;
        try {
        	results = (List<Object>) JSON.deserializeUntyped(response.getBody());
        } catch (Exception e) {
            throw new ESB_Interface.ParsingException('Unable to parse total response:\n' + response.getBody() + '\n' + ESB_Interface.formatException(e));
        }
        
        List<BPContract> contracts = new List<BPContract>();
        for (Object result : results) {
            try {
                Map<String, Object> contractInfo = (Map<String, Object>)result;
                BPContract contract = new BPContract();
                
                if (!contractInfo.containsKey('ContractId'))
                    throw new ESB_Interface.ParsingException('Response object missing key: ContractId \n' + response.getBody());
                contract.Id = (String)contractInfo.get('ContractId');
                
                if (!contractInfo.containsKey('CurrencyId'))
                    throw new ESB_Interface.ParsingException('Response object missing key: CurrencyId \n' + response.getBody());
                contract.CurrencyCode = (String)contractInfo.get('CurrencyId');
                
                contracts.add(contract);
            } catch (Exception e) {
                throw new ESB_Interface.ParsingException('Unable to parse object in response:\n' + response.getBody() + '\n' + ESB_Interface.formatException(e));
            }
        }
        return contracts;
    }
}