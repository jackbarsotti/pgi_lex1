/*********************************************************************
Name : Test_CreateCampaignHistoryFromLead 
Created On : feb 10, 2012 
Created By : Lalit Bohra
Description :Test class for Lead Trigger CreateCampaignHistoryFromLead functionality.
Task :T-27664
**********************************************************************/
@isTest
private class Test_CreateCampaignHistoryFromLead {

    /*
     * This method tests that the SGLeadEvents trigger properly attaches the campaign
     * before converting to a lead, although the CreateCampaignHistoryFromLead event
     * doesn't do this itself
     * */
     /*
    static testMethod void createCampaignHistoryFromSalesGatewayUnitTest() {
        system.debug('T1: Start');
        
        system.debug('T1: Inserting a Campaigns');
        list<Campaign> listCampaign = new list<Campaign>();  
        
        Campaign objCampaign= new Campaign();
        objCampaign.Name='Test Campaign1';
        objCampaign.CurrencyIsoCode='USD';
        listCampaign.add(objCampaign); 
        
        insert listCampaign;
        system.debug('T1: Inserted a Campaigns');
        
        system.debug('T1: Inserting a Omniture Campaigns');
        list<Omniture_Campaign_Code__c> listCampaignCode = new list<Omniture_Campaign_Code__c>();
        
        Omniture_Campaign_Code__c objOmniture= new Omniture_Campaign_Code__c();
        objOmniture.Campaign__c=objCampaign.Id;        
        objOmniture.Omniture_Campaign_Code__c='AB:CD:EF';
        listCampaignCode.add(objOmniture);
        
        insert listCampaignCode; 
        system.debug('T1: Inserted a Omniture Campaigns');

        test.startTest(); // merely placed to help with SOQL limits in this test

        system.debug('T1: Inserting a Leads');
        list<Lead> LeadList= new list<Lead>(); 

        Lead objLead1= new Lead();
        objLead1.Company='Test Company';
        objLead1.FirstName='Test Lead';
        objLead1.LastName='Test Lead';
        objLead1.Status='Open Working';
        objLead1.CurrencyIsoCode='USD';
        objLead1.Omniture_Campaign_Code__c='AB:CD:EF';
        objLead1.IM_USER_ID__c='TestUser Id11';
        ObjLead1.Phone='111-111-1111';
        ObjLead1.Email='Testing@testsite.com';
        ObjLead1.z_Source__c='Salesgateway';
        ObjLead1.Street='Street';
        ObjLead1.City='Atlanta';
        ObjLead1.State='Georgia';
        ObjLead1.PostalCode='30303';
        ObjLead1.Country='United States';
        LeadList.add(ObjLead1);

        insert LeadList;
        system.debug('T1: Inserted a Leads'); 
        
        system.debug('T1: Stop');
        test.stopTest();
        
        set<Id> LeadIdset= new set<Id>();
        LeadIdset.add(objLead1.Id);
        list<CampaignMember> CampaignMemberList=[Select id from CampaignMember where LeadId in:LeadIdset];        
        list<Lead> NewLeadList=[Select id from Lead where id in:LeadIdset and Omniture_Campaign_Code__c= null and Omniture_Campaign_Code_Copy__c !=null];
        system.debug('T1: CampaignMemberList: '+CampaignMemberList);
        system.debug('T1: NewLeadList: '+NewLeadList);
        // Two out of the two leads should get attached to the campaigns
        //system.assert(CampaignMemberList != null, 'null campaignmember list');
        //system.assert(CampaignMemberList.size() == 1, 'not enough campaignmember leads');
        //system.assert(NewLeadList != null, 'null leads with correct omniture codes list');
        //system.assert(NewLeadList.size() == 1, 'not enough leads with correct omniture codes');   
    }

    
     * This method tests that the SGLeadEvents trigger properly attaches the campaign
     * before converting to a lead, although the CreateCampaignHistoryFromLead event
     * doesn't do this itself
     * Part two to avoid SOQL limits in test
   
     
    static testMethod void createCampaignHistoryFromSalesGatewayUnitTest2() {
        system.debug('T1-2: Start');
        
        system.debug('T1-2: Inserting Two Campaigns');
        list<Campaign> listCampaign = new list<Campaign>();  
        
        Campaign objCampaign= new Campaign();
        objCampaign.Name='Test Campaign1';
        objCampaign.CurrencyIsoCode='USD';
        listCampaign.add(objCampaign);
        
        Campaign objCampaign2= new Campaign();
        objCampaign2.Name='Test Campaign2';
        objCampaign2.CurrencyIsoCode='USD';
        listCampaign.add(objCampaign2);   
        
        insert listCampaign;
        system.debug('T1-2: Inserted Two Campaigns');
        
        system.debug('T1-2: Inserting Two Omniture Campaigns');
        list<Omniture_Campaign_Code__c> listCampaignCode = new list<Omniture_Campaign_Code__c>();
        
        Omniture_Campaign_Code__c objOmniture= new Omniture_Campaign_Code__c();
        objOmniture.Campaign__c=objCampaign.Id;        
        objOmniture.Omniture_Campaign_Code__c='AB:CD:EF';
        listCampaignCode.add(objOmniture);
        
        Omniture_Campaign_Code__c objOmniture1= new Omniture_Campaign_Code__c();
        objOmniture1.Campaign__c=objCampaign2.Id;
        objOmniture1.Omniture_Campaign_Code__c='EF:GH:IJ';
        listCampaignCode.add(objOmniture1);
        
        insert listCampaignCode; 
        system.debug('T1-2: Inserted Two Omniture Campaigns');

        test.startTest(); // merely placed to help with SOQL limits in this test

        system.debug('T1-2: Inserting One Lead');
        list<Lead> LeadList= new list<Lead>(); 

        Lead objLead3= new Lead();
        objLead3.Company='Test Company3';
        objLead3.FirstName='Test Lead3';
        objLead3.LastName='Test Lead3';
        objLead3.Status='Open Working';
        objLead3.CurrencyIsoCode='USD';
        objLead3.Omniture_Campaign_Code__c='NONE';
        objLead3.IM_USER_ID__c='TestUser Id13';
        ObjLead3.Phone='111-111-1111';
        ObjLead3.Email='Testing@testsite.com';
        ObjLead3.z_Source__c='Salesgateway';
        ObjLead3.Street='Street';
        ObjLead3.City='Atlanta';
        ObjLead3.State='Georgia';
        ObjLead3.PostalCode='30303';
        ObjLead3.Country='United States';
        LeadList.add(ObjLead3);

        insert LeadList;
        system.debug('T1-2: Inserted One Lead'); 
        
        system.debug('T1-2: Stop');
        test.stopTest();
        
        set<Id> LeadIdset= new set<Id>();
        LeadIdset.add(objLead3.Id);
        list<CampaignMember> CampaignMemberList=[Select id from CampaignMember where LeadId in:LeadIdset];        
        list<Lead> NewLeadList=[Select id from Lead where id in:LeadIdset and Omniture_Campaign_Code__c= null and Omniture_Campaign_Code_Copy__c !=null];
        system.debug('T1-2: CampaignMemberList: '+CampaignMemberList);
        system.debug('T1-2: NewLeadList: '+NewLeadList);
        // None of the leads should get attached to the campaigns
        //system.assert(CampaignMemberList != null, 'null campaignmember list');
        //system.assert(CampaignMemberList.size() == 0, 'too many campaignmember leads');
        //system.assert(NewLeadList != null, 'null leads with correct omniture codes list');
        //system.assert(NewLeadList.size() == 0, 'too many leads with correct omniture codes');   
    }

    
     * This method tests that the SGLeadEvents trigger properly attaches the campaign
     * before converting to a lead, although the CreateCampaignHistoryFromLead event
     * doesn't do this itself
     * Part three to avoid SOQL limits in test
     * 
    static testMethod void createCampaignHistoryFromSalesGatewayUnitTest3() {
        system.debug('T1-3: Start');
        
        system.debug('T1-3: Inserting a Campaigns');
        list<Campaign> listCampaign = new list<Campaign>();  
        
        Campaign objCampaign2= new Campaign();
        objCampaign2.Name='Test Campaign2';
        objCampaign2.CurrencyIsoCode='USD';
        listCampaign.add(objCampaign2);   
        
        insert listCampaign;
        system.debug('T1-3: Inserted a Campaigns');
        
        system.debug('T1-3: Inserting a Omniture Campaigns');
        list<Omniture_Campaign_Code__c> listCampaignCode = new list<Omniture_Campaign_Code__c>();
        
        Omniture_Campaign_Code__c objOmniture1= new Omniture_Campaign_Code__c();
        objOmniture1.Campaign__c=objCampaign2.Id;
        objOmniture1.Omniture_Campaign_Code__c='EF:GH:IJ';
        listCampaignCode.add(objOmniture1);
        
        insert listCampaignCode; 
        system.debug('T1-3: Inserted a Omniture Campaigns');

        test.startTest(); // merely placed to help with SOQL limits in this test

        system.debug('T1-3: Inserting a Leads');
        list<Lead> LeadList= new list<Lead>(); 
        
        Lead objLead2= new Lead();
        objLead2.Company='Test Company2';
        objLead2.FirstName='Test Lead2';
        objLead2.LastName='Test Lead2';
        objLead2.Status='Open Working';
        objLead2.CurrencyIsoCode='USD';
        objLead2.Omniture_Campaign_Code__c='EF:GH';
        objLead2.IM_USER_ID__c='TestUser Id12';
        ObjLead2.Phone='111-111-1111';
        ObjLead2.Email='Testing@testsite.com';
        ObjLead2.z_Source__c='Salesgateway';
        ObjLead2.Street='Street';
        ObjLead2.City='Atlanta';
        ObjLead2.State='Georgia';
        ObjLead2.PostalCode='30303';
        ObjLead2.Country='United States';
        LeadList.add(ObjLead2);

        insert LeadList;
        system.debug('T1-3: Inserted a Leads'); 
        
        system.debug('T1-3: Stop');
        test.stopTest();
        
        set<Id> LeadIdset= new set<Id>();
        LeadIdset.add(objLead2.Id);
        list<CampaignMember> CampaignMemberList=[Select id from CampaignMember where LeadId in:LeadIdset];        
        list<Lead> NewLeadList=[Select id from Lead where id in:LeadIdset and Omniture_Campaign_Code__c= null and Omniture_Campaign_Code_Copy__c !=null];
        system.debug('T1-3: CampaignMemberList: '+CampaignMemberList);
        system.debug('T1-3: NewLeadList: '+NewLeadList);
        // Two out of the two leads should get attached to the campaigns
        //system.assert(CampaignMemberList != null, 'null campaignmember list');
        //system.assert(CampaignMemberList.size() == 1, 'not enough campaignmember leads');
        //system.assert(NewLeadList != null, 'null leads with correct omniture codes list');
        //system.assert(NewLeadList.size() == 1, 'not enough leads with correct omniture codes');   
    }

    
     * This method tests that the CreateCampaignHistoryFromLead trigger properly
     * attaches the campaign to the right leads, on insert and update
     * 
    static testMethod void createCampaignHistoryFromLeadUnitTest() {
        system.debug('T3: Start');
        
        system.debug('T3: Inserting Two Campaigns');
        list<Campaign> listCampaign = new list<Campaign>();  
        
        Campaign objCampaign= new Campaign();
        objCampaign.Name='Test Campaign1';
        objCampaign.CurrencyIsoCode='USD';
        listCampaign.add(objCampaign);
        
        Campaign objCampaign2= new Campaign();
        objCampaign2.Name='Test Campaign2';
        objCampaign2.CurrencyIsoCode='USD';
        listCampaign.add(objCampaign2);   
        
        insert listCampaign;
        system.debug('T3: Inserted Two Campaigns');
        
        system.debug('T3: Inserting Two Omniture Campaigns');
        list<Omniture_Campaign_Code__c> listCampaignCode = new list<Omniture_Campaign_Code__c>();
        
        Omniture_Campaign_Code__c objOmniture= new Omniture_Campaign_Code__c();
        objOmniture.Campaign__c=objCampaign.Id;        
        objOmniture.Omniture_Campaign_Code__c='AB:CD:EF';
        listCampaignCode.add(objOmniture);
        
        Omniture_Campaign_Code__c objOmniture1= new Omniture_Campaign_Code__c();
        objOmniture1.Campaign__c=objCampaign2.Id;
        objOmniture1.Omniture_Campaign_Code__c='EF:GH:IJ';
        listCampaignCode.add(objOmniture1);
        
        insert listCampaignCode; 
        system.debug('T3: Inserted Two Omniture Campaigns');
         
        system.debug('T3: Inserting Four Leads');
        list<Lead> LeadList= new list<Lead>(); 
        
        Lead objLead1= new Lead();
        objLead1.Company='Test Company1';
        objLead1.LastName='Test Lead1';
        objLead1.Status='Open Working';
        objLead1.CurrencyIsoCode='USD';
        objLead1.Omniture_Campaign_Code__c='AB:CD:EF';
        objLead1.IM_USER_ID__c='TestUser Id11';
        ObjLead1.Email='Testing@testsite.com';
        LeadList.add(ObjLead1);

        test.startTest(); // merely placed to help with SOQL limits in this test
        
        Lead objLead2= new Lead();
        objLead2.Company='Test Company2';
        objLead2.LastName='Test Lead2';
        objLead2.Status='Open Working';
        objLead2.Omniture_Campaign_Code__c='123'; // There's no campaign for this, it should nomatch
        objLead2.CurrencyIsoCode='USD';
        objLead2.IM_USER_ID__c='TestUser Id12';
        ObjLead2.Email='Testing@testsite.com';
        LeadList.add(ObjLead2);
        
        Lead objLead3= new Lead();
        objLead3.Company='Test Company3';
        objLead3.LastName='Test Lead3';
        objLead3.Status='Open Working';
        objLead3.Omniture_Campaign_Code__c='123'; // There's no campaign for this, it should nomatch
        objLead3.CurrencyIsoCode='USD';
        objLead3.IM_USER_ID__c='TestUser Id13';
        ObjLead3.Email='Testing@testsite.com';
        LeadList.add(ObjLead3);
        
        Lead objLead4= new Lead();
        objLead4.Company='Test Company4';
        objLead4.LastName='Test Lead4';
        objLead4.Status='Open Working';
        objLead4.Omniture_Campaign_Code__c='123'; // There's no campaign for this, it should nomatch
        objLead4.CurrencyIsoCode='USD';
        objLead4.IM_USER_ID__c='TestUser Id14';
        ObjLead4.Email='Testing@testsite.com';
        LeadList.add(ObjLead4);
       
        insert LeadList;
        system.debug('T3: Inserted Four Leads');
        
        system.debug('T3: Inserting Three Leads to Campaigns');
        objLead2.Omniture_Campaign_Code__c='EF:GH:IJ'; // should get added
        objLead3.Omniture_Campaign_Code__c='EF:GH'; // should get added
        objLead4.Omniture_Campaign_Code__c='NoMatch'; // should not get added
        update LeadList;  
        // second blank update is for increasing code coverage.
        update LeadList;
        system.debug('T3: Inserted Three Leads to Campaigns');  
        
        test.stopTest();
        system.debug('T3: End');
        
        set<Id> LeadIdset= new set<Id>();
        LeadIdset.add(objLead1.Id);
        LeadIdset.add(objLead2.Id);
        LeadIdset.add(objLead3.Id);
        LeadIdset.add(objLead4.Id);
        list<CampaignMember> CampaignMemberList=[Select id from CampaignMember where LeadId in:LeadIdset];
        list<Lead> NewLeadList=[Select id,Omniture_Campaign_Code__c,Omniture_Campaign_Code_Copy__c,Omniture_Campaign_Code_No_Match_Found__c from Lead where id in:LeadIdset and Omniture_Campaign_Code__c = null and Omniture_Campaign_Code_Copy__c != null];
        system.debug('T3: CampaignMemberList: '+CampaignMemberList);
        system.debug('T3: NewLeadList: '+NewLeadList);
        // Three out of the four leads should get attached to the campaigns
        //system.assert(CampaignMemberList != null, 'null campaignmember list');
        //system.assert(CampaignMemberList.size() == 3, 'not enough campaignmember leads');
        //system.assert(NewLeadList != null, 'null leads with correct omniture codes list');
        //system.assert(NewLeadList.size() == 3, 'not enough leads with correct omniture codes');    
        */
   // }
}