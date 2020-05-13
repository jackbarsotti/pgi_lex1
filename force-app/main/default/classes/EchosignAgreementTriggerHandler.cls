public class EchosignAgreementTriggerHandler extends TriggerHandler {
	public EchosignAgreementTriggerHandler() {
		super('EchosignAgreementTriggerHandler');
	}
	protected override void afterDelete() {
		Set<Id> oppIds = new Set<Id>();
		for(echosign_dev1__SIGN_Agreement__c agreement: (List<echosign_dev1__SIGN_Agreement__c>)Trigger.old) {
			oppIds.add(agreement.echosign_dev1__Opportunity__c);
		}
		oppIds.remove(null);
		if(oppIds.size() > 0) {
			List<Opportunity> oppList = [SELECT Id, (SELECT Id FROM echosign_dev1__R00N70000001hM2REAU__r) FROM Opportunity WHERE Id IN: oppIds FOR UPDATE];
			List<Opportunity> toUpdate = new List<Opportunity>();
			for(Opportunity opp: oppList) {
				if(opp.echosign_dev1__R00N70000001hM2REAU__r == null || opp.echosign_dev1__R00N70000001hM2REAU__r.size() == 0) {
					opp.Agreement_Status__c = 'Cancelled';
					toUpdate.add(opp);
				}
			}
			LoggerUtil.handleSaveResults('failed to save echosign agreement status', Database.update(toUpdate, false));
		}
	}
}