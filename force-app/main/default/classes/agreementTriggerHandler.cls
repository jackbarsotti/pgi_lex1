/*
@ClassName    : agreementTriggerHandler
@JIRATicket   : RT-163
@CreatedOn    : 12/Jul/2019
@ModifiedBy   : Anup
@Description  : Class to Populate fields on Opportunity and PGI-Contract
*/
public class agreementTriggerHandler extends TriggerHandler  {
    public agreementTriggerHandler() {
        super('agreementTriggerHandler');
    }
    @TestVisible private static Set<Id> oppIdsProcessed = new Set<Id>();
	/*p
	* Method Name :afterInsert	
	* Params      : 
	* Description : Method will be called after Insertion of an Agreement
	*/
    
	public override void afterInsert(){
        agreementAdobeToCreateContract((List<echosign_dev1__SIGN_Agreement__c>) trigger.new);
    }
    /*
	* Method Name :afterUpdate
	* Params      : 
	* Description : Method will be called after Updating of an Agreement
	*/
    public override void afterUpdate(){
        agreementAdobeToCreateContract((List<echosign_dev1__SIGN_Agreement__c>) trigger.new);
        createAttachmentForOpportunity((List<echosign_dev1__SIGN_Agreement__c>) trigger.new);
    }


    //public static Set<Opportunity> opportunityToUpdateSet = new Set<Opportunity>();
    public static Map<String, RecordType> recordTypeContractByName { get{
        if(recordTypeContractByName == null){ 
            recordTypeContractByName = new Map<String, RecordType>();
            for(RecordType objRt : [SELECT Id, Name FROM RecordType 
                                    WHERE SobjectType = 'CONMAN_Contract__c'])
            { // 'International Contract, iContract' are renamed to APAC Contract,NA Contract 
                recordTypeContractByName.put(objRt.Name, objRt);
            }
        }
        return recordTypeContractByName;
    }set;}

   
    private Map<Id, Opportunity> opportunityUpdateById;
    /*
    * Method Name :agreementAdobeToCreateContract
    * Params : newAgreementList
    * Description : Method will be called to update fields on Opportunity and PGI-Contract.
    */
    private void agreementAdobeToCreateContract(List<echosign_dev1__SIGN_Agreement__c> newAgreementList){
        Set<Id> oppIds = new Set<Id>();
        for(echosign_dev1__SIGN_Agreement__c a: newAgreementList) {
            oppIds.add(a.echosign_dev1__Opportunity__c);
        }
        opportunityUpdateById = new Map<Id, Opportunity>([SELECT Id,AccountId,Has_PGI_Contract__c,IsClosed,
                                                                            Competitors__c,
                                                                            Differentiating_Win_Factors__c,
                                                                            Incumbent__c,
                                                                            Primary_Won_Reason__c,
                                                                            Secondary_Won_Reason__c,
                                                                            Tertiary_Won_Reason__c,
                                                                            Opportunity_Deal_Type__c,
                                                                            Agreement_Status__c,
                                                                            StageName
                                                                        FROM Opportunity 
                                                                        WHERE Id IN: oppIds]);


        Set<Opportunity> opportunityToUpdateSet = new Set<Opportunity>(); // used to Update the // opportunityToUpdateSet
        List<CONMAN_Contract__c> conmanContractForUpdateList = new List<CONMAN_Contract__c>();
        List<CONMAN_Contract__c> conmanContractForInsertList = new List<CONMAN_Contract__c>();
        Map<Id, echosign_dev1__SIGN_Agreement__c> newAgreementById = (Map<Id, echosign_dev1__SIGN_Agreement__c>) trigger.newMap;
        Set<Id> contractSentAgreementIdSet = new Set<Id>();
        Set<Id> rejectedIdSet = new Set<Id>();
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> signedAgreementIdSet = new Set<Id>();
        Set<Id> customerAcceptedAgreement = new Set<Id>(); // here we will store agreement Id to update Customer Signed Date on CONMAN_Contract__c

        for(echosign_dev1__SIGN_Agreement__c objAgreement : newAgreementList){
            userIdSet.add(objAgreement.CreatedById);
        }


        //Map to get User Details
        Map<Id,User> idToUserMap = new Map<Id,User>([SELECT Id,User_Region__c,Country From User Where Id IN : userIdSet]);

        for(echosign_dev1__SIGN_Agreement__c objAgreement : newAgreementList){
            if(objAgreement.echosign_dev1__Status__c <> 'Draft'){
                if(objAgreement.echosign_dev1__Opportunity__c != null) {
                    if(!opportunityUpdateById.containsKey(objAgreement.echosign_dev1__Opportunity__c)){
                        opportunityUpdateById.put(objAgreement.echosign_dev1__Opportunity__c ,new Opportunity(Id = objAgreement.echosign_dev1__Opportunity__c));
                    }
                    Opportunity objOpp = opportunityUpdateById.get(objAgreement.echosign_dev1__Opportunity__c);
                    objOpp.Agreement_Status__c = objAgreement.echosign_dev1__Status__c;
                }
            }

            // used to update Customer Signed Date. 
            if(objAgreement.echosign_dev1__Status__c == 'Signed'){ // Process Builder - Auto Populate Customer Signed Date-PGiContract
                customerAcceptedAgreement.add(objAgreement.Id);
            } 

            //  Only after Signed for India 
            if(objAgreement.echosign_dev1__Status__c == 'Signed'
                && opportunityUpdateById.containsKey(objAgreement.echosign_dev1__Opportunity__c) 
                && opportunityUpdateById.get(objAgreement.echosign_dev1__Opportunity__c).Has_PGI_Contract__c == false
                &&  idToUserMap.get(objAgreement.CreatedById).Country =='India' )
            {
                conmanContractForInsertList.add(createContract(objAgreement, opportunityUpdateById, recordTypeContractByName.get('APAC Contract').Id));
                closeWinOpportunity(objAgreement);
            }
            //Only after signed for APAC
            else if(objAgreement.echosign_dev1__Status__c == 'Signed' 
                    && opportunityUpdateById.containsKey(objAgreement.echosign_dev1__Opportunity__c) 
                    && idToUserMap.get(objAgreement.CreatedById).User_Region__c == 'APAC' 
                    && opportunityUpdateById.get(objAgreement.echosign_dev1__Opportunity__c).Has_PGI_Contract__c == false)
            {
                conmanContractForInsertList.add(createContract(objAgreement, opportunityUpdateById, recordTypeContractByName.get('APAC Contract').Id));
                closeWinOpportunity(objAgreement);
            }
            //Only after signed for EMEA
            else if(objAgreement.echosign_dev1__Status__c == 'Signed' 
                    && opportunityUpdateById.containsKey(objAgreement.echosign_dev1__Opportunity__c)
                    && idToUserMap.get(objAgreement.CreatedById).User_Region__c == 'EMEA' 
                    && opportunityUpdateById.get(objAgreement.echosign_dev1__Opportunity__c).Has_PGI_Contract__c == false)
            {
                conmanContractForInsertList.add(createContract(objAgreement, opportunityUpdateById, recordTypeContractByName.get('EMEA Contract').Id));
  
                closeWinOpportunity(objAgreement);             
            }
            //Only after signed for NA
            else if(objAgreement.echosign_dev1__Status__c == 'Signed' 
                    && opportunityUpdateById.containsKey(objAgreement.echosign_dev1__Opportunity__c)
                    && idToUserMap.get(objAgreement.CreatedById).User_Region__c == 'NA' 
                    && opportunityUpdateById.get(objAgreement.echosign_dev1__Opportunity__c).Has_PGI_Contract__c == false)
            {
                conmanContractForInsertList.add(createContract(objAgreement, opportunityUpdateById, recordTypeContractByName.get('NA Contract').Id));
                closeWinOpportunity(objAgreement);

            }
            //iContract - Contract sent for NA
            else if(objAgreement.echosign_dev1__Status__c == 'Out for Signature' 
                    && idToUserMap.get(objAgreement.CreatedById).User_Region__c == 'NA'
                    && objAgreement.Created_by_iContract__c == true)
            {
                contractSentAgreementIdSet.add(objAgreement.Id);
            }
            //iContract - Contract rejected for NA
            else if(objAgreement.echosign_dev1__Status__c == 'Cancelled / Declined' 
                    && idToUserMap.get(objAgreement.CreatedById).User_Region__c == 'NA'
                    && objAgreement.Created_by_iContract__c == true)
            {
                rejectedIdSet.add(objAgreement.Id);

            }
            //For Signed Agreement with PGi Contract
            else if(objAgreement.echosign_dev1__Status__c == 'Signed' 
                    && opportunityUpdateById.containsKey(objAgreement.echosign_dev1__Opportunity__c) 
                    && opportunityUpdateById.get(objAgreement.echosign_dev1__Opportunity__c).Has_PGI_Contract__c == true)
            {
                signedAgreementIdSet.add(objAgreement.Id);
                closeWinOpportunity(objAgreement);

            }
            //For cancelled agreements for open opptys
            else if(objAgreement.echosign_dev1__Status__c == 'Cancelled / Declined' 
                    && opportunityUpdateById.containsKey(objAgreement.echosign_dev1__Opportunity__c)
                    )
            {
                rejectOpportunity(objAgreement);
            }
        }

        if(!signedAgreementIdSet.isEmpty()){
            signedAgreementIdSet.remove(null);
        }
        if(!rejectedIdSet.isEmpty()){
            rejectedIdSet.remove(null);
        }
        if(!contractSentAgreementIdSet.isEmpty()){
            contractSentAgreementIdSet.remove(null);
        }
        for(CONMAN_Contract__c objContr : [SELECT Id,Contract_Status__c ,Related_Agreement__c, Customer_Signed_Date__c, Closed_By__c
                                            FROM CONMAN_Contract__c 
                                            WHERE Related_Agreement__c IN :signedAgreementIdSet OR Related_Agreement__c IN :rejectedIdSet OR Related_Agreement__c IN :contractSentAgreementIdSet OR Related_Agreement__c IN : customerAcceptedAgreement])
        {
            // update Customer_Signed_Date__c
            if(customerAcceptedAgreement.contains(objContr.Related_Agreement__c)){
                objContr.Customer_Signed_Date__c = newAgreementById.get(objContr.Related_Agreement__c).echosign_dev1__DateSignedDate__c;
            }
            if(signedAgreementIdSet.contains(objContr.Related_Agreement__c)){
                objContr.Closed_By__c ='eSignature';
                objContr.Contract_Status__c = 'Signed';
            }
            if(rejectedIdSet.contains(objContr.Related_Agreement__c)){
                objContr.Contract_Status__c = 'Customer Rejected';
            }
            if(contractSentAgreementIdSet.contains(objContr.Related_Agreement__c)){
                objContr.Contract_Status__c = 'Sent To Customer';
            }
            conmanContractForUpdateList.add(objContr);
        }
        TriggerHandler.bypass('agreementTriggerHandler');
        if(!conmanContractForInsertList.isEmpty()){
            INSERT conmanContractForInsertList; // objConmanContractListForInsert
        }
        //System.debug('test---------->-------------conmanContractForInsertList-----------------------------------------------------------------------');
        if(!conmanContractForUpdateList.isEmpty()){
            UPDATE conmanContractForUpdateList;
        }
        //System.debug('test---------->----------conmanContractForUpdateList--------------------------------------------------------------------------');
        if(!opportunityUpdateById.isEmpty()){
            OpportunityTriggerHandler.bypassContactRole = true;
            UPDATE opportunityUpdateById.values();
        } 
        //System.debug('test---------->-------opportunityUpdateById-----------------------------------------------------------------------------');
        //TriggerHandler.clearBypass('agreementTriggerHandler');
        
    }
    /**
    create CONMAN_Contract__c record 
     */
    private  CONMAN_Contract__c createContract(echosign_dev1__SIGN_Agreement__c objAgreement, Map<Id, Opportunity> opportunityUpdateById, String recordTypeId){
        CONMAN_Contract__c objContract = new CONMAN_Contract__c();
        // Only after Signed for India 
        objContract.Account_Name__c = opportunityUpdateById.get(objAgreement.echosign_dev1__Opportunity__c).AccountId;
        objContract.Opportunity__c = objAgreement.echosign_dev1__Opportunity__c;
        objContract.RecordTypeId = recordTypeId;
        objContract.Contract_Status__c ='Customer Accepted';
        objContract.Closed_By__c ='eSignature';
        objContract.Related_Agreement__c =objAgreement.Id;
        return objContract;
    } 
    private void rejectOpportunity(echosign_dev1__SIGN_Agreement__c objAgreement) {
        Opportunity objOpp = opportunityUpdateById.get(objAgreement.echosign_dev1__Opportunity__c);
        if(objOpp == null || objOpp.isClosed) { return; }
        objOpp.Competitors__c =  '';
        objOpp.Differentiating_Win_Factors__c=  '';
        objOpp.Incumbent__c =  '';
        objOpp.Primary_Won_Reason__c =  '';
        objOpp.Secondary_Won_Reason__c= '';
        objOpp.Tertiary_Won_Reason__c= '';
    }
    /**
    Create a Opportunity record
     */
    private void closeWinOpportunity(echosign_dev1__SIGN_Agreement__c objAgreement){
        Opportunity objOpp = opportunityUpdateById.get(objAgreement.echosign_dev1__Opportunity__c); 
        if(objOpp == null) { return; } 
        // objOpp.StageName ='Closed Won';

        if(objOpp.Agreement_Status__c == 'Signed' && objOpp.StageName != 'Closed Won') { 
            objOpp.StageName = 'Closed Pending Approval';
            
        }
    }

    @testVisible private static boolean testSigned = false;
    private void createAttachmentForOpportunity(List<echosign_dev1__SIGN_Agreement__c> newAgreementList){
        Map<Id, Id> opportunityIdByagId = new Map<Id, Id>();
        Map<Id, Attachment> attachmentByagreementId = new Map<Id, Attachment>();
        for(echosign_dev1__SIGN_Agreement__c ag: newAgreementList) {
            echosign_dev1__SIGN_Agreement__c og = (echosign_dev1__SIGN_Agreement__c)Trigger.oldMap.get(ag.Id);
            if(ag.echosign_dev1__Status__c == 'Signed' || testSigned){
                System.debug(ag.Id);
                opportunityIdByagId.put(ag.Id, ag.echosign_dev1__Opportunity__c);
            }
        }
        System.debug('opportunityIdByagId' + opportunityIdByagId);
        for(Attachment att : [SELECT Id, ParentId, Name, Body, OwnerId FROM Attachment where parentId IN : opportunityIdByagId.keySet() ORDER BY CreatedDate ASC]){
            attachmentByagreementId.put(att.ParentId, att);
        }
        
        List<Attachment> attachmentList = new List<Attachment>();
        for(Id agId : attachmentByagreementId.keySet()){
            String oppId = opportunityIdByagId.get(agId);
            if(!oppIdsProcessed.contains(oppId)) {
                oppIdsProcessed.add(oppID);
                Attachment agAttach = attachmentByagreementId.get(agId);
                Attachment oppAttach = new Attachment();
                oppAttach.Name = agAttach.Name;
                oppAttach.body = agAttach.body;
                oppAttach.parentId = oppID;
                attachmentList.add(oppAttach);
            }
        }
        if(!attachmentList.isEmpty()){
            INSERT attachmentList;
        }
    }
}