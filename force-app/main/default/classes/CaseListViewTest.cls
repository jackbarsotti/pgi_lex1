@isTest
private class CaseListViewTest {

	static Account testAccount {get;set;}
	static Contract testContract {get;set;}
	static Contact testContact {get;set;}
	static Group testGroup {get;set;}
	static QueuesObject testQueue {get;set;}
	static Case testCase {get;set;}
	
    @TestSetup
    public static void setup() {
        PGITestUtilities.disableSalesWings();
		Test.startTest();
        // init env setup objects in separate context to avoid mixed dml
		System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
			testGroup = new Group(Name = 'test case queue group', type = 'Queue');
	        insert testGroup;
	        testQueue = new QueueSObject(QueueID = testGroup.Id, SobjectType = 'Case');
	        insert testQueue;
			
    	}
		Test.stopTest();
		Init(); //kicks off queuable / callout
    }
	static testMethod void myUnitTest() {
		/*** Disable Saleswings Callouts START ***/ 
       	 //PGITestUtilities.disableSalesWings();
        /*** Disable Saleswings Callouts END ***/
		
		
		Test.startTest();


		PageReference pageRef = Page.CaseListView;
		Id testCaseQueueId = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Id IN (SELECT QueueId FROM QueueSObject WHERE SObjectType = 'Case') ORDER BY Name][0].Id;
		System.assertNotEquals(testCaseQueueId, null, 'Case was queue not created');
		pageRef.getParameters().put('queueId', String.valueOf(testCaseQueueId));
		Test.setCurrentPageReference(pageRef);

		CaseListView controller = new CaseListView();

		CaseListView controllerCaseCountDownTimerConstructor = new CaseListView(new CaseCountdownTimer());

		controller.doNothing();
		controller.closePopup();
		controller.showPopup();

		System.assertNotEquals(controller.caseList, null);

		List<CaseListView.CaseWrapper> testCaseWrapperList = controller.caseWrapperList;
		System.assertNotEquals(testCaseWrapperList, null);

		controller.addQueue();
		controller.refresh();

		System.assertNotEquals(controller.caseQueuesSelectionOptions, null);

		controller.changeOwner();
		Boolean testNotifyOwner = controller.notifyOwner;

		testCaseWrapperList[0].selected = true;
		controller.saveChangeOwner();
		testCaseWrapperList[0].selected = true;
		controller.assignToMe();

		Case tstCase = controller.cse;
		CaseListView.CaseWrapper testWrapper = new CaseListView.CaseWrapper(testCase);
		testWrapper.selected = true;

		Boolean testNotify = controller.sendNotification;

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