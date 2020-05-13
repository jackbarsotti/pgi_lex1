trigger UserTrigger on User (before insert, before update, before delete, after insert, after update, after undelete, after delete) {
	new UserTriggerHandler().run();
}