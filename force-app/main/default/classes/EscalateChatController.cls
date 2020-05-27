/* Class Name : EscalateChatController
 */
public class EscalateChatController {
    public  String selectedEscalationType {get; set;}
    public  String selectedEscalationRecordType {get; set;}
    public  Boolean isContinue{get; set;}
    public  string currentRecordId {get; set;}
    //public  Boolean isEscalated{get; set;}
    public  Boolean isEscalatedToCase{get; set;}
    public  Boolean isEscalatedToFinReq{get; set;}
    public  Boolean isEscalatedToLead{get; set;}
    public  Boolean multipleLeadRecordsFound {get;set;}
    public  String returnId {get;set;}
    public  String currentUserProfile {get;set;}
    
    /* Method Name : EscalateChatController
    *  Description : Constructor method to initialise the fields
    */
    public EscalateChatController(ApexPages.StandardController controller) {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        isContinue = true;
        selectedEscalationType ='';
        selectedEscalationRecordType='';
    }
    
    /* Method Name : init
    *  Description : This method will be called when the vf page loads
    */
    public  void init(){
        System.debug('000000>>'+currentRecordId);
        LiveChatTranscript temp = [SELECT Id, Escalated__c, Escalated_FinReq__c, Escalated_Lead__c, Multiple_Lead_Records_Found__c, CurrentUserProfile__c
                            FROM LiveChatTranscript 
                            WHERE Id =: currentRecordId limit 1];
        isEscalatedToCase = temp.Escalated__c;
        isEscalatedToFinReq = temp.Escalated_FinReq__c;
        isEscalatedToLead = temp.Escalated_Lead__c;
        currentUserProfile = temp.CurrentUserProfile__c;
        multipleLeadRecordsFound = temp.Multiple_Lead_Records_Found__c;

        if(isEscalatedToCase) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This Chat has already been escalated to a Case, please view the related Case for further actions.'));
        }
        if(isEscalatedToFinReq) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This Chat has already been escalated to a FinReq, please view the related FinReq for further actions.'));
        }
        if(isEscalatedToLead && multipleLeadRecordsFound && currentUserProfile.contains('Sales')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This Chat cannot escalated to a Lead as multiple Lead records exist for this chat visitor. Please search the Email Address to locate the correct Lead.'));
        }
        else if(isEscalatedToLead && currentUserProfile.contains('Sales')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This Chat has already been escalated to a Lead or there is an existing Lead or Contact for this chat visitor. Please view the related Lead or Contact for further actions.'));
        }
        else if(isEscalatedToLead && multipleLeadRecordsFound && !currentUserProfile.contains('Sales')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This chat cannot be escalated to a Lead as multiple Lead records exist for this client. If the chat included a Sales query and you have confirmed this is not an existing customer, please refer to the PGiKnow article “Completing a Sales Lead Tracker” to submit the query to the Sales team.'));
        }
        else if(isEscalatedToLead && !currentUserProfile.contains('Sales')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This chat cannot be escalated to a Lead as there is an existing Contact or Lead record for this client. A notification has been sent to the Sales team and no further action is needed to escalate this Chat to a Lead.'));
        }
    }


    /* Method Name : getEscalationType
    *  Description : Assigning Escalation type to the select box
    */
    public  List<SelectOption> getEscalationType() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        if (!(isEscalatedToCase) && !(currentUserProfile.contains('Sales'))) {
            options.add(new SelectOption('Case','Case'));
        }
        if (!(isEscalatedToFinReq) && !(currentUserProfile.contains('Sales'))) {
            options.add(new SelectOption('Financial_Request__c','FinReq'));
        }
        if (!(isEscalatedToLead)) {
            options.add(new SelectOption('Lead','Lead'));
        }
        
        return options;
    }
    /* Method Name : handleRecordButton
    *  Description : 
    */
    public  void handleRecordButton(){
        isContinue = false;
    }
    /* Method Name : handleRecord
    *  Description : The record will be created based on the selected escalation type and record type
    */
    public void handleRecord(){
        System.debug('Id->'+currentRecordId);
        isContinue = true;  
        Id recordTypeId = [SELECT Id FROM RecordType WHERE name LIKE : ('%' + selectedEscalationRecordType + '%') and SobjectType =: selectedEscalationType limit 1].Id;
        LiveChatTranscript currentChatTranscript = [SELECT ID, PGi_Client__c,Email_Address__c, PGi_Company__c, ContactId, Subject__c, First_Name__c, Last_Name__c, Name__c, Escalated__c, Escalated_FinReq__c, Escalated_Lead__c, Region__c, Origin__c, Location_Country_Code__c, Location_Region__c, Company_Name__c
                            FROM LiveChatTranscript 
                            WHERE Id =: currentRecordId limit 1];
        
            if (currentChatTranscript.Origin__c == null || currentChatTranscript.Origin__c == '' || currentChatTranscript.Origin__c == 'undefined') {
                currentChatTranscript.Origin__c = 'Chat';
            }
            
            if(selectedEscalationType == 'Case'){

                //check if already escalated to Case
                isEscalatedToCase = currentChatTranscript.Escalated__c;
                if (isEscalatedToCase) {
                    returnId = 'none';
                }
                
                else{
                    Case escalatedCase = new Case(Origin = currentChatTranscript.Origin__c, 
                                            recordTypeId = recordTypeId,
                                            PGi_Client__c = currentChatTranscript.PGi_Client__c,
                                            PGi_Company__c = currentChatTranscript.PGi_Company__c,
                                            Follow_Up_Email_Address__c = currentChatTranscript.Email_Address__c,
                                            Subject = currentChatTranscript.Subject__c,
                                            Caller_Name__c = currentChatTranscript.Name__c);
                        // STRAT RT-473: Automatically run assignment rules for the new Case created.
                        Database.DMLOptions dmo = new Database.DMLOptions();
                        dmo.assignmentRuleHeader.useDefaultRule = true;
                        escalatedCase.setOptions(dmo);
                         // STRAT END
                        INSERT escalatedCase;
                        currentChatTranscript.Escalated__c = true;
                        currentChatTranscript.CaseId = escalatedCase.Id;
                        UPDATE currentChatTranscript;
                        returnId = escalatedCase.Id;
                }
           }
           
           else if(selectedEscalationType == 'Financial_Request__c'){  
               //FinReq escalation logic now handled by Chat_SubmitEscalatedFinReq VF page
               /*
               //check if already escalated to FinReq
                isEscalatedToFinReq = currentChatTranscript.Escalated_FinReq__c;
                if (isEscalatedToFinReq) {
                    returnId = 'none';
                }
                
                else{    

                    if (!( (new List<String>{'EMEA','NA','APAC - North','APAC - South','India'}).contains(currentChatTranscript.Location_Region__c) )){
                        //if no valid region, default region to NA
                        currentChatTranscript.Location_Region__c = 'NA';
                    }
                   
                    Financial_Request__c escalatedFinReq = new Financial_Request__c(
                                            recordTypeId = recordTypeId,
                                            PGi_Client__c = currentChatTranscript.PGi_Client__c,
                                            PGi_Company__c = currentChatTranscript.PGi_Company__c,
                                            SuppliedEmail__c = currentChatTranscript.Email_Address__c,
                                            Requested_For__c = currentChatTranscript.Email_Address__c,
                                            RequestorsEmail__c = currentChatTranscript.Email_Address__c,
                                            Subject__c = currentChatTranscript.Subject__c,
                                            Region__c = currentChatTranscript.Location_Region__c,
                                            Origin__c = 'Chat',
                                            Type__c = 'Other');
                                                    
                    INSERT escalatedFinReq;
                    currentChatTranscript.Financial_Request__c = escalatedFinReq.Id;
                    currentChatTranscript.Escalated_FinReq__c = true;
                    UPDATE currentChatTranscript;
                    returnId = escalatedFinReq.Id;
               }
               */
               returnId = 'none';
        }
        
        else if(selectedEscalationType == 'Lead'){
           //Lead escalation logic now handled by Chat_SubmitLead VF page
           /*     if (currentChatTranscript.Location_Country_Code__c == '' || currentChatTranscript.Location_Country_Code__c == 'undefined' || currentChatTranscript.Location_Country_Code__c == null ){
                        //if null or invalid country code, default to US
                        currentChatTranscript.Location_Country_Code__c = 'US';
                }
                
                if (currentChatTranscript.Company_Name__c == '' || currentChatTranscript.Company_Name__c == 'undefined' || currentChatTranscript.Company_Name__c == null){      
                    currentChatTranscript.Company_Name__c = 'Unknown';
                }
                
                if (currentChatTranscript.First_Name__c == '' || currentChatTranscript.First_Name__c == 'undefined' || currentChatTranscript.First_Name__c == null){        
                    currentChatTranscript.First_Name__c = 'Unknown';
                }
                
                if (currentChatTranscript.Last_Name__c == '' || currentChatTranscript.Last_Name__c == 'undefined' || currentChatTranscript.Last_Name__c == null){       
                    currentChatTranscript.Last_Name__c = 'Unknown';
                }
                
                //only allow Sales users to create Lead
                if (currentUserProfile.contains('Sales')) {
                
                    Lead escalatedLead = new Lead(
                                            recordTypeId = recordTypeId,
                                            Status = 'Assigned',
                                            CurrencyISOCode = 'USD',
                                            Company = currentChatTranscript.Company_Name__c,
                                            Email = currentChatTranscript.Email_Address__c,
                                            FirstName = currentChatTranscript.First_Name__c,
                                            LastName = currentChatTranscript.Last_Name__c,
                                            CountryCode = currentChatTranscript.Location_Country_Code__c,
                                            LeadSource = 'Web Chat');
                                                    
                    INSERT escalatedLead;
                    currentChatTranscript.LeadId = escalatedLead.Id;
                    currentChatTranscript.Escalated_Lead__c = true;
                    UPDATE currentChatTranscript;
                    returnId = escalatedLead.Id;
                }
          */      
          //      else returnId = 'none';
          returnId = 'none';
            
        }
    }
    
    /* Method Name : getEscalationRecordType
    *  Description : Assigning Escalation record type to the select box
    */
    public List<SelectOption> getEscalationRecordType() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        if(selectedEscalationType!='null' && selectedEscalationType != '' && selectedEscalationType != 'undefined'){
            if(selectedEscalationType == 'Case'){
                options.add(new SelectOption('Client External Support','Client External Support'));
                //return options;
            }
            else if(selectedEscalationType == 'Financial_Request__c'){
                options.add(new SelectOption('Billing Support','Billing Support'));
                //options.add(new SelectOption('Company Credit','Company Credit'));
                //options.add(new SelectOption('Payment Research Request','Payment Research Request'));
                //options.add(new SelectOption('Credit Request','Credit Request'));
                //options.add(new SelectOption('Pricing Help Request','Pricing Help Request'));
                //options.add(new SelectOption('Profile Request','Profile Request'));
                //options.add(new SelectOption('Rate Entry Request','Rate Entry Request'));
                //options.add(new SelectOption('Request for Adjustment','Request for Adjustment'));
                //options.add(new SelectOption('Revenue Assurance Audit Request','Revenue Assurance Audit Request'));
                //return options;
            }
            else if(selectedEscalationType == 'Lead'){
                options.add(new SelectOption('PGi Lead','PGi Leads'));
                //return options;
            }
        }
        
        if (options.size() == 2) {      //if only 2 options exist including the "none" option, default to the valid option
            options.remove(0);      //remove the "none" option
            isContinue = false;         //enable the continue button
        }
        
        return options;
    }  
}