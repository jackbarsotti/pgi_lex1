@isTest(seeAllData = false)
public class PIDRTriggerHandlerTest {
    
    public static List<PIDR__c> PIDRListtoInsert;
    public static Id pidrCustomerRT = Schema.SObjectType.PIDR__c.getRecordTypeInfosByName().get('Customer Request Record Type').getRecordTypeId();
    public static Id pidrEmployeeRT = Schema.SObjectType.PIDR__c.getRecordTypeInfosByName().get('Employee Request Record Type').getRecordTypeId();
    
    @testSetup static void setup() {

        Profile p = [Select Id from Profile where Name='System Administrator'];
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ',
                         Email = 'test@pgi.com', 
                         Username = 'tes'+DateTime.now().getTime()+'t@pgi.com', 
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
            
            List<PGi_Company__c> pgiCompanyList = new List<PGi_Company__c>{new PGI_Company__c(Name='test01', Region__c='EMEA'),
                new PGI_Company__c(Name='test02', Region__c='USA'),
                new PGI_Company__c(Name='test03', Region__c='APAC'),
                new PGI_Company__c(Name='test04', Region__c='EMEA'),
                new PGI_Company__c(Name='test05', Region__c='NA')};
                    INSERT pgiCompanyList;
            
            Locations__c empLoc = new Locations__c(City__c='abc',Country__c='xyz'   ,Current_assigned_headcount__c=2,Facility_Access_control_type__c='Escort Only',
                                                   Facility_Entrance_has_camera__c='Yes',Facility_Guard_Hours__c='24 hrs/day x 365 days/yr',Facility_Usage_Select_all_that_apply__c='Data Center (Unmanned)',
                                                   Maximum_worker_capacity__c=5,Rack_Room_Access_control_type__c='Escort only',Rack_Room_Entrance_has_camera__c='Yes - monitored by personnel',Region__c='APAC',
                                                   State_Province__c='yyyyy',Status__c='Active',Street__c='abc',Zip_Postal_Code__c='abcdef' );
            INSERT empLoc;
            PIDR__c pidr = new PIDR__c(RecordTypeId=pidrCustomerRT, Status__c='closed', PGi_Company__c=pgiCompanyList[0].Id,Data_Type__c='Account',Data_Details__c='date_02',
                                       First_Name__c='Jon', Last_Name__c='lincon', Request_Type__c='Port', Employee_Status__c='Current', Email_Address__c='test02@gmail.com', Phone__c='7418529635');		
            INSERT pidr;  
        }
    }
    public static void getcase(){
        User u =[SELECT Id from User Where Email = 'test@pgi.com'];
        System.runAs(u){
            PIDR__c pidro = [SELECT Id,Status__c FROM PIDR__c WHERE Status__c ='closed'];  
            Account ac = new Account(Name='Ac1',BillingCountry='India',BillingStreet='xyz');
            insert ac;
            Contact con=new Contact(AccountId=ac.Id,LastName= 'test',FirstName='test',Phone= '9887678558',Email= 'hsk@test.com');
            insert con;
            Case caseObj1 = new Case(ContactId = con.Id,AccountId = ac.Id,Status = 'Working',Origin = 'Phone',Personal_Information_Data_Request__c=pidro.Id);
            insert caseObj1;
            Case caseObj = new Case(ContactId = con.Id,AccountId = ac.Id,Status = 'Working',Origin = 'Phone',Personal_Information_Data_Request__c=pidro.Id);
            insert caseObj; 
        }
    }
    @IsTest 
    private static void validateQueues(){
        Set<String> allQueues = new Set<String>();
        allQueues.addAll(PIDRTriggerHandler.nameToGroupforCustomersMap.keySet());
        allQueues.addAll(PIDRTriggerHandler.nameToGroupforEmployeesMap.keySet());
        allQueues.addAll(PIDRTriggerHandler.nameToGroupforCaseOwnerIdMap.keySet());
        List<QueueSObject> sObjectQueueList = [SELECT Id, Queue.Name FROM QueueSObject WHERE SobjectType = 'Case' AND Queue.Name IN: allQueues];
        for(QueueSobject q: sObjectQueueList) {
            allQueues.remove(q.Queue.Name);
        }
        System.assert(allQueues.isEmpty(), 'Missing Queue:' + allQueues);
    }
    @IsTest static void testPIDRTrigger(){
        User u =[SELECT Id from User Where Email = 'test@pgi.com'];
        System.runAs(u){
            Locations__c location = [SELECT City__c,Status__c FROM Locations__c];
            PIDRListtoInsert = new List<PIDR__c>{
                new PIDR__c(RecordTypeId=pidrEmployeeRT, Status__c='Approved',Employee_Location__c=location.Id, 
                            First_Name__c='test_FN01', Last_Name__c='test_LN01', Request_Type__c='Port', Employee_Status__c='Current', Email_Address__c='test01@gmail.com'),
                    new PIDR__c(RecordTypeId=pidrEmployeeRT, Status__c='Approved', 
                                First_Name__c='test_FN02', Last_Name__c='test_LN02', Request_Type__c='Port', Employee_Status__c='Former', Phone__c='9879878529')};
                                    
                                    INSERT PIDRListtoInsert;    
        }
    }
    @isTest static void test1(){
        User u =[SELECT Id from User Where Email = 'test@pgi.com'];
        System.runAs(u){
            //List<Group> grpcusLst =[Select Id,Name From Group Where Type='Regular'];
            //List<Group> grpCaseLst =[Select Id,Name From Group Where Type='Queue'];
            List<PGi_Company__c> pgiCompanyList = [SELECT Id,Name, Region__c FROM PGi_Company__c];
            
            PIDR__c pidr = new PIDR__c(RecordTypeId=pidrCustomerRT, Status__c='Approved', PGi_Company__c=pgiCompanyList[0].Id,Data_Type__c='Account',Data_Details__c='date_02',
                                       First_Name__c='test_FN03', Last_Name__c='test_LN03', Request_Type__c='Port', Employee_Status__c='Current', Email_Address__c='test02@gmail.com', Phone__c='7418529635');
            
            INSERT pidr;
            Group ObjGroup =[Select Id,Name from group where Type='Queue' and Name='PGi-Case-EU-Branding&Conf Email' limit 1];
        List<case> lstcase = [Select Id,OwnerId from Case where OwnerId =: ObjGroup.Id];
        System.assertEquals(ObjGroup.Id, lstcase[0].OwnerId);
             
        }
    }
    @IsTest static void test2() {
        User u =[SELECT Id from User Where Email = 'test@pgi.com'];
        System.runAs(u){
            List<PGi_Company__c> pgiCompanyList = [SELECT Id,Name, Region__c FROM PGi_Company__c];
            
            PIDRListtoInsert = new List<PIDR__c>{
                new PIDR__c(RecordTypeId=pidrCustomerRT, Status__c='Approved',PGi_Company__c=pgiCompanyList[1].Id,Data_Type__c='All',Data_Details__c='Testing', 
                            First_Name__c='test_FN04', Last_Name__c='test_LN04', Request_Type__c='Port', Employee_Status__c='Current', Email_Address__c='test03@gmail.com', Phone__c='9638527415'),
                    new PIDR__c(RecordTypeId=pidrEmployeeRT, Status__c='Approved',PGi_Company__c=pgiCompanyList[2].Id,Data_Type__c='All',Data_Details__c='Testing', 
                                First_Name__c='test_FN05', Last_Name__c='test_LN05', Request_Type__c='Port', Employee_Status__c='Current', Email_Address__c='test03@gmail.com', Phone__c='9638527415')
                    };
                        INSERT PIDRListtoInsert;
            List<String> lstGroupName = new List<String>{'PGi-Case-AP-Facilities'};
                List<Group> lstGroup = [Select Id,Name from group where Type='Queue' AND Name IN :lstGroupName];
            List<case> lstcase = [Select Id,OwnerId from Case where OwnerId =: lstGroup[0].Id];
            System.assertEquals(lstGroup[0].Id, lstcase[0].OwnerId);
        }   
    }
    @isTest static void test3() {
        User u =[SELECT Id from User Where Email = 'test@pgi.com'];
        System.runAs(u){
            List<PGi_Company__c> pgiCompanyList = [SELECT Id,Name, Region__c FROM PGi_Company__c];
            
            PIDRListtoInsert = new List<PIDR__c>{
                new PIDR__c(RecordTypeId=pidrEmployeeRT, Status__c='Approved',PGi_Company__c=pgiCompanyList[3].Id,Data_Type__c='All',Data_Details__c='Testing', 
                            First_Name__c='test_FN06', Last_Name__c='test_LN06', Request_Type__c='Port', Employee_Status__c='Current', Email_Address__c='test03@gmail.com', Phone__c='9638527415'),
                    new PIDR__c(RecordTypeId=pidrEmployeeRT, Status__c='Approved',PGi_Company__c=pgiCompanyList[4].Id,Data_Type__c='All',Data_Details__c='Testing', 
                                First_Name__c='test_FN07', Last_Name__c='test_LN07', Request_Type__c='Port', Employee_Status__c='Current', Email_Address__c='test03@gmail.com', Phone__c='9638527415')};
                                    INSERT PIDRListtoInsert;
            List<String> lstGroupName = new List<String>{'PGi-Case-EU-Employee Serv','PGi-Case-EU-Facilities','PGi-Case-NA-Facilities'};
                List<Group> lstGroup = [Select Id,Name from group where Type='Queue' AND Name IN :lstGroupName]; 
            List<case> lstcase = [Select Id,OwnerId from Case where OwnerId =: lstGroup[0].Id];
            System.assertEquals(lstGroup[0].Id, lstcase[0].OwnerId);
            List<case> lstcase1 = [Select Id,OwnerId from Case where OwnerId =: lstGroup[1].Id];
            System.assertEquals(lstGroup[1].Id, lstcase1[0].OwnerId);  
            List<case> lstcase2 = [Select Id,OwnerId from Case where OwnerId =: lstGroup[2].Id];
            System.assertEquals(lstGroup[2].Id, lstcase2[0].OwnerId);
        }
    }
    @isTest static void testUpdate(){        
        User u =[SELECT Id from User Where Email = 'test@pgi.com'];
        System.runAs(u){
            List<PGi_Company__c> pgiCompanyList = [SELECT Id,Name FROM PGi_Company__c];
            PIDR__c pidro = [SELECT Id,Status__c FROM PIDR__c WHERE Status__c ='closed'];
            pidro.RecordTypeId=pidrCustomerRT;
            pidro.PGi_Company__c=pgiCompanyList[0].Id;
            pidro.Status__c = 'Approved';       
            UPDATE pidro;    
            Group ObjGroup =[Select Id,Name from group where Type='Queue' AND Name='PGi-Case-EU-Branding&Conf Email'];
            List<case> lstcase = [Select Id,OwnerId from Case where OwnerId =: ObjGroup.Id];
            System.assertEquals(ObjGroup.Id, lstcase[0].OwnerId); 
        }
    }
    @isTest static void testUpdate2()
    { 
        User u =[SELECT Id from User Where Email = 'test@pgi.com'];
        System.runAs(u){
            List<PGi_Company__c> pgiCompanyList = [SELECT Id,Name FROM PGi_Company__c];
            PIDR__c pidro = [SELECT Id,Status__c FROM PIDR__c WHERE Status__c ='closed'];
            pidro.RecordTypeId = pidrEmployeeRT;
            pidro.PGi_Company__c=pgiCompanyList[2].Id;
            pidro.Status__c = 'Approved';       
            UPDATE pidro;    
            Group ObjGroup =[Select Id,Name from group where Type='Queue' AND Name='PGi-Case-AP-Facilities'];
            List<case> lstcase = [Select Id,OwnerId from Case where OwnerId =: ObjGroup.Id];
            System.assertEquals(ObjGroup.Id, lstcase[0].OwnerId);
        }
    }
    @isTest static void testUpdate3()
    { 
        User u =[SELECT Id from User Where Email = 'test@pgi.com'];
        System.runAs(u){
            List<PGi_Company__c> pgiCompanyList = [SELECT Id,Name FROM PGi_Company__c];
            PIDR__c pidro = [SELECT Id,Status__c FROM PIDR__c WHERE Status__c ='closed'];
            pidro.RecordTypeId = pidrEmployeeRT;
            pidro.PGi_Company__c = pgiCompanyList[3].Id;
            pidro.Status__c = 'Approved';       
            UPDATE pidro;   
            List<String> lstGroupName = new List<String>{'PGi-Case-EU-Employee Serv','PGi-Case-EU-Facilities'};
                List<Group> lstGroup = [Select Id,Name from group where Type='Queue' AND Name IN :lstGroupName];
            List<case> lstcase = [Select Id,OwnerId from Case where OwnerId =: lstGroup[0].Id];
            System.assertEquals(lstGroup[0].Id, lstcase[0].OwnerId);
            List<case> lstcase1 = [Select Id,OwnerId from Case where OwnerId =: lstGroup[1].Id];
            System.assertEquals(lstGroup[1].Id, lstcase1[0].OwnerId);
        }
    }
    @isTest static void testUpdateCaseDuplicate()
    { 
        User u =[SELECT Id from User Where Email = 'test@pgi.com'];
        System.runAs(u){
            List<PGi_Company__c> pgiCompanyList = [SELECT Id,Name FROM PGi_Company__c];
            getcase();
            PIDR__c pidro = [SELECT Id,Status__c FROM PIDR__c WHERE Status__c ='closed'];
            pidro.RecordTypeId = pidrEmployeeRT;
            pidro.PGi_Company__c = pgiCompanyList[3].Id;
            pidro.Status__c = 'Approved';       
            UPDATE pidro;   
            List<String> lstGroupName = new List<String>{'PGi-Case-EU-Employee Serv','PGi-Case-EU-Facilities'};
                List<Group> lstGroup = [Select Id,Name from group where Type='Queue' AND Name IN :lstGroupName];
            List<case> lstcase = [Select Id,OwnerId from Case where OwnerId =: lstGroup[0].Id];
            System.assertEquals(0, lstcase.size());
            List<case> lstcase1 = [Select Id,OwnerId from Case where OwnerId =: lstGroup[1].Id];
            System.assertEquals(0, lstcase1.size());
        }
    }
    @isTest static void testUpdate4()
    { 
        User u =[SELECT Id from User Where Email = 'test@pgi.com'];
        System.runAs(u){
            List<PGi_Company__c> pgiCompanyList = [SELECT Id,Name FROM PGi_Company__c];
            PIDR__c pidro = [SELECT Id,Status__c FROM PIDR__c WHERE Status__c ='closed'];
            pidro.RecordTypeId = pidrEmployeeRT;
            pidro.PGi_Company__c = pgiCompanyList[4].Id;
            pidro.Status__c = 'Approved';       
            UPDATE pidro;     
            Group ObjGroup =[Select Id,Name from group where Type='Queue' AND Name='PGi-Case-NA-Facilities'];
            List<case> lstcase = [Select Id,OwnerId from Case where OwnerId =: ObjGroup.Id];
            System.assertEquals(ObjGroup.Id, lstcase[0].OwnerId);
        }  
    }
}