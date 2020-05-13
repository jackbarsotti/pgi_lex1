public without sharing class FinancialRequestTriggerHandler extends TriggerHandler {
	public FinancialRequestTriggerHandler() {
		super('FinancialRequestTriggerHandler');
	}
	protected override void beforeUpdate() {
        getCaseComments();
    }
    protected override void afterUpdate() {
        getCaseAttachments();
		getCaseContentDocuments();
		fireEventHandler();
    }
    protected override void beforeInsert() {
        getCaseComments();
    }
    protected override void afterInsert() {
        getCaseAttachments();
		getCaseContentDocuments();
		fireEventHandler();
    } 
    //Create new ContentDocumentLinks to the financial request
    private void getCaseComments() {

		Set<Id> casesToQuery = new Set<Id>();
		Map<Id,List<CaseComment>> caseIdtoCaseCommentMap = new Map<Id,List<CaseComment>>();

		for(Financial_Request__c objFR : (List<Financial_Request__c>)Trigger.new){
			if(isChanged('Historical_Case_Id__c', objFR) && (String.isNotBlank(objFR.Historical_Case_Id__c))) {
				casesToQuery.add(objFR.Historical_Case_Id__c);
			}
		}

		if (!casesToQuery.isEmpty()) {
			for(CaseComment caseCommentobj : [SELECT Id, ParentId, CommentBody, CreatedDate, CreatedBy.Name
							   FROM CaseComment 
							   WHERE ParentId IN :casesToQuery]){ 
                if(caseIdtoCaseCommentMap.containsKey(caseCommentobj.ParentId)) {
                    List<CaseComment> caseCommtsList = caseIdtoCaseCommentMap.get(caseCommentobj.ParentId);
                    caseCommtsList.add(caseCommentobj);
                    caseIdtoCaseCommentMap.put(caseCommentobj.ParentId, caseCommtsList);
                }else{
                    caseIdtoCaseCommentMap.put(caseCommentobj.ParentId, new List<CaseComment> { caseCommentobj });
                }
			}

			
			if(!caseIdtoCaseCommentMap.isEmpty()){    
	            for(Financial_Request__c objFR : (List<Financial_Request__c>)Trigger.new){
	            	if(isChanged('Historical_Case_Id__c', objFR) && caseIdtoCaseCommentMap.containsKey(objFR.Historical_Case_Id__c)){
	            		if(objFR.Internal_Comments__c == null) {
	            			objFR.Internal_Comments__c = '';
	            		}
	            		String[] appendCaseComment = new String[0];
						for(CaseComment caseCommentObj : caseIdtoCaseCommentMap.get(objFR.Historical_Case_Id__c)){
							appendCaseComment.add('CreatedDate: '+caseCommentObj.CreatedDate+',\n'+'CreatedBy: '+caseCommentObj.CreatedBy.Name+',\n'+'Body: '+caseCommentObj.CommentBody);
						}
						objFR.Internal_Comments__c  = objFR.Internal_Comments__c +'\n\n'+ String.join(appendCaseComment, '\n\n');
					}
		
				}
	        }
	    }
    }
 
    private void getCaseAttachments() {
    	//System.debug('inside getCaseAttachments>>>>>>>>>>>>> ');

    	Set<Id> casesToQuery = new Set<Id>();
    	Set<Id> parentIds = new Set<Id>();
    	Map<Id,List<Attachment>> caseIdtoAttchmentsMap = new Map<Id,List<Attachment>>();
    	List<Attachment> fin_ReqAttachmentstoInsertList = new List<Attachment>();

    	for(Financial_Request__c objFR : (List<Financial_Request__c>)Trigger.new){
    		if(isChanged('Historical_Case_Id__c', objFR) && String.isNotBlank(objFR.Historical_Case_Id__c)) {
				casesToQuery.add(objFR.Historical_Case_Id__c);
			}
		}

		for(Attachment objAttachment : [SELECT Id,Name,Body,BodyLength,ParentId 
                              FROM Attachment 
							  WHERE ParentId IN :casesToQuery]){
			if(caseIdtoAttchmentsMap.containsKey(objAttachment.ParentId)){
					caseIdtoAttchmentsMap.get(objAttachment.ParentId).add(objAttachment);
			} else {
				caseIdtoAttchmentsMap.put(objAttachment.ParentId, new List<Attachment> {objAttachment});
			}
		}
		//System.debug('caseAttachmentsList>>>>>>>>>>>>> '+caseAttachmentsList);

		if(!caseIdtoAttchmentsMap.isEmpty()){    
            for(Financial_Request__c objFR : (List<Financial_Request__c>)Trigger.new){
            	List<Attachment> attchmentsList = caseIdtoAttchmentsMap.get(objFR.Historical_Case_Id__c);
                if(attchmentsList != null) {
                    for(Attachment objAttachment: attchmentsList){
                        Attachment objAttch = new Attachment(Name = objAttachment.Name, Body = objAttachment.Body, ParentId = objFR.Id);
                        fin_ReqAttachmentstoInsertList.add(objAttch);
                    }
                }
				//System.debug('fin_ReqAttachmentstoInsertList>>>>>>>>>>>>> '+fin_ReqAttachmentstoInsertList);
			}
        }

        if(!fin_ReqAttachmentstoInsertList.isEmpty())
        	Insert fin_ReqAttachmentstoInsertList;
 
    }

  	private void getCaseContentDocuments() {

  		Set<Id> casesToQuery = new Set<Id>();
  		Map<Id,List<ContentDocumentLink>> caseIdContentDocMap = new Map<Id,List<ContentDocumentLink>>();
  		List<ContentDocumentLink> fin_ReqContentDocumentstoInsertList = new List<ContentDocumentLink>();

  		for(Financial_Request__c objFR : (List<Financial_Request__c>)Trigger.new){
    		if((String.isNotBlank(objFR.Historical_Case_Id__c)) && isChanged('Historical_Case_Id__c', objFR) && objFR.Historical_Case_Id__c.startsWith('500')) {
				casesToQuery.add(objFR.Historical_Case_Id__c);
			}
		}

		if(!casesToQuery.isEmpty()){ 
			for(ContentDocumentLink contentDoc : [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Description, ContentDocument.LatestPublishedVersionId 
												  FROM ContentDocumentLink 
												  WHERE LinkedEntityId IN :casesToQuery]){
				if(caseIdContentDocMap.containsKey(contentDoc.LinkedEntityId)){
						caseIdContentDocMap.get(contentDoc.LinkedEntityId).add(contentDoc);
				} else {
					caseIdContentDocMap.put(contentDoc.LinkedEntityId, new List<ContentDocumentLink> {contentDoc});
				}
			}
		}


		if(!caseIdContentDocMap.isEmpty()){    
            for(Financial_Request__c objFR : (List<Financial_Request__c>)Trigger.new){
            	List<ContentDocumentLink> contentDocList = caseIdContentDocMap.get(objFR.Historical_Case_Id__c);
                if(contentDocList != null) {
                    for(ContentDocumentLink objAttachment: contentDocList){
                        ContentDocumentLink contentDoc = new ContentDocumentLink(LinkedEntityId = objFR.Id, ContentDocumentId = objAttachment.ContentDocumentId, ShareType ='I');
                        fin_ReqContentDocumentstoInsertList.add(contentDoc);
                    }
                }
			}
        }

        if(!fin_ReqContentDocumentstoInsertList.isEmpty()){
        	Insert fin_ReqContentDocumentstoInsertList;
        }

	  }
	  private void fireEventHandler(){
		if(Trigger_Settings__c.getInstance().Bypass_Totango__c) { return; }
        List<Aggregate_Calculation_Event__e> listOfagregateEvents = new List<Aggregate_Calculation_Event__e>();
    
        for(Financial_Request__c finReqObj :(List<Financial_Request__c>)Trigger.new){
			if(finReqObj.PGI_Company__c != null){
                Aggregate_Calculation_Event__e obj = new Aggregate_Calculation_Event__e() ;   
                obj.PGI_Company_Id__c = finReqObj.PGI_Company__c;
                listOfagregateEvents.add(obj);
            }
        }
        if(!listOfagregateEvents.isEmpty()){
            List<Database.SaveResult> results = EventBus.publish(listOfagregateEvents);
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' +
                                     err.getStatusCode() +
                                     ' - ' +
                                     err.getMessage());
                    }
                }
                
            }
        }
    }

}