/*Class Name        : EmployeePerformanceMgmtTriggerHandler
  Developed By      : 
  Created On        : 
  Last Modified On  : 
*/
public without sharing class EmployeePerformanceMgmtTriggerHandler extends TriggerHandler {
    public EmployeePerformanceMgmtTriggerHandler() {
        super('EmployeePerformanceMgmtTriggerHandler');
    }
    protected override void afterInsert() {
        recalcShares(new Set<Id>(Trigger.newMap.keySet()));
	}
	protected override void afterUpdate() {
		recalcShares(new Set<Id>(Trigger.newMap.keySet()));
    }
/*
* Method Name : recalcShares
* Params : No Params
* Description : If Owner is Changed we have to create sharing rules for 3 levels of managers i.e., manager's manager's manager's based on OwnerId
*/
    public static void recalcShares(Set<Id> perfReviewIds){
        Map<Id,Id> managerIdByOwnerId = new Map<Id,Id>();
        Set<Id> userIds = new Set<Id>();
        List<Employee_Performance_Management__c> reviews = [SELECT Id, OwnerId FROM Employee_Performance_Management__c WHERE Id IN: perfReviewIds];
        for(Employee_Performance_Management__c review: reviews) {
            userIds.add(review.OwnerId);
        }
        List<User> userList = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId FROM User WHERE Id IN: userIds];
        for(User usr: userList) {
            if(usr.ManagerId != null){
                userIds.add(usr.ManagerId);
                if(usr.Manager.ManagerId != null){
                    userIds.add(usr.Manager.ManagerId);
                    if(usr.Manager.Manager.ManagerId != null){
                        userIds.add(usr.Manager.Manager.ManagerId);
                    }
                }
            }
            
        }
        for(User userObj : [SELECT Id, Name, ManagerId FROM User WHERE IsActive = true AND Id IN: userIds]){
            managerIdByOwnerId.put(userObj.Id, userObj.ManagerId);
        }
        List<Employee_Performance_Management__Share> empPerfMgmtList = new List<Employee_Performance_Management__Share>();
        for(Employee_Performance_Management__c obj : reviews){
            Id manager1, manager2, manager3;
            manager1 = managerIdByOwnerId.get(obj.OwnerId);
            
            if(manager1 != null){
                manager2 = managerIdByOwnerId.get(manager1);
                empPerfMgmtList.add(shareRecord(obj.Id, manager1));
            }
            if(manager2 != null){
                manager3 = managerIdByOwnerId.get(manager2);
                empPerfMgmtList.add(shareRecord(obj.Id, manager2));
            }
            if(manager3 != null){
                empPerfMgmtList.add(shareRecord(obj.Id, manager3));
            }
        }
        system.debug('empPerfMgmtList===>'+empPerfMgmtList);
        List<Database.SaveResult> srList = Database.insert(empPerfMgmtList, false);
        System.debug(srList);
    }
    public static Employee_Performance_Management__Share shareRecord(Id recordId, Id UserId){
        system.debug('empPerfMgmtList==UserId=>'+UserId);
        Employee_Performance_Management__Share empPerMgtShare = new Employee_Performance_Management__Share();
        empPerMgtShare.ParentId = recordId;
        empPerMgtShare.UserOrGroupId = UserId;
        empPerMgtShare.AccessLevel = 'edit';        
        return empPerMgtShare;
    }
    public static void removeSharing(Set<Id> managerSet){
        List<Employee_Performance_Management__Share> sharesToDelete = [SELECT Id 
                                                FROM Employee_Performance_Management__Share 
                                                WHERE UserOrGroupId IN : managerSet];
        if(!sharesToDelete.isEmpty()){
            Database.Delete(sharesToDelete, false);
        }
    }
}