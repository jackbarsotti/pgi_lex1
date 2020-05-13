@isTest
public class CheckPrimaryContactRoleTEST {
    @testSetup static void setup() {
        PGITestUtilities.disableSalesWings();
    }
    static testMethod void testContactRole() {
        
        //create an account
        Account acc = new Account();
        acc.Name = 'Acc-ContactRoles';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'California';
        acc.BillingStreet = 'Street1';
        acc.BillingPostalCode = '12345';
        
        
        insert acc;
        
        //create 2 contacts
        Contact con1 = new Contact();
        con1.FirstName = 'ContactRoles1';
        con1.LastName = 'Surname1';
        con1.AccountId = acc.Id;
        
        insert con1;
        
        Contact con2 = new Contact();
        con2.FirstName = 'ContactRoles2';
        con2.LastName = 'Surname2';
        con2.AccountId = acc.Id;
        
        insert con2;
        
        //create an opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'Opp-ContactRoles';
        opp.AccountId = acc.Id;
        opp.stagename = 'Awareness';
        opp.Amount = 10000;
        opp.CloseDate = System.Today();
        
        
        insert opp;
        
        //add 2 contact roles and make 1 the primary
        OpportunityContactRole ocr1 = new OpportunityContactRole();
        ocr1.OpportunityId = opp.Id;
        ocr1.ContactId = con1.Id;
        ocr1.IsPrimary = TRUE;
        ocr1.role='Business User';
        
        OpportunityContactRole ocr2 = new OpportunityContactRole();
        ocr2.OpportunityId = opp.Id;
        ocr2.ContactId = con2.Id;
        ocr2.IsPrimary = FALSE;
        
        
        insert ocr1;
        insert ocr2;
        
        opp.Competitor_s__c = 'Airtel';
        opp.Incumbent__c='Airtel';
        opp.Primary_Won_Reason__c = 'Budget Available';
        opp.Opportunity_Source_Close__c = 'Hoovers';
        opp.StageName = 'Awareness';
        
        OpportunityTriggerHandler.bypassContactRole = false;
        update opp;
        
        
        
        
        Integer oppAmount = 0;
        Integer singleAmount = 1;
        for (Opportunity o:[SELECT Id FROM Opportunity 
                            WHERE Name = 'Opp-ContactRoles' AND
                            Primary_contact_assigned__c = TRUE]) {
                                oppAmount++;
                            }
        System.assertEquals(singleAmount, oppAmount);
    }
    
}