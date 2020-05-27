public class SubmitLeadController {
    
    public  Lead l { get; set; }
    public  LiveChatTranscript currentChatTranscript { get; set; }
    public  Id currentRecordId {get; set;}
    public  Id recordTypeId {get; set;}
    
    public String FirstName { get; set; }
    public String LastName { get; set; }
    public String Company { get; set; }
    public String Email { get; set; }
    public String Description { get; set; }
    public String Phone { get; set; }
    
    public  String returnId {get;set;}
    public  String returnRecordType {get;set;}

    
    public SubmitLeadController() {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');    
        l = new Lead();    
    }
    
    public  void init(){
        recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('PGi Leads').getRecordTypeId();
        
        currentChatTranscript = [SELECT ID, Email_Address__c, Subject__c, First_Name__c, Last_Name__c, Escalated_Lead__c, Location_Country_Code__c, Location_Region__c, Company_Name__c
             FROM LiveChatTranscript 
             WHERE Id =: currentRecordId limit 1];
             
             l.Company = currentChatTranscript.Company_Name__c;
             l.Email = currentChatTranscript.Email_Address__c;
             FirstName = currentChatTranscript.First_Name__c;
             LastName = currentChatTranscript.Last_Name__c;
             Company = currentChatTranscript.Company_Name__c;
             Email = currentChatTranscript.Email_Address__c;          
    }
    
    public PageReference submitLead() {
            try {
                l.recordTypeId = recordTypeId;
                l.Status = 'Assigned';
                l.CurrencyISOCode = 'USD';
                l.CountryCode = currentChatTranscript.Location_Country_Code__c;
                l.LeadSource = 'Web Chat';
                
                l.FirstName = FirstName;
                l.LastName = LastName;
                l.Email = Email;
                l.Company = Company;
                l.Description = Description;
                l.Phone = Phone;
                
                INSERT l;
                currentChatTranscript.LeadId = l.Id;
                currentChatTranscript.Escalated_Lead__c = true;
                UPDATE currentChatTranscript;
                returnId = l.Id;
                
                String currentURL = ApexPages.currentPage().getUrl();
                PageReference retURL;
                if (currentURL.indexOf('chatcustompage') != -1){
                    retURL = new PageReference('/ChatEscalateLandingPage');
                }
                else retURL = new PageReference('/apex/ChatEscalateLandingPage?recordId=' + returnId + '&recordType=Lead');
                retURL.setRedirect(true);
                return retURL;
            } catch (Exception e) {
                ApexPages.addMessages(e);
                return null;
            }
    }
    
}