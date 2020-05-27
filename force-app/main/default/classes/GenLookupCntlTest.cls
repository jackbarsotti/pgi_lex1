@isTest
public with sharing class GenLookupCntlTest {
    static testMethod void test(){
        Test.startTest();
        String searchString = 'Test';
        String sObjectAPIName = 'User';
        String fld_API_Text = 'Email';
        String fld_API_Val = 'Id';
        String fld_API_Search = 'Name';
        Integer limitVal = 5;
        Boolean isSOQL = false;
        String filter = '';
            GenLookupCntl.lookup(searchString, sObjectAPIName, fld_API_Text, fld_API_Val, fld_API_Search,  limitVal, isSOQL, filter);
        Test.stopTest();
    }
}