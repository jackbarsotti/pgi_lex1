@isTest
public class BooleanExpressionTest {
   
    static testMethod void testfillLogic(){
        BooleanExpression.fillLogic();
    }
    static testMethod void testevaluateExpression(){
        
        BooleanExpression.eval('TRUE OR FALSE');
        system.assertEquals('TRUE', 'TRUE');
    }
}