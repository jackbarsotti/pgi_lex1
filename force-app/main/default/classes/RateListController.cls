global with sharing class RateListController {
  private Id accountId;
  private Id scheduleId;
  private Id customScheduleId;
  private String scheduleType;

  public RateListController(ApexPages.StandardController controller) {
    this.accountId = ApexPages.currentPage().getParameters().get('id');    
    this.scheduleId = ApexPages.currentPage().getParameters().get('baseScheduleId');   
    this.scheduleType = ApexPages.currentPage().getParameters().get('scheduleType');   
    this.customScheduleId = ApexPages.currentPage().getParameters().get('customScheduleId');   
  }

  /**
  * Remote Action to get Header Information (i.e. Base Schedule Name, Account Name, Account Number)
  */
  @RemoteAction
  global static Map<String,String> getRateListHeaderInformation(String accountId, String baseScheduleId, String customScheduleId){
    Map<String, String> obj = new Map<String, String>();
    Schedule__c schedule = (Schedule__c) RTDatabaseUtils.getEntireSObject(new Schedule__c(), baseScheduleId);
    Account account = (Account) RTDatabaseUtils.getEntireSObject(new Account(), accountId);

    obj.put('baseScheduleName', schedule.Name);
    obj.put('accountName', account.Name);
    obj.put('accountNumber', account.AccountNumber);
    return obj;
  }

  /**
  * Remote Action to get Header Information (i.e. Base Schedule Name, Account Name, Account Number)
  */
  @RemoteAction
  global static Map<String,String> getRateListHeaderInformationForEdit(String baseScheduleId){
    Map<String, String> obj = new Map<String, String>();
    Schedule__c schedule = (Schedule__c) RTDatabaseUtils.getEntireSObject(new Schedule__c(), baseScheduleId);

    obj.put('baseScheduleName', schedule.Name);
    obj.put('description', schedule.description__c);
    obj.put('objectId', schedule.objectId__c.toPlainString());
    obj.put('scheduleType', schedule.scheduleType__c);
    return obj;
  }  

  /*
  * Remote Action to get a list of Rates by type.  Bundled into a List of RateDTO objects
  */
  @RemoteAction
  global static List<RateDTO> getRatesByType(String customOrStandard, String id, List<String> chargeCodeTypes){
    List<RateDTO> rateDTOList; 

    if('Standard'.equals(customOrStandard)){
      rateDTOList = getRatesByScheduleIdAndChargeCodeType(id, chargeCodeTypes);
    }
    else if('Custom'.equals(customOrStandard)){
      rateDTOList = getRatesByCustomScheduleIdAndChargeCodeType(id, chargeCodeTypes);
    }

    return rateDTOList;
  }

  /*
  * Remote Action to get a list of Rates by schedule id and charge code type.
  */
  @RemoteAction
  global static List<RateDTO> getRatesByScheduleIdAndChargeCodeType(String scheduleId, List<String> chargeCodeTypes){
    Schedule scheduleLookup = new Schedule();
    Schedule__c schedule = scheduleLookup.findByIdAndRateChargeCodeType(scheduleId, chargeCodeTypes);
    Map<Id, RateDTO> chargeCodeToRateDTOMap = new Map<Id, RateDTO>();

    if(schedule == null)
      return chargeCodeToRateDTOMap.values();   

    for (ReadyTalk_Rate__c rate : schedule.ReadyTalk_Rates__r) {      
      RateDTO rateDTO = new RateDTO();             
      Boolean inMap = chargeCodeToRateDTOMap.containsKey(rate.chargeCode__c);  
      Boolean inRange = RTUtils.dateInRange(Date.today(), rate.startDate__c, rate.endDate__c, true, false);

      //If this charge code is not in the map, then we need to add it
      if(!inMap){
        chargeCodeToRateDTOMap.put(rate.chargeCode__c, rateDTO);
      }  

      //See if this is the current rate; if so, then set it on the rateDTO
      if(inRange){
        chargeCodeToRateDTOMap.get(rate.chargeCode__c).currentRate = rate.clone(true,true,true,true);            
      }

      //Add this rate to the List of Base Schedule Rates (keep these separate from overrides).
      if(chargeCodeToRateDTOMap.get(rate.chargeCode__c).baseScheduleRates == null)
        chargeCodeToRateDTOMap.get(rate.chargeCode__c).baseScheduleRates = new List<ReadyTalk_Rate__c>();
          
      chargeCodeToRateDTOMap.get(rate.chargeCode__c).baseScheduleRates.add(rate);
    }

    //Get the List of RateDTO objects from the map
    List<RateDTO> rateDTOList = chargeCodeToRateDTOMap.values();
    
    //Sort the List (see compareTo method on the RateDTO class)
    rateDTOList.sort();
    return rateDTOList;
  }

  /*
  * Remote Action to get a list of Rates by Custom Schedule Id and Charge Code Type
  */
  @RemoteAction
  global static List<RateDTO> getRatesByCustomScheduleIdAndChargeCodeType(String customScheduleId, List<String> chargeCodeTypes){
    CustomSchedule customScheduleLookup = new CustomSchedule();

    //Lookup the custom schedule
    CustomSchedule__c customSchedule = customScheduleLookup.findById(customScheduleId);

    if(customSchedule == null)
      return new List<RateDTO>();

    //Get all of the base schedule rates (as a DTO from the method above)
    List<RateDTO> rateDTOList = getRatesByScheduleIdAndChargeCodeType(customSchedule.baseSchedule__c, chargeCodeTypes);

    //If there are no Rate Override objects associated to this custom schedule, just return the rateDTOList
    if(customSchedule.RateOverrides__r == null)
      return rateDTOList;

    //Iterate through the rateDTO and set current and overrides 
    for(RateDTO rateDTO : rateDTOList){

      Boolean haveEndedBaseScheduleRate = false;

      for(RateOverride__c rateOverride : customSchedule.RateOverrides__r){    
        //Make sure we're adding rate overrides to the correct rate (match it up with it's parent)
        if(rateOverride.chargeCode__c == rateDTO.currentRate.chargeCode__c){

          /*
          //Need to put an "end date" on the standard schedule that has a NULL end date (if and only if this override also has a null end date)
          for(ReadyTalk_Rate__c baseScheduleRate : rateDTO.baseScheduleRates){
            if(!haveEndedBaseScheduleRate && 
              (baseScheduleRate.endDate__c == null || baseScheduleRate.endDate__c >= Date.newInstance(3000, 1, 1)) 
              && RTUtils.dateInRange(rateOverride.startDate__c, baseScheduleRate.startDate__c, baseScheduleRate.endDate__c, true, true)){
                baseScheduleRate.endDate__c = rateOverride.startDate__c;              
                haveEndedBaseScheduleRate = true;
            }
          }
          */

          //Set this override to the current rate if it's in range
          if(RTUtils.dateInRange(Date.today(), rateOverride.startDate__c, rateOverride.endDate__c, true, false)){                        
            rateDTO.currentRate.ReadyTalk_rate__c = rateOverride.ReadyTalk_rate__c;
            rateDTO.currentRate.startDate__c = rateOverride.startDate__c;
            rateDTO.currentRate.endDate__c = rateOverride.endDate__c;
          }
          
          //Add this override to the list
          if(rateDTO.rateOverrides == null)
            rateDTO.rateOverrides = new List<RateOverride__c>();

          rateDTO.rateOverrides.add(rateOverride);
        }
      }
    }

    return rateDTOList;
  }

  /*
  * Remote Action to get Rates from an Account Id, Charge Code Types and Schedule Type
  */
  @RemoteAction 
  global static List<RateDTO> getAccountRates(String accountId, List<String> chargeCodeTypes, String scheduleType){
    CustomSchedule customScheduleLookup = new CustomSchedule();
    List<RateDTO> rateDTOList = new List<RateDTO>();

    List<CustomSchedule__c> customSchedules = customScheduleLookup.findByAccountId(accountId);
    for(CustomSchedule__c customSchedule : customSchedules){
      if(customSchedule.baseScheduleType__c.equals(scheduleType) && customSchedule.isDefault__c){
        rateDTOList = getRatesByCustomScheduleIdAndChargeCodeType(customSchedule.Id, chargeCodeTypes);
        break;
      }
    }

    return rateDTOList;
  }

  /*
  * Remote Action to create a custom schedule and save rate overrides under that custom schedule
  */
  @RemoteAction
  global static void saveNewCustomScheduleAndRateOverrides(String accountId, String baseScheduleId, String name, String description, String rateChangeStartDate, Map<String,String> rateOverrides){
    /* SFB-1071: Need to be able to add/create new custom schedule without making a rate change.
    if(rateOverrides==null || rateOverrides.isEmpty())
      throw new ValidationException('You must change at least one rate.');  
    */

    CustomSchedule customScheduleRepo = new CustomSchedule();
    CustomSchedule__c newCustomSchedule = customScheduleRepo.saveCustomSchedule(name, accountId, baseScheduleId, description, false);
    saveRateOverrides(newCustomSchedule.Id, rateChangeStartDate, rateOverrides);
  }

  /*
  * Remote Action to save rate overrides and end the latest rate override
  */
  @RemoteAction
  global static void saveRateOverrides(String customScheduleId, String rateChangeStartDate, Map<String,String> rateOverrides){
    RateOverride roRepo = new RateOverride();

    for(String key : rateOverrides.keySet()){

      //Expire the most current rate override
      roRepo.expirePreviousOverride(key, customScheduleId, rateChangeStartDate);

      //Save the new Rate Override
      roRepo.saveRateOverride(key, customScheduleId, key+'-override', Decimal.valueOf(rateOverrides.get(key).replaceAll('\\$', '')), rateChangeStartDate, null);
    }  
  }

  /*
  * Remote Action to save base rate overrides and end the latest rateOverride if it meets or exceeds the entered price
  */
  @RemoteAction
  global static String saveBaseScheduleRateOverride(String scheduleId, String rateChangeStartDate, String name, String description, String objectId, String scheduleType, String endRateOverrides, Map<String,String> rateOverrides){
    Rate rateRepo = new Rate();
    RateOverride rateOverrideRepo = new RateOverride();
    Schedule scheduleRepo = new Schedule();    

    //Save the schedule information
    Schedule__c s = (Schedule__c) new Schedule.builderValidator()
      .forObject(new Schedule__c())
      .set('id', scheduleId)
      .set('name', name)
      .set('description__c', description)
      .set('scheduleType__c', scheduleType)
      .set('objectId__c', Double.valueOf(objectId))
      .buildAndValidate()
      .save();    

    if(rateOverrides.size() > 1){
      throw new ValidationException('Cannot end more than one base schedule rate at a time.  Do them separately!');
    }

    if(rateOverrides.size() <= 0){
     throw new ValidationException('You must change at least one base schedule rate!'); 
    }      

    Double maxRateObjectId = rateRepo.findMaxObjectId(Rate.table);    
    String updated = '';

    for(String chargeCodeId : rateOverrides.keySet()){      
      Decimal newRate = Decimal.valueOf(rateOverrides.get(chargeCodeId).replaceAll('\\$', ''));    

      //Expire the base rate being changed
      rateRepo.expirePreviousRate(chargeCodeId, scheduleId, rateChangeStartDate);

      //Save the new rate
      rateRepo.saveRate(chargeCodeId, chargeCodeId, rateChangeStartDate, newRate, scheduleId, null, maxRateObjectId+1);

      //Save ALL rate overrides that do no exceed the new rate
      if('on'.equals(endRateOverrides)){
        List<RateOverride__c> ros = rateOverrideRepo.findByBaseScheduleAndChargeCodeAndNullEndDateAndRateAbove(scheduleId, chargeCodeId, newRate);

        for(RateOverride__c ro : ros){
          Date d = Date.parse(rateChangeStartDate);
          if(ro.startDate__c > d)
            ro.endDate__c = ro.startDate__c;
          else
            ro.endDate__c = Date.parse(rateChangeStartDate);
        }

        try{
          Database.update(ros);       
          updated = updated+'Updated '+ros.size()+' Rate Override Records.';             

        }
        catch (Exception e){
          throw new ValidationException('Error while saving: '+e.getMessage());
        }      
      }
    }    

    return updated;
  }

  public String getAccountId() {
    return this.accountId;
  }

  public String getScheduleId() {
    return this.scheduleId;
  } 

  public String getCustomScheduleId() {
    return this.customScheduleId;
  }

  public String getScheduleType() {
    return this.scheduleType;
  }

}