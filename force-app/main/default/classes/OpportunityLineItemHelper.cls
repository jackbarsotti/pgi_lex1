public with sharing class OpportunityLineItemHelper extends TriggerHandler {
    public OpportunityLineItemHelper() {
        super('OpportunityLineItemHelper');
    }
    protected override void beforeInsert() {
        updateOpportunityLineItemField();
        // validateExistingService(Trigger.new); // commented by Anup - CloudFastener 
    } 
    protected override void beforeUpdate() {
       updateOpportunityLineItemField();
        // validateExistingService(Trigger.new); // commented by Anup - CloudFastener  // because we are not updatng any field or throwing error
    }
     protected override void afterUpdate() {
       updateOpprtunity(Trigger.new);
        // validateExistingService(Trigger.new); // commented by Anup - CloudFastener  // because we are not updatng any field or throwing error
    }
     protected override void afterInsert() {
       updateOpprtunity(Trigger.new);
        // validateExistingService(Trigger.new); // commented by Anup - CloudFastener  // because we are not updatng any field or throwing error
    }
    protected override void afterDelete() {
        updateOpprtunity(Trigger.old);
    }
    /*
    public static void validateExistingService(List<OpportunityLineItem> opliList){
        //Skip validation if Override_Validation_Rules__c = true
        User currentUser = PGI_Utility.currentUser;
        if (!currentUser.Override_Validation_Rules__c){
            Set<Id> oppIds = new Set<Id>();
            for(OpportunityLineItem opli : opliList){
                oppIds.add(opli.OpportunityId);         
            }
            //system.debug('ARC debug oppids:'+oppIds);
            //Get Count of Existing Service from new inputs
            Map<Id, Opportunity> oppExCustExSvcMap = new Map<Id, Opportunity>([SELECT Id, Type FROM Opportunity WHERE recordtype.name like '%PGi%' and Id =: oppIds AND Type = 'Existing Cust- Existing Svc']);
            //system.debug('ARC debug oppmap'+oppExCustExSvcMap);
            Map<Id, Integer> countExistingServiceMap = new Map<Id, Integer>();
            //system.debug('ARC debug Opp Line Items : '+opliList);
            for(OpportunityLineItem opli : opliList) {
                //system.debug('ARC debug product name : ' +opli.pricebookentryid);
                //system.debug('ARC debug existing service : ' +opli.Existing_Service__c);
                Id oppId = opli.OpportunityId;
                if(oppExCustExSvcMap.containsKey(oppId))
                {
                    if(!countExistingServiceMap.containsKey(oppId))
                    {
                        countExistingServiceMap.put(oppId,0);
                        if(opli.Existing_Service__c)
                        {
                            countExistingServiceMap.put(oppId,1);
                        }
                    } 
                    else
                    {
                        if(opli.Existing_Service__c)
                        {
                           countExistingServiceMap.put(oppId,countExistingServiceMap.get(oppId) + 1);
                        }       
                    }
                }    
                //system.debug('ARC debug endofloop for :' +opli.pricebookentryid);
                //system.debug('ARC debug countmap' +countExistingServiceMap);
            }
            //system.debug('ARC debug countexistingservicemap' +countExistingServiceMap);
            //Include Count of Existing Service from database
            AggregateResult[] groupedResults = [SELECT OpportunityId, Count(Id) total FROM OpportunityLineItem WHERE OpportunityId = :oppExCustExSvcMap.keySet() AND Existing_Service__c = true  GROUP BY OpportunityId ];
            system.debug('ARC debug groupedresults:'+groupedresults);
            for (AggregateResult ar : groupedResults){
                Id oppId = (Id)ar.get('OpportunityId');
                Integer totalRec = (Integer)ar.get('total');
                if(countExistingServiceMap.containsKey(oppId)){
                    countExistingServiceMap.put(oppId,countExistingServiceMap.get(oppId) + totalRec);
                }
                else{
                    countExistingServiceMap.put(oppId,totalRec);
                }
            }
            
            for(OpportunityLineItem opli : opliList){
                Id oppId = opli.OpportunityId;
                if(oppExCustExSvcMap.containsKey(oppId) && countExistingServiceMap.containsKey(oppId) && countExistingServiceMap.get(oppId) == 0){
                    //opli.addError('When the Opportunity Type is Existing Cust- Existing Svc, at least one product must be added with the Existing Service checkbox checked.');
                }
            }
        }
    }
    */
    /**
    Process builder --> Version 2: PGi-Update Standard Product Price
     */
    private void updateOpportunityLineItemField(){
        Set<Id> oppIds = new Set<Id>();
        for(OpportunityLineItem opli : (List<OpportunityLineItem>)Trigger.new){
            oppIds.add(opli.OpportunityId);         
        }
        Map<Id, Opportunity> oppExCustExSvcMap = new Map<Id, Opportunity>([SELECT Id, Type 
                                                                            FROM Opportunity 
                                                                            WHERE recordtype.name like '%PGi%' and Id =: oppIds ]);
        
        for(OpportunityLineItem opli : (List<OpportunityLineItem>)Trigger.new){
            if(oppExCustExSvcMap.containsKey(opli.OpportunityId)){
                opli.UnitPrice = opli.Value_Over_Term__c;
            }
        }        
    }
   
    
    // NJ: RT-301 
    // 
     public void  updateOpprtunity(List<opportunityLineItem> oliList) {
        Set<Id> setOfIds =  new Set<Id>();
       for(OpportunityLineItem proObj : oliList){
            setOfIds.add(proObj.OpportunityId);
        }
        List<OpportunityLineItem> lstOfProducts = [SELECT ID, Name, MRR__c, NRR__c, Value_Over_Term__c, Annual_Value__c, Product_Family__c,OpportunityId, Product_Name1__c FROM OpportunityLineItem WHERE OpportunityId in: setOfIds];
         
        Map<Id, List<OpportunityLineItem>> produstListByOppId = new Map<Id, List<OpportunityLineItem>>();
        for(OpportunityLineItem product : lstOfProducts)
        {
           if(!produstListByOppId.containsKey(product.OpportunityId)){
               produstListByOppId.put(product.OpportunityId, new List<OpportunityLineItem>());
              
           }
            produstListByOppId.get(product.OpportunityId).add(product);
        }

       
        List<Opportunity> oppList = new List<Opportunity>();
        for(ID oppId : produstListByOppId.keySet()){
            
            Opportunity objOpp = new Opportunity(Id = oppId, highest_MRR_Product_Value__c = 0,
                                                Highest_NRR_Product_Value__c = 0,
                                                Product_MRR_Total_Collab__c = 0,
                                                Product_MRR_Total_UC__c = 0,
                                                Product_MRR_Total_Webcast__c = 0,
                                                Product_MRR_Total_Webinar__c = 0,  //RT-397 Anup start
                                                Product_NRR_Total_Collab__c = 0,
                                                Product_NRR_Total_UC__c = 0, 
                                                Product_NRR_Total_Webcast__c = 0,
                                                Product_NRR_Total_Webinar__c = 0,
                                                Product_ACV_Total_Collab__c = 0, 
                                                Product_ACV_Total_UC__c = 0,
                                                Product_ACV_Total_Webcast__c = 0,
                                                Product_ACV_Total_Webinar__c = 0,
                                                Product_TCV_Total_Collab__c = 0,
                                                Product_TCV_Total_UC__c = 0,
                                                Product_TCV_Total_Webcast__c = 0,
                                                Product_TCV_Total_Webinar__c = 0,
                                                Product_MRR_Total_Legacy_UC__c = 0
                                                );  //RT-397 end
            for(OpportunityLineItem obj : produstListByOppId.get(oppId)){
                Decimal mrrValue = obj.MRR__c != null ? obj.MRR__c : 0;
                Decimal nrrValue = obj.NRR__c != null ? obj.NRR__c : 0;
                Decimal tcvValue = obj.Value_Over_Term__c != null ? obj.Value_Over_Term__c : 0;
                Decimal acvValue = obj.Annual_Value__c != null ? obj.Annual_Value__c : 0;
                if(obj.Product_Family__c == 'Collaboration') {
                	objOpp.Product_MRR_Total_Collab__c += mrrValue;
                	objOpp.Product_NRR_Total_Collab__c += nrrValue;
                	objOpp.Product_ACV_Total_Collab__c += acvValue;
                    objOpp.Product_TCV_Total_Collab__c += tcvValue; // Value_Over_Term__c
                }
                else if(String.isNotBlank(obj.Product_Family__c) && (obj.Product_Family__c.contains('Unified Communications') || obj.Product_Family__c.contains('UCaaS'))) {
                    objOpp.Product_MRR_Total_UC__c += mrrValue;                  
                    objOpp.Product_NRR_Total_UC__c += nrrValue;
                    objOpp.Product_ACV_Total_UC__c += acvValue;
                    objOpp.Product_TCV_Total_UC__c += tcvValue;
                }
                else if(obj.Product_Family__c == 'Webcast') {
                    objOpp.Product_MRR_Total_Webcast__c += mrrValue;
                    objOpp.Product_NRR_Total_Webcast__c += nrrValue;
                	objOpp.Product_ACV_Total_Webcast__c += acvValue;
                    objOpp.Product_TCV_Total_Webcast__c += tcvValue; // Value_Over_Term__c
                }
                else if(obj.Product_Family__c == 'Webinar') {
	                objOpp.Product_MRR_Total_Webinar__c += mrrValue; 
                	objOpp.Product_NRR_Total_Webinar__c += nrrValue;
                	objOpp.Product_ACV_Total_Webinar__c += acvValue;
                    objOpp.Product_TCV_Total_Webinar__c += tcvValue; // Value_Over_Term__c
                }
                
                if(mrrValue > objOpp.highest_MRR_Product_Value__c){
                    objOpp.highest_MRR_Product_Value__c = mrrValue;
                    objOpp.highest_MRR_Product_Name__c = obj.Product_Name1__c;
                }
                
                if(nrrValue > objOpp.Highest_NRR_Product_Value__c){
                    objOpp.Highest_NRR_Product_Value__c = nrrValue;
                    objOpp.Highest_NRR_Product_Name__c = obj.Product_Name1__c;
                }
                if(obj.Product_Family__c == 'Unified Communications') {
                    objOpp.Product_MRR_Total_Legacy_UC__c += mrrValue;                  
                }
                
            }
            oppList.add(objOpp);
        }
        
        if(oppList.size()>0){
            Set<ID> checkDuplicate = new Set<ID>();
            List<Opportunity> finalList = new List<Opportunity>();
            for(Opportunity c : oppList){
                if(checkDuplicate.add(c.Id)){
                    finalList.add(c);
                } 
            }
            UPDATE finalList;
        }
    }
}