/**  
* \arg ClassName        : MachingRuleCreation_Test
* \arg JIRATicket       : 
* \arg CreatedOn        : 23/April/2019
* \arg LastModifiedOn   : 
* \arg CreatededBy      : Vijay
* \arg ModifiedBy       : 
* \arg Description      : Test class for MachingRuleCreation class
*/
@isTest
private class MachingRuleCreation_Test {
    
    static List<Matching_Rule__c> lstmatchingrule;
    static List<Matching_Rule_Criteria__c> lstmatchingrulecreteria; 
    static List<Matching_Rule_Criteria__c> lstRemoveRowmatchingrulecreteria;
    static Matching_Rule__c objMR;
    static Matching_Rule_Criteria__c objMRcreteria;
    
    static void createData(){
        
        Matching_Rule__c objMR1 = new Matching_Rule__c(Name = 'TestMR3', Object_Name__c = 'Account', Support_Text__c = 'Test_Support2', Evaluation_Order__c = '1 AND 2');
        INSERT objMR1;
        Matching_Rule_Criteria__c objMRcreteria1 = new Matching_Rule_Criteria__c(Matching_Rule__c = objMR1.Id, Field_API_Name__c = 'Name', Field_Operator__c = 'equals', Field_Type__c = 'STRING', Field_Value__c = 'vijay');
        INSERT objMRcreteria1;
        
        lstmatchingrule = new List<Matching_Rule__c>{new Matching_Rule__c(Name = 'TestMR001', Parent_Matching_Rule__c = objMR1.Id,Object_Name__c = 'Account', Support_Text__c = 'Test_Support001', Evaluation_Order__c = '1'),
            new Matching_Rule__c(Name = 'TestMR002', Object_Name__c = 'Contact',  Parent_Matching_Rule__c = objMR1.Id, Support_Text__c = 'Test_Support002', Evaluation_Order__c = '1 AND 2')};
                insert lstmatchingrule;
        
        lstmatchingrulecreteria = new List<Matching_Rule_Criteria__c>{new Matching_Rule_Criteria__c(Matching_Rule__c = lstmatchingrule[0].Id, Field_API_Name__c =  'AccountId', Field_Operator__c = 'greaterthan', Field_Type__c = 'REFERENCE', Field_Value__c = '0012546845741852'),
            new Matching_Rule_Criteria__c(Matching_Rule__c = lstmatchingrule[1].Id, Field_API_Name__c = 'Price', Field_Operator__c = 'greaterThan', Field_Type__c = 'CURRENCY', Field_Value__c = '100')};
                insert lstmatchingrulecreteria;
        
        lstRemoveRowmatchingrulecreteria = new List<Matching_Rule_Criteria__c>{new Matching_Rule_Criteria__c(Matching_Rule__c = lstmatchingrule[0].Id, Field_API_Name__c =  'AccountId', Field_Operator__c = 'greaterthan', Field_Type__c = 'REFERENCE', Field_Value__c = '0012546845741852'),
            new Matching_Rule_Criteria__c(Matching_Rule__c = lstmatchingrule[1].Id, Field_API_Name__c = 'Price', Field_Operator__c = 'greaterThan', Field_Type__c = 'CURRENCY', Field_Value__c = '100')};
                insert lstRemoveRowmatchingrulecreteria;
        
        objMR = new Matching_Rule__c(Name = 'TestMR2', Object_Name__c = 'Opportunity', Parent_Matching_Rule__c = objMR1.Id, Support_Text__c = 'Test_Support2', Evaluation_Order__c = '1 AND 2');
        objMRcreteria = new Matching_Rule_Criteria__c(Field_API_Name__c = 'Name', Field_Operator__c = 'equals', Field_Type__c = 'STRING', Field_Value__c = 'vijay');
        
    }
    
    static testMethod void method1() {
        createData();
        MachingRuleCreation.getallobjects();
        MachingRuleCreation.getALLFields('Account');
        MachingRuleCreation.getRelatedChildObjects('Account');
        MachingRuleCreation.deleteMatchingRuleRecord(lstmatchingrule[0].Id);
        MachingRuleCreation.getMatchingRuleCreteria(lstmatchingrule[0].Id);
    }
    
    static testMethod void method_createRecordsId() {
        createData();
        String recordId  = null;
        
        List<Id> lstDeleteIds = new List<Id>();
        for(Matching_Rule_Criteria__c objMR : lstRemoveRowmatchingrulecreteria){
            lstDeleteIds.add(objMR.Id);
        }
        
        Matching_Rule__c objMR2 = new Matching_Rule__c(Name = 'TestMR2', Object_Name__c = 'Opportunity', Support_Text__c = 'Test_Support2', Evaluation_Order__c = '1 AND 2');
        MachingRuleCreation.createNewRecords(JSON.serialize(objMR), '['+JSON.serialize(objMRcreteria)+']', lstDeleteIds);    
        MachingRuleCreation.createNewRecords(JSON.serialize(objMR), '['+JSON.serialize(objMRcreteria)+']', lstDeleteIds);  
        MachingRuleCreation.createNewRecords(JSON.serialize(objMR2), '['+JSON.serialize(objMRcreteria)+']', lstDeleteIds);  

    }
    
}