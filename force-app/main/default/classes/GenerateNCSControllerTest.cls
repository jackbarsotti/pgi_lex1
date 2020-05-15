@isTest
public class GenerateNCSControllerTest {
	@isTest
    static void test(){
        Test.startTest();
       Opportunity opp = new Opportunity();
       opp.StageName = 'Closed Won';
       opp.CloseDate = Date.newInstance(2020, 05, 14);
       opp.Name = 'Test Opportunity';
        insert opp;
      
        GenerateNCSController.getCustomSetting();
        GenerateNCSController.getOpportunityData(opp.Id);
        GenerateNCSController.getOpportunityStageName(opp.Id);
         System.assertEquals(1, [SELECT Id, Name FROM Opportunity].size());
        System.assertEquals('Closed Won', opp.StageName);
        Test.stopTest();
    }
}