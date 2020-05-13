@isTest
private class UserTriggerHandlerTest {

	static User testUser {get;set;}

	static testMethod void unitTestIsServiceUser() {

		Init();

		Test.startTest();

		System.assertEquals(testUser.Is_Service_User__c, false);

		testUser.USERPERMISSIONSSUPPORTUSER = true;
		update testUser;

		System.assertEquals([SELECT Is_Service_User__c FROM User WHERE Id = :testUser.Id].Is_Service_User__c, true);

		Test.stopTest();
	}
	static void Init() {
		testUser = PGITestUtilities.getTestUser();
		insert testUser;
	}

	@isTest
	static void testAutoAssignUnassignedLeads(){
		List <User> usersToUpdate = new List<user>();
		
		Profile p = [SELECT Id FROM Profile WHERE Name='PGi Sales User'];
		
		User usrManager = PGITestUtilities.getTestUser(p);
		usrManager.username = 'User' + Math.random()*100 + '@pgi.com';
		usrManager.EmployeeNumber='12345';
		usrManager.ManagerId = null;
		INSERT usrManager;
		usersToUpdate.add(usrManager);
		
		User usr = PGITestUtilities.getTestUser(p);
		usr.username = 'User' + Math.random()*100 + '@pgi.com';
		usr.EmployeeNumber='67890';
		usr.ManagerId = usrManager.Id;
		INSERT usr;
		usersToUpdate.add(usr);

		User usrAdmin = PGITestUtilities.getTestUser();
		System.runAs(usrAdmin){
			Id pgiRecordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('PGi Leads').getRecordTypeId(); 

			Lead objLead1 = PGITestUtilities.getLeadDetails();
			objLead1.RecordTypeId = pgiRecordTypeIdLead;
			objLead1.Global_MQL__c = true;
			objLead1.ownerId = usr.Id;
			INSERT objLead1;

			Lead objLead2 = PGITestUtilities.getLeadDetails();
			objLead2.RecordTypeId = pgiRecordTypeIdLead;
			objLead2.Global_MQL__c = true;
			objLead2.ownerId = usrManager.Id;
			INSERT objLead2;

			for(User u : usersToUpdate){
				u.isActive = false;
				u.lastName = 'x-' + u.lastName;
			}

			Test.startTest();
			UPDATE usersToUpdate;
			Test.stopTest();

			objLead1 = [SELECT Id, ownerId FROM Lead WHERE Id = :objLead1.Id];
			System.assertEquals(usrManager.Id, objLead1.ownerId, 'lead owner has not been changed to supervisor');

			objLead2 = [SELECT Id, ownerId FROM Lead WHERE Id = :objLead2.Id];
			Id bakingQueueId = [SELECT Id FROM Group WHERE Type ='Queue' AND DeveloperName = 'PGi_Lead_Global_Inquiries_Baking' Limit 1].Id;
			System.assertEquals(bakingQueueId, objLead2.ownerId, 'lead owner has not been changed to PGi_Lead_Global_Inquiries_Baking queue');
		}
    }
}