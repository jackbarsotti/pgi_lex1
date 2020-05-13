public class CampaignMonthlyGeneratorSchedulable implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
	Set<Id> contactRecordTypeIds = ReadyTalkRecordTypeHelper.readyTalkContactRecordTypeIds;
	String query = 'SELECT Id FROM Contact WHERE CreatedDate >=: startDate AND CreatedDate <=: endDate AND RecordTypeId IN:contactRecordTypeIds ';
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	public void execute(Database.BatchableContext BC, List<Contact> scope) {
		//pull back existing campaign members
		Set<Id> existingContactsInCampaign = new Set<Id>();
		for(CampaignMember cm: [SELECT Id, ContactId, CampaignId 
														FROM CampaignMember
														WHERE CampaignId =: associatedCampaign.Id
														AND ContactId IN: scope]) {
			existingContactsInCampaign.add(cm.Id);
		}
		List<CampaignMember> campaignMembersToCreate = new List<CampaignMember>();
		for(Contact c: scope) {
			if(!existingContactsInCampaign.contains(c.Id)) {
				campaignMembersToCreate.add(new CampaignMember(
					ContactId = c.Id,
					CampaignId = associatedCampaign.Id
				));
			}
		}
		Database.insert(campaignMembersToCreate, false);
	}
	
	public void finish(Database.BatchableContext BC) {
		
	}
   	public void execute(SchedulableContext sc) {
   		CampaignMonthlyGeneratorSchedulable batchJob = new CampaignMonthlyGeneratorSchedulable();
   		Database.executeBatch(batchJob);
	}
	public Date startDate {get{
		if(startDate == null) {
			startDate = PGI_Utility.startOfMonth(System.today().addMonths(-1));
		}
		return startDate;
	} set;}

	public Date endDate {get {
		return PGI_Utility.endOfMonth(startDate);
	}}

	private Campaign associatedCampaign {get {
		if(associatedCampaign == null) {
			String searchString = campaignName + '%';
			List<Campaign> campaignList = [SELECT Id FROM Campaign WHERE Name LIKE: searchString];
			if(campaignList.size() > 0) {
				associatedCampaign = campaignList[0];
			} else {
				associatedCampaign = generateNewCampaign();
			}
		}
		return associatedCampaign;
	} set;}

	public String campaignName {get {
		DateTime dt = DateTime.newInstance(startDate.year(),startDate.month(),startDate.day()); 
		return 'New User Follow-up ' + dt.format('MMMM yyyy');
	}} 

	//generate a new campaign for the month
	public Campaign generateNewCampaign() {
		Campaign newCampaign = new Campaign();
		newCampaign.StartDate = PGI_Utility.startOfNextMonth(startDate);
		newCampaign.EndDate = PGI_Utility.endOfMonth(startDate.addMonths(1));
		newCampaign.IsActive = true;
		newCampaign.Status = 'In Progress';
		newCampaign.Type = 'Other';
		newCampaign.Partner__c = 'N/A';
		newCampaign.Name = campaignName + ' | Subscribers';
		newCampaign.CampaignMemberRecordTypeId = ReadyTalkRecordTypeHelper.readyTalkCampaignMemberRecordTypes[0].Id;
		newCampaign.Target__c = 'Prospects';
		newCampaign.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkCampaignRecordTypes[0].Id;
		insert newCampaign;
		return newCampaign;
	}
}