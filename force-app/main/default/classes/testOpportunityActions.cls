@isTest
private class testOpportunityActions {

  static testMethod void testAfterSaveUpdateProspectStatus() {
    Opportunity o = new Opportunity();
    o.SAL_Date__c = Date.today();
    List<Opportunity> olist = new List<Opportunity>();
    olist.add(o);
    //OpportunityActions.afterSaveUpdateProspectStatus(olist,null);
  }

}