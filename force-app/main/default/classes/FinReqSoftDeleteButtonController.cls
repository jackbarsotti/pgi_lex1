public with sharing class FinReqSoftDeleteButtonController {
    public String finReqId {get; set;}
    public FinReqSoftDeleteButtonController() {
        if (System.currentPageReference().getParameters().get('finReqId') != null){
            finReqId = System.currentPageReference().getParameters().get('finReqId');
        }        
    }
    public PageReference assignItToQueue(){
        
        String queueId = [SELECT Id FROM Group WHERE Type ='Queue' AND DeveloperName = 'Junk_Spam_Placeholder' Limit 1].Id;
        //if(queueId == nu)
        Financial_Request__c objFinReq = [SELECT Id, OwnerId, Assigned_To__c FROM Financial_Request__c WHERE Id =: finReqId Limit 1];
        objFinReq.OwnerId = queueId;
        objFinReq.Assigned_To__c = null; 
        UPDATE objFinReq;
        String UITheme  = UserInfo.getUiThemeDisplayed();
        String navigationURL = '';
        if(UITheme == 'Theme4d' || UITheme == 'Theme4t' || UITheme == 'Theme4u'){
            navigationURL = '/lightning/r/Case/'+objFinReq.Id+'/view';
        }else{
            navigationURL = '/'+objFinReq.Id;
        }
        PageReference pageRef = new PageReference(navigationURL);
        pageRef.setRedirect(true);
        return pageRef;
    }
}