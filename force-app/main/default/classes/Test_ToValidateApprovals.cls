@isTest

public class Test_ToValidateApprovals{

static testMethod void tovalidateapprovals() {

Account acc1 = new Account();
        acc1.Name = 'Acc123456789';
        acc1.BillingCountryCode = 'US';
        acc1.BillingStateCode = 'CA';
        acc1.BillingStreet = 'Street1';
        acc1.BillingPostalCode = '12345';
insert acc1;

Product_Engagement_Request__c per123 = new Product_Engagement_Request__c();
per123.Customer_Type__c = 'Existing Client';
per123.Customer_Engagement_Request__c = 'Customer Specific Request';
per123.PGi_Product__c = 'imeet';
per123.Related_Account__c = acc1.id;
per123.Status__c='New';
per123.Please_describe_in_detail_the__c = 'test';
per123.Business_Customer_Value__c = 'test';
per123.Key_Internal_or_External_Drivers__c = 'test';
insert per123;

Test.StartTest();
per123.Please_describe_in_detail_the__c = 'updated';

update per123;

Test.StopTest();

}
}