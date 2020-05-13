@isTest
public class Test_PopulateParentEntityonCompanies{
    static testMethod void validateparententity(){
    
        PGi_Entity__c ent1 = new PGi_Entity__c(Name = 'ent1000');
        PGi_Entity__c ent2 = new PGi_Entity__c(Name = 'ent1001');
        PGi_Entity__c ent3 = new PGi_Entity__c(Name = 'ent1001');
    
        insert ent1;
        insert ent2;
        insert ent3;
            
        Test.startTest();
            PGi_Company__c comp1 = new PGi_Company__c(Name = 'conf1000', PGi_Entity_ID__c = 'ent10000'); 
            PGi_Company__c comp2 = new PGi_Company__c(Name = 'conf1001', PGi_Entity_ID__c = 'ent1000');
            PGi_Company__c comp3 = new PGi_Company__c(Name = 'conf1002', PGi_Entity_ID__c = 'ent1001');
            insert comp1;
            insert comp2;
            insert comp3;
            PGi_Company__c comp100 = [SELECT Name, PGi_Entity__c FROM PGi_Company__c WHERE Name = 'conf1000'];
            PGi_Company__c comp101 = [SELECT Name, PGi_Entity__c FROM PGi_Company__c WHERE Name = 'conf1001'];
            PGi_Company__c comp102 = [SELECT Name, PGi_Entity__c FROM PGi_Company__c WHERE Name = 'conf1002'];
           
            System.assertEquals(NULL, comp100.PGi_Entity__c);
            System.assertEquals(ent1.Id, comp101.PGi_Entity__c);
            System.assertEquals(NULL, comp102.PGi_Entity__c);
            update comp1;
        Test.stopTest();
    }
}