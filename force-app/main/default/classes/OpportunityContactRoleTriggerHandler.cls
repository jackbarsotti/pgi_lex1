public with sharing class OpportunityContactRoleTriggerHandler extends TriggerHandler {
   public OpportunityContactRoleTriggerHandler() {
       super('OpportunityContactRoleTriggerHandler');
   }
    protected override void afterInsert(){
        checkMultipleContactRole();
    }
    protected override void afterUpdate() {
        checkMultipleContactRole();
    }    
    //RT-550
    // Author: Vijay
    
    private void checkMultipleContactRole(){
        List<Opportunity> oppToUpdateLst = new List<Opportunity>();
        Map<Id,OpportunityContactRole> oppToConRoleMap = new Map<Id,OpportunityContactRole>();

        for(OpportunityContactRole ocrObj : (List<OpportunityContactRole>) Trigger.new){
            
            if (ocrObj.Role == 'Partner Rep') {
                if(!oppToConRoleMap.containsKey(ocrObj.OpportunityId)){
                    oppToConRoleMap.put(ocrObj.OpportunityId,ocrObj);
                }
            }
        }
        System.debug('oppToConRoleMap: '+oppToConRoleMap);

        for(Opportunity oppObj : [SELECT Id, Partner_Rep__c, 
                                    (Select OpportunityId,Role 
                                    FROM OpportunityContactRoles 
                                    WHERE Role ='Partner Rep') 
                                FROM Opportunity 
                                WHERE id =:oppToConRoleMap.keySet()] ){
                                    	
            if(!oppToConRoleMap.isEmpty() && oppToConRoleMap.containsKey(oppObj.Id)){
                oppObj.Partner_Rep__c = oppToConRoleMap.get(oppObj.Id).ContactId;
                oppToUpdateLst.add(oppObj);
            }
        }

        if(!oppToUpdateLst.isEmpty()){
            System.debug('oppToUpdateLst: '+oppToUpdateLst);
            UPDATE oppToUpdateLst;
        }
    }
}