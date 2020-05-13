@isTest
public class OpportunityTriggerHandlerTest {
    public static Boolean bypassDlrs = false;
    @testSetup static void setup() {
        
        Test.startTest();
        User u = PGITestUtilities.readyTalkUser;
        System.runAs(u) {
            PGITestUtilities.disableSalesWings();
        }

    }
      static testMethod void testPrice_Per_User_for_Internal_User_Product_Line() {
        //
        // SELECT PPU__c , OpportunityId FROM OpportunityLineItem WHERE isDeleted = false ORDER BY Id DESC NULLS LAST
        //
        //
        // OpportunityLineItem > PPU__c (aggregate)
        //
        //
        // CURRENCY to rollup into Opportunity.Internal_User_Amount__c
        //
        
        Account a = PGITestUtilities.createAccount(true);
        Opportunity o = PGITestUtilities.createOpportunity(a, true);
        Product2 p = new Product2(Name = 'Third Party Support', Family = 'Not Party', IsActive = true);
    //    insert p;
        Opportunity o2 = PGITestUtilities.createOpportunity(a, true);
        Product2 notTp = new Product2(Name = 'Not Party Support', Family = 'Third Party', IsActive = true);
      //     insert notTp;
      Test.startTest();
           
          insert new List<Product2>{p,notTp} ;
        PricebookEntry pbeTp = PGITestUtilities.CreatePriceBookEntryForProduct(p);
        PricebookEntry pbeNotTp = PGITestUtilities.CreatePriceBookEntryForProduct(notTp);
        insert new List<PricebookEntry>{pbeTp, pbeNotTp};
         insert PGITestUtilities.getOpportunityLineItemDetails(o.Id, pbeTp.Id);
        insert PGITestUtilities.getOpportunityLineItemDetails(o2.Id, pbeNotTp.Id);
        
        
        
        System.assertEquals([SELECT Internal_User_Amount__c FROM Opportunity WHERE Id = :o.Id].Internal_User_Amount__c, 0);
        Test.stopTest();
        
    } 
    
    static testMethod void testCount_of_BATs() {
        //
        // SELECT IsDeleted , bizible2__Opportunity__c FROM bizible2__Bizible_Attribution_Touchpoint__c WHERE isDeleted = false
        //
        //
        // Opportunity.Count_of_BATs__c
        //
        
        Account testAcct = new Account(); 
        testAcct.Name = 'test';
        insert testAcct;
        
        Opportunity testOpp = PGITestUtilities.createClosedWonValidOpportunity(testAcct, true);
        List<bizible2__Bizible_Attribution_Touchpoint__c> testRecords = new List<bizible2__Bizible_Attribution_Touchpoint__c>();
        for(Integer i = 0, j = 0; i < 3; i++) {
            
            testRecords.add(new bizible2__Bizible_Attribution_Touchpoint__c(bizible2__Opportunity__c = testOpp.Id));
        }   
        insert testRecords;
        
        Test.startTest();
        
        System.assertEquals([SELECT Count_of_BATs__c FROM Opportunity WHERE Id = :testOpp.Id].Count_of_BATs__c, 3);
        
        Test.stopTest();
    }
    
    static testMethod void testReopen() {
        
    }
    
    static testMethod void validatePGiClosedWon() {
        Account testAcct = new Account(); 
        testAcct.Name = 'test';
        insert testAcct;
        
        Opportunity testOpp = PGITestUtilities.createClosedWonValidOpportunity(testAcct, true);
        
        CONMAN_Contract__c testPGiContract = PGITestUtilities.createPGiContract(testOpp, true);
        
        Test.startTest();
        try {
            // attempt update Opp to 'Closed Pending Review' with no attachment, assert error is thrown
            testOpp.StageName = 'Closed Pending Review';
            update testOpp;
        }
        catch(Exception e) {
            System.Assert(e.getMessage().contains(OpportunityTriggerHandler.PGI_CLOSEDWON_VALIDATION_MSG));
        } 
        
        // insert attatchment and update to Closed Pending Review again 
        
        Attachment testFile = new Attachment();
        testFile.Name = 'TestOpp File';
        testFile.Body = Blob.valueOf('TestOpp File Content');
        testFile.ParentId = testOpp.Id;
        insert testFile;
        
        testOpp.StageName = 'Closed Pending Review';
        update testOpp;
        Test.stopTest();
    }
    
    static testMethod void testContactLastSurvey(){
        Account a = PGITestUtilities.createAccount(true);
        Opportunity o = PGITestUtilities.createOpportunity(a, true);
        Contact c = PGITestUtilities.createContact(a, false);
        c.Last_Survey_Sent__c = System.today();
        insert c;
        
        o = [SELECT Id, Primary_Contact_Last_Survey_Sent__c FROM Opportunity];
        System.assert(o.Primary_Contact_Last_Survey_Sent__c == null); 
        o.Primary_Contact__c = c.Id;
        update o;
        
        o = [SELECT Id, Primary_Contact_Last_Survey_Sent__c,Managed_Svs_Support_Total__c,Professional_Svs_Total__c,Primary_Contact__c FROM Opportunity];
        // System.assertEquals(o.Primary_Contact_Last_Survey_Sent__c,null);
        // System.assertEquals(o.Primary_Contact__c,null);
    }
    static testMethod void noMatchingRates() {
        Account a = PGITestUtilities.createAccount(true);
        Opportunity o = PGITestUtilities.createOpportunity(a, false);
        insert o;
        update o;
    }
    static testMethod void noMatchingRatesBulk() {
        Account a = PGITestUtilities.createAccount(true);
        List<Opportunity> oppList = new List<Opportunity>();
        for(integer i = 0; i<200; i++) {
            Opportunity o = PGITestUtilities.createOpportunity(a, false);  
        }
        insert oppList;
        update oppList;
    }
    static testMethod void findMatchingRates() {
        Test.startTest();
        Account a = PGITestUtilities.createAccount(true);
        Opportunity o = PGITestUtilities.createOpportunity(a, false);
        insert o; 
        //Test.stopTest();
        //Test.startTest();
        update o;
        //Test.stopTest();
        
        Opportunity o2 = PGITestUtilities.createOpportunity(a, false); 
        
        // insert o2;
        
        //test insert 
        Opportunity o3 = PGITestUtilities.createOpportunity(a, false);
        o3.RecordTypeId = PGI_Utility.getRecordTypes('Opportunity').get(OpportunityTriggerHandler.PGI_RT);
        List<Opportunity> oppList2 = new List<Opportunity>{o3, o2};
            INSERT oppList2;
        //insert o3;
        List<Opportunity> oppList = new List<Opportunity>{o, o2};
            update oppList;
        
    }
    static testMethod void changeCloseDate() {
        Account a = PGITestUtilities.createAccount(true);
        Opportunity o = PGITestUtilities.createOpportunity(a, false);
        insert o; 
        o.CloseDate = System.today().addYears(1).addDays(1);
        update o;
    }
    static testMethod void testBypass() {
        Account a = PGITestUtilities.createAccount(true);
        Opportunity o = PGITestUtilities.createOpportunity(a, false);
        o.Commissions_Override__c = true;
        insert o;
    }
    static testMethod void testThirdPartyClosure() {
        OpportunityTriggerHandlerTest.bypassDlrs = true;
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('ContactTriggerHandler');
        Account a = PGITestUtilities.createAccount(true);
        Opportunity o = PGITestUtilities.createOpportunity(a, false);
        o.ownerId = PGITestUtilities.readyTalkUser.Id;
        insert o;
        Product2 p = new Product2(Name = 'Third Party Support', Family = 'Not Party', isActive = true);
        insert p;
        Opportunity o2 = PGITestUtilities.createOpportunity(a, false);
        o2.ownerId = PGITestUtilities.readyTalkUser.Id;
        insert o2;
        Product2 notTp = new Product2(Name = 'Not Party Support', Family = 'Third Party', isActive = true);
        insert notTp;
        PricebookEntry pbeTp = PGITestUtilities.CreatePriceBookEntryForProduct(p);
        PricebookEntry pbeNotTp = PGITestUtilities.CreatePriceBookEntryForProduct(notTp);
        insert new List<PricebookEntry>{pbeTp, pbeNotTp};
        insert new List<OpportunityLineItem>{PGITestUtilities.getOpportunityLineItemDetails(o.Id, pbeTp.Id), PGITestUtilities.getOpportunityLineItemDetails(o2.Id, pbeNotTp.Id)};
        Test.startTest();
        PGI_Utility.profile = null;
        System.runAs(PGITestUtilities.readyTalkUser) {
            System.assertEquals(false, PGI_Utility.profile.Name.equals('System Administrator'));
            o.StageName = 'Closed Pending Review';
            o.Z_Source__c = 'Salesgateway';
            o.Opportunity_Deal_Type__c = 'New Business';
            o.Close_Reason__c = 'We rock';
            o.PO_Date__c = System.today();
            o.PO_Number__c = '213123';
            o.Acct_Admin_Decison_Maker_Checked__c = 'Yes';
            o.Account_Assigned_To__c = UserInfo.getUserId();
            o.Prospect_Status__c = 'Event Sourced';
            o.Service_Term__c = 'Month to Month';
            o.Int_l_Audio_Rates_Discussed__c = 'Yes';
            o.Rates_set_at_Account_Level__c = 'Yes';
            o.One_Time_Revenue__c = true;
            o.Competitor_s__c = 'AAPT';
            o.Incumbent__c = 'Test';
            o.Primary_Won_Reason__c = 'test';
            o.Differentiating_Win_Factors__c = 'test';
            o2.One_Time_Revenue__c = true;
            o2.Opportunity_Deal_Type__c = 'New Business';
            o2.Z_Source__c = 'Salesgateway';
            o2.StageName = 'Closed Pending Review';
            o2.Close_Reason__c = 'We rock';
            o2.PO_Date__c = System.today();
            o2.PO_Number__c = '321231';
            o2.Acct_Admin_Decison_Maker_Checked__c = 'Yes'; 
            o2.Account_Assigned_To__c = UserInfo.getUserId();
            o2.Prospect_Status__c = 'Event Sourced';
            o2.Service_Term__c = 'Month to Month';
            o2.Int_l_Audio_Rates_Discussed__c = 'Yes';
            o2.Rates_set_at_Account_Level__c = 'Yes';
            o2.Competitor_s__c = 'AAPT';
            o2.Incumbent__c = 'Test';
            o2.Primary_Won_Reason__c = 'test';
            o2.Differentiating_Win_Factors__c = 'test';
            update new List<Opportunity>{o, o2};
                }
        Test.stopTest();    
        List<Opportunity> renewalOpportunityList = [SELECT Id FROM Opportunity WHERE Id !=: o.Id AND Id !=: o2.Id];
        System.assertEquals(0, renewalOpportunityList.size());
        o2.Competitor_s__c = 'AAPT';
        o2.Incumbent__c = 'Test';
        o2.StageName = 'Closed Lost';
        o2.Closed_Lost_Nuture_Reason__c = 'Other';
        o2.Closed_Reason_Explanation__c = 'Programmatically closed as the original opportunity is no longer Closed Pending Review';
        
        update o2;
    }
    
    static testMethod void testInactiveProducts() {
        Account a = PGITestUtilities.createAccount(true);
        Opportunity o = PGITestUtilities.createOpportunity(a, false);
        o.ownerId = PGITestUtilities.readyTalkUser.Id;
        insert o;
        Product2 p = new Product2(Name = 'Third Party Support', Family = 'Not Party', IsActive = true);
        insert p;
        Opportunity o2 = PGITestUtilities.createOpportunity(a, false);
        o2.ownerId = PGITestUtilities.readyTalkUser.Id;
        insert o2;
        Product2 notTp = new Product2(Name = 'Not Party Support', Family = 'Third Party', IsActive = true);
        insert notTp;
        PricebookEntry pbeTp = PGITestUtilities.CreatePriceBookEntryForProduct(p);
        
        PricebookEntry pbeNotTp = PGITestUtilities.CreatePriceBookEntryForProduct(notTp);
        insert new List<PricebookEntry>{pbeTp, pbeNotTp};
            insert new List<OpportunityLineItem>{PGITestUtilities.getOpportunityLineItemDetails(o.Id, pbeTp.Id), PGITestUtilities.getOpportunityLineItemDetails(o2.Id, pbeNotTp.Id)};
                
                pbeTp.IsActive = false;
        notTp.IsActive = false;
        update pbeTp;
        update notTp;
        Test.startTest();
        o.StageName = 'Closed Pending Review';
        o.Close_Reason__c = 'We rock';
        o.PO_Date__c = System.today();
        o.PO_Number__c = '213123';
        o.Acct_Admin_Decison_Maker_Checked__c = 'Yes';
        o.Account_Assigned_To__c = UserInfo.getUserId();
        o.Prospect_Status__c = 'Event Sourced';
        o.Service_Term__c = 'Month to Month';
        o.Int_l_Audio_Rates_Discussed__c = 'Yes';
        o.Rates_set_at_Account_Level__c = 'Yes';
        o.One_Time_Revenue__c = true;
        o.Competitor_s__c = 'AAPT';
        o.Incumbent__c = 'Test';
        o.Primary_Won_Reason__c = 'test';
        
        
        o.Differentiating_Win_Factors__c = 'test';
        o2.One_Time_Revenue__c = true;
        o2.StageName = 'Closed Pending Review';
        o2.Close_Reason__c = 'We rock';
        o2.PO_Date__c = System.today();
        o2.PO_Number__c = '321231';
        o2.Acct_Admin_Decison_Maker_Checked__c = 'Yes'; 
        o2.Account_Assigned_To__c = UserInfo.getUserId();
        o2.Prospect_Status__c = 'Event Sourced';
        o2.Service_Term__c = 'Month to Month';
        o2.Int_l_Audio_Rates_Discussed__c = 'Yes';
        o2.Rates_set_at_Account_Level__c = 'Yes';
        o2.Competitor_s__c = 'AAPT';
        o2.Incumbent__c = 'Test';
        o2.Primary_Won_Reason__c = 'test';
        o2.Differentiating_Win_Factors__c = 'test';
        setrecursivevariable.firstRun = true;
        Database.SaveResult[] srList = Database.update(new List<Opportunity>{o, o2}, false);
        for(Database.SaveResult sr: srList) {
            System.assertEquals(true, sr.isSuccess());
        }
    }
    
    @isTest
    private static void testAmendmentPGIRenewals(){
        //Test.startTest();
        bypassDlrs = true;
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('ContactTriggerHandler');
        OpportunityTriggerHandler.bypassContactRole = true; //bad trigger - bypass for unit tests
        Account a = PGITestUtilities.createAccount(false);
        Account a2 = PGITestUtilities.createAccount(false);
        insert new List<Account>{a, a2};
            Opportunity o1 = PGITestUtilities.createOpportunity(a, false);
        o1.ownerId = PGITestUtilities.readyTalkUser.Id;
        o1.Opportunity_Deal_Type__c = 'Up-Sell (Rev Increase)';
        
        o1.RecordTypeId = PGI_Utility.getRecordTypes('Opportunity').get(OpportunityTriggerHandler.PGI_RT);
        //insert o1;
        Product2 p1 = new Product2(Name = 'mytestProduct1', Family = 'Unified Communications', IsActive = true, Clone_for_PGi_Renewal__c = true, Clone_For_PGI_Renewals_Renewal__c = true);
        Product2 p2 = new Product2(Name = 'mytestProduct2', Family = 'Unified Communications', IsActive = true, Clone_for_PGi_Renewal__c = true);
        Product2 p3 = new Product2(Name = 'NOTCARRYFORWARD', Family = 'Unified Communications', IsActive = true, Clone_for_PGi_Renewal__c = false);
        insert new List<Product2>{p1, p2, p3};
            
            Opportunity o2 = PGITestUtilities.createOpportunity(a2, false);
        o2.ownerId = PGITestUtilities.readyTalkUser.Id;
        
        o2.Opportunity_Deal_Type__c = 'Up-Sell (Rev Increase)';
        o2.RecordTypeId = PGI_Utility.getRecordTypes('Opportunity').get(OpportunityTriggerHandler.PGI_RT);
        //insert o2;
        insert new List<Opportunity>{o1, o2};
            
            insert new List<OpportunityTeamMember>{PGITestUtilities.createOpportunityTeamMember(o1, UserInfo.getUserId(), false),
                PGITestUtilities.createOpportunityTeamMember(o2, UserInfo.getUserId(), false)};
                    
                    System.assertEquals(4, [SELECT Id FROM OpportunityTeamMember].size());
        
        PricebookEntry pbe1 = PGITestUtilities.CreatePriceBookEntryForProduct(p1);
        PricebookEntry pbe2 = PGITestUtilities.CreatePriceBookEntryForProduct(p2);
        PricebookEntry pbe3 = PGITestUtilities.CreatePriceBookEntryForProduct(p3);
        
        insert new List<PricebookEntry>{pbe1, pbe2, pbe3};
            System.debug('QueryLimit' + LIMITS.getQueries());
            insert new List<OpportunityLineItem>{PGITestUtilities.getOpportunityLineItemDetails(o1.Id, pbe1.Id), 
                PGITestUtilities.getOpportunityLineItemDetails(o1.Id, pbe2.Id),
                PGITestUtilities.getOpportunityLineItemDetails(o1.Id, pbe3.Id),
                PGITestUtilities.getOpportunityLineItemDetails(o2.Id, pbe1.Id), 
                PGITestUtilities.getOpportunityLineItemDetails(o2.Id, pbe2.Id),
                PGITestUtilities.getOpportunityLineItemDetails(o2.Id, pbe3.Id)};
                    System.assertEquals(2, [SELECT Id FROM Opportunity].size());
        System.debug('QueryLimit' + LIMITS.getQueries());
        //two opps o1, o2 each with 3 product lines
        
        // System.assertEquals([SELECT Id, Opportunity_Product_Families__c FROM Opportunity WHERE Id =: o1.Id].Opportunity_Product_Families__c, 'Unified Communications');
        // System.assertEquals([SELECT Id, Opportunity_Product_Families__c FROM Opportunity WHERE Id =: o2.Id].Opportunity_Product_Families__c, 'Unified Communications');
        o1 = closePendReview(o1);
        o2 = closePendReview(o2);
        System.debug('QueryLimit' + LIMITS.getQueries());
        Test.startTest();
        //System.debug('QueryLimit' + LIMITS.getQueries());
        //setrecursivevariable.firstRun = true;
        update new List<Opportunity>{o1, o2};
            //System.debug('QueryLimit' + LIMITS.getQueries());
            System.debug('QueryLimit' + LIMITS.getQueries());
            
            Opportunity o3 = PGITestUtilities.createOpportunity(a, false);
        
        o3.ownerId = PGITestUtilities.readyTalkUser.Id;
        o3.Opportunity_Deal_Type__c = 'Up-Sell (Rev Increase)';
        o3.RecordTypeId = PGI_Utility.getRecordTypes('Opportunity').get(OpportunityTriggerHandler.PGI_RT);
        
        insert o3;
        System.debug('QueryLimit' + LIMITS.getQueries());
        insert new List<OpportunityLineItem>{PGITestUtilities.getOpportunityLineItemDetails(o3.Id, pbe1.Id), 
            PGITestUtilities.getOpportunityLineItemDetails(o3.Id, pbe2.Id),
            PGITestUtilities.getOpportunityLineItemDetails(o3.Id, pbe3.Id)};
                
                
                //System.debug('QueryLimit' + LIMITS.getQueries());
                o3 = closePendReview(o3);
        OpportunityTriggerHandler.renewalLinesAdjusted = new Set<Id>();
        
        o3.Opportunity_Product_Families__c = 'Unified Communications';
        //setrecursivevariable.firstRun = true;
        update o3;
        System.debug('QueryLimit' + LIMITS.getQueries());
        o3.StageName = 'Prospecting';
        OpportunityTriggerHandler.renewalLinesAdjusted = new Set<Id>();
        OpportunityTriggerHandler.renewalSyncProcessedOpps = new Set<Id>();
        update o3;
        System.debug('QueryLimit' + LIMITS.getQueries());
        //System.debug('QueryLimit' + LIMITS.getQueries());
        // oppList = [SELECT Id, External_Opportunity_Id__c, RecordTypeId, (SELECT Id, New_Quantity__c, Product2.Name, Quantity, OpportunityId FROM OpportunityLineItems), (SELECT Id FROM OpportunityTeamMembers) FROM Opportunity WHERE Id !=: o1.Id AND Id !=: o2.Id AND Id !=: o3.Id];
        // System.assertEquals(2, oppList.size());
        // System.assertEquals(2, oppList[0].OpportunityLineItems.size());
        // System.assertEquals(2, oppList[1].OpportunityLineItems.size());
        // oppLineAsserts = 0;
        // for(Opportunity opp: oppList) {
        //     System.assertEquals(2, opp.OpportunityTeamMembers.size());
        //     System.assertEquals(PGI_Utility.getRecordTypes('Opportunity').get(OpportunityTriggerHandler.PGI_RENEWAL_RT), opp.RecordTypeId);
        //     for(OpportunityLineItem oli: opp.OpportunityLineItems) {
        //          if(opp.External_Opportunity_Id__c == o1.Id){
        //             System.assertEquals(10, oli.New_Quantity__c);
        //             oppLineAsserts += 1;
        //         }
        //         System.assertNotEquals('NOTCARRYFORWARD', oli.Product2.Name);
        //     }
        // }
        // System.debug('QueryLimit' + LIMITS.getQueries());
        OpportunityTriggerHandler.renewalLinesAdjusted = new Set<Id>();
        OpportunityTriggerHandler.renewalSyncProcessedOpps = new Set<Id>();
        o3 = closePendReview(o3);
        System.debug('QueryLimit' + LIMITS.getQueries());
        // Test.stopTest();
        Test.stopTest();
        update o3;
        System.debug('QueryLimit' + LIMITS.getQueries());
        //System.debug('QueryLimit' + LIMITS.getQueries());
        // oppList = [SELECT Id, External_Opportunity_Id__c, RecordTypeId, (SELECT Id, New_Quantity__c, Product2.Name, Quantity, OpportunityId FROM OpportunityLineItems), (SELECT Id FROM OpportunityTeamMembers) FROM Opportunity WHERE Id !=: o1.Id AND Id !=: o2.Id AND Id !=: o3.Id];
        // System.assertEquals(2, oppList.size());
        // System.assertEquals(2, oppList[0].OpportunityLineItems.size());
        // System.assertEquals(2, oppList[1].OpportunityLineItems.size());
        // oppLineAsserts = 0;
        // for(Opportunity opp: oppList) {
        //     System.assertEquals(2, opp.OpportunityTeamMembers.size());
        //     System.assertEquals(PGI_Utility.getRecordTypes('Opportunity').get(OpportunityTriggerHandler.PGI_RENEWAL_RT), opp.RecordTypeId);
        //     for(OpportunityLineItem oli: opp.OpportunityLineItems) {
        //          if(opp.External_Opportunity_Id__c == o1.Id){
        //             System.assertEquals(20, oli.New_Quantity__c);
        //             oppLineAsserts += 1;
        //         }
        //         System.assertNotEquals('NOTCARRYFORWARD', oli.Product2.Name);
        //     }
        // }
        // System.assertEquals(2, oppLineAsserts, 'Amendment quantity failed to update ');
        
        
    }
    private static Opportunity closePendReview(Opportunity o) {
        o.StageName = 'Closed Pending Review';
        o.Close_Reason__c = 'We rock';
        o.PO_Date__c = System.today();
        o.PO_Number__c = '213123';
        o.Acct_Admin_Decison_Maker_Checked__c = 'Yes';
        o.Account_Assigned_To__c = UserInfo.getUserId();
        o.Prospect_Status__c = 'Event Sourced';
        o.Service_Term__c = 'Month to Month';
        o.Int_l_Audio_Rates_Discussed__c = 'Yes';
        o.Rates_set_at_Account_Level__c = 'Yes';
        o.One_Time_Revenue__c = true;
        o.Competitor_s__c = 'AAPT';
        o.Incumbent__c = 'Test';
        o.Primary_Won_Reason__c = 'test';
        o.Differentiating_Win_Factors__c = 'test';
        return o;
    }
    // test method for copyOppContactRoleData();
    private static testmethod void copyOppContactRoleDataTest(){
        Test.startTest();
        Account objAcc = PGITestUtilities.createAccount(true);
        Contact objCon = PGITestUtilities.createContact(objAcc, true);
        Opportunity objOpp = PGITestUtilities.createOpportunity(objAcc, true); 
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = objCon.Id;
        ocr.OpportunityId = objOpp.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Adversary';
        insert ocr;
        
        update objOpp;
        Opportunity testOpp = [SELECT ID, Primary_Contact__c, Primary_Role__c FROM Opportunity WHERE ID =: objOpp.Id limit 1];
        System.assertEquals(objCon.Id, testOpp.Primary_Contact__c);
        System.assertEquals('Adversary', testOpp.Primary_Role__c);
        
        Test.stopTest();
    }
    private static testMethod void covertestAmenedmentPart(){
        
        Product2 p1 = new Product2(Name = 'mytestProduct1', Family = 'Unified Communications', IsActive = true, Clone_for_PGi_Renewal__c = true, Clone_For_PGI_Renewals_Renewal__c = true);
        Product2 p2 = new Product2(Name = 'mytestProduct2', Family = 'Unified Communications', IsActive = true, Clone_for_PGi_Renewal__c = true);
        Product2 p3 = new Product2(Name = 'NOTCARRYFORWARD', Family = 'Unified Communications', IsActive = true, Clone_for_PGi_Renewal__c = false);
        insert new List<Product2>{p1, p2, p3};
            
        PricebookEntry pbe1 = PGITestUtilities.CreatePriceBookEntryForProduct(p1);
        PricebookEntry pbe2 = PGITestUtilities.CreatePriceBookEntryForProduct(p2);
        PricebookEntry pbe3 = PGITestUtilities.CreatePriceBookEntryForProduct(p3);
        
        insert new List<PricebookEntry>{pbe1, pbe2, pbe3};
            
        Account a = PGITestUtilities.createAccount(false);
        Account a2 = PGITestUtilities.createAccount(false);
        insert new List<Account>{a, a2}; 
        OT_Member__c objOtMember = new OT_Member__c(Name = 'Test1' , Evaluation_Order__c = '1' , Rule_Order__c = 3);
        INSERT objOtMember;
        Team_Member__c objTeamMenb = new Team_Member__c(Name = 'Test2' , OT_Member__c = objOtMember.Id , Role__c = 'Sales Rep' , CurrencyIsoCode = 'USD' ,User__c = UserInfo.getUserId());
        INSERT objTeamMenb;
        List<OT_Rule__c> lstOtRole = new List<OT_Rule__c>{new OT_Rule__c(Name = 'Test1', OT_Member__c = objOtMember.Id , Object_Name__c = 'Opportunity' , Field_Type__c = 'Text' , Field_Operator__c = 'notEqual' , Field_Value__c = 'opp' , Line_Number__c = 1 , Field_Name__c = 'Name' , CurrencyIsoCode = 'USD'),
        new OT_Rule__c(Name = 'Test12', OT_Member__c = objOtMember.Id , Object_Name__c = 'OpportunityLineItem' , Field_Type__c = 'Text' , Field_Operator__c = 'notEqual' , Field_Value__c = 'opp' , Line_Number__c = 1 , Field_Name__c = 'Name' , CurrencyIsoCode = 'USD')};
        INSERT lstOtRole;
        Opportunity o1 = PGITestUtilities.createOpportunity(a, false);
        o1.Name = 'Jack';
        o1.ownerId = PGITestUtilities.readyTalkUser.Id;
        o1.Opportunity_Deal_Type__c = 'Up-Sell (Rev Increase)';
        o1.RecordTypeId = PGI_Utility.getRecordTypes('Opportunity').get(OpportunityTriggerHandler.PGI_RT);
        
        Opportunity o2 = PGITestUtilities.createOpportunity(a2, false);
        o2.ownerId = PGITestUtilities.readyTalkUser.Id;        
        o2.Opportunity_Deal_Type__c = 'Up-Sell (Rev Increase)';
        o2.RecordTypeId = PGI_Utility.getRecordTypes('Opportunity').get(OpportunityTriggerHandler.PGI_RENEWAL_RT);
        
        insert new List<Opportunity>{o1, o2};
            Contact objCon = PGITestUtilities.createContact(a, true);
        OpportunityContactRole ocr1 = new OpportunityContactRole();
        ocr1.ContactId = objCon.Id;
        ocr1.OpportunityId = o1.Id;
        ocr1.IsPrimary = TRUE;
        ocr1.Role = 'Adversary';
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = objCon.Id;
        ocr.OpportunityId = o1.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Adversary';
        Test.startTest();
        insert new List<OpportunityContactRole>{ocr, ocr1};
            insert new List<OpportunityTeamMember>{PGITestUtilities.createOpportunityTeamMember(o1, UserInfo.getUserId(), false),
                PGITestUtilities.createOpportunityTeamMember(o2, UserInfo.getUserId(), false)};
                    
                    List<OpportunityLineItem> oppLitenItemList = new List<OpportunityLineItem>{PGITestUtilities.getOpportunityLineItemDetails(o1.Id, pbe1.Id), 
                        PGITestUtilities.getOpportunityLineItemDetails(o1.Id, pbe2.Id),
                        PGITestUtilities.getOpportunityLineItemDetails(o1.Id, pbe3.Id),
                        PGITestUtilities.getOpportunityLineItemDetails(o2.Id, pbe1.Id), 
                        PGITestUtilities.getOpportunityLineItemDetails(o2.Id, pbe2.Id),
                        PGITestUtilities.getOpportunityLineItemDetails(o2.Id, pbe3.Id)};
                            insert oppLitenItemList;
        OpportunityTriggerHandler objHandler = new OpportunityTriggerHandler();
        objHandler.getMatchOnProduct(oppLitenItemList, pbe2.Id);
        
        o2.StageName = 'Closed Pending Review';
        
        UPDATE o2;
        OpportunityTeamMember objOppTmMbr = [select Id,Name,opportunityId from opportunityTeamMember where opportunityId =: o1.Id LIMIT 1];
        System.debug('objOppTmMbr ---> '+objOppTmMbr);
        System.assertEquals(o1.Id, objOppTmMbr.OpportunityId);
    }
    /*@TestSetup
static void makeData(){
// Account objAcc = PGITestUtilities.createAccount(true);
// List<Opportunity> listOpportunity = new List<Opportunity>();
// Opportunity objOpp = PGITestUtilities.createClosedWonValidOpportunity(objAcc, false);
// objOpp.AccountId = objAcc.ID;
// objOpp.RecordTypeId = PGI_Utility.getRecordTypes('Opportunity').get(OpportunityTriggerHandler.PGI_RT);
// objOpp.Opportunity_Product_Families__c = 'test  Unified Communications test';
// //INSERT objOpp;
// listOpportunity.add(objOpp);
// // Opportunity objOpp1 = PGITestUtilities.createClosedWonValidOpportunity(objAcc, false);
// // objOpp1.RecordTypeId = PGI_Utility.getRecordTypes('Opportunity').get(OpportunityTriggerHandler.PGI_RENEWAL_RT);
// // objOpp1.Opportunity_Product_Families__c = 'test Unified Communications test';
// // objOpp1.AccountId = objAcc.ID;
// // insert objOpp1;
// Opportunity objOpp2 = PGITestUtilities.createClosedWonValidOpportunity(objAcc, false);
// objOpp2.RecordTypeId = PGI_Utility.getRecordTypes('Opportunity').get(OpportunityTriggerHandler.PGI_RENEWAL_RT);
// objOpp2.Opportunity_Product_Families__c = 'Unified Communications';
// objOpp2.AccountId = objAcc.ID;
// listOpportunity.add(objOpp2);

// insert objOpp2;
// ! ==========================================================================================
Product2 p1 = new Product2(Name = 'mytestProduct1', Family = 'Unified Communications', IsActive = true, Clone_for_PGi_Renewal__c = true, Clone_For_PGI_Renewals_Renewal__c = true);
Product2 p2 = new Product2(Name = 'mytestProduct2', Family = 'Unified Communications', IsActive = true, Clone_for_PGi_Renewal__c = true);
Product2 p3 = new Product2(Name = 'NOTCARRYFORWARD', Family = 'Unified Communications', IsActive = true, Clone_for_PGi_Renewal__c = false);
insert new List<Product2>{p1, p2, p3};

PricebookEntry pbe1 = PGITestUtilities.CreatePriceBookEntryForProduct(p1);
PricebookEntry pbe2 = PGITestUtilities.CreatePriceBookEntryForProduct(p2);
PricebookEntry pbe3 = PGITestUtilities.CreatePriceBookEntryForProduct(p3);

insert new List<PricebookEntry>{pbe1, pbe2, pbe3};

Account a = PGITestUtilities.createAccount(false);
Account a2 = PGITestUtilities.createAccount(false);
insert new List<Account>{a, a2}; 

Opportunity o1 = PGITestUtilities.createOpportunity(a, false);
o1.ownerId = PGITestUtilities.readyTalkUser.Id;
o1.Opportunity_Deal_Type__c = 'New Business';
o1.RecordTypeId = PGI_Utility.getRecordTypes('Opportunity').get(OpportunityTriggerHandler.PGI_RT);

Opportunity o2 = PGITestUtilities.createOpportunity(a2, false);
o2.ownerId = PGITestUtilities.readyTalkUser.Id;        
o2.Opportunity_Deal_Type__c = 'New Business';
o2.RecordTypeId = PGI_Utility.getRecordTypes('Opportunity').get(OpportunityTriggerHandler.PGI_RENEWAL_RT);

insert new List<Opportunity>{o1, o2};

insert new List<OpportunityTeamMember>{PGITestUtilities.createOpportunityTeamMember(o1, UserInfo.getUserId(), false),
PGITestUtilities.createOpportunityTeamMember(o2, UserInfo.getUserId(), false)};

insert new List<OpportunityLineItem>{PGITestUtilities.getOpportunityLineItemDetails(o1.Id, pbe1.Id), 
PGITestUtilities.getOpportunityLineItemDetails(o1.Id, pbe2.Id),
PGITestUtilities.getOpportunityLineItemDetails(o1.Id, pbe3.Id),
PGITestUtilities.getOpportunityLineItemDetails(o2.Id, pbe1.Id), 
PGITestUtilities.getOpportunityLineItemDetails(o2.Id, pbe2.Id),
PGITestUtilities.getOpportunityLineItemDetails(o2.Id, pbe3.Id)};
o2.StageName = 'Closed Pending Review';
UPDATE o2;
}
*/
    private static testMethod void  convertingAllProcessBuilder(){
        Product2 p1 = new Product2(Name = 'mytestProduct1', Family = 'Unified Communications', IsActive = true, Clone_for_PGi_Renewal__c = true, Clone_For_PGI_Renewals_Renewal__c = true);
        Product2 p2 = new Product2(Name = 'mytestProduct2', Family = 'Web: GlobalMeet', IsActive = true, Clone_for_PGi_Renewal__c = true);
        insert new List<Product2>{p1, p2};
            
            PricebookEntry pbe1 = PGITestUtilities.CreatePriceBookEntryForProduct(p1);
        PricebookEntry pbe2 = PGITestUtilities.CreatePriceBookEntryForProduct(p2);
        
        insert new List<PricebookEntry>{pbe1, pbe2};
            
            Account a = PGITestUtilities.createAccount(false);
        a.BaseConversion__c = true;
        insert a; 
        
        Opportunity o1 = PGITestUtilities.createOpportunity(a, false);
        o1.ownerId = PGITestUtilities.readyTalkUser.Id;
        o1.Opportunity_Deal_Type__c = 'New Business';
        o1.RecordTypeId = PGI_Utility.getRecordTypes('Opportunity').get(OpportunityTriggerHandler.PGI_RENEWAL_RT);
        
        insert new List<Opportunity>{o1};        
            test.startTest();
            insert new List<OpportunityTeamMember>{PGITestUtilities.createOpportunityTeamMember(o1, UserInfo.getUserId(), false)};
                
                insert new List<OpportunityLineItem>{PGITestUtilities.getOpportunityLineItemDetails(o1.Id, pbe1.Id), 
                    PGITestUtilities.getOpportunityLineItemDetails(o1.Id, pbe2.Id)};
                        o1 = closePendReview(o1);
        
        update new List<Opportunity>{o1};
            
        
        test.stopTest();
        //Start: cover updateOpportunityDealType()
       /* OpportunityTriggerHandler objHandler = new OpportunityTriggerHandler();
        Opportunity OppDealType  = PGITestUtilities.createOpportunity(a, false);
        OppDealType.Opportunity_Deal_Type__c = 'Win Back';
        objHandler.updateOpportunityDealType(OppDealType);
        OppDealType.Opportunity_Deal_Type__c = 'Up-Sell (Rev Increase)';
        objHandler.updateOpportunityDealType(OppDealType);
        OppDealType.Opportunity_Deal_Type__c = 'Down-Sell (Rev Decrease)';
        objHandler.updateOpportunityDealType(OppDealType);
        OppDealType.Opportunity_Deal_Type__c = 'Renewal (No Rev Change)';
        objHandler.updateOpportunityDealType(OppDealType);
        OppDealType.Opportunity_Deal_Type__c = 'Conversion';
        objHandler.updateOpportunityDealType(OppDealType);
        OppDealType.Opportunity_Deal_Type__c = 'New Business';
        objHandler.updateOpportunityDealType(OppDealType);
        OppDealType.Opportunity_Deal_Type__c = '';
        objHandler.updateOpportunityDealType(OppDealType);*/
        // END: cover updateOpportunityDealType()
        
    }
    // /*RT-386 start  ------------------*/
    // private static testMethod void TestClosedAprovalPendingOppty(){
    //     Account act = PGITestUtilities.createAccount(false);
    //     Insert act; 
        
    //     Opportunity oppObj = PGITestUtilities.createOpportunity(act, false);
    //     oppObj.Opportunity_Deal_Type__c = 'New Business';
    //     oppObj.Agreement_Status__c = 'Signed';
    //     INSERT oppObj;
        
    //     oppObj.Opportunity_Deal_Type__c = 'Win Back';
    //     UPDATE oppObj;
    //     String updatedStage = [SELECT stageName FROM Opportunity WHERE Id =: oppObj.Id].stageName;
    //     system.assertEquals(updatedStage, 'Closed Pending Approval');
    // }
    // /* RT-386 end ----------------------------*/
    private static testMethod void TestValidateClosedWon(){
        String myError = 'You must attach a written confirmation from the customer reviewing their increasing revenue costs or an email thread of the like before proceeding.';
        Account act = PGITestUtilities.createAccount(false);
        act.Type = 'End User - Agent';
        Insert act; 
        Opportunity oppObj = PGITestUtilities.createOpportunity(act, false);
        oppObj.Opportunity_Deal_Type__c = 'Up-Sell (Rev Increase)';
        oppObj.StageName = 'Closed Pending Review';
        
        oppObj.Opportunity_Product_Families__c = 'UCaaS';
        oppObj.RecordTypeId = PGI_Utility.getRecordTypes('Opportunity').get(OpportunityTriggerHandler.PGI_RT);
        INSERT oppObj;

        Product2 notTp = new Product2(Name = 'Not Party Support', Family = 'Collaboration', IsActive = true);
        insert notTp;
        PricebookEntry pbeNotTp = PGITestUtilities.CreatePriceBookEntryForProduct(notTp);
        insert new List<PricebookEntry>{pbeNotTp};
            insert PGITestUtilities.getOpportunityLineItemDetails(oppObj.Id, pbeNotTp.Id);
        oppObj.Channel__c = 'APAC';
        String error = '';
        try{
            UPDATE oppObj;
        }
        catch (DMLException  e){
           error = e.getMessage();
           Boolean expectedExceptionThrown =  e.getMessage().contains(myError) ? true : false;
           System.AssertEquals(expectedExceptionThrown, true);
       }
    //    System.assertEquals(myError, error);
     }
   /* private static testMethod void testProductfamilyvalue(){
        Test.startTest();
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.StageName = 'Closed Pending Approval';
        opp.Amount = 3000;
        opp.Opportunity_Product_Families__c = 'TPx';
        opp.CloseDate = System.today();
        insert opp;

        Opportunity oppUpdate = [SELECT Id,Name FROM Opportunity WHERE Name =: opp.Name ];
        oppUpdate.Name = 'Test Opportunity New';
        update oppUpdate;
        Test.stopTest();
    }*/
    @isTest
    private static void testPGIClosedWonRenewal() {
        bypassDlrs = true;
        TriggerHandler.bypass('AccountTriggerHandler');
        TriggerHandler.bypass('ContactTriggerHandler');
          List<Opportunity> opportunityList=new  List<Opportunity>();
        OpportunityTriggerHandler.bypassContactRole = true; //bad trigger - bypass for unit tests
        
        Account a = PGITestUtilities.createAccount(true);
        System.debug('The Account sales'+a.Original_Sales_Person__c);
        Account a2 = PGITestUtilities.createAccount(true);
        Opportunity o1 = PGITestUtilities.createOpportunity(a, false);
        o1.ownerId = PGITestUtilities.readyTalkUser.Id;
        o1.Opportunity_Deal_Type__c = 'New Business';
        o1.RecordTypeId = PGI_Utility.getRecordTypes('Opportunity').get(OpportunityTriggerHandler.PGI_RT);
       // insert o1;
       
         opportunityList.add(o1);
        Product2 p1 = new Product2(Name = 'mytestProduct1', Family = 'Collaboration', IsActive = true, Clone_for_PGi_Renewal__c = true);
        Product2 p2 = new Product2(Name = 'mytestProduct2', Family = 'Collaboration', IsActive = true, Clone_for_PGi_Renewal__c = true);
        Product2 p3 = new Product2(Name = 'NOTCARRYFORWARD', Family = 'Not Party', IsActive = true, Clone_for_PGi_Renewal__c = false);
        insert new List<Product2>{p1, p2, p3};
            
            Opportunity o2 = PGITestUtilities.createOpportunity(a2, false);
        o2.ownerId = PGITestUtilities.readyTalkUser.Id;
        o2.Opportunity_Deal_Type__c = 'New Business';
        o2.RecordTypeId = PGI_Utility.getRecordTypes('Opportunity').get(OpportunityTriggerHandler.PGI_RT);
       // insert o2;
        opportunityList.add(o2);
        
        insert opportunityList;
        //System.debug('The Id'+o2.AccountId);
        
        //System.debug('The Idssss'+[Select Original_Sales_Person__c from Account Where Id=:o2.AccountId].Original_Sales_Person__c);
        List<Implementation_Services__c> implementationServicesList = new List<Implementation_Services__c>();
        Implementation_Services__c objImpService = PGITestUtilities.getImplementationServices(o1.Id);
        implementationServicesList.add(objImpService);
        
        Implementation_Services__c objImpService2 = PGITestUtilities.getImplementationServices(o2.Id);
        implementationServicesList.add(objImpService2);
        insert implementationServicesList;
        
        OpportunityTriggerHandler objMethod = new OpportunityTriggerHandler();
        objMethod.isAmendment(o2);
        
        insert new List<OpportunityTeamMember>{PGITestUtilities.createOpportunityTeamMember(o1, UserInfo.getUserId(), false),
            PGITestUtilities.createOpportunityTeamMember(o2, UserInfo.getUserId(), false)};
                
                System.assertEquals(4, [SELECT Id FROM OpportunityTeamMember].size());
        
        PricebookEntry pbe1 = PGITestUtilities.CreatePriceBookEntryForProduct(p1);
        PricebookEntry pbe2 = PGITestUtilities.CreatePriceBookEntryForProduct(p2);
        PricebookEntry pbe3 = PGITestUtilities.CreatePriceBookEntryForProduct(p3);
        insert new List<PricebookEntry>{pbe1, pbe2, pbe3};
            
            insert new List<OpportunityLineItem>{PGITestUtilities.getOpportunityLineItemDetails(o1.Id, pbe1.Id), 
                PGITestUtilities.getOpportunityLineItemDetails(o1.Id, pbe2.Id),
                PGITestUtilities.getOpportunityLineItemDetails(o1.Id, pbe3.Id),
                PGITestUtilities.getOpportunityLineItemDetails(o2.Id, pbe1.Id), 
                PGITestUtilities.getOpportunityLineItemDetails(o2.Id, pbe2.Id),
                PGITestUtilities.getOpportunityLineItemDetails(o2.Id, pbe3.Id)};
                    System.assertEquals(2, [SELECT Id FROM Opportunity].size());
        //two opps o1, o2 each with 3 product lines
        
        o1 = closePendReview(o1);
        o2 = closePendReview(o2);
       /*o1.StageName = 'Closed Pending Approval';
        o2.StageName = 'Closed Pending Approval';
        update new List<Opportunity>{o1, o2};*/
       o1.StageName = 'Closed Won';
        o2.StageName = 'Closed Won';
        Test.startTest();
       update new List<Opportunity>{o1, o2};
           Test.stopTest();
            //assert renewal generation
            List<Opportunity> oppList = [SELECT Id, RecordTypeId, (SELECT Id, New_Quantity__c, Product2.Name, Quantity FROM OpportunityLineItems), (SELECT Id FROM OpportunityTeamMembers) FROM Opportunity WHERE Id !=: o1.Id AND Id !=: o2.Id];
        System.assertEquals(2, oppList.size());
        System.assertEquals(2, oppList[0].OpportunityLineItems.size());
        System.assertEquals(2, oppList[1].OpportunityLineItems.size());
        Integer oppLineAsserts = 0;
        for(Opportunity opp: oppList) {
            System.assertEquals(PGI_Utility.getRecordTypes('Opportunity').get(OpportunityTriggerHandler.PGI_RENEWAL_RT), opp.RecordTypeId);
            System.assertEquals(2, opp.OpportunityTeamMembers.size());
            for(OpportunityLineItem oli: opp.OpportunityLineItems) {
                System.assertNotEquals('NOTCARRYFORWARD', oli.Product2.Name);
                System.assertEquals(10, oli.New_Quantity__c);
                oppLineAsserts += 1;
            }
        }
        System.assertEquals(4, oppLineAsserts);
        
       // o1.StageName = 'Prospecting';
       // update o1;
        o1.StageName = 'Prospecting';
        o1 = closePendReview(o1);
        update o1;
        //assert reopening did not create additional lines
        oppList = [SELECT Id, RecordTypeId, (SELECT Id, New_Quantity__c, Product2.Name, Quantity FROM OpportunityLineItems), (SELECT Id FROM OpportunityTeamMembers) FROM Opportunity WHERE Id !=: o1.Id AND Id !=: o2.Id];
        System.assertEquals(2, oppList.size(), Database.query('SELECT Id, External_Opportunity_Id__c FROM Opportunity'));
        System.assertEquals(2, oppList[0].OpportunityLineItems.size());
        System.assertEquals(2, oppList[1].OpportunityLineItems.size());
        oppLineAsserts = 0;
        for(Opportunity opp: oppList) {
            System.assertEquals(2, opp.OpportunityTeamMembers.size());
            System.assertEquals(PGI_Utility.getRecordTypes('Opportunity').get(OpportunityTriggerHandler.PGI_RENEWAL_RT), opp.RecordTypeId);
            for(OpportunityLineItem oli: opp.OpportunityLineItems) {
                System.assertNotEquals('NOTCARRYFORWARD', oli.Product2.Name);
                System.assertEquals(10, oli.New_Quantity__c);
                oppLineAsserts += 1;
            }
        }
        
    }
    @isTest
    private static void testPGIMQA() {
       Account a = PGITestUtilities.createAccount(true);
        a.Global_Account_MQA__c = true;
        a.Global_Account_MQA_Assignment_date__c = system.today().addDays(-1);
        Update a;
       /* Contact c1a1 =new Contact();
        c1a1.AccountId=a.Id;
        c1a1.LastName='opptyContact1';
        c1a1.Global_Contact_MQL_Assignment_date__c = System.now().addDays(-1);
        Insert c1a1;  
        System.debug('The Account sales'+a.Original_Sales_Person__c);
        Account a2 = PGITestUtilities.createAccount(true);*/
        Opportunity o1 = PGITestUtilities.createOpportunity(a, false);
        Insert o1;
        o1.Opportunity_Deal_Type__c='New Business';
        Update o1;
        // System.assertEquals(true, [SELECT Id,Converted_from_MQA__c From Opportunity WHERE Id =: o1.Id].Converted_from_MQA__c);
        /*OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c1a1.Id;
        ocr.OpportunityId = o1.Id;
        ocr.Role='Champion';
          ocr.IsPrimary=true;
        Insert ocr;*/
    }
       @isTest
    private static void testMAL() {
       Account a = PGITestUtilities.createAccount(true);
        a.Global_Account_MQA__c = true;
        a.Global_Account_MQA_Assignment_date__c = system.today().addDays(-1);
        Update a;
        Contact c1a1 =new Contact();
        c1a1.AccountId=a.Id;
        c1a1.Global_Contact_MQL__c = true;
        c1a1.LastName='opptyContact1';
        c1a1.Global_Contact_MQL_Assignment_date__c = System.now().addDays(-1);
        Insert c1a1;  
        /*System.debug('The Account sales'+a.Original_Sales_Person__c);
        Account a2 = PGITestUtilities.createAccount(true);*/
        Opportunity o1 = PGITestUtilities.createOpportunity(a, false);
        Insert o1;
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c1a1.Id;
        ocr.OpportunityId = o1.Id;
        ocr.Role='Champion';
          ocr.IsPrimary=true;
        Insert ocr;
        o1.Opportunity_Deal_Type__c='New Business';
        Update o1;
        o1.Opportunity_Deal_Type__c='Renewal (No Rev Change)';
        Update o1;
        // System.assertEquals(true, [SELECT Id,Converted_From_Contact_MQL__c From Opportunity WHERE Id =: o1.Id].Converted_From_Contact_MQL__c);
        
    }
        @isTest
    private static void testMALelse() {
       Account a = PGITestUtilities.createAccount(true);
        a.Global_Account_MQA__c = true;
        a.Global_Account_MQA_Assignment_date__c = system.today().addDays(-1);
        Update a;
        Contact c1a1 =new Contact();
        c1a1.AccountId=a.Id;
        c1a1.Global_Contact_MQL__c = true;
        c1a1.LastName='opptyContact1';
        c1a1.Global_Contact_MQL_Assignment_date__c = System.now().addMonths(-8);
        Insert c1a1;  
        /*System.debug('The Account sales'+a.Original_Sales_Person__c);
        Account a2 = PGITestUtilities.createAccount(true);*/
        Opportunity o1 = PGITestUtilities.createOpportunity(a, false);
        Insert o1;
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c1a1.Id;
        ocr.OpportunityId = o1.Id;
        ocr.Role='Champion';
          ocr.IsPrimary=true;
        Insert ocr;
        o1.Opportunity_Deal_Type__c='New Business';
        Update o1;
        o1.Opportunity_Deal_Type__c='Renewal (No Rev Change)';
        Update o1;
        // System.assertEquals(false, [SELECT Id,Converted_From_Contact_MQL__c From Opportunity WHERE Id =: o1.Id].Converted_From_Contact_MQL__c);
        
    }
           @isTest
    private static void testfireEvent() {
        User Objuser = PGITestUtilities.getTestUser();
        insert Objuser;
        System.runAs(objuser) {
       Account account = PGITestUtilities.getAccountDetails();
            insert account;
            
            Account account1 = PGITestUtilities.getAccountDetails();
            account1.Ultimate_Parent_Account__c = account.Id;
            insert account1;
            
            
            
            Opportunity opp = PGITestUtilities.getOpportunityDetails();
            Insert opp;
            //Opportunity opportunity1 = PGITestUtilities.getOpportunityDetails();
            //Insert opportunity1;
            PGi_Company__c pgiComapny = PGITestUtilities.getPGiCompany(account.Id);
            pgiComapny.CorpCustSFAccountID__c = account.Id;
            pgiComapny.PGi_Entity_ID__c = 'sam';
            pgiComapny.DirectSFOpptyID__c = opp.Id;
            pgiComapny.RelatedAccount__c = account.Id;
            pgiComapny.Ultimate_Parent_Account__c = account1.Id;
            pgiComapny.PrimarySalesRep__c = Objuser.Id;
            //pgiComapny.SF_Opportunity_ID__c = opportunity.Id;
            insert pgiComapny;
            opp.PGICompany__c=pgiComapny.Id;
            Update opp;
            opp.Name='T2';
            Update opp;
        }
    }
}