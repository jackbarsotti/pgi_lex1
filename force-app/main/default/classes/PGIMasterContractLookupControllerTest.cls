@isTest
public class PGIMasterContractLookupControllerTest {
    /*
    @testSetup static void setup() {
        PGITestUtilities.disableSalesWings();
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
                         ProfileId = p.Id
                        ); 
        insert uu; 
        Account accountObj= new Account();
        accountObj.Name='Test';
        Insert accountObj;
        Contact con = new Contact();
        //con.RecordTypeId=RecordTypeId;
        con.AccountId=accountObj.Id;
        con.LastName='Test';
        con.Email='Test@q.com';
        con.Title='Title';
        con.Language_Preference__c='FR';
        Insert con;
        
        Opportunity opporObj = new Opportunity();
        opporObj.AccountId =accountObj.Id;
        opporObj.Name='Test1';
        opporObj.Opportunity_Source_Open__c='Customer';
        opporObj.StageName='Prospecting';
        opporObj.CloseDate=Date.today();
        opporObj.Has_PGI_Contract__c =false;
        opporObj.Has_PGI_Contract__c =false;
        Insert opporObj;
        
        Quote quote=new Quote();
        quote.Name='Test quote';
        quote.ContactId=con.Id;
        quote.OpportunityId=opporObj.Id;
        quote.Status='Quote InProgress';
        Insert quote;
       
        
    }
    static testMethod void testMethod1(){ 
        User userObj = [Select Id from User Where Email = 'test@pgi.com'];
        System.runAs(userObj){
            Account accobj=[Select Id from Account Where Name='Test'];
           
            ApexPages.currentPage().getParameters().put('lksrch','Test1');
            ApexPages.currentPage().getParameters().put('accountId',String.valueOf(accobj.Id));
            ApexPages.currentPage().getParameters().put('quoteType','Existing');
            PGIMasterContractLookupController obj = new PGIMasterContractLookupController();
           
        }
    }
    static testMethod void testMethod2(){ 
        User userObj = [Select Id from User Where Email = 'test@pgi.com'];
        System.runAs(userObj){
            Account accobj=[Select Id from Account Where Name='Test'];
            
            ApexPages.currentPage().getParameters().put('lksrch','TestP');
            ApexPages.currentPage().getParameters().put('accountId',String.valueOf(accobj.Id));
            ApexPages.currentPage().getParameters().put('quoteType','Existing Customer – Rate Change');
            PGIMasterContractLookupController obj = new PGIMasterContractLookupController();
            
    }
    static testMethod void testMethod3(){ 
        User userObj = [Select Id from User Where Email = 'test@pgi.com'];
        System.runAs(userObj){
            Account accobj=[Select Id from Account Where Name='Test'];
            
            ApexPages.currentPage().getParameters().put('lksrch',null);
            ApexPages.currentPage().getParameters().put('accountId',String.valueOf(accobj.Id));
            ApexPages.currentPage().getParameters().put('quoteType','Existing Customer – Rate Change');
            ApexPages.currentPage().getParameters().put('frm','Account');
            ApexPages.currentPage().getParameters().put('txt','Test12');
            PGIMasterContractLookupController obj = new PGIMasterContractLookupController();
            obj.search();
            System.assertEquals('Account', obj.getFormTag());
            System.assertEquals('Test12', obj.getTextBox());
        }
    }*/
}