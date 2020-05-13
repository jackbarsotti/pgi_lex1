@IsTest
public class LoggerUtilTest extends LoggerUtil {
	@IsTest
	public static void testLog(){
		Account a = new Account();
		Account a2 = new Account(Name = 'Test');
		try {
			insert a;
		} catch (DmlException dmlEx) {
			log('Custom Message', dmlEx);
			log(dmlEx);
		}
		System.assertEquals(2, LoggerUtil.errorLogs.size());

		try {
			insert a;
		} catch (Exception ex) {
			log('Custom Message', ex);
			log(ex);
		}
		System.assertEquals(4, LoggerUtil.errorLogs.size());

		List<String> messageList = new List<String>{'1', '2'};
		log('msg', messageList);
		System.assertEquals(5, LoggerUtil.errorLogs.size());

		HttpResponse response = new HttpResponse();
		log('msg', response);
		log(response);
		System.assertEquals(7, LoggerUtil.errorLogs.size());


		handleSaveResults(Database.insert(a, false));
		System.assertEquals(8, LoggerUtil.errorLogs.size());
		handleSaveResults(Database.upsert(a, false));
		System.assertEquals(9, LoggerUtil.errorLogs.size());

		handleSaveResults(Database.insert(new List<Account>{a, a2}, false));
		System.assertEquals(10, LoggerUtil.errorLogs.size());

		handleSaveResults(Database.upsert(new List<Account>{a, a2}, false));
		System.assertEquals(11, LoggerUtil.errorLogs.size());

		handleSaveResults('Custom Message', Database.insert(a, false));
		System.assertEquals(12, LoggerUtil.errorLogs.size());
		handleSaveResults('Custom Message', Database.upsert(a, false));
		System.assertEquals(13, LoggerUtil.errorLogs.size());

		handleSaveResults('Custom Message', Database.upsert(new List<Account>{a, a2}, false));
		System.assertEquals(14, LoggerUtil.errorLogs.size());

		handleSaveResults('Custom Message', Database.insert(new List<Account>{a, a2}, false));
		System.assertEquals(16, LoggerUtil.errorLogs.size());

		commitLogs();

		System.assertEquals(0, LoggerUtil.errorLogs.size());		
		System.assertEquals(16, [SELECT Id FROM Error_Log__c].size());
	}
}