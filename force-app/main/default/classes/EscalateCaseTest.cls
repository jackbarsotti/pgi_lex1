@IsTest
public class EscalateCaseTest {
	@isTest
	public static void testCaseEscalation() {
		Case c = PGITestUtilities.createCase();
		insert c;
		Test.setCurrentPage(Page.EscalateCase);
		ApexPages.Standardcontroller sc  = new Apexpages.Standardcontroller(c);
		EscalateCase ext = new EscalateCase(sc);
		ext.init();

		System.assertEquals(true, [SELECT Id, Escalated__c FROM Case].Escalated__c, 'Case failed to escalate');
		ext.init();
		ext.goBack();
	}
}