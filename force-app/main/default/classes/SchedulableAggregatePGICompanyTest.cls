@isTest
public class SchedulableAggregatePGICompanyTest {
    static testmethod void testBatch(){
        List<PGI_Entity__c> pgiEntityList = new List<PGI_Entity__c>();
        for(Integer i = 0; i < 10; i++) {
            pgiEntityList.add(New PGI_Entity__c(
                Name = 'Test Entity' + i,
                 Place_Holder__c = false
            ));
        }
        insert pgiEntityList;
        
        Test.startTest();
        ID BatchProcessdId = Database.executeBatch(new SchedulableAggreagatePGICompany());
        Test.stopTest();
        
        Integer noOfPGIEntityObj = [SELECT COUNT() FROM PGI_Entity__c WHERE Place_Holder__c = false];
        System.assertEquals(10, noOfPGIEntityObj); 
    }
    
    static testMethod void testSchedule() {
		String cronExpr = '0 0 0 15 3 ? 2022';
          List<PGI_Entity__c> pgiEntityList = new List<PGI_Entity__c>();
        for(Integer i = 0; i < 10; i++) {
            pgiEntityList.add(New PGI_Entity__c(
                Name = 'Test Entity' + i,
                 Place_Holder__c = false
            ));
        }
        insert pgiEntityList;
        
         Test.startTest();
        String jobId = System.schedule('myJobTestJobName', cronExpr, new SchedulableAggreagatePGICompany());
        Test.stopTest();
         
        Integer noOfPGIEntityObj = [SELECT COUNT() FROM PGI_Entity__c WHERE Place_Holder__c = false];
        System.assertEquals(10, noOfPGIEntityObj); 
	}
}