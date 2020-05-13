/**  
* \arg ClassName        : OTE_CMP_ControllerTest
* \arg JIRATicket       : 
* \arg CreatedOn        : 19/July/2019
* \arg LastModifiedOn   : 
* \arg CreatededBy      : Vijay
* \arg ModifiedBy       : 
* \arg Description      : Test class for OTE_CMP_Controller class
*/
@isTest
private class OTE_CMP_ControllerTest 
{	
    static OT_Member__c objOTMember;
    static OT_Rule__c objOTRule;
    static Team_Member__c objTeamMember;
    
    @testSetup static void setup() 
    {
        Account objAcc = new Account(Name = 'Test1');
        INSERT objAcc;
        List<OT_Member__c> otMemberList = new List<OT_Member__c>{new OT_Member__c(Name = 'Test1' , Evaluation_Order__c = '1 AND 2' , Rule_Order__c = 1),
            new OT_Member__c(Name = 'Test12' , Evaluation_Order__c = '1 AND 2' , Rule_Order__c = 2)};
                Insert otMemberList;     
        List<OT_Rule__c> otRoleList = new List<OT_Rule__c>{new OT_Rule__c(Name = 'Test1', OT_Member__c = otMemberList[0].Id , Object_Name__c = 'Account' , Field_Type__c = 'Text' , Field_Operator__c = 'notEqual' , Field_Value__c = 'opp' , Line_Number__c = 1 , Field_Name__c = 'Name' , CurrencyIsoCode = 'USD'),
            new OT_Rule__c(Name = 'Test12', OT_Member__c = otMemberList[1].Id , Object_Name__c = 'OpportunityLineItem' , Field_Type__c = 'Text' , Field_Operator__c = 'notEqual' , Field_Value__c = 'opp' , Line_Number__c = 2 , Field_Name__c = 'Name' , CurrencyIsoCode = 'USD')};
                INSERT otRoleList;
        List<Team_Member__c> teamMemberList = new List<Team_Member__c>{new Team_Member__c(Name = 'Test1' , OT_Member__c = otMemberList[0].Id , Role__c = 'Sales Rep' , CurrencyIsoCode = 'USD' ,User__c = UserInfo.getUserId()),
            new Team_Member__c(Name = 'Test12' , OT_Member__c = otMemberList[1].Id , Role__c = 'Sales Rep' , CurrencyIsoCode = 'USD' ,User__c = UserInfo.getUserId()),
            new Team_Member__c(Name = 'Test13' , OT_Member__c = otMemberList[1].Id , Role__c = 'Sales Rep' , CurrencyIsoCode = 'USD' ,User__c = UserInfo.getUserId())};
                Insert teamMemberList;  
        
        objOTMember = new OT_Member__c(Name = 'Member_test01' , Evaluation_Order__c = '1' , Rule_Order__c = 1);
        objOTRule = new OT_Rule__c(Name = 'TestRule1' , Object_Name__c = 'Account' , Field_Type__c = 'Text' , Field_Operator__c = 'notEqual' , Field_Value__c = 'opp' , Line_Number__c = 1 , Field_Name__c = 'Name' , CurrencyIsoCode = 'USD');
        objTeamMember = new Team_Member__c(Name = 'Test12' , OT_Member__c = otMemberList[1].Id , Role__c = 'Sales Rep' , CurrencyIsoCode = 'USD' ,User__c = UserInfo.getUserId());
    }
    static testMethod void method1()
    {
        setup();
        List<OT_Member__c> otMembList =[SELECT Id,Name,Evaluation_Order__c,Rule_Order__c FROM OT_Member__c]; 
        
        OTE_CMP_Controller.getObjectKeyPrefix();
        OTE_CMP_Controller.getOTERecords(otMembList[0].Id);
        OTE_CMP_Controller.getALLFields('Account');
        OTE_CMP_Controller.getRoleValues();
        Map<Id,OT_Rule__c> roleIdMap = new Map<Id,OT_Rule__c>([Select Id from OT_Rule__c WHERE OT_Member__c = :otMembList[0].Id]);
        Map<Id,Team_Member__c> teamMemberMap = new Map<Id,Team_Member__c>([Select Id from Team_Member__c where OT_Member__c =:otMembList[0].Id]);
        
        OTE_CMP_Controller.saveOppyTeamEngineRecords(JSON.serialize(objOTMember),'['+JSON.serialize(objOTRule)+']','['+JSON.serialize(objTeamMember)+']',new List<Id>(roleIdMap.keySet()),new List<Id>(teamMemberMap.keySet()));
        OTE_CMP_Controller.deleteRecord(String.valueOf(new List<Id>(roleIdMap.keySet())[0]));
        system.assertEquals([SELECT count() FROM OT_Rule__c WHERE OT_Member__c = :otMembList[0].Id],0);
    }
}