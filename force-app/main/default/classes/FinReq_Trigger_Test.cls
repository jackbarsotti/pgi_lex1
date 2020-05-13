@isTest
public class FinReq_Trigger_Test {
	@TestSetup
	static void setupUsers() {
		List<User> users = new List<User>();
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

		User rvp_user = new User(Username='rvp@pgi.com', LastName='rvp', Email='rvp@pgi.com', Alias='rvp', CommunityNickname='rvp', TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', EmployeeNumber='12345', ProfileId=p.Id, LanguageLocaleKey='en_US');
		users.add(rvp_user);

		User svp_user = new User(Username='svp@pgi.com', LastName='svp', Email='svp@pgi.com', Alias='svp', CommunityNickname='svp', TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', EmployeeNumber='12345', ProfileId=p.Id, LanguageLocaleKey='en_US');
		users.add(svp_user);

		User main_user = new User(Username='main@pgi.com', LastName='main', Email='main@pgi.com', Alias='main', CommunityNickname='main', TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', EmployeeNumber='12345', ProfileId=p.Id, LanguageLocaleKey='en_US');
		users.add(main_user);

		INSERT users;

		main_user.RVP__c = rvp_user.Id;
		main_user.SVP__c = svp_user.Id;
		UPDATE main_user;
	}
	static List<User> get_approval_users() {
		Set<String> userNameList = new Set<String>{'rvp@pgi.com', 'svp@pgi.com', 'main@pgi.com'};
		List<User> users = [SELECT Id FROM User WHERE userName IN: userNameList ORDER BY UserName DESC];
		return users;
	}

	static testMethod void update_finreq_no_pgicontract() {
		Financial_Request__c fr = new Financial_Request__c();
		INSERT fr;

		Test.startTest();

		fr.Status__c = 'Approved';
		UPDATE fr;

		Test.stopTest();
	}

	static testMethod void update_finreq_no_approval() {
		Opportunity opp = PGITestUtilities.getOpportunityDetails();
		INSERT opp;
		Account acc = PGITestUtilities.getAccountDetails();
		INSERT acc;
		CONMAN_Contract__c pgic = PGITestUtilities.getConManContractDetails(acc.Id, opp.Id);
		pgic.Contract_Status__c = 'New';
		INSERT pgic;

		Financial_Request__c fr = new Financial_Request__c(PGi_Contract__c = pgic.Id, Status__c='In Progress');
		INSERT fr;

		Test.startTest();

		fr.Status__c = 'Approved';
		UPDATE fr;

		Test.stopTest();

		pgic = [SELECT Id, Contract_Status__c FROM CONMAN_Contract__c WHERE Id = :pgic.Id];
		System.assertEquals('New', pgic.Contract_Status__c, 'Contract Status');
	}

	static testMethod void update_finreq_not_dealdesk() {
		List<User> users = get_approval_users();

		Opportunity opp = PGITestUtilities.getOpportunityDetails();
		INSERT opp;
		Account acc = PGITestUtilities.getAccountDetails();
		INSERT acc;
		CONMAN_Contract__c pgic = PGITestUtilities.getConManContractDetails(acc.Id, opp.Id);
		pgic.Contract_Status__c = 'New';
		pgic.Required_Approval_Pricing_RVP__c = true;
		pgic.OwnerId = users.get(0).Id;
		INSERT pgic;

		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		req.setComments('Testing Approvals');
		req.setObjectId(pgic.Id);
		req.setProcessDefinitionNameOrId('iContract_NA_Approvals_v9');
		req.setSkipEntryCriteria(true);

		Approval.ProcessResult result = Approval.process(req);
		System.assert(result.isSuccess(), 'Unable to start the Approval Process required for the test: iContract_NA_Approvals_v9');

		List<ProcessInstance> approvals = [
			SELECT Id, TargetObjectId, Status, ProcessDefinitionId,
			(SELECT NodeStatus, ProcessNodeName FROM Nodes),
			(SELECT Id FROM Workitems)
			FROM ProcessInstance WHERE TargetObjectId = :pgic.Id
		];
		// System.assertEquals(1, approvals.size(), '1 Approval found');
		// System.assertEquals('Pending', approvals.get(0).Status, 'Correct Approval Status');
		// System.assertEquals(1, approvals.get(0).Nodes.size(), '1 Approval Step found');
		// System.assertEquals('Pricing - RVP', approvals.get(0).Nodes.get(0).ProcessNodeName, 'Correct Approval Step');
		// System.assertEquals('Pending', approvals.get(0).Nodes.get(0).NodeStatus, 'Correct Approval Step Status');

		Financial_Request__c fr = new Financial_Request__c(PGi_Contract__c = pgic.Id, Status__c='In Progress');
		INSERT fr;

		Test.startTest();

		fr.Status__c = 'Approved';
		UPDATE fr;

		Test.stopTest();

		pgic = [SELECT Id, Contract_Status__c FROM CONMAN_Contract__c WHERE Id = :pgic.Id];
		

		approvals = [
			SELECT Id, TargetObjectId, Status, ProcessDefinitionId,
			(SELECT NodeStatus, ProcessNodeName FROM Nodes),
			(SELECT Id FROM Workitems)
			FROM ProcessInstance WHERE TargetObjectId = :pgic.Id
		];
		System.assertEquals(1, approvals.size(), '1 Approval found');
		
	}

	static testMethod void update_finreq_dealdesk_approval() {
		List<User> users = get_approval_users();

		Opportunity opp = PGITestUtilities.getOpportunityDetails();
		INSERT opp;
		Account acc = PGITestUtilities.getAccountDetails();
		INSERT acc;
		CONMAN_Contract__c pgic = PGITestUtilities.getConManContractDetails(acc.Id, opp.Id);
		pgic.Contract_Status__c = 'New';
		pgic.Required_Approval_Deal_Desk__c = true;
		pgic.OwnerId = users.get(0).Id;
		pgic.Product_Details_Were_Manually_Changed__c = 'No';
		pgic.T_Cs_Were_Manually_Changed__c = 'No';
		INSERT pgic;

		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		req.setComments('Testing Approvals');
		req.setObjectId(pgic.Id);
		req.setProcessDefinitionNameOrId('iContract_NA_Approvals_v9');
		req.setSkipEntryCriteria(true);

		Approval.ProcessResult result = Approval.process(req);
		System.assert(result.isSuccess(), 'Unable to start the Approval Process required for the test: iContract_NA_Approvals_v9');

		List<ProcessInstance> approvals = [
			SELECT Id, TargetObjectId, Status, ProcessDefinitionId,
			(SELECT NodeStatus, ProcessNodeName FROM Nodes),
			(SELECT Id FROM Workitems)
			FROM ProcessInstance WHERE TargetObjectId = :pgic.Id
		];
		System.assertEquals(1, approvals.size(), '1 Approval found');
		System.assertEquals('Pending', approvals.get(0).Status, 'Correct Approval Status');
		System.assertEquals(1, approvals.get(0).Nodes.size(), '1 Approval Step found');
		System.assertEquals('Pricing - Deal Desk', approvals.get(0).Nodes.get(0).ProcessNodeName, 'Correct Approval Step');
		System.assertEquals('Pending', approvals.get(0).Nodes.get(0).NodeStatus, 'Correct Approval Step Status');

		Financial_Request__c fr = new Financial_Request__c(PGi_Contract__c = pgic.Id, Status__c='In Progress');
		INSERT fr;

		Test.startTest();

		fr.Status__c = 'Approved';
		UPDATE fr;

		Test.stopTest();

		pgic = [SELECT Id, Contract_Status__c FROM CONMAN_Contract__c WHERE Id = :pgic.Id];
		System.assertEquals('Approved', pgic.Contract_Status__c, 'Contract Status');

		approvals = [
			SELECT Id, TargetObjectId, Status, ProcessDefinitionId,
			(SELECT NodeStatus, ProcessNodeName FROM Nodes),
			(SELECT Id FROM Workitems)
			FROM ProcessInstance WHERE TargetObjectId = :pgic.Id
		];
		System.assertEquals(1, approvals.size(), '1 Approval found');
		System.assertEquals('Approved', approvals.get(0).Status, 'Correct Approval Status');
		System.assertEquals(1, approvals.get(0).Nodes.size(), '1 Approval Step found');
		System.assertEquals('Pricing - Deal Desk', approvals.get(0).Nodes.get(0).ProcessNodeName, 'Correct Approval Step');
		System.assertEquals('Approved', approvals.get(0).Nodes.get(0).NodeStatus, 'Correct Approval Step Status');
	}

	static testMethod void update_finreq_dealdesk_approval_double() {
		List<User> users = get_approval_users();

		Opportunity opp = PGITestUtilities.getOpportunityDetails();
		INSERT opp;
		Account acc = PGITestUtilities.getAccountDetails();
		INSERT acc;
		CONMAN_Contract__c pgic = PGITestUtilities.getConManContractDetails(acc.Id, opp.Id);
		pgic.Contract_Status__c = 'New';
		pgic.Required_Approval_Deal_Desk__c = true;
		pgic.OwnerId = users.get(0).Id;
		INSERT pgic;

		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		req.setComments('Testing Approvals');
		req.setObjectId(pgic.Id);
		req.setProcessDefinitionNameOrId('iContract_NA_Approvals_v9');
		req.setSkipEntryCriteria(true);

		Approval.ProcessResult result = Approval.process(req);
		System.assert(result.isSuccess(), 'Unable to start the Approval Process required for the test: iContract_NA_Approvals_v9');

		List<ProcessInstance> approvals = [
			SELECT Id, TargetObjectId, Status, ProcessDefinitionId,
			(SELECT NodeStatus, ProcessNodeName FROM Nodes),
			(SELECT Id FROM Workitems)
			FROM ProcessInstance WHERE TargetObjectId = :pgic.Id
		];
		System.assertEquals(1, approvals.size(), '1 Approval found');
		System.assertEquals('Pending', approvals.get(0).Status, 'Correct Approval Status');
		System.assertEquals(1, approvals.get(0).Nodes.size(), '1 Approval Step found');
		System.assertEquals('Pricing - Deal Desk', approvals.get(0).Nodes.get(0).ProcessNodeName, 'Correct Approval Step');
		System.assertEquals('Pending', approvals.get(0).Nodes.get(0).NodeStatus, 'Correct Approval Step Status');

		Financial_Request__c fr = new Financial_Request__c(PGi_Contract__c = pgic.Id, Status__c='Approved');
		INSERT fr;

		Test.startTest();

		fr.Justification__c = 'This will not trigger';
		fr.Status__c = 'Approved';
		UPDATE fr;

		Test.stopTest();

		pgic = [SELECT Id, Contract_Status__c FROM CONMAN_Contract__c WHERE Id = :pgic.Id];
		System.assertEquals('Pending Approval', pgic.Contract_Status__c, 'Contract Status');

		approvals = [
			SELECT Id, TargetObjectId, Status, ProcessDefinitionId,
			(SELECT NodeStatus, ProcessNodeName FROM Nodes),
			(SELECT Id FROM Workitems)
			FROM ProcessInstance WHERE TargetObjectId = :pgic.Id
		];
		System.assertEquals(1, approvals.size(), '1 Approval found');
		System.assertEquals('Pending', approvals.get(0).Status, 'Correct Approval Status');
		System.assertEquals(1, approvals.get(0).Nodes.size(), '1 Approval Step found');
		System.assertEquals('Pricing - Deal Desk', approvals.get(0).Nodes.get(0).ProcessNodeName, 'Correct Approval Step');
		System.assertEquals('Pending', approvals.get(0).Nodes.get(0).NodeStatus, 'Correct Approval Step Status');
	}

	static testMethod void update_finreq_dealdesk_rejected() {
		List<User> users = get_approval_users();

		Opportunity opp = PGITestUtilities.getOpportunityDetails();
		INSERT opp;
		Account acc = PGITestUtilities.getAccountDetails();
		INSERT acc;
		CONMAN_Contract__c pgic = PGITestUtilities.getConManContractDetails(acc.Id, opp.Id);
		pgic.Contract_Status__c = 'New';
		pgic.Required_Approval_Deal_Desk__c = true;
		pgic.OwnerId = users.get(0).Id;
		INSERT pgic;

		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		req.setComments('Testing Approvals');
		req.setObjectId(pgic.Id);
		req.setProcessDefinitionNameOrId('iContract_NA_Approvals_v9');
		req.setSkipEntryCriteria(true);

		Approval.ProcessResult result = Approval.process(req);
		System.assert(result.isSuccess(), 'Unable to start the Approval Process required for the test: iContract_NA_Approvals_v9');

		List<ProcessInstance> approvals = [
			SELECT Id, TargetObjectId, Status, ProcessDefinitionId,
			(SELECT NodeStatus, ProcessNodeName FROM Nodes),
			(SELECT Id FROM Workitems)
			FROM ProcessInstance WHERE TargetObjectId = :pgic.Id
		];
		System.assertEquals(1, approvals.size(), '1 Approval found');
		System.assertEquals('Pending', approvals.get(0).Status, 'Correct Approval Status');
		System.assertEquals(1, approvals.get(0).Nodes.size(), '1 Approval Step found');
		System.assertEquals('Pricing - Deal Desk', approvals.get(0).Nodes.get(0).ProcessNodeName, 'Correct Approval Step');
		System.assertEquals('Pending', approvals.get(0).Nodes.get(0).NodeStatus, 'Correct Approval Step Status');

		Financial_Request__c fr = new Financial_Request__c(PGi_Contract__c = pgic.Id, Status__c='In Progress');
		INSERT fr;

		Test.startTest();

		fr.Status__c = 'Rejected';
		UPDATE fr;

		Test.stopTest();

		pgic = [SELECT Id, Contract_Status__c FROM CONMAN_Contract__c WHERE Id = :pgic.Id];
		System.assertEquals('Rejected', pgic.Contract_Status__c, 'Contract Status');

		approvals = [
			SELECT Id, TargetObjectId, Status, ProcessDefinitionId,
			(SELECT NodeStatus, ProcessNodeName FROM Nodes),
			(SELECT Id FROM Workitems)
			FROM ProcessInstance WHERE TargetObjectId = :pgic.Id
		];
		System.assertEquals(1, approvals.size(), '1 Approval found');
		System.assertEquals('Rejected', approvals.get(0).Status, 'Correct Approval Status');
		System.assertEquals(1, approvals.get(0).Nodes.size(), '1 Approval Step found');
		System.assertEquals('Pricing - Deal Desk', approvals.get(0).Nodes.get(0).ProcessNodeName, 'Correct Approval Step');
		System.assertEquals('Rejected', approvals.get(0).Nodes.get(0).NodeStatus, 'Correct Approval Step Status');
	}

	static testMethod void update_finreq_dealdesk_cancelled() {
		List<User> users = get_approval_users();

		Opportunity opp = PGITestUtilities.getOpportunityDetails();
		INSERT opp;
		Account acc = PGITestUtilities.getAccountDetails();
		INSERT acc;
		CONMAN_Contract__c pgic = PGITestUtilities.getConManContractDetails(acc.Id, opp.Id);
		pgic.Contract_Status__c = 'New';
		pgic.Required_Approval_Deal_Desk__c = true;
		pgic.OwnerId = users.get(0).Id;
		INSERT pgic;

		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		req.setComments('Testing Approvals');
		req.setObjectId(pgic.Id);
		req.setProcessDefinitionNameOrId('iContract_NA_Approvals_v9');
		req.setSkipEntryCriteria(true);

		Approval.ProcessResult result = Approval.process(req);
		System.assert(result.isSuccess(), 'Unable to start the Approval Process required for the test: iContract_NA_Approvals_v9');

		List<ProcessInstance> approvals = [
			SELECT Id, TargetObjectId, Status, ProcessDefinitionId,
			(SELECT NodeStatus, ProcessNodeName FROM Nodes),
			(SELECT Id FROM Workitems)
			FROM ProcessInstance WHERE TargetObjectId = :pgic.Id
		];
		System.assertEquals(1, approvals.size(), '1 Approval found');
		System.assertEquals('Pending', approvals.get(0).Status, 'Correct Approval Status');
		System.assertEquals(1, approvals.get(0).Nodes.size(), '1 Approval Step found');
		System.assertEquals('Pricing - Deal Desk', approvals.get(0).Nodes.get(0).ProcessNodeName, 'Correct Approval Step');
		System.assertEquals('Pending', approvals.get(0).Nodes.get(0).NodeStatus, 'Correct Approval Step Status');

		Financial_Request__c fr = new Financial_Request__c(PGi_Contract__c = pgic.Id, Status__c='In Progress');
		INSERT fr;

		Test.startTest();

		fr.Status__c = 'Cancelled';
		UPDATE fr;

		Test.stopTest();

		pgic = [SELECT Id, Contract_Status__c FROM CONMAN_Contract__c WHERE Id = :pgic.Id];
		System.assertEquals('Pending Approval', pgic.Contract_Status__c, 'Contract Status');

		approvals = [
			SELECT Id, TargetObjectId, Status, ProcessDefinitionId,
			(SELECT NodeStatus, ProcessNodeName FROM Nodes),
			(SELECT Id FROM Workitems)
			FROM ProcessInstance WHERE TargetObjectId = :pgic.Id
		];
		System.assertEquals(1, approvals.size(), '1 Approval found');
		System.assertEquals('Pending', approvals.get(0).Status, 'Correct Approval Status');
		System.assertEquals(1, approvals.get(0).Nodes.size(), '1 Approval Step found');
		System.assertEquals('Pricing - Deal Desk', approvals.get(0).Nodes.get(0).ProcessNodeName, 'Correct Approval Step');
		System.assertEquals('Pending', approvals.get(0).Nodes.get(0).NodeStatus, 'Correct Approval Step Status');
	}

	static testMethod void update_finreq_dealdesk_completed() {
		List<User> users = get_approval_users();

		Opportunity opp = PGITestUtilities.getOpportunityDetails();
		INSERT opp;
		Account acc = PGITestUtilities.getAccountDetails();
		INSERT acc;
		CONMAN_Contract__c pgic = PGITestUtilities.getConManContractDetails(acc.Id, opp.Id);
		pgic.Contract_Status__c = 'New';
		pgic.Required_Approval_Deal_Desk__c = true;
		pgic.OwnerId = users.get(0).Id;
		INSERT pgic;

		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		req.setComments('Testing Approvals');
		req.setObjectId(pgic.Id);
		req.setProcessDefinitionNameOrId('iContract_NA_Approvals_v9');
		req.setSkipEntryCriteria(true);

		Approval.ProcessResult result = Approval.process(req);
		System.assert(result.isSuccess(), 'Unable to start the Approval Process required for the test: iContract_NA_Approvals_v9');

		List<ProcessInstance> approvals = [
			SELECT Id, TargetObjectId, Status, ProcessDefinitionId,
			(SELECT NodeStatus, ProcessNodeName FROM Nodes),
			(SELECT Id FROM Workitems)
			FROM ProcessInstance WHERE TargetObjectId = :pgic.Id
		];
		System.assertEquals(1, approvals.size(), '1 Approval found');
		System.assertEquals('Pending', approvals.get(0).Status, 'Correct Approval Status');
		System.assertEquals(1, approvals.get(0).Nodes.size(), '1 Approval Step found');
		System.assertEquals('Pricing - Deal Desk', approvals.get(0).Nodes.get(0).ProcessNodeName, 'Correct Approval Step');
		System.assertEquals('Pending', approvals.get(0).Nodes.get(0).NodeStatus, 'Correct Approval Step Status');

		Financial_Request__c fr = new Financial_Request__c(PGi_Contract__c = pgic.Id, Status__c='In Progress');
		INSERT fr;

		Test.startTest();

		fr.Status__c = 'Completed';
		UPDATE fr;

		Test.stopTest();

		pgic = [SELECT Id, Contract_Status__c FROM CONMAN_Contract__c WHERE Id = :pgic.Id];
		System.assertEquals('Pending Approval', pgic.Contract_Status__c, 'Contract Status');

		approvals = [
			SELECT Id, TargetObjectId, Status, ProcessDefinitionId,
			(SELECT NodeStatus, ProcessNodeName FROM Nodes),
			(SELECT Id FROM Workitems)
			FROM ProcessInstance WHERE TargetObjectId = :pgic.Id
		];
		System.assertEquals(1, approvals.size(), '1 Approval found');
		System.assertEquals('Pending', approvals.get(0).Status, 'Correct Approval Status');
		System.assertEquals(1, approvals.get(0).Nodes.size(), '1 Approval Step found');
		System.assertEquals('Pricing - Deal Desk', approvals.get(0).Nodes.get(0).ProcessNodeName, 'Correct Approval Step');
		System.assertEquals('Pending', approvals.get(0).Nodes.get(0).NodeStatus, 'Correct Approval Step Status');
	}
}