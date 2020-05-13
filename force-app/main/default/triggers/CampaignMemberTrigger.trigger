trigger CampaignMemberTrigger on CampaignMember (before insert,after insert) {
	new CampaignMemberTriggerHandler().run();
}