trigger FinReg_Trigger on Financial_Request__c (after update) {

	Map<Id, Financial_Request__c> finreqs_status_changed = new Map<Id, Financial_Request__c>();
	Set<Id> related_contracts_ids = new Set<Id>();

	for (Id fr_id : Trigger.newMap.keySet()) {
		Financial_Request__c new_finreq = Trigger.newMap.get(fr_id);
		Financial_Request__c old_finreq = Trigger.oldMap.get(fr_id);

		// Only consider FinReqs that are now Approved/Rejected and have a PGi Contract
		if (new_finreq.Status__c != old_finreq.Status__c)
			if (new_finreq.Status__c == 'Approved' || new_finreq.Status__c == 'Rejected')
				if (new_finreq.PGi_Contract__c != null) {
					finreqs_status_changed.put(fr_id, new_finreq);
					related_contracts_ids.add(new_finreq.PGi_Contract__c);
				}
	}

	List<ProcessInstance> approval_processes = [
		SELECT Id, TargetObjectId, Status, ProcessDefinitionId,
		(SELECT NodeStatus, ProcessNodeName FROM Nodes WHERE NodeStatus = 'Pending'),
		(SELECT Id FROM Workitems)
		FROM ProcessInstance WHERE Status = 'Pending' AND TargetObjectId IN :related_contracts_ids
	];

	Map<Id, ProcessInstance> approval_processes_map = new Map<Id, ProcessInstance>();
	for (ProcessInstance approval_process : approval_processes)
		approval_processes_map.put(approval_process.TargetObjectId, approval_process);

	for (Id fr_id : finreqs_status_changed.keySet()) {
		Financial_Request__c finreq = finreqs_status_changed.get(fr_id);

		// Not currently under approval
		if (!approval_processes_map.containsKey(finreq.PGi_Contract__c))
			continue;

		ProcessInstance approval_process = approval_processes_map.get(finreq.PGi_Contract__c);

		// Oddly, no steps to check (or too many, and no way to compare)
		if (approval_process.Nodes == null || approval_process.Nodes.size() != 1)
			continue;
		if (approval_process.Workitems == null || approval_process.Workitems.size() != 1)
			continue;

		// Under approval, but not the Deal Desk
		if (approval_process.Nodes.get(0).ProcessNodeName != 'Pricing - Deal Desk' && approval_process.Nodes.get(0).ProcessNodeName != 'Pricing - Deal Desk Testing')
			continue;

		// Approve/Reject the approval
		Approval.ProcessWorkitemRequest approval_step = new Approval.ProcessWorkitemRequest();
		approval_step.setComments('See ' + finreq.Name);
		if (finreq.Status__c == 'Approved')
			approval_step.setAction('Approve');
		else if (finreq.Status__c == 'Rejected')
			approval_step.setAction('Reject');
		approval_step.setWorkItemId(approval_process.Workitems.get(0).Id);

		Approval.ProcessResult approval_result = Approval.process(approval_step);
		System.assert(approval_result.isSuccess(), 'Updating the Deal Desk Approval Step for ' + finreq.Name + ' failed.');
	}

}