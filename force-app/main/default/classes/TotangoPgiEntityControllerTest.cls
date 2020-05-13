@isTest
public with sharing class TotangoPgiEntityControllerTest {
    @testSetup static void setup() {
        Test.startTest();
        PGi_Entity__c pgiEntityObject = new PGi_Entity__c(Name = 'test Entity',
                                                            Place_Holder__c = false,Next_Renewal_Date__c=Date.today().addDays(6));
        INSERT pgiEntityObject;
        // PGi_Entity__c pgiEntityObject1 = new PGi_Entity__c(Name = 'test Entity11',
        //                                                     Place_Holder__c = false);
        // INSERT pgiEntityObject1;
        PGi_Company__c pgiCompanyObject = new PGi_Company__c(Name = 'Test Company',
                                                            PGi_Entity__c = pgiEntityObject.Id, isActive__c=true);
        INSERT pgiCompanyObject;
        PGi_Company__c secondarypgiCompanyObject = new PGi_Company__c(Name = 'Test Company 2',
                                                            PGi_Entity__c = pgiEntityObject.Id, isActive__c=true);
        INSERT secondarypgiCompanyObject;
        PGi_Company__c pgiCompany = new PGi_Company__c(Name = 'Test Company 3',
                                                            PGi_Entity__c = pgiEntityObject.Id, isActive__c=true);
        INSERT pgiCompany;
        PGi_Company__c fourthpgiCompanyObject = new PGi_Company__c(Name = 'Test Company 4',
                                                            PGi_Entity__c =null, isActive__c=true);
        INSERT fourthpgiCompanyObject;
        
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        testOppty.Name = 'Opp Test 1';
        testOppty.PGiCompany__c = pgiCompanyObject.id;
        testOppty.PGiEntity__c=pgiEntityObject.id;
        testOppty.StageName = 'Awareness';
        testOppty.CloseDate = Date.today().addDays(3);
        testOppty.Competitor_s__c = 'Other';
        testOppty.Incumbent__c = 'Other';
        testOppty.Product__c = 'Web: GlobalMeet';
        testOppty.Opportunity_Deal_Type__c = 'New Business';
        testOppty.Channel__c = 'Cloud';
        testOppty.Renewal_Contract_Date__c = Date.today().addDays(3);
        insert testOppty;
        
        Opportunity testOppty3 = PGITestUtilities.getOpportunityDetails();
        testOppty3.Name = 'Opp Test 4';
        testOppty3.PGiCompany__c = fourthpgiCompanyObject.id;
        testOppty3.PGiEntity__c = null;
        testOppty3.StageName = 'Awareness';
        testOppty3.CloseDate = Date.today().addDays(3);
        testOppty3.Competitor_s__c = 'Other';
        testOppty3.Incumbent__c = 'Other';
        testOppty3.Product__c = 'Web: GlobalMeet';
        testOppty3.Opportunity_Deal_Type__c = 'New Business';
        testOppty3.Channel__c = 'Cloud';
        testOppty3.Renewal_Contract_Date__c = Date.today().addDays(3);
        insert testOppty3;
        
        Opportunity testOppty1 = PGITestUtilities.getOpportunityDetails();
        testOppty1.Name = 'Opp Test 2';
        testOppty1.PGiEntity__c = pgiEntityObject.id;
        testOppty1.StageName = 'Awareness';
        testOppty1.CloseDate = Date.today().addDays(3);
        testOppty1.Competitor_s__c = 'Other';
        testOppty1.Incumbent__c = 'Other';
        testOppty1.Product__c = 'Web: GlobalMeet';
        testOppty1.Opportunity_Deal_Type__c = 'New Business';
        testOppty1.Channel__c = 'Cloud';
        testOppty1.Renewal_Contract_Date__c = Date.today().addDays(3);
        
        insert testOppty1;
        
         Opportunity testOppty2 = PGITestUtilities.getOpportunityDetails();
        testOppty2.Name = 'Opp Test 3';
        testOppty2.PGiEntity__c = null;
        testOppty2.StageName = 'Awareness';
        testOppty2.CloseDate = Date.today().addDays(3);
        testOppty2.Competitor_s__c = 'Other';
        testOppty2.Incumbent__c = 'Other';
        testOppty2.Product__c = 'Web: GlobalMeet';
        testOppty2.Opportunity_Deal_Type__c = 'New Business';
        testOppty2.Channel__c = 'Cloud';
        testOppty2.Renewal_Contract_Date__c = Date.today().addDays(3);
        
        insert testOppty2;

        Case caseObj = new Case();
        caseObj.status='Closed';
        caseObj.PGi_Company__c = fourthpgiCompanyObject.id;
        Insert caseObj;
        Case caseObj1 = new Case();
        caseObj1.status='Open';
        caseObj1.PGi_Company__c = pgiCompanyObject.id;
        Insert caseObj1;
        Case caseObj2 = new Case();
        caseObj2.status='Open';
        caseObj2.PGi_Company__c = pgiCompanyObject.id;
        caseObj2.Area_of_Focus__c = 'Client Education/Request';
        Insert caseObj2;

        Id recordTypeId =  Schema.SObjectType.Financial_Request__c.getRecordTypeInfosByName().get('PGi-Company Cancellation Request').getRecordTypeId();
        Financial_Request__c fr = new Financial_Request__c(PGi_Company__c = pgiCompany.id);
		fr.Status__c = 'Approved';
        fr.RecordTypeId = recordTypeId;
        fr.DateofCancellationNotice__c = Date.today().addDays(3);
        Insert fr;
        Test.stopTest();
    }
    static testmethod void aggregateQueueable(){
        // Test.startTest(); 
        Set<String> pgiCompanyIdSet = new Set<String>();
        for(PGi_Company__c pgiCompanyObject: [SELECT Id 
                                   FROM PGi_Company__c ]){
                                    pgiCompanyIdSet.add(pgiCompanyObject.Id);
        }
        TotangoQueueableRecords objChildQueue = new TotangoQueueableRecords(pgiCompanyIdSet);
        // TotangoPgiEntityController obj = new TotangoPgiEntityController(pgiCompanyIdSet);
        // objChildQueue.pgiCompanyIdSet = pgiCompanyIdSet;
        // objChildQueue.recordsInstance = obj;
        system.enqueueJob(objChildQueue);
    
    }

    static testmethod void aggregatePGiCompany(){
        Test.startTest();
        Set<String> companyIdSet = new Set<String>();
        for(Financial_Request__c finReq: [SELECT PGI_Company__c FROM Financial_Request__c]) {
            companyIdSet.add(finReq.PGI_Company__c);
        }
        TotangoPgiEntityController obj = new TotangoPgiEntityController(companyIdSet);
        obj.companyById = new Map<Id, PGI_Company__c>([SELECT Id, Inactive_Date__c, PGi_Entity__c, Count_of_Open_Opportunities__c, Open_Opportunities_TCV__c, Next_Renewal_Deal_s_Stage__c,
        Open_Opportunities_ACV__c, Open_Opportunities_MRR__c, Open_Opportunities_NRR__c, Next_Renewal_Date__c, 
        Total_Closed_FinReq_Count__c, Total_Open_FinReq_Count__c,	Total_FinReq_Count__c, Cancellation_Service_Plan_Type__c, Cancellation_of_Services_Received__c, 
        Total_Cases_for_Customer_Education_in_Pa__c,Total_Cases_Open_in_Past_90_Days_from_c__c, Total_Open_Case_Count__c, Total_Closed_Case_Count__c,
        Total_Case_Count__c, Average_Age_of_Open_Cases__c FROM Pgi_Company__c]);
        obj.opportunitiesById = new Map<Id, Opportunity>([SELECT Id, PGiEntity__c, PGiCompany__c, StageName, Amount__c, Total_Annual_Value__c,Total_MRR_Formula__c, Total_NRR_Formula__c, Renewal_Contract_Date__c, Start_Date__c, isClosed, isWon
                                                        FROM Opportunity]);
        obj.finReqById = new Map<Id, Financial_Request__c>([SELECT Id, PGi_Company__c, Status__c,RecordTypeId,createdDate,  DateofCancellationNotice__c, ServicePlanType__c
                                                        FROM Financial_Request__c]);
        obj.caseById = new Map<Id, Case>([SELECT Id,PGi_Company__c, Status, CreatedDate,ClosedDate, Area_of_Focus__c, isClosed
                                            FROM Case]);
        
        Test.stopTest();
        obj.aggregateToPgiCompany();
        PGi_Company__c pgiCompanyObject =[SELECT TCV_of_all_Closed_Won_Deals__c,
                                                TCV_of_all_Closed_Lost_Deals__c,
                                                Count_of_Open_Opportunities__c, 
                                                Total_Closed_FinReq_Count__c,
                                                Total_Open_FinReq_Count__c,
                                                Total_FinReq_Count__c,
                                                Cancellation_Service_Plan_Type__c,
                                                Cancellation_of_Services_Received__c,
                                                Total_Cases_for_Customer_Education_in_Pa__c,
                                                Total_Cases_Open_in_Past_90_Days_from_c__c,
                                                Total_Open_Case_Count__c,
                                                Total_Closed_Case_Count__c,
                                                Average_Age_of_Open_Cases__c,
                                                Next_Renewal_Deal_s_Stage__c,
                                                Total_Case_Count__c 
                                                FROM PGi_Company__c
                                                WHERE Name = 'Test Company'];
        system.assertEquals(1, pgiCompanyObject.Count_of_Open_Opportunities__c);
        system.assertEquals(1, pgiCompanyObject.Total_Cases_for_Customer_Education_in_Pa__c);
        system.assertEquals(2, pgiCompanyObject.Total_Cases_Open_in_Past_90_Days_from_c__c);
        system.assertEquals(2, pgiCompanyObject.Total_Open_Case_Count__c);
        system.assertEquals(0, pgiCompanyObject.Total_Closed_Case_Count__c);
        system.assertEquals(0, pgiCompanyObject.Average_Age_of_Open_Cases__c);
        system.assertEquals(2, pgiCompanyObject.Total_Case_Count__c);
        System.debug('===>'+pgiCompanyObject);
                                                
        
    }
    static testmethod void aggregatePGiEntity(){
        test.startTest();
        Set<String> companyIdSet = new Set<String>();
        for(Financial_Request__c finReq: [SELECT PGI_Company__c FROM Financial_Request__c]) {
            companyIdSet.add(finReq.PGI_Company__c);
        }
        TotangoPgiEntityController obj = new TotangoPgiEntityController(companyIdSet);
        obj.opportunitiesById = new Map<Id, Opportunity>([SELECT Id, PGiEntity__c, PGiCompany__c, StageName, Amount__c, Total_Annual_Value__c,Total_MRR_Formula__c, Total_NRR_Formula__c, Renewal_Contract_Date__c, Start_Date__c, isClosed, isWon
                                                        FROM Opportunity]);
     
        obj.aggregateToPGIEntity();
        test.stopTest();
         PGi_Entity__c pgiEntityObject =[SELECT Count_of_Active_Companies__c,
                                                 Count_of_Open_Opportunities__c, 
                                                 Total_Closed_FinReq_Count__c,
                                                 Total_Open_FinReq_Count__c,
                                                 Total_FinReq_Count__c,
                                                 Total_Cases_for_Customer_Education_in_Pa__c,
                                                Total_Cases_Open_in_Past_90_Days_from_c__c,
                                                 Total_Open_Case_Count__c,
                                                Total_Closed_Case_Count__c,
                                                 Next_Renewal_Deal_s_Stage__c,
                                                 Total_Case_Count__c 
                                                 FROM PGi_Entity__c];

        
    }
}