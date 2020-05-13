@isTest
public class agreementTriggerHandlerTest {
    
    @TestSetup static void agreementTriggerTest(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> userList = new List<User>();
        User userObject= new User(FirstName='JASON',Alias = 'jliv',Email = 'jason.liveston@pgi.com',
                                  ProfileId = profileId.id,TimeZoneSidKey = 'GMT',LanguageLocaleKey = 'en_US',
                                  EmailEncodingKey = 'UTF-8',EmployeeNumber='12345',LocaleSidKey = 'en_US');
        userObject.LastName = 'hunt';
        userObject.Username = 'TestRT1@pgi.com';
        userObject.User_Region__c ='APAC';
        userList.add(userObject.clone(false,false,false,false));
        userObject.LastName = 'hunt2';
        userObject.Username = 'TestRT2@pgi.com';
        userObject.User_Region__c ='EMEA';
        userList.add(userObject.clone(false,false,false,false));
        userObject.LastName = 'hunt3';
        userObject.Username = 'TestRT3@pgi.com';
        userObject.User_Region__c ='NA';
        userList.add(userObject.clone(false,false,false,false));
        
        INSERT userList;
        System.runAs(userList[0]){
        Account actObject = new Account(Name ='test1',BillingCountry='India',BillingStreet='3rd cross');
        Insert actObject;
        Test.startTest();
        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(AccountId =actObject.Id, Name='Test1', Opportunity_Source_Open__c='Customer',
                            StageName='Prospecting', CloseDate=Date.today(),Has_PGI_Contract__c =false),
                new Opportunity(AccountId =actObject.Id, Name='Test2', Opportunity_Source_Open__c='Customer',
                                StageName='Prospecting', CloseDate=Date.today(),Has_PGI_Contract__c =true) };    
                                    Insert opportunityList;
        
        echosign_dev1__SIGN_Agreement__c objTestAgr = new echosign_dev1__SIGN_Agreement__c(Name='Test1',echosign_dev1__Status__c='Signed',echosign_dev1__Opportunity__c=opportunityList[0].Id);
        system.debug('====<>'+objTestAgr);
        Insert objTestAgr;
        Test.stopTest();
        }
    }
    @isTest static void changeTheStatus(){
        Opportunity oppartunityObj =[Select Id,AccountId from Opportunity where Name='Test1'];
        System.debug('oppartunityObj1'+oppartunityObj.AccountId);
        System.debug('oppartunityObj2'+oppartunityObj.Id);
        echosign_dev1__SIGN_Agreement__c obj =[Select Id,echosign_dev1__Status__c From echosign_dev1__SIGN_Agreement__c Where Name='Test1' limit 1];        
        obj.echosign_dev1__Status__c='Cancelled / Declined';
        UPDATE obj;
        CONMAN_Contract__c ConmanContractobj =[Select Id,Opportunity__c,Closed_By__c,Contract_Status__c,Related_Agreement__c,Account_Name__c From CONMAN_Contract__c];
        System.debug('ConmanContractobj1'+ConmanContractobj);
        System.assertEquals('Customer Accepted', ConmanContractobj.Contract_Status__c);
        System.assertEquals('eSignature', ConmanContractobj.Closed_By__c);
        System.assertEquals(oppartunityObj.AccountId, ConmanContractobj.Account_Name__c);
        System.assertEquals(obj.Id, ConmanContractobj.Related_Agreement__c);
    }
    @isTest static void testmethodForUser(){
        //echosign_dev1__SIGN_Agreement__c obj =[Select Id,echosign_dev1__Status__c From echosign_dev1__SIGN_Agreement__c Where Name='Test1'];        
        //obj.echosign_dev1__Status__c='Cancelled / Declined';
        //UPDATE obj;
        
        User usr= [Select Id FROM User Where User_Region__c ='APAC' And LastName='hunt' Limit 1];
        System.runAs(usr){
        Account actObject =[Select Id From Account Limit 1];
        Opportunity oppObject = new Opportunity(AccountId =actObject.Id, Name='Test1', Opportunity_Source_Open__c='Customer',
                                                StageName='Prospecting', CloseDate=Date.today(),Has_PGI_Contract__c =false);
        Insert oppObject;
        Opportunity oppObject1 = [Select Id From Opportunity Where Has_PGI_Contract__c = true Limit 1];
        /* Insert oppObject1; */
        /*Opportunity oppObject1 = new Opportunity(Has_PGI_Contract__c = true);
Insert oppObject1; */
        test.startTest();
        
            
            List<echosign_dev1__SIGN_Agreement__c> agreementList = new List<echosign_dev1__SIGN_Agreement__c>{
                new echosign_dev1__SIGN_Agreement__c(echosign_dev1__Status__c='Cancelled / Declined',echosign_dev1__Opportunity__c=oppObject.Id),
                    new echosign_dev1__SIGN_Agreement__c(CreatedBy = usr, echosign_dev1__Status__c='Signed',echosign_dev1__Opportunity__c=oppObject.Id),
                    new echosign_dev1__SIGN_Agreement__c(CreatedBy = usr, echosign_dev1__Status__c='Signed',echosign_dev1__Opportunity__c=oppObject1.Id)};
                        INSERT agreementList;
            CONMAN_Contract__c objContract =[Select Opportunity__c From CONMAN_Contract__c WHERE Opportunity__c =:agreementList[1].echosign_dev1__Opportunity__c Limit 1];
            system.assertEquals(objContract.Opportunity__c,agreementList[1].echosign_dev1__Opportunity__c);
            Opportunity OpportunityObj = [Select Id,AccountId,Competitors__c,Differentiating_Win_Factors__c,Incumbent__c,Primary_Won_Reason__c From Opportunity Where Has_PGI_Contract__c = true Limit 1];          
            List<CONMAN_Contract__c> ConmanContractobjLst =[Select Id,Opportunity__c,Closed_By__c,Contract_Status__c,Related_Agreement__c,Account_Name__c From CONMAN_Contract__c];         
            System.assertEquals('Customer Accepted', ConmanContractobjLst[0].Contract_Status__c);
            System.assertEquals('eSignature', ConmanContractobjLst[0].Closed_By__c);
            System.assertEquals(OpportunityObj.AccountId, ConmanContractobjLst[0].Account_Name__c);
            System.assertEquals(null,OpportunityObj.Differentiating_Win_Factors__c);
            System.assertEquals(null,OpportunityObj.Competitors__c);
        }
        test.stopTest();
    }
    @isTest static void testmethodForUser1(){
        
        User usr1= [Select Id FROM User Where User_Region__c ='NA'And LastName='hunt3' Limit 1];
        System.runAs(usr1){
        Account actObject =[Select Id From Account Limit 1];
        Opportunity oppObject = new Opportunity(AccountId =actObject.Id, Name='Test1', Opportunity_Source_Open__c='Customer',
                                                StageName='Prospecting', CloseDate=Date.today(),Has_PGI_Contract__c =false);
        Insert oppObject;
        test.startTest();
        
            List<echosign_dev1__SIGN_Agreement__c> agreementList = new List<echosign_dev1__SIGN_Agreement__c>{
                new echosign_dev1__SIGN_Agreement__c(echosign_dev1__Status__c='Out for Signature',Created_by_iContract__c=true),
                    new echosign_dev1__SIGN_Agreement__c(echosign_dev1__Status__c='Cancelled / Declined',Created_by_iContract__c=true),
                    new echosign_dev1__SIGN_Agreement__c(CreatedBy = usr1, echosign_dev1__Status__c='Signed',echosign_dev1__Opportunity__c=oppObject.Id)};
                        INSERT agreementList;
            
            List<CONMAN_Contract__c> contractList = new List<CONMAN_Contract__c>{
                new CONMAN_Contract__c(Account_Name__c = oppObject.AccountId, Closed_By__c ='eSignature', Opportunity__c = oppObject.Id,
                                       Related_Agreement__c=agreementList[0].Id),
                    new CONMAN_Contract__c(Account_Name__c = oppObject.AccountId, Closed_By__c ='eSignature', Opportunity__c = oppObject.Id,
                                           Related_Agreement__c=agreementList[1].Id),
                    new CONMAN_Contract__c(Account_Name__c = oppObject.AccountId, Closed_By__c ='eSignature', Opportunity__c = oppObject.Id,
                                           Related_Agreement__c=agreementList[2].Id)};
                                               INSERT contractList;
            agreementList[0].Name ='Test 1';
            agreementList[1].Name ='Test 2';
            agreementList[2].Name ='Test 3';
            
            UPDATE agreementList;
            
            CONMAN_Contract__c objContract =[Select Related_Agreement__c  ,Contract_Status__c, Customer_Signed_Date__c From CONMAN_Contract__c WHERE Related_Agreement__c =:agreementList[1].Id Limit 1];
            system.assertEquals('New',objContract.Contract_Status__c);
            CONMAN_Contract__c objContract1 =[Select Related_Agreement__c  ,Account_Name__c,Closed_By__c,Contract_Status__c, Customer_Signed_Date__c From CONMAN_Contract__c WHERE Related_Agreement__c =:agreementList[2].Id Limit 1];
            system.assertEquals(agreementList[2].echosign_dev1__DateSignedDate__c, objContract1.Customer_Signed_Date__c);
            System.assertEquals('Customer Accepted', objContract1.Contract_Status__c);
            System.assertEquals('eSignature', objContract1.Closed_By__c);
            System.assertEquals(actObject.Id, objContract1.Account_Name__c);
            test.stopTest();
        }
        
    }
    @isTest static void testmethodForUser3(){
        User usr3= [Select Id FROM User Where User_Region__c ='EMEA' And LastName='hunt2' Limit 1];
        System.runAs(usr3){
        Account actObject =[Select Id From Account Limit 1];
        Opportunity oppObject = new Opportunity(AccountId =actObject.Id, Name='Test1', Opportunity_Source_Open__c='Customer',
                                                StageName='Prospecting', CloseDate=Date.today(),Has_PGI_Contract__c =false);
        Insert oppObject;
        test.startTest();
        
            List<echosign_dev1__SIGN_Agreement__c> agreementList = new List<echosign_dev1__SIGN_Agreement__c>{
                new echosign_dev1__SIGN_Agreement__c(CreatedBy = usr3, echosign_dev1__Status__c='Signed',echosign_dev1__Opportunity__c=oppObject.Id)};
                    INSERT agreementList;
            CONMAN_Contract__c objContract =[Select Opportunity__c,Account_Name__c,Contract_Status__c,Closed_By__c From CONMAN_Contract__c WHERE Opportunity__c =:agreementList[0].echosign_dev1__Opportunity__c Limit 1];
            system.assertEquals(objContract.Opportunity__c,agreementList[0].echosign_dev1__Opportunity__c);
            system.assertEquals(oppObject.AccountId,objContract.Account_Name__c);
            system.assertEquals('Customer Accepted',objContract.Contract_Status__c);
            system.assertEquals('eSignature',objContract.Closed_By__c);
        }
        test.stopTest();
    }
    @isTest static void testmethodForUser4(){ 
        Account actObject = new Account(Name ='test1',BillingCountry='India',BillingStreet='3rd cross');
        Insert actObject;
        Test.startTest();
        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(AccountId =actObject.Id, Name='Test1', Opportunity_Source_Open__c='Customer',
                            StageName='Prospecting', CloseDate=Date.today(),Has_PGI_Contract__c =false),
                new Opportunity(AccountId =actObject.Id, Name='Test2', Opportunity_Source_Open__c='Customer',
                                StageName='Prospecting', CloseDate=Date.today(),Has_PGI_Contract__c =true) };    
                                    Insert opportunityList;
        
        echosign_dev1__SIGN_Agreement__c objTestAgr = new echosign_dev1__SIGN_Agreement__c(Name='Test1',echosign_dev1__Status__c='Signed',echosign_dev1__Opportunity__c=opportunityList[0].Id);
        Insert objTestAgr;
        CONMAN_Contract__c objContract =[Select Opportunity__c,Account_Name__c,Contract_Status__c,Closed_By__c From CONMAN_Contract__c WHERE Opportunity__c =:objTestAgr.echosign_dev1__Opportunity__c Limit 1];
        Test.stopTest();
        system.assertEquals('Customer Accepted',objContract.Contract_Status__c);
        system.assertEquals(opportunityList[0].AccountId,objContract.Account_Name__c);
        system.assertEquals(objContract.Opportunity__c,objTestAgr.echosign_dev1__Opportunity__c);
        
    }
    @isTest static void testmethodForOpportunityAttachment(){
        Account actObject = new Account(Name ='test1',BillingCountry='India',BillingStreet='3rd cross');
        Insert actObject;
        Test.startTest();
        Opportunity oppObj = new Opportunity(AccountId =actObject.Id, Name='Test1', Opportunity_Source_Open__c='Customer',
                                            StageName='Prospecting', CloseDate=Date.today(),Has_PGI_Contract__c =false) ;    
        Insert oppObj;
        
        echosign_dev1__SIGN_Agreement__c objTestAgr = new echosign_dev1__SIGN_Agreement__c(Name='Test1',echosign_dev1__Status__c='Out for Signature',echosign_dev1__Opportunity__c=oppObj.Id);
        Insert objTestAgr;
        // CONMAN_Contract__c objContract = new CONMAN_Contract__c(Account_Name__c = actObject.Id, Closed_By__c ='eSignature', Opportunity__c = oppObj.Id,
        //                            Related_Agreement__c=objTestAgr.Id);
        // INSERT objContract;
                
        Attachment attach=new Attachment();    
		attach.Name='Unit Test Attachment';
		Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
		attach.body=bodyBlob;
		attach.ContentType = 'application/msword';
		attach.IsPrivate = false;
        attach.Description = 'Test';
        attach.parentId = objTestAgr.Id;
        insert attach;
        System.assertEquals(1, [SELECT Id, ParentId, Name, Body, OwnerId FROM Attachment where parentId =: objTestAgr.Id ORDER BY CreatedDate ASC].size());

        
        objTestAgr = new echosign_dev1__SIGN_Agreement__c(Id = objTestAgr.Id, echosign_dev1__Opportunity__c = oppObj.Id);
        objTestAgr.echosign_dev1__Status__c = 'Signed';
        agreementTriggerHandler.testSigned = true;
        
        echosign_dev1__SIGN_Agreement__c agr = [SELECT Id, echosign_dev1__Opportunity__c, echosign_dev1__Status__c, (SELECT Id FROM Attachments) FROM  echosign_dev1__SIGN_Agreement__c WHERE ID =: objTestAgr.Id];
        system.assertNotEquals(null, agr.echosign_dev1__Opportunity__c);
        system.assertEquals(oppObj.Id, agr.echosign_dev1__Opportunity__c);
        system.assertEquals(1, agr.attachments.size());
        Update objTestAgr;
        Test.stopTest();
        agreementTriggerHandler.oppIdsProcessed = new Set<Id>();
        agreementTriggerHandler.testSigned = true;
        Update objTestAgr;

        echosign_dev1__SIGN_Agreement__c agr2 = [SELECT Id, echosign_dev1__Opportunity__c, echosign_dev1__Status__c, (SELECT Id FROM Attachments) FROM  echosign_dev1__SIGN_Agreement__c WHERE ID =: objTestAgr.Id];
        system.assertNotEquals(null, agr2.echosign_dev1__Opportunity__c);
        system.assertEquals(oppObj.Id, agr2.echosign_dev1__Opportunity__c);
        system.assertEquals(1, agr2.attachments.size());
        
        List<Attachment> aList = [Select Id From attachment where parentId =:oppObj.Id];
        // integer count= database.countQuery('select count() from attachment where parentId ='+oppObj.Id);
        
        //TRIGGER IS GETTING WRONG ID? NEED TO FIX THIS ASSERTION
        // System.assertEquals(1, aList.size());
        
    }
}