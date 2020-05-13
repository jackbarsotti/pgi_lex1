/**  
* \arg ClassName        : MatchingService_Test
* \arg JIRATicket       : 
* \arg CreatedOn        : 23/April/2019
* \arg LastModifiedOn   : 
* \arg CreatededBy      : Vijay
* \arg ModifiedBy       : 
* \arg Description      : Test class for MatchingService class
*/
@isTest
private class MatchingService_Test {
    
    static List<Matching_Rule__c> lstmatchingrule;
	static List<Matching_Rule_Criteria__c> lstmatchingrulecreteria;
    static List<Matching_Rule__c> lstchildmatchingrule;
	static List<Matching_Rule_Criteria__c> lstchildmatchingrulecreteria;
    static Account objAcc;
    static Contact objCont;
    
    static void createData(){
        	
        	objAcc = new Account(Name = 'test_Acc1');
        	INSERT objAcc;
        
        	objCont = new Contact(LastName = 'test_Cont1', AccountId = objAcc.Id);
        	INSERT objCont;
        
            lstmatchingrule = new List<Matching_Rule__c>{new Matching_Rule__c(Name = 'Vijay',Object_Name__c = 'Account', Support_Text__c = 'Test_Support001', Evaluation_Order__c = '1 AND 2 AND 3 AND 4 AND 5')};
            insert lstmatchingrule;
        
        	lstmatchingrulecreteria = new List<Matching_Rule_Criteria__c>{new Matching_Rule_Criteria__c(Line_Number__c = 1 ,Matching_Rule__c = lstmatchingrule[0].Id, Field_API_Name__c =  'Name', Field_Operator__c = 'greaterthan', Field_Type__c = 'REFERENCE', Field_Value__c = '0012546845741852'),
                new Matching_Rule_Criteria__c(Line_Number__c = 2 ,Matching_Rule__c = lstmatchingrule[0].Id, Field_API_Name__c = 'Site', Field_Operator__c = 'equals', Field_Type__c = 'TEST', Field_Value__c = 'test0021'),
                new Matching_Rule_Criteria__c(Line_Number__c = 3 ,Matching_Rule__c = lstmatchingrule[0].Id, Field_API_Name__c = 'AccountSource', Field_Operator__c = 'lessThan', Field_Type__c = 'PICKLIST', Field_Value__c = 'test01'),
                new Matching_Rule_Criteria__c(Line_Number__c = 4 ,Matching_Rule__c = lstmatchingrule[0].Id, Field_API_Name__c = 'Phone', Field_Operator__c = 'lessThan', Field_Type__c = 'PHONE', Field_Value__c = '9888825558'),
                new Matching_Rule_Criteria__c(Line_Number__c = 5 ,Matching_Rule__c = lstmatchingrule[0].Id, Field_API_Name__c = 'SLAExpirationDate__c', Field_Operator__c = 'greaterThan', Field_Type__c = 'DATE', Field_Value__c = 'Aug 19, 2019')};
            insert lstmatchingrulecreteria;
        
        	lstchildmatchingrule = new List<Matching_Rule__c>{new Matching_Rule__c(Parent_Matching_Rule__c = lstmatchingrule[0].Id, Name = 'Child_MR',Object_Name__c = 'Contact', Relationship_Name__c = 'Contacts' ,Support_Text__c = 'Test_ChildSupport001', Evaluation_Order__c = '1')};
            insert lstchildmatchingrule;
        
        	lstchildmatchingrulecreteria = new List<Matching_Rule_Criteria__c>{new Matching_Rule_Criteria__c(Line_Number__c = 1 ,Matching_Rule__c = lstchildmatchingrule[0].Id, Field_API_Name__c =  'LastName', Field_Operator__c = 'equals', Field_Type__c = 'Text', Field_Value__c = 'test_Cont1')};
                //new Matching_Rule_Criteria__c(Line_Number__c = 2 ,Matching_Rule__c = lstchildmatchingrule[0].Id, Field_API_Name__c = 'OtherStreet', Field_Operator__c = 'equals', Field_Type__c = 'TEXTAREA', Field_Value__c = 'Bengalore')
            insert lstchildmatchingrulecreteria;
         
    }
    
    static testMethod void method1() {
        createData();
        MatchingService.processRecord('Account', objAcc.Id);
        MatchingService.getallobjects();
        
    }
    
    static testMethod void methodChildMatch() {
        Account objAcc1 = new Account(Name = 'Rule_001');
        INSERT objAcc1;
        Contact objCont1 = new Contact(LastName = 'Rule_002', AccountId = objAcc1.Id);
        INSERT objCont1;
        
        Matching_Rule__c objMR = new Matching_Rule__c(Name = 'test_MRRule',Object_Name__c = 'Account' ,Support_Text__c = 'Support help for Rule_001', Evaluation_Order__c = '1');
        INSERT objMR;
        
        Matching_Rule_Criteria__c objMRcreteria = new Matching_Rule_Criteria__c(Line_Number__c = 1 ,Matching_Rule__c = objMR.Id, Field_API_Name__c = 'Name', Field_Operator__c = 'equals', Field_Type__c = 'TEXT', Field_Value__c = 'Rule_001');
        INSERT objMRcreteria;
        
        Matching_Rule__c objChild_MR = new Matching_Rule__c(Parent_Matching_Rule__c = objMR.Id, Name = 'test_Child_MRRule', Object_Name__c = 'Contact' ,Relationship_Name__c = 'Contacts' ,Support_Text__c = 'Support help for Child Matching Rule_002', Evaluation_Order__c = '1');
        INSERT objChild_MR;
        
        Matching_Rule_Criteria__c objChild_MRcreteria = new Matching_Rule_Criteria__c(Line_Number__c = 1 ,Matching_Rule__c = objChild_MR.Id, Field_API_Name__c = 'LastName', Field_Operator__c = 'equals', Field_Type__c = 'TEXT', Field_Value__c = 'Rule_002');
        INSERT objChild_MRcreteria;
        
        MatchingService.processRecord('Account', objAcc1.Id);
    }
    
    static testMethod void methodChilddontMatch() {
        Account objAcc1 = new Account(Name = 'Rule_001');
        INSERT objAcc1;
        Contact objCont1 = new Contact(LastName = 'Rule_002', AccountId = objAcc1.Id);
        INSERT objCont1;
        
        Matching_Rule__c objMR = new Matching_Rule__c(Name = 'test_MRRule',Object_Name__c = 'Account' ,Support_Text__c = 'Support help for Rule_001', Evaluation_Order__c = '1');
        INSERT objMR;
        
        Matching_Rule_Criteria__c objMRcreteria = new Matching_Rule_Criteria__c(Line_Number__c = 1 ,Matching_Rule__c = objMR.Id, Field_API_Name__c = 'Name', Field_Operator__c = 'equals', Field_Type__c = 'TEXT', Field_Value__c = 'Rule_001');
        INSERT objMRcreteria;
        
        Matching_Rule__c objChild_MR = new Matching_Rule__c(Parent_Matching_Rule__c = objMR.Id, Name = 'test_Child_MRRule', Object_Name__c = 'Contact' ,Relationship_Name__c = 'Contacts' ,Support_Text__c = 'Support help for Child Matching Rule_002', Evaluation_Order__c = '1');
        INSERT objChild_MR;
        
        Matching_Rule_Criteria__c objChild_MRcreteria = new Matching_Rule_Criteria__c(Line_Number__c = 1 ,Matching_Rule__c = objChild_MR.Id, Field_API_Name__c = 'LastName', Field_Operator__c = 'equals', Field_Type__c = 'TEXT', Field_Value__c = 'Rule_00222');
        INSERT objChild_MRcreteria;
        
        MatchingService.processRecord('Account', objAcc1.Id);
        MatchingService.validateRule(String.valueOf(objMR.Id));
    }
    
}