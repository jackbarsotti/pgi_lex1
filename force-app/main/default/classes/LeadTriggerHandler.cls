public class LeadTriggerHandler extends TriggerHandler {
    public static Boolean isExecute = false;
    public static Boolean ispopulatedExecute = false;

    protected override void beforeInsert() {
        LeadBeforeInsertBeforeUpdateSyncAddressFields();
        LeadBeforeInsertBeforeUpdateSetDefaultInvoiceTypes();
        //RT-48
            //getLeadGlobalMQLFieldspopulate();
    }
    protected override void beforeUpdate() {
        LeadBeforeInsertBeforeUpdateSyncAddressFields();
        //RT-48
            getLeadGlobalMQLFieldspopulate();
           // populateGlobalMQAonAccAndOpp();
    }

    protected override void afterInsert() {
        //RT-91
            //populateRelatedAccountforLeads();
            populateGlobalMQAonAccAndOpp();
    }

    protected override void afterUpdate() {
        //RT-91
            //populateRelatedAccountforLeads();
            populateGlobalMQAonAccAndOpp();
    }

    private void LeadBeforeInsertBeforeUpdateSetDefaultInvoiceTypes() {
        LeadActions.setDefaultInvoiceTypes(Trigger.new);
    }

    private void LeadBeforeInsertBeforeUpdateSyncAddressFields() {
        LeadActions.syncAddressFields(Trigger.new, Trigger.old);
    }

    public static Map<ID, Schema.RecordTypeInfo> leadRtMap = Lead.sObjectType.getDescribe().getRecordTypeInfosById();
    public static Map<ID, Schema.RecordTypeInfo> accountRtMap = Account.sObjectType.getDescribe().getRecordTypeInfosById();

    private void getLeadGlobalMQLFieldspopulate() {

        //if(LeadTriggerHandler.isExecute){
        //    return;
        //}

        //LeadTriggerHandler.isExecute = true;

        //PGi Lead RecordType Id
        Id pgiRecordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('PGi Leads').getRecordTypeId();

        //Marketing Profile Id
        Id pgiProfileId = [SELECT Id, Name FROM Profile Where Name = 'PGi Marketing User'].Id;

        //User's Id
        
        //Users for setting Global MQL fields during ownership change
        Set<String> querySet = new Set<String>{'Eloqua Integration', 'Olark Chat Integration', 'CRM Support Team', 'SF Marketing Cloud Integration', 'Integration Olark Chat', 'Integration Eloqua', 'Support Team CRM', 'Integration SF Marketing Cloud'};
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name FROM User Where Name IN: querySet]);
        
        //A subset of the above users, if Created By, then MQL fields should always be set regardless of any other conditions
        Set<String> mqlCreatorsSet = new Set<String>{'Olark Chat Integration', 'Integration Olark Chat'};

        Map<Id,User> userMapMQLCreators = new Map<Id,User>();
        for(User user : userMap.values()){
            if(mqlCreatorsSet.contains(user.Name)){
                userMapMQLCreators.put(user.Id, user);
            }
        }

        Map<Id,User> userIdMap;
        
        Set<Id> ownerIDs = new Set<Id>();
        List<Id> createdByIDs = new List<Id>();
        for(Lead objLead : (List<Lead>)Trigger.new){
            ownerIDs.add(objLead.OwnerId);
           createdByIDs.add(objLead.CreatedbyId);
        }

        Id userInfoId = System.UserInfo.getUserId();
        if(createdByIDs.isEmpty()){
            createdByIDs.add(0,userInfoId);
        }

        
        if(!ownerIDs.isEmpty() && !createdByIDs.isEmpty()){
            Set<Id> userIdSet = new Set<Id>();
            userIdSet.addAll(ownerIDs);
            userIdSet.addAll(createdByIDs);
            userIdMap = new Map<Id,User>([SELECT Id, Name, ProfileId, Profile.Name 
                                                       FROM User
                                                       WHERE Id IN :userIdSet]);
        }

        for(Lead objLead : (List<Lead>)Trigger.new){
            Boolean updateGlobalMQL = false;
            if(userMapMQLCreators.containsKey(objLead.CreatedbyId) && objLead.Global_MQL__c == false){
                updateGlobalMQL = true;
            } else if(String.valueOf(objLead.OwnerId).startsWith('005') && isChanged('OwnerId', objLead)) {
                if(userIdMap.keySet().contains(objLead.OwnerId) && userIdMap.get(objLead.OwnerId).ProfileId != pgiProfileId) {
                    if(objLead.RecordTypeId == pgiRecordTypeIdLead && 
                        objLead.Global_MQL__c == false &&
                        ((userIdMap.get(objLead.CreatedbyId) != null && userIdMap.get(objLead.CreatedbyId).ProfileId == pgiProfileId) 
                            || userMap.containsKey(objLead.CreatedbyId)
                            || (objLead.LeadSource == 'Inbound Call' || objLead.LeadSource == 'Customer Referral' || objLead.LeadSource == 'Internal Referral' || objLead.LeadSource == 'Web Chat')
                            )
                    ) {
                        updateGlobalMQL = true;
                        //System.debug('Onj Updated>>>>>>>> '+objLead);
                    }
                }
            }
            if(updateGlobalMQL){
                objLead.Global_MQL__c = true;
                objLead.Global_MQL_Assignment_Date__c = objLead.Global_MQL_Assignment_Date__c == null ? Date.today() : objLead.Global_MQL_Assignment_Date__c;
            }
        }
    }
    //RT-513 To set Global MQA on account and Opportunity 
    private void populateGlobalMQAonAccAndOpp() {
        List<Account> accountToUpdate = new List<Account>();
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        Set<Id> leadAccConvertedId = new Set<Id>();
        Set<Id> leadOppConvertedId = new Set<Id>();

        for(Lead leadObj : (List<Lead>)Trigger.new){
            if(leadObj.ConvertedAccountId != null && leadObj.Global_MQL__c == true){
               leadAccConvertedId.add(leadObj.ConvertedAccountId);
            }
            if(leadObj.ConvertedOpportunityId != null && leadObj.Global_MQL__c == true){
                leadOppConvertedId.add(leadObj.ConvertedOpportunityId);
            }
        }

        for(Account accountObj : [SELECT Id, Global_Account_MQA__c, Global_Account_MQA_Assignment_date__c
                                    FROM Account
                                    WHERE Id =: leadAccConvertedId]){
                                    
            if (!accountObj.Global_Account_MQA__c){
                accountObj.Global_Account_MQA__c = true;
                accountObj.Global_Account_MQA_Assignment_date__c = System.today();
                accountToUpdate.add(accountObj);
            }
        }
        // Converted_from_MQL__c will be set to true due to workflow FieldUpdate (PGi-Converted from MQL)
        for(Opportunity oppObj : [SELECT Id, Converted_from_MQL__c
                                    FROM Opportunity
                                    WHERE Id =: leadOppConvertedId]){
                                    
            if (!oppObj.Converted_from_MQL__c){
                oppObj.Converted_from_MQL__c = true;
                oppToUpdate.add(oppObj);
            }
        }

        if(!oppToUpdate.isEmpty()){
            UPDATE oppToUpdate;
        }
        if(!accountToUpdate.isEmpty()){
            UPDATE accountToUpdate;
        }
    }
  //  private void populateRelatedAccountforLeads() {

  //      if(LeadTriggerHandler.ispopulatedExecute){
  //          return;
  //      }

  //      LeadTriggerHandler.ispopulatedExecute = true;

  //      Set<String> domainstoexclude = new Set<String>{'aol.com','bellsouth.net','charter.net','comast.net','comcast.net','cox.net','earthlink.net','gmail.com','hotmail.co.uk','hotmail.com','hotmail.fr','hotmail.','icloud.com','live.com','mac.com','mailinator.com','me.com','msn.com','outlook.com','sbcglobal.net','verizon.net','yahoo.','yahoo.co.id','yahoo.co.in','yahoo.co.jp','yahoo.com','yahoo.com.hk','yahoo.de','yahoo.fr','ymail.com'};
  //      Set<Id> leadIds = new Set<Id>();
  //      Set<String> companyNamesFromLead = new Set<String>();
  //      Set<String> emailDomainsFromLead = new Set<String>();
  //      Map<String,Set<Account>> nametoAccountsMap = new Map<String,Set<Account>>();
  //      Map<String,Set<Id>> nametoAccountIdsMap = new Map<String,Set<Id>>();
  //      Map<String,Set<Id>> domainNametoAccountIdsMap = new Map<String,Set<Id>>();
  //      Map<String,Set<Account>> domainNametoAccountsMap = new Map<String,Set<Account>>();
  //      Set<Id> accoutIdsMatchingwithLeadEmails = new Set<Id>();
  //      Set<Lead> leadRecordsUpdateforEmailMatch = new Set<Lead>();
  //      List<Lead> leadwithMultipleAccountEmailMatches = new List<Lead>();

  //      List<Lead> singleLeadAccountNameMatchList = new List<Lead>();
  //      List<Lead> multipleLeadAccountNameMatchList = new List<Lead>();

  //      Set<Id> accountIdsSet = new Set<Id>();

  //      //Lead Update list
  //      List<Lead> leadsWithsingleEmailMatches = new List<Lead>();
  //      List<Lead> leadsWithNoAccountNameMatches = new List<Lead>();
  //      List<Lead> leadsWithNoAccountStatusMatches = new List<Lead>();
  //      List<Lead> leadsWithSinleAccountStatusMatches = new List<Lead>();
  //      List<Lead> leadsWithMultipleAccountStatusMatches = new List<Lead>();
  //      List<Lead> leadListToUpdate = new List<Lead>();
  //      Map<Id, Account> accountMap = new Map<Id, Account>();
  //      for(Lead lead : (List<Lead>)Trigger.new){
  //          if (leadRtMap.get(lead.recordTypeID).getName().containsIgnoreCase('PGi') && (lead.Company_for_Match_Logic__c <> null || lead.email <> null) && (lead.account__c == null || lead.Potential_Account_Matches__c == null) && ( lead.Country == 'United States' || lead.Country == 'Canada') && (lead.created_by_user_s_name__c.contains('Eloqua')|| lead.created_by_user_s_region__c == 'NA'))
  //          {
  //              leadIds.add(lead.Id);
  //          }
  //      }
  //      if(!leadIds.isEmpty()){
  //          for(Lead lead : [SELECT Id,Name,Company_for_Match_Logic__c,Potential_Account_Matches__c,Emaildomain__c
  //                           FROM Lead
  //                           WHERE Id IN :leadIds]){
  //              if(String.isNotBlank(lead.Company_for_Match_Logic__c))
  //              companyNamesFromLead.add(lead.Company_for_Match_Logic__c);

  //              if(String.isNotBlank(lead.Emaildomain__c))
  //              emailDomainsFromLead.add('%'+lead.Emaildomain__c+'%');

  //          }
  //      }
		
  //      if(!companyNamesFromLead.isEmpty()){
  //          for(Account account : [SELECT Id, Name, RecordtypeId, Status__c, OwnerId, Owner.isActive
  //                                          FROM Account 
  //                                          WHERE Name IN :companyNamesFromLead]) {
  //              accountMap.put(account.Id, account);
  //              if(accountRtMap.get(account.RecordtypeId).getName().containsIgnoreCase('PGi')){
  //                  if(!nametoAccountsMap.containsKey(account.Name)){
  //                          nametoAccountsMap.put(account.Name, new Set<Account>{account});
  //                          nametoAccountIdsMap.put(account.Name, new Set<Id>{account.Id});
  //                      }
  //                      else{
  //                          nametoAccountsMap.get(account.Name).add(account);
  //                          nametoAccountIdsMap.get(account.Name).add(account.Id);
  //                      }
  //              }                                
  //          }
  //      }
		//system.debug('nametoAccountsMap----->'+nametoAccountsMap);
  //      system.debug('nametoAccountIdsMap--==--->'+nametoAccountIdsMap);
  //         if(!emailDomainsFromLead.isEmpty()){
  //          for(Account account : [SELECT Id, Name, RecordtypeId, Status__c, Webdomain__c, Owner.isActive
  //                                          FROM Account 
  //                                          WHERE Website != null AND Website LIKE :emailDomainsFromLead]){
  //              accountMap.put(account.Id, account);
  //              if(accountRtMap.get(account.RecordtypeId).getName().containsIgnoreCase('PGi')){
  //                  if(!domainNametoAccountIdsMap.containsKey(account.Webdomain__c)){
  //                      domainNametoAccountIdsMap.put(account.Webdomain__c, new Set<Id> {account.Id});
  //                      domainNametoAccountsMap.put(account.Webdomain__c, new Set<Account>{account});
  //                      }
  //                      else{
  //                          domainNametoAccountIdsMap.get(account.Webdomain__c).add(account.Id);
  //                          domainNametoAccountsMap.get(account.Webdomain__c).add(account);
  //                      }
  //              }
  //          }
  //      }
		//system.debug('domainNametoAccountIdsMap----->'+domainNametoAccountIdsMap);
  //      system.debug('domainNametoAccountsMap--==--->'+domainNametoAccountsMap);
  //      if(!leadIds.isEmpty()){
  //          for(Lead lead : [SELECT Id,Name,Company_for_Match_Logic__c,Emaildomain__c,Potential_Account_Matches__c
  //                           FROM Lead
  //                           WHERE Id IN :leadIds]){
  //              if(lead.Emaildomain__c <> null){
  //                  if(!domainstoexclude.contains(lead.Emaildomain__c) && domainNametoAccountIdsMap.containskey(lead.Emaildomain__c)){
  //                      accoutIdsMatchingwithLeadEmails = domainNametoAccountIdsMap.get(lead.Emaildomain__c);
  //                      if(accoutIdsMatchingwithLeadEmails.size() == 1 ){
  //                          lead.Account__c = new List<Id> ( accoutIdsMatchingwithLeadEmails )[0];
  //                          lead.Potential_Account_Matches__c = null;
  //                          if(accountMap.get(lead.Account__c) != null) {
  //                              if(accountMap.get(lead.Account__c).owner.isActive) {
  //                                  lead.OwnerId = accountMap.get(lead.Account__c).OwnerId;
  //                              }
  //                          }
  //                          leadsWithsingleEmailMatches.add(lead);
  //                      }else{
  //                          leadwithMultipleAccountEmailMatches.add(lead);
  //                      }
  //                  }
  //              }else{		                                      	
  //                      if(lead.Emaildomain__c == null && nametoAccountsMap.containskey(lead.Company_for_Match_Logic__c)){
  //                          if(nametoAccountsMap.get(lead.Company_for_Match_Logic__c).size() == 1){
  //                              singleLeadAccountNameMatchList.add(lead);
  //                          }
  //                          else
  //                              multipleLeadAccountNameMatchList.add(lead);
  //                      }

  //                  }
                
  //          }
  //      }
  //      System.debug('leadwithMultipleAccountEmailMatches>>>'+leadwithMultipleAccountEmailMatches); 
  //      TriggerHandler.bypass('LeadTriggerHandler');
  //      //if(!leadsWithsingleEmailMatches.isEmpty())
  //      //UPDATE leadsWithsingleEmailMatches;
  //      TriggerHandler.clearBypass('LeadTriggerHandler');

  //      Map<String,String> leadEmailtoNameMap = new Map<String,String>();
  //      Map<String,Lead> leadEmailtoLeadRecordMap = new Map<String,Lead>();
  //      for(Lead lead : leadwithMultipleAccountEmailMatches){
  //          leadEmailtoNameMap.put(lead.Emaildomain__c, lead.Name);
  //          leadEmailtoLeadRecordMap.put(lead.Emaildomain__c, lead);
  //      }

  //      Set<Account> multipleAccountEmailMatches = new Set<Account>();
  //      if(!leadwithMultipleAccountEmailMatches.isEmpty()){
  //          for(Lead lead : leadwithMultipleAccountEmailMatches){

  //              String strAccIdCollection = '';
  //              List<String> relatedAccountIdsString = new List<String> ( (Set<String>)JSON.deserialize(JSON.serialize(domainNametoAccountIdsMap.get(lead.Emaildomain__c)), Set<String>.class) );
		//		System.debug('relatedAccountIdsString'+relatedAccountIdsString);
  //              if(lead.Company_for_Match_Logic__c == null){
  //                  for(String strAccId : relatedAccountIdsString){
  //                      strAccIdCollection += (strAccIdCollection == '' ? '' : ',') + strAccId;
  //                  }
  //                  lead.Potential_Account_Matches__c = strAccIdCollection;
  //                  lead.Account__c = null;
  //              }else{
  //                  multipleAccountEmailMatches = domainNametoAccountsMap.get(lead.Emaildomain__c);
  //              }
  //              System.debug('multipleAccountEmailMatches=====>>'+multipleAccountEmailMatches);
  //          }
  //      }

  //      Map<Lead, Set<Id>> matchingNamesofLeadtoAccountIdsMap = new Map<Lead, Set<Id>>();
  //      Map<Lead, Set<Account>> matchingNamesofLeadtoAccountsMap = new Map<Lead, Set<Account>>();

  //          if(!multipleAccountEmailMatches.isEmpty()){
  //              for(String strLeadEmail : domainNametoAccountsMap.keySet()){
  //                  for(Account account : domainNametoAccountsMap.get(strLeadEmail)){
  //                      if(account.Name == leadEmailtoNameMap.get(strLeadEmail)){
  //                          if(!matchingNamesofLeadtoAccountIdsMap.containsKey(leadEmailtoLeadRecordMap.get(strLeadEmail))){
  //                              System.debug('account==>'+account);
  //                              matchingNamesofLeadtoAccountIdsMap.put(leadEmailtoLeadRecordMap.get(strLeadEmail), new Set<Id>{account.Id});
  //                              matchingNamesofLeadtoAccountsMap.put(leadEmailtoLeadRecordMap.get(strLeadEmail), new Set<Account>{account});
  //                          }else{
  //                              matchingNamesofLeadtoAccountIdsMap.get(leadEmailtoLeadRecordMap.get(strLeadEmail)).add(account.Id);
  //                              matchingNamesofLeadtoAccountsMap.get(leadEmailtoLeadRecordMap.get(strLeadEmail)).add(account);
  //                          }
  //                      }
  //                      System.debug('account else==>'+account);
		//				system.debug('matchingNamesofLeadtoAccountIdsMap'+matchingNamesofLeadtoAccountIdsMap);
  //                      if(!matchingNamesofLeadtoAccountIdsMap.containsKey(leadEmailtoLeadRecordMap.get(strLeadEmail))){
                            
  //                          String strAccIdCollection = '';
  //                          List<String> relatedAccountIdsString = new List<String> ( (Set<String>)JSON.deserialize(JSON.serialize(domainNametoAccountIdsMap.get(strLeadEmail)), Set<String>.class) );

  //                              for(String strAccId : relatedAccountIdsString){
  //                                  strAccIdCollection += (strAccIdCollection == '' ? '' : ',') + strAccId;
  //                              }
  //                              if(leadEmailtoLeadRecordMap.get(strLeadEmail) != null) {
  //                                  leadEmailtoLeadRecordMap.get(strLeadEmail).Potential_Account_Matches__c = strAccIdCollection;
  //                              }
  //                                  //leadsWithNoAccountNameMatches.add(leadEmailtoLeadRecordMap.get(strLeadEmail));
  //                          	   system.debug('leadsWithNoAccountNameMatches'+leadsWithNoAccountNameMatches);
  //                      }else{
  //                          System.debug('yyyyyyyyyyyyyyyyyyy...');
  //                          if(matchingNamesofLeadtoAccountIdsMap.get(leadEmailtoLeadRecordMap.get(strLeadEmail)).size() == 1)
  //                                  singleLeadAccountNameMatchList.add(leadEmailtoLeadRecordMap.get(strLeadEmail));
  //                              else
  //                                  multipleLeadAccountNameMatchList.add(leadEmailtoLeadRecordMap.get(strLeadEmail));
  //                      }
  //                  }
  //                  if(leadEmailtoLeadRecordMap.get(strLeadEmail) != null) {
  //                      leadsWithNoAccountNameMatches.add(leadEmailtoLeadRecordMap.get(strLeadEmail));
  //                  }
  //                  System.debug('leadsWithNoAccountNameMatches===>'+leadsWithNoAccountNameMatches);
  //              }
  //          }
        
  //       TriggerHandler.bypass('LeadTriggerHandler');
         
  //     if(leadsWithNoAccountNameMatches != null && !leadsWithNoAccountNameMatches.isEmpty())
  //         UPDATE leadsWithNoAccountNameMatches;
  //      TriggerHandler.clearBypass('LeadTriggerHandler');

  //      if(!singleLeadAccountNameMatchList.isEmpty()){ 
  //          for (Lead lead : singleLeadAccountNameMatchList)
  //          {
  //              if(lead.Emaildomain__c <> NULL)
  //                  accoutIdsMatchingwithLeadEmails = matchingNamesofLeadtoAccountIdsMap.get(lead); 
  //              if(lead.Emaildomain__c == NULL && lead.Company_for_Match_Logic__c <> NULL)
  //                  accoutIdsMatchingwithLeadEmails = nametoAccountIdsMap.get(lead.Company_for_Match_Logic__c);         
  //              lead.Account__c = new List<Id> ( accoutIdsMatchingwithLeadEmails )[0]; 
  //              if(accountMap.get(lead.Account__c) != null) {
  //                  if(accountMap.get(lead.Account__c).owner.isActive) {
  //                      lead.OwnerId = accountMap.get(lead.Account__c).OwnerId;
  //                  }
  //              }
  //              lead.Potential_Account_Matches__c = null;
  //              //leadRecordsUpdateforEmailMatch.add(lead);
  //          }
  //           TriggerHandler.bypass('LeadTriggerHandler');
  //            // UPDATE  singleLeadAccountNameMatchList;
  //          TriggerHandler.clearBypass('LeadTriggerHandler');
  //      }   

  //      Map<String,Lead> leadCompanyMatchLogictoLeadMap = new Map<String,Lead>();
  //      Map<Lead,Set<Account>> leadListAccountsMap = new Map<Lead,Set<Account>>();
		//System.debug('multipleLeadAccountNameMatchList>>>'+multipleLeadAccountNameMatchList);
  //      if(!multipleLeadAccountNameMatchList.isEmpty()){
  //          for(Lead lead : multipleLeadAccountNameMatchList){

  //              if(lead.Emaildomain__c <> null){
  //                  leadListAccountsMap.put(lead,matchingNamesofLeadtoAccountsMap.get(lead));
  //              }
  //              if(lead.Emaildomain__c == null && lead.Company_for_Match_Logic__c <> NULL){
  //                  leadListAccountsMap.put(lead,nametoAccountsMap.get(lead.Company_for_Match_Logic__c));    
  //              }

  //              leadCompanyMatchLogictoLeadMap.put(lead.Company_for_Match_Logic__c,lead);

  //          }
  //      }

  //      Map<Lead,Set<Id>> leadtoAccIDStatusMatchMap = new Map<Lead,Set<Id>>();

  //      if(!leadCompanyMatchLogictoLeadMap.isEmpty()){
  //          for(String compnyMatch : leadCompanyMatchLogictoLeadMap.keySet()){
  //              for(Account account: leadListAccountsMap.get(leadCompanyMatchLogictoLeadMap.get(compnyMatch))){
  //                  if(account.Status__c == 'Customer'){

  //                      if(!leadtoAccIDStatusMatchMap.containsKey(leadCompanyMatchLogictoLeadMap.get(compnyMatch)))
  //                          leadtoAccIDStatusMatchMap.put(leadCompanyMatchLogictoLeadMap.get(compnyMatch), new Set<Id> {account.ID});
  //                      else
  //                          leadtoAccIDStatusMatchMap.get(leadCompanyMatchLogictoLeadMap.get(compnyMatch)).add(account.Id);
  //                  }
  //              }

  //              if(!leadtoAccIDStatusMatchMap.containsKey(leadCompanyMatchLogictoLeadMap.get(compnyMatch))){
                    
  //                  if(leadCompanyMatchLogictoLeadMap.get(compnyMatch).Emaildomain__c <> null){
  //                      accountIdsSet = matchingNamesofLeadtoAccountIdsMap.get(leadCompanyMatchLogictoLeadMap.get(compnyMatch));
  //                  }else{
  //                      accountIdsSet = nametoAccountIdsMap.get(compnyMatch);
  //                  }

  //                  String strAccIdCollection = '';
  //                  List<String> relatedAccountIdsString = new List<String> ( (Set<String>)JSON.deserialize(JSON.serialize(accountIdsSet), Set<String>.class) );
  //                  for (String accountId : relatedAccountIdsString)
  //                  {
  //                      strAccIdCollection += (strAccIdCollection==''?'':',')+accountId;
  //                  } 
  //                  leadCompanyMatchLogictoLeadMap.get(compnyMatch).Potential_Account_Matches__c = strAccIdCollection; 

  //                  //Update Lead
  //                  leadsWithNoAccountStatusMatches.add(leadCompanyMatchLogictoLeadMap.get(compnyMatch));
  //                  leadListToUpdate.addAll(leadsWithNoAccountStatusMatches);
  //              }
  //              else{

  //                  if(leadtoAccIDStatusMatchMap.get(leadCompanyMatchLogictoLeadMap.get(compnyMatch)).size()==1){
  //                      leadCompanyMatchLogictoLeadMap.get(compnyMatch).Account__c = new List<Id> ( leadtoAccIDStatusMatchMap.get(leadCompanyMatchLogictoLeadMap.get(compnyMatch)) )[0];
  //                      if(accountMap.get(leadCompanyMatchLogictoLeadMap.get(compnyMatch).Account__c) != null) {
  //                          if(accountMap.get(leadCompanyMatchLogictoLeadMap.get(compnyMatch).Account__c).owner.isActive) {
  //                              leadCompanyMatchLogictoLeadMap.get(compnyMatch).OwnerId = accountMap.get(leadCompanyMatchLogictoLeadMap.get(compnyMatch).Account__c).OwnerId;
  //                          }
  //                      }

  //                  //Update Lead
  //                  leadsWithSinleAccountStatusMatches.add(leadCompanyMatchLogictoLeadMap.get(compnyMatch));
  //                  leadListToUpdate.addAll(leadsWithSinleAccountStatusMatches);
  //                  }
  //                  else
                        
  //                  accountIdsSet = leadtoAccIDStatusMatchMap.get(leadCompanyMatchLogictoLeadMap.get(compnyMatch));
  //                  String strAccIdCollection = '';
  //                  List<String> relatedAccountIdsString = new List<String> ( (Set<String>)JSON.deserialize(JSON.serialize(accountIdsSet), Set<String>.class) );
  //                  for (String accountId : relatedAccountIdsString)
  //                  {
  //                      strAccIdCollection += (strAccIdCollection==''?'':',')+accountId;
  //                  } 
  //                  leadCompanyMatchLogictoLeadMap.get(compnyMatch).Potential_Account_Matches__c = strAccIdCollection; 

  //                  //Update Lead
  //                  leadsWithMultipleAccountStatusMatches.add(leadCompanyMatchLogictoLeadMap.get(compnyMatch));
  //                  leadListToUpdate.addAll(leadsWithMultipleAccountStatusMatches);
  //              }
  //          }
  //      }
  //      leadListToUpdate.addAll(leadsWithsingleEmailMatches);
  //      TriggerHandler.bypass('LeadTriggerHandler');
  //      System.debug('leadListToUpdate=>'+leadListToUpdate.size());
  //      if(!leadListToUpdate.isEmpty()){
  //          System.debug('updateLead==>'+leadListToUpdate);
  //          UPDATE leadListToUpdate;
  //      }
  //      TriggerHandler.clearBypass('LeadTriggerHandler');
  //  }
}