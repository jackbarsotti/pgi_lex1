global with sharing class AccountProvisionController extends BaseController {
  private Id accountId;   
  
  public AccountProvisionController(ApexPages.StandardController controller) {
    this.accountId = ApexPages.currentPage().getParameters().get('id');    
  }

  @RemoteAction
  global static Map<String,String> getAudioSchedulesByType(String type) {
    Schedule lookup = new Schedule();
    Map<String,String> schedules = new Map<String,String>();
    for(Schedule__c schedule : lookup.findAllSchedulesByType(type)){
      schedules.put(schedule.id,schedule.name);
    }
    return schedules;
  }

  @RemoteAction
  global static String getStatusMessage(String accountId) {
    Account temp = (Account) RTDatabaseUtils.getEntireSObject(new Account(), accountId);
    
    if(temp.Status__c == null || temp.Status__c.equals('New') || temp.Status__c.equals('Not Provisioned'))
      return null;    
    
    if(temp.Status__c.equals('Active')) 
      return 'This account has been provisioned.';
    else if (temp.Status__c.equals('Pending'))
      return 'Provisioning account... <img src="/resource/RTResources/images/spinner.gif"/>';
    else if (temp.Status__c.contains('Error'))
      return 'Could not provision Account: '+temp.Status_Description__c;      
    else
      return 'Processing...';         
  }

  @RemoteAction
  global static Boolean provision(String accountId, String audioScheduleName, String audioScheduleId, String webScheduleName, String webScheduleId, 
    String hostingScheduleName, String hostingScheduleId) {

    Account temp = (Account) RTDatabaseUtils.getEntireSObject(new Account(), accountId);

    //Check the Service Provider and Invoice Frequency
    if(temp.BBS_L3ServiceProvider__c == null){
      //Try to get the default L3 Service Provider
      for(PicklistEntry pe : Account.BBS_L3ServiceProvider__c.getDescribe().getPicklistValues()){
        if(pe.defaultValue){
          temp.BBS_L3ServiceProvider__c = pe.value;
        }
      }
      
      if(temp.BBS_L3ServiceProvider__c == null)
        throw new ValidationException('L3 Service Prodivder is required (and no default found in Salesforce), please correct and re-provision.');
    }
    
    if(temp.BBS_InvoiceFrequency__c == null){
      //Try to get the default Invoice Frequency
      for(PicklistEntry pe : Account.BBS_InvoiceFrequency__c.getDescribe().getPicklistValues()){
        if(pe.defaultValue){
          temp.BBS_InvoiceFrequency__c = pe.value;
        }
      }      

      if(temp.BBS_InvoiceFrequency__c == null)
        throw new ValidationException('Invoice Frequency is required, (and no default found in Salesforce), please correct and re-provision.');
    } 

    //Set the rate start date to today               
    temp.Rate_Start_Date__c = Date.today();
    
    //Set the tollfree number
    if(temp.Toll_Free_Number__c == null)
      temp.Toll_Free_Number__c = RTConfig.DEFAULT_TOLL_FREE_NUMBER;
    
    //Set the card name
    if(temp.Account_Card_Name__c == null) 
      temp.Account_Card_Name__c = temp.Name;

    //Set Provisioned to true
    temp.Provisioned__c = true;

    //Set the Provisioned Date to today
    temp.Date_Provisioned__c = DateTime.now();

    //Update the Account record            
    Database.update(temp);

    //Add custom schedules
    CustomSchedule customScheduleRepo = new CustomSchedule();
    customScheduleRepo.saveCustomSchedule(temp.Name+': '+audioScheduleName, accountId, audioScheduleId, 'Custom schedule based on '+audioScheduleName, true);
    customScheduleRepo.saveCustomSchedule(temp.Name+': '+webScheduleName, accountId, webScheduleId, 'Custom schedule based on '+webScheduleName, true);
    customScheduleRepo.saveCustomSchedule(temp.Name+': '+hostingScheduleName, accountId, hostingScheduleId, 'Custom schedule based on '+hostingScheduleName, true);

    return true;
  }

  public String getAccountId() {
    return this.accountId;
  }  
}