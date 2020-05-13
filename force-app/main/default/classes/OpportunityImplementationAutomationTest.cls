@isTest
private class OpportunityImplementationAutomationTest 
{
    @testSetup static void setup() 
    {
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User usr = new User(LastName = 'LIVESTON', 
                            FirstName='JASON',
                            Alias = 'jliv',
                            Email = 'bellemay@pgi.com',
                            Username = 'bellemay@sfdc01.com',
                            CommunityNickname = 'bellemay',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            EmployeeNumber='12345',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US',
                            User_Region__c ='NA'
                           );
        Insert usr;
       User usr1 = new User(LastName = 'test Class user', 
                            FirstName='JASON',
                            Alias = 'test',
                            Email = 'testclassDeveloperUserFake@pgi.com',
                            Username = 'testclassDeveloperUserFakePgi@sfdc01.com',
                            CommunityNickname = 'ComtestPBGI',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            EmployeeNumber='12345',
                            LocaleSidKey = 'en_US',
                            User_Region__c ='APAC',
                            Channel__c = 'APAC'
                           );
        Insert usr1;
        System.runAs(usr1) {
        RecordType recordtype =[select Id from Recordtype WHERE name ='PGi Opportunity' and sObjectType  = 'Opportunity' ];
        List<Opportunity> lstoppty = new List<Opportunity>{new Opportunity(Name = 'test' , CloseDate = system.today() , RecordTypeId = recordtype.id , Owner_Region__c = 'NA' , Stagename = 'Awareness' , Forecast_Status__c = 'Commit' , CurrencyIsoCode = 'USD' , Probability = 0 , 
                                        NoISTNeeded__c = false , Competitor_s__c ='Airtel' , Incumbent__c ='Arkadin' , Differentiating_Win_Factors__c ='abc' , Primary_Won_Reason__c ='Pricing Structure'),
            new Opportunity(Name = 'test 1',CloseDate = system.today(),Owner_Region__c ='EMEA',Stagename = 'Purchase',Forecast_Status__c='Commit',CurrencyIsoCode = 'USD',Probability = 0,Competitor_s__c ='Airtel',Incumbent__c='Arkadin',Differentiating_Win_Factors__c ='abc',Primary_Won_Reason__c ='Pricing Structure'),
            new Opportunity(Name = 'test 2',CloseDate = system.today(),Owner_Region__c ='APAC',Stagename = 'Purchase',Forecast_Status__c='Commit',CurrencyIsoCode = 'USD',Probability = 0,Competitor_s__c ='Airtel',Incumbent__c='Arkadin',Differentiating_Win_Factors__c ='abc',Primary_Won_Reason__c ='Pricing Structure')};
        Insert lstoppty; 
        }
        
    }
    public static testMethod void TestGoToOpportunityLink(){
        test.starttest(); 
        OpportunityImplementationAutomation notificationcnt = new OpportunityImplementationAutomation();
        system.assert(notificationcnt.GoToOpportunityLink()!=null);
        /*Cover wrapper code*/
        notificationcnt.ViewData();
        notificationcnt.CreateImpSerRecord();
        notificationcnt.getSortDirection();
        notificationcnt.setSortDirection('name');
        notificationcnt.setSortDirection('ASC');
        notificationcnt.GoToOpportunityLink();
        notificationcnt.NoISTNeeded();
        
        
        User u3 =[Select Id,FirstName,User_Region__c,Channel__c from User where User_Region__c ='NA' AND Email = 'bellemay@pgi.com'];
        system.runas(U3) {
            /*Cover wrapper code*/
            OpportunityImplementationAutomation notificationcnt2=new OpportunityImplementationAutomation();
            system.assert(notificationcnt2.GoToOpportunityLink()!=null);
            
            notificationcnt2.ViewData();
            for(OpportunityImplementationAutomation.oOpportunity obj : notificationcnt2.OpportunityList ){
                obj.selected = true;
            }
            notificationcnt2.CreateImpSerRecord();
            notificationcnt2.getSortDirection();
            notificationcnt2.setSortDirection('name');
        }
        List<Implementation_Services__c> objImplemServic = [Select Implementation_Owner__c,Implementation_Type__c,IST_Status__c,IST_Completed_Status__c,Related_Opportunity__c from Implementation_Services__c];
        Opportunity obj =[Select Id,Name,NoISTNeeded__c from Opportunity where Name = 'test'];
        System.assertEquals(obj.Id,  objImplemServic[0].Related_Opportunity__c);
        System.assertEquals('N/A',objImplemServic[0].Implementation_Type__c);
        System.assertEquals('No IS Assigned',objImplemServic[0].IST_Status__c);
        System.assertEquals('No IS Assigned',objImplemServic[0].IST_Completed_Status__c);
        test.stoptest();
        
    }
      public static testMethod void TestGoToOpportunityLink1(){
         OpportunityImplementationAutomation notificationcnt1 = new OpportunityImplementationAutomation();
        system.assert(notificationcnt1.GoToOpportunityLink()!=null);
        User U1 = [Select Id,User_Region__c,Channel__c from User where Email = 'testclassDeveloperUserFake@pgi.com' LIMIT 1];
        System.debug('------------->'+U1.User_Region__c);
        system.runas(U1) {
            /*Cover wrapper code*/
            
            notificationcnt1.ViewData();
            for(OpportunityImplementationAutomation.oOpportunity obj : notificationcnt1.OpportunityList ){
                obj.selected = true;
            }
            notificationcnt1.CreateImpSerRecord();
            notificationcnt1.getSortDirection();
            notificationcnt1.setSortDirection('name');
            //notificationcnt1.setSortDirection('ASC');
            //notificationcnt1.GoToOpportunityLink();
        }
    }
}