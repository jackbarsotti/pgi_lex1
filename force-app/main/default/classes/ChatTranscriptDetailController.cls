public without sharing class ChatTranscriptDetailController {

public LiveChatTranscript lct {get; set;}

    public ChatTranscriptDetailController(ApexPages.StandardController controller) {
        lct = (LiveChatTranscript)controller.getRecord();
    }
    public pageReference Redirecttocase(){
        PageReference p = new PageReference('/apex/CaseTabViewer');
                        p.getParameters().put('id', ApexPages.CurrentPage().getparameters().get('caseId'));
                        p.getParameters().put('isNew', 'true');
                        p.setRedirect(true);
                        return p;
    }
    
    public pageReference updatePage(){
    
        LiveChatTranscript temp = [SELECT CaseId, Financial_Request__c, LeadId, Escalated__c, Escalated_FinReq__c, Escalated_Lead__c
                FROM LiveChatTranscript
                WHERE Id =:lct.Id];

        lct.CaseId = temp.CaseId;
        lct.Financial_Request__c = temp.Financial_Request__c;
        lct.LeadId = temp.LeadId;    
        lct.Escalated__c = temp.Escalated__c;
        lct.Escalated_FinReq__c = temp.Escalated_FinReq__c;
        lct.Escalated_Lead__c = temp.Escalated_Lead__c;
        update lct;
        return null;
    }
}