trigger ProblemReviewTicketTrigger on Problem_Review_Ticket__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    new ProblemReviewTicketTriggerHandler().run();
}