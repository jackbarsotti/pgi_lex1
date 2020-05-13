@isTest 


public class Legacy_Reports_Control_Test {


   @isTest static void Legacy_Reports_Control_Test_Run() {
   
   

   
   
FSL_Company__c    testCompany = new FSL_Company__c();

testCompany.Exclude_From_Reports__c = false;
testCompany.Name = 'Goldman';
insert testCompany;

   
Conference__c testConference = new Conference__c();
testConference.Lead_Bridge__c = 'GE01';
testConference.Conference_ID__c = '24234234234_234';
testConference.Call_Start__c = DateTime.Now();
testConference.Call_End__c= DateTime.Now().AddHours(1);
testConference.Pre_Conference__c= DateTime.Now();
testConference.Company__c = testCompany.id;
testConference.Call_Type__c= 'PCE';
insert testConference;

Conference__c testConferenceTwo = new Conference__c();
testConferenceTwo.Lead_Bridge__c = 'GE01';
testConferenceTwo.Linked_Bridges__c= 'GE02';
testConferenceTwo.Conference_ID__c = '24234234234_235';
testConferenceTwo.Call_Start__c = DateTime.Now();
testConferenceTwo.Call_End__c= DateTime.Now().AddHours(1);
testConferenceTwo.Company__c = testCompany.id;
testConferenceTwo.Pre_Conference__c= DateTime.Now();
testConferenceTwo.Call_Type__c= 'Event';
insert testConferenceTwo;



WorkType testWorkType = new WorkType();
testWorkType.Name = 'Lead';
testWorkType.EstimatedDuration = 60;
testWorkType.Duration__c = 60;
testWorkType.Call_Role__c = true;
insert testWorkType;


WorkType testWorkTypeTwo = new WorkType();
testWorkTypeTwo.Name = 'AL';
testWorkTypeTwo.EstimatedDuration = 60;
testWorkTypeTwo.Duration__c = 60;
testWorkTypeTwo.Call_Role__c = true;
insert testWorkTypeTwo;


WorkOrder testWorkOrderTwo = new WorkOrder();
testWorkOrderTwo.Status = 'New';
testWorkOrderTwo.WorkType = testWorkType;
testWorkOrderTwo.Conference__c = testConferenceTwo.id;
insert testWorkOrderTwo;


WorkOrder testWorkOrder = new WorkOrder();
testWorkOrder.Status = 'New';
testWorkOrder.WorkType = testWorkType;
testWorkOrder.Conference__c = testConference.id;
insert testWorkOrder;


ServiceAppointment testRole = new ServiceAppointment();
testRole.Role_ID__c ='Test Role';
testRole.Status ='Active';
testRole.Work_Order__r = testWorkOrder;

testRole.ParentRecordid = testWorkOrder.id;
testRole.EarliestStartTime = DateTime.Now();
testRole.DueDate = DateTime.Now().AddHours(1); 
insert testRole;


ServiceAppointment testRoleTwo = new ServiceAppointment();
testRoleTwo.Role_ID__c ='Test Role2';
testRoleTwo.Work_Order__r = testWorkOrderTwo;
testRoleTwo.ParentRecordid = testWorkOrderTwo.id;
testRoleTwo.EarliestStartTime = DateTime.Now();
testRoleTwo.DueDate = DateTime.Now().AddHours(1); 
testRole.Role_Not_Needed__c = true;
insert testRoleTwo;



Legacy_Reports_Control lr = new Legacy_Reports_Control ();
lr.Exclude = false;
lr.Page_Load();
lr.ReportDate = date.today();
lr.Run_Report();
lr.Run_Staffing_Review();




delete testRole;
delete testRoleTwo;

delete testWorkOrder;
delete testWorkType;
delete testConference;
delete testCompany;



}
   
   
}