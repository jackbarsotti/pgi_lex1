@isTest
private class testAccountProvisionController {
    
    static testMethod Id createacc(){
        Account a = new Account(Name='Test0',Status__c = 'New',BBS_L3ServiceProvider__c = null,BBS_InvoiceFrequency__c = null,
                               Toll_Free_Number__c = null);
        INSERT a;
        RTDatabaseUtils.getEntireSObject(new Account(), a.Id);
        return a.Id;
    }
    
  //private static ApexPages.StandardController controller = new ApexPages.StandardController(RTDatabaseUtils.getEntireSObject(new Account(), MockAccount.getNewAccount().id));
  private static ApexPages.StandardController controller = new ApexPages.StandardController(RTDatabaseUtils.getEntireSObject(new Account(), createacc()));

  //AccountProvisionController.AccountProvisionController
  static testMethod void testConstruct() {
    AccountProvisionController c = new AccountProvisionController(controller);
    c.getAccountId();
    System.assert(c != null);
  }

  //AccountProvisionController.getAudioSchedulesByType
  static testMethod void testGetAudioSchedulesByType() {
      Test.startTest();
      Schedule scheduleRepo = new Schedule();
        scheduleRepo.findAllSchedulesByType('Audio');
      Test.stopTest();
    System.assert(AccountProvisionController.getAudioSchedulesByType('Audio')!=null);
  }  

  //AccountProvisionController.getStatusMessage
  static testMethod void testGetStatusMessage() {
      Account acc = new Account();
      acc.Name='Test';
      acc.Status__c= null;
      insert acc;
      //RTDatabaseUtils.getEntireSObject(new Account(), acc.Id);
      AccountProvisionController.getStatusMessage(acc.Id);
 }

  //AccountProvisionController.Provision
  static testMethod void testProvision() {
    Account a = (Account)controller.getRecord();

    //Create a new schedule
    Schedule scheduleRepo = new Schedule();
    Schedule__c audioSchedule = scheduleRepo.saveSchedule('Audio: Test Schedule', 'A test audio schedule', 'Audio', Double.valueOf(1.0));
    Schedule__c webSchedule = scheduleRepo.saveSchedule('Web: Test Schedule', 'A test web schedule', 'Web', Double.valueOf(2.0));
    Schedule__c hostingSchedule = scheduleRepo.saveSchedule('Hosting: Test Schedule', 'A test hosting schedule', 'Hosting', Double.valueOf(3.0));

    System.assert(AccountProvisionController.provision(a.Id, audioSchedule.name, audioSchedule.Id, webSchedule.name, webSchedule.Id, hostingSchedule.name, hostingSchedule.Id) == true);
  }
}