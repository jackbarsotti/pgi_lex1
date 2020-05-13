global class BatchSObjectDelete implements Database.Batchable<SObject> {
  public String sObjectName;

  public Id accountId;
  public List<Department__c> departments;
  public List<Contact> contacts;
  public List<Subscription__c> subscriptions;

  public Boolean accountDeleted = false;
  public Boolean departmentsDeleted = false;
  public Boolean contactsDeleted = false;
  public Boolean subscriptionsDeleted = false;

  public String action = '';

  public static AccountRepository accountRepository = new AccountRepository();
  public static Department departmentRepository = new Department();
  public static ContactRepository contactRepository = new ContactRepository();
  public static Subscription subscriptionRepository = new Subscription();

  /*
  * 
  */
  global System.Iterable<SObject> start(Database.BatchableContext BC){
    System.debug('In Start, sObjectName is: '+sObjectName);

    //Process Subscription__c sObjects
    if('Subscription'==sObjectName){
      return subscriptions;
    }
    //Process Contact sObjects
    else if('Contact'==sObjectName){
      return contacts;
    }
    //Process Department__c sObjects
    else if('Department'==sObjectName){
      return departments;
    } 
    //Process Account sObjects       
    else if('Account'==sObjectName){
      Account a = accountRepository.findById(accountId);
      List<Account> accounts = new List<Account>();
      accounts.add(a);
      return accounts;
    }

    return new List<SObject>();
  }

  /*
  * 
  */
  global void execute(Database.BatchableContext BC, List<SObject> sObjectList){
    System.debug('In Execute, sObjectName is: '+sObjectName);
    System.debug('Subscriptions: '+subscriptions);
    System.debug('Contacts: '+contacts);
    System.debug('Departments: '+departments);
    System.debug('Account: '+accountId);    

    if('Subscription'==sObjectName && 'DeleteSubscriptions'==action){
      subscriptionRepository.del(subscriptions);
    }
    else if('Contact'==sObjectName && 'DeleteContacts'==action && subscriptionsDeleted){
      contactRepository.del(contacts);        
    }
    else if('Department'==sObjectName && 'DeleteDepartments'==action && contactsDeleted && subscriptionsDeleted){
      departmentRepository.del(departments);                
    }
    else if('Account'==sObjectName && 'DeleteAccount'==action && departmentsDeleted && contactsDeleted && subscriptionsDeleted){
      Account a = accountRepository.findById(accountId);
      accountRepository.del(a);
    }
  }

  /*
  * 
  */
  global void finish(Database.BatchableContext BC){
    System.debug('In Finish: '+sObjectName);
    System.debug('Subscriptions: '+subscriptions);
    System.debug('Subscriptions Deleted: '+subscriptionsDeleted);
    System.debug('Contacts: '+contacts);
    System.debug('Contacts Deleted: '+contactsDeleted);
    System.debug('Departments: '+departments);
    System.debug('Departments Deleted: '+departmentsDeleted);
    System.debug('Account: '+accountId);
    System.debug('Account Deleted: '+accountDeleted);

    //After DeleteSubscription, run DeleteContacts
    if('Subscription'==sObjectName && 'DeleteSubscriptions'==action){
      afterSubscriptionDeleteRemoveContacts();
    }    

    if('Contact'==sObjectName && 'DeleteContacts'==action){
      //Before DeleteContacts, run DeleteSubscriptions
      if(!subscriptionsDeleted && subscriptions != null){
        beforeContactDeleteRemoveSubscriptions();
      }

      //After DeleteContacts, run DeleteDepartments (if there are any)
      else if(departments != null && departments.size() > 0) {
          afterContactDeleteRemoveDepartments();          
      }

      //After Contacts are deleted and there are no departments, then delete the account (if there is one)      
      else if( (departments == null || departments.size() < 1) && accountId != null)  {
        afterDepartmentDeleteRemoveAccount();
      }
    }

    if('Department'==sObjectName && 'DeleteDepartments'==action){
      //Before DeleteDepartments, run DeleteContacts
      if(!contactsDeleted && contacts != null){
        beforeDepartmentDeleteRemoveContacts();
      }

      //After DeleteDepartments, run DeleteAccount (if there are any)
      else{
        if(accountId != null){
          afterDepartmentDeleteRemoveAccount();          
        }
      }
    }

    if('Account'==sObjectName && 'DeleteAccount'==action){
      //Before AccountDelete, run DeleteDepartments
      if(!departmentsDeleted){
        beforeAccountDeleteRemoveDepartments();
      }

      //After DeleteDepartments, run DeleteAccount
      else{
        //NOOP -- Account Delete is handled after department deletes
      }
    }
  }

  public void afterSubscriptionDeleteRemoveContacts() {
    String jobName = 'Delete Contacts: '+String.valueOf(DateTime.now().secondGmt())+String.valueOf(DateTime.now().millisecondGmt());    
    BatchSObjectDelete batchContactDelete = new BatchSObjectDelete();
    batchContactDelete.sObjectName = 'Contact';
    batchContactDelete.action = 'DeleteContacts';
    batchContactDelete.subscriptionsDeleted = true;
    batchContactDelete.subscriptions = subscriptions;
    batchContactDelete.contacts = contacts;
    batchContactDelete.departments = departments;
    batchContactDelete.accountId = accountId;
    System.scheduleBatch(batchContactDelete, jobName, 1);
  }

  public void beforeContactDeleteRemoveSubscriptions() {
    String jobName = 'Delete Subscriptions: '+String.valueOf(DateTime.now().secondGmt())+String.valueOf(DateTime.now().millisecondGmt());
    BatchSObjectDelete batchSubDelete = new BatchSObjectDelete();
    batchSubDelete.sObjectName = 'Subscription';
    batchSubDelete.action = 'DeleteSubscriptions';
    batchSubDelete.subscriptionsDeleted = false;
    batchSubDelete.subscriptions = subscriptions;
    batchSubDelete.contacts = contacts;  
    batchSubDelete.departments = departments;
    batchSubDelete.accountId = accountId;  
    System.scheduleBatch(batchSubDelete, jobName, 1);      
  }

  public void afterContactDeleteRemoveDepartments() {
    String jobName = 'Delete Departments: '+String.valueOf(DateTime.now().secondGmt())+String.valueOf(DateTime.now().millisecondGmt());
    BatchSObjectDelete batchDepartmentDelete = new BatchSObjectDelete();
    batchDepartmentDelete.sObjectName = 'Department';
    batchDepartmentDelete.action = 'DeleteDepartments';
    batchDepartmentDelete.subscriptionsDeleted = true;
    batchDepartmentDelete.contactsDeleted = true;
    batchDepartmentDelete.subscriptions = subscriptions;
    batchDepartmentDelete.contacts = contacts;  
    batchDepartmentDelete.departments = departments;
    batchDepartmentDelete.accountId = accountId;        
    System.scheduleBatch(batchDepartmentDelete, jobName, 1);
  }

  public void beforeDepartmentDeleteRemoveContacts() {
    String jobName = 'Delete Contacts: '+String.valueOf(DateTime.now().secondGmt())+String.valueOf(DateTime.now().millisecondGmt());
    BatchSObjectDelete batchContactDelete = new BatchSObjectDelete();
    batchContactDelete.sObjectName = 'Contact';
    batchContactDelete.action = 'DeleteContacts';
    batchContactDelete.subscriptionsDeleted = false;
    batchContactDelete.contactsDeleted = false;   
    batchContactDelete.subscriptions = subscriptions;     
    batchContactDelete.contacts = contacts;
    batchContactDelete.departments = departments;
    batchContactDelete.accountId = accountId;
    System.scheduleBatch(batchContactDelete, jobName, 1);
  }

  public void afterDepartmentDeleteRemoveAccount() {
    String jobName = 'Delete Account: '+String.valueOf(DateTime.now().secondGmt())+String.valueOf(DateTime.now().millisecondGmt());
    BatchSObjectDelete batchAccountDelete = new BatchSObjectDelete();
    batchAccountDelete.sObjectName = 'Account';
    batchAccountDelete.action = 'DeleteAccount';
    batchAccountDelete.subscriptionsDeleted = true;
    batchAccountDelete.contactsDeleted = true;
    batchAccountDelete.departmentsDeleted = true;
    batchAccountDelete.subscriptions = subscriptions;
    batchAccountDelete.contacts = contacts;  
    batchAccountDelete.departments = departments;
    batchAccountDelete.accountId = accountId;    
    System.scheduleBatch(batchAccountDelete, jobName, 1);    
  }

  public void beforeAccountDeleteRemoveDepartments() {
    String jobName = 'Delete Departments: '+String.valueOf(DateTime.now().secondGmt())+String.valueOf(DateTime.now().millisecondGmt());
    BatchSObjectDelete batchDepartmentDelete = new BatchSObjectDelete();
    batchDepartmentDelete.sObjectName = 'Department';
    batchDepartmentDelete.action = 'DeleteDepartments';
    batchDepartmentDelete.subscriptionsDeleted = false;
    batchDepartmentDelete.contactsDeleted = false;
    batchDepartmentDelete.departmentsDeleted = false;
    batchDepartmentDelete.subscriptions = subscriptions;
    batchDepartmentDelete.contacts = contacts;  
    batchDepartmentDelete.departments = departments;
    batchDepartmentDelete.accountId = accountId;    
    System.scheduleBatch(batchDepartmentDelete, jobName, 1);    
  }

  public static List<Subscription__c> getSubscriptionsFromContactList(List<Contact> contacts){
    List<Id> contactIds = new List<Id>();
    for(Contact contact : contacts){
      contactIds.add(contact.Id);
    }
    return subscriptionRepository.getSubscriptionsWhereContactInList(contactIds);      
  }

  public static List<Contact> getContactsFromDepartmentList(List<Department__c> departments){
    List<Id> departmentIds = new List<Id>();
    for(Department__c department : departments){
      departmentIds.add(department.Id);
    }
    return contactRepository.getContactsWhereDepartmentInList(departmentIds);  
  }

  public static List<Contact> getContactsByAccountId(Id accountId){
    return contactRepository.getContactsByAccountId(accountId);  
  }  

  public static List<Department__c> getDepartmentsFromAccountId(Id accountId){
    return departmentRepository.getDepartmentsByAccountId(accountId);
  }

}