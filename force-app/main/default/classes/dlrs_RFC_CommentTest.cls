/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_RFC_CommentTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_RFC_CommentTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new RFC_Comment__c());
    }
}