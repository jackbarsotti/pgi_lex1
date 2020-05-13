public class RTEventCloseController {
    
    private RTEvent__c event;
    private RTEventClose__c eventClose;
    
    private ApexPages.StandardController stdController;
    
    private List<OtherChargeCredit__c> postedCharges;
    private List<OtherChargeCredit__c> previewCharges = null;

    
    /* initializer method.
     * gets the parent event object, and any charges/credits that are associated
     * with this event.
     */
    public RTEventCloseController(ApexPages.StandardController controller) {
        stdController = controller;
        
        system.debug('Getting eventClose from standard controller..');
        eventClose = (RTEventClose__c)controller.getRecord();
        String eventID = eventClose.RT_Event__c;
        system.debug('EventClose record is ' + controller.getRecord());
        system.debug('Event id is ' + eventID);
        if (eventID != null) {
          event = (RTEvent__C)RTDatabaseUtils.getEntireSObject(new RTEvent__c(), eventID);
          system.debug('Found event: ' + event);
        }
        
        postedCharges = findPostedOtherChargeCredit();
        
    }
    
    public PageReference cancel() {
      PageReference eventPage = new ApexPages.StandardController(event).view();
      eventPage.setRedirect(true);
      return eventPage;
    }
    
    
    /* calls doSave and implements error handling. */
    public void save() {
      try {
         doSave();
      } catch (DmlException ex) {
        ApexPages.addMessages(ex);
      }
    }
    
    /* does the actual save of the object. Throws DMLException if error */
    private void doSave() {
      update eventClose;
      update event;
    }
    
    
    private boolean validateForOCC() {
    
      if (event.Event_Date__c == null) {
        throw new NotFoundException('The Event Date must be populated before closing the Event. Click the Cancel button to return to the RT Event.');
      }
      
      if (event.Broadcast_Audio_Event_Duration2__c == null || event.Broadcast_Audio_Event_Participants__c == null) { 
        throw new NotFoundException('Total Participants and Event Duration fields must be populated before before previewing or posting charges.');
      }
      
      return true;
    }
    
    /* Controller method to handle Preview button action (with reRender tag).
     * Calls the charge calc method and then stores the result
     * for the VIEW to access.
    */
    public void preview() {
      try {
        previewCharges = null;
        doSave();
        
        // throws exception if something is missing.
        validateForOCC();
       
        previewCharges = calculateOtherChargesCredits();
      } catch (Exception ex) {
        ApexPages.addMessages(ex);
      } 
        
    }
    
    
    /* Controller method to handle the Post button action 
     * Calls the charge calc method and then inserts
     * each record.
    */
    public void post() {
    
      try {
        previewCharges = null;
        doSave();
        
        // throws exception if something is missing.
        validateForOCC();
        
        SavePoint sp = Database.setSavePoint();
        
        try {
          for (OtherChargeCredit__c occ: calculateOtherChargesCredits()) {
            insert occ;
          }
          
        } catch (DMLException dbEx) {
          Database.rollback(sp);
          ApexPages.addMessages(dbEx);
        }
        
        postedCharges = findPostedOtherChargeCredit();
         
      } catch (Exception ex) {
        ApexPages.addMessages(ex);
      } 

    }
    

    /* does a query to find any charges and credits related to this event. */
    private List<OtherChargeCredit__c> findPostedOtherChargeCredit() {
        System.debug('Getting OtherChargeCredit for event.');
        List<OtherChargeCredit__c>  charges = null;
        if (event != null) {
            System.debug('Searching based on event id: ' + event.Id);
        charges =  [select Id, Name, AccessCode__c, Account_Name__c, BilledDate__c, ChargeOrCredit__c, 
                 Contact_Name__c, Description__c, Product__c, RTEventName__c, ServiceDate__c from OtherChargeCredit__c WHERE RTEventName__c = :event.Id];
        } else {
            System.debug('No event record found. Skipping OCC lookup.');
        }
        
        return charges;
    }
    
    private List<OtherChargeCredit__c> calculateOtherChargesCredits() {
      system.debug('Enter calculateOtherChargesCredits');
      List<OtherChargeCredit__c> charges = new List<OtherChargeCredit__c>();
      system.debug('calling to calc additional minute charge');
      Decimal additionalMinuteCharge = calcAdditionalMinuteCharge();
      
      system.debug('Calling to calc additional participants charge');
      Decimal additionalParticipantCharge = calcAdditionalParticipantCharge();
      
      system.debug('adding base price charge');
      charges.add(buildOCCRecord('Base Price', eventClose.Base_Event_Charge__c));
      
      if (additionalMinuteCharge > 0) {
        system.debug('creating occ record for additional minutes');
        charges.add(buildOCCRecord('Additional Minutes', additionalMinuteCharge));
      }
      if (additionalParticipantCharge > 0) {
        system.debug('creating occ record for additional participants');
        charges.add(buildOCCRecord('Additional Participants', additionalParticipantCharge));
      }
      system.debug('Is internaltional tollfree booked?');
      Decimal intlTollFreeAddOn = calcIntlTollFreeAddOn();
      if (event.Int_l_Toll_Free_Booked__c == true && intlTollFreeAddOn > 0) {
        system.debug('yes it is');
        charges.add(buildOCCRecord('International Toll-Free Add-On', intlTollFreeAddOn));
      }
      
      system.debug('Checking support type for live event monitoring... support type is: '+event.Support_type__c);
      if ((event.Support_Type__c != null && event.Support_Type__c.startsWith('100%'))
          && ('Gold Event'.equalsIgnoreCase(event.Broadcast_Audio_Type__c) || 'Stand Alone'.equalsIgnoreCase(event.Broadcast_Audio_Type__c))
          && event.First_Presenter_Event__c == false 
          && event.First_Organizer_Event__c == false) {
            charges.add(buildOCCRecord('Full Live Event Monitoring & Support', eventClose.Live_Event_Monitoring_Rate__c));
      }
      
      system.debug('checking for op-assist add-on.');
      if ('Operator Assisted Premium'.equalsIgnoreCase(event.RT_Event_type__c) 
         && ('Platinum Event'.equalsIgnoreCase(event.Broadcast_Audio_Type__c) || 'Gold Event'.equalsIgnoreCase(event.Broadcast_Audio_Type__c))) {
          charges.add(buildOCCRecord('Premium Op-Assist Add-On', eventClose.Premium_Op_Assist_Rate__c));
      }

      system.debug('done creating occ records for preview/post');
      return charges;
    }

    private OtherChargeCredit__c buildOCCRecord(String chargeType, Decimal charge) {
      OtherChargeCredit__c occ = new OtherChargeCredit__c();
      Date serviceDate = event.Event_Date__c;
      occ.ServiceDate__c = serviceDate;
      occ.RTEventName__c = event.Id;
      List<Subscription__c> subList = [select Name from Subscription__c where Id = :event.Access_Code__c limit 1];
      String subscrName = '-';
      if (subList != null && subList.size() > 0) {
        subscrName = subList.get(0).Name;
      }
      String description = 'Total Participants: {0} Duration: {1} Access Code: {2}';
      String[] arguments = new String[] {String.valueOf(event.Broadcast_Audio_Event_Participants__c), 
          String.valueOf(event.Broadcast_Audio_Event_Duration2__c != null ? event.Broadcast_Audio_Event_Duration2__c : 0), 
          subscrName};
      occ.Description__c = String.format(description, arguments);
      occ.Product__c = getProduct(chargeType);
      occ.ChargeOrCredit__c = charge;
      occ.AccessCode__c = event.Bill_to_Access_Code__c;
      
      return occ;
    }
    
    private String getProduct(String chargeType) {
      String product = 'Charge - ';
      if (event.Broadcast_Audio_Type__c != null) {
        if (event.Broadcast_Audio_Type__c.equals('Gold Event')) {
          product += 'Gold Webinar - ';
        } else if (event.Broadcast_Audio_Type__c.equals('Platinum Event')) {
          product += 'Platinum Webinar - ';
        } else {
          product += 'Broadcast Audio - ';
        }
      } else {
        product += 'Broadcast Audio - ';
      }
      return product += chargeType;
    }
    
    private Decimal calcAdditionalMinuteCharge() {
      
      Integer participants = Integer.valueOf(event.Broadcast_Audio_Event_Participants__c);
      Integer duration = Integer.valueOf(event.Broadcast_Audio_Event_Duration2__c);
      Decimal rate = eventClose.Additional_Minutes_Rate__c;
      Decimal charge = 0;
      Integer timeOverageUnits = calcTimeOverageUnits(duration);
      system.debug('Additional minute units = ' + timeOverageUnits);
      
      charge = rate * (timeOverageUnits * (calcParticipantOverageUnits(participants)+1));
      
      system.debug('additonal minutes charge is ' + charge);
      return charge;
    }
        
    private Decimal calcAdditionalParticipantCharge() {
      Integer participants = Integer.valueOf(event.Broadcast_Audio_Event_Participants__c);
      Decimal rate = eventClose.Additional_Participants_Rate__c;
      Decimal charge = 0;
      
      charge = rate * calcParticipantOverageUnits(participants);
      
      system.debug('participant charge is ' + charge);
      
      return charge;
    }
    
    private Integer calcTimeOverageUnits(Integer duration) {
      Integer includedMinutes = 70;
      Double minutesPerUnit = 30;
      Integer overageUnits = 0;
      system.debug('CalcTimeOverageUnits - duration is ' + duration);
      if (duration > includedMinutes) {
        // find out which 'incremental block of time' the conf falls into.
        overageUnits = Integer.valueOf(Math.ceil((duration - includedMinutes) / minutesPerUnit));
        system.debug('CalcTimeOverageUnits - overage units is ' + overageUnits);
      }
      return overageUnits;
    }
    
    private Integer calcParticipantOverageUnits(Integer participants) {
      Integer includedParticipants = 110;
      Double participantsPerUnit = 100;
      Integer overageUnits = 0;
      
      if (participants > includedParticipants) {
        overageUnits = Integer.valueOf(Math.ceil((participants - includedParticipants)/participantsPerUnit));
      }
      return overageUnits;
    }
    
    private Decimal calcIntlTollFreeAddOn() {
      Decimal rate = eventClose.ITF_Add_on_Rate__c;
      Decimal linesReserved = event.Total_lines_reserved__c;
      Decimal charge = 0;
      
      if ( linesReserved != null && ('Gold Event'.equalsIgnoreCase(event.Broadcast_Audio_Type__c) || 'Platinum Event'.equalsIgnoreCase(event.Broadcast_Audio_Type__c)) ) {
        charge = rate * Math.ceil(linesReserved/10);
      }
      return charge;
    }
    
    /* Getter to put the parent event on the VIEW layer */
    public RTEvent__c getEvent() {
        return event;
    }
    
    /* Getter for unit testing */
    public RTEventClose__c getEventClose() {
        return eventClose;
    }

    
    /* Getter to put any preview OtherChargeCredit on the VIEW layer */
    public List<OtherChargeCredit__c> getPostedOtherChargeCredit() {
      return postedCharges;
    }
    
    /* getter to get preview values for VIEW layer */
    public List<OtherChargeCredit__c> getPreviewOtherChargeCredit() {
      return previewCharges;
    }
}