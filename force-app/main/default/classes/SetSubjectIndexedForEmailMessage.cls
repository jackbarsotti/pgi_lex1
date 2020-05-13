/* 
     * Created by: Vijay
     * RT-462: To backfills “Subject Indexed” from “Subject”
    */


global class SetSubjectIndexedForEmailMessage implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime dt = System.now().addMonths(-2);
        String query ='SELECT Id,Subject_Indexed__c,Subject FROM EmailMessage WHERE Subject !=\'\' AND CreatedDate >: dt';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<EmailMessage> emailLst) {
        List<EmailMessage> emMsgToUpdateLst = new List<EmailMessage>();
        for(EmailMessage em : emailLst){
            if(String.isNotBlank(em.Subject)) {
                if(em.Subject.length() > 255) {
                    em.Subject_Indexed__c = em.Subject.left(255);
                    emMsgToUpdateLst.add(em);
                } else {
                    em.Subject_Indexed__c = em.Subject;
                    emMsgToUpdateLst.add(em);
                }
            }
        }
        UPDATE emMsgToUpdateLst;
        System.debug('The value'+emMsgToUpdateLst[0].Subject_Indexed__c);
    }
    global void finish(Database.BatchableContext bc) {
        
    }
}