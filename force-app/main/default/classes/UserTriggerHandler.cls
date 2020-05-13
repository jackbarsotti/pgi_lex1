public without sharing class UserTriggerHandler extends TriggerHandler {
	protected override void beforeUpdate() {
		populateIsServiceUser();
	}
	protected override void beforeInsert() {
		populateIsServiceUser();
	}
	protected override void afterUpdate() {
		recalcShare();
		checkDeactivatedUsers();
    }

	private void populateIsServiceUser() {
		for(User user : (List<User>)Trigger.new) {
			user.Is_Service_User__c = user.USERPERMISSIONSSUPPORTUSER;
		}
	}
	// Map<Id, User> newUserMap, Map<Id,User> oldUserMap
	public void recalcShare() {
		EmployeePerformanceMgmtTriggerHandler empInstanceObj = new EmployeePerformanceMgmtTriggerHandler();
		Set<Id> userId = new Set<Id>();
		for(User obj : (List<User>)Trigger.newMap.values()){
			User oldUser = (User)Trigger.oldMap.get(obj.Id);
			if(obj.ManagerID !=  oldUser.ManagerId || obj.isActive != oldUser.isActive){
				userId.add(obj.Id);
				userId.add(oldUser.ManagerId);
				userId.add(obj.ManagerId);
			}
		}
		for(User userObj : [SELECT Id, Name, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId FROM User WHERE IsActive = true AND Id IN: userId]){
            if(userObj.ManagerId != null) {
				userId.add(userObj.ManagerId);
				if(userObj.Manager.ManagerId != null) {
					userId.add(userObj.Manager.ManagerId);
					if(userObj.Manager.Manager.ManagerId != null) {
						userId.add(userObj.Manager.Manager.ManagerId);
					}
				} 
			}
		}
		List<Employee_Performance_Management__Share> shareList = [SELECT Id, UserOrGroupId, ParentId FROM Employee_Performance_Management__Share WHERE UserOrGroupId IN: userId];
		Set<Id> sharesToRecalc = new Set<Id>();
		
		for(Employee_Performance_Management__Share share: shareList) {
			sharesToRecalc.add(share.parentId);
		}
		Database.delete(shareList, false);
		EmployeePerformanceMgmtTriggerHandler.recalcShares(sharesToRecalc);
	}

	private static Set<Id> deactivatedUserIdsProcessed = new Set<Id>();
	private static void checkDeactivatedUsers(){
		Set<Id> userIds = new Set<Id>();
		for (User usr : (List<User>)Trigger.newMap.values()){
			User oldUser = (User)Trigger.oldMap.get(usr.Id);
      		if(usr.isActive == false && oldUser.isActive == true && usr.Profile_Name_Text__c.contains('Sales') && !userIds.contains(usr.Id)){
          		userIds.add(usr.Id);
      		}  
		} 
		if (!userIds.isEmpty()){
			deactivatedUserIdsProcessed.addAll(userIds);
			autoAssignUnassignedLeads(userIds);
		}
	}

	@future
	private static void autoAssignUnassignedLeads(Set<Id> userIds){
		List<Lead> leadsForUsers = [SELECT Id, ownerId, Status FROM Lead WHERE isConverted = False AND RecordType.Name LIKE '%PGi%' AND Status <> 'Disqualified' AND OwnerId IN :userids AND Global_MQL__c = true];
		Map<Id, User> userMap = new Map<Id, User>([SELECT Id, ManagerId FROM User WHERE Id IN :userIds]);
		Id bakingQueueId = [SELECT Id FROM Group WHERE Type ='Queue' AND DeveloperName = 'PGi_Lead_Global_Inquiries_Baking' Limit 1].Id;
		for(Lead l : leadsForUsers){
			if(userMap.get(l.ownerId).ManagerId != null){
				l.ownerId = userMap.get(l.ownerId).ManagerId;
			}else{
				l.ownerId = bakingQueueId;
			}
			l.status = 'Assigned';
			l.Eloqua_Lead_Score__c = null;
		}
		UPDATE leadsForUsers;
	}
}