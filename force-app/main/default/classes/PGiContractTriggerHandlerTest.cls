@isTest
public class PGiContractTriggerHandlerTest {

    @isTest
    public static void testCreateApprovedVersion(){
    Account acct = PGITestUtilities.getAccountDetails();
    insert acct;
    
    Opportunity opp = PGITestUtilities.getOpportunityDetails();
    opp.AccountId = acct.Id;
    insert opp;
    
    CONMAN_Contract__c ic = PGITestUtilities.createConManContract(acct, opp, false);
    ic.Contract_Status__c = 'Pending Approval';
    insert ic;

    CONMAN_Contract__c c = [SELECT Id, Contract_Status__c FROM CONMAN_Contract__c WHERE Id = :ic.Id];
    List<CPQ_Contract_Approved_Version__c> approvedVersionsBeforeUpdate = new List<CPQ_Contract_Approved_Version__c>([SELECT Id, (SELECT Id, parentId FROM Attachments) FROM CPQ_Contract_Approved_Version__c WHERE PGi_Contract__c = :c.Id]);
    System.AssertEquals(approvedVersionsBeforeUpdate.size(), 0);

    Test.startTest();
    c.Contract_Status__c = 'Approved';
    update c;
    Test.stopTest();

    List<CPQ_Contract_Approved_Version__c> approvedVersionsAfterUpdate = new List<CPQ_Contract_Approved_Version__c>([SELECT Id, (SELECT Id, parentId FROM Attachments) FROM CPQ_Contract_Approved_Version__c WHERE PGi_Contract__c = :c.Id]);
    System.AssertEquals(approvedVersionsAfterUpdate.size(), 1, 'No Approval versions were found for the PGi Contract');
    System.AssertEquals(approvedVersionsAfterUpdate[0].attachments.size(), 1, 'No Attachments were found for the Approval Version on the PGi Contract');
    }
}