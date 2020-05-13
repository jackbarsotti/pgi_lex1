global with sharing class AddPlanController {
  
  private List<Package__c> packages;
  private List<RT_Product__c> products;   
  private Map<String,ScheduleOverride__c> productsWithCustomSchedules;
  private Package__c assignedPackage;
  private Plan__c assignedPlan;  
  private Id accountId;    
  private Id assignedPackageId;
  private Boolean quantityEnabled;
  public Account account {get; set;}
  
  private final Pkg pkg = new Pkg();
  
  public AddPlanController(ApexPages.StandardController controller) {
    this.accountId = ApexPages.currentPage().getParameters().get('id');    
    account = (Account)controller.getRecord();
    this.packages = pkg.findAllPackages(); 
  }
  
  /**
   * Return all Packages as select options
   */
  public List<SelectOption> getPackageItems() {
    List<SelectOption> options = new List<SelectOption>();
    for(Package__c p : this.packages) {
      options.add(new SelectOption(p.id,p.name));
    }
    return options;    
  }
  
  /**
   * Return all products for the selected package
   */
  public List<RT_Product__c> getProducts() {
    productsWithCustomSchedules = new Map<String,ScheduleOverride__c>();

    if(this.assignedPackageId == null)
      this.assignedPackage = this.packages.get(0);
    else
      this.assignedPackage = pkg.findById(this.assignedPackageId);      
    
    CustomSchedule customSchedulelookup = new CustomSchedule();
    Schedule scheduleLookup = new Schedule();
    List<RT_Product__c> products = new List<RT_Product__c>();
    List<CustomSchedule__c> customSchedules = customSchedulelookup.findByAccountId(this.accountId);

    for(RT_Product__c product : this.assignedPackage.RT_Products__r) {
      Schedule__c schedule = scheduleLookup.findById(product.schedule__c);
      String scheduleType = null;

      if(schedule != null)
        scheduleType = schedule.scheduleType__c;
      
      //If the base product doesn't have the schedule flagged as "use by default", then use a Custom Schedule
      if(!product.useAssignedScheduleAsDefault__c){
        for(CustomSchedule__c cs : customSchedules){
          if(cs.baseScheduleType__c.equals(scheduleType) && cs.isDefault__c){
            ScheduleOverride__c so = new ScheduleOverride__c();
            so.customSchedule__c = cs.Id;
            productsWithCustomSchedules.put(product.Id, so);
          }
        }
      }

      if(!productsWithCustomSchedules.containsKey(product.Id))
        productsWithCustomSchedules.put(product.Id, new ScheduleOverride__c());

      products.add(product);
    }
    
    //Set the billable type to the selected Package's billable type
    this.assignedPlan = new Plan__c();
    this.assignedPlan.billableType__c = this.assignedPackage.billableType__c;
    this.assignedPlan.name = this.assignedPackage.name;
    this.quantityEnabled = this.assignedPackage.QuantityEnabled__c;

    return products;
  }
    
  /**
   * Add a new plan, replicating the current plan's products; add overrides as necessary
   */
  @RemoteAction
  global static boolean addPlan(String accountId, String packageId, String planName, String billableType, String startDate, String endDate, String quantity, String quantityStartDate, String planProducts) {
    return doAddPlan(accountId, packageId, planName, billableType, startDate, endDate, quantity, quantityStartDate, planProducts);
  }

//  @RemoteAction
//  global static boolean addPlan(String accountId, String packageId, String planName, String billableType, String startDate, String endDate, String planProducts) {
//    return doAddPlan(accountId, packageId, planName, billableType, startDate, endDate, null, null, planProducts);
//  }

  private static boolean doAddPlan(String accountId, String packageId, String planName, String billableType, String startDate, String endDate, String quantity, String quantityStartDate, String planProducts) {
    Pkg pkgLookup = new Pkg();
    Plan planRepo = new Plan();
    Schedule scheduleLookup = new Schedule();
    CustomSchedule customScheduleLookup = new CustomSchedule();
    NegotiatedProduct npRepo = new NegotiatedProduct();

    Package__c pkg = pkgLookup.findById(packageId);
    Account a = (Account) [select name,parentID from Account where id =: accountId];
    List<Schedule__c> schedules = scheduleLookup.findAllSchedules();

    if (pkg.QuantityEnabled__c && (quantity == null || quantity == '')) {
      throw new ValidationException('Quantity is a required field.');
    }

    if (pkg.QuantityEnabled__c && Integer.valueOf(quantity) < 1) {
      throw new ValidationException('Quantity must be greater than 0.');
    }

    //Support for parent account's custom schedule assignments
    List<CustomSchedule__c> customSchedules = new List<CustomSchedule__c>();

    if(a.parentID != null)
      customSchedules = customScheduleLookup.findByAccountIdOrParentAccountId(accountId, a.parentID);
    else
      customSchedules = customScheduleLookup.findByAccountId(accountId);

    //Create plan
    Plan__c newPlan = planRepo.savePlan(planName, a.id, pkg.id, billableType, startDate, endDate, quantity, quantityStartDate);

    //Create Negotiated Products
    Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(planProducts);
    List<Object> jsonProducts = (List<Object>) m.get('products');

    //Loop through incoming
    for(Object jsonProduct : jsonProducts) {
      //Parse incoming JSON into objects
      String productName = StringUtils.nullIfEmpty(JsonUtils.getJsonValue(jsonProduct, 'productName'));
      String productId = StringUtils.nullIfEmpty(JsonUtils.getJsonValue(jsonProduct, 'id'));
      Decimal singleCharge = StringUtils.decimalValueOf(JsonUtils.getJsonValue(jsonProduct, 'singleCharge').replaceAll('\\$', '').replaceAll(',', ''));
      Decimal recurringCharge = StringUtils.decimalValueOf(JsonUtils.getJsonValue(jsonProduct, 'recurringCharge').replaceAll('\\$', '').replaceAll(',', ''));
      String recurringChargeFrequency = StringUtils.nullIfEmpty(JsonUtils.getJsonValue(jsonProduct, 'recurringChargeFrequency'));
      String schedule = StringUtils.nullIfEmpty(JsonUtils.getJsonValue(jsonProduct, 'schedule'));
      Id scheduleId = null;
      Id customScheduleId = null;

      //Match the incoming schedule to the corresponding schedule/custom schedule based on it's name
      for(Schedule__c s : schedules) {
        if(s.name==schedule)
          scheduleId = s.id;
      }

      for(CustomSchedule__c c : customSchedules) {
        if(c.name==schedule)
          customScheduleId = c.id;
      }

      //Get the product we are dealing with
      RT_Product__c product = getProductFromPackage(pkg, productId);

      //Save negotiated product
      NegotiatedProduct__c np = npRepo.saveNegotiatedProduct(productName, productId, newPlan.id, a.id);

      //Save single charge override
      if(product != null && product.singleCharge__c != singleCharge) {
        SingleChargeOverride scoDao = new SingleChargeOverride();
        scoDao.saveSingleChargeOverride(productName, product.singleCharge__c, np.id, singleCharge, startDate, endDate);
      }

      //Save recurring charge override
      if(product != null && (product.recurringCharge__c != recurringCharge || product.recurringChargeFrequency__c != recurringChargeFrequency)) {
        RecurringChargeOverride rcoDao = new RecurringChargeOverride();
        rcoDao.saveRecurringChargeOverride(productName, product.recurringCharge__c, np.id, recurringCharge, recurringChargeFrequency, startDate, endDate);
      }

      //Save schedule override
      if(product != null && schedule != product.scheduleName__c) {
        ScheduleOverride scheduleDao = new ScheduleOverride();
        scheduleDao.saveScheduleOverride(productName, np.id, scheduleId, customScheduleId, startDate, endDate);
      }
    }
    return true;
  }
       
  private static RT_Product__c getProductFromPackage(Package__c pkg, String productId) {
    for(RT_Product__c product : pkg.RT_Products__r) {
      if(product.id==productId) {
        return product;
      }        
    }
    return null;
  }
  
  public PageReference packageSelect() {
    getProducts();
    return null;
  }
  
  public String getAccountId() {
    return this.accountId;
  }  
  
  public Package__c getAssignedPackage() {
    return this.assignedPackage;
  }  
  
  public void setAssignedPackage(Package__c assignedPackage) {
    this.assignedPackage = assignedPackage;
  }
  
  public Id getAssignedPackageId() {
    return this.assignedPackageId;
  }  
  
  public void setAssignedPackageId(Id assignedPackageId) {
    this.assignedPackageId = assignedPackageId;
  }  
  
  public Plan__c getAssignedPlan() {
    return this.assignedPlan;
  }
  
  public void setAssignedPlan(Plan__c assignedPlan) {
    this.assignedPlan = assignedPlan;
  }   

  public Map<String,ScheduleOverride__c> getProductsWithCustomSchedules() {
    return this.productsWithCustomSchedules;
  }

  public Boolean getQuantityEnabled() {
    return this.quantityEnabled;
  }

  public void setQuantityEnabled(Boolean enabled) {
    this.quantityEnabled = enabled;
  }
}