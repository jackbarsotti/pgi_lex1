public class CallLogTriggerHandler extends TriggerHandler {
    public CallLogTriggerHandler() {
        super('CallLogTriggerHandler');
    }
    protected override void afterUpdate() {
        updateClientTasks((List<Call_Log__c>)Trigger.new, (Map<Id, Call_Log__c>)Trigger.oldMap);
    }
    private void updateClientTasks(List<Call_Log__c> callLogs, Map<Id, Call_Log__c> oldMap) {
        Set<Id> cIds = new Set<Id>();
        for(Call_Log__c cl: callLogs) {
            if(cl.PGi_Client__c != oldMap.get(cl.Id).PGI_Client__c) {
                cIds.add(cl.Id);
            }
        }
        if(cIds.size() > 0) {
            List<Task> tasksToUpdate = [SELECT Id FROM Task WHERE WhatId IN: cIds];
            Database.update(tasksToUpdate, false); 
        }
    }
}