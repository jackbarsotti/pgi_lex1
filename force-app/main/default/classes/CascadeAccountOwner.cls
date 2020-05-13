public class CascadeAccountOwner implements Queueable{
  private String objectType;
  private Id accountId;
  private Id oldAccountOwnerId;
  private Id newAccountOwnerId;

  public CasCadeAccountOwner(String objectType, Id accountId, Id oldAccountOwnerId, Id newAccountOwnerId){
    this.objectType = objectType;
    this.accountId = accountId;
    this.oldAccountOwnerId = oldAccountOwnerId;
    this.newAccountOwnerId = newAccountOwnerId;
  }

  public void execute(QueueableContext context) {            
    if(this.objectType.equals('Subscription__c')){
      updateSubscriptions();
      System.enqueueJob(new CascadeAccountOwner('Department__c', this.accountId, this.oldAccountOwnerId, this.newAccountOwnerId));
    }
    else if(this.objectType.equals('Department__c')){
      updateDepartments();
      System.enqueueJob(new CascadeAccountOwner('Contact', this.accountId, this.oldAccountOwnerId, this.newAccountOwnerId));
    }
    else if(this.objectType.equals('Contact')){
      updateContacts();
    }
    else if(this.objectType.equals('Execute')){
      System.enqueueJob(new CascadeAccountOwner('Subscription__c', this.accountId, this.oldAccountOwnerId, this.newAccountOwnerId));
    }
    else{
      System.debug('Invalid objectType '+this.objectType+' passed to CascadeAccountOwner.');
    }
  }

  private void updateSubscriptions(){
    String query = 'select id, inactive__c, OwnerId, contact__r.Account.id from Subscription__c where contact__r.Account.id = \'' + this.accountId + '\'' +
      ' and inactive__c=false';

    List<Subscription__c> objects = Database.query(query);
    List<Subscription__c> updates = new List<Subscription__c>();

    for(Subscription__c o : objects){      
      o.Ownerid=this.newAccountOwnerId;
      updates.add(o);
    }

    try{
      update updates;
    }
    catch(Exception e){

    }
  }

  private void updateDepartments(){
    String query = 'select id, inactive__c, OwnerId, Parent_Account__r.id from Department__c where Parent_Account__r.id = \'' + this.accountId + '\'' +
      ' and inactive__c=false';
    List<Department__c> objects = Database.query(query);
    List<Department__c> updates = new List<Department__c>();

    for(Department__c o : objects){
      o.Ownerid=this.newAccountOwnerId;
      updates.add(o);      
    }

    try{
      update updates;
    }
    catch(Exception e){

    }
  }

  private void updateContacts(){
    String query = 'select id, inactive__c, OwnerId, Contact.Account.id from Contact where Contact.Account.id = \'' + this.accountId + '\'' +
      ' and inactive__c=false';

    List<Contact> objects = Database.query(query);
    List<Contact> updates = new List<Contact>();

    for(Contact o : objects){      
      o.Ownerid=this.newAccountOwnerId;
      updates.add(o);      
    }

    try{
      update updates;
    }
    catch(Exception e){

    }
  }
}