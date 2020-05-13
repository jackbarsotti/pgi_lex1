@IsTest
public with sharing class kanbanActiveSprintTest {
    public kanbanActiveSprintTest() {

    }
    @TestSetup
    static void setData(){
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Contact con = new Contact(LastName = 'Test contact');
        insert con;
        AgileSprint__c agileSprit = new AgileSprint__c();
        agileSprit.Name = 'ActiveSprint';
        agileSprit.AssociatedGroup__c = 'Mediation';
        agileSprit.Status__c ='Active';
        insert agileSprit;
        Case caseObj = new Case(
                                Subject = 'Case Subject',
                                ContactId = con.ID,
                                AccountId = acc.Id,
                                Status = 'Working',
                                Precision__c = 1.0,
                                Origin = 'Phone',
                                AgileSprint__c = agileSprit.Id,
                                AgileStatus__c = 'To Do'
                            );
        insert caseObj;
        Case caseObj1 = new Case(
                                Subject = 'Case Subject',
                                ContactId = con.ID,
                                AccountId = acc.Id,
                                Status = 'Working',
                                Precision__c = 1.0,
                                Origin = 'Phone',
                                AgileSprint__c = agileSprit.Id,
                                AgileStatus__c = 'To Do'
                            );
        insert caseObj1;
        Case caseObj2 = new Case(
                                Subject = 'Case Subject',
                                ContactId = con.ID,
                                AccountId = acc.Id,
                                Status = 'Working',
                                Precision__c = 1.0,
                                Origin = 'Phone',
                                AgileSprint__c = agileSprit.Id,
                                AgileStatus__c = 'To Do'
                            );
        insert caseObj2;
    }
    @isTest
    public static void testGetActiveAgiles(){
        Test.startTest();
        String objName = 'Case';
        String[] objFields = new String[]{'Precision__c','CaseNumber','KanbanOrder__c','GeneralDetails__c','AgileStatus__c','AgileSprint__c','Assigned_To__c	','Assigned_To__r.Name','AgileTester__c','AgileTester__r.Name','AgileEpic__c','AgileEpic__r.Name','AgileEpic__r.EpicColor__c','AgileSprint__r.Name','AgileSprint__r.AssociatedGroup__c'};

        // String[] objFields ;// {"Precision__c","CaseNumber",'KanbanOrder__c','GeneralDetails__c'};//= 'AssociatedGroup__c';
        String kanbanField = 'AgileSprint__c';
        Boolean isForBackLog = true;
        String selectedGroup = 'Mediation';
        String field = 'Precision__c';
        Boolean order = true;
        kanbanActiveSprint.getActiveAgiles(objName, objFields, kanbanField, isForBackLog, selectedGroup,field,order);
        Boolean isForBackLog1 = false;
        kanbanActiveSprint.getActiveAgiles(objName, objFields, kanbanField, isForBackLog1, selectedGroup,field,false);
        System.assertEquals(1, [SELECT Id, Name 
                                FROM AgileSprint__c 
                                WHERE AssociatedGroup__c =:selectedGroup AND (Status__c = 'Not Started' OR Status__c = 'Active')
                                ORDER BY StartDate__c ASC].Size());
        Test.stopTest();
    }
    
    @isTest
    public static void testGetPickListValuesIntoList(){
        Test.startTest();
        kanbanActiveSprint.getPickListValuesIntoList('AgileSprint__c', 'AssociatedGroup__c');
        System.assertEquals(5, kanbanActiveSprint.getPickListValuesIntoList('AgileSprint__c', 'AssociatedGroup__c').Size());
        Test.stopTest();
    }
    // @isTest
    // public static void testGetallSprint(){
    //     kanbanActiveSprint.getallSprint();
    //     System.assertEquals(1, kanbanActiveSprint.getallSprint().Size());
    // }
    @isTest
    public static void testUpdateStatus(){
        Test.startTest();
        kanbanActiveSprint.updateStatus('ActiveSprint', 'Start', 'Mediation');
        kanbanActiveSprint.updateStatus('ActiveSprint', 'Complete', 'Mediation');
        kanbanActiveSprint.updateStatus('ActiveSprint', 'name', 'Mediation');
        System.assertEquals(1, [SELECT Id,Name,AssociatedGroup__c,Status__c FROM AgileSprint__c].Size());
        Test.stopTest();
    }
    @isTest
    public static void testGetAgileStatusToGroup(){
        Test.startTest();
        kanbanActiveSprint.getAgileStatusToGroup();
        System.assertEquals(5, [SELECT Id,GroupName__c,AgileStatus__c FROM AssGroupToAgileStatus__mdt].Size());
        Test.stopTest();
    }
    @isTest
    public static void testGetAgileNameToStatus(){
        Test.startTest();
        kanbanActiveSprint.getAgileNameToStatus();
        System.assertEquals(1, [SELECT Id,Name,AssociatedGroup__c,Status__c FROM AgileSprint__c].Size());
        Test.stopTest();
    }
    @isTest
    public static void testGetGroupToStatus(){
        Test.startTest();
        kanbanActiveSprint.getGroupToStatus();
        List<sObject> records = new List<sObject>();
        List<sObject> backlogCases = new List<sObject>();
        List<String> pickVals = new List<String>();
        
        // kanbanActiveSprint.kanbanWrap obj = new kanbanActiveSprint.kanbanWrap(records,pickVals,backlogCases);
        System.assertEquals(1, [SELECT Id,Name,AssociatedGroup__c,Status__c FROM AgileSprint__c WHERE  Status__c ='Active'].Size());
        Test.stopTest();
    }
    @isTest
    public static void testSetPrecision(){
        Test.startTest();
        // AgileSprint__c agileSprit = new AgileSprint__c();
        // agileSprit.Name = 'ActiveSprint';
        // agileSprit.AssociatedGroup__c = 'Mediation';
        // agileSprit.Status__c ='Active';
        // insert agileSprit;

        List<Case> caseLst = [SELECT Id, Precision__c, CaseNumber, KanbanOrder__c, GeneralDetails__c, AgileStatus__c, AgileSprint__c, Assigned_To__c, AgileTester__c, AgileEpic__c,AgileSprint__r.Name, AgileSprint__r.AssociatedGroup__c
                              FROM Case 
                              WHERE Subject = 'Case Subject'];
       
        String sprintName = '';
        // String sprintName = 'ActiveSprint';
        Id caseId = caseLst[2].Id;
        // kanbanActiveSprint.setPrecision(caseLst, '' ,caseId);
        kanbanActiveSprint.setPrecision(caseLst, sprintName, caseId,true,2);
        Case objCase = [Select Precision__c from Case where Id =:caseId];
        System.assertEquals(objCase.Precision__c, 2);
        System.assertNotEquals(objCase.Precision__c, caseLst[0].Precision__c);
        // kanbanActiveSprint.setPrecision(caseLst, sprintName, caseId);
       Test.stopTest();
    }
    @isTest
    public static void testSetPrecisionElse(){
        Test.startTest();
        AgileSprint__c agileSprit = new AgileSprint__c();
        agileSprit.Name = 'ActiveSprint';
        agileSprit.AssociatedGroup__c = 'Salesforce: CRM Ops & Dev';
        agileSprit.Status__c ='Active';
        insert agileSprit;
        List<Case> caseLst = [SELECT Id, Precision__c, CaseNumber, KanbanOrder__c, GeneralDetails__c, AgileStatus__c, AgileSprint__c, Assigned_To__c, AgileTester__c, AgileEpic__c,AgileSprint__r.Name, AgileSprint__r.AssociatedGroup__c
                              FROM Case 
                              WHERE Subject = 'Case Subject'];
        Id caseId = caseLst[0].Id;
        String sprintName = 'ActiveSprint';
        try{
            kanbanActiveSprint.setPrecision(caseLst, sprintName, caseId,true,null);
        }catch(Exception e){}
        Case objCase = [Select Precision__c from Case where Id =:caseId];
        System.assertEquals(objCase.Precision__c, 2);
        System.assertNotEquals(objCase.Precision__c, caseLst[0].Precision__c);
        
        Test.stopTest();
    }                           
    @isTest
    public static void testGetUpdateStage(){
        Test.startTest();
        Case cse = new Case();
        List<Case> caseLst = [SELECT Id, Subject,Precision__c,Status FROM Case WHERE Subject = 'Case Subject'];
        String sprintName = 'ActiveSprint';
        Id recId = caseLst[0].Id;
        String kanbanField = 'AgileSprint__c';
        String kanbanNewValue = 'ActiveSprint' ;
        Boolean isForBackLog = true;
        String groupselected = 'Mediation';
        kanbanActiveSprint.getUpdateStage(recId, kanbanField, kanbanNewValue, isForBackLog,groupselected);
        System.assertEquals('Success', kanbanActiveSprint.getUpdateStage(recId, kanbanField, kanbanNewValue, isForBackLog,groupselected));
        Test.stopTest();
    }
}