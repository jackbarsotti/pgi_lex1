@isTest
private class TaskTriggerHandlerTest {
	
	@TestSetup
	static void makeData(){
		PGi_Client__c objPgiClient = new PGi_Client__c(name = 'test 0001');
		INSERT objPgiClient;
        
		Call_Log__c callLogObj = new Call_Log__c();
        callLogObj.PGi_Client__c = objPgiClient.Id;
        INSERT callLogObj;
        
		Id PgiClientRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'PGi_Client_VIP_Request'].Id;
		Case objCase = new Case(Type = 'Issue', Status = 'New', Subject= 'Test', Description = 'test abnn', 
								RequestorsEmail__c ='fake@fake.com', RecordTypeId = PgiClientRecordType, PGi_Client__c = objPgiClient.Id  );
		INSERT objCase;
        
		List<Task> taskList =  new List<Task>();		
		Task objTask =PGITestUtilities.getTaskDetails(objCase.Id);
        taskList.add(objTask);
        Task objTaskCall =PGITestUtilities.getTaskDetails(callLogObj.Id);
        taskList.add(objTaskCall);
		INSERT taskList;
	} 
	
	@isTest static void test_methodOne() {
        Case objCase = [SELECT Id FROM Case Limit 1 ];
		PGi_Client__c pgiClient = [SELECT Id FROM PGi_Client__c Limit 1 ];
		Task objTask = [SELECT Id, PGi_Client__c FROM Task where whatId =: objCase.ID  Limit 1];
		System.assertEquals(pgiClient.Id, objTask.PGi_Client__c);
        
        Call_Log__c callLogObj = [SELECT Id FROM Call_Log__c Limit 1 ];
        Task objTaskCall = [SELECT Id, PGi_Client__c FROM Task where whatId =: callLogObj.ID  Limit 1];
		System.assertEquals(pgiClient.Id, objTaskCall.PGi_Client__c);
	}
	
}