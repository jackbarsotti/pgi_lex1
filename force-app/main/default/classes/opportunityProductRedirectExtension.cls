//public with sharing class opportunityProductRedirectExtension {

//    Id oppId;

//    // we are extending the OpportunityLineItem controller, so we query to get the parent OpportunityId
//    public opportunityProductRedirectExtension(ApexPages.StandardController controller) {
//        oppId = [select Id, OpportunityId from OpportunityLineItem where Id = :controller.getRecord().Id limit 1].OpportunityId;
//    }
    
//    // then we redirect to our desired page with the Opportunity Id in the URL
//    public pageReference redirect(){
//        return new PageReference('/apex/opportunityProductEntry?id=' + oppId);
//    }

//}

public with sharing class opportunityProductRedirectExtension {
    Id oliId;
    Id oppId;
    String rtname;

    // we are extending the OpportunityLineItem controller, so we query to get the parent OpportunityId
    public OpportunityProductRedirectExtension(ApexPages.StandardController controller) {
        oppId = [select Id, OpportunityId from OpportunityLineItem where Id = :controller.getRecord().Id limit 1].OpportunityId;
        oliId = controller.getRecord().Id;
        rtname = [Select Id,RecordType.Name from Opportunity where Id =: oppId].recordtype.name;
    }   
    public pageReference redirect(){
        if(rtname.contains('PGi'))
        {
            return new PageReference('/apex/opportunityProductEntry?id=' + oppId);
        }
        else
        {
            PageReference newpage;
            newPage = new PageReference('/apex/OpportunityProductEditPage?id='+oliId);
            newPage.getParameters().put('retURL', oppId);
            return newPage.setRedirect(true);   
        }
    }
}