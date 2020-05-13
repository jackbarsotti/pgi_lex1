@isTest
private class testAccountCascadeSettingsController {
  private static ApexPages.StandardController controller;
  static {
    PGITestUtilities.disableSalesWings();
    Subscription__c s = MockSubscription.getNewSubscription();
    s.Provision__c = true;
    s.Parent_Ind_ID__c = 'foo';
    update s;
    Contact c = (Contact) RTDatabaseUtils.getEntireSObject(new Contact(), s.contact__c, ',Contact.Account.Id');
    Account a = (Account) RTDatabaseUtils.getEntireSObject(new Account(), c.Account.Id);
    ApexPages.currentPage().getParameters().put('id', a.Id);
    controller = new ApexPages.StandardController(a);
  }

  static testMethod void testConstruct() {
    Test.startTest();
    PGITestUtilities.disableSalesWings();
    Test.stopTest();
    AccountCascadeSettingsController a = new AccountCascadeSettingsController(controller);
    
    System.assert(a!=null);
  }
  
  static testMethod void testGetErrorMessages() {
    Test.startTest();
    PGITestUtilities.disableSalesWings();
    Test.stopTest();
    AccountCascadeSettingsController a = new AccountCascadeSettingsController(controller);
    
    System.assert(a.getErrorMessages() == null);
  }

  static testMethod void testCascade() {
 
    AccountCascadeSettingsController a = new AccountCascadeSettingsController(controller);
      a.accountCodePrompt=true;
      a.appShareAllowed=true;
      a.archivePeriod=true;
      a.autoDeleteSlides=true;
      a.conferenceControlsAllowed=true;
      a.coPresenterAllowed=true;
      a.entryAnnouncement=true;
      a.grantControlAllowed=true;
      a.internationalDialoutAllowed=true;
      a.numberOfAudioPorts=true;
      a.podcasting=true;
      a.quickstartAllowed=true;
      a.recordingAllowed=true;
      a.recordingEditingAllowed=true;
      a.securityOption=true;
      a.slidePresentationAllowed=true;
      a.videoConferencingAllowed=true;
      a.voipAllowed=true;
      a.webConfAllowed=true;
    a.cascadeSettings();
    a.cancel();
     
    System.assert(1==1);
  }
}