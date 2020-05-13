/**
 * Created by gregory.jensen on 10/3/17.
 */

public with sharing class PlanQuantityHistory extends AbstractRepository {
    public final static String table = 'PlanQuantityHistory__c';
    public final static String columns = 'id,name,plan__c,quantity__c,startDate__c,endDate__c,LastModifiedDate,LastModifiedBy.Name';

    public List<PlanQuantityHistory__c> getPlanQuantityHistorysByPlanId(Id planId){
        List<PlanquantityHistory__c> planQuantityHistorys = (List<PlanQuantityHistory__c>) Database.query(selectBuilder(table,columns,'where plan__c =: planId'));
        return planQuantityHistorys;
    }

}