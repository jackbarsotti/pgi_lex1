@isTest
public class CeligoSyncANDCeligoAccountSyncPollerTest {
    @testSetup static void setup(){
        Account acc = new Account(
            Name = 'TestAccount',
            NetSuite_Pull__c = false
        );
        INSERT acc;
        
        Opportunity ObjOppor = new Opportunity(
            Name = 'TestOppotunity',
            StageName = 'Purchase',
            CloseDate = Date.newInstance(2019, 11, 22),
            AccountId = acc.Id
        );
        INSERT ObjOppor;
        
    }
    
    static testMethod void TestCeligoAccountSyncPoller() {
        CeligoAccountSyncPoller ObjCeligoAccSyncPoller = new CeligoAccountSyncPoller();
         Account acc = [SELECT Id,Name FROM Account WHERE Name = 'TestAccount'];
        ApexPages.Standardcontroller StController  = new Apexpages.Standardcontroller(acc);
        PageReference pageRef = Page.account_status;
        pageRef.getParameters().put('whence', acc.Id);
        Test.setCurrentPageReference(pageRef);
      	ObjCeligoAccSyncPoller.redirect(acc.Id);
        ObjCeligoAccSyncPoller.checkSyncStatus();
        ObjCeligoAccSyncPoller.getMessage();
        System.assertEquals('No Errors',ObjCeligoAccSyncPoller.getErrorMessage());
        
        
    }
    static testMethod void TestCeligoSyncPoller(){
        Account acc = [SELECT Id,Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opportunityObj =[SELECT Id,AccountId FROM Opportunity WHERE AccountId=:acc.Id];
        CeligoAccountSyncPoller ObjCeligoSyncPoller = new CeligoAccountSyncPoller();
        Boolean show = true;
        Boolean error = false;
        ObjCeligoSyncPoller.getShowLoader();
        ObjCeligoSyncPoller.setShowLoader(show);
        ObjCeligoSyncPoller.setShowError(error);
        ObjCeligoSyncPoller.getOpportunityById(opportunityObj.Id);
        ObjCeligoSyncPoller.getAccountById(acc.Id);
        ObjCeligoSyncPoller.getShowError();
        System.assertEquals(false,ObjCeligoSyncPoller.getShowError());
        
    }
}