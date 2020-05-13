/* 
     * Created by: Vijay
     * RT-461: To backfills “Average_SLA_Time__c” from “Average SLA In Minutes”
    */
    
    global class SetAverageSlaInMinutesForCase implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query ='SELECT Id,Average_SLA_Time__c,Average_SLA_In_Minutes__c FROM Case WHERE Average_SLA_Time__c !=\'\'';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Case> CaseLst) {
        List<Case> caseToUpdate = new List<Case>();
        for(Case objCase : CaseLst){
            String strAvgSlaTime=objCase.Average_SLA_Time__c;
            List<String> avgSlaSplitList=strAvgSlaTime.split(':');
            Boolean isNegativeValue =strAvgSlaTime.contains('-');
            decimal hrsInInMin;
            if(avgSlaSplitList.size() > 0){
                hrsInInMin= (Decimal.valueOf(avgSlaSplitList[0].removeStart('-'))*60) + Decimal.valueOf(avgSlaSplitList[1]);
            }
            String hrsinmStr= String.valueOf(hrsInInMin);
            if(isNegativeValue){
                hrsinmStr ='-'+hrsinmStr;
            }
            objCase.Average_SLA_In_Minutes__c = Decimal.valueOf(hrsinmStr); 
            caseToUpdate.add(objCase);
            System.debug('The value'+objCase.Average_SLA_In_Minutes__c);
        }
        UPDATE caseToUpdate;
    }
    global void finish(Database.BatchableContext bc) {
        
    }
}