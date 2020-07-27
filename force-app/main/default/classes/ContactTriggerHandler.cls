public class ContactTriggerHandler extends TriggerHandler {
    public ContactTriggerHandler() {
        super('ContactTriggerHandler');
    }
    protected override void beforeInsert() {
        // ContactBeforeInsertBeforeUpdate.trigger
        contactBeforeInsertBeforeUpdateSyncAddressFields();
        // RT-513 New Contact Global MQL Field
        //setGlobalMQLAssignmentDate();
        // celigoUpdateContact.trigger
        celigoUpdateContact();
        ContactActions.onContactDelete(Trigger.new, Trigger.old);  
    }
    protected override void beforeUpdate() {
        // ContactBeforeInsertBeforeUpdate.trigger
        contactBeforeInsertBeforeUpdateSyncAddressFields();
        // RT-513 New Contact Global MQL Field 
        setGlobalMQLAssignmentDate();
        // celigoUpdateContact.trigger
        celigoUpdateContact();
        ContactActions.onContactDelete(Trigger.new, Trigger.old);  
    }
    protected override void afterUpdate() {
        cascadeStatusToFoxDenUser(Trigger.new);
        // RT-513
        //setConvertedMQLOnOpportunity();  
    }
    protected override void afterInsert(){
        // RT-513
      //  setConvertedMQLOnOpportunity();  
    }
    
    // logic from celigoUpdateContact.trigger
    private void celigoUpdateContact() {
        List<Id> ids = new List<Id>();
        for (Contact contact: (List<Contact>)Trigger.new) {
            if(contact.AccountId != null && !contact.NetSuite_Locked__c && !contact.Celigo_Update__c && ReadyTalkRecordTypeHelper.readyTalkContactRecordTypeIds.contains(contact.RecordTypeId)) {
                ids.add(contact.AccountId);
            }
        }
        System.debug('>> ids >>'+ids);
        if(ids.isEmpty()) {
            return;
        }
        List<Account> acs = [select Id, NetSuite_Id__c from account where id IN :ids];
        System.debug('>> acs >>'+acs);
        for(Contact contact: (List<Contact>)Trigger.new) {
            //COD-1376
            if(!ReadyTalkRecordTypeHelper.readyTalkContactRecordTypeIds.contains(contact.RecordTypeId)) {
                continue;
            }
            System.debug('>> contact.AccountId >>'+contact.AccountId);
            System.debug('>> contact.NetSuite_Locked__c >>'+contact.NetSuite_Locked__c);
            System.debug('>> contact.Celigo_Update__c >>'+contact.Celigo_Update__c);
            if(contact.AccountId == null  || contact.NetSuite_Locked__c) {
                continue;	
            }
            
            if(contact.Celigo_Update__c) {
                contact.Celigo_Update__c = false;
                continue;
            }
            
            if(Trigger.isInsert) {
                contact.NetSuite_Id__c = null;
                contact.NetSuite_Locked__c = false;
                contact.NS_Sync__c = null;
            }
            
            // if (contact.NetSuite_Id__c == null && contact.Email == null) {
            contact.NetSuite_Push__c = false;
            contact.NetSuite_Pull__c = false; 
            System.debug('>>> before continue >>>');
            continue;
            System.debug('>>> After continue >>>');
            // }
            
            Integer index = -1;
            for(Integer i = 0; i< acs.size(); i++) {
                if(acs[i].Id == contact.AccountId) {
                    index=i;
                    break;
                }
            }
            
            if(index == -1 || acs[index].NetSuite_Id__c == null) {
                continue; 
            }
            
            contact.NetSuite_Push__c = true;
            contact.NetSuite_Pull__c = true;   
        }
    }
    
    // logic from ContactBeforeInsertBeforeUpdate.trigger
    private void contactBeforeInsertBeforeUpdateSyncAddressFields() {
        ContactActions.syncAddressFields(Trigger.new, Trigger.old);
        
        //Ensure we are not the System Admin API Only user (we don't want the e-mail to be generated if we are)
        Profile profile = null;
        
        try {
            if(!Test.isRunningTest()) {
                profile = PGI_Utility.profile;
            }
        }
        catch(Exception e){
            
        }
        
        if(profile != null && profile.Name != null && profile.Name.equals('System Admin API Only')) {
            return;
        }
        
        //Actions:
        //ContactActions.onContactDelete(Trigger.new, Trigger.old);  
        ContactActions.checkForEmailDupes(Trigger.new, Trigger.old);
    }
    private Map<Id, List<FoxDen_User__c>> foxDenUsersByContactId {get {
        if(foxDenUsersByContactId == null) {
            foxDenUsersByContactId = new Map<Id, List<FoxDen_User__c>>();
            List<FoxDen_User__c> foxdenUsers = [SELECT Id, Status__c, Contact__c FROM FoxDen_User__c WHERE Contact__c IN: Trigger.newMap.keySet()];
            for(FoxDen_User__c user: foxdenUsers) {
                foxDenUsersByContactId.put(user.Contact__c, new List<FoxDen_User__c>());
            }  
            for(FoxDen_User__c user: foxdenUsers) {
                foxDenUsersByContactId.get(user.Contact__c).add(user);
            }
        }  
        return foxDenUsersByContactId;
    } set;}
    private void cascadeStatusToFoxDenUser(List<Contact> contacts) {
        List<FoxDen_User__c> toUpdate = new List<FoxDen_User__c>();
        for(Contact c: contacts) {
            if(c.Status__c != 'Active') {
                if(foxDenUsersByContactId.get(c.Id) != null){
                    for(FoxDen_User__c user: foxDenUsersByContactId.get(c.Id)){
                        if(user.Status__c != c.Status__c) {
                            user.Status__c = c.Status__c;
                            toUpdate.add(user);
                        }
                    }
                }
            }
        }
        Database.update(toUpdate, Test.isRunningTest());
    }
    private Map<Id, Contact> contactsWithRelatedById {get {
        if(contactsWithRelatedById == null) {
            contactsWithRelatedById = new Map<Id, Contact>([SELECT Id, (SELECT Id FROM Form_Submissions__r), (SELECT Id FROM CampaignMembers) FROM Contact WHERE Id IN: Trigger.new]);
        }
        return contactsWithRelatedById;
    } set;}
    
     private void setGlobalMQLAssignmentDate() {
        for(Contact conObj : (List<Contact>)Trigger.new){
            if(!conObj.Global_Contact_MQL__c) {
                Contact contactWithRelated = contactsWithRelatedById.get(conObj.Id);
                System.debug('>>> contactWithRelated >>>'+contactWithRelated.Form_Submissions__r);
                if(contactWithRelated.Form_Submissions__r != null && contactWithRelated.Form_Submissions__r.size() > 0){
                     conObj.Global_Contact_MQL__c = true;
                     conObj.Global_Contact_MQL_Assignment_date__c = System.now(); 
                }
            }
         }
     }
    
    
      /*private void setConvertedMQLOnOpportunity(){
         set<Id> accountIdSet=new Set<Id>();
         List<Opportunity> oppToUpdateList = new List<Opportunity>();
         for(Contact c:(List<Contact>)Trigger.new){
                 accountIdSet.add(c.AccountId);
         }
          Map<Id,List<Opportunity>> OppToAccountMap = new Map<Id,List<Opportunity>>();
         for(Opportunity oppObj : [SELECT Id, Name, AccountId, CreatedDate,CloseDate,Converted_from_MQL__c
                                                                     FROM Opportunity 
                                                                     WHERE AccountId =:accountIdSet] ){
               if (OppToAccountMap.containsKey (oppObj.AccountId)) {
                OppToAccountMap.get (oppObj.AccountId).add (oppObj);
            } else {
                OppToAccountMap.put (oppObj.AccountId, new List< Opportunity> {oppObj});
            }           
         }
          for(Contact conObj : (List<Contact>)Trigger.new){
              if(!OppToAccountMap.isEmpty() && OppToAccountMap.containsKey(conObj.AccountId)){
                  for(Opportunity oppObj :OppToAccountMap.get(conObj.AccountId)){
                      if((conObj.Global_Contact_MQL_Assignment_date__c <= oppObj.CreatedDate && conObj.Global_Contact_MQL_Assignment_date__c >= oppObj.CreatedDate.addMonths(-6)) || (conObj.Global_Contact_MQL_Assignment_date__c >= oppObj.CreatedDate && conObj.Global_Contact_MQL_Assignment_date__c <= oppObj.CloseDate ) ){
                         oppObj.Converted_from_MQL__c = true;
                          oppToUpdateList.add(oppObj);
                      }
                      else{
                          oppObj.Converted_from_MQL__c = false;
                          oppToUpdateList.add(oppObj);
                      }
                  }
              }
          }
          if(!oppToUpdateList.isEmpty()){
              System.debug('Empty');
             UPDATE oppToUpdateList;
         }
      } */
}