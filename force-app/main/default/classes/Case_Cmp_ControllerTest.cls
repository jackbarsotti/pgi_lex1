@isTest
public class Case_Cmp_ControllerTest {
    
    @isTest static void testCaseCmpMethods(){
        
        Case_SLA_Exception_Rules__c caseRulesObj=new Case_SLA_Exception_Rules__c();
        caseRulesObj.Name='testCaseRule';
        caseRulesObj.Rule_Order__c=10;
        insert caseRulesObj;
        
        List<Case_SLA_Exception_Rule_Conditions__c> caseExcList=new List<Case_SLA_Exception_Rule_Conditions__c>();
        Case_SLA_Exception_Rule_Conditions__c caseExcObj=new Case_SLA_Exception_Rule_Conditions__c();
        caseExcObj.Field_Name__c='Name';
        caseExcObj.Field_Value__c='test Account';
        caseExcObj.Field_Operator__c='Equals';
        caseExcObj.Object_Name__c='Account';
        caseExcObj.Field_Label__c='Account Name';
        // caseExcObj.Field_API_Name__c='Name';
        caseExcObj.Name='testCaseExcRule1';
        caseExcObj.Case_SLA_Exception_Rules__c=caseRulesObj.Id;
        caseExcList.add(caseExcObj);
        Case_SLA_Exception_Rule_Conditions__c caseExcptObj=new Case_SLA_Exception_Rule_Conditions__c();
        caseExcptObj.Name='testCaseExcRule2';
        caseExcptObj.Case_SLA_Exception_Rules__c=caseRulesObj.Id;
        caseExcptObj.Field_Name__c='Name';
        caseExcptObj.Field_Value__c='test Account2';
        caseExcptObj.Field_Operator__c='Equals';
        caseExcptObj.Object_Name__c='Account';
        caseExcptObj.Field_Label__c='Account Name';
        caseExcList.add(caseExcptObj);
        insert caseExcList;
        
        Test.startTest();
        Case_Cmp_Controller.wrappOTERuleObjects testName = new Case_Cmp_Controller.wrappOTERuleObjects(caseRulesObj,caseExcList);
        
        //  Case_Cmp_Controller caseCmpObj=new Case_Cmp_Controller();
        Case_Cmp_Controller.getALLFields('Account');
        String keyPrfixVal=Case_Cmp_Controller.getObjectKeyPrefix();
         String oteRecords=Case_Cmp_Controller.getOTERecords(caseRulesObj.Id);
        Case_Cmp_Controller.deleteRecord(caseRulesObj.Id);
        List<String> lstString=Case_Cmp_Controller.getRoleValues();
        System.assert(lstString!=null);
        System.assert(oteRecords!=null);
        System.assert(keyPrfixVal!=null);
        Test.stopTest();
        
    }
    
    @isTest static void testSaveOppyTeamEngineRecords(){
     
         Case_SLA_Exception_Rules__c caseRulesObj=new Case_SLA_Exception_Rules__c();
        caseRulesObj.Name='testCaseRule';
        caseRulesObj.Rule_Order__c=10;
        insert caseRulesObj;
        
        List<Case_SLA_Exception_Rule_Conditions__c> caseExcList=new List<Case_SLA_Exception_Rule_Conditions__c>();
        Case_SLA_Exception_Rule_Conditions__c caseExcObj=new Case_SLA_Exception_Rule_Conditions__c();
        caseExcObj.Field_Name__c='Name';
        caseExcObj.Field_Value__c='test Account';
        caseExcObj.Field_Operator__c='Equals';
        caseExcObj.Object_Name__c='Account';
        caseExcObj.Field_Label__c='Account Name';
        // caseExcObj.Field_API_Name__c='Name';
        caseExcObj.Name='testCaseExcRule1';
        caseExcObj.Case_SLA_Exception_Rules__c=caseRulesObj.Id;
        caseExcList.add(caseExcObj);
        Case_SLA_Exception_Rule_Conditions__c caseExcptObj=new Case_SLA_Exception_Rule_Conditions__c();
        caseExcptObj.Name='testCaseExcRule2';
        caseExcptObj.Case_SLA_Exception_Rules__c=caseRulesObj.Id;
        caseExcptObj.Field_Name__c='Name';
        caseExcptObj.Field_Value__c='test Account2';
        caseExcptObj.Field_Operator__c='Equals';
        caseExcptObj.Object_Name__c='Account';
        caseExcptObj.Field_Label__c='Account Name';
        caseExcList.add(caseExcptObj);
        insert caseExcList;
        
       
        string OppteamMember=JSON.serialize(caseRulesObj);
            List<OT_Rule__c> oTRuleList=new List<OT_Rule__c>();
            OT_Rule__c oTRuleObj=new OT_Rule__c();
            oTRuleObj.Field_Name__c='Name';
            oTRuleObj.Field_Value__c='test Account';
            oTRuleObj.Field_Operator__c='Equals';
            oTRuleObj.Object_Name__c='Account';
            oTRuleObj.Name='testOppRule1';
            oTRuleList.add(oTRuleObj);
            OT_Rule__c oTRuleObj2=new OT_Rule__c();
            oTRuleObj2.Name='testOppRule2';
            oTRuleObj2.Field_Name__c='Name';
            oTRuleObj2.Field_Value__c='test Contact';
            oTRuleObj2.Field_Operator__c='Equals';
            oTRuleObj2.Object_Name__c='Contact';
            
            oTRuleList.add(oTRuleObj2);
            OT_Rule__c oTRuleObj3=new OT_Rule__c();
            oTRuleObj3.Name='testOppRule3';
            oTRuleObj3.Field_Name__c='Name';
            oTRuleObj3.Field_Value__c='test Contact2';
            oTRuleObj3.Field_Operator__c='Equals';
            oTRuleObj3.Object_Name__c='Contact';
            oTRuleList.add(oTRuleObj3);
            insert oTRuleList;
            List<Id> oppRuleDelIds=new List<Id>(); 
            List<OT_Rule__c> oppRuleList=new List<OT_Rule__c>();
            oppRuleList=[SELECT Id,Name FROM OT_Rule__c LIMIT 2];
            system.debug('>>>oppRuleList'+oppRuleList);
            for(OT_Rule__c Ot:oppRuleList){
                oppRuleDelIds.add(Ot.Id);
            }
            System.debug('oppRuleDelIds: ' + oppRuleDelIds);
           
             string oppTeamRul=JSON.serialize(caseExcList);
            Test.startTest();
            try
            {
               string retRecords=Case_Cmp_Controller.saveOppyTeamEngineRecords(OppteamMember,oppTeamRul,oppRuleDelIds);
               System.assert(retRecords!=null);
            }
            catch(exception e)
            {
            } 
            
            Test.stopTest();
            
            
        
    }
}