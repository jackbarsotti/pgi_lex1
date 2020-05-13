@RestResource(urlMapping='/iContractStartApproval/*')
// While the class is called 'LegalApproval', this now starts the normal 'Approval'
global class iContractStartLegalApproval {
    @HttpGet
    global static String ApprovalRequest() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String contractIdRequest = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Id contractId;
        try {
            contractId = contractIdRequest;
        } catch (Exception e) {
            return 'Invalid PGi Contract ID: ' + contractIdRequest;
        }	
        
        CONMAN_Contract__c foundContract = [SELECT Id, OwnerId, Owner.Email, Owner.Name,
                                            Required_Approval_ARG__c,
                                            Required_Approval_Legal__c,
                                            Required_Approval_Pricing_RVP__c,
                                            Required_Approval_Pricing_SVP__c,
                                            Required_Approval_Deal_Desk__c,
                                            Required_Approval_Billing__c,
                                            Owners_RVP__r.Email, Owners_SVP__r.Email
                                            FROM CONMAN_Contract__c
                                            WHERE id = :contractId];

        // Simply return an 'unnecessary' message when nothing was required
        if (!foundContract.Required_Approval_Billing__c &&
            !foundContract.Required_Approval_Legal__c &&
            !foundContract.Required_Approval_Pricing_RVP__c &&
            !foundContract.Required_Approval_Pricing_SVP__c &&
            !foundContract.Required_Approval_Deal_Desk__c &&
            !foundContract.Required_Approval_ARG__c) {
                return iContract.UNNECESSARY;
            }
        
        
  //      try {
            // Start by submitting for approval
            String result = iContract.startApproval(foundContract.Id, foundContract.OwnerId);
            
        	// Send a 'skipped' email to RVP and SVP (Approval Process cannot do anything with them)
            if (result == iContract.SUCCESS &&
                foundContract.Required_Approval_Deal_Desk__c &&
                (foundContract.Required_Approval_Pricing_RVP__c || foundContract.Required_Approval_Pricing_SVP__c)) {
                    
            		// Render email
                    EmailTemplate templateId = [SELECT Id FROM EmailTemplate WHERE Name = 'iContract Submitted for Approval (Skipped)'];
                    Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId.Id, foundContract.OwnerId, foundContract.Id);
                    mail.setSenderDisplayName(foundContract.Owner.Email);
                    mail.setReplyTo(foundContract.Owner.Email);
                    List<String> emailAddresses = new List<String>();
                    if (foundContract.Required_Approval_Pricing_RVP__c)
                        emailAddresses.add(foundContract.Owners_RVP__r.Email);
                    if (foundContract.Required_Approval_Pricing_SVP__c)
                        emailAddresses.add(foundContract.Owners_SVP__r.Email);
                    mail.setToAddresses(emailAddresses);
                    mail.setSaveAsActivity(false);

            		// Send email
                    List<Messaging.SingleEmailMessage> allEmails = new List<Messaging.SingleEmailMessage>();
                    allEmails.add(mail);
                    List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(allEmails, false);
            
            		// Check for issues
            		String emailErrorMessage = '';
                    for (Messaging.SendEmailResult emailResult : emailResults) {
                        emailErrorMessage = '';
                    	for (Messaging.SendEmailError error : emailResult.getErrors())
                            emailErrorMessage += error.getMessage() + '\n';
                        if (!emailResult.isSuccess() || !String.isEmpty(emailErrorMessage))
                            System.debug('Unable to send emails: ' + emailErrorMessage);
                    }
                }
            
            return result;
     /*   } catch (Exception e) {
            return iContract.formatException(e);
        } */
    }
}