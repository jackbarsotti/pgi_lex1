public with sharing class AccountRepository extends AbstractRepository {

  public final static String table = 'Account';
  public final static String columns = 'id,name';

  /**
   * Queries
   */
  public Account findById(Id accountId) {
    return (Account) Database.query(selectBuilder(table,columns,'where id = :accountId limit 1'));
  }

  /**
   * Helper for delete
   */
  public void cascadeDelete(Account account){
    if(account.Inactive__c == true && account.Status__c=='Deleting')
      account.Inactive__c = false;

    List<Department__c> departments = BatchSObjectDelete.getDepartmentsFromAccountId(account.Id);
    List<Contact> contacts = BatchSObjectDelete.getContactsByAccountId(account.Id);
    BatchSObjectDelete batchDelete1 = new BatchSObjectDelete();
    batchDelete1.sObjectName = 'Account';
    batchDelete1.action = 'DeleteAccount';
    batchDelete1.subscriptionsDeleted = false; 
    batchDelete1.contactsDeleted = false;    
    batchDelete1.departmentsDeleted = false;
    batchDelete1.subscriptions = BatchSObjectDelete.getSubscriptionsFromContactList(contacts);  
    batchDelete1.contacts = contacts;
    batchDelete1.departments = departments;
    batchDelete1.accountId = account.Id;
    Database.executeBatch(batchDelete1);  
  }

  public void del(Account account){
    try{
      //Delete the Account
      account.Inactive__c = true;
      account.Inactivated_By__c = Userinfo.getUserName();
      account.Date_Deleted__c = Datetime.now();
      account.Status__c = 'Delete';  
      update(account);  
    }
    catch(Exception e){
      throw new ConstructableException('Sorry, unable to complete the deletion of this account because '+e.getMessage());
    }
  }  
}