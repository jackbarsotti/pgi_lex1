@isTest
public class Test_RollUpHelper{
    /* DEAD/UNMAINTAINED
    static testMethod void validaterolluphelper() {
            Opportunity testOppty123 = PGITestUtilities.getOpportunityDetails();
            testOppty123.StageName = 'Awareness';
            testOppty123.CloseDate = Date.today().addDays(10);
            insert testOppty123;
            Account testAcct123 = PGITestUtilities.getAccountDetails();
            testAcct123.NumberOfEmployees = 1000;
            insert testAcct123;
            CONMAN_Contract__c testContract123 = PGITestUtilities.getConManContractDetails(testAcct123.Id, testOppty123.Id);
            insert testContract123;      
            Offerings__c offr123 = new Offerings__c(Name='Test123', Licensed_Product__c=true, Unique_ID__c='1', Tab__c='N/A', Type__c='N/A');
            insert offr123;
            
            Test.startTest();
            
            LicenseSet__c lic123 = new LicenseSet__c(Name='Test123', Price__c=10, Enterprise_Name__c=offr123.Id, Subscription_License_Term_Months__c = 23,Number_of_Licensed_Named_Users__c=25,Opportunity__c=testOppty123.Id, PGi_Contract__c=testContract123.Id);
            insert lic123;
            testContract123 = [SELECT Total_ACV__c FROM CONMAN_Contract__c WHERE Id =:testContract123.Id];
            system.assertequals(3000,testcontract123.Total_ACV__c);
    
            Test.stopTest();
    }*/
}