global with sharing class PlanController {  
  
  private final Account a;
  private final List<Plan__c> plans;
  private final List<SingleChargeOverride__c> singleChargeOverrides;
  private final List<RecurringChargeOverride__c> recurringChargeOverrides;
  private final List<ScheduleOverride__c> scheduleOverrides;
  private List<PlanQuantityHistory__c> planQuantityHistorys;

  private final Plan__c plan;
  private final SingleChargeOverride singleChargeOverrideLookup = new SingleChargeOverride();
  private final RecurringChargeOverride recurringChargeOverrideLookup = new RecurringChargeOverride();
  private final ScheduleOverride scheduleOverrideLookup = new ScheduleOverride();
  private final PlanQuantityHistory planQuantityHistoryLookup = new PlanQuantityHistory();
  private final Plan planLookup = new Plan();

  private Map<String, Map<String,List<Object>>> npOverrides;
  private Map<String, OverridesDTO> currentNpOverrides;
  private Map<String, OverridesTotalDTO> currentPlanTotals;
  private Map<String, Boolean> npFutureChanges;
  private Map<String, Integer> activeCounts;

  private String futureQuantityChanges = 'No';
  private Boolean hasQuantityHistorys = false;
   
  public PlanController(ApexPages.StandardController controller) {
    this.a = (Account)controller.getRecord();    
    this.plans = planLookup.getPlansByAccountId(a.id);
    this.singleChargeOverrides = singleChargeOverrideLookup.findByAccountId(a.id);
    this.recurringChargeOverrides = recurringChargeOverrideLookup.findByAccountId(a.id);
    this.scheduleOverrides = scheduleOverrideLookup.findByAccountId(a.id);

    populateCurrentOverridesMap(this.plans,this.singleChargeOverrides,this.recurringChargeOverrides,this.scheduleOverrides);
    populateActiveCounts(this.plans);
    populateFutureChangesMap(this.plans,this.singleChargeOverrides,this.recurringChargeOverrides,this.scheduleOverrides);    
  }    
  
  public PlanController() {
    Id accountId = ApexPages.currentPage().getParameters().get('accountId');
    Id planId = ApexPages.currentPage().getParameters().get('planId');
    this.a = (Account) [select id,name from Account where id =: accountId limit 1];
    this.plan = planLookup.getById(planId);
    this.singleChargeOverrides = singleChargeOverrideLookup.findByAccountId(a.id);
    this.recurringChargeOverrides = recurringChargeOverrideLookup.findByAccountId(a.id);
    this.scheduleOverrides = scheduleOverrideLookup.findByAccountId(a.id);

    populateCurrentOverridesMap(new List<Plan__c>{this.plan},this.singleChargeOverrides,this.recurringChargeOverrides,this.scheduleOverrides);
    populateActiveCounts(new List<Plan__c>{this.plan});
    populateFutureChangesMap(new List<Plan__c>{this.plan},this.singleChargeOverrides,this.recurringChargeOverrides,this.scheduleOverrides);    
    populateOverridesMap(this.plan);
  }
  
  private void populateOverridesMap(Plan__c plan) {    	
    Map<String, Map<String, List<Object>>> npOverrides = new Map<String, Map<String, List<Object>>>();
    for(NegotiatedProduct__c np : plan.NegotiatedProducts__r) {      
      Map<String, List<Object>> overridesMap = new Map<String,List<Object>>();
      List<SingleChargeOverride__c> scoList = singleChargeOverrideLookup.findByNegotiatedProductId(np.id);
      List<RecurringChargeOverride__c> rcoList = recurringChargeOverrideLookup.findByNegotiatedProductId(np.id);
      List<ScheduleOverride__c> schedoList =  scheduleOverrideLookup.findByNegotiatedProductId(np.id);      
      overridesMap.put('singleChargeOverrides', scoList);
      overridesMap.put('recurringChargeOverrides', rcoList);
      overridesMap.put('scheduleOverrides', schedoList);
      npOverrides.put(np.id, overridesMap);      
    }
    this.npOverrides = npOverrides;
  }
  
  private void populateActiveCounts(List<Plan__c> plans) {
  	Map<String, Integer> counts = new Map<String, Integer>();
  	for (Plan__c plan : plans) {
  		Integer numACs = planLookup.getActiveAccessCodes(plan.Id);
  		counts.put(plan.Id, numACs);
  	}
  	this.activeCounts = counts;
  }
  
  /*
  * called during initialization
  */
  private void populateCurrentOverridesMap(List<Plan__c> plans, List<SingleChargeOverride__c> scos, List<RecurringChargeOverride__c> rcos, List<ScheduleOverride__c> sos) {
    System.debug('Entered populateCurrentOverridesMap');
    System.debug('Plans: '+plans);
    System.debug('Single Charge Overrides: '+scos);
    System.debug('Recurring Charge Overrides: '+rcos);
    System.debug('Schedule Overrides: '+sos);

    Map<String,OverridesDTO> currentOverrides = new Map<String, OverridesDTO>();
    Map<String,OverridesTotalDTO> currentPlanTotals = new Map<String,OverridesTotalDTO>();
    
    for(Plan__c plan : plans) {   
    	OverridesTotalDTO planDto = new OverridesTotalDTO();
      //SFB-1387: If the plan start date is in the future and a recurring charge is in the future, then pick that up to display 
      Date compareDate = RTUtils.dateIsBefore(Date.today(), plan.startDate__c) ? plan.startDate__c : Date.today();

      if(plan.quantityStartDate__c != null) {
        hasQuantityHistorys = RTUtils.dateIsBefore(Date.today(), plan.quantityStartDate__c);//check if the quantity start date is in the future
        if (hasQuantityHistorys) {
          planQuantityHistorys = planQuantityHistoryLookup.getPlanQuantityHistorysByPlanId(plan.Id);
          for (PlanQuantityHistory__c pqh : planQuantityHistorys) {
            if (RTUtils.dateInRange(Date.today(), pqh.startDate__c, pqh.endDate__c, true, false)) {//find the plan quantity history that today is in
              plan.quantity__c = pqh.quantity__c;
              plan.quantityStartDate__c = pqh.startDate__c;
              futureQuantityChanges = 'Yes';
            }
          }
        }
      }
      for(NegotiatedProduct__c np : plan.NegotiatedProducts__r) {       
        OverridesDTO dto = new OverridesDTO();        
        
        //SFB-2345: Start date is inclusive and endDate is exclusive when selecting overrides, so using dateInRange(d, startDate, endDate, true, false)

        //Single Charge Overrides
        for(SingleChargeOverride__c sco : scos){          
          if(RTUtils.dateInRange(compareDate, sco.startDate__c, sco.endDate__c, true, false) && np.id == sco.negotiatedProduct__c){
            dto.singleChargeOverride = sco;
          }
        }

        if(dto.singleChargeOverride == null)
          dto.singleChargeOverride = np.Product__r;

        //Recurring Charge Overrides
        for(RecurringChargeOverride__c rco : rcos){
          if(RTUtils.dateInRange(compareDate, rco.startDate__c, rco.endDate__c, true, false) && np.id == rco.negotiatedProduct__c){
            dto.recurringChargeOverride = rco;

            //SFB-1387: Always set the frequency to the override value if there is one
            planDto.frequency = rco.recurringChargeFrequency__c;
          }
        }  

        if(dto.recurringChargeOverride == null){
          dto.recurringChargeOverride = np.Product__r;

          //SFB-1387: If the frequency for this plan is empty, then use the base
          if(planDto.frequency == null)
            planDto.frequency = np.Product__r.recurringChargeFrequency__c;
        }

        //Schedule Overrides
        for(ScheduleOverride__c so : sos){     
          Boolean hasValidScheduleOverride = false;

          if(RTUtils.dateInRange(compareDate, so.startDate__c, so.endDate__c, true, false) && np.id == so.negotiatedProduct__c){
            hasValidScheduleOverride = true;
          }

          if(hasValidScheduleOverride){
            if(so.customSchedule__c != null){
              dto.hasCustomSchedule = true;
              dto.viewScheduleURLParams = 'id='+plan.account__c+'&customScheduleId='+so.customSchedule__c+'&scheduleType='+so.customSchedule__r.baseScheduleType__c+'&baseScheduleId='+so.customSchedule__r.baseSchedule__c;
            }
            else{
              dto.viewScheduleURLParams = 'id='+plan.account__c+'&scheduleType='+so.standardSchedule__r.scheduleType__c+'&baseScheduleId='+so.customSchedule__r.baseSchedule__c;
              dto.hasCustomSchedule = false;
            }
                    
            dto.hasScheduleOverride = true;
            dto.scheduleOverride = so;            
          }                                
        }          

        //SFB-1387: Use the Schedule name to determine the schedule type.  This is fraught with peril.
        if(dto.scheduleOverride == null){
          dto.scheduleOverride = np.Product__r;
          dto.hasScheduleOverride = false;

          if(np.product__r.schedule__c != null)
            dto.viewScheduleURLParams = 'id='+plan.account__c+'&scheduleType='+np.product__r.schedule__r.Name.replaceAll('\\s-.*', '')+'&baseScheduleId='+np.product__r.schedule__c;          
        }
        
        currentOverrides.put(np.id, dto);
        
        // now roll these overrides/base prices into the plan total
        planDto.addRecurringCharge(dto.recurringChargeOverride);
        planDto.addSingleCharge(dto.singleChargeOverride);
        
      }      
      
      currentPlanTotals.put(plan.Id, planDto);
    }
    
    this.currentNpOverrides = currentOverrides;
    this.currentPlanTotals = currentPlanTotals;
  }

  
  private void populateFutureChangesMap(List<Plan__c> plans,List<SingleChargeOverride__c> scos, List<RecurringChargeOverride__c> rcos, List<ScheduleOverride__c> sos) {
    Map<String, Boolean> npFutureChanges = new Map<String, Boolean>();    
    for(Plan__c plan : plans) {      
      for(NegotiatedProduct__c np : plan.NegotiatedProducts__r) {

        for(SingleChargeOverride__c sco : scos){
          if(sco.startDate__c > Date.today() && np.id == sco.negotiatedProduct__c){
            npFutureChanges.put(np.id,true);
          }
        }

        for(RecurringChargeOverride__c rco : rcos){
          if(rco.startDate__c > Date.today() && np.id == rco.negotiatedProduct__c){
            npFutureChanges.put(np.id,true);
          }
        }

        for(ScheduleOverride__c so : sos){
          if(so.startDate__c > Date.today() && np.id == so.negotiatedProduct__c){
            npFutureChanges.put(np.id,true);
          }
        }

        if(npFutureChanges.get(np.id) == null)
          npFutureChanges.put(np.id,false);        
      }
    }
    this.npFutureChanges = npFutureChanges;
  }

  @RemoteAction
  global static boolean makeDefault(Id planId, Boolean isOverride) {
    if(planId==null)
      throw new ValidationException('Invalid planId (product) provided to make default: '+planId);

    Plan planRepository = new Plan();
    Plan__c p = planRepository.getById(planId);

    if(!p.billableType__c.equals('ACCESS_CODE'))
      throw new ValidationException('Cannot make non ACCESS_CODE type products the default');  

    if(p.isDefault__c)
      throw new ValidationException('This Product is already the default');

    //Iterate through all plans for this account and find the matching plan passed in
    List<Plan__c> allPlansForAccount = planRepository.getPlansByAccountId(p.account__c);
    for(Plan__c plan : allPlansForAccount){
      if(plan.isDefault__c && !isOverride)
        return false;
    
      //Mark the provided plan as default
      if(plan.isDefault__c && isOverride){
        new Plan.builderValidator()
          .forObject(plan)
          .set('isDefault__c', false)
          .buildAndValidate()
          .save();  

        //Save defaultPlan__c to the Account object
        Account a = (Account) RTDatabaseUtils.getEntireSObject(new Account(), p.account__c);
        a.defaultPlan__c = planId;
        Database.update(a);
      }     
    }

    //Unmark this plan as default
    new Plan.builderValidator()
      .forObject(p)
      .set('isDefault__c', true)
      .buildAndValidate()
      .save();  

    return true;  
  }

  @RemoteAction
  global static boolean editPlan(Id planId, String quantity, String quantityOld, String startDate) {
    if(planId==null)
      throw new ValidationException('Invalid planId (product) provided to edit: '+planId);

    //Validations
    if(StringUtils.equals(quantityOld, quantity))
      throw new ValidationException('You must change the quantity');

    if(quantity == null) {
      throw new ValidationException('Quantity is a required field.');
    }

    if(Integer.valueOf(quantity) < 1) {
      throw new ValidationException('Quantity must be greater than 0');
    }

    Date sDate = null;
    try{
      sDate = Date.parse(startDate);
    }
    catch(Exception e){
      throw new ValidationException('Invalid start date, please check, and try again.');
    }

    Plan planRepository = new Plan();
    Plan__c p = planRepository.getById(planId);

    //update plan quantity and start date
    new Plan.builderValidator()
            .forObject(p)
            .set('quantity__c', Integer.valueOf(quantity))
            .set('quantityStartDate__c', sDate)
            .buildAndValidate()
            .save();

    return true;
  }
  
  @RemoteAction
  global static boolean editProduct(Id negotiatedProductId, String singleChargeOld, String singleCharge, String recurringChargeOld, String recurringCharge, String scheduleOld, String schedule, String startDate, String endDate) {

    //Validations
    if(StringUtils.equals(singleChargeOld, singleCharge) && StringUtils.equals(recurringChargeOld, recurringCharge) && StringUtils.equals(scheduleOld, schedule))
      throw new ValidationException('You must change at least one value');

    Date sDate = null;
    try{
      sDate = Date.parse(startDate);
    }
    catch(Exception e){
      throw new ValidationException('Invalid start date, please check, and try again.');
    }
    
    SingleChargeOverride scoDao = new SingleChargeOverride();
    RecurringChargeOverride rcoDao = new RecurringChargeOverride();
    ScheduleOverride scheduleDao = new ScheduleOverride();
    
    //Get Overrides for this negotiated product
    SingleChargeOverride__c sco = scoDao.findByNegotiatedProductIdAndInRange(negotiatedProductId, sDate);
    RecurringChargeOverride__c rco = rcoDao.findByNegotiatedProductIdAndInRange(negotiatedProductId, sDate);
    ScheduleOverride__c so = scheduleDao.findByNegotiatedProductIdAndInRange(negotiatedProductId, sDate);
    
    NegotiatedProduct negotiatedProduct = new NegotiatedProduct();
    NegotiatedProduct__c np = negotiatedProduct.getById(negotiatedProductId);
    
    //Save Single Charge Override
    if(!StringUtils.equals(singleChargeOld, singleCharge)) {         
      Decimal dSingleCharge = StringUtils.decimalValueOf(singleCharge);
      if(dSingleCharge == null)
        throw new ValidationException('Invalid Single Charge entry');  

      if(sco != null && sco.endDate__c != null)
        throw new ValidationException('Single Charge entry conflict: '+sco.Name+': '+sco.startDate__c+' - '+sco.endDate__c);

      scoDao.expirePreviousOverride(negotiatedProductId, startDate);
      scoDao.saveSingleChargeOverride(np.Product__r.Name, np.Product__r.singleCharge__c, negotiatedProductId, dSingleCharge, startDate, endDate);
    }
    
    //Save Recurring Charge Override
    if(!StringUtils.equals(recurringChargeOld, recurringCharge)) {         
      Decimal dRecurringCharge = StringUtils.decimalValueOf(recurringCharge);
      if(dRecurringCharge == null)
        throw new ValidationException('Invalid Recurring Charge entry');  

      if(rco != null && rco.endDate__c != null)
        throw new ValidationException('Recurring Charge entry conflict: '+rco.Name+': '+rco.startDate__c+' - '+rco.endDate__c);         

      rcoDao.expirePreviousOverride(negotiatedProductId, startDate);

      //SFB-1372: Need the correct recurring charge frequency
      List<RecurringChargeOverride__c> rcos = rcoDao.findByNegotiatedProductId(negotiatedProductId);
      String recurringChargeFrequency = np.Product__r.recurringChargeFrequency__c;

      if(rcos != null && rcos.size() > 0){
        recurringChargeFrequency = rcos.get(0).recurringChargeFrequency__c;
      }

      rcoDao.saveRecurringChargeOverride(np.Product__r.Name, np.Product__r.recurringCharge__c, negotiatedProductId, dRecurringCharge, recurringChargeFrequency, startDate, endDate);      
    }    
    
    //Save Schedule Override
    if(!StringUtils.equals(scheduleOld, schedule)) {
      Schedule scheduleLookup = new Schedule();
      CustomSchedule customScheduleLookup = new CustomSchedule();
      List<Schedule__c> schedules = scheduleLookup.findAllSchedules();

      //Support for parent account's custom schedule assignments
      List<CustomSchedule__c> customSchedules = new List<CustomSchedule__c>();

      if(np.Account__r.parentID != null)
        customSchedules = customScheduleLookup.findByAccountIdOrParentAccountId(np.Account__r.id, np.Account__r.parentID);
      else
        customSchedules = customScheduleLookup.findByAccountId(np.Account__r.id);

      Id scheduleId = null;
      Id customScheduleId = null;

      if(so != null && so.endDate__c != null)
        throw new ValidationException('Schedule entry conflict: '+so.Name+': '+so.startDate__c+' - '+so.endDate__c);      

      for(Schedule__c s : schedules) {
        if(s.name==schedule)
          scheduleId = s.id;
      }
      
      for(CustomSchedule__c c : customSchedules) {
        if(c.name==schedule)
          customScheduleId = c.id;
      }   

      scheduleDao.expirePreviousOverride(negotiatedProductId, startDate);
      scheduleDao.saveScheduleOverride(np.Product__r.Name, negotiatedProductId, scheduleId, customScheduleId, startDate, endDate);
    }    
    
    
    return true;
  }
  
  public Plan__c getPlan() {
    return this.plan;
  }
    
  public List<Plan__c> getPlans(){
    return this.plans;
  }
  
  public Map<String, Integer> getActiveAccessCodeCounts() {
  	return this.activeCounts;
  }
  
  public Map<String, Map<String,List<Object>>> getNPOverrides() {
    return this.npOverrides;
  }
  
  public Map<String, Boolean> getNPFutureChanges() {
    return this.npFutureChanges;
  }
  
  public Map<String, OverridesDTO> getCurrentNpOverrides() {
    return this.currentNpOverrides;    
  }
  
  public Map<String, OverridesTotalDTO> getCurrentPlanTotals() {
  	return this.currentPlanTotals;
  }
  
  public Account getAccount() {
    return this.a;
  }

  public String getAccountId() {
    return this.a.Id;
  }

  public String getFutureQuantityChanges() {
    return this.futureQuantityChanges;
  }

  public PageReference refresh() {
    return null;
  }
    
}