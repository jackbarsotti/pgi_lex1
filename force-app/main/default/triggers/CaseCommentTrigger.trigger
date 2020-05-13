trigger CaseCommentTrigger on CaseComment (before insert, before update, before delete, after insert, after update, after undelete) {
	new CaseCommentTriggerHandler().run();
}