global with sharing class PublicGroupExplorer {
    public PublicGroupExplorer() {

    }

    @RemoteAction
    global static List<User> queryUsers() {
        List<User> users = new List<User>();

        for(User user : [SELECT Id, Name 
                         FROM User]) {
            users.add(user); 
        }  

        return users;
    }

    @RemoteAction
    global static List<Group> queryAllRegularPublicGroups() {
        List<Group> groups = new List<Group>();

        groups = [SELECT Id, Name
                      FROM Group
                      WHERE Type = 'Regular'];

        return groups;
    }

    @RemoteAction
    global static List<UserGroupWrapper> queryUsersByGroupId(String selectedGroupId) {
        List<UserGroupWrapper> users = new List<UserGroupWrapper>();
        Set<Id> groupIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();

        for(GroupMember member : [SELECT UserOrGroupId
                                  FROM GroupMember
                                  WHERE GroupId = :selectedGroupId]) {
            if(String.valueOf(member.UserOrGroupId).startsWith('00G')) {
                groupIds.add(member.UserOrGroupId);
            }
            else {
                userIds.add(member.UserOrGroupId);  
            }
            
        }
        // query for nested groups as group members
        if(!groupIds.isEmpty()) {
            for(GroupMember member : [SELECT UserOrGroupId
                                      FROM GroupMember
                                      WHERE GroupId IN :groupIds]) {
                userIds.add(member.UserOrGroupId);
            }
        }

        if(!userIds.isEmpty()) {
            Set<Id> managerIds = new Set<Id>();

            for(User user : [SELECT Id, Name, ManagerId
                             FROM User
                             WHERE Id IN :userIds]) {
                users.add(new UserGroupWrapper(user, 'Group Member'));
                managerIds.add(user.ManagerId);
            }
            // query for managers of members
            // TODO: Group.DoesIncludeBosses (Granted access to Managers)
            if(!managerIds.isEmpty()) {
                for(User manager : [SELECT Id, Name
                                 FROM User
                                 WHERE Id IN :managerIds]) {
                    users.add(new UserGroupWrapper(manager, 'Manager of Group Member'));
                }   
            }
        }

        return users;
    }

    global class UserGroupWrapper {
        public String userName {get;set;}
        public String userId {get;set;}
        public String reasonForMembership {get;set;}

        global UserGroupWrapper(User user, String reasonForMembership) {
            this.userName = user.Name;
            this.userId = user.Id;
            this.reasonForMembership = reasonForMembership;
        }
    }

    @RemoteAction
    global static List<Group> queryGroupsByUserId(String selectedUserId) {
        List<Group> groups = new List<Group>();
        Set<Id> groupIds = new Set<Id>();

        for(GroupMember member : [SELECT GroupId, UserOrGroupId
                                  FROM GroupMember 
                                  WHERE UserOrGroupId = :selectedUserId]) {
            groupIds.add(member.GroupId);
        }

        if(!groupIds.isEmpty()) {

            for(GroupMember member : [SELECT GroupId, UserOrGroupId
                                      FROM GroupMember 
                                      WHERE UserOrGroupId IN :groupIds]) {
                groupIds.add(member.GroupId);
            }
            
            groups = [SELECT Id, Name
                      FROM Group
                      WHERE Id IN :groupIds];
        }

        return groups;
    }

}