public without sharing class ChatTranscriptTriggerHandler extends TriggerHandler {

    protected override void beforeInsert() {
        updateRelatedFields();
        updateRegionFields();
        updateGMDescription();
    }

    protected override void beforeUpdate() {
        updateRelatedFields();
        updateRegionFields();
        updateGMDescription();
    }
    
    protected override void afterInsert() {
        updateLinkedRecordDescription();
        mergeRecordsToExistingContactLead();
    }
    
    protected override void afterUpdate() {
        updateLinkedRecordDescription();
        mergeRecordsToExistingContactLead();
    }
    
    private void updateLinkedRecordDescription() {
        for (LiveChatTranscript chatTranscript :(List<LiveChatTranscript>) trigger.new) {
        if(chatTranscript.Body != null) {
            String strippedChatTranscriptBody = chatTranscript.Body.replaceAll('</p>', '</p><br>').unescapeHtml4().stripHtmlTags();

            if(chatTranscript.CaseId != null) {
                Case linkedCase = [SELECT Description, RecordTypeId FROM Case WHERE Id = :chatTranscript.CaseId];
                if(linkedCase.RecordTypeId == [SELECT Id FROM RecordType WHERE name LIKE '%Inbound Email Support%' and SobjectType = 'Case' LIMIT 1].Id) {
                    linkedCase.Description = strippedChatTranscriptBody;
                    UPDATE linkedCase;

                    String fromEmail;
                    switch on chatTranscript.Query_Topic__c {
                        when 'Web or Audio Meetings' {
                            fromEmail = 'support@mymeetingroom.com';
                        }
                        when 'Business Phone Systems' {
                            fromEmail = 'support@mymeetingroom.com';
                        }
                        when 'Operator Assisted Events' {
                            fromEmail = 'reservations@mymeetingroom.com';
                        }
                        when 'Sales' {
                            fromEmail = 'support@mymeetingroom.com';
                        }
                    }

                    EmailMessage newEmail = new EmailMessage(
                        Incoming = true,
                        FromAddress = chatTranscript.Email_Address__c,
                        FromName = chatTranscript.Name__c,
                        ToAddress = fromEmail,
                        Subject = chatTranscript.Subject__c,
                        HtmlBody = chatTranscript.Body,
                        ParentId = chatTranscript.CaseId
                    );
                    INSERT newEmail;
                }
            }
            
            if(chatTranscript.Financial_Request__c != null) {
                Financial_Request__c linkedFinReq = [SELECT CaseDescription__c FROM Financial_Request__c WHERE Id = :chatTranscript.Financial_Request__c];
                linkedFinReq.CaseDescription__c = strippedChatTranscriptBody;
                UPDATE linkedFinReq;
            }
        }
    }
    }
    
    
    
    private void updateRegionFields() {
        List<LiveChatTranscript> ctList = new List<LiveChatTranscript>();
        
        //add transcripts IDs in the current trigger to the list  
        for (LiveChatTranscript ct:(List<LiveChatTranscript>) trigger.new){  
        
            if(ct.Location != null && ct.Location != '') {          
                ctList.add(ct);
            }
        }
        
        for (LiveChatTranscript ct_new : ctList){    
            String location = ct_new.Location;
            String country;
            String[] location_values = location.split(',');
            if (location_values[2].length() > 0) {
                country = location_values[2];
                ct_new.Location_Country__c = country;
            }
        }
    }

    //parse GM Description string from In Product chats
    private void updateGMDescription(){

          List<LiveChatTranscript> ctList = new List<LiveChatTranscript>();
        
          //add transcripts IDs in the current trigger to the list  
          for (LiveChatTranscript ct:(List<LiveChatTranscript>) trigger.new){  
      
              //only process transcripts with non-null GM_Description
              if(ct.GM_Description__c != null && ct.GM_Description__c != '') {          
                  ctList.add(ct);
              }
          }
         
         for (LiveChatTranscript ct_new : ctList){    
            String GM_Description = ct_new.GM_Description__c;
            GM_Description = GM_Description.substring(1, GM_Description.length()-1);
            String[] values = GM_Description.split(',');
            GM_Description = String.join(values,'\n');
            ct_new.GM_Description__c = GM_Description;
         }
    }

    //lookup PGi Client based on email address, lookup Case number based on case number entered by client
    private void updateRelatedFields() {

     List<LiveChatTranscript> ctList = new List<LiveChatTranscript>();
     List<PGi_Client__c> clientList = new List<PGi_Client__c>();
     List<Case> caseList = new List<Case>();
     List<Contact> contactList = new List<Contact>();
     List<Lead> leadList = new List<Lead>();
     
     List<string> caseNumbers = new List<string>();
     List<string> emailList = new List<string>();
     
     Map<string, Case> mapOfCaseByCaseNum = new Map<string, Case>();
     Map<string, PGi_Client__c> mapOfClientByEmail = new Map<string, PGi_Client__c>();
     Map<string, Contact> mapOfContactByEmail = new Map<string, Contact>();
     Map<string, Lead> mapOfLeadByEmail = new Map<string, Lead>();
     
     for (LiveChatTranscript ct:(List<LiveChatTranscript>) trigger.new){
        if(ct.Case_Number__c != null) {
            caseNumbers.add(ct.Case_Number__c);
        }
        if(ct.Email_Address__c != null){
            emailList.add(ct.Email_Address__c);
        }
     }

    caseList = [Select Id, CaseNumber from Case WHERE Case.CaseNumber IN : caseNumbers LIMIT 100];
    clientList = [Select Id, Client_Email__c, PGi_Company__c from PGi_Client__c WHERE PGi_Client__c.Client_Email__c IN : emailList LIMIT 100];
    contactList = [Select Id, Email, AccountId from Contact WHERE Contact.Email IN : emailList LIMIT 100];
    leadList = [Select Id, Email, Account__c from Lead WHERE Lead.Email IN : emailList LIMIT 100];
     
    if (caseList.size() > 0) {
        for (Case c : caseList){
            mapOfCaseByCaseNum.put(c.CaseNumber, c);
        }
    }

    if (clientList.size() > 0) {
        for (PGi_Client__c cli : clientList){
            mapOfClientByEmail.put(cli.Client_Email__c, cli);
        }
    }
    
    if (contactList.size() > 0) {
        for (Contact con : contactList){
            mapOfContactByEmail.put(con.Email, con);
        }
    }
    
    if (leadList.size() > 0) {
        for (Lead ld : leadList){
            mapOfLeadByEmail.put(ld.Email, ld);
        }
    }

    if (caseList.size() > 0 || clientList.size() > 0 || contactList.size() > 0 || LeadList.size() > 0) {
        for (LiveChatTranscript ct_new :(List<LiveChatTranscript>) trigger.new){
            if (mapOfCaseByCaseNum.containsKey(ct_new.Case_Number__c)){
                Case c = mapOfCaseByCaseNum.get(ct_new.Case_Number__c);
                ct_new.CaseId = c.Id;
                ct_new.Escalated__c = true;
            }
            if (mapOfClientByEmail.containsKey(ct_new.Email_Address__c)){
                PGi_Client__c clt = mapOfClientByEmail.get(ct_new.Email_Address__c);
                
                List<PGi_Client__c> relatedClients = new List<PGi_Client__c>();
                relatedClients = [SELECT Id FROM PGi_Client__c WHERE Client_Email__c =: ct_new.Email_Address__c LIMIT 2];
                
                if (relatedClients.size() == 1){
                    ct_new.PGi_Client__c = clt.Id;
                    if(clt.PGi_Company__c != null){
                        ct_new.PGi_Company__c = clt.PGi_Company__c;
                    }
                }
                else if (relatedClients.size() > 1){
                    ct_new.Multiple_Client_Records_Found__c = true;
                }
            }
            if (mapOfContactByEmail.containsKey(ct_new.Email_Address__c)){
                Contact cnt = mapOfContactByEmail.get(ct_new.Email_Address__c);
                ct_new.ContactId = cnt.Id;
                ct_new.Escalated_Lead__c = true;
                if(cnt.AccountId != null){
                    ct_new.Account__c = cnt.AccountId;
                }
            }
            if (mapOfLeadByEmail.containsKey(ct_new.Email_Address__c)){
                Lead  led = mapOfLeadByEmail.get(ct_new.Email_Address__c);
                if(led != null) {   
                    List<Lead> relatedLeads = new List<Lead>();
                    relatedLeads = [SELECT Id FROM Lead WHERE Email =: ct_new.Email_Address__c LIMIT 2];
                    //if only 1 lead record is found with the email address
                    if (relatedLeads.size() == 1){
                        //only populate the LeadId if there is no related Contact record
                        if (ct_new.ContactId == null) {
                            ct_new.LeadId = led.Id;
                            ct_new.Escalated_Lead__c = true;
                            if(led.Account__c != null){
                                ct_new.Account__c = led.Account__c;
                            }
                        }
                    }
                    //if more than 1 lead record is found with the same email address
                    else if (relatedLeads.size() > 1){
                        ct_new.Multiple_Lead_Records_Found__c = true;
                        ct_new.Escalated_Lead__c = true;
                    }                   
                }
            }
        }
    }  
  }
  
  private void mergeRecordsToExistingContactLead(){
    List<Contact> contactList = new List<Contact>();
    List<Lead> leadList = new List<Lead>();
    List<string> emailList = new List<string>();
    Map<string, Contact> mapOfContactByEmail = new Map<string, Contact>();
    Map<string, Lead> mapOfLeadByEmail = new Map<string, Lead>();

    for (LiveChatTranscript ct:(List<LiveChatTranscript>) trigger.new){
        if(ct.Email_Address__c != null){
            emailList.add(ct.Email_Address__c);
        }
     }
    Id contactOwner = [select Id, Name from Group where  Type = 'Queue' And Name = 'Sales Operations Support'].Id;  
    for(contact con : [Select Id, Email, OwnerId, Owner.IsActive, Global_Contact_MQL__c, Lead_Source_Most_Recent__c
                        FROM Contact WHERE Contact.Email IN : emailList LIMIT 1000]){
        if(!con.Owner.IsActive && con.OwnerId == null){
            con.OwnerId = contactOwner;
        }
        con.Lead_Source_Most_Recent__c = 'Web Chat';
        con.Global_Contact_MQL__c = true;
        contactList.add(con);
    }
    // Set<Id> proFileIdSet = new Set<Id>();
    // for(Profile pfObj :[SELECT id From Profile Where Name = 'PGi Sales User' OR Name = 'SalesforceIQ Integration User' OR Name = 'ChatCustomPage Profile']){
    //     proFileIdSet.add(pfObj.Id);
    // }
    Id currentUserProfileId = userinfo.getProfileId();
    for(Lead leadObj : [Select Id, Email, OwnerId, Owner.IsActive, Global_MQL__c, Lead_Source_Most_Recent__c,Status,Janati_RR__Round_Robin__c
                        FROM Lead WHERE Lead.Email IN : emailList LIMIT 1000]){
        if(!leadObj.Owner.IsActive && leadObj.OwnerId == null){
            leadObj.Status = 'Assigned';
            leadObj.Janati_RR__Round_Robin__c = 'Yes';
        }
        //automated process user has a null profile
        // if(proFileIdSet.contains(currentUserProfileId) || currentUserProfileId == null){ 
        leadObj.Global_MQL__c = true;
        // }
        leadObj.Lead_Source_Most_Recent__c = 'Web Chat';
        leadList.add(leadObj);
    }
    if(contactList.size() > 0){
        Database.update(contactList, false);
    }
    if(leadList.size() > 0){
        Database.update(leadList, false);
    }
  }
}