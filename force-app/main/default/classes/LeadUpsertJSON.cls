@RestResource(urlMapping='/LeadUpsertJSON/*')
global with sharing class LeadUpsertJSON {
    global class LeadRequest{
       public  String leadId;
       public  String FirstName;
        public String LastName;
        public String Phone;
        public String Email;
        public String ECommerceAccountNumber;
        public Boolean ECommerceConvert;
        public String LeadSource;
        public String Company;
        public String Status;
        public String Street;
        public String City;
        public String State;
        public String PostalCode;
        public String Country;
        public Integer BusinessType;
        public Boolean DoNotSolicit;
        public String CompanyID;
        public String ProductOfInterest;
        public string Department;
        //public string Topic;
    }

    global class LeadResponse{
        String errorMessage;
        String leadId;
        String accountId;
        String contactId;
        String opportunityId;
    }
    
    @HttpPut
    global static LeadResponse upsertLeadJSON(){
       
        LeadRequest ldReq =  (LeadRequest)JSON.deserializestrict(
                        RestContext.request.requestbody.tostring(),LeadRequest.class);
        Lead ld = setLeadRecord(ldReq);
        upsert ld;
        //Savepoint sp = Database.setSavepoint();
        
        
        LeadUpsertJSON.LeadResponse resp = new LeadUpsertJSON.LeadResponse();
        ld = [select id, convertedaccountid, convertedcontactid, convertedopportunityid from lead where id = :ld.id];
        resp.leadid = ld.id;
        resp.accountId = ld.convertedaccountid;
        resp.contactId = ld.convertedContactid;
        resp.opportunityId = ld.convertedopportunityid;
        system.debug('resp: ' + resp);
        
       return resp;
    }
   
    public static lead setLeadRecord(LeadUpsertJSON.LeadRequest ldReq){
          
       String leadRecordTypeId = [Select Id From RecordType Where SobjectType = 'Lead' and Name LIKE '%PGi%'].Id;   
          
       Lead ld = new Lead();      
       ld.FirstName = ldReq.FirstName;
       ld.Id = ldReq.leadId;
       ld.LastName = ldReq.LastName;
       ld.Phone = ldReq.Phone;
       ld.Email = ldReq.Email;
       ld.ECommerce_Account_Number__c = ldReq.ECommerceAccountNumber;
       ld.ECommerce_Convert__c = ldReq.ECommerceConvert;
       ld.LeadSource = ldReq.LeadSource;
       ld.Company = ldReq.Company;
       ld.Status = ldReq.Status;
       ld.Street = ldReq.Street;
       ld.City = ldReq.City ;
       ld.State = ldReq.State;
       ld.PostalCode = ldReq.PostalCode ;
       ld.Country = ldReq.Country ;
       system.debug('country:'+ld.Country);
       ld.Business_Type__c= ldReq.BusinessType;
       ld.DoNotSolicit__c = ldReq.DoNotSolicit;
       ld.Product_Interest__c = ldReq.ProductOfInterest;
       ld.recordtypeid = leadRecordTypeId;
       ld.z_Source__c = Label.Default_Z_Source;
       ld.Department__c = ldreq.Department;
       //ld.Topic__c = ldreq.Topic;
       
       return ld;
    }
}