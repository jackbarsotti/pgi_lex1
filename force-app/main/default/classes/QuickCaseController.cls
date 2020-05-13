public without sharing class QuickCaseController {
	public QuickCaseController() {
		Id recordTyId;
		if(ApexPages.currentPage().getParameters().get('RecordType') != null) {
			recordTyId = ApexPages.currentPage().getParameters().get('RecordType');
		}
		if(recordTyId != null) {
			caseTemplates =[SELECT Id, Name, Name__c, Description__c, RecordType__c FROM Case_Template__c WHERE RecordType__c =: recordTyId ORDER BY Name__c ];
		} else {
			caseTemplates =[SELECT Id, Name, Name__c, Description__c, RecordType__c FROM Case_Template__c ORDER BY Name__c];
		}
		
		targetBase = '/apex/CreateCase?ent=Case&save_new=1&QuickCase=';

	}
	public QuickCaseController(ApexPages.StandardController controller) {
		Id recordTyId;
		if(ApexPages.currentPage().getParameters().get('RecordType') != null) {
			recordTyId = ApexPages.currentPage().getParameters().get('RecordType');
		}
		if(recordTyId != null) {
			caseTemplates =[SELECT Id, Name, Name__c, Description__c, RecordType__c FROM Case_Template__c WHERE RecordType__c =: recordTyId ORDER BY Name__c ];
		} else {
			caseTemplates =[SELECT Id, Name, Name__c, Description__c, RecordType__c FROM Case_Template__c ORDER BY Name__c];
		}
		
		targetBase = '/apex/CreateCase?ent=Case&save_new=1&QuickCase=';
	}
	public List<Case_Template__c> caseTemplates {get; set;}
	public String targetBase {get; set;}
	public List<SelectOption> caseTemplateSelectList {get {
		List<SelectOption> selectList = new List<SelectOption>();
		selectList.add(new SelectOption('', '--None--'));
		for(Case_Template__c ct: caseTemplates) {
			selectList.add(new SelectOption(ct.Name, ct.Name__c));
		}
		return selectList;
	}}
}