public class AutoAssignUnassignedLeadsHandler {
// @future
// public static void assignleads(Set<Id> userIds) {
    
// List<Lead> Leadsforusers = [Select id,ownerid,status from lead where isConverted = False and recordtype.name like '%PGi%' and status <> 'Disqualified' and ownerid IN :userids AND Global_MQL__c = true];

// system.debug('ARC debug LeadIds:' +Leadsforusers);

// if(!Leadsforusers.isEmpty())
// {
//     for(Lead ld : Leadsforusers)
//     {
//         ld.ownerid = '00Ga0000003werP';
//         ld.status = 'Assigned';
//         ld.Eloqua_Lead_Score__c = null;
//     }
//     update Leadsforusers;
// }
// }
}