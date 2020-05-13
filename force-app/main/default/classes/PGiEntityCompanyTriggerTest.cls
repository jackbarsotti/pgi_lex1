@isTest
public without sharing class PGiEntityCompanyTriggerTest {
	static testMethod void testNormalUpdate(){
		Account a = PGITestUtilities.createAccount(true);
		Opportunity o = PGITestUtilities.createOpportunity(a, true);
		o = [SELECT Id, Opportunity_Number__c FROM Opportunity];
		PGi_Entity__c e = PGITestUtilities.createEntity(true);
		PGi_Company__c c = PGITestUtilities.createCompany(e, true);
		ConMan_Contract__c contract = PGITestUtilities.createConManContract(a, o, true);

		System.assert([SELECT Id, PGiCompany__c FROM ConMan_Contract__c].PGiCompany__c != c.Id, 'contract was already associated to company');

		c.SF_Opportunity_ID__c = o.Opportunity_Number__c;
		update c;
		System.assert([SELECT Id, PGiCompany__c FROM ConMan_Contract__c].PGiCompany__c == c.Id, 'contract did not associate to company');
	}

}