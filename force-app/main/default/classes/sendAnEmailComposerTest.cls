@isTest
public class sendAnEmailComposerTest {

     @testSetup static void methodSetUp() {
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ',
                         Email = 'test.FromTestSendEmailComposer.com@pgi.com', 
                         Username = 'test.FromTestSendEmailComposer567.com@pgi.com', 
                         EmailEncodingKey = 'UTF-8', 
                         Alias = 'Test', 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US',
                         EmployeeNumber='12345',
                         ProfileId = p.Id,
                         IsActive =True
                        ); 
        INSERT uu; 
        System.runAs(uu){
        PGITestUtilities.disableSalesWings();
        Id pgi_ClientESRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('PGi_Client_External_Support').getRecordTypeId();
        Id outboundCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Outbound_Email_Support').getRecordTypeId();
        Account accountObj= new Account();
        accountObj.Name='Test';
        INSERT accountObj;
        Contact contactObj= new Contact();
        contactObj.AccountId=accountObj.Id;
        contactObj.Email='Test@eX.com';
        contactObj.LastName='Test';
        contactObj.FirstName='Testfn';
        contactObj.Language_Preference__c='EN';
        contactObj.Title='test';
        INSERT contactObj;
        Email_SLA_Management__c objEmailSla = new Email_SLA_Management__c();
        objEmailSla.Origin__c='Email';
        objEmailSla.Email_Template__c='pgiTemplate';
        objEmailSla.From_Address__c='Ecampl123e@ex.com';
        INSERT objEmailSla;
         
            Case objCase = new Case(
                Subject = 'TestEmail',
                ContactId=contactObj.Id,
                Follow_Up_Email_Address__c='Ecample@ex.com',
                RecordTypeId = pgi_ClientESRTId
            );
            INSERT objCase;
          
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'name';
            validEmailTemplate.DeveloperName = 'pgiTemplate';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = uu.Id;
            validEmailTemplate.Body='Test123';
            validEmailTemplate.HtmlValue='Test456';
            INSERT validEmailTemplate;
            
        }
    }
    
    static testMethod void testAllSendEmaiCompMethods(){
        User userObj = [SELECT Id 
                        FROM User 
                        WHERE Email = 'test.FromTestSendEmailComposer.com@pgi.com' LIMIT 1];
        System.runAs(userObj){
            Case caseObj=[SELECT Id,Subject,ContactId,Follow_Up_Email_Address__c,RecordTypeId 
                          FROM Case 
                          WHERE Subject = 'TestEmail']; 
         //   EmailTemplate emailTemplateObj = [Select Id,isActive,Name,DeveloperName,TemplateType,FolderId,Body,HtmlValue from EmailTemplate Where Name ='name'];
               
      
            List<EmailTemplate> emailTempList=SendAnEmailComposer.getTemplates(userObj.Id);
            System.assert(emailTempList!=null);
            List<OrgWideEmailAddress> orgWideEmailList=SendAnEmailComposer.getFromAdress();
            System.assert(orgWideEmailList!=null);
            List<Folder> folderList=SendAnEmailComposer.getEmailFolders();
            System.assert(folderList!=null);
            Email_SLA_Management__c emailSLAObj=SendAnEmailComposer.getEmailSLA('Ecampl123e@ex.com');
            System.assert(emailSLAObj!=null);
            EmailTemplate emailTempObj=SendAnEmailComposer.generatePreview('pgiTemplate', caseObj.Id);
            System.assert(emailTempObj!=null);
       }             
    }
}