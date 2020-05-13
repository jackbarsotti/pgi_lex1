trigger OnAccountOwnerChangetrigger on Account (after update) {
        
      system.debug('Entered OnAccountOwnerChangeTrigger');

      Set<Id> accountIds = new Set<Id>();
      Map<Id, String> oldOwnerIds = new Map<Id, String>();
      Map<Id, String> newOwnerIds = new Map<Id, String>();
      List<Lead> leadstoupdate = new List<Lead>();
      List<Contact> contactstoupdate = new List<Contact>();
      List<Opportunity> oppstoupdate = new List<Opportunity>();
      Map<ID,Schema.RecordTypeInfo> rt_Map = Account.sObjectType.getDescribe().getRecordTypeInfosById();
      //get account info      
      for (Account a : Trigger.new)
      {
         if (rt_map.get(a.recordTypeID).getName().containsIgnoreCase('PGi') && a.Exclude_from_Integration__c == False && a.OwnerId != Trigger.oldMap.get(a.Id).OwnerId)
         {
            oldOwnerIds.put(a.Id, Trigger.oldMap.get(a.Id).OwnerId);
            newOwnerIds.put(a.Id, a.OwnerId);
            accountIds.add(a.Id);
         }
         
      }
      if (!accountIds.isEmpty()) 
      {
      // update leads
          for(Lead ld :[select Id,ownerid,account__c,ISCONVERTED,status from Lead where account__c in :accountIds])
          {
              String newOwnerId = newOwnerIds.get(ld.account__c);
              String oldOwnerId = oldOwnerIds.get(ld.account__c);
              if (ld.OwnerId == oldOwnerId && ld.ISCONVERTED == False && ld.status <> 'Disqualified')
              {
                  Lead updatedlead = new Lead(Id = ld.Id, OwnerId = newOwnerId);
                  leadstoupdate.add(updatedlead);
              }
          }
      // update contacts                  
          for (Account acc : [SELECT Id, (SELECT Id, OwnerId, owner.isactive,owner.name FROM Contacts) FROM Account WHERE Id in :accountIds])
          {
              String newOwnerId = newOwnerIds.get(acc.Id);
              String oldOwnerId = oldOwnerIds.get(acc.Id);
              for (Contact c : acc.Contacts)
              {
                  if (c.OwnerId == oldOwnerId || c.owner.isactive == False || c.owner.name == 'Sales & Marketing Database')
                  {
                      system.debug('ARC debug contact owner active: ' +c.owner.isactive);
                      system.debug('ARC debug contact owner name: ' +c.owner.name);
                      Contact updatedContact = new Contact(Id = c.Id, OwnerId = newOwnerId);
                      contactstoupdate.add(updatedContact);
                  }    
              }
          }
          // update opportunities
          for(Opportunity opp :[select Id,ownerid,accountid,ISCLOSED from Opportunity where accountid in :accountIds])
          {
              String newOwnerId = newOwnerIds.get(opp.accountid);
              String oldOwnerId = oldOwnerIds.get(opp.accountid);
              if (opp.OwnerId == oldOwnerId && opp.ISCLOSED == False)
              {
                  Opportunity updatedopp = new Opportunity(Id = opp.Id, OwnerId = newOwnerId);
                  oppstoupdate.add(updatedopp);
              }
          }
          if(!leadstoupdate.isEmpty())
              update leadstoupdate;
          if(!contactstoupdate.isEmpty()) 
           update contactstoupdate; 
          if(!oppstoupdate.isEmpty())
              update oppstoupdate;  
       }
}