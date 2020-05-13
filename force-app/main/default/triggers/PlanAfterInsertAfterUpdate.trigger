/**
 * Created by gregory.jensen on 9/19/17.
 */

trigger PlanAfterInsertAfterUpdate on Plan__c (after insert, after update) {
    Map<Id, Plan__c> newPlans = Trigger.newMap;
    Map<Id, Plan__c> oldPlans = Trigger.oldMap;

    List<Id> plansNeedingQuantityHistory = new List<Id>();

    List<PlanQuantityHistory__c> planQuantityHistories = new List<PlanQuantityHistory__c>();

    if (null == oldPlans || oldPlans.size() == 0) { //after insert
        for (Plan__c p : newPlans.values()) {
            if (p.quantity__c != null) {
                PlanQuantityHistory__c pqh = new PlanQuantityHistory__c();
                pqh.quantity__c = p.Quantity__c;
                pqh.startDate__c = p.quantityStartDate__c;
                pqh.Plan__c = p.Id;
                planQuantityHistories.add(pqh);
            }
        }
        insert planQuantityHistories;
    }
    else { //after update
        for (Plan__c p : newPlans.values()) {
            Plan__c oldPlan = oldPlans.get(p.Id);
            if (p.Quantity__c != oldPlan.Quantity__c) {
                plansNeedingQuantityHistory.add(oldPlan.Id);
                PlanQuantityHistory__c pqh = new PlanQuantityHistory__c();
                pqh.quantity__c = p.Quantity__c;
                pqh.startDate__c = p.quantityStartDate__c;
                pqh.Plan__c = p.Id;
                planQuantityHistories.add(pqh);
            }
        }
        List<PlanQuantityHistory__c> oldHistories = [ SELECT startDate__c, endDate__c, Plan__c, quantity__c
                                                      FROM PlanQuantityHistory__c
                                                      WHERE endDate__c = null AND Plan__c in :plansNeedingQuantityHistory ];

        Map<Id, PlanQuantityHistory__c> planToPqhMap = new Map<Id, PlanQuantityHistory__c> ();
        for (PlanQuantityHistory__c pqh : planQuantityHistories) {
            planToPqhMap.put(pqh.Plan__c, pqh);
        }
        for (PlanQuantityHistory__c pqh : oldHistories){
            if (planToPqhMap.containsKey(pqh.Plan__c)) {
                pqh.endDate__c = planToPqhMap.get(pqh.Plan__c).startDate__c;
                planQuantityHistories.add(pqh);
            }
        }

        upsert planQuantityHistories;

    }

}