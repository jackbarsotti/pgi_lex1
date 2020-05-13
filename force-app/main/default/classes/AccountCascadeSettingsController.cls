public with sharing class AccountCascadeSettingsController extends BaseController {

  public Account a {get; set;}
  
  public Boolean accountCodePrompt {get; set;}
  public Boolean appShareAllowed {get; set;}
  public Boolean archivePeriod {get; set;}
  public Boolean autoDeleteSlides {get; set;}
  public Boolean conferenceControlsAllowed {get; set;}
  public Boolean coPresenterAllowed {get; set;}
  public Boolean entryAnnouncement {get; set;}
  public Boolean internationalDialoutAllowed {get; set;}
  public Boolean grantControlAllowed {get; set;}
  public Boolean numberOfAudioPorts {get; set;}
  public Boolean podcasting {get; set;}
  public Boolean quickstartAllowed {get; set;}
  public Boolean recordingAllowed {get; set;}
  public Boolean recordingEditingAllowed {get; set;}
  public Boolean securityOption {get; set;}
  public Boolean slidePresentationAllowed {get; set;}
  public Boolean voipAllowed {get; set;}
  public Boolean videoConferencingAllowed {get; set;}
  public Boolean webConfAllowed {get; set;}
  
  public List<ErrorMessage> errorMessages;
  
  public AccountCascadeSettingsController(ApexPages.StandardController controller) {
    if(getPageID() != null)
      this.a = (Account) RTDatabaseUtils.getEntireSObject(new Account(), getPageID());
  }

  public PageReference cascadeSettings() {     
    try {
      List<Subscription__c> subscriptions = (List<Subscription__c>) RTDatabaseUtils.getSObjectList(new Subscription__c(), 'where Provision__c = true and Inactive__c = false and Contact__r.Account.id = \''+this.a.id+'\'');
      
      for(Subscription__c sub : subscriptions) {
        sub.Recording_Allowed__c = this.recordingAllowed==true ? this.a.Recording_Allowed__c : sub.Recording_Allowed__c;
        sub.Recording_Editing_Allowed__c = this.recordingEditingAllowed ? this.a.Recording_Editing_Allowed__c : sub.Recording_Editing_Allowed__c;
        sub.Account_Code_Prompt__c = this.accountCodePrompt ? this.a.Account_Codes__c : sub.Account_Code_Prompt__c;
        sub.Security_Passcode__c = this.securityOption ? this.a.Security_Option__c : sub.Security_Passcode__c;
        sub.Quickstart__c = this.quickstartAllowed ? this.a.Quickstart__c : sub.Quickstart__c;
        sub.International_Dial_Out_Allowed__c = this.internationalDialoutAllowed ? this.a.International_Dial_Out_Allowed__c : sub.International_Dial_Out_Allowed__c;
        sub.Entry_Announcement__c = this.entryAnnouncement ? this.a.Entry_Announcement__c : sub.Entry_Announcement__c;
        sub.Moderator_Allowed__c = this.conferenceControlsAllowed ? this.a.Moderator_Allowed__c : sub.Moderator_Allowed__c;
        sub.Web_Conference_Allowed__c = this.webConfAllowed ? this.a.Web_Conf_Allowed__c : sub.Web_Conference_Allowed__c;
        sub.Video_Conferencing_Allowed__c = this.videoConferencingAllowed ? this.a.Video_Conferencing_Allowed__c : sub.Video_Conferencing_Allowed__c;
        sub.Slide_Presentation_Allowed__c = this.slidePresentationAllowed ? this.a.Slide_Presentation_Allowed__c : sub.Slide_Presentation_Allowed__c;
        sub.App_Share_Allowed__c = this.appShareAllowed ? this.a.App_Share_Allowed__c : sub.App_Share_Allowed__c;
        sub.Auto_Delete_Slides__c = this.autoDeleteSlides ? this.a.Auto_Delete_Slides__c : sub.Auto_Delete_Slides__c;
        sub.Copresenter_Allowed__c = this.coPresenterAllowed ? this.a.Copresenter_Allowed__c : sub.Copresenter_Allowed__c;
        sub.Archive_Period__c = this.archivePeriod ? this.a.Archive_Period__c : sub.Archive_Period__c;
        sub.Remote_Control_Allowed__c = this.grantControlAllowed ? this.a.Remote_Control_Allowed__c : sub.Remote_Control_Allowed__c;
        sub.Audio_Subscription_Size__c = this.numberOfAudioPorts ? this.a.Audio_Subscription_Size__c : sub.Audio_Subscription_Size__c;
        sub.Podcasting__c = this.podcasting ? this.a.Podcast__c : sub.Podcasting__c;
        sub.voipAllowed__c = this.voipAllowed ? this.a.voipAllowed__c : sub.voipAllowed__c;
      }
      
      //Perform the update; add any to the errorMessages list
      this.errorMessages = new List<ErrorMessage>();
      Database.SaveResult[] updateResults = Database.update(subscriptions,false);
      Integer index = 0;
      for(Database.SaveResult updateResult : updateResults) {
        if(!updateResult.isSuccess()) {
          ErrorMessage message = new ErrorMessage();
          message.setId(subscriptions.get(index).Id);
          message.setMessage('Access Code: '+subscriptions.get(index).name+' Message: '+updateResult.getErrors()[0].getMessage());
          this.errorMessages.add(message);
        }
        index++;
      }
      
      //If there are error messages, then stay on the page
      if(!errorMessages.isEmpty())
        return null;
    }
    catch(Exception ex){
      //If there are error messages, then stay on the page
      this.errorMessages = new List<ErrorMessage>();
      ErrorMessage message = new ErrorMessage();
      message.setMessage(ex.getMessage() +' '+ex.getStackTraceString());
      this.errorMessages.add(message);
      return null;
    }
    
    //Update was a success, got back to the account view
    return gotoView(this.a);
  }
  
  public void setErrorMessages(List<ErrorMessage> errorMessages) {
    this.errorMessages = errorMessages;
  }
  
  public List<ErrorMessage> getErrorMessages() {    
    return this.errorMessages;
  }

  public virtual override PageReference cancel() {
    return gotoView(this.a.id);
  }  

}