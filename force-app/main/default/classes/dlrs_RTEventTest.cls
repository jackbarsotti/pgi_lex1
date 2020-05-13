/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_RTEventTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_RTEventTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new RTEvent__c());
    }
}