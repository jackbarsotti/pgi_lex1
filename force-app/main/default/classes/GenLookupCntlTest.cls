@isTest
public with sharing class GenLookupCntlTest {
    static testMethod void testLookup(){
        Test.startTest();
        String searchString = 'Test';
        String sObjectAPIName = 'Contact';
        String fld_API_Text = 'Name';
        String fld_API_Val = 'Id';
        String fld_API_Search = 'Name';
        Integer limitVal = 3;
        Boolean isSOQL = false;
        String filter = '';

        Contact conObj = New Contact(LastName='Test');
        INSERT conObj;
        Contact conObj2 = New Contact(LastName='Test123');
        INSERT conObj2;
        Contact conObj3 = New Contact(LastName='Test1345');
        INSERT conObj3;
             GenLookUpResult[] genLookUpResults=GenLookupCntl.lookup(searchString, sObjectAPIName, fld_API_Text, fld_API_Val, fld_API_Search,  limitVal, isSOQL, filter);
             GenLookUpResult[] genLookUpResult=GenLookupCntl.lookup(searchString, sObjectAPIName, fld_API_Text, fld_API_Val, fld_API_Search,  limitVal, true, filter);
            System.assertEquals(searchString, [SELECT Id,Name FROM Contact WHERE Id =: conObj.Id].Name);
            System.assert(genLookUpResult!=null);
        Test.stopTest();
    }
    
    static testMethod void testLookupSecond(){
        Test.startTest();
        Contact conObj = New Contact(LastName='TestContact');
        INSERT conObj;
        
        String searchString = 'TestCo';
        String sObjectAPIName = 'Contact';
        String fld_API_Text = 'Name';
        String fld_API_Val = 'Id';
        String fld_API_Search ='Name';
        Integer limitVal = 1;
        Boolean isSOQL = false;
        String filter = '';

            GenLookUpResult[] genLookUpResults=GenLookupCntl.lookup(searchString, sObjectAPIName, fld_API_Text, fld_API_Val, fld_API_Search,  limitVal, isSOQL, filter);
            System.assert(genLookUpResults!=null);
            
        Test.stopTest();
    }
}