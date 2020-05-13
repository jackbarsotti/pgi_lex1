trigger AutoAssignUnassignedLeads on User (after update) {

// Set<Id> userIds = new Set<Id>();

// for (User usr : Trigger.new)
// {
//       //if(usr.isactive == False && trigger.oldMap.get(usr.Id).isActive == True)
//       if(usr.isactive == False && trigger.oldMap.get(usr.Id).isActive == True && usr.Profile_Name_Text__c.contains('Sales') && usr.User_Region__c == 'NA')
//       {
//           userIds.add(usr.id); 
//       }  
// } 
// system.debug('ARC debug Userids:' +userIds);
// if(!userIds.isEmpty())
// {
// AutoAssignUnassignedLeadsHandler.assignleads(userIds);
// }

}