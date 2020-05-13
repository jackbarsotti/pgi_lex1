@isTest
public class Test_AutoDeleteChildrecords{
    static testMethod void deletechildrecs(){
    
        PGi_Entity__c ent = new PGi_Entity__c(name='ent1000');
        PGi_Company__c comp = new PGi_Company__c(name='comp1000',PGi_Entity__c=ent.id);
        PGi_Client__c cli = new PGi_Client__c(name='cli1000',PGi_Company__c=comp.id);
        PGi_Conference__c conf = new PGi_Conference__c(name='conf1000',PGi_Client__c=cli.id);
                
        insert ent;
        insert comp;
        insert cli;
        insert conf;
                    
        Test.startTest();
            delete ent;
            delete comp;
            delete cli;
           
                       
        Test.stopTest();
    }
}