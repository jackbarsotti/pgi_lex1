public without sharing class CaseDeleteGMQueue implements Schedulable {
	private static boolean t = true;
    public static DateTime filterTime {get {
        if(Test.isRunningTest()) {
            return DateTime.now();
        } else {
            return DateTime.now().addHours(-24);
        }
    }}
    public static Id queueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'PGi-Case-GM Testing'].Id;
    //process 1 contract at a time and then reschedule itself
    public void execute(SchedulableContext sc) {
        List<Case> casesToDelete = [SELECT Id FROM Case WHERE OwnerId =: queueId AND CreatedDate <: filterTime LIMIT 200];
        if(casesToDelete.size() == 200) {
        	scheduleMe(1, true);
        } else {
        	scheduleMe(0, false);
        }
        delete casesToDelete;
        //purge existing cases
        for(CronTrigger ct : [SELECT Id, CronJobDetail.Name, CronJobDetail.JobType 
            FROM CronTrigger WHERE CronJobDetail.Name like 'CaseDeleteGMQueue%' AND Id =: sc.getTriggerId()]){
            System.abortJob(ct.Id);
        }
    }
    public static void scheduleMe(Integer i, Boolean now) {
        Datetime futureTime = System.now();
        Integer day, month, hour, minute, second, year;
        //reschedule
        if(now) {
	    	futureTime = system.now().addMinutes(i);
	    	minute = futureTime.minute();
	    	hour = futureTime.hour();
	    	second = futureTime.second();
	    } else {
	    	futureTime = futureTime.addDays(1);
	    	hour = 11;
	    	minute = 0;
	    	second = 0;
	    }

        day = futureTime.day();
        month = futureTime.month();
        year = futureTime.year();
        
        String strSchedule = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;            
        String strJobName = 'CaseDeleteGMQueue-' + strSchedule;
        System.schedule(strJobName, strSchedule, new CaseDeleteGMQueue());
    }
}