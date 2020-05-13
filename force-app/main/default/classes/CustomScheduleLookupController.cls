global with sharing class CustomScheduleLookupController {

  public String accountId {get;set;}
  public String lksrch {get;set;}
  public String scheduleType {get;set;}
  public List<Schedule__c> schedules {get;set;}
  public List<CustomSchedule__c> customSchedules {get;set;}
  public List<CustomSchedule__c> parentAccountCustomSchedules {get;set;}
  
  public CustomScheduleLookupController(ApexPages.StandardController controller) {
    accountId = ((Account)controller.getRecord()).id;    
    performSearch(); 
  }

  public CustomScheduleLookupController() {
    accountId = System.currentPageReference().getParameters().get('accountId');
    lksrch = System.currentPageReference().getParameters().get('lksrch');
    performSearch();  
  }

  public PageReference goBack() {
    return new PageReference('/' + accountId);
  }

  public PageReference search() {
    performSearch();
    return null;
  }

  //Used for ScheduleList.page and CustomScheduleLookup.page; be careful
  private void performSearch() {
    Schedule scheduleRepository = new Schedule();
    CustomSchedule customScheduleRepository = new CustomSchedule();

    //Retreive all base schedules and custom schedules for this account
    this.schedules = scheduleRepository.findAllSchedules();
    this.customSchedules = customScheduleRepository.findByAccountId(accountId);
    Account a = (Account)[select parentID,id from Account where id = :accountId limit 1];

    //If this account has a parent account, then grab it's custom schedules as well
    if(a.parentID != null)
      this.parentAccountCustomSchedules = customScheduleRepository.findByAccountId(a.parentID);

    //For search, search by name and 
    if(lksrch != null) {
      List<Schedule__c> schedules = (List<Schedule__c>)[select scheduleType__c, name from Schedule__c where name =: lksrch limit 1];
      if(schedules == null || schedules.size() <= 0)
        this.scheduleType = ((CustomSchedule__c) [select baseScheduleType__c, name from CustomSchedule__c where name =: lksrch limit 1]).baseScheduleType__c;
      else
        this.scheduleType = schedules.get(0).scheduleType__c;      
    }
  }

  // Used by the visualforce page to send the link to the right dom element
  public string getFormTag() {
    return System.currentPageReference().getParameters().get('frm');
  }

  // Used by the visualforce page to send the link to the right dom element for the text box
  public string getTextBox() {
    return System.currentPageReference().getParameters().get('txt');
  }

  @RemoteAction
  global static boolean makeDefault(String customScheduleId, Boolean isOverride) {
    CustomSchedule lookup = new CustomSchedule();
    CustomSchedule__c cs = lookup.findById(customScheduleId);

    if(cs.isDefault__c)
      throw new ValidationException('This custom schedule is already a default '+cs.baseScheduleType__c+ ' schedule.');

    List<CustomSchedule__c> allCustomsForAccount = lookup.findByAccountId(cs.account__c);

    for(CustomSchedule__c c : allCustomsForAccount){
      if(c.isDefault__c && (c.baseScheduleType__c == cs.baseScheduleType__c) && !isOverride)
        return false;
      
      if(c.isDefault__c && (c.baseScheduleType__c == cs.baseScheduleType__c) && isOverride){
        CustomSchedule__c customSchedule = (CustomSchedule__c) new CustomSchedule.builderValidator()
          .forObject(c)
          .set('isDefault__c', false)
          .buildAndValidate()
          .save();  
      }
    }

    CustomSchedule__c customSchedule = (CustomSchedule__c) new CustomSchedule.builderValidator()
      .forObject(cs)
      .set('isDefault__c', true)
      .buildAndValidate()
      .save();  

    return true;      
  }
}