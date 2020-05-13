@isTest
private class ScheduleBatchScorecardGenerator_Test {
	//This test method is used to coverage the code of ScheduleBatchScorecardGenerator class
    static testMethod void testMultiselectController() {
    	ScorecardSurveyRecipients__c em = new ScorecardSurveyRecipients__c();
    	em.Email__c ='asdfasdf@gmail.com';
    	em.Name='asdfasdf';
    	insert em;
    	
    	PGi_Vendor_List__c vl = new PGi_Vendor_List__c();
		vl.Show_on_Surveys__c = true;
		vl.Name ='ABC';
		insert vl; 

		Vendor_Scorecard__c testVS = new Vendor_Scorecard__c();
		
		Vendor_Scorecard__c vs = new Vendor_Scorecard__c();
		vs.Month_Year__c = 'sep-2017';
		vs.Related_PGi_Vendor__c = vl.id;
		insert vs;
		
		vl = new PGi_Vendor_List__c();
		vl.Show_on_Surveys__c = true;
		vl.Name ='ABCD';
		insert vl; 
         
        Test.startTest();
        ScheduleBatchScorecardGenerator sh1 = new ScheduleBatchScorecardGenerator();
		String sch = '0 0 23 * * ?'; 
		system.schedule('Test Territory Check', sch, sh1); 
		
		Database.executeBatch(new BatchScorecardGenerator());
		
		
		Database.executeBatch(new BatchScorecardGenerator(date.today()));

		// test with matching url-end params to the vendor scorecard related record
		Database.executeBatch(new BatchScorecardGenerator('sep-2017'));
		
        Test.stopTest();

    }    
}