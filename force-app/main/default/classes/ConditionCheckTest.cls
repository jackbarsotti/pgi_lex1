@isTest
public class ConditionCheckTest {
     @testSetup static void setup() {
       PGITestUtilities.disableSalesWings();
    }
    
    static testMethod void methodChildMatch() {
        Account objAcc1 = new Account(Name = 'Rule_001', AnnualRevenue = 20);
        INSERT objAcc1;
        
        Datetime accDatetime = [SELECT Id,CreatedDate,LastActivityDate FROM Account Where Id = :objAcc1.Id].CreatedDate;
        
        Contact objCont1 = new Contact(LastName = 'Rule_002', Birthdate = date.today(), AccountId = objAcc1.Id, Phone = '9988998898', DoNotCall = true);
        INSERT objCont1;
        Opportunity objOppo1 = new Opportunity(Name = 'Rule_003',StageName = 'Qualification', CloseDate = date.today(), AccountId = objAcc1.Id, Probability = 30);
        INSERT objOppo1;
        
        Matching_Rule__c objAcc_MR = new Matching_Rule__c(Name = 'MR_Rule1',Object_Name__c = 'Contact' ,Support_Text__c = 'Support help for Rule_001', Evaluation_Order__c = '1 AND 2 AND 3 AND 4 AND 5');
        INSERT objAcc_MR;
        
        Date todayvalue = Date.today();
		Datetime todaydattimevalue = DateTime.now();
        
        List<Matching_Rule_Criteria__c> lstAcc_MRCreteria = new List<Matching_Rule_Criteria__c>{
            new Matching_Rule_Criteria__c(Line_Number__c = 1 ,Matching_Rule__c = objAcc_MR.Id, Field_API_Name__c = 'AnnualRevenue', Field_Operator__c = 'equals', Field_Type__c = 'Currency', Field_Value__c = '20'),
                new Matching_Rule_Criteria__c(Line_Number__c = 2 ,Matching_Rule__c = objAcc_MR.Id, Field_API_Name__c = 'AnnualRevenue', Field_Operator__c = 'notEqual', Field_Type__c = 'Currency', Field_Value__c = '40'),
                new Matching_Rule_Criteria__c(Line_Number__c = 3 ,Matching_Rule__c = objAcc_MR.Id, Field_API_Name__c = 'AnnualRevenue', Field_Operator__c = 'lessThan', Field_Type__c = 'Currency', Field_Value__c = '40'),
                new Matching_Rule_Criteria__c(Line_Number__c = 4 ,Matching_Rule__c = objAcc_MR.Id, Field_API_Name__c = 'AnnualRevenue', Field_Operator__c = 'greaterThan', Field_Type__c = 'Currency', Field_Value__c = '10'),
                new Matching_Rule_Criteria__c(Line_Number__c = 5,Matching_Rule__c = objAcc_MR.Id, Field_API_Name__c = 'AnnualRevenue', Field_Operator__c = 'lessOrEqual', Field_Type__c = 'Currency', Field_Value__c = '40'),
                new Matching_Rule_Criteria__c(Line_Number__c = 6 ,Matching_Rule__c = objAcc_MR.Id, Field_API_Name__c = 'AnnualRevenue', Field_Operator__c = 'greaterorEqual', Field_Type__c = 'Currency', Field_Value__c = '10'),
                new Matching_Rule_Criteria__c(Line_Number__c = 7 ,Matching_Rule__c = objAcc_MR.Id, Field_API_Name__c = 'CreatedDate', Field_Operator__c = 'equals', Field_Type__c = 'DATETIME', Field_Value__c = String.valueOf(accDatetime)),
				new Matching_Rule_Criteria__c(Line_Number__c = 8 ,Matching_Rule__c = objAcc_MR.Id, Field_API_Name__c = 'CreatedDate', Field_Operator__c = 'notEqual', Field_Type__c = 'DATETIME', Field_Value__c = String.valueOf(todaydattimevalue)),
                new Matching_Rule_Criteria__c(Line_Number__c = 9 ,Matching_Rule__c = objAcc_MR.Id, Field_API_Name__c = 'CreatedDate', Field_Operator__c = 'lessThan', Field_Type__c = 'DATETIME', Field_Value__c = String.valueOf(todaydattimevalue + 5)),
                new Matching_Rule_Criteria__c(Line_Number__c = 10 ,Matching_Rule__c = objAcc_MR.Id, Field_API_Name__c = 'CreatedDate', Field_Operator__c = 'greaterThan', Field_Type__c = 'DATETIME', Field_Value__c = String.valueOf(todaydattimevalue - 5)),
                new Matching_Rule_Criteria__c(Line_Number__c = 11 ,Matching_Rule__c = objAcc_MR.Id, Field_API_Name__c = 'CreatedDate', Field_Operator__c = 'lessOrEqual', Field_Type__c = 'DATETIME', Field_Value__c = String.valueOf(accDatetime + 2)),
				new Matching_Rule_Criteria__c(Line_Number__c = 12 ,Matching_Rule__c = objAcc_MR.Id, Field_API_Name__c = 'CreatedDate', Field_Operator__c = 'greaterorEqual', Field_Type__c = 'DATETIME', Field_Value__c = String.valueOf(accDatetime - 2))};
                    insert lstAcc_MRCreteria;
        
        Account  accDatetimerecord = [SELECT Id,CreatedDate,LastActivityDate FROM Account Where Id = :objAcc1.Id];
        ConditionCheck.checkCondition(objAcc1, lstAcc_MRCreteria[0]);
        ConditionCheck.checkCondition(objAcc1, lstAcc_MRCreteria[1]);
        ConditionCheck.checkCondition(objAcc1, lstAcc_MRCreteria[2]);
        ConditionCheck.checkCondition(objAcc1, lstAcc_MRCreteria[3]);
        ConditionCheck.checkCondition(objAcc1, lstAcc_MRCreteria[4]);
        ConditionCheck.checkCondition(objAcc1, lstAcc_MRCreteria[5]);
        ConditionCheck.checkCondition(accDatetimerecord, lstAcc_MRCreteria[6]);
        ConditionCheck.checkCondition(accDatetimerecord, lstAcc_MRCreteria[7]);
        ConditionCheck.checkCondition(accDatetimerecord, lstAcc_MRCreteria[8]);
        ConditionCheck.checkCondition(accDatetimerecord, lstAcc_MRCreteria[9]);
        ConditionCheck.checkCondition(accDatetimerecord, lstAcc_MRCreteria[10]);
        ConditionCheck.checkCondition(accDatetimerecord, lstAcc_MRCreteria[11]);
        
        Matching_Rule__c objCont_MR = new Matching_Rule__c(Name = 'MR_Rule2',Object_Name__c = 'Contact' ,Relationship_Name__c = 'Contacts', Support_Text__c = 'Support help for Rule_001', Evaluation_Order__c = '1 AND 2 AND 3 AND 4 AND 5');
        INSERT objCont_MR;
        
        List<Matching_Rule_Criteria__c> lstContactMRCreteria = new List<Matching_Rule_Criteria__c>{new Matching_Rule_Criteria__c(Line_Number__c = 1 ,Matching_Rule__c = objCont_MR.Id, Field_API_Name__c =  'Name', Field_Operator__c = 'equals', Field_Type__c = 'TEXT', Field_Value__c = 'Rule_002'),
            new Matching_Rule_Criteria__c(Line_Number__c = 2 ,Matching_Rule__c = objCont_MR.Id, Field_API_Name__c = 'DoNotCall', Field_Operator__c = 'equals', Field_Type__c = 'BOOLEAN', Field_Value__c = 'true'),
            new Matching_Rule_Criteria__c(Line_Number__c = 3 ,Matching_Rule__c = objCont_MR.Id,  Field_API_Name__c = 'DoNotCall', Field_Operator__c = 'notEqual', Field_Type__c = 'BOOLEAN', Field_Value__c = 'false'),
            new Matching_Rule_Criteria__c(Line_Number__c = 4 ,Matching_Rule__c = objCont_MR.Id,  Field_API_Name__c = 'PHONE', Field_Operator__c = 'equals', Field_Type__c = 'TEXT', Field_Value__c = '9988998898'),
            new Matching_Rule_Criteria__c(Line_Number__c = 5 ,Matching_Rule__c = objCont_MR.Id, Field_API_Name__c = 'PHONE', Field_Operator__c = 'notEqual', Field_Type__c = 'TEXT', Field_Value__c = '8888888888'),
            new Matching_Rule_Criteria__c(Line_Number__c = 6 ,Matching_Rule__c = objCont_MR.Id,  Field_API_Name__c =  'Name', Field_Operator__c = 'equals', Field_Type__c = 'TEXT', Field_Value__c = 'Rule_003'),
            new Matching_Rule_Criteria__c(Line_Number__c = 7 ,Matching_Rule__c = objCont_MR.Id,  Field_API_Name__c =  'PHONE', Field_Operator__c = 'lessThan', Field_Type__c = 'TEXT', Field_Value__c = 'Rule_004'),
            new Matching_Rule_Criteria__c(Line_Number__c = 8 ,Matching_Rule__c = objCont_MR.Id,  Field_API_Name__c =  'PHONE', Field_Operator__c = 'greaterThan', Field_Type__c = 'TEXT', Field_Value__c = '88'),
            new Matching_Rule_Criteria__c(Line_Number__c = 9 ,Matching_Rule__c = objCont_MR.Id,  Field_API_Name__c =  'PHONE', Field_Operator__c = 'lessOrEqual', Field_Type__c = 'TEXT', Field_Value__c = 'Rule_004'),
            new Matching_Rule_Criteria__c(Line_Number__c = 10 ,Matching_Rule__c = objCont_MR.Id,  Field_API_Name__c =  'PHONE', Field_Operator__c = 'greaterOrEqual', Field_Type__c = 'TEXT', Field_Value__c = '9988998898'),
            new Matching_Rule_Criteria__c(Line_Number__c = 11,Matching_Rule__c = objCont_MR.Id,  Field_API_Name__c =  'PHONE', Field_Operator__c = 'contains', Field_Type__c = 'TEXT', Field_Value__c = '9988'),
            new Matching_Rule_Criteria__c(Line_Number__c = 12 ,Matching_Rule__c = objCont_MR.Id,  Field_API_Name__c =  'PHONE', Field_Operator__c = 'notContain', Field_Type__c = 'TEXT', Field_Value__c = 'Rule_004'),
            new Matching_Rule_Criteria__c(Line_Number__c = 13 ,Matching_Rule__c = objCont_MR.Id,  Field_API_Name__c =  'PHONE', Field_Operator__c = 'startsWith', Field_Type__c = 'TEXT', Field_Value__c = '9988'),
            new Matching_Rule_Criteria__c(Line_Number__c = 14 ,Matching_Rule__c = objCont_MR.Id,  Field_API_Name__c =  'PHONE', Field_Operator__c = 'includes', Field_Type__c = 'TEXT', Field_Value__c = '9988'),
            new Matching_Rule_Criteria__c(Line_Number__c = 15 ,Matching_Rule__c = objCont_MR.Id,  Field_API_Name__c =  'PHONE', Field_Operator__c = 'excludes', Field_Type__c = 'TEXT', Field_Value__c = '77'),
            new Matching_Rule_Criteria__c(Line_Number__c = 16 ,Matching_Rule__c = objCont_MR.Id, Field_API_Name__c =  'Birthdate', Field_Operator__c = 'equals', Field_Type__c = 'DATE', Field_Value__c = String.valueOf(todayvalue)),
            new Matching_Rule_Criteria__c(Line_Number__c = 17 ,Matching_Rule__c = objCont_MR.Id, Field_API_Name__c =  'Birthdate', Field_Operator__c = 'notEqual', Field_Type__c = 'DATE', Field_Value__c = String.valueOf(todayvalue + 1)),
            new Matching_Rule_Criteria__c(Line_Number__c = 18 ,Matching_Rule__c = objCont_MR.Id, Field_API_Name__c =  'Birthdate', Field_Operator__c = 'lessThan', Field_Type__c = 'DATE', Field_Value__c = String.valueOf(todayvalue + 3)),
            new Matching_Rule_Criteria__c(Line_Number__c = 19 ,Matching_Rule__c = objCont_MR.Id, Field_API_Name__c =  'Birthdate', Field_Operator__c = 'greaterThan', Field_Type__c = 'DATE', Field_Value__c = String.valueOf(todayvalue - 5)),
            new Matching_Rule_Criteria__c(Line_Number__c = 20 ,Matching_Rule__c = objCont_MR.Id, Field_API_Name__c =  'Birthdate', Field_Operator__c = 'lessOrEqual', Field_Type__c = 'DATE', Field_Value__c = String.valueOf(todayvalue)),
            new Matching_Rule_Criteria__c(Line_Number__c = 21 ,Matching_Rule__c = objCont_MR.Id, Field_API_Name__c =  'Birthdate', Field_Operator__c = 'greaterorEqual', Field_Type__c = 'DATE', Field_Value__c = String.valueOf(todayvalue))};
                insert lstContactMRCreteria;
        
        ConditionCheck.checkCondition(objCont1, lstContactMRCreteria[0]);
        ConditionCheck.checkCondition(objCont1, lstContactMRCreteria[1]);
        ConditionCheck.checkCondition(objCont1, lstContactMRCreteria[2]);
        ConditionCheck.checkCondition(objCont1, lstContactMRCreteria[3]);
        ConditionCheck.checkCondition(objCont1, lstContactMRCreteria[4]);
        ConditionCheck.checkCondition(objCont1, lstContactMRCreteria[5]);
        ConditionCheck.checkCondition(objCont1, lstContactMRCreteria[6]);
        ConditionCheck.checkCondition(objCont1, lstContactMRCreteria[7]);
        ConditionCheck.checkCondition(objCont1, lstContactMRCreteria[8]);
        ConditionCheck.checkCondition(objCont1, lstContactMRCreteria[9]);
        ConditionCheck.checkCondition(objCont1, lstContactMRCreteria[10]);
        ConditionCheck.checkCondition(objCont1, lstContactMRCreteria[11]);
        ConditionCheck.checkCondition(objCont1, lstContactMRCreteria[12]);
        ConditionCheck.checkCondition(objCont1, lstContactMRCreteria[13]);
        ConditionCheck.checkCondition(objCont1, lstContactMRCreteria[14]);
        ConditionCheck.checkCondition(objCont1, lstContactMRCreteria[15]);
        ConditionCheck.checkCondition(objCont1, lstContactMRCreteria[16]);
        ConditionCheck.checkCondition(objCont1, lstContactMRCreteria[17]);
        ConditionCheck.checkCondition(objCont1, lstContactMRCreteria[18]);
        ConditionCheck.checkCondition(objCont1, lstContactMRCreteria[19]);
        ConditionCheck.checkCondition(objCont1, lstContactMRCreteria[20]);
        
        Matching_Rule__c objOpp_MR = new Matching_Rule__c(Name = 'MR_Rule3',Object_Name__c = 'Opportunity' ,Relationship_Name__c = 'Opportunities', Support_Text__c = 'Support help for Opportunity Rule_001', Evaluation_Order__c = '1 AND 2 AND 3 AND 4 AND 5');
        INSERT objOpp_MR;
        
        List<Matching_Rule_Criteria__c> lstOpportyMRCreteria = new List<Matching_Rule_Criteria__c>{new Matching_Rule_Criteria__c(Line_Number__c = 1 ,Matching_Rule__c = objOpp_MR.Id, Field_API_Name__c =  'Probability', Field_Operator__c = 'equals', Field_Type__c = 'Percent', Field_Value__c = '30'),
            new Matching_Rule_Criteria__c(Line_Number__c = 2 ,Matching_Rule__c = objOpp_MR.Id, Field_API_Name__c =  'Probability', Field_Operator__c = 'notEqual', Field_Type__c = 'Percent', Field_Value__c = '70'),
            new Matching_Rule_Criteria__c(Line_Number__c = 3 ,Matching_Rule__c = objOpp_MR.Id, Field_API_Name__c =  'Probability', Field_Operator__c = 'lessThan', Field_Type__c = 'Percent', Field_Value__c = '80'),
            new Matching_Rule_Criteria__c(Line_Number__c = 4 ,Matching_Rule__c = objOpp_MR.Id, Field_API_Name__c =  'Probability', Field_Operator__c = 'greaterThan', Field_Type__c = 'Percent', Field_Value__c = '10'),
            new Matching_Rule_Criteria__c(Line_Number__c = 5 ,Matching_Rule__c = objOpp_MR.Id, Field_API_Name__c =  'Probability', Field_Operator__c = 'lessOrEqual', Field_Type__c = 'Percent', Field_Value__c = '30'),
            new Matching_Rule_Criteria__c(Line_Number__c = 6 ,Matching_Rule__c = objOpp_MR.Id, Field_API_Name__c =  'Probability', Field_Operator__c = 'greaterorEqual', Field_Type__c = 'Percent', Field_Value__c = '30')};
           // new Matching_Rule_Criteria__c(Line_Number__c = 6 ,Matching_Rule__c = objOpp_MR.Id, Field_API_Name__c =  'null', Field_Operator__c = 'greaterorEqual', Field_Type__c = 'Percent', Field_Value__c = '30')
                INSERT lstOpportyMRCreteria;
        
        ConditionCheck.checkCondition(objOppo1, lstOpportyMRCreteria[0]);
        ConditionCheck.checkCondition(objOppo1, lstOpportyMRCreteria[1]);
        ConditionCheck.checkCondition(objOppo1, lstOpportyMRCreteria[2]);
        ConditionCheck.checkCondition(objOppo1, lstOpportyMRCreteria[3]);
        ConditionCheck.checkCondition(objOppo1, lstOpportyMRCreteria[4]);
        ConditionCheck.checkCondition(objOppo1, lstOpportyMRCreteria[5]);
        //ConditionCheck.checkCondition(objOppo1, lstOpportyMRCreteria[6]);
    }
    
}