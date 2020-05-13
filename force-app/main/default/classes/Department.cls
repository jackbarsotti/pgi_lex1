public with sharing class Department extends AbstractRepository {

  public final static String table = 'Department__c';
  public final static String columns = 'id,name,Parent_Account__c,Provision__c,Inactive__c, Status__c, Date_Deleted__c';

  /**
   * Queries
   */
  public List<Department__c> getDepartmentsByAccountId(Id accountId){
    return (List<Department__c>) Database.query(selectBuilder(table,columns, 'where Provision__c = true and Parent_Account__c = :accountId and (Inactive__c = false or Status__c = \'Error\')'));
  }

  /**
   * Helpers for deletes
   */
  //Executed when someone initiates a delete action for a single department (i.e. delete button on department page)
  public void cascadeDelete(Department__c department){
    List<Department__c> departments = new List<Department__c>();
    departments.add(department);

    try{
      cascadeDelete(departments);
    }
    catch(Exception e){
      throw new ConstructableException('Sorry, unable to complete deletion of this department because '+e.getMessage());
    }
  }

  //Executed when a list of departments needs to be deleted (i.e. delete all departments under an Account)
  public void cascadeDelete(List<Department__c> departments){
    for(Department__c department : departments){

      //If this department is marked as Inactive__c and Status__c is Deleting it will attempt to fire an outbound message, we don't want that here.
      if(department.Inactive__c == true && department.Status__c=='Deleting')
        department.Inactive__c = false;
    }

    //Get all of the contacts hanging off of these departments/accounts and delete them (via batch)
    //The Finish method of the Batch Executor will delete all of the departments/accounts
    List<Contact> contacts = BatchSObjectDelete.getContactsFromDepartmentList(departments);

    BatchSObjectDelete batchDelete = new BatchSObjectDelete();
    batchDelete.sObjectName = 'Department';
    batchDelete.action = 'DeleteDepartments';
    batchDelete.subscriptionsDeleted = false; 
    batchDelete.contactsDeleted = false;    
    batchDelete.subscriptions = BatchSObjectDelete.getSubscriptionsFromContactList(contacts);  
    batchDelete.contacts = contacts;
    batchDelete.departments = departments;
    Database.executeBatch(batchDelete);
  }

  //Executed from Finish methods on Batch Deletes
  public void del(List<Department__c> departments){
    for(Department__c department : departments){
      //Mark department as deleted (Inactive__c) now
      if(department.Inactive__c == false)
        department.Inactive__c = true;

      //Mark department inactivated by user
      if(department.Inactivated_By__c == null)
        department.Inactivated_By__c = Userinfo.getUserName();

      //Mark contact deleted date
      if(department.Date_Deleted__c == null) 
        department.Date_Deleted__c = Datetime.now();

      //Mark the Status__c as Delete so that we don't end up in an infinite loop
      if(department.Status__c == 'Deleting')
        department.Status__c = 'Delete';
    }

    try{
      update(departments);
    }
    catch(Exception e){
      throw new ConstructableException('Sorry, unable to complete deletion of this department because '+e.getMessage());      
    }    
  }  
}