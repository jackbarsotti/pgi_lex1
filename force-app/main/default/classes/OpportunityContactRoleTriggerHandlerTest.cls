@isTest
public class OpportunityContactRoleTriggerHandlerTest {
    static testMethod void setOppParentRep() {
        PGITestUtilities.disableSalesWings();
        Account a = PGITestUtilities.createAccount(true);
        Contact c = PGITestUtilities.createContact(a, True);
        Opportunity o = PGITestUtilities.createOpportunity(a, true);
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c.Id;
        ocr.OpportunityId = o.Id;
        ocr.Role='Partner Rep';
        Insert ocr;
        system.assertequals(c.Id,[Select Partner_Rep__c FROM Opportunity Where Id =: o.Id].Partner_Rep__c);
    }
    static testMethod void setOppParentRepAfter() {
        PGITestUtilities.disableSalesWings();
        Account a = PGITestUtilities.createAccount(true);
        Contact c = PGITestUtilities.createContact(a, True);
        Opportunity o = PGITestUtilities.createOpportunity(a, true);
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c.Id;
        ocr.OpportunityId = o.Id;
        ocr.Role='Champion';
        Insert ocr;
        system.assertNotEquals(c.Id,[Select Partner_Rep__c FROM Opportunity Where Id =: o.Id].Partner_Rep__c);
        
        ocr.Role='Partner Rep';
        Update ocr;
        system.assertequals(c.Id,[Select Partner_Rep__c FROM Opportunity Where Id =: o.Id].Partner_Rep__c);
    }
}