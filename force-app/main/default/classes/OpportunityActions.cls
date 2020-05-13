public class OpportunityActions {

  ////SFB-12
  //public static void afterSaveUpdateProspectStatus(List<Opportunity> newOpps, List<Opportunity> oldOpps) {
  //  for(Opportunity opp : newOpps) {
  //    if(!ReadyTalkRecordTypeHelper.readyTalkOpportunityRecordTypeIds.contains(opp.RecordTypeId)) {
  //        continue;
  //    }
  //    if(opp.SAL_Date__c != null) {
  //      List<Contact> contacts = [select id,Prospect_Status__c from Contact where id in (select contactid from OpportunityContactRole where OpportunityId=:opp.Id)];

  //      //Should only be 1 contact
  //      for (Contact c : contacts) {
  //        //Update the Prospect_Status__c to Marketing Qualified Lead (MQL) if it isn't already...if it is, then don't touch it
  //        if(c.Prospect_Status__c != 'Marketing Qualified Lead (MQL)' && 
  //            c.Prospect_Status__c != 'Sales Sourced' && 
  //            c.Prospect_Status__c != 'Event Sourced' &&
  //            c.Prospect_Status__c != 'AM Sourced') {
            
  //          c.Prospect_Status__c = 'Marketing Qualified Lead (MQL)';
  //          update(c);
  //        }
  //      }
  //    }        
  //  }
  //}
}