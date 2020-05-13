/**
*    Opportunity trigger logic for Before/After insert/Update/delete Events
*
*    Modification Log
*
*    Deepthi        PGI    11/06/2014      Opportunity trigger logic for Before/After Insert/Update/Delete 
**/

public class OpportunityEventHandler{
    public static boolean skipExecution = false; // boolean to exempt recursive trigger logic execution
    public static boolean inFutureContext = false; // prevent future method calls recursively in SetDefaultOpportunityRegionField trigger
    /*
    * Logic to Associate Opportunity.AccountId with existing Account matching  eCommerceAccountNumber
    */
    public static void updateOpportunity(list<Opportunity> opporLst){
        //map<String, list<Opportunity>> opporEcomAcctNoMap = new map<String, list<Opportunity>>();
        //list<Opportunity> opporEcomLst = new list<Opportunity>();
        
        ///* Storing map<opportunity.EcommerceAccountNumber, list<Opportunities>> */
        //for(Opportunity oppor:opporLst){
        //  if(oppor.ECommerce_Account_Number__c != null){
        //    opporEcomLst = opporEcomAcctNoMap.containskey(oppor.ECommerce_Account_Number__c)?
        //                    opporEcomAcctNoMap.get(oppor.ECommerce_Account_Number__c):new list<Opportunity>();
        //    opporEcomLst.add(oppor);
        //    opporEcomAcctNoMap.put(oppor.ECommerce_Account_Number__c, opporEcomLst);  
        //  }
          
        //}
        ////END of Storing opportunity eCommerceAccountNumber in Map
        
        // START Retrieving Accounts matching the EcommerceAccountNumber and Associate the matching Opportunity with Account 
        //if(opporEcomAcctNoMap != null && opporEcomAcctNoMap.size()>0){
        //try{
        //   for(Account act: [select id, ECommerce_Account_Number__c from account 
        //                where ECommerce_Account_Number__c != null and recordtype.name like '%PGi%' and ECommerce_Account_Number__c in :opporEcomAcctNoMap.keyset()]){
        //       if(opporEcomAcctNoMap.containskey(act.ECommerce_Account_Number__c)){
        //          for(Opportunity oppor:opporEcomAcctNoMap.get(act.ECommerce_Account_Number__c)){         
        //           oppor.accountid = act.id;
        //          }
        //       }
        //   }
        // }
        // catch(Exception e){
        //     system.debug('OpportunityEventHandler Exception : ' + e.getMessage()); 
        // }
        //}
        ///* END logic for associating opportunity with account matching eCommerceAccountNumber */
        //system.debug('OpporLst:'+ opporLst);
    }
    
    /**
    * Logic to delete Opportunity LicenseSets on deleting Opportunities
    **/
    public static void deleteOpporLicenseSets(list<opportunity> opporLst){
        delete [select id from licenseset__c where Opportunity__c in :opporLst];
    }

    /**
    * Logic to delete Opportunity License/Assets on deleting Opportunities
    **/ 
    public static void deleteOpporLicenses(list<opportunity> opporLst){
        delete [select id from Asset where Opportunity__c in :opporLst];
    }
    
    /*
    * Logic to create Contracts for Opportunities updated with StageName = 'Closed Won' and eCommerceConvert = true
    */
    public static void createContracts(map<id, Opportunity> newOpporMap, map<id,Opportunity> oldOpporMap){
        list<opportunity> opporLst = new list<opportunity>();
        /* START getting list of opportunities updated with StageName = 'Closed Won' and eCommerceConvert = true */
         for(Opportunity oppor:newOpporMap.values()){
            Opportunity oldOppor = oldOpporMap.get(oppor.id);
            if(oppor.StageName == 'Closed Won' && oppor.ECommerce_Convert__c && 
                (
                    oppor.ECommerce_Convert__c <> oldOppor.ECommerce_Convert__c
                )
                ){
                opporLst.add(oppor);
            }
         }
         /* END - getting opportunity list with 'Closed Won' and eCommerceConvert */
         
         
         
        /* END logic to create Contracts for opportunity */      
    }
    /* Logic to mirror Opportunity Licenseset to OpportunityLineItem using ProductMapping 
        if opportunity.isClosed (StageName = Closed Won/Lost)
    */
    public static void mirrorOpportunityLineItemLicenseSet(map<id, Opportunity> oldOpporMap, map<id, Opportunity> opporMap){
    }//mirrorOpportunityLineItemLicenseSet
    
    public static List<opportunityLineItem> addExistingOppLineItem(Set<ID> closeOpp){
       return new List<opportunityLineItem>(); 
    }
    /*
    public static void setOpportunityScorecardFields(Map<Id, Opportunity> oldOppMap, Map<Id, Opportunity> oppMap){
        Map<Id, Opportunity> oppToUpdateMap = new Map<Id, Opportunity>();
        for(Opportunity opp : oppMap.values()){
            if(opp.OwnerId != oldOppMap.get(opp.Id).OwnerId){
                oppToUpdateMap.put(opp.Id, opp);
            }
        }
        
        List<GCS_Acq_Opportunity_Scorecard__c> oppScorecardList = [SELECT Id, Opportunity__c FROM GCS_Acq_Opportunity_Scorecard__c WHERE Opportunity__c =: oppToUpdateMap.keySet()];
        for(GCS_Acq_Opportunity_Scorecard__c oppScorecard : oppScorecardList){
            oppScorecard.OwnerId = oppToUpdateMap.get(oppScorecard.Opportunity__c).OwnerId;
        }
        update oppScorecardList;
    }*/
    private static Integer isGCSReadWritePermission {get {
        if(isGCSReadWritePermission == null) {
            isGCSReadWritePermission = [SELECT count() FROM SetupEntityAccess WHERE SetupEntityId IN (SELECT Id FROM CustomPermission WHERE DeveloperName = 'GCS_Read_Write_Ramp_Dates')
                                            AND ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE Assignee.Id =: UserInfo.getUserId())];  
        }
        return isGCSReadWritePermission;
    } set;} 
    public static void validateRampDates(List<Opportunity> oppList){
         
        if(isGCSReadWritePermission == 1){
            Set<Id> oppIds = new Set<Id>();
            for(Opportunity opp : oppList){
                if(opp.Probability == 80 || opp.Probability == 90 || (opp.StageName != null && opp.StageName.contains('Closed Won'))){
                    oppIds.add(opp.Id);
                }
            }
            
            Set<Id> errorOppIds = new Set<Id>();
            List<OpportunityLineItem> opliList = [SELECT Initial_Bill_Date__c, X100_Ramp_Date__c, OpportunityId FROM OpportunityLineItem WHERE Existing_Service__c = false AND OpportunityId IN :oppIds];
            for(OpportunityLineItem opli : opliList){
                if(opli.Initial_Bill_Date__c == null || opli.X100_Ramp_Date__c == null){
                    errorOppIds.add(opli.OpportunityId);
                }
            }
            
            for(Opportunity opp : oppList){
                if(errorOppIds.contains(opp.Id)){
                    opp.addError('Before setting Probability % to 80 or higher or Status to Closed Won, both Initial Bill Date and 100% Ramp Date on the product screen are required for any product that is not an Existing Service');
                }
            }
        }
    }
    
    public static void UpdateOppFields(Set<Id> ownerIds, List<Opportunity> oppList){
       /*Map<Id,User> UserInfo  = new Map<Id,User>([Select Id, User_Region__c,Manager.Name,Location__c,Channel__c From User where Id in: ownerIds 
                                                    and (not Profile.Name like:'System Administrator%')]);*/
        Map<Id,User> UserManagerInfo  = new map<Id,User>([Select Id, User_Region__c, Channel__c, Location__c, Manager.Name, Manager.Email From User where Id in: ownerIds]);
        for(Opportunity opp : oppList){
            if(UserManagerInfo.containsKey(opp.OwnerId)){
                User user = UserManagerInfo.get(opp.OwnerId);
                opp.Owner_Region__c = user.User_Region__c;
                opp.Channel__c = user.Channel__c; 
                opp.Location__c = user.Location__c;
                //opp.Supervisor__c = user.Manager.Name;
                //opp.Supervisors_Email__c = user.Manager.Email;
                //opp.Opportunity_Source_Close__c = 'None';
            }
        }
    }
    
    /*
    @future
    public static void UpdateSupervisorEmail(Set<Id> oppIds){
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<Opportunity> oppList = [SELECT Id, OwnerId, Owner.Manager.Email FROM Opportunity WHERE Id=:oppIds];
        for(Opportunity opp : oppList){
            oppsToUpdate.add(new Opportunity(Id = opp.Id, Supervisors_Email__c = opp.Owner.Manager.Email));
        }
        
        if (oppsToUpdate.size()>0){
            OpportunityEventHandler.inFutureContext = true;
            update oppsToUpdate;
        }
    } */
}