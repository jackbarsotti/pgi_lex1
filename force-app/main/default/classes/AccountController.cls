public with sharing class AccountController extends BaseController {

  Account a;
  String deleteID;
  WaitDialog dialog;
  Integer subscriptionCount;

  /**
   * Default Constructor
   */
  public AccountController(ApexPages.StandardController controller) {
    //Delete
    this.deleteID = ApexPages.currentPage().getParameters().get('delID');
    

    //Delete Account
    if (this.deleteID != null) {
      this.a = (Account) RTDatabaseUtils.getEntireSObject(new Account(), this.deleteID);
      setWaitDialogContent();
    }
  }
  public PageReference init() {
    String retUrl = ApexPages.currentPage().getParameters().get('retURL');
    if(ReadyTalkRecordTypeHelper.readyTalkAccountRecordTypeIds.contains(this.a.RecordTypeId)) {
        return null;
    } else {
        delete a;
        return new PageReference(retUrl);
    } 
  }
  /**
   * Setter for the wait dialog content.
   */
  public void setWaitDialogContent() {
    this.dialog = new WaitDialog();
    if (this.deleteID != null && this.subscriptionCount == null) {
      getWaitDialog().setHeader('Question...');
      getWaitDialog().setStatus('This will delete this account along with all departments, contacts and subscriptions associated with it. Are you sure you want to do this?');
      getWaitDialog().setButton('Delete');
      getWaitDialog().setClickCommand('preDelete()');
      getWaitDialog().setCancelButton('Cancel');
      getWaitDialog().setShouldRenderCancelButton(true);
      getWaitDialog().setCancelClickCommand('cancelDelete()');
      getWaitDialog().setShouldRender(true);
    }

    if (this.deleteID != null && this.subscriptionCount != null && ((this.subscriptionCount <= RTConfig.LIMIT_NUMBER_SUBSCRIPTIONS || getIsAdministrator()) || (this.subscriptionCount > RTConfig.LIMIT_NUMBER_SUBSCRIPTIONS && ValidateAccountFields.timeFrameOKToBulkDelete))) {
      getWaitDialog().setHeader('Question...');
      getWaitDialog().setStatus('Please describe the reason for deleting this account.');
      getWaitDialog().setButton('Continue');
      getWaitDialog().setClickCommand('customDelete()');
      getWaitDialog().setCancelButton('Cancel');
      getWaitDialog().setCancelClickCommand('cancelDelete()');
      getWaitDialog().setShouldRenderCancelButton(true);
      getWaitDialog().setShouldRenderForm(true);
      getWaitDialog().setShouldRender(true);
    }

    if (this.deleteID != null && this.subscriptionCount != null && this.subscriptionCount > RTConfig.LIMIT_NUMBER_SUBSCRIPTIONS && !ValidateAccountFields.timeFrameOKToBulkDelete) {
      getWaitDialog().setHeader('Error: Too many subscriptions...');
      getWaitDialog().setStatus('Due to the number of subscriptions to be deleted (' + this.subscriptionCount + '), this action must be performed after working hours (after 4PM MT).');
      getWaitDialog().setButton('OK');
      getWaitDialog().setClickCommand('cancelDelete()');
      getWaitDialog().setShouldRender(true);
    }

    if (this.deleteID != null && this.a.Suspend_Account__c == true) {
      getWaitDialog().setHeader('Error...');
      getWaitDialog().setStatus('This account is in suspended status and cannot be deleted.  Contact SF/Billing Team in order to delete this account.');
      getWaitDialog().setButton('OK');
      getWaitDialog().setClickCommand('cancelDelete()');
      getWaitDialog().setShouldRenderCancelButton(false);
      getWaitDialog().setShouldRender(true);
    }
  }

  public void preDelete() {
    this.subscriptionCount = 0;
    //Abstract to RTAccountUtils.getSubscriptionCount()

    //Subscriptions
    List<Subscription__c> subscriptions = [select id, inactive__c from Subscription__c where Contact__r.Account.id = : getAccount().id and inactive__c = false];
    this.subscriptionCount += subscriptions.size();

    setWaitDialogContent();
  }

  public PageReference customDelete() {
    this.a.Inactive__c = true;
    this.a.Status__c = 'Deleting';

    update(this.a);

    AccountRepository accountRepository = new AccountRepository();
    accountRepository.cascadeDelete(this.a);
    return gotoView(this.a);
  }

  public PageReference cancelDelete() {
    return gotoView(this.a.id);
  }

  /**
   * Returns the wait dialog
   */
  public WaitDialog getWaitDialog() {
    return this.dialog;
  }

  public Account getAccount() {
    return this.a;
  }
}