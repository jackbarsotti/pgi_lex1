public class TotangoQueueableRecords implements Queueable {
    private Set<String> pgiCompanyIdSet = new Set<String>();
    private Set<String> pgiEntityIdSet = new Set<String>();
    public TotangoQueueableRecords(Set<String> pgiCompanyIdSet) {
        pgiCompanyIdSet.remove(null);
        pgiCompanyIdSet.remove('');
        this.pgiCompanyIdSet = pgiCompanyIdSet;
        if(!this.pgiCompanyIdSet.isEmpty()) {
            List<PGI_Company__c> pgiCompanies = [SELECT PGi_Entity__c FROM PGi_Company__c WHERE Id IN: pgiCompanyIdSet];
            for(PGI_Company__c comp: pgiCompanies) {
                this.pgiEntityIdSet.add(comp.PGI_Entity__c);
            }
        }
        this.pgiEntityIdSet.remove(null);
        this.pgiEntityIdSet.remove('');

        TotangoPgiEntityController obj = new TotangoPgiEntityController(pgiCompanyIdSet, pgiEntityIdSet);
        this.recordsInstance = obj;
    }
    public TotangoQueueableRecords(Set<String> pgiCompanyIdSet, Set<String> entityIds) {
        pgiCompanyIdSet.remove(null);
        pgiCompanyIdSet.remove('');
        this.pgiCompanyIdSet = pgiCompanyIdSet;
        this.pgiEntityIdSet = entityIds;

        if(!this.pgiCompanyIdSet.isEmpty()) {
            List<PGI_Company__c> pgiCompanies = [SELECT PGI_Entity__c FROM PGi_Company__c WHERE Id IN: pgiCompanyIdSet];
            for(PGI_Company__c comp: pgiCompanies) {
                this.pgiEntityIdSet.add(comp.PGI_Entity__c);
            }
        }
        this.pgiEntityIdSet.remove(null);
        this.pgiEntityIdSet.remove('');

        TotangoPgiEntityController obj = new TotangoPgiEntityController(pgiCompanyIdSet, entityIds);
        this.recordsInstance = obj;
    }

    public TotangoPgiEntityController recordsInstance;
    Map<Id, PGI_Company__c> pgiCompanyRecordsById = new Map<Id, PGI_Company__c>();
    Map<Id, Opportunity> opportunityRecordsById = new Map<Id, Opportunity>();
    Map<Id,Financial_Request__c> finReqRecordsById = new Map<Id,Financial_Request__c>();
    Map<Id,Case> caseRecordsById = new Map<Id,Case>();
    public void execute( QueueableContext qc ) {
        if(recordsInstance.isCompanyQuery) {
            getCompanyRecords();
        }
        // Getting Opportunities Related to PGI Company
        if(recordsInstance.isOpportunityQuery){
            getOpportunityRecords();  
        }
        // Getting FinRequests Related to PGI Company
        if(recordsInstance.isFinReqQuery){                                               
            getFinReqRecords();
        }
        //  Getting Cases Related to PGI Company
        if(recordsInstance.isCaseQuery){                                                     
            getCaseRecords();
        }

        if(!recordsInstance.isCompanyQuery && !recordsInstance.isCaseQuery && !recordsInstance.isFinReqQuery && !recordsInstance.isOpportunityQuery){
            TriggerHandler.bypass('PgiCompanyTriggerHandler');
            TriggerHandler.bypass('PgiEntityTriggerHandler');
            OpportunityTriggerHandlerTest.bypassDlrs = true;
            setrecursivevariable.firstRun = false;
            if(recordsInstance.reprocessCompanyDML == false && recordsInstance.reprocessEntityDML == false) {
                recordsInstance.aggregateToPgiCompany();
            } else if(recordsInstance.reprocessCompanyDML) {
                enqueueChildJob();
            }
            if(recordsInstance.reprocessCompanyDML == false) {
                recordsInstance.aggregateToPGIEntity();
                if(recordsInstance.reprocessEntityDML) {
                    enqueueChildJob();
                }
            }
        } else {
            enqueueChildJob();
        }
    }
    /**
     * method to call queueable class when the limit reached
     */
    private void enqueueChildJob(){
        TotangoQueueableRecords objChildQueue = new TotangoQueueableRecords(pgiEntityIdSet, pgiCompanyIdSet);
        objChildQueue.recordsInstance = recordsInstance;
        if(!Test.isRunningTest()){
            system.enqueueJob(objChildQueue);
        }
    }
    private integer queryLimit {get{ 
        return (Limits.getLimitQueryRows() - Limits.getQueryRows() - 10000);
    } set;}
    public void getCompanyRecords() {
        Integer thisQueryLimit = queryLimit;
        pgiCompanyRecordsById = new Map<Id, PGI_Company__c>([SELECT Id, Inactive_Date__c, PGi_Entity__c, Count_of_Open_Opportunities__c, Open_Opportunities_TCV__c, Next_Renewal_Deal_s_Stage__c,
                                                                Open_Opportunities_ACV__c, Open_Opportunities_MRR__c, Open_Opportunities_NRR__c, Next_Renewal_Date__c, 
                                                                Total_Closed_FinReq_Count__c, Total_Open_FinReq_Count__c,	Total_FinReq_Count__c, Cancellation_Service_Plan_Type__c, Cancellation_of_Services_Received__c, 
                                                                Total_Cases_for_Customer_Education_in_Pa__c,Total_Cases_Open_in_Past_90_Days_from_c__c, Total_Open_Case_Count__c, Total_Closed_Case_Count__c,
                                                                Total_Case_Count__c, Average_Age_of_Open_Cases__c
                                                            FROM PGI_Company__c WHERE PGi_Entity__c IN: pgiEntityIdSet  AND PGi_Entity__r.Place_Holder__c = false LIMIT: thisQueryLimit]);
        recordsInstance.companyById.putAll(pgiCompanyRecordsById);
        for(PGI_Company__c comp: pgiCompanyRecordsById.values()){ 
            this.pgiCompanyIdSet.add(comp.Id);
        }
        if(Limits.getQueryRows() < 40000){
            recordsInstance.isOpportunityQuery = true;
            recordsInstance.isCompanyQuery = false;
        }
    }
    /*
    * @description : Getting Opportunities
    * @author Anup Kage (anup@cloudfastener.com) | 3/16/2020 
    * @return void 
    **/
    public void getOpportunityRecords(){
        Integer thisQueryLimit = queryLimit;
        opportunityRecordsById = new Map<Id, Opportunity>();
        if(pgiCompanyIdSet != null && !pgiCompanyIdSet.isEmpty()) {
            opportunityRecordsById.putAll([SELECT Id, PGiCompany__c, PGIEntity__c, StageName, Amount__c, Total_Annual_Value__c,Total_MRR_Formula__c, Total_NRR_Formula__c, Renewal_Contract_Date__c, Start_Date__c, IsClosed, IsWon
                                                        FROM Opportunity
                                                        WHERE Id NOT IN: recordsInstance.opportunitiesById.keySet()  AND
                                                        PGiCompany__r.Placeholder__c = false AND PGiCompany__c IN: pgiCompanyIdSet 
                                                        LIMIT :thisQueryLimit]);
        }
        if(pgiEntityIdSet != null && !pgiEntityIdSet.isEmpty()) {
            opportunityRecordsById.putAll([SELECT Id, PGiCompany__c, PGIEntity__c, StageName, Amount__c, Total_Annual_Value__c,Total_MRR_Formula__c, Total_NRR_Formula__c, Renewal_Contract_Date__c, Start_Date__c, IsClosed, IsWon
                                                        FROM Opportunity
                                                        WHERE Id NOT IN: recordsInstance.opportunitiesById.keySet()  AND
                                                        PGiCompany__r.Placeholder__c = false AND PGIEntity__c IN: pgiEntityIdSet 
                                                        LIMIT :thisQueryLimit]);
        }
        recordsInstance.opportunitiesById.putAll(opportunityRecordsById);
        if(Limits.getQueryRows() < 40000){
            recordsInstance.isOpportunityQuery = false;
            recordsInstance.isFinReqQuery = true;
        }

    }
    /**
    * @description : Getting Financial Requests
    * @author Anup Kage (anup@cloudfastener.com) | 3/16/2020 
    * @return void 
    **/
    public void getFinReqRecords(){
        Integer thisQueryLimit = queryLimit;
        finReqRecordsById = new Map<Id,Financial_Request__c>([SELECT Id, PGi_Company__c, Status__c,RecordTypeId,createdDate,  DateofCancellationNotice__c, ServicePlanType__c
                                                                FROM Financial_Request__c
                                                                WHERE Id NOT IN: recordsInstance.finReqById.keySet() 
                                                                AND PGi_Company__r.Placeholder__c = false 
                                                                AND PGi_Company__c IN: pgiCompanyIdSet
                                                                LIMIT :thisQueryLimit]);
        recordsInstance.finReqById.putAll(finReqRecordsById);
        if(Limits.getQueryRows() < 40000){
            recordsInstance.isFinReqQuery = false;
            recordsInstance.isCaseQuery = true;
        }
    }
    /**
    * @description : Getting Cases
    * @author Anup Kage (anup@cloudfastener.com) | 3/16/2020 
    * @return void 
    **/
    public void getCaseRecords(){
        Integer thisQueryLimit = queryLimit;
        caseRecordsById = new Map<Id,Case>([SELECT Id,PGi_Company__c, Status, CreatedDate,ClosedDate, Area_of_Focus__c, IsClosed
                                            FROM Case 
                                            WHERE Id NOT IN: recordsInstance.caseById.keySet() 
                                            AND PGi_Company__r.Placeholder__c = false 
                                            AND PGi_Company__c IN: pgiCompanyIdSet
                                            LIMIT :thisQueryLimit]);
        recordsInstance.caseById.putAll(caseRecordsById);
        if(Limits.getQueryRows() < 40000){
            recordsInstance.isCaseQuery = false;
        }
    }
}