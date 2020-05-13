public without sharing class CasePurgeAutoCreated implements Schedulable {
	private static boolean t = true;
    public static DateTime filterTime {get {
        if(Test.isRunningTest()) {
            return DateTime.now();
        } else {
            return DateTime.now().addHours(-4);
        }
    }}
    //process 1 contract at a time and then reschedule itself
    public void execute(SchedulableContext sc) {
        scheduleMe(10);
        List<Case> casesToDelete = [SELECT Id, Auto_Generated_For_Case__c FROM Case WHERE Auto_Generated_For_Case__c =: t AND CreatedDate <: filterTime LIMIT 5];
        for(Case c: casesToDelete) {
            if(c.Auto_Generated_For_Case__c == true) {
                try {
                    delete c;
                } catch (exception e) {
                    System.debug(e);
                    System.assert(false, 'Failed: ' + e.getMessage());
                }
            }
        }
        //purge existing cases
        for(CronTrigger ct : [SELECT Id, CronJobDetail.Name, CronJobDetail.JobType 
            FROM CronTrigger WHERE CronJobDetail.Name like 'CasePurgeAutoCreated%' AND Id =: sc.getTriggerId()]){
            System.abortJob(ct.Id);
        }
    }
    public static void scheduleMe(Integer i) {
        //reschedule
        Datetime futureTime = system.now().addMinutes(i);
        Integer day = futureTime.day();
        Integer month = futureTime.month();
        Integer hour = futureTime.hour();
        Integer minute = futureTime.minute();
        Integer second = futureTime.second();
        Integer year = futureTime.year();
        String strSchedule = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;            
        String strJobName = 'CasePurgeAutoCreated-' + strSchedule;
        System.schedule(strJobName, strSchedule, new CasePurgeAutoCreated());
    }
}