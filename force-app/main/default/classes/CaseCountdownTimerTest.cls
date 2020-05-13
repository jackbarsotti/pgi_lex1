@isTest
private class CaseCountdownTimerTest {
	
	static Account testAccount {get;set;}
	static Contract testContract {get;set;}
	static Contact testContact {get;set;}
	static Group testGroup {get;set;}
	static QueuesObject testQueue {get;set;}
	static Case testCase {get;set;}

	static testMethod void myUnitTest() {
		// init env setup objects in separate context to avoid mixed dml
		System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
			testGroup = new Group(Name = 'test case queue group', type = 'Queue');
	        insert testGroup;
	        testQueue = new QueueSObject(QueueID = testGroup.Id, SobjectType = 'Case');
	        insert testQueue;
    	}


		Test.startTest();
		Init();


		PageReference pageRef = Page.CaseCountdownTimer;
		pageRef.getParameters().put('id', testCase.Id);
		Test.setCurrentPageReference(pageRef);
		ApexPages.Standardcontroller sc  = new Apexpages.Standardcontroller(testCase);

		CaseCountdownTimer controller = new CaseCountdownTimer(sc);
		CaseCountdownTimer controller2 = new CaseCountdownTimer();

		CaseCountdownTimer.CaseTimerWrapper testWrapper = CaseCountdownTimer.queryCaseQueues();

		CaseCountdownTimer.saveAssignToMe(new List<Id>{testCase.Id});

		List<Case> testCases = CaseCountdownTimer.queryCasesByQueueId(String.valueOf([SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Id IN (SELECT QueueId FROM QueueSObject WHERE SObjectType = 'Case') ORDER BY Name][0].Id));

		// TODO assert results
		CaseCountdownTimer.refreshTimers(String.valueOf(testCase.Id));

		Test.stopTest();
	}


	static void Init() {
		testAccount = new Account();
	    testAccount.Name = 'test account';
		insert testAccount;
		
		testContract = new Contract();
		testContract.Name = 'test contract';
		testContract.AccountId = testAccount.Id; 
		insert testContract;
		
		testContact = new Contact();
		testContact.AccountId = testContract.AccountId;
		testContact.LastName = 'test';
		testContact.FirstName ='test';
		testContact.Phone = '1111111111';
		testContact.Email = 'email@test.com';
		insert testContact;
		
		RecordType rc = [Select Name, IsActive, Id From RecordType where SobjectType = 'Case' and Name = 'PGi-Client External Support' and IsActive = true limit 1];

	    testCase = new Case();
	    //testCase.OwnerId = testQueue.QueueID;
	    testCase.OwnerId = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Id IN (SELECT QueueId FROM QueueSObject WHERE SObjectType = 'Case') ORDER BY Name][0].Id;
	    testCase.ContactId = testContact.Id;
	    testCase.AccountId = testAccount.Id;
	    testCase.Status = 'Working';
	    testCase.Origin = 'Phone';
	    testCase.RecordTypeId = rc.Id;
	    insert testCase;
    }
}