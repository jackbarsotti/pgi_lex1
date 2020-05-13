trigger AccountReadyTalkTrigger on Account (before insert, before update, after insert, after update, before delete, after undelete, after delete) {
	new AccountReadyTalkTriggerHandler().run();
}