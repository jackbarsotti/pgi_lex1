@isTest
public with sharing class GenLookupCntlTest {
    static testMethod void test(){
        Test.startTest();
        String searchString = 'Test';
        String sObjectAPIName = 'Contact';
        String fld_API_Text = 'Name';
        String fld_API_Val = 'Id';
        String fld_API_Search = 'Name';
        Integer limitVal = 5;
        Boolean isSOQL = false;
        String filter = '';

        Contact con = New Contact(LastName='Test');
        insert con;
            GenLookupCntl.lookup(searchString, sObjectAPIName, fld_API_Text, fld_API_Val, fld_API_Search,  limitVal, isSOQL, filter);
            GenLookupCntl.lookup(searchString, sObjectAPIName, fld_API_Text, fld_API_Val, fld_API_Search,  limitVal, true, filter);
            System.assertEquals(searchString, [SELECT Id,Name FROM Contact WHERE Id =: con.Id].Name);
        Test.stopTest();
    }
}