@isTest
public with sharing class CampaignTriggerHandlerTest {
    public CampaignTriggerHandlerTest() {

    }
    @isTest(seeAllData=true)
	public static void test() {
        

        Test.startTest();
        Campaign cmp = new Campaign();
        cmp.Name = 'Test Campaign1';
        cmp.Type = 'Email';
        insert cmp;
    //     CampaignMemberStatus obj = new CampaignMemberStatus();
    //     obj.CampaignId = cmp.Id;
    //    // obj.Label = 'Sent';
    //     obj.isDefault = True;
    //     insert obj;

      /*  Campaign cmp1 = new Campaign();
        cmp1.Name = 'Test Campaign2';
        cmp1.Type = 'Advertisement';
        insert cmp1;
        CampaignMemberStatus obj1 = new CampaignMemberStatus();
        obj1.CampaignId = cmp1.Id;
        obj1.Label = 'Responded';
        obj1.isDefault = True;
        insert obj1;
        */
        List<CampaignMemberStatus> cmLst = [Select Id, Label, CampaignID  FROM CampaignMemberStatus WHERE CampaignID=:cmp.Id];
        System.assert(cmLst.size() > 2);
        Test.stopTest();
    }
    @isTest(seeAllData=true)
	public static void testElse() {
        Test.startTest();
        // CampaignMember_Status__mdt obj = new CampaignMember_Status__mdt();
        // obj.Status__c = 'Responded';
        // insert obj;

        Campaign cmp1 = new Campaign();
        cmp1.Name = 'Test Campaign2';
        cmp1.Type = 'Events';
        insert cmp1;
    //     CampaignMemberStatus obj1 = new CampaignMemberStatus();
    //     obj1.CampaignId = cmp1.Id;
    //    // obj1.Label = 'Responded';
    //     obj1.isDefault = True;
    //     insert obj1;
        List<CampaignMemberStatus> cmLst = [Select Id, Label, CampaignID  FROM CampaignMemberStatus WHERE CampaignID=:cmp1.Id];
        System.assert(cmLst.size() > 2);
        Test.stopTest();
    }
}