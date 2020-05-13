public class RTEventActions {
  /**
  * Update all RTEvent Coordinator_Notes_New__c and Event_Manager_Notes_New__c
  */
  public static void updateRTEventNotes(List<RTEvent__c> events){
    Set<Id> accountIds = new Set<Id>(); 
    Set<Id> eventIds = new Set<Id>();

    for(RTEvent__c event : events){
      eventIds.add(event.Id);
      if(!String.isBlank(event.Account__c)) {
        accountIds.add(event.Account__c);
      }
    }
    Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, (SELECT Id FROM Rates__r LIMIT 1) FROM Account WHERE Id IN: accountIds]);
    List<RTEvent__c> fullEvents = (List<RTEvent__c>) [select Id, Access_Code__r.Coordinator_Notes_New__c, Access_Code__r.Event_Manager_Notes_New__c from RTEvent__c where Id in :eventIds];

    for(RTEvent__c event: events) {
      Account acct = accounts.get(event.Account__c);
      if(acct != null && acct.Rates__r.size() > 0) {
        event.Event_Webcasting_Rates__c = acct.Rates__r[0].Id;
      }
    }
    //Modify the values
    for(RTEvent__c fullEvent : fullEvents){  
      for(RTEvent__c event : events){
        if(fullEvent.Id == event.Id){
          if(fullEvent.Access_Code__r.Coordinator_Notes_New__c != null && !fullEvent.Access_Code__r.Coordinator_Notes_New__c.equals(event.Coordinator_Notes_New__c))
            event.Coordinator_Notes_New__c = fullEvent.Access_Code__r.Coordinator_Notes_New__c;

          if(fullEvent.Access_Code__r.Event_Manager_Notes_New__c != null && !fullEvent.Access_Code__r.Event_Manager_Notes_New__c.equals(event.Event_Manager_Notes_New__c))
            event.Event_Manager_Notes_New__c = fullEvent.Access_Code__r.Event_Manager_Notes_New__c;
        }
      }    
    }
  }

  /**
  * SFB-1361
  * When an eventManager__c is assigned, then create or update an Event record with a 15 minute reminder and assign it to the user that matches the eventManager__c Id
  * Caveat: I'm not a fan of this code.  -B.A.A
  */
  public static void addEventRecords(Map<Id,RTEvent__c> rtevents, Map<Id,RTEvent__c> oldrtevents){    
    //Ids of all RTEvent__c records currently being handled
    Set<Id> rtEventIds = rtevents.keySet();

    //Query related objects and get Full RTEvent__c objects
    List<RTEvent__c> fullEvents = (List<RTEvent__c>) [select Id, eventManager__c, status__c, Reservation__c, Audio_Provider__c, EM_Role__c, Support_Type__c, account__r.Name, Access_Code__r.name, DenverStartTime__c, Denver_End_Time__c from RTEvent__c where Id in :rtEventIds];    

    //Query existing Event records (for updating)
    List<Event> existingEventRecords = (List<Event>) [select Id, WhatId from Event where WhatId in :rtEventIds];

    //Create a map of RTEvent__c.Id -> Event
    Map<Id,Event> rtEventIdToExistingEvent = new Map<Id,Event>();
    for(Event e : existingEventRecords){
      rtEventIdToExistingEvent.put(e.WhatId, e);
    }

    //Create a map of RTEvent__c.Id -> RTEvent.eventManager__c
    //And a map of RTEvent__c.Id => full RTEvent__c record
    Map<Id,Id> rteventIdToUserId = new Map<Id,Id>();
    Map<Id,RTEvent__c> fullRTEvents = new Map<Id,RTEvent__c>();  
    for(RTEvent__c rtevent : fullEvents){      
          rteventIdToUserId.put(rtevent.Id, rtevent.eventManager__c);
      fullRTEvents.put(rtEvent.Id, rtevent);
    }

    //Do 1 query to select all users who exist in the rtEventIdToUserName map
    List<Id> userIds = rteventIdToUserId.values();
    List<User> users = (List<User>) [select Id from User where Id in :userIds];

    List<Event> eventsToUpsert = new List<Event>();
    List<Event> eventsToDelete = new List<Event>();

    //Recurse through rtEventIdToUserName map and match up user records
    for(Id rteventId : rteventIdToUserId.keySet()){
      RTEvent__c fullrtEvent = fullRTEvents.get(rteventId);      

      String userId = rteventIdToUserId.get(rteventId);

      //If the userId is null (i.e. rtevent.eventManager__c is null/blank then remove the event record)
      if(userId == null){
        Event eventToDelete = rtEventIdToExistingEvent.get(rtEventId);   
         
          if(eventToDelete != null)   
          eventsToDelete.add(eventToDelete);
      }
      else{
        //Don't create an Event if this RTEvent has one of the following status__c settings
        if('CANCELLED' == fullrtEvent.status__c || 'Closed' == fullrtEvent.status__c || 'DUPLICATE' == fullrtEvent.status__c)
          continue;
        
        for(User u : users){
          if(u.Id == userId){  

            //Update existing Event record
            Event eventToUpsert = rtEventIdToExistingEvent.get(rtEventId);

            //Insert a new Event record
            if(eventToUpsert == null)                  
              eventToUpsert = new Event();

            eventToUpsert.Subject = fullrtEvent.account__r.Name+' '+fullrtEvent.support_type__c;
            eventToUpsert.Description = fullrtEvent.Reservation__c+','+fullrtEvent.Access_Code__r.name+','+fullrtEvent.Audio_Provider__c+','+fullrtEvent.EM_Role__c;
            eventToUpsert.OwnerId = u.Id;
            eventToUpsert.StartDateTime = fullrtEvent.DenverStartTime__c;
            eventToUpsert.EndDateTime = fullrtEvent.Denver_End_Time__c;
            eventToUpsert.WhatId = fullrtEvent.Id;
            eventToUpsert.ReminderDateTime = DateTime.newInstance(fullrtEvent.DenverStartTime__c.addMinutes(-15).date(), fullrtEvent.DenverStartTime__c.addMinutes(-15).time());
            eventToUpsert.IsReminderSet = true;
            eventsToUpsert.add(eventToUpsert);
          }
        }
      }
    }
    upsert(eventsToUpsert);
    delete(eventsToDelete);
  }         
}