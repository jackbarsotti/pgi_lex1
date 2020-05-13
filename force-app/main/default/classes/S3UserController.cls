global with sharing class S3UserController extends BaseController {

  Contact c;
  S3User__c user {get; set;}
  public String planId {get; set;}
  public Boolean isDelete;
  public String planStartDate {
    set;
    get {
      if(planStartDate == null)
        planStartDate = Date.today().format();
      return planStartDate;
    }
  }  

  public S3UserController(ApexPages.StandardController controller) {    
    S3User__c user = (S3User__c)controller.getRecord();    
    
    if(user!=null){    
      this.user = user;
    }    

    if(ApexPages.currentPage().getParameters().get('delID') != null){
      this.isDelete = true;
    }
    else{
      try{
        this.c = (Contact) RTDatabaseUtils.getEntireSObject(new Contact(), getRetURL(), ',Account.Status__c,Account.defaultPlan__c,Account.Id');
        if(this.user != null && this.user.email__c == null){
          this.user.email__c = c.email;
        }
      }
      catch(Exception e){
        throw new ValidationException('You cannot create a S3 User object without a reference to a Contact.  Use the New S3 User button from a Contact record.');
      }      
    }
  }

  public S3UserController(){    
  }

  public PageReference save() {
    SavePoint sp = Database.setSavePoint();
    Id userId = null;

    try {
      Database.UpsertResult result = Database.upsert(this.user);
      if(!result.isSuccess())
        throw new ValidationException('Unable to save, please try again.');

      userId = result.getId();

      //Save the Plan Assignment record
      //Name field: (avoid a lookup by adding name to the id field; same with endDate Looks like: id:name:endDate)
      //Validate the planStartDate first
      if (this.planStartDate == null || this.planStartDate == '')
        throw new ValidationException('Plan start date cannot be empty');

      //Validate planId
      if (this.planId == null)
        throw new ValidationException('Unable to provision.  An assigned plan is required to provision a S3 User.');

      PlanAssignment planAssignmentRepository = new PlanAssignment();
      planAssignmentRepository.savePlanAssignment(this.planId.split(':')[1], this.planId.split(':')[0], 'S3User__c', userId, this.planStartDate, this.planId.split(':')[2]);  
    } 
    catch (Exception ex) {
      ApexPages.addMessages(ex);
      Database.rollback(sp);
      return null;
    }

    return gotoView(userId);
  }

  @RemoteAction
  public static void customDelete(String userId){
    S3User s3UserRepository = new S3User();    
    S3User__c user = s3UserRepository.findById(userId);

    user.Inactive__c = true;

    //If it was already marked w/ a delete date, don't change it
    if(user.Date_Deleted__c == null) 
      user.Date_Deleted__c = Datetime.now();

    //If it was already deleted, don't put it back into a deleting status.
    if(user.Status__c != 'Delete') 
      user.Status__c = 'Deleting';
  
    try{
      update(user);    
    }
    catch(Exception e){
      throw new ValidationException('Sorry, unable to complete deletion of this S3 user because '+e.getMessage());      
    }
  }

  /**
   * Get the Account Level Plans (where today is in the plans start/end range) as SelectOption objects
   */
  public List<SelectOption> getAccountLevelPlans() {
    List<SelectOption> options = new List<SelectOption>();
    Plan planRepository = new Plan();
    List<Plan__c> accountPlans = planRepository.getPlansByAccountIdAndBillableTypeWhereAccessCodeInRange(this.c.Account.Id, 'S3_USER', Date.today());

    for (Plan__c plan : accountPlans) {
      if (plan.isDefault__c != null && plan.isDefault__c && options.size() > 0)
        options.add(0, new SelectOption(plan.Id + ':' + plan.Name + ':' + RTUtils.formatDateSafe(plan.endDate__c, null), plan.Name + ': ' + RTUtils.formatDateSafe(plan.startDate__c, 'No start') + ' - ' + RTUtils.formatDateSafe(plan.endDate__c, '∞')));
      else
        options.add(new SelectOption(plan.Id + ':' + plan.Name + ':' + RTUtils.formatDateSafe(plan.endDate__c, null), plan.Name + ': ' + RTUtils.formatDateSafe(plan.startDate__c, 'No start') + ' - ' + RTUtils.formatDateSafe(plan.endDate__c, '∞')));
    }

    return options;
  }  

  public S3User__c getUser(){
    return this.user;
  }

  public String getUserId(){
    return this.user.Id;
  }

  public String getContactId(){
    if(this.c != null)
      return this.c.Id;
    else
      return null;
  }

  public Boolean getIsDelete(){
    return this.isDelete;
  }
}