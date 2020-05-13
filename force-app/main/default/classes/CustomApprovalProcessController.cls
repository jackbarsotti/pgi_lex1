/*
	Copyright (c) ajay-gupta.com
	All rights reserved.
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions
	are met:
	1. Redistributions of source code must retain the above copyright
	   notice, this list of conditions and the following disclaimer.
	2. Redistributions in binary form must reproduce the above copyright
	   notice, this list of conditions and the following disclaimer in the
	   documentation and/or other materials provided with the distribution.
	3. The name of the author may not be used to endorse or promote products
	   derived from this software without specific prior written permission.
	
	THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
	IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
	OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
	IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, 
	INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
	NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
	DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
	THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
	THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
/**
 * Author : Ajay Gupta
 * ClassName : CustomApprovalProcessController
 * Description : This class generates the customized view of Approval Process 
 *			   History.
 **/
public with sharing class CustomApprovalProcessController {
	//Properties Declaration
	transient public ApprovalList aSW {get; private set;}
	public Id recordId;
	private String ORG_LNK;
	
   	//Properties Construnctor
	public CustomApprovalProcessController(ApexPages.StandardController controller) {
		recordId = ApexPages.currentPage().getParameters().get('id');
		ORG_LNK = 'https://'+URL.getSalesforceBaseUrl().getHost();
		if(!String.isBlank(recordID)){
			aSW = new ApprovalList();
			aSW = generateData();
		}			
	}
	public Boolean approved {get {
		if(approved == null) {
			approved = [SELECT Status__c FROM Request_For_Change__c WHERE Id =: recordId].Status__c == 'Approved';
		}
		return approved;
	} set;}
	public String retractApprovalLink { get{
		PageReference pr = Page.RequestForChangeRetractApproval;
		pr.getParameters().put('id', recordId);
		return pr.getUrl();
	}}

	private ApprovalList generateData(){
		ApprovalList approvalResultForObject = new ApprovalList();
		List<ApprovalStepWrapper> aSW = new List<ApprovalStepWrapper>();
		String recallApprovalProcessLink;
		Boolean isSubmitForApproval = true;
		for(ProcessInstance pI:getProcessHistory(recordId).values()){
			Map<Id,List<ProcessInstanceHistory>> mapOfProcessNodeIdAndProcessInstanceHistory = new Map<Id,List<ProcessInstanceHistory>>();
			Set<Id> processNodeId= new Set<Id>(); 
			
			for(ProcessInstanceHistory sWI:pI.StepsAndWorkitems){
				if(processNodeId.size() ==0)
					processNodeId.add(sWI.ProcessNodeId);
				else if(processNodeId.size()>0 && processNodeId.contains(sWI.ProcessNodeId)!= NULL)
					processNodeId.add(sWI.ProcessNodeId);
			}
			
			for(Id pNId: processNodeId){
				ApprovalStepWrapper aSWr = new ApprovalStepWrapper();
				for(ProcessInstanceHistory sWI:pI.StepsAndWorkitems){
					if(sWI.processNodeId == pNID){
						aSWr.listOfSteps.add(sWI);
					}
					if(sWI.StepStatus == 'Pending'){
						aSWr.workItemApproveOrRejectLink = ORG_LNK+'/p/process/ProcessInstanceWorkitemWizardStageManager?id='+sWI.Id;
						aSWr.workItemReassignLink =  ORG_LNK+'/'+sWI.Id+'/e?et=REASSIGN&retURL=/'+recordId;
						recallApprovalProcessLink =  ORG_LNK +'/'+sWI.Id+'/e?et=REMOVE&retURL=/'+recordId;
						isSubmitForApproval = false;
					}
					
				}
				aSW.add(aSWr);
			}
		}
		approvalResultForObject.approvals = aSW;
		approvalResultForObject.recordId = recordId;
		approvalResultForObject.isSubmitForApproval = isSubmitForApproval;
		approvalResultForObject.recallApprovalProcessLink = recallApprovalProcessLink;
		return approvalResultForObject;
	}
	private Map<Id, ProcessInstance> getProcessHistory(Id objectId){
	   return new Map<Id, ProcessInstance>([
	   		SELECT Id, 
		   		(SELECT ID, ProcessNodeId, StepStatus,Comments, TargetObjectId,ActorId, CreatedById, 
		   			IsDeleted, IsPending, OriginalActorId, ProcessInstanceId, RemindersSent, CreatedDate,
		   			Actor.Name, OriginalActor.Name, ProcessNode.Name 
	   			FROM StepsAndWorkitems ORDER BY CreatedDate DESC) 
			FROM ProcessInstance 
			WHERE TargetObjectId =: objectId ORDER BY CreatedDate DESC]);
	}
	public class ApprovalStepWrapper{
		public String workItemApproveOrRejectLink {get;set;}
		public String workItemReassignLink {get;set;}
		public List<ProcessInstanceHistory> listOfSteps {get;set;}
		public ApprovalStepWrapper(){
			listOfSteps = new List<ProcessInstanceHistory>();
		}
	}
	public class ApprovalList{
		public List<ApprovalStepWrapper> approvals {get;set;}
		public String recallApprovalProcessLink {get;set;}
		public Boolean isSubmitForApproval {get;set;}
		public Id recordId {get;set;}
		public ApprovalList(){
			approvals = new List<ApprovalStepWrapper>();
			isSubmitForApproval = true;
		}
	}
}