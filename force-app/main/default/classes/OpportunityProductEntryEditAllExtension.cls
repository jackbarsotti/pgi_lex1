public with sharing class OpportunityProductEntryEditAllExtension {
    public Opportunity theOpp {get;set;}
    String rtname;

    // we are extending the OpportunityLineItem controller, so we query to get the parent OpportunityId
    public OpportunityProductEntryEditAllExtension(ApexPages.StandardController controller) {
        theopp = database.query('SELECT Id, RecordType.Name, RecordType.DeveloperName FROM Opportunity WHERE Id = \'' + controller.getRecord().Id + '\' limit 1');
        rtname = theopp.recordtype.name;
    } 
    public pageReference redirect(){
        if(rtname.contains('PGi'))
        {
            return new PageReference('/apex/opportunityProductEntry?id=' + theopp.Id);
        } else {
            PageReference newpage;
            newPage = new PageReference('/apex/ReadyTalkOpportunityProductEntry?id='+theopp.Id+'&retURL=%2F'+theopp.Id);
            //newPage.getParameters().put('nooverride', '1');
            return newPage.setRedirect(true);   
        }       
    }
}