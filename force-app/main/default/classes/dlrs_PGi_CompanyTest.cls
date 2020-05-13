/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_PGi_CompanyTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_PGi_CompanyTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new PGi_Company__c());
    }
}