public with sharing class OpportunityProductEntryRedirectExtension {
    public Opportunity theOpp {get;set;}
    String rtname;
    String oppdealtype;

    // we are extending the OpportunityLineItem controller, so we query to get the parent OpportunityId
    public OpportunityProductEntryRedirectExtension(ApexPages.StandardController controller) {
        theopp = database.query('select Id,recordtype.name,opportunity_deal_type__c  from Opportunity where Id = \'' + controller.getRecord().Id + '\' limit 1');
        rtname = theopp.recordtype.name;
        oppdealtype = theopp.opportunity_deal_type__c;
    }  
    public pageReference redirect(){
        if(rtname.contains('PGi'))
        {
            if(oppdealtype == null){
                apexpages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'The Opportunity Deal Type should be populated before adding a product to this Opportunity'));
                return null;}
            else
                return new PageReference('/apex/opportunityProductEntry?id=' + theopp.Id);
        }
        else
        {
            PageReference newpage;
            return new PageReference('/apex/ReadyTalkOpportunityProductEntry?id=' + theopp.Id);
            //newPage = new PageReference('/p/opp/SelectSearch?addTo='+theopp.Id+'&retURL=%2F'+theopp.Id);
            //newPage.getParameters().put('nooverride', '1');
            return newPage.setRedirect(true);   
        }           
    }
}