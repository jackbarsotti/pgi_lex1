public class SubmitFinReqController {
    
    public Financial_Request__c f { get; set; }
    public String Name { get; set; }
    public String Email { get; set; }
    public String Query { get; set; }
    public String Region { get; set; }
    
    
    public SubmitFinReqController() {

        f = new Financial_Request__c();
    }
    
    public PageReference submitFinReq() {
    
        Id recordTypeId = Schema.SObjectType.Financial_Request__c.getRecordTypeInfosByName().get('PGi-Billing Support').getRecordTypeId();
    
            try {
                f.Subject__c = 'Missed chat from ' + Name;
                f.Requested_For__c = Email;
                f.RequestorsEmail__c = Email;
                f.CaseDescription__c = Query;
                f.Region__c = Region;
                f.RecordTypeId = recordTypeId;
                INSERT f;
                PageReference retURL = new PageReference('/ChatLandingPage' + '?origin=web');
                retURL.setRedirect(true);
                return retURL;
            } catch (Exception e) {
                ApexPages.addMessages(e);
                return null;
            }
    }
}