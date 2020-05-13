@isTest
public with sharing class Case_ConditionCheckTest {
    public Case_ConditionCheckTest() {

    }
    @testSetup
    static void setData(){
        Case cse = new Case();
        cse.Subject = 'Test';
        cse.Status = 'New';
        insert cse;

        Case_SLA_Exception_Rules__c cseExpRule = new Case_SLA_Exception_Rules__c();
        cseExpRule.Name = 'test1';
        cseExpRule.Rule_Order__c = 1.0;
        // cseExpRule.Evaluation_Order__c = '1';
        insert cseExpRule;

        // Case_SLA_Exception_Rule_Conditions__c cserulecond = new Case_SLA_Exception_Rule_Conditions__c();
        // cserulecond.Name = 'test rule condition';
        // cserulecond.Case_SLA_Exception_Rules__c = cseExpRule.Id;
        // insert cserulecond;
    }
    static testMethod void testElse() {
        Case caseObj = new Case();
        caseObj.Subject = 'Test case1';
        caseObj.Status = 'Working';
        caseObj.Origin = 'Phone';
        insert caseObj;
    
        Case_SLA_Exception_Rules__c cseExpRule = new Case_SLA_Exception_Rules__c();
        cseExpRule.Name = 'test2';
        cseExpRule.Rule_Order__c = 1.0;
        cseExpRule.Evaluation_Order__c = '1';
        insert cseExpRule;
        Case_SLA_Exception_Rule_Conditions__c cserulecond = new Case_SLA_Exception_Rule_Conditions__c();
        cserulecond.Name = 'Test Rule Condition 1';
        cserulecond.Object_Name__c = 'Owner';
        cserulecond.Field_Name__c = 'Name';
        cserulecond.Field_Type__c = 'TEXTAREA';
        cserulecond.Field_Value__c = 'Test Account';
        cserulecond.Field_Operator__c = 'equals';
        cserulecond.Case_SLA_Exception_Rules__c = cseExpRule.Id;
        insert cserulecond;
        Case_SLA_Exception_Rule_Conditions__c ruleCond = [SELECT Id, Name, Object_Name__c, Field_Name__c, Field_API_Name__c, Field_Operator__c, Field_Type__c, Field_Value__c, Relationship_Name__c, Case_SLA_Exception_Rules__c FROM Case_SLA_Exception_Rule_Conditions__c WHERE Id =: cserulecond.ID ];
        Case_ConditionCheck.checkCondition(caseObj, ruleCond);
        System.assertEquals(false,Case_ConditionCheck.checkCondition(caseObj, cserulecond));
    } 
// For Date Type
    static testMethod void testDate() {
        Test.startTest();
        Account ac = new Account();
        ac.Name='2020-04-15';
        insert ac;
    Case caseObj = new Case();
    caseObj.AccountId = ac.Id;
    caseObj.Subject = 'Test case';
    caseObj.Status = 'Working';
    insert caseObj;

    Case_SLA_Exception_Rules__c cseExpRule = new Case_SLA_Exception_Rules__c();
    cseExpRule.Name = 'test1';
    cseExpRule.Rule_Order__c = 1.0;
    cseExpRule.Evaluation_Order__c = '1';
    insert cseExpRule;

    Case_SLA_Exception_Rule_Conditions__c cserulecond = new Case_SLA_Exception_Rule_Conditions__c();
    cserulecond.Name = 'Test Rule Condition';
    cserulecond.Object_Name__c = 'Account';
    cserulecond.Field_Name__c = 'Name';
    cserulecond.Field_Type__c = 'DATE';
    cserulecond.Field_Value__c = '2020-04-15';
    cserulecond.Field_Operator__c = 'equals';
    cserulecond.Case_SLA_Exception_Rules__c = cseExpRule.Id;
    insert cserulecond;
    Case_SLA_Exception_Rule_Conditions__c ruleCond = [SELECT Id, Name, Object_Name__c, Field_Name__c, Field_API_Name__c, Field_Operator__c, Field_Type__c, Field_Value__c, Relationship_Name__c, Case_SLA_Exception_Rules__c FROM Case_SLA_Exception_Rule_Conditions__c WHERE Id =: cserulecond.ID ];
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'notEqual';
    ruleCond.Field_Value__c = '2020-04-16';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'greaterThan';
    ruleCond.Field_Value__c = '2020-04-17';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'lessOrEqual';
    ruleCond.Field_Value__c = '2020-04-15';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'lessThan';
    ruleCond.Field_Value__c = '2020-04-12';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'greaterOrEqual';
    ruleCond.Field_Value__c = '2020-04-15';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    System.assertEquals(true,Case_ConditionCheck.checkCondition(caseObj, ruleCond));

    // For Boolean Type
    Account acc = [SELECT Id,Name FROM Account WHERE Name = '2020-04-15'];
    acc.Name = 'True';
    update acc;
    ruleCond.Field_Type__c = 'BOOLEAN';
    ruleCond.Field_Operator__c = 'equals';
    ruleCond.Field_Value__c = 'True';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'notEqual';
    ruleCond.Field_Value__c = 'false';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    System.assertEquals(true,Case_ConditionCheck.checkCondition(caseObj, ruleCond));
    Test.stopTest();
    }

    static testMethod void testDouble() {
        Test.startTest();
        Account ac = new Account();
        ac.Name='55.0';
        insert ac;
    Case caseObj = new Case();
    caseObj.AccountId = ac.Id;
    caseObj.Subject = 'Test case';
    caseObj.Status = 'Working';
    insert caseObj;

    Case_SLA_Exception_Rules__c cseExpRule = new Case_SLA_Exception_Rules__c();
    cseExpRule.Name = 'test1';
    cseExpRule.Rule_Order__c = 1.0;
    cseExpRule.Evaluation_Order__c = '1';
    insert cseExpRule;
    Case_SLA_Exception_Rule_Conditions__c cserulecond = new Case_SLA_Exception_Rule_Conditions__c();
    cserulecond.Name = 'Test Rule Condition';
    cserulecond.Object_Name__c = 'Account';
    cserulecond.Field_Name__c = 'Name';
    cserulecond.Field_Type__c = 'DOUBLE';
    cserulecond.Field_Value__c = '55';
    cserulecond.Field_Operator__c = 'equals';
    cserulecond.Case_SLA_Exception_Rules__c = cseExpRule.Id;
    insert cserulecond;
    Case_SLA_Exception_Rule_Conditions__c ruleCond = [SELECT Id, Name, Object_Name__c, Field_Name__c, Field_API_Name__c, Field_Operator__c, Field_Type__c, Field_Value__c, Relationship_Name__c, Case_SLA_Exception_Rules__c FROM Case_SLA_Exception_Rule_Conditions__c WHERE Id =: cserulecond.ID ];
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'notEqual';
    ruleCond.Field_Value__c = '56';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'greaterThan';
    ruleCond.Field_Value__c = '56';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'lessOrEqual';
    ruleCond.Field_Value__c = '55';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'lessThan';
    ruleCond.Field_Value__c = '53';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'greaterOrEqual';
    ruleCond.Field_Value__c = '55';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    System.assertEquals(true,Case_ConditionCheck.checkCondition(caseObj, ruleCond));

    // FOR DateTime 
    Account acc = [SELECT Id,Name FROM Account WHERE Name = '55.0'];
    acc.Name = '2020-04-15 08:14:00';
    update acc;
    ruleCond.Field_Type__c = 'DATETIME';
    ruleCond.Field_Operator__c = 'equals';
    ruleCond.Field_Value__c = '2020-04-15 08:14:00';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'notEqual';
    ruleCond.Field_Value__c = '2020-05-15 08:14:00';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'lessThan';
    ruleCond.Field_Value__c = '2020-04-14 07:14:00';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'greaterThan';
    ruleCond.Field_Value__c = '2020-04-19 08:14:00';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'lessOrEqual';
    ruleCond.Field_Value__c = '2020-04-15 08:14:00';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'greaterOrEqual';
    ruleCond.Field_Value__c = '2020-04-15 08:14:00';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    System.assertEquals(true,Case_ConditionCheck.checkCondition(caseObj, ruleCond));
    Test.stopTest();    
    }
    // Integer Type
    static testMethod void testInteger() {
        Test.startTest();
        Account ac = new Account();
        ac.Name='55';
        insert ac;
    Case caseObj = new Case();
    caseObj.AccountId = ac.Id;
    caseObj.Subject = 'Test case';
    caseObj.Status = 'Working';
    insert caseObj;

    Case_SLA_Exception_Rules__c cseExpRule = new Case_SLA_Exception_Rules__c();
    cseExpRule.Name = 'test1';
    cseExpRule.Rule_Order__c = 1.0;
    cseExpRule.Evaluation_Order__c = '1';
    insert cseExpRule;
    Case_SLA_Exception_Rule_Conditions__c cserulecond = new Case_SLA_Exception_Rule_Conditions__c();
    cserulecond.Name = 'Test Rule Condition';
    cserulecond.Object_Name__c = 'Account';
    cserulecond.Field_Name__c = 'Name';
    cserulecond.Field_Type__c = 'INTEGER';
    cserulecond.Field_Value__c = '55';
    cserulecond.Field_Operator__c = 'equals';
    cserulecond.Case_SLA_Exception_Rules__c = cseExpRule.Id;
    insert cserulecond;
    Case_SLA_Exception_Rule_Conditions__c ruleCond = [SELECT Id, Name, Object_Name__c, Field_Name__c, Field_API_Name__c, Field_Operator__c, Field_Type__c, Field_Value__c, Relationship_Name__c, Case_SLA_Exception_Rules__c FROM Case_SLA_Exception_Rule_Conditions__c WHERE Id =: cserulecond.ID ];
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Value__c = '46';
    ruleCond.Field_Operator__c = 'notEqual';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'greaterThan';
    ruleCond.Field_Value__c = '56';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'lessOrEqual';
    ruleCond.Field_Value__c = '55';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'lessThan';
    ruleCond.Field_Value__c = '53';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'greaterOrEqual';
    ruleCond.Field_Value__c = '55';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    System.assertEquals(true,Case_ConditionCheck.checkCondition(caseObj, ruleCond));

    Account acc = [SELECT Id,Name FROM Account WHERE Name = '55'];
    acc.Name = 'Text';
    update acc;
    ruleCond.Field_Type__c = 'STRING';
    ruleCond.Field_Operator__c = 'equals';
    ruleCond.Field_Value__c = 'Text';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'notEqual';
    ruleCond.Field_Value__c = 'TextNot';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'lessThan';
    ruleCond.Field_Value__c = 'TextLT';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'greaterThan';
    ruleCond.Field_Value__c = 'TextGRT';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'lessOrEqual';
    ruleCond.Field_Value__c = 'Text';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'greaterOrEqual';
    ruleCond.Field_Value__c = 'Text';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'contains';
    ruleCond.Field_Value__c = 'TextLT';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'doesnotcontains';
    ruleCond.Field_Value__c = 'Test';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'startsWith';
    ruleCond.Field_Value__c = 'Text';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'includes';
    ruleCond.Field_Value__c = 'Text';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    ruleCond.Field_Operator__c = 'excludes';
    ruleCond.Field_Value__c = 'Test';
    update ruleCond;
    Case_ConditionCheck.checkCondition(caseObj, ruleCond);
    System.assertEquals(true,Case_ConditionCheck.checkCondition(caseObj, ruleCond));
    Test.stopTest();
    }
}