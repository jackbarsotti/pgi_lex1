@isTest
private class ScorecardController_Test {
	//This test method is used to coverage the code of ScheduleBatchScorecardGenerator class
    static testMethod void testScorecardController0() {
    	PGi_Vendor_List__c vl = new PGi_Vendor_List__c();
		vl.Show_on_Surveys__c = true;
		vl.Name ='ABC';
		insert vl;
			
		Vendor_Scorecard__c vs = new Vendor_Scorecard__c();
		vs.Month_Year__c = 'sep-2017';
		vs.Related_PGi_Vendor__c = vl.id;
		insert vs;	
		
		vl = new PGi_Vendor_List__c();
		vl.Show_on_Surveys__c = true;
		vl.Name ='ABCD';
		insert vl;
					
		vs = new Vendor_Scorecard__c();
		vs.Month_Year__c = 'sep-2017';
		vs.Related_PGi_Vendor__c = vl.id;
		insert vs;				
														
		Vendor_Survey__c vsy = new Vendor_Survey__c();
		vsy.Vendor_Scorecard__c = vs.Id;
		vsy.Communicates_network_impacting_issues__c = 0;
		vsy.Familiar_with_PGi_business_and_trouble__c = 0;
		vsy.Knowledgeable_of_outstanding_problems__c = 0;
		vsy.Provides_accurate_timely_ticket_updates__c = 0;
		vsy.Responsive_when_PGI_escalations_occur__c = 0;
		insert vsy;
		
		vl = new PGi_Vendor_List__c();
		vl.Show_on_Surveys__c = true;
		vl.Name ='ABCE';
		insert vl;
 		vs = new Vendor_Scorecard__c();
		vs.Month_Year__c = 'sep-2017';
		vs.Related_PGi_Vendor__c = vl.id;
		insert vs;	
		     
 		PageReference pageRef = Page.scorecard;
		pageRef.getParameters().put('data', vs.Month_Year__c);
		
		Test.setCurrentPageReference(pageRef);
        ScorecardController sc = new ScorecardController(); 
        sc.nextVendor();
        sc.previousVendor();
        
        pageRef = Page.scorecard;
		pageRef.getParameters().put('data', '');
		
		Test.setCurrentPageReference(pageRef);		         
        sc = new ScorecardController(); 
    }  
    //This test method is used to coverage the code of ScheduleBatchScorecardGenerator class
    static testMethod void testScorecardController1() {
		PGi_Vendor_List__c vl = new PGi_Vendor_List__c();
		vl.Show_on_Surveys__c = true;
		vl.Name ='ABC';
		insert vl;
			
		Vendor_Scorecard__c vs = new Vendor_Scorecard__c();
		vs.Month_Year__c = 'sep-2017';
		vs.Related_PGi_Vendor__c = vl.id;
		insert vs;	
				 	
    	PageReference pageRef = Page.scorecard;
		pageRef.getParameters().put('data', vs.Month_Year__c);
			
		Test.setCurrentPageReference(pageRef);
        ScorecardController sc = new ScorecardController(); 
        sc.nextVendor();
        sc.previousVendor();
    }  
     
}