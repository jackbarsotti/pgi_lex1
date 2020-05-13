@IsTest
public class CampaignMonthlyGeneratorSchedulableTest {
	//for each test - we will have 3 contacts (1 created before, 1 created after, 1 created during period)

	//test with existing campaign
	@IsTest
	public static void testWithCampaign() {
		System.assertEquals(0, [SELECT Id FROM Campaign].size(), 'There should not be a campaign yet');
		Campaign generatedCampaign = new CampaignMonthlyGeneratorSchedulable().generateNewCampaign();
		System.assertEquals(1, [SELECT Id FROM Campaign].size(), '1 campaign should have been created');
		Test.startTest();
		CampaignMonthlyGeneratorSchedulable batchJob = new CampaignMonthlyGeneratorSchedulable();
   		Database.executeBatch(batchJob);
   		Test.stopTest();
   		System.assertEquals(1, [SELECT Id FROM Campaign].size(), 'No additional campaigns should have been created');
   		List<CampaignMember> cm = [SELECT Id, ContactId, CampaignId FROM CampaignMember];
   		System.assertEquals(1, cm.size(), 'Wrong number of campaign members generated');
   		System.assertEquals(cm[0].ContactId, [SELECT Id FROM Contact WHERE CreatedDate =: System.today().addMonths(-1)].Id, 'Wrong contact associated to Campaign Member');
	}
	//test without campaign
	@IsTest
	public static void testWithoutCampaign() {
		System.assertEquals(0, [SELECT Id FROM Campaign].size(), 'There should not be a campaign yet');
		Test.startTest();
   		CampaignMonthlyGeneratorSchedulable batchJob = new CampaignMonthlyGeneratorSchedulable();
   		Database.executeBatch(batchJob);
   		Test.stopTest();
   		System.assertEquals(1, [SELECT Id FROM Campaign].size(), 'No additional campaigns should have been created');
   		List<CampaignMember> cm = [SELECT Id, ContactId, CampaignId FROM CampaignMember];
   		System.assertEquals(1, cm.size(), 'Wrong number of campaign members generated');
   		System.assertEquals(cm[0].ContactId, [SELECT Id FROM Contact WHERE CreatedDate =: System.today().addMonths(-1)].Id, 'Wrong contact associated to Campaign Member');
	}
	@TestSetup
	public static void createAccountAndContacts() {
		Account acct = PGITestUtilities.createAccount(true);

		List<Contact> contactList = new List<Contact>();
		Contact con1 = PGITestUtilities.createContact(acct, false);
		con1.CreatedDate = System.today().addMonths(-2);
		con1.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkContactRecordTypes[0].Id;
		contactList.add(con1);

		Contact con2 = PGITestUtilities.createContact(acct, false);
		con2.CreatedDate = System.today().addMonths(-1);
		con2.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkContactRecordTypes[0].Id;
		contactList.add(con2);

		Contact con3 = PGITestUtilities.createContact(acct, false);
		con3.CreatedDate = System.today();
		con3.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkContactRecordTypes[0].Id;
		contactList.add(con3);

		insert contactList;
	}
}