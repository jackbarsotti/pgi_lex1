public with sharing class ContactRepository extends AbstractRepository {

  public final static String table = 'Contact';
  public final static String columns = 'id,name,Account.Id,Department_Parent__c,Inactive__c, Inactivated_By__c, Provisioned__c, Status__c, Date_Deleted__c';

  /**
   * Validations
   */    
  public class builderValidator extends AbstractValidator {     
  } 

  /**
   * Queries
   */
  public List<Contact> getContactsByAccountId(Id accountId){
    return (List<Contact>) Database.query(selectBuilder(table,columns, 'where Account.Id = :accountId and Provisioned__c = true and (Inactive__c = false or Status__c = \'Error\')'));
  }
  
  public List<Contact> getContactsWhereDepartmentInList(List<Id> departmentIds){
    return (List<Contact>) Database.query(selectBuilder(table,columns, 'where Provisioned__c = true and Department_Parent__c in :departmentIds and (Inactive__c = false or Status__c = \'Error\')'));
  }  

  /**
   * Helpers for deletes
   * Executed when someone initiates a delete action for a single contact (i.e. delete button on contact page)
   */
  public void cascadeDelete(Contact contact){
    List<Contact> contacts = new List<Contact>();
    contacts.add(contact);

    try{
      cascadeDelete(contacts);
    }
    catch(Exception e){
      throw new ConstructableException('Sorry, unable to complete deletion of this contact because '+e.getMessage());      
    }

  } 

  //Executed when a list of contacts needs to be deleted (i.e. delete all contacts under an Account/Department)
  public void cascadeDelete(List<Contact> contacts){
    for(Contact contact : contacts){
      //A little trickery - we will make this contact look active again (Inactive__c true).
      //The delete will occur in the final method of a batch job (after all of it's subscriptions are deleted)

      //If this contact is marked as Inactive__c and Status__c is Deleting it will attempt to fire an outbound message, we don't want that here.
      if(contact.Inactive__c == true && contact.Status__c=='Deleting')
        contact.Inactive__c = false;
    }

    //Get all of the subscriptions hanging off of these contacts and delete them (via batch)
    //The Finish method of the Batch Executor will delete all of the Contacts    
    BatchSObjectDelete batchDelete = new BatchSObjectDelete();
    batchDelete.sObjectName = 'Contact';
    batchDelete.action = 'DeleteContacts';
    batchDelete.subscriptionsDeleted = false; 
    batchDelete.subscriptions = BatchSObjectDelete.getSubscriptionsFromContactList(contacts);    
    batchDelete.contacts = contacts;    
    Database.executeBatch(batchDelete);
  }

  //Executed from Finish methods on Batch Deletes
  public void del(List<Contact> contacts){
    for(Contact contact : contacts){
      //Mark Contact as deleted (Inactive__c) now
      if(contact.Inactive__c == false)
        contact.Inactive__c = true;

      //Mark contact inactivated by user
      if(contact.Inactivated_By__c == null)
        contact.Inactivated_By__c = Userinfo.getUserName();

      //Mark contact deleted date
      if(contact.Date_Deleted__c == null) 
        contact.Date_Deleted__c = Datetime.now();

      //Mark the Status__c as Delete so that we don't end up in an infinite loop
      contact.Status__c = 'Delete';
    }

    try{
      update(contacts);
    }
    catch(Exception e){
      throw new ConstructableException('Sorry, unable to complete deletion of this contact because '+e.getMessage());      
    }    
  }
}