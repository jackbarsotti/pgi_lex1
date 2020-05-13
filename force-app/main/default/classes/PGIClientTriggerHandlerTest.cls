@IsTest
public class PGIClientTriggerHandlerTest {
	@IsTest
    public static void testMatchOnCompanyID(){
    
        PGi_Entity__c ent = new PGi_Entity__c(Name = 'ent1000');
        PGi_Company__c comp1 = new PGi_Company__c(Name = 'comp1000', PGi_Entity__c = ent.Id);
        PGi_Company__c comp2 = new PGi_Company__c(Name = 'comp1001', PGi_Entity__c = ent.Id);
        PGi_Company__c comp3 = new PGi_Company__c(Name = 'comp1001', PGi_Entity__c = ent.Id);
        insert ent;
        insert comp1;
        insert comp2;
        insert comp3;
            
        Test.startTest();
            PGi_Client__c cli1 = new PGi_Client__c(Name = 'cli1000', PGi_Company_ID__c = 'comp10000'); 
            PGi_Client__c cli2 = new PGi_Client__c(Name = 'cli1001', PGi_Company_ID__c = 'comp1000');
            PGi_Client__c cli3 = new PGi_Client__c(Name = 'cli1002', PGi_Company_ID__c = 'comp1001');
            insert cli1;
            insert cli2;
            insert cli3;
            PGi_Client__c cli100 = [SELECT Name, PGi_Company__c FROM PGi_Client__c WHERE Name = 'cli1000'];
            PGi_Client__c cli101 = [SELECT Name, PGi_Company__c FROM PGi_Client__c WHERE Name = 'cli1001'];
            PGi_Client__c cli102 = [SELECT Name, PGi_Company__c FROM PGi_Client__c WHERE Name = 'cli1002'];
           
            system.assertequals(NULL, cli100.PGi_Company__c);
            system.assertequals(comp1.Id, cli101.PGi_Company__c);
            system.assertequals(NULL, cli102.PGi_Company__c);
            
            update cli1;
        Test.stopTest();
    }
}