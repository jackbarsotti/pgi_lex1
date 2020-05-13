@isTest
private class testProvisioningEmailHelper {
    @testSetup static void setup() {
        Test.startTest();
        PGITestUtilities.disableSalesWings();
        
        Test.stopTest();
    } 
    
    private static SFPCTestHelper sfpcTestHelper;
    
    private static void init() {
        sfpcTestHelper = new SFPCTestHelper();
        sfpcTestHelper.createForAccount(MockAccount.getNewAccount());
    }
    
    @isTest static void test_NeedsProvisioningEmail_newSub() {
        init();
        System.assert(!ProvisioningEmailHelper.needsProvisioningEmail(MockSubscription.getNewSubscription(), null));
    }
    
    @isTest static void test_NeedsProvEmail_sameStatus() {
        init();
        Subscription__c oldSub = MockSubscription.getNewSubscription();
        Subscription__c newSub = sfpcTestHelper.subscription;
        
        // shouldn't need an email because the mocks are created with the same state.
        System.assert(!ProvisioningEmailHelper.needsProvisioningEmail(newSub, oldSub));
    }
    
    @isTest
    static void test_NeedsProvEmail_movedToActive() {
        init();
        Subscription__c oldSub = MockSubscription.getNewSubscription();
        Subscription__c newSub = sfpcTestHelper.subscription;
        newSub.ProvisioningEmailSent__c = null;
        newSub.Status__c = 'Active';
        newSub.Send_Provisioning_Email__c = true;
        Database.update(newSub);
        oldSub.Status__c = 'AddError';
        System.assert(ProvisioningEmailHelper.needsProvisioningEmail(newSub, oldSub));
    }
    
    @isTest static void test_NeedsProvEmail_movedToActiveEmailAlreadySent() {
        init();
        Subscription__c oldSub = MockSubscription.getNewSubscription();
        Subscription__c newSub = sfpcTestHelper.subscription;
        newSub.ProvisioningEmailSent__c = Datetime.now();
        newSub.Status__c = 'Active';
        newSub.Send_Provisioning_Email__c = true;
        Database.update(newSub);
        oldSub.Status__c = 'AddError';
        System.assert(!ProvisioningEmailHelper.needsProvisioningEmail(newSub, oldSub));
    }
    
    @isTest  
    static void testSendProvisioningEmail() {
        init();
        Subscription__c subSObj = sfpcTestHelper.subscription;
        subSObj.Contact__c = sfpcTestHelper.subscription.contact__c;
        subSObj.ProvisioningEmailSent__c = null;
        subSObj.Status__c = 'Active';
        subSObj.Add_l_Provisioning_Email_Addresses__c = 'timothy.barsotti@pgi.com';
        subSObj.Add_l_Provisioning_Emails__c = true;
        Database.update(subSObj);
        
        System.assert(subSObj != null);
        
        System.assert(ProvisioningEmailHelper.sendProvisioningEmail(subSObj, 'Provisioning_BBS'));
    }
    
    @isTest  
    static void testSendFoxDenEmail() {
        init();
        Subscription__c subSObj = sfpcTestHelper.subscription;
        
        ProvisioningEmailHelper.needsFoxDenProvisioningEmail(sfpcTestHelper.foxDenUser,sfpcTestHelper.foxDenUser);
        subSObj.Contact__c = subSObj.contact__c;
        subSObj.ProvisioningEmailSent__c = null;
        subSObj.Status__c = 'Active';
        Database.update(subSObj);
        
        System.assert(subSObj != null);    
        Test.stopTest();
    }
    
    @isTest
    static void testSplitAdditionalEmailAddress() {
        init();
        String[] addys = ProvisioningEmailHelper.splitAdditionalEmailAddresses('foo@bar.com,,,foo2@bar.com;foo3@bar.com    foo4@bar.com');
        System.assertEquals(4, addys.size());
    }
    @isTest
    static void testsendFoxDenProvisioningEmail(){
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
            init();
            Contact c = new Contact();
            c.Email ='Test@pgi.com';
            c.LastName = 'test Contact';
            INSERT c;
            
            FoxDen_User__c FUser = new FoxDen_User__c();
            FUser.Contact__c = c.Id;
            FUser.Email__c = 'vinayak@raagvitech.com';
            FUser.Name = 'test';
            FUser.Status__c = 'Pending';
            FUser.Inactive__c = true;
            FUser.Date_Deleted__c= null;
            INSERT FUser;
            
            EmailTemplate template=new EmailTemplate();
            template.Name='test123';
            template.isActive = true;
            template.FolderId=UserInfo.getUserId();
            template.TemplateType='text';
            template.DeveloperName='abcd';
            Insert template;  
            // EmailTemplate templates=[SELECT id from EmailTemplate where developerName = 'abcd' ];
            //  system.runAs(templates){
            //  } */
            ProvisioningEmailHelper.sendFoxDenProvisioningEmail(FUser,template.DeveloperName);
            //   Test.startTest();
            //   FoxDenUser foxDenUserRepository = new FoxDenUser(); 
            //    FoxDen_User__c user = foxDenUserRepository.findById(FUser.id);
            
            
            //  FUser.stopTest();
            system.assertEquals('Pending',FUser.Status__c );
        }
    }
    @isTest
    static void testsendS3ProvisioningEmail(){
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
        init();
        Contact c = new Contact();
            c.Email ='Test@pgi.com';
            c.LastName = 'test Contact';
            INSERT c;
            
        S3User__c s3User = new S3User__c();
        s3User.Contact__c = c.Id;
        s3User.Email__c = 'vinayak@raagvitech.com';
        s3User.Name = 'test';
        s3User.Status__c = 'Pending';
        s3User.Inactive__c = true;
        s3User.Date_Deleted__c= null;
        INSERT s3User;
        
            EmailTemplate template=new EmailTemplate();
            template.isActive = true;
            template.Name='test123';
            template.FolderId=UserInfo.getUserId();
            template.TemplateType='text';
            template.DeveloperName='abcd';
            Insert template;  
            
            ProvisioningEmailHelper.sendS3ProvisioningEmail(s3User,template.DeveloperName);
           
            system.assertEquals('Pending',s3User.Status__c );
        }
    }
}