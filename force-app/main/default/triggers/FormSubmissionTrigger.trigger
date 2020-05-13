trigger FormSubmissionTrigger on Form_Submissions__c (before insert,after insert,after update,before update) {
	new FormSubmissionTriggerHandler().run();
}