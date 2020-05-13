global with sharing class ContactController extends BaseController {

  Account a;
  Department__c d;
  Contact c;
  boolean isValidContact;
  String deleteID;
  WaitDialog dialog;

  public ContactController() {
    //Delete
    this.deleteID = ApexPages.currentPage().getParameters().get('delID');

    if (this.deleteID == null) {
      //Contact can be made from the Account level or the Department level
      boolean isDepartment = 'Department__c'.equals(RTDatabaseUtils.getObjectNameFromPageID());
      this.c = new Contact();

      //New Contact (from Department or Account...)
      if(isDepartment) {
        this.d = (Department__c) RTDatabaseUtils.getEntireSObject(new Department__c(), getPageID());
        RTContactUtils.copyDepartmentFieldsToContact(this.d, this.c);                
      } else {
        this.a = (Account) RTDatabaseUtils.getEntireSObject(new Account(), getPageID());
        RTContactUtils.copyAccountFieldsToContact(this.a, this.c);
      }
    } else {
      this.c = (Contact) RTDatabaseUtils.getEntireSObject(new Contact(), this.deleteID, ',Owner.Name, RecordType.Name');
      setWaitDialogContent();
    }
  }
  public PageReference init() {
    String retUrl = ApexPages.currentPage().getParameters().get('retURL');
    if(c.RecordTypeId == null) {
      for(Id i: ReadyTalkRecordTypeHelper.readyTalkContactRecordTypeIds) {
        c.RecordTypeId = i;
      }
    }
    if(ReadyTalkRecordTypeHelper.readyTalkContactRecordTypeIds.contains(this.c.RecordTypeId)) {
        return null;
    } else {
      if(c != null && c.Id != null) {
        delete c;
      }
        return new PageReference(retUrl);
    } 
  }
  public ContactController(ApexPages.StandardController controller) {
    Contact contact = (contact)controller.getRecord();    

    if(contact!=null){      
      this.c = contact;
    }
  }  

  /**
   * Setter for the wait dialog content.
   */
  public void setWaitDialogContent() {
    this.dialog = new WaitDialog();
    if (this.deleteID != null) {
      getWaitDialog().setHeader('Question...');
      getWaitDialog().setStatus('This will delete this contact along with all subscriptions associated with it. Are you sure you want to do this?');
      getWaitDialog().setButton('Delete');
      getWaitDialog().setClickCommand('customDelete()');
      getWaitDialog().setCancelButton('Cancel');
      getWaitDialog().setCancelClickCommand('cancelDelete()');
      getWaitDialog().setShouldRender(true);
      getWaitDialog().setShouldRenderCancelButton(true);
    }
  }

  public PageReference save() {
    try {
      //Validate
      ValidateContactFields.validateOnSave(this.c);

      //Insert/Update this contact
      upsert(this.c);
    } catch (Exception ex) {
      ApexPages.addMessages(ex);
      return null;
    }

    return gotoView(this.c.id);
  }

  public PageReference saveThenNew() {
    save();
    PageReference redir = new PageReference('/apex' + '/ContactSetDispatcher');
    redir.getParameters().put('id', ApexPages.currentPage().getParameters().get('id'));
    redir.getParameters().put('retURL', ApexPages.currentPage().getParameters().get('retURL'));

    return redir.setRedirect(true);
  }

  public PageReference customDelete() {
    try {
      this.c.Inactive__c = true;
      this.c.Status__c = 'Deleting';
      update(this.c);
    } catch (Exception ex) {
      this.c.addError('Could not complete deletion: ');
      ApexPages.addMessages(ex);
      return null;
    }

    return gotoView(this.c.id);
  }

  /**
  * Remote action to call out to the syncPasscode endpoint
  */
  @RemoteAction
  global static String restore(String contactId) {
    try{
      Contact temp = (Contact) RTDatabaseUtils.getEntireSObject(new Contact(), contactId, ',Account.status__c, Department_Parent__r.status__c');
      
      if(temp.Account.status__c != 'Active')
        throw new ValidationException('Related Account must be in an Active status before restoring.');

      if(temp.Department_Parent__c != null && temp.Department_Parent__r.status__c != 'Active')
        throw new ValidationException('Related Department must be in an Active status before restoring.');

      if(temp.status__c != 'Delete' && temp.status__c != 'RestoreError')
        throw new ValidationException('Contact must be in a Delete satus before restoring.');

      if(temp.Date_Deleted__c == null)
        throw new ValidationException('Contact must have a Date Deleted value set before restoring.');

      if(temp.Date_Deleted__c.addDays(30) < DateTime.now())
        throw new ValidationException('Cannot restore Contacts that were deleted more than 30 days ago.');

      temp.status__c = 'Restoring';    
      temp.inactive__c = false;
      temp.Date_Deleted__c = null;
      temp.Inactivated_By__c = null;

      update(temp);
    }
    catch (Exception e){
      return e.getMessage();
    }
    return 'success';
  }

  @RemoteAction
  global static String getStatusMessage(String contactId) {
    Contact temp = (Contact) RTDatabaseUtils.getEntireSObject(new Contact(), contactId);

    if (temp.Status__c != null) {
      if (temp.Status__c.equals('Active'))
        return 'success';
      else if (temp.Status__c.equals('Restoring'))
        return 'Restoring access code, please wait... <img src="/resource/RTResources/images/spinner.gif"/>';
      else if (temp.Status__c.contains('Error'))
        return 'Could not restore Access Code: ' + temp.Status_Description__c;
    }

    return null;
  }

  public PageReference cancelDelete() {
    return gotoView(this.c);
  }

  public Contact getContact() {
    return this.c;
  }

  public void setContact(Contact c) {
    this.c = c;
  }

  public Id getContactId() {
    return this.c.Id;
  }

  /**
   * Returns the wait dialog
   */
  public WaitDialog getWaitDialog() {
    return this.dialog;
  }

  /**
   * Returns the Administrator Information title
   */
  public String getAdministratorInformationTitle() {
    return getIsAdministrator() == true ? 'Administrator Information' : 'For System Administrators Only *** DO NOT ALTER ***';
  }
}