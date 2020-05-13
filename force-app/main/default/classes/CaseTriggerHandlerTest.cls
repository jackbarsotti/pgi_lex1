@isTest
public without sharing class CaseTriggerHandlerTest {
    /*for(Case c: (List<Case>)Trigger.new) {
if((isChanged('Confirmed_Production_Defect__c', c) && c.Confirmed_Production_Defect__c 
|| isChanged('Status', c) && c.Status == 'Resolved')
&& String.isNotBlank(c.Return_for_Client_Follow_Up__c)) {
if(queueNameToQueue.get(c.Return_for_Client_Follow_Up__c) != null) {
c.OwnerId = queueNameToQueue.get(c.Return_for_Client_Follow_Up__c).Id;
}
}
}*/
    //static testMethod void testClosedCaseComment() {
    //    Case testCase = createCase(true);
    //    testCase.Status = 'Closed';
    //    update testCase;
    //    // assert case comment is created when case is closed
    //    system.assert([SELECT Id FROM CaseComment WHERE ParentId = :testCase.Id].Id != null);
    //}
    
    static testMethod void testConfirmedDefect(){
        Case c = createCase(true);
        String originalOwnerId = String.valueOf(c.OwnerId);
        c.Confirmed_Production_Defect__c = true;
        update c;
        c = requery(c);
        system.assert(c.OwnerId != originalOwnerId);
        system.assert(c.OwnerId == qList[1].QueueId);
    }
    static testMethod void testUnconfirmedDefect(){
        Case c = createCase(true);
        Id originalOwnerId = c.OwnerId;
        c.Confirmed_Production_Defect__c = false;
        update c;
        c = requery(c);
        system.assert(c.OwnerId == originalOwnerId);
        system.assert(c.OwnerId == qList[0].QueueId);
    }
    static testMethod void testResolved(){
        Case c = createCase(true);
        Id originalOwnerId = c.OwnerId;
        Id recordTypeId = null;
        for(RecordType rt: CaseTriggerHandler.caseRecordTypeMap.values()) {
            if(rt.DeveloperName == CaseTriggerHandler.PGI_EXTERNAL_SUPPORT) {
                recordTypeId = rt.Id;
                break;
            }
        }
        c.RecordTypeId = recordTypeId;
        c.Status = 'Resolved';
        update c;
        c = requery(c);
        system.assert(c.OwnerId != originalOwnerId);
        system.assert(c.OwnerId == qList[1].QueueId);
    }
    static testMethod void testUnresolved(){
        Case c = createCase(true);
        Id originalOwnerId = c.OwnerId;
        c.Status = 'Unresolved';
        update c;
        c = requery(c);
        system.assert(c.OwnerId == originalOwnerId);
        system.assert(c.OwnerId == qList[0].QueueId);
    }
    static testMethod void testNormalUpdate(){
        Case c = createCase(false);
        c.Return_for_Client_Follow_Up__c = '';
        insert c;
        c = requery(c);
        Id originalOwnerId = c.OwnerId;
        c.Status = 'Unresolved';
        update c;
        c = requery(c);
        system.assert(c.OwnerId == originalOwnerId);
        system.assert(c.OwnerId == qList[0].QueueId);
    }
    private static Case requery(Case c) {
        return [SELECT Id, OwnerId, Return_for_Client_Follow_Up__c FROM Case WHERE Id =: c.Id];
    }
    private static List<QueueSobject> qList = [SELECT Id, QueueId, Queue.Name FROM QueueSobject WHERE SobjectType = 'Case'];
    private static Case createCase(Boolean doInsert){
        Case c = new Case(
            Subject = 'Test Cases',
            OwnerId = qList[0].QueueId,
            Return_for_Client_Follow_Up__c = qList[1].Queue.Name,
            RecordTypeId = '0121B000001hgNa'
        );
        if(doInsert){
            System.debug(c.Return_for_Client_Follow_Up__c);
            insert c;
        }
        return c;
    }
    static testMethod void testRelatedConferences() {
        PGI_Conference__c conf = new PGI_Conference__c(Name = '321');
        insert conf;
        PGI_Client__c client = new PGI_Client__c(Name = '123');
        insert client;
        
        
        Case c = createCase(false);
        c.PGi_Client_via_external_form__c = '123';
        c.PGi_Conference_via_external_form__c = '321';
        c.Bill_To_Client__c = client.Id;
        insert c;
        
        Case cse = [SELECT PGI_Client__c, PGI_Conference__c FROM Case];
        System.assert(cse.PGI_Client__c == client.Id);
        System.assert(cse.PGI_Conference__c == conf.Id);
    }
    static testMethod void testChildCount() {
        Case parentOf0 = createCase(false);
        Case parentOf2 = createCase(false); 
        Case parentOf4 = createCase(false); //two standard, two custom
        insert new List<Case>{parentOf0, parentOf2, parentOf4};
            
            //test insert operation
            List<Case> children = new List<Case>();
        Case childOf2A = createCase(false);
        childOf2A.ParentId = parentOf2.Id;
        children.add(childOf2A);
        Case childOf2B = createCase(false);
        childOf2B.External_Support_Case_Number__c = parentOf2.Id;
        children.add(childOf2B);
        insert children;
        
        Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, Child_Cases__c FROM Case]) ;
        System.assert(caseMap.get(parentOf0.Id).Child_Cases__c == 0);
        System.assert(caseMap.get(parentOf2.Id).Child_Cases__c == 2);
        System.assert(caseMap.get(parentOf4.Id).Child_Cases__c == 0);
        
        //test insert and update
        List<Case> childrenOf4th = new List<Case>();
        Case childOf4A = createCase(false);
        childOf4A.ParentId = parentOf4.Id;
        childrenOf4th.add(childOf4A);
        Case childOf4B = createCase(false);
        childOf4B.External_Support_Case_Number__c = parentOf4.Id;
        childrenOf4th.add(childof4B);
        
        Case childOf4C = createCase(false);
        //childOf4C.ParentId = parentOf4.Id;
        childrenOf4th.add(childOf4C);
        Case childOf4D = createCase(false);
        //childOf4D.External_Support_Case_Number__c = parentOf4.Id;
        childrenOf4th.add(childOf4D);
        insert childrenOf4th;
        
        caseMap = new Map<Id, Case>([SELECT Id, Child_Cases__c FROM Case]) ;
        System.assert(caseMap.get(parentOf0.Id).Child_Cases__c == 0);
        System.assert(caseMap.get(parentOf2.Id).Child_Cases__c == 2);
        System.assert(caseMap.get(parentOf4.Id).Child_Cases__c == 2);
        
        //test update
        childOf4C.ParentId = parentOf4.Id;
        childOf4D.External_Support_Case_Number__c = parentOf4.Id;
        update childrenOf4th;
        
        caseMap = new Map<Id, Case>([SELECT Id, Child_Cases__c FROM Case]) ;
        System.assert(caseMap.get(parentOf0.Id).Child_Cases__c == 0);
        System.assert(caseMap.get(parentOf2.Id).Child_Cases__c == 2);
        System.assert(caseMap.get(parentOf4.Id).Child_Cases__c == 4);
    }
    
    
    //static testMethod void testProcessRFCCases() {
    //    Request_For_Change__c testRFCCase = PGITestUtilities.createRFC(false);
    //    testRFCCase.Status__c = 'Approved';
    //    insert testRFCCase;
    
    //    Case c = createCase(false);
    //    c.Status = 'Accepted';
    //    c.Related_RFC__c = testRFCCase.Id;
    //    insert c;
    //}
    
    //static testMethod void testProcessRFCCaseComplete() {
    //    Request_For_Change__c testRFCCase = PGITestUtilities.createRFC(false);
    //    testRFCCase.Status__c = 'Complete'; // will skip processing
    //    insert testRFCCase;
    
    //    Case c = createCase(false);
    //    c.Status = 'Accepted';
    //    c.Related_RFC__c = testRFCCase.Id;
    //    insert c;
    //}
    
    //static testMethod void testProcessRFCCaseNew() {
    //    Request_For_Change__c testRFCCase = PGITestUtilities.createRFC(false);
    //    testRFCCase.Status__c = 'New'; // will skip processing
    //    insert testRFCCase;
    
    //    Case c = createCase(false);
    //    c.Status = 'New';
    //    c.Related_RFC__c = testRFCCase.Id;
    //    insert c;
    
    //    Case testCase = createCase(true);
    //}
    static testMethod void findDuplicateCaseOnEmail2Case(){
        Case parentCase = createCase(false);
        parentCase.Subject = 'Test email';
        parentCase.SuppliedEmail = 'test@abc.org';
        
        INSERT parentCase;
        Case parentCaseObj = createCase(false);
       
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(parentCase.Id, yesterday);
        EmailMessage newEmail = new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, 
                                                 ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', 
                                                 Subject = 'Test email', TextBody = '23456 ', ParentId = parentCase.Id,CcAddress ='test',BccAddress='testBcc'); 
        insert newEmail;
        
        
        Case childCase = createCase(false);
        childCase.Subject = 'Test email';
        childCase.SuppliedEmail = 'test@abc.org';
        INSERT childCase;
        parentCase.status = 'In Progress';
        update parentCase;
      
        Case childCase1 = createCase(false);
        childCase1.Subject = 'Test email';
        childCase1.SuppliedEmail = 'test@abc.org';
        INSERT childCase1;
        
        Case childCase2 = createCase(false);
        childCase2.Subject = 'Test email';
        childCase2.SuppliedEmail = 'test@abc.org';
        INSERT childCase2;
        
        Case childCase3 = createCase(false);
        childCase3.Subject = 'fw: Test email';
        childCase3.SuppliedEmail = 'test@abc.org';
        INSERT childCase3;
       
        
    }
    static testMethod void checkForClosed(){
       
          Email_SLA_Management__c SLAObj = new Email_SLA_Management__c();
        SLAObj.Origin__c = 'Email';
        SLAObj.SLA_In_Hours__c = 2;
         INSERT SLAObj;
        
         Email_SLA_Management__c SLAObj1 = new Email_SLA_Management__c();
        SLAObj1.Origin__c = 'test';
         SLAObj1.SLA_In_Hours__c = 2;
        INSERT SLAObj1;
        
        Case caseObj = createCase(true);
        Case c = createCase(true);
        Id originalOwnerId = c.OwnerId;
        Id recordTypeId = null;
        for(RecordType rt: CaseTriggerHandler.caseRecordTypeMap.values()) {
            if(rt.DeveloperName == CaseTriggerHandler.Inbound_Email_Support) {
                recordTypeId = rt.Id;
                break;
            }
        }
        c.RecordTypeId = recordTypeId;
        c.Status = 'Closed';
        c.ParentId = caseObj.Id;
        c.First_Response_Time__c = null;
        c.SLA_In_Hours__c = null;
        c.SLA_Time_to_Complete__c = datetime.newInstance(2019, 10, 15, 12, 30, 0);
        c.Service_Restored__c =  True;         
        update c;
        c = requery(c);
 
        case cse = createCase(false);
        cse.RecordTypeId = recordTypeId;
        cse.SLA_In_Hours__c = null;
        cse.Origin = 'Email';
        INSERT cse;
       // cse = requery(cse);
        Case caseChildObj = createCase(false);
        caseChildObj.Status = 'Customer Replied';
        caseChildObj.RecordTypeId = recordTypeId;
        INSERT caseChildObj;
       
    }
  
   static testMethod void TestpopulatePGiforInboundEmailServiceCaseRT(){
        Case caseObj = createCase(true);
       
          PGI_Client__c pgiObj = new PGI_Client__c();
       		INSERT pgiObj;
        	pgiObj.Client_Email__c = 'test@abc.org';
            UPDATE pgiObj;
       
        Id originalOwnerId = caseObj.OwnerId;
        Id recordTypeId = null;
        for(RecordType rt: CaseTriggerHandler.caseRecordTypeMap.values()) {
            if(rt.DeveloperName == CaseTriggerHandler.Inbound_Email_Support) {
                recordTypeId = rt.Id;
                break;
            }
        }
       
        case cse = createCase(true);
        cse.RecordTypeId = recordTypeId;
        cse.SuppliedEmail = 'test@abc.org';
        
        UPDATE cse;
      
        Case caseChildObj = createCase(false);
        caseChildObj.Status = 'Customer Replied';
        caseChildObj.RecordTypeId = recordTypeId;
        caseChildObj.SuppliedEmail = 'test@abc.org';
        INSERT caseChildObj;
        
        	
       
    }
    static testMethod void testaddToPausedTimeToScheduledFields(){
        Case c = createCase(true);
       
        Id recordTypeId = null;
       
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'PGi_Client_External_Support'];
        c.RecordTypeId = rt.Id;
        c.Status = 'Closed';
        c.Total_Paused_Time__c = 2.0; 
        update c;
        c = requery(c);

        
        
    }
    
    static testMethod void testpullDataFromParentCase(){
        Case c = createCase(true);
       
         Case caseChild = createCase(true);
        RecordType rtype = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'PGi_Client_External_Support'];
        caseChild.ParentId = c.Id;
        caseChild.RecordTypeId = rtype.Id;
        UPDATE caseChild;
        
    
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'PGi_Parent_Ticket_NOC'];
        c.RecordTypeId = rt.Id;
        c.Status = 'Closed';
        c.Priority = '1 - Critical';
        c.Total_Paused_Time__c = 2.0; 
        c.Tracking_Root_Category__c = 'Application';
        c.Tracking_Root_Cause__c = '3rd Party Carrier';
        c.Tracking_Root_Issue__c = 'AAPT';
       
        update c;
        c = requery(c);
        
        
        //system.assert(c.OwnerId != originalOwnerId);
        //system.assert(c.OwnerId == qList[1].QueueId);
        
       
        
        Case ParentCase =createCase(true);
       Case caseChild2 = createCase(true);
        RecordType rectype = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'PGi_Client_External_Support'];
        caseChild2.ParentId = ParentCase.Id;
        caseChild2.RecordTypeId = rectype.Id;
        UPDATE caseChild2; 
    }
    
    
    static testMethod void teststampCaseCountdownFields(){
        Case c = createCase(true);
        Id originalOwnerId = c.OwnerId;
        Id recordTypeId = null;
        
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'PGi_Parent_Ticket_NOC'];
        c.RecordTypeId = rt.Id;
        c.Status = 'Closed';
        c.Priority = '4 - Low';
        c.Total_Paused_Time__c = 2.0; 
        update c;
        c = requery(c);
        
        //system.assert(c.OwnerId != originalOwnerId);
        //system.assert(c.OwnerId == qList[1].QueueId);
        
        Case caseChild = createCase(true);
        RecordType rtype = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'PGi_Client_External_Support'];
        
        caseChild.Priority = '5 - No Impact/Info';
        caseChild.RecordTypeId = rtype.Id;
        
        UPDATE caseChild;
        caseChild = requery(caseChild);
        
        Case caseChild2 = createCase(true);
        RecordType rectype = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'PGi_Client_External_Support'];
        
        caseChild2.Priority = '5 - No Impact/Info';
        caseChild2.RecordTypeId = rectype.Id;
        UPDATE caseChild2;
        caseChild2 = requery(caseChild2);
         
          Case caseChild4 = createCase(true);        
        caseChild4.Priority = '2 - High';
        caseChild4.RecordTypeId = rectype.Id;
        UPDATE caseChild4;
        //caseChild2 = requery(caseChild2); 
        
        Case caseChild3 = createCase(true);
        caseChild3.Priority = 'none';
        caseChild3.RecordTypeId = rectype.Id;
        UPDATE caseChild3;
       
       
       // caseChild3 = requery(caseChild3);
        
    }
    static testMethod void testsetUrgencyLevel(){
        PGi_Client__c PGIObj = new PGi_Client__c();
        PGIObj.Red_Flag_Date__c = date.newInstance(2019, 10, 15);
        INSERT PGIObj;
        
        PGi_Entity__c EntityObj = new PGi_Entity__c();
        INSERT EntityObj;
        
        PGi_Company__c	PgiCompany = new PGi_Company__c	();
        PgiCompany.Red_Flag_Date__c = date.newInstance(2019, 10, 15);
        PgiCompany.Status_Level__c = 'B';
        PgiCompany.PGi_Entity_ID__c =  '90370';
        Insert PgiCompany; 
        
        
        PGi_Company__c	PgiCompanyObj = new PGi_Company__c	();
        PgiCompanyObj.Red_Flag_Date__c = null;
        PgiCompanyObj.Status_Level__c = 'P';
        
        Insert PgiCompanyObj; 
        
        Case c = createCase(true);
        
        Id originalOwnerId = c.OwnerId;
        Id recordTypeId = null;
        
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'PGi_Client_External_Support'];
        c.RecordTypeId = rt.Id;
        c.PGI_Client__c = PGIObj.Id;
        
        update c;
        c = requery(c);
        
        Case cobj = createCase(true);
        cobj.RecordTypeId = rt.Id;
        cobj.PGi_Company__c = PgiCompanyObj.Id;
        
        update cobj;
        //c = requery(c);
        
        Case cobject = createCase(true);
        cobject.RecordTypeId = rt.Id;
        cobject.PGi_Company__c = PgiCompany.Id; 
        
        UPDATE cobject;
        
      Case CaseObject = [SELECT ID,Urgency_Level__c FROM Case WHERE PGi_Company__c =:PgiCompanyObj.Id];
      System.assertEquals(CaseObject.Urgency_Level__c, 'Medium');
    }
    
    static testMethod void pgiIncidentReviewUpdates(){
        PGi_Company__c ObjPGI = new PGi_Company__c();
        INSERT ObjPGI;
        
        Case ParentCase = createCase(true);
        Case objCase = createCase(true);
        objCase.ParentId = ParentCase.Id;
        UPDATE ParentCase;
        objCase = requery(objCase);
        
        Case c = createCase(false);
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'PGi_Incident_Case_Review'];
        c.RecordTypeId = rt.Id;
        c.PGi_Company__c = ObjPGI.Id;
        c.Customer_s_Case_Number_for_Review__c = objCase.Id ;
        // c.ParentId = objCase.Id ;
        //	c.Parent_Ticket_NOC__c = null; 
        INSERT c;
        c = requery(c);
        
        Case CaseChild = createCase(false);
        //  RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'PGi_Incident_Case_Review'];
        CaseChild.RecordTypeId = rt.Id;
        CaseChild.PGi_Company__c = ObjPGI.Id;
        CaseChild.Customer_s_Case_Number_for_Review__c = objCase.Id ;
        CaseChild.ParentId = objCase.Id ;
        //	CaseChild.Parent_Ticket_NOC__c = null; 
        INSERT CaseChild;
        c = requery(c);
        
    }
    static testMethod void pgiInternalSupportCaseClosedSurvey(){
        // EmailTemplate ET = new EmailTemplate();
        // ET.DeveloperName = 'PGi_Case_Internal_Support_Survey';
        //  INSERT ET;
        
        Case c = createCase(true);
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'PGi_Internal_Support'];
        c.RecordTypeId = rt.Id;
        c.Status = 'Closed';
        //c.ServiceNow_System_ID__c = null ;
        UPDATE c;
        c = requery(c);
    }
    static testMethod void TestsetPriorityLevel(){
        Case objCase = createCase(true);
        objCase.Urgency_Level__c = 'High';
        objCase.Impact_Level__c = 'High';
        Update objCase;
        
        Case objCase1 = createCase(true);
        objCase1.Urgency_Level__c = 'High';
        objCase1.Impact_Level__c = 'Low';
        Update objCase1;
        
        Case objCase2 = createCase(true);
        objCase2.Urgency_Level__c = 'Low';
        objCase2.Impact_Level__c = 'Medium';
        Update objCase2;
        
        Case objCase4 = createCase(true);
        objCase2.Urgency_Level__c = 'High';
        objCase2.Impact_Level__c = 'Medium';
        Update objCase2;
        
        Case objCase3 = createCase(true);
        objCase3.Impact_Level__c = 'No Impact';
        Update objCase3;
        
        Case CaseObject = [SELECT Id, Priority FROM Case WHERE Id =: objCase.Id];
        System.assertEquals(CaseObject.Priority, '1 - Critical');
    }
    
    static testMethod void TestsetpgiOLAdetails(){
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        User u = PGITestUtilities.getTestUser();
        insert u;
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
        insert testQueue; 
        System.runAs(u){
             
      
            RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'PGi_Parent_Ticket_NOC'];
            Case objCase1 = createCase(true);
        	objCase1.OwnerId = testGroup.Id;
            objCase1.Status = 'Resolved';
            objCase1.RecordTypeId = rt.Id;
            objCase1.Service_Restored__c = false;
            UPDATE objCase1;
            Case objCase2 = createCase(true);
            objCase1.Status = 'Resolved';
            objCase1.RecordTypeId = rt.Id;
            objCase1.Service_Restored__c = true;
            UPDATE objCase2;
        }
        
        
    }
    static testMethod void TestzendeskProfileMap(){
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Admin API Only'].Id,
            LastName = 'last',
            Email = 'test@salesforce.com',
            Username = 'test@abc.org' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            EmployeeNumber='12345'
            
        );
        insert u;
        System.runAs(u){
            Case objCase2 = createCase(true);
            RecordType zendeskRT = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'PGi_Client_External_Support'];
            objCase2.RecordTypeId = zendeskRT.Id;
            objCase2.Status = 'New';
            objCase2.ZD_Source__c = 'Mail';
            objCase2.Service_Restored__c = true;
            Update objCase2;
            
            Case objCase3 = createCase(true);
            objCase3.RecordTypeId = zendeskRT.Id;
            objCase3.Status = 'New';
            objCase3.ZD_Source__c = 'Web Form';
            Update objCase3;
            
            Case objCase4 = createCase(true);
            objCase4.RecordTypeId = zendeskRT.Id;
            objCase4.Status = 'New';
            objCase4.ZD_Source__c = 'Chat';
            Update objCase4;
            
            Case CaseObject = [SELECT Id,Origin FROM Case WHERE Id =: objCase3.Id];
            System.assertEquals(CaseObject.Origin,'Web Ticket'); 
            RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'PGi_Client_External_Support'];
            
            
            Case objCase5 = createCase(true);
            objCase5.RecordTypeId = rt.Id;
            objCase5.ZD_Source__c = 'Open';
            Update objCase5;
            
            Case objCase6 = createCase(true);
            objCase6.RecordTypeId = rt.Id;
            objCase6.ZD_Source__c = 'Pending';
            Update objCase6;
            
            /*Case objCase7 = createCase(true);
            objCase7.RecordTypeId = rt.Id;
            objCase7.ZD_Source__c = 'Solved';
            objCase7.Assigned_To__c = u.Id;
            Update objCase7;*/
            
            CaseObject = [SELECT Id,Status FROM Case WHERE Id =: objCase5.Id];
            System.assertEquals(CaseObject.Status,'In Progress');
        }
        
        
        
       
        
    }
    static testMethod void testNotInZendeskProfileMap(){
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'PGi Sales Mgr'].Id,
            LastName = 'last',
            Email = 'test@salesforce.com',
            Username = 'test@abc.org' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            EmployeeNumber='12345'
            
        );
        insert u;
        // Case objCase5 = createCase(true);
        System.runAs(u){
            Case objCase = createCase(false);
            objCase.Subject = 'Test Case';
            objCase.Status = 'Accepted';
            INSERT objCase;
            
            Case objCase1 = createCase(false);
            objCase1.Subject = 'Test Case1';
            objCase1.Status = 'Accepted';
            INSERT objCase1;
            System.debug('The Case >>>>>>>>>>> '+ objCase1);
            Case objCase2 = createCase(false);
            objCase2.Subject = 'Test Case2';
            objCase2.Status = 'Accepted';
            INSERT objCase2;
            RecordType NotInZendeskRT = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'PGi_Client_External_Support'];
            /*Case ObjCse = [SELECT Id FROM CASE WHERE Id =:objCase.Id];
            ObjCse.RecordTypeId = NotInZendeskRT.Id;
            ObjCse.ZD_Source__c = 'Mail';
            UPDATE ObjCse;
            
            Case ObjCseTest1 = [SELECT Id FROM CASE WHERE Id =:objCase1.Id LIMIT 1];
            ObjCseTest1.RecordTypeId = NotInZendeskRT.Id;
            ObjCseTest1.ZD_Source__c = 'Web Form';
            UPDATE ObjCseTest1;
            
            Case ObjCseTest2 = [SELECT Id FROM CASE WHERE Id =:objCase2.Id LIMIT 1];
            ObjCseTest2.RecordTypeId = NotInZendeskRT.Id;
            ObjCseTest2.ZD_Source__c = 'Chat';
            UPDATE ObjCseTest2;
            
            /*Case CaseObject = [SELECT Id,Origin FROM Case WHERE Id =: ObjCse.Id];
            System.assertEquals(CaseObject.Origin,'Email');*/
        }
        

    }
   
    static testMethod void testpgiUpdateEmailChildCases(){
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Inbound_Email_Support'];
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'test@salesforce.com',
            Username = 'test@abc.org' + System.currentTimeMillis(),
            Title = 'title',
            Alias = 'alias',
            CompanyName = 'TEST',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            EmployeeNumber='12345'
            
        );
        INSERT u;
     
        // Case objCase5 = createCase(true);
        System.runAs(u) {
            Case objCase = createCase(false);
            objCase.RecordTypeId = rt.Id;        
            INSERT objCase;
            Case objChildCase = createCase(true);
            objChildCase.ParentId = objCase.Id; 
            UPDATE objChildCase;
            objCase.Assigned_To__c = u.Id;
            UPDATE objCase;
            
            
            Case objEmailParentCase = createCase(FALSE);
            objEmailParentCase.Status = 'Closed';
            objEmailParentCase.RecordTypeId = rt.Id;
            INSERT objEmailParentCase;
            Case objEmailChildCase = createCase(true);
            objEmailChildCase.ParentId = objEmailParentCase.Id;
            UPDATE objEmailChildCase; 
            objEmailParentCase.Case_Resolution_Notes__c ='test';
            objEmailParentCase.Status = 'Closed';
            UPDATE objEmailParentCase;
            
            Case CaseObject = [SELECT Id,Assigned_To__c FROM Case WHERE Id =: objChildCase.Id];
            System.assertEquals(CaseObject.Assigned_To__c, objCase.Assigned_To__c);
        }
        
    }
    static testMethod void testemailToCaseFindParentCase(){
        Profile p = [Select Id from Profile where Name='PGi Legal'];
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ',
                         Email = 'Example@pgi.com', 
                         Username = 'Example1@'+DateTime.now().getTime()+'pgi.com', 
                         EmailEncodingKey = 'UTF-8', 
                         Alias = 'Test', 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US',
                         EmployeeNumber='12345',
                         ProfileId = p.Id
                        ); 
        insert uu;
        System.runAs(uu){
            PGITestUtilities.disableSalesWings();
            Account ac = new Account();
            ac.Name='Ac1';
            ac.BillingCountry='India';
            ac.BillingStreet='xyz';
            insert ac;
            
            Contact con=new Contact();
            con.AccountId=ac.Id;
            con.LastName= 'test';
            con.FirstName='test';
            con.Phone= '9887678558';
            con.Email= 'hsk@test.com';
            insert con;
            
            Case caseObj1 = new Case();
            caseObj1.ContactId = con.Id;
            caseObj1.AccountId = ac.Id;
            caseObj1.Status = 'Working';
            caseObj1.Origin = 'Phone';
            caseObj1.Average_SLA_Time__c='12:00';
            caseObj1.Average_SLA_In_Minutes__c=null;  
            caseObj1.Subject='Test';
            caseObj1.SuppliedEmail='Vijay@raagviTech.com';
            insert caseObj1;

            EmailMessage objEmailMsg = new EmailMessage();
            objEmailMsg.ParentId = caseObj1.Id;
            objEmailMsg.Subject = 'Test';
            objEmailMsg.ToAddress = 'Ecample@ex.com';
            objEmailMsg.BccAddress = 'Ecample1@ex.com';
            objEmailMsg.CcAddress = 'Ecample1@ex.com';
            objEmailMsg.FromAddress = 'noreply@pgi.com';
            objEmailMsg.htmlBody = 'This has body';
            objEmailMsg.TextBody = 'This has body of text';    
            objEmailMsg.MessageDate = datetime.now();
            objEmailMsg.CreatedById=uu.Id;
            insert objEmailMsg;
        }
    }
}