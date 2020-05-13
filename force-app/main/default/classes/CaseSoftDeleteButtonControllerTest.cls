@isTest (SeeAllData = false)
private class CaseSoftDeleteButtonControllerTest
{
	
	@TestSetup static void makeData(){
		Case caseObj = PGITestUtilities.createCase();
		INSERT caseObj;

		Group objGroup = new Group();
		objGroup.Name = 'Junk/Spam Placeholder';
		objGroup.Type = 'Queue';
		INSERT objGroup;
		Profile objProfile = [SELECT id, name FROM Profile WHERE name = 'System Administrator' Limit 1];

		User admin = [SELECT Id FROM User WHERE profileid =: objProfile.id AND isActive= true Limit 1];
		system.runas(admin){
			QueuesObject testQueue = new QueueSObject(QueueID = objGroup.id, SobjectType = 'Case');
				insert testQueue;
		}
	}

	@isTest static void itShouldWork(){
		Case objCase =  [SELECT Id, OwnerId FROM Case Limit 1];
		Test.startTest();
		PageReference pref = Page.CaseSoftDeleteButton;
		Test.setCurrentPage(pref);
		apexPages.Currentpage().getParameters().put('CaseId',objCase.id);
		CaseSoftDeleteButtonController obj = new CaseSoftDeleteButtonController();
		obj.assignItToQueue();
		Test.StopTest();

		Case objCaseUpdate =  [SELECT Id, OwnerId FROM Case Limit 1];
		Group objGrp =  [SELECT Id FROM Group where DeveloperName = 'Junk_Spam_Placeholder' Limit 1];
		System.assertEquals (objGrp.Id, objCaseUpdate.OwnerId );
	}
}