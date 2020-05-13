@isTest
public class PGi_ServiceCatalogValidatorUtilityTest {
    @testSetUp static void setup()
    {
        Account acc = new Account();
        acc.Name='Test1';
        Insert acc;
    }
    static testMethod void testvalidObjectName(){
        PGi_ServiceCatalogValidatorUtility obj = new PGi_ServiceCatalogValidatorUtility();
        System.assertEquals(false, obj.validObjectName('null'));
        System.assertEquals(true,obj.validObjectName('Account'));
    }
    static testMethod void testvalidFieldSet(){
        Account acc= [Select Id,Name from Account];
        PGi_ServiceCatalogValidatorUtility obj = new PGi_ServiceCatalogValidatorUtility();
        System.assertEquals(true, obj.validFieldSet('Account','Emergency_Account_Fields'));
        System.assertEquals(false, obj.validFieldSet('Account','test'));
        System.assertEquals(false, obj.validFieldSet('null','Name'));
    }
    static testMethod void testvalidField(){
        PGi_ServiceCatalogValidatorUtility obj = new PGi_ServiceCatalogValidatorUtility();
        System.assertEquals(true, obj.validField('Account','Name'));
        System.assertEquals(false, obj.validField('null','test'));
    }
    static testMethod void testvalidFieldInput(){
        PGi_ServiceCatalogValidatorUtility obj = new PGi_ServiceCatalogValidatorUtility();
        Datetime myDate =Date.today();
        String str=String.valueOf(myDate);
        obj.validFieldInput('Account','ABM_PES_Last_Change_Date__c',str);
        obj.validFieldInput('Account','Date_Provisioned__c',str);
        obj.validFieldInput('Account','Date_Provisioned__c','2019-11-12');
        System.assertEquals('true', obj.validFieldInput('Account','Name','Test1'));
        System.assertEquals('true', obj.validFieldInput('Account','Zendesk__createdUpdatedFlag__c','true'));
        System.assertEquals('true',  obj.validFieldInput('Account','Cumulative_Total_Booked__c','10'));
        System.assertEquals('true', obj.validFieldInput('Account','NumberOfEmployees','10'));
    }
    static testMethod void testvalidStaticResource(){
              PGi_ServiceCatalogValidatorUtility obj = new PGi_ServiceCatalogValidatorUtility();
        System.assertEquals(true, obj.validateStaticResource('A12_Alert','test'));
        System.assertEquals(false, obj.validateStaticResource('null','test'));
    }
}