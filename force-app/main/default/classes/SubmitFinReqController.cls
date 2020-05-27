public class SubmitFinReqController {
    
    public Financial_Request__c f { get; set; }
    public LiveChatTranscript currentChatTranscript { get; set; }
    public Id currentRecordId { get; set; }
    public Id recordTypeId { get; set; }
    
    public String Name { get; set; }
    public String FirstName { get; set; }
    public String LastName { get; set; }
    public String Email { get; set; }
    public String Query { get; set; }
    public String Subject { get; set; }
    public String Region { get; set; }
    
    public String returnId { get; set; }
    
    
    public SubmitFinReqController() {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        f = new Financial_Request__c();
    }
 
    // submitFinReq Method for external FinReq creation from Missed Chat
    public PageReference submitFinReq() {
    
        recordTypeId = Schema.SObjectType.Financial_Request__c.getRecordTypeInfosByName().get('PGi-Billing Support').getRecordTypeId();
    
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
    
    // init Method for internal FinReq escalation from Live Chat
    public  void init(){
        recordTypeId = Schema.SObjectType.Financial_Request__c.getRecordTypeInfosByName().get('PGi-Billing Support').getRecordTypeId();
        
        currentChatTranscript = [SELECT ID, Email_Address__c, Subject__c, First_Name__c, Last_Name__c, Escalated_FinReq__c, Location_Country_Code__c, Location_Region__c
             FROM LiveChatTranscript 
             WHERE Id =: currentRecordId limit 1];
             
             FirstName = currentChatTranscript.First_Name__c;
             LastName = currentChatTranscript.Last_Name__c;
             Name = FirstName + ' ' + LastName;
             Subject = 'Billing Query from' + ' ' + Name;
             Email = currentChatTranscript.Email_Address__c;  
             Region = currentChatTranscript.Location_Region__c;
             
             if (!( (new List<String>{'EMEA','NA','APAC - North','APAC - South','India'}).contains(Region) )){
                   //if no valid region, default region to NA
                   Region = 'NA';
             }
    }
    
      public List<SelectOption> getRegions(){
          List<SelectOption> options = new List<SelectOption>();
            
          Schema.DescribeFieldResult fieldResult = Financial_Request__c.Region__c.getDescribe();
          List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
          for( Schema.PicklistEntry p : ple)
          {
              options.add(new SelectOption(p.getLabel(), p.getValue()));
          }       
          return options;
      }
    
    
        // submitEscalatedFinReq Method for internal FinReq escalation by Agent from Live Chat
    public PageReference submitEscalatedFinReq() {   
    
            try {
                f.Requested_For__c = Email;
                f.RequestorsEmail__c = Email;
                f.Internal_Comments__c = Query;     
                f.Subject__c = Subject;    
                f.Region__c = Region;
                f.Origin__c = 'Chat';
                f.RecordTypeId = recordTypeId;
                INSERT f;
                currentChatTranscript.Financial_Request__c = f.Id;
                currentChatTranscript.Escalated_FinReq__c = true;
                UPDATE currentChatTranscript;
                
                returnId = f.Id;
                PageReference retURL = new PageReference('/apex/ChatEscalateLandingPage?recordId=' + returnId + '&recordType=FinReq');
                retURL.setRedirect(true);
                return retURL;
            } catch (Exception e) {
                ApexPages.addMessages(e);
                return null;
            }
    }
}