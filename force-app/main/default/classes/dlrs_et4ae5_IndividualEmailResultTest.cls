/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_et4ae5_IndividualEmailResultTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_et4ae5_IndividualEmailResultTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new et4ae5__IndividualEmailResult__c());
    }
}