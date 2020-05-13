/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Financial_RequestTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Financial_RequestTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Financial_Request__c());
    }
}