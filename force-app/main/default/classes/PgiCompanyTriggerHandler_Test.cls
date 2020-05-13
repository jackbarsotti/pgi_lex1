/**
* @Test Class Name : PgiCompanyTriggerHandler_Test
* @Class Name : PgiCompanyTriggerHandler
*/
@isTest
private class PgiCompanyTriggerHandler_Test
{
    
    @testSetup static void setup() {    
        User Objuser = PGITestUtilities.getTestUser();
        insert Objuser;
        System.runAs(objuser) {
            Account account = PGITestUtilities.getAccountDetails();
            insert account;
            
            Account account1 = PGITestUtilities.getAccountDetails();
            account1.Ultimate_Parent_Account__c = account.Id;
            insert account1;
            
            
            
            Opportunity opportunity = PGITestUtilities.getOpportunityDetails();
            Insert opportunity;
            //Opportunity opportunity1 = PGITestUtilities.getOpportunityDetails();
            //Insert opportunity1;
            PGi_Company__c pgiComapny = PGITestUtilities.getPGiCompany(account.Id);
            pgiComapny.CorpCustSFAccountID__c = account.Id;
            pgiComapny.PGi_Entity_ID__c = 'sam';
            pgiComapny.DirectSFOpptyID__c = opportunity.Id;
            pgiComapny.RelatedAccount__c = account.Id;
            pgiComapny.Ultimate_Parent_Account__c = account1.Id;
            pgiComapny.PrimarySalesRep__c = Objuser.Id;
            //pgiComapny.SF_Opportunity_ID__c = opportunity.Id;
            insert pgiComapny;
            AccountTeamMember accountTeamMember = new AccountTeamMember();
            accountTeamMember.AccountId = account.Id;
            accountTeamMember.UserId = Objuser.Id;
            accountTeamMember.teammemberrole='Sales Engineer';
            INSERT accountTeamMember;
            System.assertEquals(pgiComapny.RelatedAccount__c, account.Id);
        }
    }
    
    @isTest static void pgiInsertWithSFDCId() 
    {  
        Account getaccount = [SELECT Id,SFDC_Account_ID__c FROM Account][0];
        Opportunity getOpportunity = [SELECT Id,Opportunity_Number__c FROM Opportunity][0];
        
        CONMAN_Contract__c pgiContract = new CONMAN_Contract__c();
        pgiContract.Opportunity__c = getOpportunity.Id;
        pgiContract.Account_Name__c = getaccount.Id;
        Insert pgiContract;
        
        System.debug('getOpportunity>>>>>>>>>> '+getOpportunity);
        PGi_Company__c pgiComapny = [SELECT Id,PGi_Entity_ID__c,SF_Account_ID__c,RelatedAccount__c FROM PGi_Company__c][0];
        pgiComapny.CorpCustSFAccountID__c = null;
        pgiComapny.SF_Account_ID__c = getaccount.SFDC_Account_ID__c;
        pgiComapny.SF_Opportunity_ID__c = getOpportunity.Opportunity_Number__c;
        pgiComapny.DirectSFOpptyID__c = null;
        pgiComapny.PGi_Entity_ID__c = '1234';
        UPDATE pgiComapny;
        //138-144
        /* PGi_Company__c pgiComapny1 = new PGi_Company__c();
pgiComapny1.SF_Account_ID__c = null;
pgiComapny1.Region__c = 'USA';
Insert pgiComapny1;*/
        
        System.assertEquals(pgiComapny.RelatedAccount__c, getaccount.Id);
    }
    
    @isTest static void pgiInsertWithREmptySFDCId() 
    {  
        //set emai9l of user with company
        User Objuser1 = PGITestUtilities.getTestUser();
        Objuser1.Email = 'cf@pgi.com';
        Objuser1.IsActive = true;
        Objuser1.Username = 'cf001@fr.com';
        INSERT Objuser1;
        System.runAs(objuser1) {
            PGi_Company__c pgiComapny = [SELECT Id,DirectSFOpptyID__c,Sales_Rep_s_Email__c,SF_Account_ID__c,RelatedAccount__c FROM PGi_Company__c][0];
            pgiComapny.SF_Account_ID__c = null;
            pgiComapny.Sales_Rep_s_Email__c = 'cf@pgi.com';
            pgiComapny.Region__c = 'USA';
            UPDATE pgiComapny;
        }
        // System.debug('Is active ...................>>>>>'+Objuser.IsActive);
    }
    @isTest static void pgiInsertWithREmptySFDCId1() 
    {
        //AccountTeamMember accountTeamMember = [Select Id,AccountId,UserId from AccountTeamMember where  teammemberrole = 'Sales Engineer'];
        //System.debug(')))))))))))))))))))))))))--------->>>>>>'+accountTeamMember);
        //AccountTeamMember accountTeamMember = PGITestUtilities.getAccountTeamMembe(getaccount.Id , Objuser1.Id);
        //insert accountTeamMember;
    }
    @isTest static void pgiInsertWithREmptySFDCId2() 
    {
        Account getaccount = [SELECT Id,SFDC_Account_ID__c FROM Account][0];
        Opportunity opportunity = new Opportunity();
        
        PGi_Company__c pgiComapny = [SELECT Id,Sales_Rep_s_Email__c,SF_Account_ID__c,RelatedAccount__c FROM PGi_Company__c][0];        
        pgiComapny.DirectSFOpptyID__c = opportunity.Id;
        UPDATE pgiComapny;   
        CONMAN_Contract__c pgiContract = new CONMAN_Contract__c();
        pgiContract.Account_Name__c = getaccount.Id;
        pgiContract.Opportunity__c = opportunity.Id;
        INSERT pgiContract;
    }
     @isTest static void pgiInsertWithREmptySFDCId3() 
     {
         PGI_Entity__c pgiEntity = new PGI_Entity__c();    
         pgiEntity.Name = 'sam';
         Insert pgiEntity;
         PGi_Company__c pgiComapny1 = [SELECT Id,PGi_Entity_ID__c,PGI_Entity__c FROM PGi_Company__c][0];
         pgiComapny1.PGi_Entity_ID__c = 'sam';
         pgiComapny1.PGi_Entity__c = pgiEntity.Id;
         UPDATE pgiComapny1;
     }
     @isTest static void pgiInsertWithREmptySFDCId4() 
     {
        /* //325
         Account getaccount = [SELECT Id,SFDC_Account_ID__c FROM Account][0];
         //getaccount.SFDC_Account_ID__c = getaccount.Id;
          UPDATE getaccount;
         PGi_Company__c pgiComapny1 = [SELECT Id,PGi_Entity_ID__c,SF_Account_ID__c FROM PGi_Company__c][0];
         pgiComapny1.SF_Account_ID__c = getaccount.Id;
         UPDATE pgiComapny1;*/
     }
}