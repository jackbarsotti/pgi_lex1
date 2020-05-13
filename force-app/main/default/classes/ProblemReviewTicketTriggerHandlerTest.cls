@IsTest
public class ProblemReviewTicketTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        Group q = new Group(Name = 'Test', DeveloperName = 'Test', Type = 'Queue');
        insert q;
        QueueSobject qs = new QueueSobject(QueueId = q.Id, SobjectType = 'Problem_Review_Ticket__c');
        insert qs;
    }
    @IsTest
    public static void testOwnership() {
        Problem_Review_Ticket__c prt = new Problem_Review_Ticket__c();
        insert prt;
        prt.Assignment_Group__c = 'Test';
        update prt;
        System.assertNotEquals(UserInfo.getUserId(), [SELECT Owner.Name FROM Problem_Review_Ticket__c].OwnerId );
    }
}