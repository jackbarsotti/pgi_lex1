@IsTest
public class PGIConferenceTriggerHandlerTest {
	@isTest
    public static void testMatchOnClientID(){
    
        PGi_Entity__c ent = new PGi_Entity__c(Name = 'ent1000');
        PGi_Company__c comp = new PGi_Company__c(Name = 'comp1000', PGi_Entity__c = ent.id);
        PGi_Client__c cli1 = new PGi_Client__c(Name = 'cli1000', PGi_Company__c = comp.id);
        PGi_Client__c cli2 = new PGi_Client__c(Name = 'cli1001', PGi_Company__c = comp.id);
        PGi_Client__c cli3 = new PGi_Client__c(Name = 'cli1001', PGi_Company__c = comp.id);
        
        insert ent;
        insert comp;
        insert cli1;
        insert cli2;
        insert cli3;
            
        Test.startTest();
            PGi_Conference__c conf1 = new PGi_Conference__c(Name = 'conf1000', Client_ID__c = 'cli10000'); 
            PGi_Conference__c conf2 = new PGi_Conference__c(Name = 'conf1001', Client_ID__c = 'cli1000');
            PGi_Conference__c conf3 = new PGi_Conference__c(Name = 'conf1002', Client_ID__c = 'cli1001');
            insert conf1;
            insert conf2;
            insert conf3;
            PGi_Conference__c conf100 = [SELECT Name,PGi_Client__c FROM PGi_Conference__c WHERE Name = 'conf1000'];
            PGi_Conference__c conf101 = [SELECT Name,PGi_Client__c FROM PGi_Conference__c WHERE Name = 'conf1001'];
            PGi_Conference__c conf102 = [SELECT Name,PGi_Client__c FROM PGi_Conference__c WHERE Name = 'conf1002'];
           
            System.assertEquals(NULL, conf100.PGi_Client__c);
            System.assertEquals(cli1.id, conf101.PGi_Client__c);
            System.assertEquals(NULL, conf102.PGi_Client__c);
            
            update conf1;
            
        Test.stopTest();
    }
}