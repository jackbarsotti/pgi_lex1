@isTest
public class CasePurgeAutoCreatedTest {
	@isTest
	public static void testPurgeCreateCase() {
		Case c = new Case(Auto_Generated_For_Case__c = true);
		insert c;
		Case c2 = new Case(Auto_Generated_For_Case__c = false);
		insert c2;
		Test.startTest();
		CasePurgeAutoCreated.scheduleMe(1);
		List<CronTrigger> ct = [SELECT Id, CronJobDetail.Name, CronJobDetail.JobType 
            FROM CronTrigger WHERE CronJobDetail.Name like 'CasePurgeAutoCreated%'];
        System.assert(ct.size() >= 1);
		Test.stopTest();
		List<Case> caseList = [SELECT Id, IsDeleted FROM Case ALL ROWS];
		System.assert(caseList.size() == 2, 'Wrong size on case list');
		for(Case cse: caseList) {
			if(cse.Id == c.Id) {
				System.assert(cse.IsDeleted == true);
			} else {
				System.assert(cse.IsDeleted == false);
			}
		}
		List<CronTrigger> SecondCt = [SELECT Id, CronJobDetail.Name, CronJobDetail.JobType 
            FROM CronTrigger WHERE CronJobDetail.Name like 'CasePurgeAutoCreated%' AND Id NOT IN: ct];
        System.assert(SecondCt.size()> 0 , 'Same cron job');
    }
}