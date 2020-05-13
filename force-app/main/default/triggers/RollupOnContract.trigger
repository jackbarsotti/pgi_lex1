trigger RollupOnContract on LicenseSet__c (after insert,after update,after delete) {

Set<Id> contIds = new Set<Id>();
Decimal tempACV,tempTCV,tempMRR,tempMaxTerm;

for ( LicenseSet__c ls : trigger.isDelete ? trigger.Old : trigger.new)
{
    if(Trigger.isInsert || Trigger.isDelete || (Trigger.isUpdate && (ls.Admin_Text_Tag__c != Trigger.oldMap.get(ls.Id).Admin_Text_Tag__c || ls.TCV__c != Trigger.oldMap.get(ls.Id).TCV__c || ls.ACV__c != Trigger.oldMap.get(ls.Id).ACV__c || ls.MRR__c != Trigger.oldMap.get(ls.Id).MRR__c || ls.Max_Term_After_Promo__c != Trigger.oldMap.get(ls.Id).Max_Term_After_Promo__c)))
        contIds.add(ls.PGi_Contract__c);
}
List<CONMAN_Contract__c> contractstoupdate = [Select id,Total_ACV__c,Total_TCV__c,Total_MRR__c,Total_Max_Term_After_Promo__c,(select id,ACV__c,TCV__c,MRR__c,Max_Term_After_Promo__c from LicenseSets__r) from CONMAN_Contract__c where ID IN :contIds ];

if(!contractstoupdate.isEmpty()){
for ( CONMAN_Contract__c cont : contractstoupdate)
{
    tempACV = 0;
    tempTCV = 0;
    tempMRR = 0;
    tempMaxTerm = 0;
    for ( LicenseSet__c lset : cont.LicenseSets__r)
    {
        system.debug('ARC debug lset acv: '+lset.ACV__c);
        tempACV += lset.ACV__c;
        tempTCV += lset.TCV__c;
        tempMRR += lset.MRR__c;
        tempMaxTerm += lset.Max_Term_After_Promo__c;
    }
    cont.Total_ACV__c = tempACV;
    cont.Total_TCV__c = tempTCV;
    cont.Total_MRR__c = tempMRR;
    cont.Total_Max_Term_After_Promo__c = tempMaxTerm;
}
update contractstoupdate;
}
}