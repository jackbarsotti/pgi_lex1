public class FormSubmissionTriggerHandler extends TriggerHandler {
    public FormSubmissionTriggerHandler() {
        super('FormSubmissionTriggerHandler');
    }
        protected override void afterInsert(){
            setGlobalContactMql();
        }

        private void setGlobalContactMql(){

            List<Contact> contactList = new List<Contact>();
            Set<Id> contactId = new Set<Id>();

            for(Form_Submissions__c formSubObj : (List<Form_Submissions__c>) Trigger.new){
                if(formSubObj.Contact_Id__c != null){
                    System.debug('Test');
                    contactId.add(formSubObj.Contact_Id__c);
                }
            }

            for(Contact conObj : [SELECT Id, Global_Contact_MQL__c, Global_Contact_MQL_Assignment_date__c, 
                                    (SELECT Id FROM Form_Submissions__r) 
                                    FROM Contact
                                    WHERE Id =: contactId]){

                if(conObj.Form_Submissions__r != null 
                    && conObj.Form_Submissions__r.size() == 1 
                    && conObj.Global_Contact_MQL__c !=true 
                    )
                    {
                       conObj.Global_Contact_MQL__c =true;
                       conObj.Global_Contact_MQL_Assignment_date__c = System.now();
                       contactList.add(conObj);
                   } 
            }

            if(!contactList.isEmpty()){
                UPDATE contactList;
            }
        }
    }