@isTest

public class Test_AutopopulateAccount {

        
        @testSetup static void setup(){
                
                system.debug('AR Start Test'); 
                Profile p = [select id from profile where name='System Administrator'];
                User user1 = new User(alias = 'test123', email='test123@pgi.com',
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                localesidkey='en_US', EmployeeNumber='12345', profileid = p.Id, country='United States',
                                timezonesidkey='America/Los_Angeles', username='test123@pgi.com');
                insert user1;
                
                User user2 = new User(alias = 'test456', email='test456@pgi.com',
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                localesidkey='en_US', EmployeeNumber='12345', profileid = p.Id, country='United States',
                                timezonesidkey='America/Los_Angeles', username='test456@pgi.com');
                insert user2;
                System.runAs(user1) {
                        Account acc1 = new Account();
                        acc1.Name = 'Acc1-ContactRoles';
                        acc1.BillingCountry = 'United States';
                        acc1.BillingCountryCode = 'US';
                        acc1.BillingState = 'California';
                        acc1.BillingStateCode = 'CA';
                        acc1.BillingStreet = 'Street1';
                        acc1.BillingPostalCode = '12345';
                        insert acc1;
                                
                        Account acc2 = new Account();
                        acc2.Name = 'Acc2-ContactRoles';
                        acc2.BillingCountry = 'United States';
                        acc2.BillingCountryCode = 'US';
                        acc2.BillingState = 'California';
                        acc2.BillingStateCode = 'CA';
                        acc2.BillingStreet = 'Street1';
                        acc2.BillingPostalCode = '12345';
                        acc2.ownerid = user1.id;
                        insert acc2;
                        
                        AccountTeamMember atm = new AccountTeamMember();
                        atm.accountid = acc2.id;
                        atm.UserId = user1.id;
                        //atm.AccountAccessLevel = 'Edit';
                        atm.TeamMemberRole = 'Sales Rep';
                        
                        
                        //create a company record
                        PGi_Company__c comp = new PGi_Company__c();
                        comp.name = 'Testcompany';
                        comp.CurrencyIsoCode = 'USD';
                        comp.RelatedAccount__c = acc1.Id;
                        insert comp;
                }
        }
        
        static testMethod void accountupdatewhileinsert() {
  
                Account acc4=[select id,name,sfdc_account_id__c,ownerid from account where name = 'Acc2-ContactRoles'];
                PGi_Company__c comp = [select id,relatedaccount__c,name,SF_Account_ID__c,Sales_Rep_s_Email__c from pgi_company__c where name = 'Testcompany'];
                comp.SF_Account_ID__c = acc4.sfdc_account_id__c;
                comp.Sales_Rep_s_Email__c='test456@pgi.com';
                update comp;
                User user3=[select id,email from user where email = 'test123@pgi.com'];
                User user4=[select id,email from user where email = 'test456@pgi.com'];
                PGi_Company__c comp1 = [select id,relatedaccount__c,name,SF_Account_ID__c,PrimarySalesRep__c from pgi_company__c where name = 'Testcompany'];
                AccountTeamMember atm1=[select id,UserId,accountId from AccountTeamMember where accountId =: acc4.id];
                system.assertequals(comp1.relatedaccount__c, acc4.Id);
                system.assertequals(comp1.PrimarySalesRep__c, user4.Id);
                system.assertEquals(atm1.userid,user4.id);
        
        }
      
}