/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Call_LogTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Call_LogTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Call_Log__c());
    }
}