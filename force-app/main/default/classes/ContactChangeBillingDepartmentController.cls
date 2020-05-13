public with sharing class ContactChangeBillingDepartmentController extends BaseController {

  public Contact c;
  public List<Department__c> departments;  
  public String departmentId {get; set;}

  public ContactChangeBillingDepartmentController(ApexPages.StandardController controller) {
    if(getPageID() != null)
      this.c = (Contact) RTDatabaseUtils.getEntireSObject(new Contact(), getPageID(), ',Account.Id');
  }

  /**
   * Returns this contact's list of departments
   */
  public List<Department__c> getDepartments() {       
    List<Department__c> departments = new List<Department__c>();
    
    if(this.c == null || this.c.AccountId == null)
      return departments;
    
    Department__c emptyDepartment = new Department__c();
    emptyDepartment.Name='None';
    departments.add(emptyDepartment);
    departments.addAll((List<Department__c>)Database.query('Select Id, Name, Parent_Account__c From Department__c '+
        'Where Inactive__c = false '+ 
        'and Status__c = \'Active\' and Parent_Account__c = \''+this.c.AccountId+'\' order by Name asc'));
        
    return departments;
  }

  public PageReference save() {  
    Contact original = this.c;
    
    try {
      this.c.AdminEditing__c = 'sking';
      this.c.SF_Department_ID__c = this.departmentId == '' ? null : this.departmentId;
      this.c.Department_Parent__c = this.departmentId == '' ? null : this.departmentId;      
      update(this.c);
      
      this.c.AdminEditing__c = '';
      update(this.c);
    }
    catch(Exception ex){
      original.AdminEditing__c = '';
      update(original);
      ApexPages.addMessages(ex);
      return null;
    }
    return gotoView(this.c);
  }

  public virtual override PageReference cancel() {
    return gotoView(this.c.id);
  }  

  public void setContact(Contact c) {
    this.c = c;
  }

  public Contact getContact() {
    return this.c;
  }
}