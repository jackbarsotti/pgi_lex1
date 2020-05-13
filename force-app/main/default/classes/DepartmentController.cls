public with sharing class DepartmentController extends BaseController {
  // Properties
  public Department__c department {get {return department;} set {department = value;}}
  String deleteID {get {return this.deleteID;} set {this.deleteID = value;}}
  WaitDialog dialog {get {return this.dialog;} set {this.dialog = value;}}

  // Constructors
  public DepartmentController() {
    this.deleteID = ApexPages.currentPage().getParameters().get('delID');

    if (this.deleteID != null) {
      this.department = (Department__c) RTDatabaseUtils.getEntireSObject(new Department__c(), this.deleteID, ',Owner.Name');
      setWaitDialogContent();
    } else {
      // Assume we are called from the Account's buttons
      Account parentAccount = (Account) RTDatabaseUtils.getEntireSobject(new Account(), getPageID());
      department = new Department__c();
      setNewDeptDefaults();
      copyAccountFields(parentAccount);
    }
  }

  // Set various default values
  private void setNewDeptDefaults() {
    department.Status__c = 'Not Provisioned';
    department.RecordType = [select id, name from RecordType
                             where SobjectType = 'Department__c'
                                 and name = 'Not Provisioned'];
    department.Provision__c = true;
    department.Kit_Number__c = 'http://www.readytalk.com/intl';

  }

  // Copy fields from a given Account into this Department
  //  - used to carry down fields from the parent
  private void copyAccountFields(Account parent) {
    department.OwnerID = parent.OwnerID;
    department.Toll_Free_Number__c = parent.Toll_Free_Number__c;
    department.Kit_Number__c = parent.Kit_Number__c;
    department.Kit_Name__c = parent.Kit_Name__c;
    department.Parent_Account__c = parent.id;
    department.Parent_Account_Number__c = parent.AccountNumber;
    department.Provision__c = parent.Provisioned__c;
    department.Send_Provisioning_Email__c = parent.Send_Provisioning_Email__c;
    department.Send_Welcome_Kit__c = parent.Send_Welcome_Kit__c;
    department.Start_Page__c = parent.Start_Page__c;
    department.Additional_email_addresses__c = parent.Add_E_Mails__c;
    department.Ship_To_Name__c = parent.Ship_To_Name__c;
    department.Shipping_Address__c = parent.ShippingStreet;
    department.City__C = parent.ShippingCity;
    department.State__c = parent.ShippingState;
    department.Postal_Code__c = parent.ShippingPostalCode;
    department.Country__c = parent.ShippingCountry;
    // Shipping Address Info
    //if (parent.Use_Billing_Info_as_Shipping_Info__c) {
    //  department.Ship_To_Name__c = parent.Biling_Contact__c;
    //  //department.Shipping_Address__c = parent.Billing_Street_Address_1__c;
    //  //department.Shipping_Address_2__c = parent.Billing_Street_Address_2__c;
    //  //department.State__c = parent.Billing_State__c;
    //  //department.City__C = parent.Billing_City__c;
    //  //department.Country__c = parent.Billing_Country__c;
    //  //department.Postal_Code__c = parent.Billing_Zip__c;
    //  department.ShippingStreet = parent.BillingStreet;
    //  department.ShippingCity = parent.BillingCity;
    //  department.ShippingState = parent.BillingState;
    //  department.ShippingPostalCode = parent.BillingPostalCode;
    //  department.ShippingCountry = parent.BillingCountry;
    //} else {
      //department.Ship_To_Name__c = parent.Ship_To_Name__c;
      //department.Shipping_Address__c = parent.Shipping_Address_1__c;
      //department.Shipping_Address_2__c = parent.Shipping_Address_2__c;
      //department.State__c = parent.Shipping_State__c;
      //department.City__C = parent.Shipping_City__c;
      //department.Country__c = parent.Shipping_Country__c;
      //department.Postal_Code__c = parent.Shipping_Zip__c;
        
    //}
  }

  /**
   * Setter for the wait dialog content.
   */
  public void setWaitDialogContent() {
    this.dialog = new WaitDialog();
    if (this.deleteID != null) {
      getWaitDialog().setHeader('Question...');
      getWaitDialog().setStatus('This will delete this department along with all contacts and subscriptions associated with it. Are you sure you want to do this?');
      getWaitDialog().setButton('Delete');
      getWaitDialog().setClickCommand('customDelete()');
      getWaitDialog().setCancelButton('Cancel');
      getWaitDialog().setCancelClickCommand('cancelDelete()');
      getWaitDialog().setShouldRender(true);
    }
  }

  public PageReference customDelete() {
    this.department.Inactive__c = true;
    this.department.Status__c = 'Deleting';
    update(this.department);

    Department departmentRepository = new Department();
    departmentRepository.cascadeDelete(this.department);
    return gotoView(department.id);
  }


  public List<SelectOption> getDependentPicklistItemsKitNumbers() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('', '-- None --'));
    List <Schema.PicklistEntry> items = Department__c.Kit_Number__c.getDescribe().getPicklistValues();
    for (Schema.PicklistEntry entry : items) {
      if (entry.isActive()) {
        options.add(new SelectOption(entry.getValue(), entry.getLabel()));
      }
    }
    return options;
  }

  public PageReference save() {
    try {
      //ValidateDepartmentFields.validate(department);
      //Insert/Update this contact
      upsert(department);
    } catch (Exception ex) {
      ApexPages.addMessages(ex);
      return null;
    }
    return gotoView(department.id);
  }

  public PageReference saveThenNew() {
    save();
    PageReference redir = new PageReference('/apex/DepartmentDispatcher');
    redir.getParameters().put('id', ApexPages.currentPage().getParameters().get('id'));
    redir.getParameters().put('retURL', ApexPages.currentPage().getParameters().get('retURL'));
    return redir.setRedirect(true);
  }

  /**
   * Returns the wait dialog
   */
  public WaitDialog getWaitDialog() {
    return this.dialog;
  }

  public PageReference cancelDelete() {
    return gotoView(this.department);
  }
}