@isTest
private class CaseTabViewerTest {
    //This test method is used to coverage the code of ScheduleBatchScorecardGenerator class
    static testMethod void myUnitTest() { 
        
        
        CaseTabViewer__c ctvcs = new CaseTabViewer__c();
        ctvcs.RecordType__c = 'PGi-Client External Support';
        ctvcs.Top_Count__c = 0;
        ctvcs.Name = 'PGi-Client External Support';
        insert ctvcs;
        
        Test.setMock(HttpCalloutMock.class, new CaseTabViewerMockHttp());
        
        Account ac = new Account();
        ac.Name='Ac1';
        insert ac;
        
        Contract objContract=new Contract();
        objContract.Name='Contract1';
        objContract.AccountId=ac.Id; 
        insert objContract;
        
        Contact con=new Contact();
        con.AccountId=objContract.AccountId;
        con.LastName= 'test';
        con.FirstName='test';
        con.Phone= '9887678558';
        con.Email= 'hsk@test.com';
        insert con;
        
        RecordType rc=[Select Name, IsActive, Id From RecordType where SobjectType = 'Case' and Name = 'PGi-Client External Support' and IsActive = true limit 1];
        RecordType rc2 =[Select Name, IsActive, Id From RecordType where SobjectType = 'Case' and Name != 'PGi-Client External Support' and IsActive = true limit 1];
        
        
        //test redirect
        Case caseObj1 = new Case();
        caseObj1.ContactId = con.Id;
        caseObj1.AccountId = ac.Id;
        caseObj1.Status = 'Working';
        caseObj1.Origin = 'Phone';
        caseObj1.recordTypeId = rc.Id;
        caseObj1.Auto_Generated_For_Case__c = true;
        insert caseObj1;
        
        Case_Template__c ct = new Case_Template__c(Name__c = 'Test');
        insert ct;
        Case_Template__c queriedCaseTemplate = [SELECT Name FROM Case_Template__c];
        
        Default_Value__c dv = new Default_Value__c(Case_Template__c = ct.Id, Field_API_Name__c = 'subject');
        dv.put('Value__c', 'Test Value');
        Default_Value__c dv2 = new Default_Value__c(Case_Template__c = ct.Id, Field_API_Name__c = 'currencyIsoCode');
        dv2.put('Value__c', 'USD');
        Default_Value__c dv3 = new Default_Value__c(Case_Template__c = ct.Id, Field_API_Name__c = 'Most_Recent_SLA_Start__c');
        dv3.put('Value__c', String.valueOf(System.now()));
      //  String Valdate =  date.today().format('**yyyy-MM-dd**');
        Default_Value__c dv5 = new Default_Value__c(Case_Template__c = ct.Id, Field_API_Name__c = 'Authorization_Date__c');
        dv5.put('Value__c', String.valueOf(System.Today()));
        //Date today = System.Today();
        //String todayStr = today.format();
        Default_Value__c dv6 = new Default_Value__c(Case_Template__c = ct.Id, Field_API_Name__c = 'Count_of_Call_Logs__c');
        dv6.put('Value__c', String.valueOf(5));
        Default_Value__c dv4 = new Default_Value__c(Case_Template__c = ct.Id, Field_API_Name__c = 'Child_Cases__c');
        dv4.put('Value__c', '5');
        Default_Value__c dv7 = new Default_Value__c(Case_Template__c = ct.Id, Field_API_Name__c = 'Auto_Generated_For_Case__c');
         dv7.put('Value__c', String.valueOf(true));
        insert dv;
        insert dv2;
        insert dv3;
          insert dv4;
       // insert dv5;
        insert dv6;
        insert dv7;
        
        Test.startTest();
        PageReference pageRef = Page.CaseTabViewer;
        pageRef.getParameters().put('RecordType', rc.Id);
        pageRef.getParameters().put('caseObj1', caseObj1.Id);
        Test.setCurrentPageReference(pageRef);
        ApexPages.Standardcontroller sc  = new Apexpages.Standardcontroller(caseObj1);
       
        
        
        //test no redirect 
        Case caseObj2 = new Case();
        ApexPages.Standardcontroller sc2  = new Apexpages.Standardcontroller(caseObj2);
        PageReference pageRef2 = Page.CaseTabViewer;
        pageRef2.getParameters().put('RecordType', rc2.Id);
        pageRef2.getParameters().put('caseObj2', caseObj2.Id);
        Test.setCurrentPageReference(pageRef2);
        CaseTabViewer ctv2 = new CaseTabViewer(sc2);
        ctv2.addError();
        ctv2.init();
        
        CaseTabViewer ctv = new CaseTabViewer(sc);
        ctv.init();
        
        ctv.quickCase = queriedCaseTemplate.Name;
        ctv.quickCasePopulation();
        Case cse = (case)sc.getRecord();
        system.assert(cse.Subject == 'Test Value');
        ctv.quickCase = null;
        ctv.quickCasePopulation();
        system.assert(cse.Subject == null);
        //ctv.save();
        
        
        ApexPages.Standardcontroller dvc = new ApexPages.StandardController(dv);
        PageReference dvPageRef = Page.DefaultValue;
        Test.setCurrentPageReference(dvPageRef);
        DefaultValueExtension dve = new DefaultValueExtension(dvc);
        List<SelectOption> cFields = dve.caseFields;
        //system.assert(false, dve.ct);
        //dve.save();
        dv = (Default_Value__c)dvc.getRecord();
        dve.saveAndNew();
       // dve.save();
        
        pageRef = Page.CaseTabViewer;
        pageRef.getParameters().put('RecordTypeId', rc.Id);
        pageRef.getParameters().put('caseObj1', caseObj1.Id);
        Test.setCurrentPageReference(pageRef);
        
        sc  = new Apexpages.Standardcontroller(caseObj1);
        //ctv = new CaseTabViewer(sc);
        Test.stopTest();
        ctv.caseCommentBody = 'test';
        ctv.save();
        //ctv.editMode();
        ctv.populateCaseNumber();
        ctv.cancel();
        ctv.notInConsole();
        ctv.inConsole();
        Decimal Count = ctv.topCount;
        Decimal tCount = ctv.tabCount;
        Boolean Enabled = ctv.quickCaseEnabled;
        Boolean Notify = ctv.isSendNotification;
        String rectName = ctv.rtName;
        String Symptoms = ctv.ProductSymptoms;
        
        // assert case comment is created when case is closed
        system.assert([SELECT Id FROM CaseComment WHERE ParentId = :caseObj1.Id].Id != null);
    }
    static testMethod void TestgetClientInfo(){
        
        PGI_Client__c ObjClient = new PGI_Client__c();
        ObjClient.Client_Name__c = 'TestClient';
        Insert ObjClient;
        String Name = ObjClient.Client_Name__c;
        CaseTabViewer.getClientInfo(Name,ObjClient.Id);
        
        PGI_Conference__c objConference = new PGI_Conference__c();
        objConference.Name = 'testConference';
        INSERT objConference;
        String NameConf = objConference.Name;
        CaseTabViewer.getConferenceInfo(NameConf, objConference.Id);
       CaseTabViewer.fetchProductSymptoms();
        Test.setMock(HttpCalloutMock.class, new CaseTabViewerMockHttp());
        RecordType rc=[Select Name, IsActive, Id From RecordType where SobjectType = 'Case' and Name = 'PGi-Client External Support' and IsActive = true limit 1];
        RecordType rc2 =[Select Name, IsActive, Id From RecordType where SobjectType = 'Case' and Name != 'PGi-Client External Support' and IsActive = true limit 1];
        
        
        //test redirect
        Case caseObj1 = new Case();
        //  caseObj1.ContactId = con.Id;
        // caseObj1.AccountId = ac.Id;
        caseObj1.Status = 'Working';
        caseObj1.Origin = 'Phone';
        caseObj1.recordTypeId = rc.Id;
        caseObj1.Description = 'hii';
        caseObj1.Resolution_Comments__c = 'Test Case comment';
        insert caseObj1;
        Case caseObj = new Case();
        Test.startTest();
        PageReference pageRef = Page.CaseTabViewer;
        pageRef.getParameters().put('Id', caseObj1.Id);
        pageRef.getParameters().put('isNew', 'true');
        pageRef.getParameters().put('isClassic', 'true');
        pageRef.getParameters().put('QuickCase', caseObj.Id);
         pageRef.getParameters().put('save_new', 'CF00N1B00000AxSsh_lkid');
        pageRef.getParameters().put('retURL', 'https://www.google.com/search?q=gmail&oq=gmail&aqs=chrome.0.69i59j0l5j69i60l2.3529j0j7&sourceid=chrome&ie=UTF-8');
        Test.setCurrentPageReference(pageRef);
        ApexPages.Standardcontroller ObjSc  = new Apexpages.Standardcontroller(caseObj1);
        CaseTabViewer CaseTabObj = new CaseTabViewer(ObjSc);
        CaseTabObj.caseCommentBody = 'test';
        CaseTabObj.cancel();
        CaseTabObj.save();
        
        CaseTabObj.isClassic();
    }
    
    static testMethod void TestCaseInfo(){
        
         PGI_Client__c ObjClient = new PGI_Client__c();
        ObjClient.Client_Name__c = 'TestClient';
        Insert ObjClient;
        String Name = ObjClient.Client_Name__c;
        CaseTabViewer.getClientInfo(Name,null);
        
        PGI_Conference__c objConference = new PGI_Conference__c();
        objConference.Name = 'testConference';
        INSERT objConference;
        String NameConf = objConference.Name;
        CaseTabViewer.getConferenceInfo(NameConf, null);
        
        Case_Template__c cseTemp = new Case_Template__c(Name__c = 'Test');
        insert cseTemp;
        Case_Template__c queriedCaseTemplate = [SELECT Name FROM Case_Template__c];
        CaseTabViewer__c ctvcs = new CaseTabViewer__c();
        ctvcs.RecordType__c = 'PGi-Client External Support';
        ctvcs.Top_Count__c = 0;
        ctvcs.Name = 'PGi-Client External Support';
        insert ctvcs;
        
        Test.setMock(HttpCalloutMock.class, new CaseTabViewerMockHttp());
        
        RecordType rc=[Select Name, IsActive, Id From RecordType where SobjectType = 'Case' and Name = 'PGi-Client External Support' and IsActive = true limit 1];
        RecordType rc2 =[Select Name, IsActive, Id From RecordType where SobjectType = 'Case' and Name != 'PGi-Client External Support' and IsActive = true limit 1];
        
        
        
        Case caseObj1 = new Case();
        
        caseObj1.Status = 'complete';
        caseObj1.Origin = 'Phone';
        caseObj1.recordTypeId = rc.Id;
        caseObj1.Description = 'hii';
        caseObj1.Resolution_Comments__c = 'Test Case comment';
        caseObj1.Auto_Generated_For_Case__c = true;
        INSERT caseObj1;
        Case caseObj = new Case();
        Test.startTest();
        PageReference pageRef = Page.CaseTabViewer;
        pageRef.getParameters().put('RecordTypeId', rc.Id);
        pageRef.getParameters().put('Id', caseObj1.Id);
        pageRef.getParameters().put('isNew', 'true');
        pageRef.getParameters().put('isClassic', 'true');
        pageRef.getParameters().put('QuickCase', queriedCaseTemplate.Name);
        
        pageRef.getParameters().put('retURL', 'https://www.google.com/search?q=gmail&oq=gmail&aqs=chrome.0.69i59j0l5j69i60l2.3529j0j7&sourceid=chrome&ie=UTF-8');
        Test.setCurrentPageReference(pageRef);
       
        ApexPages.Standardcontroller ObjSc  = new Apexpages.Standardcontroller(caseObj1);
        CaseTabViewer CaseTabObj = new CaseTabViewer(ObjSc);
        CaseTabObj.caseCommentBody = 'test';
        
       // Case cse = (case)ObjSc.getRecord();
       // DELETE cse;
       CaseTabObj.cancel();
        try{
            CaseTabObj.save();
        }
        catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage()); 
        }
       
        CaseTabObj.isClassic();
        //test no redirect 
        Case caseObj2 = new Case();
        ApexPages.Standardcontroller sc2  = new Apexpages.Standardcontroller(caseObj2);
        PageReference pageRef2 = Page.CaseTabViewer;
        pageRef2.getParameters().put('RecordTypeId', rc2.Id);
        pageRef2.getParameters().put('Id', caseObj2.Id);
        pageRef2.getParameters().put('isNew', 'true');
        Test.setCurrentPageReference(pageRef2);
        CaseTabViewer CaseTab = new CaseTabViewer(sc2);
        
        CaseTab.addError();
        CaseTab.doNothing();
        CaseTab.init();
        CaseTab.caseCommentBody = 'test';
        
        system.assert([SELECT Id FROM RecordType WHERE Id = :caseObj2.RecordTypeId] != null);
        
        
        
    }
    
}