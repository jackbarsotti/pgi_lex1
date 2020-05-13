public class RTEventTriggerHandler extends TriggerHandler {
	public RTEventTriggerHandler() {
		super('RTEventTriggerHandler');
	}
	protected override void beforeInsert(){
		RTEventActions.updateRTEventNotes((List<RTEvent__c>)Trigger.new); //replaces RTEventBeforeInsertBeforeUpdate trigger
	}
	protected override void afterInsert(){
		RTEventActions.addEventRecords((Map<Id, RTEvent__c>)Trigger.newMap, (Map<Id, RTEvent__c>)Trigger.oldMap); //replaces RTEventAfterInsertAfterUpdate trigger
	}
	protected override void beforeUpdate(){
		RTEventActions.updateRTEventNotes((List<RTEvent__c>)Trigger.new); //replaces RTEventBeforeInsertBeforeUpdate trigger
	}
	protected override void afterUpdate(){
		RTEventActions.addEventRecords((Map<Id, RTEvent__c>)Trigger.newMap, (Map<Id, RTEvent__c>)Trigger.oldMap); //replaces RTEventAfterInsertAfterUpdate trigger
	}
}