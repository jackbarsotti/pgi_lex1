trigger PGiCompanyTrigger on PGi_Company__c (before insert, before update, before delete, after insert, after update, after undelete, after delete) {
	new PGiCompanyTriggerHandler().run();
}