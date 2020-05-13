trigger AccountTrigger on Account (before insert, before update, before delete, after delete, after insert, after update) {
	new AccountTriggerHandler().run();
}