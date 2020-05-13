/**
* Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
**/
@IsTest
private class dlrs_AccountTest	
{
    public class MyException extends Exception {}
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_AccountTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Account());
    }
    @IsTest
    Private static void catchTestTrigger(){
         
        Test.startTest();
        try
        {
            Account a = new Account(Name = 'test');
            Update a;
            throw new MyException('Failed to update the account record due to the following error:');
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage().contains('Failed to update the account record due to the following error')) ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        }
       }
}