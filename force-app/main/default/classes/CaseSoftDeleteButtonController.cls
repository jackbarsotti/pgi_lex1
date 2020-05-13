public with sharing class CaseSoftDeleteButtonController {
	public String caseId 	{get;set;} 
	public CaseSoftDeleteButtonController() {
		if (System.currentPageReference().getParameters().get('CaseId') != null) { 
			caseId = System.currentPageReference().getParameters().get('CaseId'); 
		}
	}
	public PageReference assignItToQueue(){
		
		String queueId = [SELECT Id FROM Group WHERE Type ='Queue' AND DeveloperName = 'Junk_Spam_Placeholder' Limit 1].Id;
		//if(queueId == nu)
		Case objCase = [SELECT Id, OwnerId FROM Case WHERE Id =: caseId Limit 1];
		objCase.OwnerId = queueId; 
		UPDATE objCase;
		String UITheme  = UserInfo.getUiThemeDisplayed();
		String navigationURL = '';
		if(UITheme == 'Theme4d' || UITheme == 'Theme4t' || UITheme == 'Theme4u'){
			navigationURL = '/lightning/r/Case/'+objCase.Id+'/view';
		}else{
			navigationURL = '/'+objCase.Id;
		}
		PageReference pageRef = new PageReference(navigationURL);
		pageRef.setRedirect(true);
		return pageRef;
	}
}