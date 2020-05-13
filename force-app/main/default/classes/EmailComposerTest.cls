@isTest
public class EmailComposerTest {
    @testSetup static void methodName() {
        
        
        Profile p = [Select Id from Profile where Name='System Administrator'];
        
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ',
                         Email = 'test.FromTestCEmailComposer.com@pgi.com', 
                         Username = 'test.FromTestCEmailComposer567.com@pgi.com', 
                         EmailEncodingKey = 'UTF-8', 
                         Alias = 'Test', 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US',
                         EmployeeNumber='12345',
                         ProfileId = p.Id,
                         IsActive =True
                        ); 
        insert uu; 
        System.runAs(uu){
        PGITestUtilities.disableSalesWings();
        Id pgi_ClientESRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PGi_Client_External_Support').getRecordTypeId();
        Id outboundCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Outbound_Email_Support').getRecordTypeId();
        Account accountObj= new Account();
        accountObj.Name='Test';
        Insert accountObj;
        Contact contactObj= new Contact();
        contactObj.AccountId=accountObj.Id;
        contactObj.Email='Test@eX.com';
        contactObj.LastName='Test';
        contactObj.FirstName='Testfn';
        contactObj.Language_Preference__c='EN';
        contactObj.Title='test';
        Insert contactObj;
        Email_SLA_Management__c objEmailSla = new Email_SLA_Management__c();
        objEmailSla.Origin__c='Email';
        objEmailSla.Email_Template__c='pgiTemplate';
        objEmailSla.From_Address__c='Ecampl123e@ex.com';
        Insert objEmailSla;
         Lead l    =    new Lead(
                            FirstName = 'Test',
                            LastName = 'Owner',
                            //Topic__c = 'Test',
                            Phone = '2222012011',
                            Email = 'LeadQueueOwner@pgi.com',
                            ECommerce_Account_Number__c = 'Ecom-000000001',
                            ECommerce_Convert__c = false,
                            LeadSource = 'ECommerce Customer',
                            Company = 'Pfiz I',
                            ChannelType__c = 'Direct',
                            Status = 'Qualifying',
                            Street = '1500 Main Street',
                            City = 'SanJose',
                            StateCode = 'CA',
                            PostalCode = '95802',
                            CountryCode = 'US',
                            Business_Type__c = 1,
                            DoNotSolicit__c = true,
                            Z_Source__c = 'eCommerce',
                            Department__c = 'Sales',
                            Product_Interest__c='Web: GlobalMeet'
                        );

            insert l;
        
            Case objCase = new Case(
                Subject = 'TestEmail',
                ContactId=contactObj.Id,
                Follow_Up_Email_Address__c='Ecample@ex.com',
                RecordTypeId = pgi_ClientESRTId
            );
            INSERT objCase;
            Case objCse1 = new Case(
                Subject = 'EmailTest',
                OwnerId = uu.Id,
                RecordTypeId = outboundCaseRTId
            );
            INSERT objCse1;
            Case objCase1 = new Case(
                Subject = 'TestEmail1',
                Origin='Email',
                Follow_Up_Email_Address__c='Ecample1@ex.com',
                ParentId =objCase.Id,
                ContactId=contactObj.Id,
                RecordTypeId = outboundCaseRTId
            );
            Insert objCase1;
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'name';
            validEmailTemplate.DeveloperName = 'pgiTemplate';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = uu.Id;
            validEmailTemplate.Body='Test123';
            validEmailTemplate.HtmlValue='Test456';
            insert validEmailTemplate;
            
        }
    }
    static testMethod void testforNullCase(){
        User userObj = [Select Id from User Where Email = 'test.FromTestCEmailComposer.com@pgi.com' LIMIT 1];
        System.runAs(userObj){
            Case caseObj = new Case();
            EmailTemplate emailTemplate = [Select Id,isActive,Name,DeveloperName,TemplateType,FolderId,Body,HtmlValue from EmailTemplate Where Name = 'name']; 
            
            test.startTest();
            PageReference pageRef = Page.SendAnEmail;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('inConsole', null);
            EmailComposer emailComposerObj = new EmailComposer(); 
            emailComposerObj.init();   
            
            String selectedTemplateStr =emailComposerObj.selectedTemplate;
            String ccAddressStr =emailComposerObj.ccAddress;
            ccAddressStr='test@test.com';
            String bccAddressStr =emailComposerObj.bccAddress;
            bccAddressStr='test@test1.com';
            Boolean initialized =emailComposerObj.initialized;
            System.assertEquals(true, initialized);
            String replyMailId = emailComposerObj.replyMailId;
            System.assertEquals(null, replyMailId);
            test.stopTest();
        }
    }
    static testMethod void testforPGiExternalSupport(){
        User userObj = [Select Id from User Where Email = 'test.FromTestCEmailComposer.com@pgi.com' LIMIT 1];
        System.runAs(userObj){
            Case caseObj=[Select Id,Subject,ContactId,Follow_Up_Email_Address__c,RecordTypeId from Case where Subject = 'TestEmail']; 
            EmailTemplate emailTemplate = [Select Id,isActive,Name,DeveloperName,TemplateType,FolderId,Body,HtmlValue from EmailTemplate Where Name = 'name']; 
            Email_SLA_Management__c emailSLAObj =[Select Id,Origin__c,Email_Template__c,From_Address__c from Email_SLA_Management__c where Origin__c='Email'];
            emailSLAObj.From_Address__c='pgisfnoreply@pgi.com';
            update emailSLAObj;
            test.startTest();
            PageReference pageRef = Page.SendAnEmail;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Id', caseObj.Id);
            pageRef.getParameters().put('inConsole', 'true');
            pageRef.getParameters().put('toAll', 'Example@taAll.com');
            pageRef.getParameters().put('replyMailId', 'Example@replyMailId.com');
            pageRef.getParameters().put('fwdMailId', 'Example@fwdMailId.com');
            pageRef.getParameters().put('selectedTemplate', String.valueOf(emailTemplate.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
            EmailComposer emailComposerObj = new EmailComposer();
            emailComposerObj.init();
            
            Boolean initialized =emailComposerObj.initialized;
            System.assertEquals(false, initialized);
            case passedInFrom = emailComposerObj.passedInFrom;
            // System.assertEquals(caseObj.Follow_Up_Email_Address__c, passedInFrom.Follow_Up_Email_Address__c);
            emailComposerObj.composeEmail();
            emailComposerObj.send();
            emailComposerObj.selectTemplate();
            emailComposerObj.validParent();
            //emailComposerObj.rerenderTemplate();
            List<SelectOption> statusPicklist =emailComposerObj.statusPicklist;
            EmailMessage emailMsgObj =emailComposerObj.em;
            List<SelectOption> objList =emailComposerObj.fromAddressOptions;
            EmailTemplate theEmailTemplate =emailComposerObj.theEmailTemplate;
            System.assertEquals(emailTemplate.Id, theEmailTemplate.Id);
            emailComposerObj.cancel();
            test.stopTest();
            
        }   
    }
    static testMethod void testForOutboundEmailSupport(){
        User userObj = [Select Id from User Where Email = 'test.FromTestCEmailComposer.com@pgi.com' LIMIT 1];
        System.runAs(userObj){
            
            Case caseObj=[Select Id,Subject,ContactId,Follow_Up_Email_Address__c,Origin,RecordTypeId from Case where Subject = 'TestEmail1']; 
            EmailTemplate emailTemplate = [Select Id,isActive,Name,DeveloperName,TemplateType,FolderId,Body,HtmlValue from EmailTemplate Where Name = 'name']; 
            EmailMessage objEmailMsg = new EmailMessage();
            objEmailMsg.ParentId = caseObj.Id;
            objEmailMsg.Subject = 'subject';
            objEmailMsg.ToAddress = 'Ecample@ex.com';
            objEmailMsg.BccAddress = 'Ecample1@ex.com';
            objEmailMsg.CcAddress = 'Ecample1@ex.com';
            objEmailMsg.FromAddress = 'Ecampl123e@ex.com';
            objEmailMsg.htmlBody = 'This has body';
            objEmailMsg.TextBody = 'This has body of text';    
            objEmailMsg.MessageDate = datetime.now();
            insert objEmailMsg;
            Email_SLA_Management__c emailSLAObj =[Select Id,Origin__c,Email_Template__c,From_Address__c from Email_SLA_Management__c where Origin__c='Email'];
            test.startTest();
            PageReference pageRef = Page.SendAnEmail;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Id', caseObj.Id);
            pageRef.getParameters().put('inConsole', 'true');
            pageRef.getParameters().put('toAll', 'Example@taAll.com');
            pageRef.getParameters().put('replyMailId', String.valueOf(objEmailMsg.Id));
            pageRef.getParameters().put('fwdMailId', String.valueOf(objEmailMsg.Id));
            pageRef.getParameters().put('selectedTemplate', String.valueOf(emailTemplate.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
            EmailComposer emailComposerObj = new EmailComposer(); 
            
            emailComposerObj.init();
            case passedInFrom = emailComposerObj.passedInFrom;
            
            emailComposerObj.composeEmail();
            emailComposerObj.validateParentCase();
            emailComposerObj.send();
            Contact theContact = emailComposerObj.theContact;
            System.assertEquals(caseObj.ContactId, theContact.Id);
            emailComposerObj.setInConsole();
            String subject = emailComposerObj.subject;
            System.assertEquals(caseObj.Follow_Up_Email_Address__c, passedInFrom.Follow_Up_Email_Address__c);
            System.assertEquals(caseObj.Origin, passedInFrom.Origin);
            EmailTemplate theEmailTemplate =emailComposerObj.theEmailTemplate;
            System.assertEquals(emailTemplate.Id, theEmailTemplate.Id);
            test.stopTest();
        }   
    }
    static testMethod void testContactToIds(){
        User userObj = [Select Id,FirstName,LastName,Email from User Where Email = 'test.FromTestCEmailComposer.com@pgi.com' LIMIT 1];
        System.runAs(userObj){
            List<Id> contactIdList=new List<Id>();
            Contact contactObj =[Select Id,Email,FirstName,LastName from contact where FirstName='Testfn'];
            contactIdList.add(contactObj.Id);
            Case caseObj=[Select Id,Subject,ContactId,Follow_Up_Email_Address__c,RecordTypeId from Case where Subject = 'TestEmail1']; 
            EmailTemplate emailTemplate = [Select Id,isActive,Name,DeveloperName,TemplateType,FolderId,Body,HtmlValue from EmailTemplate Where Name = 'name']; 
            EmailMessage objEmailMsg = new EmailMessage();
            objEmailMsg.Status='3';
            objEmailMsg.ParentId = caseObj.Id;
            objEmailMsg.Subject = 'subject';
            
            objEmailMsg.BccAddress = 'Ecample1@ex.com;test@ex.com';
            objEmailMsg.htmlBody = 'This has body';
            objEmailMsg.TextBody = 'This has body of text'; 
            objEmailMsg.MessageDate = datetime.now();
            String[] toIds = new String[]{contactObj.Id};
            objEmailMsg.ToAddress = 'Ecample@ex.com;test@ex.com';
            objEmailMsg.CcAddress = 'Ecample1@ex.com;test@ex.com';
            objEmailMsg.FromAddress = 'Ecampl123e@ex.com';
            insert objEmailMsg;
            EmailMessageRelation emr = new EmailMessageRelation();
            emr.emailMessageId = objEmailMsg.id;
            emr.relationId = contactObj.Id; // user id of the sender
            emr.relationType = 'ToAddress';
            insert emr;
            Email_SLA_Management__c emailSLAObj =[Select Id,Origin__c,Email_Template__c,From_Address__c from Email_SLA_Management__c where Origin__c='Email'];
            test.startTest();
            PageReference pageRef = Page.SendAnEmail;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Id', caseObj.Id);
            pageRef.getParameters().put('inConsole', 'true');
            pageRef.getParameters().put('toAll', 'Example@taAll.com');
            pageRef.getParameters().put('replyMailId', String.valueOf(objEmailMsg.Id));
            pageRef.getParameters().put('fwdMailId', String.valueOf(objEmailMsg.Id));
            pageRef.getParameters().put('selectedTemplate', String.valueOf(emailTemplate.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
            EmailComposer emailComposerObj = new EmailComposer(); 
            emailComposerObj.init();
            emailComposerObj.composeEmail();
            emailComposerObj.validParent();
            emailComposerObj.send();
            Contact theContact = emailComposerObj.theContact;
            System.assertEquals(caseObj.ContactId, theContact.Id);
            case passedInFrom = emailComposerObj.passedInFrom;
            System.assertEquals(caseObj.Follow_Up_Email_Address__c, passedInFrom.Follow_Up_Email_Address__c);
            EmailTemplate theEmailTemplate =emailComposerObj.theEmailTemplate;
            System.assertEquals(emailTemplate.Id, theEmailTemplate.Id);
            test.stopTest();
        }   
    }
    static testMethod void testContactBccIds(){
        User userObj = [Select Id,FirstName,LastName,Email from User Where Email = 'test.FromTestCEmailComposer.com@pgi.com' LIMIT 1];
        System.runAs(userObj){
            List<Id> contactIdList=new List<Id>();
            Contact contactObj =[Select Id,Email,FirstName,LastName from contact where FirstName='Testfn'];
            contactIdList.add(contactObj.Id);
            Case caseObj=[Select Id,Subject,ContactId,Follow_Up_Email_Address__c,RecordTypeId from Case where Subject = 'TestEmail1']; 
            EmailTemplate emailTemplate = [Select Id,isActive,Name,DeveloperName,TemplateType,FolderId,Body,HtmlValue from EmailTemplate Where Name = 'name']; 
            EmailMessage objEmailMsg = new EmailMessage();
            objEmailMsg.Status='3';
            objEmailMsg.ParentId = caseObj.Id;
            objEmailMsg.Subject = 'subject';
            
            objEmailMsg.BccAddress = 'Ecample1@ex.com;test@ex.com';
            objEmailMsg.htmlBody = 'This has body';
            objEmailMsg.TextBody = 'This has body of text'; 
            objEmailMsg.MessageDate = datetime.now();
            String[] toIds = new String[]{contactObj.Id};
            objEmailMsg.ToAddress = 'Ecample@ex.com;test@ex.com';
            objEmailMsg.CcAddress = 'Ecample1@ex.com;test@ex.com';
            objEmailMsg.FromAddress = 'Ecampl123e@ex.com';
            insert objEmailMsg;
            EmailMessageRelation emr = new EmailMessageRelation();
            emr.emailMessageId = objEmailMsg.id;
            emr.relationId = contactObj.Id; // user id of the sender
            emr.relationType = 'BccAddress';
            insert emr;
            Email_SLA_Management__c emailSLAObj =[Select Id,Origin__c,Email_Template__c,From_Address__c from Email_SLA_Management__c where Origin__c='Email'];
            test.startTest();
            PageReference pageRef = Page.SendAnEmail;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Id', caseObj.Id);
            pageRef.getParameters().put('inConsole', 'true');
            pageRef.getParameters().put('toAll', 'Example@taAll.com');
            pageRef.getParameters().put('replyMailId', String.valueOf(objEmailMsg.Id));
            pageRef.getParameters().put('fwdMailId', String.valueOf(objEmailMsg.Id));
            pageRef.getParameters().put('selectedTemplate', String.valueOf(emailTemplate.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
            EmailComposer emailComposerObj = new EmailComposer();
            emailComposerObj.init();
            emailComposerObj.composeEmail();
            emailComposerObj.validParent();
            emailComposerObj.send();
            Contact theContact = emailComposerObj.theContact;
            System.assertEquals(caseObj.ContactId, theContact.Id);
            case passedInFrom = emailComposerObj.passedInFrom;
            System.assertEquals(caseObj.Follow_Up_Email_Address__c, passedInFrom.Follow_Up_Email_Address__c);
            EmailTemplate theEmailTemplate =emailComposerObj.theEmailTemplate;
            System.assertEquals(emailTemplate.Id, theEmailTemplate.Id);
            test.stopTest();
        }   
    }
    static testMethod void testContactCcIds(){
        User userObj = [Select Id,FirstName,LastName,Email from User Where Email = 'test.FromTestCEmailComposer.com@pgi.com' LIMIT 1];
        System.runAs(userObj){
            List<Id> contactIdList=new List<Id>();
            Contact contactObj =[Select Id,Email,FirstName,LastName from contact where FirstName='Testfn'];
            contactIdList.add(contactObj.Id);
            Case caseObj=[Select Id,Subject,ContactId,Follow_Up_Email_Address__c,RecordTypeId from Case where Subject = 'TestEmail1']; 
            EmailTemplate emailTemplate = [Select Id,isActive,Name,DeveloperName,TemplateType,FolderId,Body,HtmlValue from EmailTemplate Where Name = 'name']; 
            EmailMessage objEmailMsg = new EmailMessage();
            objEmailMsg.Status='3';
            objEmailMsg.ParentId = caseObj.Id;
            objEmailMsg.Subject = 'subject';
            
            objEmailMsg.BccAddress = 'Ecample1@ex.com;test@ex.com';
            objEmailMsg.htmlBody = 'This has body';
            objEmailMsg.TextBody = 'This has body of text'; 
            objEmailMsg.MessageDate = datetime.now();
            String[] toIds = new String[]{contactObj.Id};
            objEmailMsg.ToAddress = 'Ecample@ex.com;test@ex.com';
            objEmailMsg.CcAddress = 'Ecample1@ex.com;test@ex.com';
            objEmailMsg.FromAddress = 'Ecampl123e@ex.com';
            insert objEmailMsg;
            EmailMessageRelation emr = new EmailMessageRelation();
            emr.emailMessageId = objEmailMsg.id;
            emr.relationId = contactObj.Id; // user id of the sender
            emr.relationType = 'CcAddress';
            insert emr;
            Email_SLA_Management__c emailSLAObj =[Select Id,Origin__c,Email_Template__c,From_Address__c from Email_SLA_Management__c where Origin__c='Email'];
            test.startTest();
            PageReference pageRef = Page.SendAnEmail;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Id', caseObj.Id);
            pageRef.getParameters().put('inConsole', 'true');
            pageRef.getParameters().put('toAll', 'Example@taAll.com');
            pageRef.getParameters().put('replyMailId', String.valueOf(objEmailMsg.Id));
            pageRef.getParameters().put('fwdMailId', String.valueOf(objEmailMsg.Id));
            pageRef.getParameters().put('selectedTemplate', String.valueOf(emailTemplate.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
            EmailComposer emailComposerObj = new EmailComposer(); 
            emailComposerObj.init();
            emailComposerObj.composeEmail();
            emailComposerObj.validParent();
            emailComposerObj.send();
            Contact theContact = emailComposerObj.theContact;
            System.assertEquals(caseObj.ContactId, theContact.Id);
            case passedInFrom = emailComposerObj.passedInFrom;
            System.assertEquals(caseObj.Follow_Up_Email_Address__c, passedInFrom.Follow_Up_Email_Address__c);
            EmailTemplate theEmailTemplate =emailComposerObj.theEmailTemplate;
            System.assertEquals(emailTemplate.Id, theEmailTemplate.Id);
            test.stopTest();
        }   
    }
    static testMethod void testUserToIds(){
        User userObj = [Select Id,FirstName,LastName,Email from User Where Email = 'test.FromTestCEmailComposer.com@pgi.com' LIMIT 1];
        System.runAs(userObj){
            List<Id> contactIdList=new List<Id>();
            Contact contactObj =[Select Id,Email,FirstName,LastName from contact where FirstName='Testfn'];
            contactIdList.add(contactObj.Id);
            Case caseObj=[Select Id,Subject,ContactId,Follow_Up_Email_Address__c,RecordTypeId from Case where Subject = 'TestEmail1']; 
            EmailTemplate emailTemplate = [Select Id,isActive,Name,DeveloperName,TemplateType,FolderId,Body,HtmlValue from EmailTemplate Where Name = 'name']; 
            EmailMessage objEmailMsg = new EmailMessage();
            objEmailMsg.Status='3';
            objEmailMsg.ParentId = caseObj.Id;
            objEmailMsg.Subject = 'subject';
            
            objEmailMsg.BccAddress = 'Ecample1@ex.com;test@ex.com';
            objEmailMsg.htmlBody = 'This has body';
            objEmailMsg.TextBody = 'This has body of text'; 
            objEmailMsg.MessageDate = datetime.now();
            String[] toIds = new String[]{contactObj.Id};
            objEmailMsg.ToAddress = 'Ecample@ex.com;test@ex.com';
            objEmailMsg.CcAddress = 'Ecample1@ex.com;test@ex.com';
            objEmailMsg.FromAddress = 'Ecampl123e@ex.com';
            insert objEmailMsg;
            EmailMessageRelation emr = new EmailMessageRelation();
            emr.emailMessageId = objEmailMsg.id;
            emr.relationId = userObj.Id; // user id of the sender
            emr.relationType = 'ToAddress';
            insert emr;
            Email_SLA_Management__c emailSLAObj =[Select Id,Origin__c,Email_Template__c,From_Address__c from Email_SLA_Management__c where Origin__c='Email'];
            test.startTest();
            PageReference pageRef = Page.SendAnEmail;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Id', caseObj.Id);
            pageRef.getParameters().put('inConsole', 'true');
            pageRef.getParameters().put('toAll', 'Example@taAll.com');
            pageRef.getParameters().put('replyMailId', String.valueOf(objEmailMsg.Id));
            pageRef.getParameters().put('fwdMailId', String.valueOf(objEmailMsg.Id));
            pageRef.getParameters().put('selectedTemplate', String.valueOf(emailTemplate.Id));
                pageRef.getParameters().put('composeEmail', 'true');
            ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
            EmailComposer emailComposerObj = new EmailComposer(); 
            emailComposerObj.init();
            emailComposerObj.composeEmail();
            emailComposerObj.validParent();
            emailComposerObj.send();
            Contact theContact = emailComposerObj.theContact;
            System.assertEquals(caseObj.ContactId, theContact.Id);
            case passedInFrom = emailComposerObj.passedInFrom;
            System.assertEquals(caseObj.Follow_Up_Email_Address__c, passedInFrom.Follow_Up_Email_Address__c);
            EmailTemplate theEmailTemplate =emailComposerObj.theEmailTemplate;
            System.assertEquals(emailTemplate.Id, theEmailTemplate.Id);
            test.stopTest();
        }   
    }
    static testMethod void testUserCcIds(){
        User userObj = [Select Id,FirstName,LastName,Email from User Where Email = 'test.FromTestCEmailComposer.com@pgi.com' LIMIT 1];
        System.runAs(userObj){
            List<Id> contactIdList=new List<Id>();
            Contact contactObj =[Select Id,Email,FirstName,LastName from contact where FirstName='Testfn'];
            contactIdList.add(contactObj.Id);
            Case caseObj=[Select Id,Subject,ParentId,ContactId,Follow_Up_Email_Address__c,RecordTypeId from Case where Subject = 'TestEmail1']; 
            EmailTemplate emailTemplate = [Select Id,isActive,Name,DeveloperName,TemplateType,FolderId,Body,HtmlValue from EmailTemplate Where Name = 'name']; 
            EmailMessage objEmailMsg = new EmailMessage();
            objEmailMsg.Status='3';
            objEmailMsg.ParentId = caseObj.Id;
            objEmailMsg.Subject = 'subject';
            
            objEmailMsg.BccAddress = 'Ecample1@ex.com;test@ex.com';
            objEmailMsg.htmlBody = 'This has body';
            objEmailMsg.TextBody = 'This has body of text'; 
            objEmailMsg.MessageDate = datetime.now();
            String[] toIds = new String[]{contactObj.Id};
            objEmailMsg.ToAddress = 'Ecample@ex.com;test@ex.com';
            objEmailMsg.CcAddress = 'Ecample1@ex.com;test@ex.com';
            objEmailMsg.FromAddress = 'Ecampl123e@ex.com';
            insert objEmailMsg;
            EmailMessageRelation emr = new EmailMessageRelation();
            emr.emailMessageId = objEmailMsg.id;
            emr.relationId = userObj.Id; // user id of the sender
            emr.relationType = 'CcAddress';
            insert emr;
            Email_SLA_Management__c emailSLAObj =[Select Id,Origin__c,Email_Template__c,From_Address__c from Email_SLA_Management__c where Origin__c='Email'];
            test.startTest();
            PageReference pageRef = Page.SendAnEmail;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Id', caseObj.Id);
            pageRef.getParameters().put('inConsole', 'true');
            pageRef.getParameters().put('toAll', 'Example@taAll.com');
            pageRef.getParameters().put('replyMailId', String.valueOf(objEmailMsg.Id));
            pageRef.getParameters().put('fwdMailId', String.valueOf(objEmailMsg.Id));
            pageRef.getParameters().put('selectedTemplate', String.valueOf(emailTemplate.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
            EmailComposer emailComposerObj = new EmailComposer(); 
            emailComposerObj.init();
            emailComposerObj.composeEmail();
            emailComposerObj.validParent();
            Contact theContact = emailComposerObj.theContact;
            System.assertEquals(caseObj.ContactId, theContact.Id);
            case passedInFrom = emailComposerObj.passedInFrom;
            System.assertEquals(caseObj.Follow_Up_Email_Address__c, passedInFrom.Follow_Up_Email_Address__c);
            EmailTemplate theEmailTemplate =emailComposerObj.theEmailTemplate;
            System.assertEquals(emailTemplate.Id, theEmailTemplate.Id);
            test.stopTest();
            emailComposerObj.doNothing();
        }   
    }
    static testMethod void testUserBccIds(){
        User userObj = [Select Id,FirstName,LastName,Email from User Where Email = 'test.FromTestCEmailComposer.com@pgi.com' LIMIT 1];
        System.runAs(userObj){
            List<Id> contactIdList=new List<Id>();
            Contact contactObj =[Select Id,Email,FirstName,LastName from contact where FirstName='Testfn'];
            contactIdList.add(contactObj.Id);
            Case caseObj=[Select Id,Subject,ContactId,Follow_Up_Email_Address__c,RecordTypeId from Case where Subject = 'TestEmail1']; 
            EmailTemplate emailTemplate = [Select Id,isActive,Name,DeveloperName,TemplateType,FolderId,Body,HtmlValue from EmailTemplate Where Name = 'name']; 
            EmailMessage objEmailMsg = new EmailMessage();
            objEmailMsg.Status='3';
            objEmailMsg.ParentId = caseObj.Id;
            objEmailMsg.Subject = 'subject';
            
            objEmailMsg.BccAddress = 'Ecample1@ex.com;test@ex.com';
            objEmailMsg.htmlBody = 'This has body';
            objEmailMsg.TextBody = 'This has body of text'; 
            objEmailMsg.MessageDate = datetime.now();
            String[] toIds = new String[]{contactObj.Id};
            objEmailMsg.ToAddress = 'Ecample@ex.com;test@ex.com';
            objEmailMsg.CcAddress = 'Ecample1@ex.com;test@ex.com';
            objEmailMsg.FromAddress = 'Ecampl123e@ex.com';
            insert objEmailMsg;
            EmailMessageRelation emr = new EmailMessageRelation();
            emr.emailMessageId = objEmailMsg.id;
            emr.relationId = userObj.Id; // user id of the sender
            emr.relationType = 'BccAddress';
            insert emr;
            Email_SLA_Management__c emailSLAObj =[Select Id,Origin__c,Email_Template__c,From_Address__c from Email_SLA_Management__c where Origin__c='Email'];
            test.startTest();
            PageReference pageRef = Page.SendAnEmail;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Id', caseObj.Id);
            pageRef.getParameters().put('inConsole', 'true');
            pageRef.getParameters().put('toAll', 'Example@taAll.com');
            pageRef.getParameters().put('replyMailId', String.valueOf(objEmailMsg.Id));
            pageRef.getParameters().put('fwdMailId', String.valueOf(objEmailMsg.Id));
            pageRef.getParameters().put('selectedTemplate', String.valueOf(emailTemplate.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
            EmailComposer emailComposerObj = new EmailComposer();
            emailComposerObj.init();
            emailComposerObj.composeEmail();
            emailComposerObj.validParent();
            emailComposerObj.send();
            Contact theContact = emailComposerObj.theContact;
            System.assertEquals(caseObj.ContactId, theContact.Id);
            case passedInFrom = emailComposerObj.passedInFrom;
            System.assertEquals(caseObj.Follow_Up_Email_Address__c, passedInFrom.Follow_Up_Email_Address__c);
            EmailTemplate theEmailTemplate =emailComposerObj.theEmailTemplate;
            System.assertEquals(emailTemplate.Id, theEmailTemplate.Id);
            test.stopTest();
        }   
    }
    static testMethod void testForDiffertAddress(){
        User userObj = [Select Id from User Where Email = 'test.FromTestCEmailComposer.com@pgi.com' LIMIT 1];
        System.runAs(userObj){
            Case caseObj=[Select Id,Subject,ContactId,Follow_Up_Email_Address__c,RecordTypeId from Case where Subject = 'TestEmail1']; 
            EmailTemplate emailTemplate = [Select Id,isActive,Name,DeveloperName,TemplateType,FolderId,Body,HtmlValue from EmailTemplate Where Name = 'name']; 
            EmailMessage objEmailMsg = new EmailMessage();
            objEmailMsg.ParentId = caseObj.Id;
            objEmailMsg.Subject = 'subject';
            objEmailMsg.ToAddress = 'Ecample@ex.com';
            objEmailMsg.BccAddress = 'Ecample1@ex.com';
            objEmailMsg.CcAddress = 'Ecample1@ex.com';
            objEmailMsg.FromAddress = 'Ecampl123e@ex.com';
            objEmailMsg.htmlBody = 'This has body';
            objEmailMsg.TextBody = 'This has body of text';    
            objEmailMsg.MessageDate = datetime.now();
            insert objEmailMsg;
            Email_SLA_Management__c emailSLAObj =[Select Id,Origin__c,Email_Template__c,From_Address__c from Email_SLA_Management__c where Origin__c='Email'];
            emailSLAObj.From_Address__c='Ecample1@ex.com';
            update emailSLAObj;
            PageReference pageRef = Page.SendAnEmail;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Id', caseObj.Id);
            pageRef.getParameters().put('inConsole', 'true');
            pageRef.getParameters().put('toAll', 'Example@taAll.com');
            pageRef.getParameters().put('replyMailId', String.valueOf(objEmailMsg.Id));
            pageRef.getParameters().put('selectedTemplate', String.valueOf(emailTemplate.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
            EmailComposer emailComposerObj = new EmailComposer(); 
            emailComposerObj.init();
            emailComposerObj.composeEmail();
            emailComposerObj.send();
            Contact theContact = emailComposerObj.theContact;
            System.assertEquals(caseObj.ContactId, theContact.Id);
            case passedInFrom = emailComposerObj.passedInFrom;
            System.assertEquals(caseObj.Follow_Up_Email_Address__c, passedInFrom.Follow_Up_Email_Address__c);
            // EmailTemplate theEmailTemplate =emailComposerObj.theEmailTemplate;
            // System.assertEquals(emailTemplate.Id, theEmailTemplate.Id);
        }   
    }
    static testMethod void testCheckIfFwdMailId(){
        User userObj = [Select Id from User Where Email = 'test.FromTestCEmailComposer.com@pgi.com' LIMIT 1];
        System.runAs(userObj){
            Case caseObj=[Select Id,Subject,ContactId,Follow_Up_Email_Address__c,RecordTypeId from Case where Subject = 'TestEmail1']; 
            EmailTemplate emailTemplate = [Select Id,isActive,Name,DeveloperName,TemplateType,FolderId,Body,HtmlValue from EmailTemplate Where Name = 'name']; 
            EmailMessage objEmailMsg = new EmailMessage();
            objEmailMsg.ParentId = caseObj.Id;
            objEmailMsg.Subject = 'subject';
            objEmailMsg.ToAddress = 'Ecample@ex.com';
            objEmailMsg.BccAddress = 'Ecample1@ex.com';
            objEmailMsg.CcAddress = 'Ecample1@ex.com';
            objEmailMsg.FromAddress = 'Ecampl123e@ex.com';
            objEmailMsg.htmlBody = 'This has body';
            objEmailMsg.TextBody = 'This has body of text';    
            objEmailMsg.MessageDate = datetime.now();
            insert objEmailMsg;
            Email_SLA_Management__c emailSLAObj =[Select Id,Origin__c,Email_Template__c,From_Address__c from Email_SLA_Management__c where Origin__c='Email'];
            emailSLAObj.From_Address__c='Ecample1@ex.com';
            update emailSLAObj;
            PageReference pageRef = Page.SendAnEmail;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Id', caseObj.Id);
            pageRef.getParameters().put('inConsole', 'true');
            pageRef.getParameters().put('toAll', 'Example@taAll.com');
            pageRef.getParameters().put('fwdMailId', String.valueOf(objEmailMsg.Id));
            pageRef.getParameters().put('selectedTemplate', String.valueOf(emailTemplate.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
            EmailComposer emailComposerObj = new EmailComposer(); 
            emailComposerObj.init();
            emailComposerObj.composeEmail();
            emailComposerObj.send();
            Contact theContact = emailComposerObj.theContact;
            System.assertEquals(caseObj.ContactId, theContact.Id);
            case passedInFrom = emailComposerObj.passedInFrom;
            System.assertEquals(caseObj.Follow_Up_Email_Address__c, passedInFrom.Follow_Up_Email_Address__c);
            // EmailTemplate theEmailTemplate =emailComposerObj.theEmailTemplate;
            system.debug('--emailTemplate---->'+emailComposerObj);
            // System.assertEquals(emailTemplate.Id, theEmailTemplate.Id);
        }  
    }
    static testMethod void testleadBccIds(){
        User userObj = [Select Id,FirstName,LastName,Email from User Where Email = 'test.FromTestCEmailComposer.com@pgi.com' LIMIT 1];
        System.runAs(userObj){
            List<Id> contactIdList=new List<Id>();
            Lead leadObj =[Select Id,Email,FirstName,LastName from Lead where FirstName='Test'];
            Case caseObj=[Select Id,Subject,ContactId,Follow_Up_Email_Address__c,RecordTypeId from Case where Subject = 'TestEmail1']; 
            EmailTemplate emailTemplate = [Select Id,isActive,Name,DeveloperName,TemplateType,FolderId,Body,HtmlValue from EmailTemplate Where Name = 'name']; 
            EmailMessage objEmailMsg = new EmailMessage();
            objEmailMsg.Status='3';
            objEmailMsg.ParentId = caseObj.Id;
            objEmailMsg.Subject = 'subject';
            objEmailMsg.BccAddress = 'Ecample1@ex.com;test@ex.com';
            objEmailMsg.htmlBody = 'This has body';
            objEmailMsg.TextBody = 'This has body of text'; 
            objEmailMsg.MessageDate = datetime.now();
            objEmailMsg.ToAddress = 'Ecample@ex.com;test@ex.com';
            objEmailMsg.CcAddress = 'Ecample1@ex.com;test@ex.com';
            objEmailMsg.FromAddress = 'Ecampl123e@ex.com';
            insert objEmailMsg;
            EmailMessageRelation emr = new EmailMessageRelation();
            emr.emailMessageId = objEmailMsg.id;
            emr.relationId = leadObj.Id; // user id of the sender
            emr.relationType = 'BccAddress';
            insert emr;
            Email_SLA_Management__c emailSLAObj =[Select Id,Origin__c,Email_Template__c,From_Address__c from Email_SLA_Management__c where Origin__c='Email'];
            test.startTest();
            PageReference pageRef = Page.SendAnEmail;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Id', caseObj.Id);
            pageRef.getParameters().put('inConsole', 'true');
            pageRef.getParameters().put('toAll', 'Example@taAll.com');
            pageRef.getParameters().put('replyMailId', String.valueOf(objEmailMsg.Id));
            pageRef.getParameters().put('fwdMailId', String.valueOf(objEmailMsg.Id));
            pageRef.getParameters().put('selectedTemplate', String.valueOf(emailTemplate.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
            EmailComposer emailComposerObj = new EmailComposer(); 
            emailComposerObj.init();
            emailComposerObj.composeEmail();
            emailComposerObj.send();
            emailComposerObj.validParent();
            Contact theContact = emailComposerObj.theContact;
            System.assertEquals(caseObj.ContactId, theContact.Id);
            case passedInFrom = emailComposerObj.passedInFrom;
            System.assertEquals(caseObj.Follow_Up_Email_Address__c, passedInFrom.Follow_Up_Email_Address__c);
            EmailTemplate theEmailTemplate =emailComposerObj.theEmailTemplate;
            System.assertEquals(emailTemplate.Id, theEmailTemplate.Id);
            test.stopTest();
        }   
    }
    static testMethod void testleadToIds(){
        User userObj = [Select Id,FirstName,LastName,Email from User Where Email = 'test.FromTestCEmailComposer.com@pgi.com' LIMIT 1];
        System.runAs(userObj){
            List<Id> contactIdList=new List<Id>();
            Lead leadObj =[Select Id,Email,FirstName,LastName from Lead where FirstName='Test'];
            //contactIdList.add(contactObj.Id);
            Case caseObj=[Select Id,Subject,ContactId,Follow_Up_Email_Address__c,RecordTypeId from Case where Subject = 'TestEmail1']; 
            EmailTemplate emailTemplate = [Select Id,isActive,Name,DeveloperName,TemplateType,FolderId,Body,HtmlValue from EmailTemplate Where Name = 'name']; 
            EmailMessage objEmailMsg = new EmailMessage();
            objEmailMsg.Status='3';
            objEmailMsg.ParentId = caseObj.Id;
            objEmailMsg.Subject = 'subject';
            
            objEmailMsg.BccAddress = 'Ecample1@ex.com;test@ex.com';
            objEmailMsg.htmlBody = 'This has body';
            objEmailMsg.TextBody = 'This has body of text'; 
            objEmailMsg.MessageDate = datetime.now();
            //String[] toIds = new String[]{contactObj.Id};
            objEmailMsg.ToAddress = 'Ecample@ex.com;test@ex.com';
            objEmailMsg.CcAddress = 'Ecample1@ex.com;test@ex.com';
            objEmailMsg.FromAddress = 'Ecampl123e@ex.com';
            insert objEmailMsg;
            EmailMessageRelation emr = new EmailMessageRelation();
            emr.emailMessageId = objEmailMsg.id;
            emr.relationId = leadObj.Id; // user id of the sender
            emr.relationType = 'ToAddress';
            insert emr;
            Email_SLA_Management__c emailSLAObj =[Select Id,Origin__c,Email_Template__c,From_Address__c from Email_SLA_Management__c where Origin__c='Email'];
            test.startTest();
            PageReference pageRef = Page.SendAnEmail;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Id', caseObj.Id);
            pageRef.getParameters().put('inConsole', 'true');
            pageRef.getParameters().put('toAll', 'Example@taAll.com');
            pageRef.getParameters().put('replyMailId', String.valueOf(objEmailMsg.Id));
            pageRef.getParameters().put('fwdMailId', String.valueOf(objEmailMsg.Id));
            pageRef.getParameters().put('selectedTemplate', String.valueOf(emailTemplate.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
            EmailComposer emailComposerObj = new EmailComposer(); 
            emailComposerObj.init();
            emailComposerObj.composeEmail();
            emailComposerObj.send();
            emailComposerObj.validParent();
            Contact theContact = emailComposerObj.theContact;
            System.assertEquals(caseObj.ContactId, theContact.Id);
            case passedInFrom = emailComposerObj.passedInFrom;
            System.assertEquals(caseObj.Follow_Up_Email_Address__c, passedInFrom.Follow_Up_Email_Address__c);
            EmailTemplate theEmailTemplate =emailComposerObj.theEmailTemplate;
            System.assertEquals(emailTemplate.Id, theEmailTemplate.Id);
            test.stopTest();
        }   
    }
    static testMethod void testleadccIds(){
        User userObj = [Select Id,FirstName,LastName,Email from User Where Email = 'test.FromTestCEmailComposer.com@pgi.com' LIMIT 1];
        System.runAs(userObj){
            List<Id> contactIdList=new List<Id>();
            Lead leadObj =[Select Id,Email,FirstName,LastName from Lead where FirstName='Test'];
            //contactIdList.add(contactObj.Id);
            Case caseObj=[Select Id,Subject,ContactId,Follow_Up_Email_Address__c,RecordTypeId from Case where Subject = 'TestEmail1']; 
            EmailTemplate emailTemplate = [Select Id,isActive,Name,DeveloperName,TemplateType,FolderId,Body,HtmlValue from EmailTemplate Where Name = 'name']; 
            EmailMessage objEmailMsg = new EmailMessage();
            objEmailMsg.Status='3';
            objEmailMsg.ParentId = caseObj.Id;
            objEmailMsg.Subject = 'subject';
            
            objEmailMsg.BccAddress = 'Ecample1@ex.com;test@ex.com';
            objEmailMsg.htmlBody = 'This has body';
            objEmailMsg.TextBody = 'This has body of text'; 
            objEmailMsg.MessageDate = datetime.now();
            //String[] toIds = new String[]{contactObj.Id};
            objEmailMsg.ToAddress = 'Ecample@ex.com;test@ex.com';
            objEmailMsg.CcAddress = 'Ecample1@ex.com;test@ex.com';
            objEmailMsg.FromAddress = 'Ecampl123e@ex.com';
            insert objEmailMsg;
            EmailMessageRelation emr = new EmailMessageRelation();
            emr.emailMessageId = objEmailMsg.id;
            emr.relationId = leadObj.Id; // user id of the sender
            emr.relationType = 'CcAddress';
            insert emr;
            Email_SLA_Management__c emailSLAObj =[Select Id,Origin__c,Email_Template__c,From_Address__c from Email_SLA_Management__c where Origin__c='Email'];
            test.startTest();
            PageReference pageRef = Page.SendAnEmail;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Id', caseObj.Id);
            pageRef.getParameters().put('inConsole', 'true');
            pageRef.getParameters().put('toAll', 'Example@taAll.com');
            pageRef.getParameters().put('replyMailId', String.valueOf(objEmailMsg.Id));
            pageRef.getParameters().put('fwdMailId', String.valueOf(objEmailMsg.Id));
            pageRef.getParameters().put('selectedTemplate', String.valueOf(emailTemplate.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
            EmailComposer emailComposerObj = new EmailComposer(); 
            //emailComposerObj.validate();
            //emailComposerObj.passedInFrom=caseObj1;
             emailComposerObj.resetForm();
            emailComposerObj.init();
            emailComposerObj.composeEmail();
            emailComposerObj.send();
            emailComposerObj.validParent();
            Contact theContact = emailComposerObj.theContact;
            System.assertEquals(caseObj.ContactId, theContact.Id);
            case passedInFrom = emailComposerObj.passedInFrom;
            System.assertEquals(caseObj.Follow_Up_Email_Address__c, passedInFrom.Follow_Up_Email_Address__c);
            EmailTemplate theEmailTemplate =emailComposerObj.theEmailTemplate;
            System.assertEquals(emailTemplate.Id, theEmailTemplate.Id);
            test.stopTest();
           
        }   
    }

}