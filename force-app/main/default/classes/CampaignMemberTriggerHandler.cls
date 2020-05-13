public class CampaignMemberTriggerHandler extends TriggerHandler {
    public CampaignMemberTriggerHandler() {
        super('CampaignMemberTriggerHandler');
    }
        protected override void afterInsert(){
            // setGlobalContactMql();
        }
        
        private void setGlobalContactMql(){

            List<Contact> contactList = new List<Contact>();
            Set<Id> contactId = new Set<Id>();

            for(CampaignMember campaignMemberObj : (List<CampaignMember>) Trigger.new){
                if(campaignMemberObj.ContactId != null){
                    contactId.add(campaignMemberObj.ContactId);
                }
            }
            for(Contact conObj : [SELECT Id, Global_Contact_MQL__c, Global_Contact_MQL_Assignment_date__c, 
                                    (SELECT Id FROM Form_Submissions__r), 
                                    (SELECT Id FROM CampaignMembers) 
                                    FROM Contact 
                                    WHERE Id =: contactId FOR UPDATE]){
                if((conObj.CampaignMembers != null 
                    && conObj.CampaignMembers.size() == 1 
                    && conObj.Global_Contact_MQL__c !=true 
                    && conObj.Form_Submissions__r.size() == 0) )
                    {
                    //    conObj.Global_Contact_MQL__c =true;
                    //    conObj.Global_Contact_MQL_Assignment_date__c = System.now();
                    //    contactList.add(conObj);
                   } 
            }

            if(!contactList.isEmpty()){
                // UPDATE contactList;
            }
        }
    }