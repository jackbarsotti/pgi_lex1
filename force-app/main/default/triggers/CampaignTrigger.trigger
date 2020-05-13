trigger CampaignTrigger on Campaign (before insert, before update, before delete, after delete, after insert, after update) {
	new CampaignTriggerHandler().run();
}