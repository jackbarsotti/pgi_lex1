@isTest 
public class DataRetentionServiceTest {
    
    public static testMethod void disassociateContactRelatedCasesTest(){
        
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0 ;i <5;i++)
        {
            Contact contObj = new Contact();
            contObj.LastName ='TestContName'+i;
            contacts.add(contObj);
        }
        insert contacts;
        
         Test.startTest();
        List<Case> caseList = new List<Case>();
        for(Integer i=0 ;i <5;i++)
        {
            Case caseObj = new Case();
            caseObj.ContactId = contacts[i].id;
            caseList.add(caseObj);
        }
        insert caseList;

        DataRetentionService.disassociateContactRelatedCases(contacts);
        DataRetentionService.disassociateCaseContacts(caseList);
        System.assertEquals(Null, [SELECT Id, ContactId FROM Case LIMIT 1].ContactId);
        Test.stopTest();
    }
    
    public static testMethod void disassociateAccountRelatedCasesTest(){
        List<Account> accounts = new List<Account>();
        for(Integer i=0;i <5;i++)
        {
            Account accObj = new Account();
            accObj.Name ='TestAccName'+i;
            accounts.add(accObj);
        }
        insert accounts;
         
        Test.startTest();
        List<Case> caseList = new List<Case>();
        for(Integer i=0 ;i <5;i++)
        {
            Case caseObj = new Case();
            caseObj.AccountId = accounts[i].id;
            caseList.add(caseObj);
        }
        insert caseList;
         DataRetentionService.disassociateAccountRelatedCases(accounts);
        DataRetentionService.disassociateCaseAccounts(caseList);
        System.assertEquals(Null, [SELECT Id, AccountId FROM Case LIMIT 1].AccountId);
        Test.stopTest();
    }
    
    public static testMethod void buildRetentionQueryTest(){
         Test.startTest();
        List<FilterObject__c> lstFtObj= new List<FilterObject__c>();
        for(Integer i=0 ;i <5;i++)
        {
            FilterObject__c foobj = new FilterObject__c();
            foobj.Name ='TestFOName'+i;
            foobj.Status__c='Active';
            foobj.Object__c = 'Account';
            lstFtObj.add(foobj);
        }
        insert lstFtObj;
        
        
        List<FilterField__c> lstFFObj = new List<FilterField__c>();
        lstFFObj.add(new FilterField__c(FilterObject__c = lstFtObj[0].id,Value__c= 'test',Field__c = 'Name',Operator__c = 'Includes' ));
        lstFFObj.add(new FilterField__c(FilterObject__c = lstFtObj[1].id,Value__c= '11/25/2019',Field__c = 'Billing_Start_Date__c',Operator__c = 'Greater Than Or Equal' ));
        lstFFObj.add(new FilterField__c(FilterObject__c = lstFtObj[2].id,Value__c= '100',Field__c = 'AnnualRevenue',Operator__c = 'Greater Than' ));
         insert lstFFObj;
		
        String filterObjectName = 'Account';
        for(Integer i=0 ;i <2;i++)
        {
        DataRetentionService.buildRetentionQuery(lstFtObj[i].Id);
        DataRetentionService.validQuery(filterObjectName,lstFFObj);
        DataRetentionService.validateFields(lstFFObj);
            
        }
    
        System.assertEquals(true, DataRetentionService.validObjectName(filterObjectName));
        Test.stopTest();
    }
       
}