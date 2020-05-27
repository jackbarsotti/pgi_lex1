public class SubmitMMHFinReqController {
    
    public Financial_Request__c f { get; set; }
    public String Name { get; set; }
    public String Email { get; set; }
    public String ClientId { get; set; }
    public String CompanyName { get; set; }
    public String Region { get; set; }
    public String InvoiceNum { get; set; }
    public String Query { get; set; }
    
    
    public SubmitMMHFinReqController() {

        f = new Financial_Request__c();
    }
    
    public PageReference submitFinReq() {
    
        Id recordTypeId = Schema.SObjectType.Financial_Request__c.getRecordTypeInfosByName().get('PGi-Billing Support').getRecordTypeId();
        Id pgiClientLookupId;

        try {
            pgiClientLookupId = [SELECT Id FROM PGi_Client__c WHERE Name = :ClientId LIMIT 1].Id;
        }
        catch (Exception e) {
            pgiClientLookupId = null;
        }

        try {
            f.Priority__c = '2 - High';
            f.Type__c = 'Other';
            f.RecordTypeId = recordTypeId;
            f.Origin__c = 'Submission';
            f.Subject__c = 'Support Site Submission from ' + Name;
            f.Requested_For__c = Email;
            f.RequestorsEmail__c = Email;
            f.Bill_To_Client__c = pgiClientLookupId;
            f.Region__c = Region;
            f.CaseDescription__c = 'Client ID: ' + ClientId + '\nCompany Name: ' + CompanyName + '\nInvoice Number: ' + InvoiceNum + '\n\nQuery: ' + Query;
            INSERT f;
            PageReference retURL = new PageReference('/MMH_SubmitFinReq_Success');
            retURL.setRedirect(true);
            return retURL;
        } catch (Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
    }
}