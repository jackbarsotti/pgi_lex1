public with sharing class RTEventCloseDispatcher {
  //Webinar_Package_Additional_Participants__c
  //Premium_Operator_Assisted_Add_On__c
  //Broadcast_Audio_Base_Amount__c
  //Gold_Webinar_Base_Amount__c
  //Platinum_Webinar_Base_Amount__c
  //Webinar_Package_Additional_Minutes__c
  //Broadcast_Audio_Additional_Minutes__c
  //Broadcast_Audio_Additional_Participants__c
  //ITF_Add_On__c
  //Live_Event_Monitoring__c
  //Premium_Operator_Assisted_Add_On__c
  private RTEvent__c rtEvent;
  public static List<String> additionalFields = new String[] {
    'Access_Code__c',
    'Name',
    'Bill_to_Access_Code__c',
    'Broadcast_Audio_Type__c',
    'Broadcast_Audio_Event_Duration2__c',
    'Broadcast_Audio_Event_Participants__c',
    'Bill_to_Access_Code__r.Contact__r.AccountId'
    //'Bill_to_Access_Code__r.Contact__r.Account.Gold_Webinar_Base_Amount__c',
    //'Bill_to_Access_Code__r.Contact__r.Account.Platinum_Webinar_Base_Amount__c',
    //'Bill_to_Access_Code__r.Contact__r.Account.Broadcast_Audio_Base_Amount__c',
    //'Bill_to_Access_Code__r.Contact__r.Account.Webinar_Package_Additional_Minutes__c',
    //'Bill_to_Access_Code__r.Contact__r.Account.Broadcast_Audio_Additional_Minutes__c',
    //'Bill_to_Access_Code__r.Contact__r.Account.Webinar_Package_Additional_Participants__c',
    //'Bill_to_Access_Code__r.Contact__r.Account.Broadcast_Audio_Additional_Participants__c',
    //'Bill_to_Access_Code__r.Contact__r.Account.ITF_Add_On__c',
    //'Bill_to_Access_Code__r.Contact__r.Account.Live_Event_Monitoring__c',
    //'Bill_to_Access_Code__r.Contact__r.Account.Premium_Operator_Assisted_Add_On__c'
  };

  public RTEventCloseDispatcher(ApexPages.StandardController controller) {
    if (!Test.isRunningTest()) {
      controller.addFields(additionalFields);
    }
    rtEvent = (RTEvent__c)controller.getRecord();
    rates = [SELECT Id, Webinar_Package_Additional_Participants__c,
                 Premium_Operator_Assisted_Add_On__c,
                 Broadcast_Audio_Base_Amount__c,
                 Gold_Webinar_Base_Amount__c,
                 Platinum_Webinar_Base_Amount__c,
                 Webinar_Package_Additional_Minutes__c,
                 Broadcast_Audio_Additional_Minutes__c,
                 Broadcast_Audio_Additional_Participants__c,
                 ITF_Add_On__c,
                 Live_Event_Monitoring__c 
              FROM Event_Webcasting_Rates__c 
              WHERE Related_Account__c =: rtEvent.Bill_to_Access_Code__r.Contact__r.AccountId LIMIT 1];
  }
  private Event_Webcasting_Rates__c rates {get; set;}
  public PageReference createEventClose() {       
    PageReference redir = new PageReference('/apex/RTEventClose');
    RTEventClose__c rtEventClose = getRTEventClose();
    redir.getParameters().put('id', rtEventClose.id);

    return redir;
  }
  
  private RTEventClose__c getRTEventClose() {
    List<RTEventClose__c> rtEventCloseList = [SELECT Id FROM RTEventClose__c where RT_Event__c = :rtEvent.id LIMIT 1];
    if (rtEventCloseList.size() > 0) {
      return rtEventCloseList.get(0);
    } else {
      return createRTEventClose();
    }
  }
  
  private RTEventClose__c createRTEventClose() {
    RTEventClose__c rtEventClose = new RTEventClose__c();
    rtEventclose.RT_Event__c = rtEvent.Id;
    rtEventclose.Name = rtEvent.Name;
    
    rtEventclose.Base_Event_Charge__c = getBaseEventCharge();
    rtEventclose.Additional_Minutes_Rate__c = getAdditionalMinuteRate();
    rtEventclose.Additional_Participants_Rate__c = getAdditionalParticipantRate();
    rtEventclose.ITF_Add_on_Rate__c = getITFAddonRate();
    rtEventclose.Live_Event_Monitoring_Rate__c = getLiveEventMonitoringRate();  
    rtEventclose.Premium_Op_Assist_Rate__c = getPremiumOpAssistRate();
    
    insert rtEventClose;
    
    return rtEventClose;
  }
  
  private Decimal getBaseEventCharge() {
    Decimal charge;
    if (rtEvent.Broadcast_Audio_Type__c != null) {
      if (rtEvent.Broadcast_Audio_Type__c.equals('Gold Event')) {
        charge = rates.Gold_Webinar_Base_Amount__c;
      } else if (rtEvent.Broadcast_Audio_Type__c.equals('Platinum Event')) {
        charge = rates.Platinum_Webinar_Base_Amount__c;
      } else {
        charge = rates.Broadcast_Audio_Base_Amount__c;
      }
    }
    return (charge == null ? 0 : charge);
  }
  
  private Decimal getAdditionalMinuteRate() {
    Decimal rate = 0.00;
    if (rtEvent.Broadcast_Audio_Type__c != null) {
      if (rtEvent.Broadcast_Audio_Type__c.equals('Gold Event') || rtEvent.Broadcast_Audio_Type__c.equals('Platinum Event')) {
        rate = rates.Webinar_Package_Additional_Minutes__c;
      } else {
        rate = rates.Broadcast_Audio_Additional_Minutes__c;
      }
    }
    return rate;
  }

  private Decimal getAdditionalParticipantRate() {
    Decimal rate = 0.00;
    if (rtEvent.Broadcast_Audio_Type__c != null) {
      if (rtEvent.Broadcast_Audio_Type__c.equals('Gold Event') || rtEvent.Broadcast_Audio_Type__c.equals('Platinum Event')) {
        rate = rates.Webinar_Package_Additional_Participants__c;
      } else {
        rate = rates.Broadcast_Audio_Additional_Participants__c;
      }
    }
    return rate;
  }
  
  private Decimal getITFAddonRate() {
  	return ((rates.ITF_Add_On__c == null) ? 0.00 : 
  	    rates.ITF_Add_On__c);
  }
  
  private Decimal getLiveEventMonitoringRate() {
  	return ((rates.Live_Event_Monitoring__c == null) ? 0.00 : 
  	    rates.Live_Event_Monitoring__c);
  }

  private Decimal getPremiumOpAssistRate() {
  	return  ((rates.Premium_Operator_Assisted_Add_On__c == null) ? 0.00 : 
  	    rates.Premium_Operator_Assisted_Add_On__c);
  }
}