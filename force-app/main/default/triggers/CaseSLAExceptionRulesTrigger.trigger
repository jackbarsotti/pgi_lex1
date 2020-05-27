trigger CaseSLAExceptionRulesTrigger on Case_SLA_Exception_Rules__c (before delete) {
    CaseSLAExceptionRulesTriggerHandler objHandler = new CaseSLAExceptionRulesTriggerHandler();
    if(Trigger.isBefore)
    {
       if(Trigger.isDelete)
        {
            objHandler.onBeforeDelete();
        }
    }
}