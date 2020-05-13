@isTest (SeeAllData = false)
private class FinReqSoftDeleteButtonControllerTest
{
	
	@TestSetup static void makeData(){

        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User userObj = PGITestUtilities.getTestUser(p);
        insert userObj;

		Group objGroup = new Group();
		objGroup.Name = 'Junk/Spam Placeholder';
		objGroup.Type = 'Queue';
		INSERT objGroup;
		Profile objProfile = [SELECT id, name FROM Profile WHERE name = 'System Administrator' Limit 1];

		User admin = [SELECT Id FROM User WHERE profileid =: objProfile.id AND isActive= true Limit 1];
		QueuesObject testQueue = new QueueSObject(QueueID = objGroup.id, SobjectType = 'Financial_Request__c');
		insert testQueue;
		system.runas(admin){
			
			Case caseObj = PGITestUtilities.createCase();
			caseObj.Description = 'TestDescription';
			caseObj.Status = 'New';
			INSERT caseObj;
			Financial_Request__c finReqObj = PGITestUtilities.getFinancialRequests(caseObj.Id, userObj.Id);
			insert finReqObj;
		}
	}

	@isTest static void itShouldWork(){
		Financial_Request__c objFinReq =  [SELECT Id, OwnerId FROM Financial_Request__c Limit 1];
		Test.startTest();
		PageReference pref = Page.FinReqSoftDeleteButton;
		Test.setCurrentPage(pref);
		apexPages.Currentpage().getParameters().put('finReqId',objFinReq.id);
		FinReqSoftDeleteButtonController obj = new FinReqSoftDeleteButtonController();
		obj.assignItToQueue();
		Test.StopTest();

		Financial_Request__c objFinReqUpdate =  [SELECT Id, OwnerId FROM Financial_Request__c Limit 1];
		Group objGrp =  [SELECT Id FROM Group where DeveloperName = 'Junk_Spam_Placeholder' Limit 1];
		System.assertEquals (objGrp.Id, objFinReqUpdate.OwnerId );
	}
}