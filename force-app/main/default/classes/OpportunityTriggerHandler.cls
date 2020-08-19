public without sharing class OpportunityTriggerHandler extends TriggerHandler {
    public OpportunityTriggerHandler() {
        super('OpportunityTriggerHandler');
    }
    public static Boolean bypassContactRole = false;
    public class OpportunityTriggerHandlerException extends Exception {}
    public static final String PGI_RT = 'PGi Opportunity';
    public static final String PGI_RENEWAL_RT = 'PGi Renewal Opportunity';
    public static final String PGI_CLOSEDWON_VALIDATION_MSG = 'In order to Close this deal as Won, you must ensure a PGi Contract exists with a Start Date, Renewal Date, and that the agreement has been attached to the Opportunity record itself. Please complete those steps then return to Close this deal.';
    protected override void beforeUpdate() {
        //autoClose();
        //RT-472 Vijay New fields on opp( Sales Audit Approved Date,Approval Comment) to update
        SetApprovalDateComment();
        setProductFamilies();
        convertingAllProcessBuilderAllEvent();        
        summarizeFamilyValues();
        setLastSurveyDate(); 
         validatePGiClosedWon();
         copyOppContactRoleData();
        setConvertedMQAField();
        setConvertedfromGlobalContactMql();
       
        // updateOpportunityToclosedPendingAproval(); //RT-386 Anup
        // validateOpportunityClosedWonForPGiContract(); //RT-388 Anup
        
    }
    protected override void beforeInsert() {
        convertingAllProcessBuilder();
        convertingAllProcessBuilderAllEvent();

        assignPB();
        // setConvertedMQAField();
    }
    protected override void afterInsert() {
        // checkProductfamilyvalue();
        checkForMaxOneRenewalOpp();
           
        fireEventHandler();
        
        // system.debug('Debug checking--------------------->'+!System.isFuture()+'====BATCH='+ !System.isBatch());
        if(!System.isFuture() && !System.isBatch()) {
            checkOpportunitesWithMatchedTeamEngineRules(Trigger.newMap.keySet());
        }
    }
    protected override void afterUpdate() {
        
        // checkProductfamilyvalue();
        checkForReopen();
        fireEventHandler();
        // check for renewal opp
        checkForPGIRenewalOpp();
          
        checkForMaxOneRenewalOpp();
        if(!System.isFuture() && !System.isBatch()) {
            checkOpportunitesWithMatchedTeamEngineRules(Trigger.newMap.keySet()); 
        }
    }  
    
    private void setProductFamilies() {
        // Comment By Anup: this method is called in beforeUpdate event but some process builder is depending Opportunity_Product_Families__c field which are firing on insert nd update event.So need update process builder code which is in convertingAllProcessBuilder(); //* PGi-Base Conversion 
        Map<Id, Opportunity> oppsWithRelated = oppSelector.getOppsWithRelated(Trigger.newMap.keySet());
        for(Opportunity o: oppsWithRelated.values()) {
            Set<String> oppProdFamilies = new Set<String>();
            String collectionString = '';
            for(OpportunityLineItem oli: o.OpportunityLineItems) {
                oppProdFamilies.add(oli.Product_Family__c);
            }
            List<String> oppProdFamilieslist = new List<String>(oppProdFamilies);
            oppProdFamilieslist.sort();
            for (String s: oppProdFamilieslist) {
                collectionString += (collectionString == '' ? '' : ',' ) + s;
            }
            Opportunity oppty = (Opportunity)Trigger.newMap.get(o.Id);
            oppty.Opportunity_Product_Families__c = collectionString;
        }
        
        
    }
    private Map<Id, Account> relatedAccounts {get {
        if(relatedAccounts == null) {
            Set<Id> accountIds = new Set<Id>();
            for(Opportunity opp: (List<Opportunity>)Trigger.new) {
                accountIds.add(opp.AccountId);
            }
            System.debug('The list'+accountIds.size());
            relatedAccounts = new Map<Id, Account>([SELECT Id,  OwnerId, BaseConversion__c, 
                                                    (SELECT Id FROM Opportunities WHERE RecordType.Name =: PGI_RENEWAL_RT AND IsClosed = false AND Opportunity_Product_Families__c LIKE '%Unified Communications%') 
                                                    FROM Account WHERE Id IN: accountIds]);
        }
        System.debug('The Map'+relatedAccounts);
        return relatedAccounts;
    } set;}

    private void checkForMaxOneRenewalOpp() {
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Account> accountMap = relatedAccounts;
        for(Opportunity o: (List<Opportunity>)Trigger.new) {
            System.debug('AccEl'+accountMap.get(o.AccountId));
            System.debug('AccEl'+accountMap.get(o.AccountId).Opportunities.size());
            if(accountMap.get(o.AccountId) != null && accountMap.get(o.AccountId).Opportunities != null && accountMap.get(o.AccountId).Opportunities.size() > 1) {
                o.addError('You are only allow to have one open renewal opportunity with Unified Communications at a time.');
            }
        }
    }
    // //RT-509 Created by Vijay.
    // private void checkProductfamilyvalue(){
    //     for(Opportunity opp: (List<Opportunity>)Trigger.new) {
    //         String productfamilyvalue = opp.Opportunity_Product_Families__c;
    
    //         System.debug('>>>> productfamilyvalue >>>>'+productfamilyvalue);
    //             if(String.isNotBlank(productfamilyvalue) && productfamilyvalue.contains('TPx') && opp.StageName == 'Closed Pending Approval'){
    //             // if(productfamilyvalue.contains('TPx')){
    //                 System.debug('>>>> opp.Opportunity_Product_Families__c >>>> ');
    //                 System.debug('>>> if >>>');
    //                 Attachment attach=new Attachment();   	
    //                 attach.Name='Unit Test Attachment';
    //                 Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    //                 attach.body=bodyBlob;
    //                 attach.parentId=opp.id;
    //                 insert attach;
    //                 System.debug('>> attach >>'+attach);
    //             }else{
    //                 System.debug('>>> else >>>');
    //             }
    //     }
    // }
    //populate the persona from the ACR
    
    //1663 - auto close set by time based workflow rule - Removed per COD-1825
    //private void autoClose(){ 
    //    for(Opportunity o: (List<Opportunity>)Trigger.new) {
    //        if(o.Auto_Close__c && !o.isClosed) {
    //            if(o.Opportunity_Deal_Type__c == 'Renewal (No Rev Change)') {
    //                o.StageName = 'Closed Won - Renewal';
    //            } else {
    //                o.StageName = 'Closed Won';
    //            }
    //        }
    //    }
    //}
    @TestVisible
    private Boolean isAmendment(Opportunity opp) {
        return opp.Opportunity_Deal_Type__c != 'New Business' && opp.Opportunity_Deal_Type__c != 'Renewal (No Rev Change)';
    }
    private Boolean isRenewal(Opportunity opp) {
        return opp.RecordType != null && opp.RecordType.Name == PGI_RENEWAL_RT;
    }
    private Boolean justNowClosedWon(Opportunity opp) {
        return isChanged('IsClosed', opp) && opp.isClosed && opp.isWon;
    }
    //private Map<Id, List<Opportunity>> openPGIRenewalOppsByAccountId {
    //    get{ 
    //        return oppSelector.getOpenPGIRenewalOppsByAccountId(Trigger.new);
    //    }
    //}
    public static Set<Id> renewalSyncProcessedOpps = new Set<Id>();
    private void checkForPGIRenewalOpp() {
        Map<Id, List<Opportunity>> openUCRenewalOppsByAccountId = oppSelector.getOpenPGIRenewalOppsByAccountId((List<Opportunity>)Trigger.new);
        Map<Id,Opportunity> renewalOppMap = new Map<Id,Opportunity>();
        List<Opportunity> closedAmendmentsToSync = new List<Opportunity>();
        // 1662 / 1663
        for(Opportunity opp : filterPGiOpps((List<Opportunity>)Trigger.new)) {
            if(renewalSyncProcessedOpps.contains(opp.Id)) {
                continue;
            }
            if(justNowClosedWon(opp) && (opp.Opportunity_Deal_Type__c == 'New Business' || opp.Opportunity_Deal_Type__c == 'Renewal (No Rev Change)')) {
                Opportunity oppWithRelated = oppsWithRelated.get(opp.Id);
                System.debug('>> oppWithRelated >>'+oppWithRelated);
                System.debug('opp.Opportunity_Product_Families__c'+opp.Opportunity_Product_Families__c);
                System.debug('openUCRenewalOppsByAccountId.get(opp.AccountId).size()'+openUCRenewalOppsByAccountId.get(opp.AccountId).size());
                if(String.isNotBlank(opp.Opportunity_Product_Families__c) && opp.Opportunity_Product_Families__c.contains('Unified Communications') && openUCRenewalOppsByAccountId.get(opp.AccountId) != null && openUCRenewalOppsByAccountId.get(opp.AccountId).size() > 0) {
                    closedAmendmentsToSync.add(opp);
                } else {
                    Set<OpportunityLineItem> linesToCopy = getPGIProductsToClone(oppWithRelated);
                    if(linesToCopy.size() > 0) {
                        renewalOppMap.put(opp.Id, opp);
                    }
                }
                
            } else if (isChanged('IsClosed', opp) && String.isNotBlank(opp.Opportunity_Product_Families__c) && opp.Opportunity_Product_Families__c.contains('Unified Communications') && openUCRenewalOppsByAccountId.get(opp.AccountId) != null && openUCRenewalOppsByAccountId.get(opp.AccountId).size() > 0) {
                closedAmendmentsToSync.add(opp); // this will enter only when opprtunity is stage changed from closed to  other value. 
            }
            //} else if (isChanged('IsClosed', opp)) {
            //    if(isAmendment(opp) && String.isNotBlank(opp.Opportunity_Product_Families__c) && opp.Opportunity_Product_Families__c.contains('Unified Communications')) {
            //        closedAmendmentsToSync.add(opp);
            //    }
            //}
        }
        renewalSyncProcessedOpps.addAll(renewalOppMap.keySet());
        createPGIRenewalOpps(renewalOppMap);
        renewalSyncProcessedOpps.addAll(new Map<Id, Opportunity>(closedAmendmentsToSync).keySet());
        syncAmendments(closedAmendmentsToSync);
    }
    //1664 automation trigger for amendments, so that when an Account already has an OPEN PGi Renewal Opportunity, 
    private void syncAmendments(List<Opportunity> amendmentsToSync) {
        System.debug('>> amendmentsToSync >>'+amendmentsToSync);
        Map<Id, List<Opportunity_Line_Amendment__c>> oppLineAmendmentsByOppId = oppSelector.getOppLineAmendmentsByOppId(amendmentsToSync);
        Map<Id, List<Opportunity>> openUCRenewalOppsByAccountId = oppSelector.getOpenPGIRenewalOppsByAccountId(amendmentsToSync);
        for(Opportunity amendmentOpp: amendmentsToSync) {
            
            //revalidate they are amendments and are in current trigger
            if(!Trigger.newMap.keySet().contains(amendmentOpp.Id)) {
                //    System.debug('isAmendment:'+isAmendment(amendmentOpp) + ' -- Contained in Trigger New Map: ' + Trigger.newMap.keySet().contains(amendmentOpp.Id));
                continue;
            }
            
            Opportunity amendmentOppWithRelated = oppsWithRelated.get(amendmentOpp.Id);
            List<Opportunity> openRenewalsForAccount = openUCRenewalOppsByAccountId.get(amendmentOpp.AccountId);
            Opportunity openRenewalOpp;
            if(openRenewalsForAccount.size() > 1) {
                //System.debug('More than 1 open renewal...');
                //LoggerUtil.log('more than one renewal deal exists for this account')
                throw new OpportunityTriggerHandlerException('More than one open renewal Unified Communication deal exists for this account. Please close one prior to saving this opportunity.');
            } else if(openRenewalsForAccount.size() == 1) {
                openRenewalOpp = openRenewalsForAccount[0];
                syncAmendment(amendmentOppWithRelated, openRenewalOpp, oppLineAmendmentsByOppId);
            } else {
                //no open renewal
                //if Deal Type is Conversion and Renewal does not already exist, then create renewal
                if(amendmentOppWithRelated.Opportunity_Deal_Type__c == 'Conversion') {
                    //TODO - create Renewal
                } else if(amendmentOppWithRelated.Opportunity_Deal_Type__c == 'Up-Sell (Rev Increase)' || amendmentOppWithRelated.Opportunity_Deal_Type__c == 'Down-Sell (Rev Decrease)') {
                    //TODO 
                    //if it was possible that if Deal Type is Upsell or Downsell, 
                    //and no Renewal already exist - could one be created by taking the current upsell/downsell + the historical oppty with deal type of "New Business" 
                    //from the same Account and combining the two to create a proper Renewal deal
                }
            }
        }
        try {
            upsert syncLineItemsToUpsert;
            syncLineItemsToUpsert = new List<OpportunityLineItem>();
            upsert syncAmendmentsToUpsert; 
            syncAmendmentsToUpsert = new List<Opportunity_Line_Amendment__c>();
            delete syncAmendmentsToDelete;
            syncAmendmentsToDelete = new List<Opportunity_Line_Amendment__c>();
            insert oppTeamToInsert;
            oppTeamToInsert = new List<OpportunityTeamMember>();
            insert contactRolesToInsert;
            contactRolesToInsert = new List<OpportunityContactRole>();  
        } catch (exception e) {
            throw new OpportunityTriggerHandlerException('Failed to update due failed syncing of auto renewals. ' + e.getMessage());
        }
        
    }
    
    private List<OpportunityLineItem> syncLineItemsToUpsert = new List<OpportunityLineItem>();
    private List<Opportunity_Line_Amendment__c> syncAmendmentsToUpsert = new List<Opportunity_Line_Amendment__c>();
    private List<OpportunityTeamMember> oppTeamToInsert = new List<OpportunityTeamMember>();
    private List<Opportunity_Line_Amendment__c> syncAmendmentsToDelete = new List<Opportunity_Line_Amendment__c>();
    private List<OpportunityContactRole> contactRolesToInsert = new List<OpportunityContactRole>();
    private void syncAmendment(Opportunity amendmentOppWithRelated, Opportunity renewalOpp, Map<Id, List<Opportunity_Line_Amendment__c>> oppLineAmendmentsByOppId) {
        oppTeamToInsert.addAll(syncOppTeam(amendmentOppWithRelated, renewalOpp));
        //contactRolesToInsert.addAll(syncContactRoles(amendmentOppWithRelated, renewalOpp));
        syncLineItems(amendmentOppWithRelated, renewalOpp, oppLineAmendmentsByOppId);
    }
    @TestVisible
    private List<OpportunityTeamMember> syncOppTeam(Opportunity amendmentOppWithRelated, Opportunity renewalOpp){
        List<OpportunityTeamMember> returnList = new List<OpportunityTeamMember>();
        Set<String> existingKeys = new Set<String>();
        if(renewalOpp.OpportunityTeamMembers != null) {
            for(OpportunityTeamMember sobj: renewalOpp.OpportunityTeamMembers) {
                existingKeys.add('' + sObj.OpportunityAccessLevel + sObj.TeamMemberRole + sObj.UserId);
            }
        }
        
        if(amendmentOppWithRelated.OpportunityTeamMembers != null) {
            for(OpportunityTeamMember sObj: amendmentOppWithRelated.OpportunityTeamMembers) {
                if(!existingKeys.contains('' + sObj.OpportunityAccessLevel + sObj.TeamMemberRole + sObj.UserId)){
                    OpportunityTeamMember newOppTeamMember = new OpportunityTeamMember(
                        OpportunityId = renewalOpp.Id,
                        OpportunityAccessLevel = sObj.OpportunityAccessLevel,
                        TeamMemberRole = sObj.TeamMemberRole,
                        UserId = sObj.UserId
                    );
                    returnList.add(newOppTeamMember);
                }
            }   
        }
        return returnList;
    }
    //private List<OpportunityContactRole> syncContactRoles(Opportunity amendmentOppWithRelated, Opportunity renewalOpp){
    //    List<OpportunityContactRole> returnList = new List<OpportunityContactRole>();
    //    Set<String> existingKeys = new Set<String>();
    //    if(renewalOpp.OpportunityContactRoles != null) {
    //        for(OpportunityContactRole sobj: renewalOpp.OpportunityContactRoles) {
    //            existingKeys.add('' + sobj.ContactId + sobj.IsPrimary + sobj.Role);
    //        }
    //    }
    
    //    if(amendmentOppWithRelated.OpportunityContactRoles != null) {
    //        for(OpportunityContactRole sObj: amendmentOppWithRelated.OpportunityContactRoles) {
    //            if(!existingKeys.contains('' + sobj.ContactId + sobj.IsPrimary + sobj.Role)) {
    //                OpportunityContactRole newOcr = new OpportunityContactRole(
    //                    OpportunityId = renewalOpp.Id,
    //                    ContactId = sobj.ContactId,
    //                    IsPrimary = sobj.IsPrimary,
    //                    Role = sobj.Role
    //                    );
    //                returnList.add(newOcr);
    //            }
    //        }   
    //    }
    //    return returnList;
    //}
    private OpportunityLineItem cloneLine(OpportunityLineItem oli, Opportunity sourceParent) {
        return cloneLine(oli, sourceParent, false);
    }
    private OpportunityLineItem cloneLine(OpportunityLineItem oli, Opportunity sourceParent, boolean isAmendment) {
        OpportunityLineItem clone = oli.clone(false, false, false, false);
        Map<String, Object> oppLineMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(clone));
        //allow upsert to work
        if(clonedOppLinesById.keySet().contains(oli.Id)) {
            oppLineMap.remove('Product2Id');
            oppLineMap.remove('PricebookEntryId');
        }
        oppLineMap.remove('TotalPrice');
        oppLineMap.remove('OpportunityId');
        clone = (OpportunityLineItem) JSON.deserialize(JSON.serialize(oppLineMap), OpportunityLineItem.class);
        //clone.OpportunityId = null;
        if(isAmendment) {
            clone.OpportunityId = sourceParent.Id;
        } else {
            clone.Opportunity = new Opportunity(External_Opportunity_ID__c = sourceParent.Id);  
        }
        
        clone.Cloned_From_Opportunity_Product_Id__c = oli.Id;
        return clone;
    }
    private void syncLineItems(Opportunity amendmentOppWithRelated, Opportunity renewalOpp, Map<Id, List<Opportunity_Line_Amendment__c>> oppLineAmendmentsByOppId){
        List<OpportunityLineItem> returnList = new List<OpportunityLineItem>();
        Map<Id, OpportunityLineItem> renewalLines = new Map<Id, OpportunityLineItem>(renewalOpp.OpportunityLineItems);
        Map<Id, OpportunityLineItem> amendmentLines = new Map<Id, OpportunityLineItem>(amendmentOppWithRelated.OpportunityLineItems);
        
        Set<String> existingKeys = new Set<String>(); 
        if(renewalOpp.OpportunityLineItems != null) {
            for(OpportunityLineItem sobj: renewalOpp.OpportunityLineItems) {
                existingKeys.add(sobj.Product2Id);
            }
        }
        
        List<Opportunity_Line_Amendment__c> oppLineAmendments = oppLineAmendmentsByOppId.get(renewalOpp.Id);
        Map<Id, Opportunity_Line_Amendment__c> oppLineAmendmentsByAmendmentLineId = new Map<Id, Opportunity_Line_Amendment__c>();
        if(oppLineAmendments != null && oppLineAmendments.size() > 0) {
            for(Opportunity_Line_Amendment__c ola: oppLineAmendments) {
                oppLineAmendmentsByAmendmentLineId.put(ola.Amendment_Line_Id__c, ola);
            }
        }
        
        if(amendmentOppWithRelated.OpportunityLineItems != null) {
            for(OpportunityLineItem amendedLine: getPGIProductsToClone(amendmentOppWithRelated)) {
                Opportunity_Line_Amendment__c ola = new Opportunity_Line_Amendment__c();
                OpportunityLineItem renewalLine;
                
                if(existingKeys.contains(amendedLine.Product2Id)) { //original opp contains product
                    //check to see if amended already 
                    if(oppLineAmendmentsByAmendmentLineId.get(amendedLine.Id) != null) { //line has previously been amended
                        ola = oppLineAmendmentsByAmendmentLineId.get(amendedLine.Id);
                        if(renewalLines.keySet().contains(ola.Renewal_Line_Id__c)) { //get previous amended line
                            renewalLine = renewalLines.get(ola.Renewal_Line_Id__c);
                        } else { //previously amended renewal line no longer exists
                            syncAmendmentsToDelete.add(ola); 
                            renewalLine = getMatchOnProduct(renewalLines.values(), amendedLine.Product2Id);
                        }
                    } else {
                        //product exists on renewal - update it
                        renewalLine = getMatchOnProduct(renewalLines.values(), amendedLine.Product2Id);
                    }
                }
                
                if(renewalLine != null) { //net new product being added
                    if(amendedLine.New_Quantity__c == null) {
                        amendedLine.New_Quantity__c = 0;
                    }
                    if(renewalLine.New_Quantity__c == null) {
                        renewalLine.New_Quantity__c = 0;
                    }
                    Decimal previousQuantity = ola.Previous_Quantity__c != null ? ola.Previous_Quantity__c : 0;
                    Decimal deltaQuantity = amendedLine.New_Quantity__c - previousQuantity;
                    if(amendmentOppWithRelated.isClosed == false) {
                        deltaQuantity *= -1;    
                    }
                    renewalLine.New_Quantity__c += deltaQuantity;
                } else {
                    renewalLine = cloneLine(amendedLine, renewalOpp, true);
                }
                ola.Amendment_Line_Id__c = amendedLine.Id;
                ola.Amendment_Opportunity__c = amendedLine.OpportunityId;
                ola.Renewal_Line_Id__c = renewalLine.Id;
                ola.Renewal_Opportunity__c = renewalLine.OpportunityId;
                ola.Previous_Quantity__c = renewalLine.New_Quantity__c;
                if(!renewalLinesAdjusted.contains(renewalLine.Id)) {
                    syncLineItemsToUpsert.add(renewalLine);
                    if(amendmentOppWithRelated.isClosed == false && ola.Id != null) {
                        syncAmendmentsToDelete.add(ola);
                    } else if(ola != null) {
                        syncAmendmentsToUpsert.add(ola);        
                    }
                    if(renewalLine != null) {
                        renewalLinesAdjusted.add(renewalLine.Id);
                    }
                }
            }
        }
    }
    @TestVisible
    private static Set<Id> renewalLinesAdjusted = new Set<Id>();
    @TestVisible
    private OpportunityLineItem getMatchOnProduct(List<OpportunityLineItem> findMatch, Id productId) {
        for(OpportunityLineItem oli: findMatch) {
            if(oli.Product2Id == productId) {
                return oli;
            }
        }
        return null;
    }
    private Set<OpportunityLineItem> getPGIProductsToClone(Opportunity oppWithProducts) {
        Boolean isRenewal = isRenewal(oppWithProducts);
        Set<OpportunityLineItem> returnList = new Set<OpportunityLineItem>();
        if(oppWithProducts.OpportunityLineItems == null || oppWithProducts.OpportunityLineItems.size() == 0) {
            return returnList;
        }
        for(OpportunityLineItem oli: oppWithProducts.OpportunityLineItems) {
            if((!isRenewal && oli.Product2.Clone_for_PGi_Renewal__c) 
               || (isRenewal && oli.Product2.Clone_for_PGi_Renewals_Renewal__c)) {
                   returnList.add(oli);
               }
        }
        return returnList;
    }
    
    //check to see if it has third party support
    private List<OpportunityLineItem> clonePGIOppLines(Opportunity clonedOpp) {
        Boolean returnValue = false;
        Opportunity opp = oppsWithRelated.get(clonedOpp.External_Opportunity_ID__c);
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        if(opp != null && opp.OpportunityLineItems != null) {
            Set<OpportunityLineItem> productsToClone = getPGIProductsToClone(opp); 
            for(OpportunityLineItem oli: productsToClone) {
                OpportunityLineItem clone = cloneLine(oli, opp);
                //oli.clone(false, false, false, false);
                //Map<String, Object> oppLineMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(clone));
                ////allow upsert to work
                //if(clonedOppLinesById.keySet().contains(oli.Id)) {
                //  oppLineMap.remove('Product2Id');
                //  oppLineMap.remove('PricebookEntryId');
                //}
                //oppLineMap.remove('OpportunityId');
                //clone = (OpportunityLineItem) JSON.deserialize(JSON.serialize(oppLineMap), OpportunityLineItem.class);
                ////clone.OpportunityId = null;
                //clone.Opportunity = new Opportunity(External_Opportunity_ID__c = clonedOpp.Id);
                //clone.Cloned_From_Opportunity_Product_Id__c = oli.Id;
                oliList.add(clone);
            }
        }
        return new List<OpportunityLineItem>(oliList);
    }
    private static User pgiRenewalOwner {get {
        if(pgiRenewalOwner == null) {
            List<User> userList = [SELECT ID FROM User WHERE PGI_Renewal_Owner__c =: true AND IsActive = true];
            if(!userList.isEmpty()) {
                return pgiRenewalOwner = userList[0];
            } else {
                pgiRenewalOwner = new User();
            }
        }
        return pgiRenewalOwner;
    } set;}
    private void createPGIRenewalOpps(Map<Id, Opportunity> renewalOppMap) {
        if(renewalOppMap == null || renewalOppMap.size() == 0) {
            return;
        }
        List<Opportunity> insertRenewalOpps = new List<Opportunity>();
        // 1662
        // Opp Settings
        for(Opportunity opp : renewalOppMap.values()) {
            Opportunity opportunityWithRelated = oppsWithRelated.get(opp.Id);
            if(opportunityWithRelated == null) { continue; }
            
            
            //Carry over Renewal_Contract_Term_Type__c
            CONMAN_Contract__c relatedContract = opportunityWithRelated.CONMAN_Contracts__r != null && opportunityWithRelated.CONMAN_Contracts__r.size() > 0 ? opportunityWithRelated.CONMAN_Contracts__r[0] : null;
            Opportunity oldOpp = (Opportunity)Trigger.oldMap.get(opp.Id);
            String stage;
            if(oldOpp.RecordTypeId == PGI_Utility.getRecordTypes('Opportunity').get(PGI_RENEWAL_RT)) {
                stage = oldOpp.StageName;   
            } else {
                stage = 'C Mutual Plan';
            }
            
            Opportunity renewalToGenerate = new Opportunity(OwnerId = opp.OwnerId, 
                                                            Name = opp.Name,
                                                            AccountId = opp.AccountId, 
                                                            StageName = stage,
                                                            Renewal_Type__c = 'Renewal',
                                                            Renewal_Contract_Term_Type__c = opp.Renewal_Contract_Term_Type__c,
                                                            External_Opportunity_ID__c = opp.Id,
                                                            Opportunity_Deal_Type__c = 'Renewal (No Rev Change)',
                                                            RecordTypeId = PGI_Utility.getRecordTypes('Opportunity').get(PGI_RENEWAL_RT),
                                                            CurrencyIsoCode = opp.CurrencyIsoCode,
                                                            Use_Case_Description__c = opp.Use_Case_Description__c,
                                                            NextStep = opp.NextStep,
                                                            Red_Flags__c = opp.Red_Flags__c,
                                                            Strategy__c = opp.Strategy__c
                                                           );
            if(pgiRenewalOwner != null && pgiRenewalOwner.Id != null) {
                renewalToGenerate.ownerId = pgiRenewalOwner.Id;
            }
            if(!renewalToGenerate.Name.startsWith('Renewal - ')){
                String nameStr = 'Renewal - ' + opp.Name;
                if(nameStr.length() > 80) {
                    nameStr = nameStr.left(80);
                }
                renewalToGenerate.name = nameStr;
            }
            if(relatedContract != null) {
                renewalToGenerate.CloseDate = relatedContract.Contract_Renewal_Date__c;
                renewalToGenerate.Renewal_Contract_Date__c = relatedContract.Contract_Renewal_Date__c;
                renewalToGenerate.Auto_Renew__c = relatedContract.Auto_Renewal__c == true ? 'Yes' : 'No';
            } else if (opp.Auto_Close__c) { //1663
                renewalToGenerate.CloseDate = opp.CloseDate.addYears(1);
                renewalToGenerate.Renewal_Contract_Date__c = opp.Renewal_Contract_Date__c.addYears(1);
                renewalToGenerate.Auto_Renew__c = opp.Auto_Renew__c;
            }
            if(renewalToGenerate.CloseDate == null) {
                renewalToGenerate.CloseDate = opp.CloseDate.addYears(1);
            }
            
            insertRenewalOpps.add(renewalToGenerate);
        }
        
        /*
Contact Role settings = clone from origin
Opportunity Team = clone from origin
*/
        if(!insertRenewalOpps.isEmpty()) {
            //System.assertEquals(1, insertRenewalOpps.size(), insertRenewalOpps);
            upsert insertRenewalOpps External_Opportunity_ID__c;
            //TODO - handle save results
            List<OpportunityLineItem> oppLinesToInsert = new List<OpportunityLineItem>();
            List<OpportunityTeamMember> otmToInsert = new List<OpportunityTeamMember>();
            List<OpportunityContactRole> otcToInsert = new List<OpportunityContactRole>();
            for(Opportunity clonedOpp: insertRenewalOpps) {
                if(clonedOpp.Id != null) {
                    oppLinesToInsert.addAll(clonePGIOppLines(clonedOpp));
                    otmToInsert.addAll(cloneOppTeamMembers(clonedOpp));
                    otcToInsert.addAll(cloneOppContactRole(clonedOpp));
                }
            }
            upsert oppLinesToInsert Cloned_From_Opportunity_Product_Id__c;
            renewalLinesAdjusted.addAll(new Map<Id, OpportunityLineItem>(oppLinesToInsert).keySet());
            Database.insert(otmToInsert, true);
            Database.insert(otcToInsert, true);
        }
    }
    private static Set<Id> otmProcessed = new Set<Id>();
    private List<OpportunityTeamMember> cloneOppTeamMembers(Opportunity clonedOpp) {
        List<OpportunityTeamMember> returnList = new List<OpportunityTeamMember>();
        System.debug('The Opportunity cloned is'+oppsWithRelated.get(clonedOpp.External_Opportunity_ID__c));
        System.debug('The Opportunity cloned is'+ oppsWithRelated.get(clonedOpp.External_Opportunity_ID__c).OpportunityTeamMembers);
        if(clonedOpp.Id == null || oppsWithRelated.get(clonedOpp.External_Opportunity_ID__c) == null || oppsWithRelated.get(clonedOpp.External_Opportunity_ID__c).OpportunityTeamMembers == null || oppsWithRelated.get(clonedOpp.External_Opportunity_ID__c).OpportunityTeamMembers.size() == 0) {
            return returnList;
        }
        
        for(OpportunityTeamMember sObj: oppsWithRelated.get(clonedOpp.External_Opportunity_ID__c).OpportunityTeamMembers) {
            if(otmProcessed.contains(sObj.Id)) {continue;}
            OpportunityTeamMember clone = new OpportunityTeamMember(
                OpportunityId = clonedOpp.Id,
                UserId = sObj.UserId,
                TeamMemberRole = sObj.TeamMemberRole,
                OpportunityAccessLevel = sObj.OpportunityAccessLevel
            );
            returnList.add(clone);
            otmProcessed.add(sObj.Id);
        }
        return returnList;
    }
    private static Set<Id> ocrProcessed = new Set<Id>();
    private List<OpportunityContactRole> cloneOppContactRole(Opportunity clonedOpp) {
        List<OpportunityContactRole> returnList = new List<OpportunityContactRole>();
        System.debug('The  opportunity cloned'+oppsWithRelated.get(clonedOpp.External_Opportunity_ID__c));
        System.debug('The  opportunity cloned'+oppsWithRelated.get(clonedOpp.External_Opportunity_ID__c).OpportunityContactRoles);
        if(clonedOpp.Id == null || oppsWithRelated.get(clonedOpp.External_Opportunity_ID__c) == null || oppsWithRelated.get(clonedOpp.External_Opportunity_ID__c).OpportunityContactRoles == null || oppsWithRelated.get(clonedOpp.External_Opportunity_ID__c).OpportunityContactRoles.size() == 0) {
            return returnList;
        }
        
        for(OpportunityContactRole sObj: oppsWithRelated.get(clonedOpp.External_Opportunity_ID__c).OpportunityContactRoles) {
            if(ocrProcessed.contains(sObj.Id)) {continue;}
            OpportunityContactRole clone = new OpportunityContactRole(
                OpportunityId = clonedOpp.Id,
                IsPrimary = sObj.IsPrimary,
                Role = sObj.Role,
                ContactId = sObj.ContactId
            );
            returnList.add(clone);
            ocrProcessed.add(sObj.Id);
        }
        return returnList;
    }
    // used in commented Class
    /*private void validateProductsAreActive(List<Opportunity> oppList) {
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(oppList);
        Map<Id, Opportunity> queriedOpps = oppSelector.getOppsWithRelated(oppMap.keySet());
        for(Opportunity opp: oppList) {
            Opportunity oppWithRelated = queriedOpps.get(opp.Id);
            for(OpportunityLineItem oli: oppWithRelated.OpportunityLineItems) {
                if(!oli.PricebookEntry.IsActive || !oli.Product2.IsActive) {
                    Opportunity triggerOpp = (Opportunity)Trigger.newMap.get(opp.Id); //add error
                    triggerOpp.addError('The product ' + oli.Product2.Name + ' is not active. Please select an active product.');
                }
            }
        }
    }*/
    private Boolean superUserProfile() {
        //Bypass 3 profiles apex validation: ""In order to Close this deal as Won, you must ensure a PGi Contract exists with a Start Date, Renewal Date, and that the agreement has been attached to the Opportunity record itself. Please complete those steps then return to Close this deal..""
        Profile profile = PGI_Utility.profile;
        return profile.Name == 'System Administrator' || profile.Name == 'System Admin API Only' || profile.Name == 'PGi Sales Operations';
    }
    private void validatePGiClosedWon() {
        Map<Id,Opportunity> oppIds = new Map<Id,Opportunity>();
        Set<Id> upsellDownSellIds = new Set<Id>();
        // loop through PGi Opps
        for(Opportunity opp : filterPGiOpps((List<Opportunity>)Trigger.new)) {
            System.debug('>> opp.stageName >>'+opp.StageName);
            if(!superUserProfile()) {
                System.debug('>> opp.stageName 1 >>'+opp.StageName);
                System.debug('>> IsChanged(StageName, opp) >>'+IsChanged('StageName', opp)+'>>>>'+opp);
                if(IsChanged('StageName', opp) && (opp.StageName == 'Closed Won' || opp.StageName == 'Closed Pending Approval')) {
                  System.debug('Entering');  
                    // closed won PGi Opps must meet the following criteria or an error will be displayed to the user
                    // formula text - Initial_Product_Family_Interest__c CONTAINS 'Web: GlobalMeet' or 'Conversion Project'
                    // picklist - Opportunity_Deal_Type__c = 'Conversion' or 'New Business'
                    // picklist - Channel__c = 'Cloud' or 'Major Accounts' or 'APAC' or 'JAPAN' or 'Tier One' ORRRRR
                    // Channel__c = 'Partners' AND Account_Type__c = 'End User – Agent' or 'Direct'
                     //02266649
                    if(opp.Opportunity_Product_Families__c.contains('TPx') || (opp.Opportunity_Deal_Type__c != null &&
                                                                               opp.Channel__c != null &&
                                                                               ((opp.Opportunity_Deal_Type__c == 'Conversion' ||
                                                                                 opp.Opportunity_Deal_Type__c == 'New Business' ||
                                                                                 opp.Opportunity_Deal_Type__c == 'Win Back') 
                                                                                &&
                                                                                ((opp.Channel__c == 'Cloud' ||
                                                                                  opp.Channel__c == 'Major Accounts' ||
                                                                                  opp.Channel__c == 'APAC' ||
                                                                                  opp.Channel__c == 'Japan' ||
                                                                                  opp.Channel__c == 'Tier One')
                                                                                 ||
                                                                                 (opp.Channel__c == 'Partners' && (opp.Account_Type__c == 'End User - Agent' || opp.Account_Type__c == 'Partner Direct')))))) {
                                                                                     
                                                                                     // first validation passed, add to map to query related pgi contracts
                                                                                     oppIds.put(opp.Id, opp);
                                                                                 } else if(opp.Product_TCV_Total_Growth_Products__c != null && opp.Product_TCV_Total_Growth_Products__c > 0 && opp.Opportunity_Deal_Type__c != null &&
                                                                                           opp.Opportunity_Deal_Type__c.contains('Sell (Rev')
                                                                                           ) {
                                                                                                oppIds.put(opp.Id, opp);
                                                                                                upsellDownSellIds.add(opp.Id);
                                                                                            }
                }
            }
        }
        
        // if opps passed first validation then query for a related PGi Contract
        // query for related PGi Contract (CONMAN_Contract__c)
        // Contract_Start_Date__c Contract_Renewal_Date__c Has_Attachment__c
        // Opportunity__c
        System.debug('The  oppSize'+oppIds.size());
        if(oppIds.size() > 0) {
            Set<Id> oppIdsWithRelatedPGiContract = new Set<Id>();
            Set<Id> contractsWithStartAndRenewalDates = new Set<Id>();
            //todo - if non tpx - make sure has contract + attachment

            for(CONMAN_Contract__c pgiContract : [SELECT Id, Contract_Start_Date__c, Contract_Renewal_Date__c, 
                                                        Has_Attachment__c, Opportunity__c
                                                    FROM CONMAN_Contract__c
                                                    WHERE Opportunity__c IN :oppIds.keySet()]) {
                if(pgiContract.Contract_Start_date__c != null && pgiContract.Contract_Renewal_Date__c != null) {
                    contractsWithStartAndRenewalDates.add(pgiContract.Opportunity__c);
                }
                oppIdsWithRelatedPGiContract.add(pgiContract.Opportunity__c);
            }            
            Set<Id> oppIdsWithAttachment = new Set<Id>();
            
            for(Attachment oppAttachment : [SELECT Id, ParentId
                                            FROM Attachment
                                            WHERE ParentId IN :oppIds.keySet()]) {
                                                oppIdsWithAttachment.add(oppAttachment.ParentId);
                                            }
            // }
            // loop through to validate Opportunity has a related PGi Contract with a Start Date, Renewal Date and an Attachment
            // if no valid PGi Contract, then display error message to the User
            for(Id oppId : oppIds.keySet()) {
                Opportunity opp = (Opportunity)Trigger.newMap.get(oppId);
                if(opp.Opportunity_Product_Families__c == 'Webcast' || opp.Opportunity_Product_Families__c == 'Webcast;') {
                    if(!oppIdsWithAttachment.contains(oppId)) {
                        Trigger.newMap.get(oppId).addError('Please ensure a contract has been attached to this opportunity.');
                    }
                } else if(String.isNotBlank(opp.Opportunity_Product_Families__c) && opp.Opportunity_Product_Families__c.contains('TPx')) {
                    if(!oppIdsWithAttachment.contains(oppId)) {
                        Trigger.newMap.get(oppId).addError('Please ensure a contract has been attached to this opportunity.');
                    }
                } else if(upsellDownSellIds.contains(oppId)) {
                    if(!oppIdsWithAttachment.contains(oppId)) {
                        Trigger.newMap.get(oppId).addError('You must attach a written confirmation from the customer reviewing their revenue cost changes or an email thread of the like before proceeding.');
                    }
                }  else if(!oppIdsWithAttachment.contains(oppId) || !contractsWithStartAndRenewalDates.contains(oppId)) {
                    Trigger.newMap.get(oppId).addError(PGI_CLOSEDWON_VALIDATION_MSG);
                }
            }
        }
    }
    
    /* filters out records by PGi record type */
    private List<Opportunity> filterPGiOpps(List<Opportunity> sobjs) {
        Set<Id> pgiRtSet = new Set<Id>();
        Map<String,Id> recordTypes = PGI_Utility.getRecordTypes('Opportunity');
        if(recordTypes.containsKey(PGI_RT)) {
            pgiRtSet.add(recordTypes.get(PGI_RT));
        }
        if(recordTypes.containsKey(PGI_RENEWAL_RT)) {
            pgiRtSet.add(recordTypes.get(PGI_RENEWAL_RT));
        }
        List<Opportunity> pgiOpportunitys = new List<Opportunity>();
        
        // loop thru Opportunitys matching record types to filter
        for(Opportunity opp : (List<Opportunity>)sobjs) {
            if(pgiRtSet.contains(opp.RecordTypeId)) { 
                pgiOpportunitys.add(opp);
            }
        }
        System.debug('>> pgiOpportunitys >>'+pgiOpportunitys);
        return pgiOpportunitys;
    }
    
    /* COD-1370 As Sal Sales, I need to create a new trigger, so that when an opportunity is Closed Won with 
the Product(s) 'Third Party Support' a new opportunity will be created with a Close Date of the Previous opportunity plus 11 months.
*/
    private static Set<Id> thirdPartyOppsGenerated = new Set<Id>();
    //private List<Opportunity> thirdPartyOppToInsert = new List<Opportunity>();
    private List<Opportunity> oppsToInsert = new List<Opportunity>();
    private List<OpportunityLineItem> oppLinesToInsert = new List<OpportunityLineItem>();
    private Map<Id, List<OpportunityLineItem>> thirdPartyOppLinesByOriginalOppId = new Map<Id, List<OpportunityLineItem>>();
    
    @TestVisible
    private static Set<Id> reOpenedOppsProcessed = new Set<Id>();
    //COD-1615 - if a opportunity that was previously closed won and has become re-opened or closed lost, purge the associated renewal opportunity
    public static void checkForReopen() {
        Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>)Trigger.oldMap;
        Set<Id> reOpenedOppIds = new Set<Id>();
        for(Opportunity o: (List<Opportunity>)Trigger.new) {
            if(o.isWon != true && oldMap.get(o.Id).isWon == true && !reOpenedOppsProcessed.contains(o.Id)) { //no longer closed won
                reOpenedOppIds.add(o.Id);
                reOpenedOppsProcessed.add(o.Id);
            }
        }
        List<Opportunity> toUpdate = new List<Opportunity>();
        if(reOpenedOppIds.size() > 0) {
            for(Opportunity o: [SELECT Id FROM Opportunity WHERE External_Opportunity_ID__c IN: reOpenedOppIds]) {
                o.StageName = 'Closed Lost';
                o.Closed_Lost_Nuture_Reason__c = 'Other';
                o.Closed_Reason_Explanation__c = 'Programmatically closed as the original opportunity is no longer Closed Won';
                toUpdate.add(o);
            }
        }
        Database.update(toUpdate, Test.isRunningTest());
    }
    //COD-1370
    // private void checkForClosureAndHandleR() {
    //     List<Opportunity> toValidate = new List<Opportunity>();
    //     for(Opportunity o: (List<Opportunity>)Trigger.new) {
    //         if(o.isClosed && o.isWon && !o.Opt_Out_Of_Auto_Renewal__c) {
    //             if(isChanged('IsClosed', o)) {
    //                 toValidate.add(o);
    //             }
    
    //             List<OpportunityLineItem> thirdPartyLines = thirdPartyOppLines(o);
    //             if(!thirdPartyLines.isEmpty()) {
    //                 generateThirdPartyOpp(o, thirdPartyLines);
    //             }
    //         }
    //     }
    //     validateProductsAreActive(toValidate);
    //     //remove synced quote ID
    //     List<sObject> sObjList = (List<Opportunity>)PGI_Utility.removeFields(oppsToInsert, new Set<String>{'Id', 'SyncedQuoteId', 'SyncedQuote'});
    //     //fix generic upsert error
    //     List<Opportunity> oppList = new List<Opportunity>();
    //     for(sObject s: sObjList) {
    //         oppList.add((Opportunity)s);  
    //     }
    
    //     upsert oppList External_Opportunity_ID__c;
    //     upsert oppLinesToInsert Cloned_From_Opportunity_Product_Id__c;
    // }
    //generate a cloned opp 11 months in the future
    /* private void generateThirdPartyOpp(Opportunity o, List<OpportunityLineItem> oliList) {

if(thirdPartyOppsGenerated.contains(o.Id) || PGI_Utility.profile.Name.equals('System Administrator')) { return; }
thirdPartyOppsGenerated.add(o.Id);
Opportunity clone = o.clone();
clone.External_Opportunity_ID__c = o.Id;
clone.Id = null;
clone.StageName = 'Perception Analysis';
clone.Probability = 70;
clone.CloseDate = clone.CloseDate.addMonths(11);
clone.Close_Reason__c = '';
clone.ForecastCategoryName = 'Best Case';
clone.PO_Number__c = '';
clone.PO_Date__c = null;
if(!clone.Name.startsWith('Renewal - ')){
String nameStr = 'Renewal - ' + clone.Name;
if(nameStr.length() > 80) {
nameStr = nameStr.left(80);
}
clone.name = nameStr;
}
//thirdPartyOppToInsert.add(clone);
oppsToInsert.add(clone);
for(OpportunityLineItem oli: oliList) {
//oli.OpportunityId = clone.Id;
//oli.Opportunity = clone;
oppLinesToInsert.add(oli);
}

}*/
    private void setLastSurveyDate() {
        for(Opportunity o: (List<Opportunity>)Trigger.new) {
            if(o.Primary_Contact__c != null && relatedContacts.get(o.Primary_Contact__c) != null && relatedContacts.get(o.Primary_Contact__c).Last_Survey_Sent__c != null) {
                o.Primary_Contact_Last_Survey_Sent__c = relatedContacts.get(o.Primary_Contact__c).Last_Survey_Sent__c;
            }
        }
    }
    private Map<Id, Contact> relatedContacts { get{
        if(relatedContacts == null) {
            Set<Id> contactIds = new Set<Id>();
            for(Opportunity o: (List<Opportunity>)Trigger.new) {
                contactIds.add(o.Primary_Contact__c);
            }
            contactIds.remove(null);
            relatedContacts = new Map<Id, Contact>([SELECT Id, Last_Survey_Sent__c, Last_Survey_Date__c FROM Contact WHERE Id IN: contactIds]);
        }
        return relatedContacts;
    } set;}
    private void summarizeFamilyValues() {
        for(Opportunity o: (List<Opportunity>)Trigger.new) {
            if(oppFamilySummaryMap.get(o.Id) != null) {
                Map<String, Decimal> familySummary = oppFamilySummaryMap.get(o.Id);
                o.Managed_Svs_Support_Total__c = familySummary.get('Managed Service & Support') == null ? 0 : familySummary.get('Managed Service & Support'); 
                o.Managed_Svs_Support_Margin__c = familySummary.get('Managed Service & SupportMargin') == null ? 0 : familySummary.get('Managed Service & SupportMargin'); 
                o.Professional_Svs_Total__c = familySummary.get('Professional Services') == null ? 0 : familySummary.get('Professional Services'); 
                o.Professional_Svs_Margin__c = familySummary.get('Professional ServicesMargin') == null ? 0 : familySummary.get('Professional ServicesMargin'); 
                o.Third_Party_Support_Total__c = familySummary.get('Third Party Support') == null ? 0 : familySummary.get('Third Party Support'); 
                o.Third_Party_Support_Margin__c = familySummary.get('Third Party SupportMargin') == null ? 0 : familySummary.get('Third Party SupportMargin'); 
                o.Third_Party_Total__c = familySummary.get('Third Party') == null ? 0 : familySummary.get('Third Party'); 
                o.Third_Party_Margin__c = familySummary.get('Third PartyMargin') == null ? 0 : familySummary.get('Third PartyMargin'); 
            }
        }
    }
    
    private OpportunitySelector oppSelector = new OpportunitySelector();
    public Map<Id, Opportunity> oppsWithRelated {get {
        //if(oppsWithRelated != null){
        return oppSelector.getOppsWithRelated(Trigger.newMap.keySet());   
        // }else{
        //     return oppsWithRelated;
        // }  
    }}
    
    public Map<Id, OpportunityLineItem> clonedOppLinesById {get {
        if(oppsWithRelated != null && clonedOppLinesById == null) {
            clonedOppLinesById = new Map<Id, OpportunityLineItem>();
            Set<Id> originalOppLineIds = new Set<Id>();
            for(Opportunity opp: oppsWithRelated.values()) {
                for(OpportunityLineItem oli: opp.OpportunityLineItems) {
                    originalOppLineIds.add(oli.Id); 
                }
            }
            if(!originalOppLineIds.isEmpty()){
                for(OpportunityLineItem oli: [SELECT Id, Cloned_From_Opportunity_Product_Id__c
                                              FROM OpportunityLineItem WHERE Cloned_From_Opportunity_Product_Id__c IN: originalOppLineIds]) {
                                                  clonedOppLinesById.put(oli.Cloned_From_Opportunity_Product_Id__c, oli);
                                              }
            }
        }
        return clonedOppLinesById;
    } set;}
    
    //This map's primary key is the opp id
    //secondary key is the product family
    //decimal value is the given opportunity's product families amount
    private Map<Id, Map<String, Decimal>> oppFamilySummaryMap {get {
        if(oppFamilySummaryMap == null) {
            oppFamilySummaryMap = new Map<Id, Map<String, Decimal>>();
            for(Opportunity o: oppsWithRelated.values()) {
                Map<String, Decimal> productFamilySummary = oppFamilySummaryMap.get(o.Id) == null ? new Map<String, Decimal>() : oppFamilySummaryMap.get(o.Id);
                for(OpportunityLineItem oli: o.OpportunityLineItems) {
                    Decimal familyTotal = productFamilySummary.get(oli.Product_Family__c) == null ? 0 : productFamilySummary.get(oli.Product_Family__c);
                    Decimal familyMargin = productFamilySummary.get(oli.Product_Family__c + 'Margin') == null ? 0 : productFamilySummary.get(oli.Product_Family__c + 'Margin');
                    if(oli.Total_Margin__c != null) {
                        familyMargin += oli.Total_Margin__c;
                    }
                    if(oli.TotalPrice != null) {
                        familyTotal += oli.TotalPrice;
                    }
                    productFamilySummary.put(oli.Product_Family__c, familyTotal);
                    productFamilySummary.put(oli.Product_Family__c+ 'Margin', familyMargin);
                }
                oppFamilySummaryMap.put(o.Id, productFamilySummary);
            }
        }
        return oppFamilySummaryMap;
    } set;}
    /*private Set<String> currencyCodes { get{
if(currencyCodes == null) {
currencyCodes = new Set<String>();
for(Opportunity opp: oppsWithRelated.values()) {
currencyCodes.add(opp.Owner.DefaultCurrencyIsoCode);
currencyCodes.add(opp.CurrencyIsoCode);
}
}
return currencyCodes;




} set; }*/
    
    private static List<Pricebook2> pbList {get {
        if(pbList == null) {
            pbList = [SELECT Id, Name, IsStandard FROM Pricebook2];
        }
        return pbList;
    } set;}
    private static Map<String, Pricebook2> pbMap {get {
        if(pbMap == null) {
            pbMap = new Map<String, Pricebook2>();
            for(Pricebook2 pb: pbList) {
                if(pb.isStandard) {
                    pbMap.put('STANDARD', pb);
                } else {
                    pbMap.put(pb.Name, pb);
                }
            }
        }
        return pbMap;
    } set;}
    /**LOBs:
-User custom field of Company:
PGi, TalkPoint,iMeetCentral
Matches Pricebook name with the exception that PGi uses the standard Pricebook 
*/
    private Map<Id, User> relatedOwners {get {
        if(relatedOwners == null) {
            Set<String> ownerIds = PGI_Utility.pluckStrings(Trigger.new, 'OwnerID');
            relatedOwners = new Map<Id, User>([SELECT Id, Company__c, Channel__c FROM User WHERE Id IN: ownerIds]); // ! move to variable
        }
        return relatedOwners;
    } set;}
    private static List<RecordType> rtList { get{
        if(rtList == null) {
            rtList = [SELECT Id, DeveloperName, Name FROM RecordType WHERE sObjectType = 'Opportunity'];
        }
        return rtList;
    } set;} 
    private void assignPB() {
        try {
            //Map<String, Id> recordTypeIdByName = PGI_Utility.getRecordTypes('Opportunity');
            
            for(Opportunity opp: (List<Opportunity>)Trigger.new){
                String oppRtName = '';
                //for(String recordTypeName :recordTypeIdByName.keySet()) {
                //    System.debug(recordTypeName);
                //    if(recordTypeIdByName.get(recordTypeName) == opp.RecordTypeId) {
                //        oppRtName = recordTypeName;
                //        System.debug('found match');
                //        break;
                //    }
                //}
                for(RecordType rt: rtList) {
                    if(rt.Id == opp.RecordTypeId) {
                        oppRtName = rt.Name;
                        break;
                    }
                }
                if(relatedOwners != null && 
                   relatedOwners.get(opp.OwnerId).Company__c != null 
                   && String.isBlank(opp.External_Opportunity_ID__c)) { //bypass cloned opps for price book assignment
                       if (String.isBlank(opp.Channel__c)){ 
                           opp.Channel__c = relatedOwners.get(opp.OwnerId).Channel__c;
                       }
                   }
                if(String.isBlank(opp.External_Opportunity_ID__c)) {
                    if (oppRtName.contains('iMC')) {
                        opp.Pricebook2Id = pbMap.get('iMC Price Book').Id;
                    } else if (oppRtName.contains('ReadyTalk')) {
                        opp.PriceBook2Id = pbMap.get('ReadyTalk Price Book').Id;
                    } else if (oppRtName.contains('TalkPoint')) {
                        opp.PriceBook2Id = pbMap.get('TalkPoint Price Book').Id;
                    }  else {
                        opp.Pricebook2Id = pbMap.get('PGi Simplified').Id;
                    }
                }
                
                
            }
        } catch(Exception ex){
            //system.debug(LoggingLevel.ERROR,'Error When Assigning region wise pricebook to opportunity '+ex.getMessage());
        }
    }
    /** 
// running this code on before update 
* @Method Name   : copyOppContactRoleData
* @Param         : Map<Id, Opportunity>
* @ReturnType    : void
* @Discription   : assign the primary OpportunityContactRole's Role to the opportunity Primary_Role__c and contactId to the Primary_Contact__c;
*/
    private void copyOppContactRoleData(){
        
        Map<Id, Opportunity> OpportunityById = (Map<Id, Opportunity>) Trigger.newMap;
        Map<Id, OpportunityContactRole> opportunityContactRoleByOppID = new Map<Id, OpportunityContactRole>();
        // for(OpportunityContactRole obj : [SELECT ID, ContactId, OpportunityId, Role, Contact.Buyer_Persona__c
        //                                     FROM OpportunityContactRole
        //                                     WHERE  OpportunityId =: OpportunityById.keySet() AND IsPrimary = TRUE ]) // ! move to related Query
        for( Opportunity objOpp : oppSelector.getOppsWithRelated(Trigger.newMap.keySet()).values())
        {
            for(OpportunityContactRole obj : objOpp.OpportunityContactRoles){
                if(obj.IsPrimary == true){
                    opportunityContactRoleByOppID.put(objOpp.Id, obj);
                }
            }
        }
        for(Opportunity obj : OpportunityById.values()){
            if(opportunityContactRoleByOppID.containsKey(obj.Id)){
                OpportunityContactRole objOppContactRole = opportunityContactRoleByOppID.get(obj.Id);
                obj.Primary_Role__c = objOppContactRole.Role;
                obj.Primary_Contact_s_Buyer_Persona__c = objOppContactRole.Contact.Buyer_Persona__c;
                obj.Primary_Contact__c = objOppContactRole.ContactId;
            }
        }
    }
    /** 
// running this code on before Insert 
* @Method Name   : convertingAllProcessBuilder
* @Param         :
* @ReturnType    : void
* @Discription   : we are converting all opportunity process builder to trigger.
*/
    private void convertingAllProcessBuilder(){
        
        Set<Id> opportunityRecordTypeIdSet = new Set<Id>(); //PGi recordType
        Set<Id> opportunityiMCRecordTypeIdSet = new Set<Id>();
        //iMC
        for(RecordType rt : rtList)
        {
            if(rt.DeveloperName.containsIgnoreCase('PGi')){
                opportunityRecordTypeIdSet.add(rt.Id);
            }else if(rt.DeveloperName.containsIgnoreCase('iMC')){
                opportunityiMCRecordTypeIdSet.add(rt.Id);
            }
        }
        
        Map<Id, Account> accountById = relatedAccounts;
        // PGi-RW_Set Opportunity Source Open_18id
        for(Opportunity oppObj : (List<Opportunity>)trigger.new){
            // update  opportunity Opportunity_Source_Open__c   // PGi-Update Oppty Source
            if(oppObj.LeadSource != null &&  opportunityRecordTypeIdSet.contains(oppObj.RecordTypeId)){
                oppObj.Opportunity_Source_Open__c = oppObj.LeadSource;
            }
            // iMC - Reassign Renewal Opportunities to Account Owner 
            if(oppObj.AccountId != null && opportunityiMCRecordTypeIdSet.contains(oppObj.RecordTypeId) && oppObj.OwnerId != accountById.get(oppObj.AccountId).OwnerId){
                oppObj.OwnerId = accountById.get(oppObj.AccountId).OwnerId;
            }
        }
        
        
    }
    /** 
* * when a record is created or edited
* * @Method Name   : convertingAllProcessBuilderAllEvent
* @Param         :
* @ReturnType    : void
* @Discription   : we are converting all opportunity process builder to trigger.
*/        
    private void convertingAllProcessBuilderAllEvent(){
        Set<Id> opportunityRecordTypeIdSet = new Set<Id>();
        Boolean isNew = trigger.isInsert;
        Set<Id> opportunitiesIDSet = new Set<Id>(); // used to updated Implementation_Services__c records 
        String ReadyTalkOpportunityRecordTypeId;
        String talkpointRtId = '';
        for(RecordType rt : rtList) //! move to
        {
            if(rt.DeveloperName.containsIgnoreCase('PGi')){
                opportunityRecordTypeIdSet.add(rt.Id);
            }
            if(rt.Name == 'ReadyTalk Opportunity' ){
                ReadyTalkOpportunityRecordTypeId = rt.Id;
            }
            if(rt.Name == 'TalkPoint Opty') {
                talkpointRtId = rt.Id;
            }
            
            
        }
        Map<Id, Account> accToUpdateById = new  Map<Id, Account>(); // PGi-Base Conversion update Account's Conversion Priority field
        Map<Id, Account> accountById = relatedAccounts;
        
        
        // to post message in chatter post 
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        
        
        // PGi-RW_Set Opportunity Source Open_18id
        for(Opportunity oppObj : (List<Opportunity>)trigger.new){
            
            //* PGi-Update Opty Type
            if(oppObj.IsClosed == false && (opportunityRecordTypeIdSet.contains(oppObj.RecordTypeId) || talkpointRtId == oppObj.RecordTypeId)){
                //System.debug('okkkk---> PGi-Update Opty Type');
                updateOpportunityDealType(oppObj);
            }
            //* PGi-Set IST Completed Status Flow vs4
            if(oppObj.StageName == 'Closed Lost' && opportunityRecordTypeIdSet.contains(oppObj.RecordTypeId)){
                // update the Cancelled Notes in Implementation_Services__c
                opportunitiesIDSet.add(oppObj.Id);
            }
            //* PGi-Base Conversion
            if(oppObj.AccountId != null && accountById.containsKey(oppObj.AccountId) && accountById.get(oppObj.AccountId).BaseConversion__c == true 
               && oppObj.StageName != 'Awareness' && String.isNotBlank(oppObj.Opportunity_Product_Families__c) && oppObj.Opportunity_Product_Families__c.containsIgnoreCase('Web: GlobalMeet') ){
                   Account acc = accountById.get(oppObj.AccountId);
                   acc.ConversionPriority__c = 'Worked';
                   accToUpdateById.put(acc.Id, acc); // Update Conversion Priority // PGi-Base Conversion
               }
            
        } 
        //* PGi-Base Conversion 
        
        UPDATE accToUpdateById.values(); 
        System.debug('>> opportunitiesIDSet.size() >>'+opportunitiesIDSet.size());
        if(opportunitiesIDSet.size() > 0){
            // update Implementation_Services__c // update the Cancelled Notes in Implementation_Services__c
            List<Implementation_Services__c> ImplementationServiceList = new List<Implementation_Services__c>();
            for(Implementation_Services__c objImpServ : [SELECT Id, Cancelled_Notes__c, IST_Completed_Status__c 
                                                         FROM Implementation_Services__c 
                                                         WHERE Related_Opportunity__c =: opportunitiesIDSet ])
            {
                //System.debug('Implementation_Services__c>>>>'+objImpServ);
                objImpServ.Cancelled_Notes__c = 'Per Opportunity, closed lost by sales.';
                if(objImpServ.IST_Completed_Status__c != 'Cancelled'){
                    objImpServ.IST_Completed_Status__c = 'Cancelled';
                }
                ImplementationServiceList.add(objImpServ);
            }
            UPDATE ImplementationServiceList; 
            //ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
        }
    }
    
    @TestVisible
    private void updateOpportunityDealType(Opportunity oppObj){
        switch on oppObj.Opportunity_Deal_Type__c {
            when 'Up-Sell (Rev Increase)' {		
                oppObj.Type = 'Existing Cust- Existing Svc';
            }	
            when 'Down-Sell (Rev Decrease)' {		 
                oppObj.Type = 'Existing Cust- Existing Svc';
            }
            when 'Renewal (No Rev Change)' {		
                oppObj.Type = 'Existing Cust- Existing Svc';
            }
            when 'Existing Customer' {		
                oppObj.Type = 'Existing Cust- Existing Svc';
            }
            when 'Existing Customer – New Div' {		
                oppObj.Type = 'Existing Cust- Existing Svc';
            }
            when 'Existing Customer – New Country' {		
                oppObj.Type = 'Existing Customer – New Country';
            }
            when 'Conversion'{
                oppObj.Type = 'Existing Cust- New Svc';
            }
            when 'New Business' {
                oppObj.Type = 'New Logo';
            }
            when 'New Customer' {
                oppObj.Type = 'New Logo';
            }
            when 'Win Back' {
                oppObj.Type = 'Winback';
            }
            when else {
                oppObj.Type = NULL;
            }
        }
    }
    
    /** RT-164 Opportunity Team Engine */
    
    public class teamEngine{
        List<OT_Member__c> ruleEngineList;
        Set<String> opportynityFieldsSet;
        Set<String> lineItemFieldsSet;
        
        public teamEngine(List<OT_Member__c> ruleEngineList, Set<String> opportynityFieldsSet, Set<String> lineItemFieldsSet){
            this.ruleEngineList = ruleEngineList;
            this.opportynityFieldsSet = opportynityFieldsSet;
            this.lineItemFieldsSet = lineItemFieldsSet; 
        }
    }
    
    // To get Map of MemberId to Acc/Opp/Owner Fields and  MemberId to OpportunityLineItem Fields
    private static teamEngine teamEngineWrapper {get {
        if(teamEngineWrapper == null){
            Set<String> opportynityFieldsSet = new Set<String>{'Id'};
                Set<String> lineItemFieldsSet = new Set<String>{'Id', 'OpportunityId'};
                    
                    List<OT_Member__c> ruleEngineList =  [SELECT ID, Name, Evaluation_Order__c, Rule_Order__c,
                                                          (SELECT ID, Object_Name__c, Relationship_Name__c,Field_API_Name__c, Field_Name__c, Field_Type__c, Field_Value__c, Line_Number__c, Field_Operator__c
                                                           FROM Opportunity_Team_Rules__r Order by Line_Number__c ASC ),
                                                          (SELECT Id,OT_Member__c,Role__c,User__c
                                                           FROM Team_Members__r)                                              
                                                          FROM OT_Member__c Order by Rule_Order__c ASC];
            //    System.debug('ot member is'+ruleEngineList);
            for(OT_Member__c otMemberRules : ruleEngineList) {
                //TODO - comment this
                for(OT_Rule__c objRule : otMemberRules.Opportunity_Team_Rules__r){
                    if(String.isBlank(objRule.Relationship_Name__c)){
                        opportynityFieldsSet.add(objRule.Field_API_Name__c);
                    }else/* if(Opp Line item) */{
                        lineItemFieldsSet.add(objRule.Field_API_Name__c); 
                    }
                }     
            }
            teamEngineWrapper = new teamEngine(ruleEngineList, opportynityFieldsSet, lineItemFieldsSet);
        }
        return teamEngineWrapper;
    } set;}
    
    /**
MethodName:  checkOpportunitesWithMatchedTeamEngineRules
Ticket No: RT-164
**/
    @future
    private static void checkOpportunitesWithMatchedTeamEngineRules(Set<Id> oppIds) {    
        
        String soqlQueryString = 'SELECT '+String.Join(new List<String>(teamEngineWrapper.opportynityFieldsSet), ',');
        soqlQueryString += ',( SELECT '+String.Join(new List<String>(teamEngineWrapper.lineItemFieldsSet), ',') + ' FROM OpportunityLineItems )';
        soqlQueryString += ' FROM Opportunity WHERE Id =: oppIds ';
        
        // System.debug('soqlQueryString>>>>>>>>> '+soqlQueryString);
        List<Opportunity> objOpportunity = Database.query(soqlQueryString);
        System.debug('objOpportunity>>>>>>>>> '+objOpportunity);
        
        List<OpportunityTeamMember> oppyTeamMemberListtoInsertforMatchedOppy = new List<OpportunityTeamMember>();
        String oppId;
        Map<Id, Decimal> matchedRuleOrderByOppId = new Map<Id, Decimal>();
        for(OT_Member__c otMemberRules : teamEngineWrapper.ruleEngineList){
            //String EvaluationOrder = otMemberRules.Evaluation_Order__c;
            // System.debug('EvaluationOrder>>1111>>>>> '+EvaluationOrder);
            if(objOpportunity.size() == matchedRuleOrderByOppId.size()){
                // if map size is equal to list of opportunity then we can think that all opportunities are matched with some rule so we need to break loop;
                break;
            }
            for(Opportunity objOpp : objOpportunity){
                if(matchedRuleOrderByOppId.containsKey(objOpp.Id)){ // if this opportunity is matched with other rule then will not check further.
                    continue;
                }
                String EvaluationOrder = otMemberRules.Evaluation_Order__c;
                for(OT_Rule__c objRule : otMemberRules.Opportunity_Team_Rules__r){
                    //system.debug('objRule==>'+objRule);
                    if(String.isBlank(objRule.Relationship_Name__c)){
                        EvaluationOrder = EvaluationOrder.replaceFirst(String.valueOf(objRule.Line_Number__c), String.valueOf(checkOpportunityMatch(objOpp,objRule))).toUpperCase();
                        System.debug('EvaluationOrder>>aaa>>>>> '+EvaluationOrder);
                        oppId = objOpp.Id;
                    }else if(objOpp.OpportunityLineItems.size() > 0){
                        for(OpportunityLineItem objOppLineItem : objOpp.OpportunityLineItems){
                            System.debug('EvaluationOrder>>opppLineItem>>>before>> '+EvaluationOrder);
                            EvaluationOrder = EvaluationOrder.replaceFirst(String.valueOf(objRule.Line_Number__c), String.valueOf(checkOpportunityMatch(objOppLineItem,objRule))).toUpperCase();
                            System.debug('EvaluationOrder>>opppLineItem>>>>> '+EvaluationOrder);
                            oppId = objOppLineItem.OpportunityId;
                        }
                    }else{
                        EvaluationOrder = EvaluationOrder.replaceFirst(String.valueOf(objRule.Line_Number__c), 'FALSE').toUpperCase();
                    }
                }
                if(BooleanExpression.eval(EvaluationOrder)){
                    matchedRuleOrderByOppId.put(objOpp.ID, otMemberRules.Rule_Order__c);
                    for(Team_Member__c teamMember : otMemberRules.Team_Members__r){
                        OpportunityTeamMember objOppTeamMember = new OpportunityTeamMember(OpportunityId = oppId, UserId = teamMember.User__c, TeamMemberRole = teamMember.Role__c); 
                        oppyTeamMemberListtoInsertforMatchedOppy.add(objOppTeamMember);
                    }
                    //break;
                }
            }
            
            // System.debug('oppId>>>>>>>>>>> '+oppId);
            // System.debug('EvaluationOrder>>>> '+EvaluationOrder+' <<<<Bool value>>> '+BooleanExpression.eval(EvaluationOrder));
            
        }
        
        if(!oppyTeamMemberListtoInsertforMatchedOppy.isEmpty()){
            Database.insert(oppyTeamMemberListtoInsertforMatchedOppy, false);
        }
        
    }
    //  
    private static Boolean checkOpportunityMatch(sObject objRec ,OT_Rule__c otRule){
        System.debug('isMatched>>>> '+OTE_ConditionCheck.checkCondition(objRec, otRule));
        return OTE_ConditionCheck.checkCondition(objRec, otRule);
    }
    
    // /* RT- 386 start 
    // * before Update Logic
    // * Description: Updating opportunity when the agreement status = signed and opportunity deal type = New Business or Win Back
    // * Author :Anup
    // **/
    // public static void updateOpportunityToclosedPendingAproval(){
    //     for(Opportunity obj : (List<Opportunity>)Trigger.new) {
    //         if(obj.Agreement_Status__c == 'Signed' && (obj.Opportunity_Deal_Type__c =='New Business' || obj.Opportunity_Deal_Type__c == 'Win Back')) { 
    //             obj.StageName = 'Closed Pending Approval';
    //         }
    //     }
    // }
    /* RT- 388 start
*  Description: Validating opportunity record when it is closed won
*  Author :Anup
**/
    // public static void validateOpportunityClosedWonForPGiContract(){
    //     RecordType objRecordType = [SELECT Id FROM RecordType WHERE name = 'PGi Opportunity' and sObjectType = 'Opportunity'];
    //     for(Opportunity obj : (List<Opportunity>)Trigger.new) {
    //         System.debug('=obj.StageName====>'+obj.StageName);
    //         System.debug('=obj.Opportunity_Product_Families__c====>'+obj.Opportunity_Product_Families__c);
    //         System.debug('=obj.Opportunity_Deal_Type__c====>'+obj.Opportunity_Deal_Type__c);
    //         System.debug('=obj.Channel__c====>'+obj.Channel__c);
    //         if((obj.recordTypeId == objRecordType.Id && obj.StageName == 'Closed Won') &&
    //             ((obj.Opportunity_Product_Families__c == 'UCaaS' || obj.Opportunity_Product_Families__c == 'Collaboration') &&
    //             obj.Opportunity_Deal_Type__c == 'Up-Sell (Rev Increase)' && 
    //             ((obj.Channel__c == 'Cloud' ||
    //              obj.Channel__c == 'Major Accounts' ||
    //              obj.Channel__c == 'APAC' ||
    //              obj.Channel__c == 'Japan' ||
    //              obj.Channel__c == 'Tier One') || 
    //              (obj.Channel__c == 'Partners' &&
    //              (obj.Account_Type__c == 'End User - Agent' || obj.Account_Type__c == 'Partner Direct'))))){
    //                 obj.addError('You must attach a written confirmation from the customer reviewing their increasing revenue costs or an email thread of the like before proceeding.');
    //         }
    
    //     }
    // }
    //RT-472 add fields When approval process is approved.
    private void SetApprovalDateComment() {
        Set<ID> oppId = new Set<Id>();
        Id processDefnId = [SELECT Id FROM ProcessDefinition WHERE DeveloperName = 'PGi_Closed_Pending_Approval'].Id;
        Set<Id> processIstId = new Set<Id>();
        
        List<Opportunity> opptyList =  [SELECT Id, (SELECT Id, ActorId, Comments, CreatedById, CreatedDate, IsDeleted,
                                                    ElapsedTimeInDays, ElapsedTimeInHours, ElapsedTimeInMinutes, IsPending,
                                                    OriginalActorId, ProcessInstanceId, ProcessNodeId, RemindersSent,
                                                    StepStatus, SystemModstamp, TargetObjectId
                                                    FROM ProcessSteps 
                                                    WHERE ProcessInstance.ProcessDefinitionId =: processDefnId)
                                        FROM Opportunity
                                        WHERE Id IN: Trigger.new];
        // ProcessInstanceStep
        Set<Id> processSetIds = new Set<Id>();
        for(Opportunity oppObject : opptyList) {
            for(ProcessInstanceHistory ps: oppObject.ProcessSteps) {
                if(ps.StepStatus == 'Approved') {
                    Opportunity opp = (Opportunity)Trigger.newMap.get(oppObject.Id);
                    if(opp != null && opp.Sales_Audit_Approved_Date__c == null) {
                        opp.Approval_Comment__c = ps.Comments;
                        opp.Sales_Audit_Approved_Date__c = ps.SystemModstamp;
                    }
                }
            }
        }
    }
    /* end -----------------------------------------*/
    /*
* Method to insert records to fiere Platform Event
*/
    private void fireEventHandler(){
        if(Trigger_Settings__c.getInstance().Bypass_Totango__c) { return; }
        List<Aggregate_Calculation_Event__e> listOfagregateEvents = new List<Aggregate_Calculation_Event__e>();
        
        for(Opportunity oppObj :(List<Opportunity>)Trigger.new){
            if(oppObj.PGICompany__c != null || oppObj.PGIEntity__c != null){
                Aggregate_Calculation_Event__e obj = new Aggregate_Calculation_Event__e() ;   
                obj.PGI_Company_Id__c   = oppObj.PGICompany__c;
                obj.PGI_Entity__c       = oppObj.PGIEntity__c;
                listOfagregateEvents.add(obj);
            }
        }
        if(!listOfagregateEvents.isEmpty()){
            List<Database.SaveResult> results = EventBus.publish(listOfagregateEvents);
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } 
                
            }
        }
    }
    
   private void setConvertedfromGlobalContactMql(){
       for(Opportunity o:(List<Opportunity>)Trigger.new){
           Opportunity oppWithRelated = oppsWithRelated.get(o.Id);
           System.debug('Test123@Rc'+oppWithRelated.Primary_Contact__c);
           System.debug('Test123@Date'+oppWithRelated.Primary_Contact__r.Global_Contact_MQL_Assignment_date__c);
          
           if(oppWithRelated.Primary_Contact__c != null
                    && oppWithRelated.Primary_Contact__r.Global_Contact_MQL_Assignment_date__c != null 
                    && oppWithRelated.Primary_Contact__r.Global_Contact_MQL__c == true) {
                        System.debug('The Updates');
               DateTime assignDate = oppWithRelated.Primary_Contact__r.Global_Contact_MQL_Assignment_date__c;
               System.debug('The AssigDate'+assignDate);
               System.debug('The CreatedDate'+o.CreatedDate);
               if((o.CreatedDate > assignDate) && ( o.CreatedDate < assignDate.addMonths(6) )){
                   System.debug('The Updates1');
                       o.Converted_from_Global_Contact_MQL__c =true;
                  }
               else{
                    o.Converted_from_Global_Contact_MQL__c =false;
               }
           }
       }
    }

    private void setConvertedMQAField(){
        for(Opportunity opp1:(List<Opportunity>)Trigger.new){
            Opportunity oppWithRelated = oppsWithRelated.get(opp1.Id);
            if(oppWithRelated.AccountId != null && oppWithRelated.Account.Global_Account_MQA_Assignment_date__c != null) {
                DateTime globalAccMQAAssignDate = oppWithRelated.Account.Global_Account_MQA_Assignment_date__c;
                if((opp1.CreatedDate > globalAccMQAAssignDate) && (opp1.CreatedDate < globalAccMQAAssignDate.addMonths(6))){
                    System.debug('The New Updates');
                    opp1.Converted_from_MQA__c =true;
               }
            }
            
        }
    }
}