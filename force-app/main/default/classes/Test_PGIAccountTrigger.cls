/**
 * This is the test class for the PGIAccountTrigger class and PGIAccountTriggerHelper class. 
 * It contains test methods to test the functionality of company count value on account object.
 *
 * @author Amit M.
 * @version 1.0
 */
@isTest
private class Test_PGIAccountTrigger {

    /* Stores list of company objects. */
    private static List<PGi_Company__c> companyList;
    
    /* Stores account object. */
    private static Account account;
    

    private static void setUp(Boolean createCompanyRevenue)
    {
        account = PGITestUtilities.getAccountDetails();
        //account.Count_of_Companies__c = 0;
        insert account;
        system.assertNotEquals(account.Id, null);
        companyList = new List<PGi_Company__c>();
        /*
        for (Integer i = 0; i < 10; i++)
        {
            Company__c company = PGITestUtilities.getCompany(account.Id);
            company.TESLA_InactiveDate__c = null;
            companyList.add(company);
        }
        insert companyList;

        if (createCompanyRevenue)
        {
            List<Company_Revenue__c> companyRevenueList = new List<Company_Revenue__C>();
            for (Company__c company : companyList)
            {
                companyRevenueList.add(PGITestUtilities.createCompanyRevenue(account.Id, company.Id));
                companyRevenueList.add(PGITestUtilities.createCompanyRevenue(account.Id, company.Id));
            }
            insert companyRevenueList;
        }*/
    }
}