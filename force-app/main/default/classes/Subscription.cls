public with sharing class Subscription extends AbstractRepository  {

  public final static String table = 'Subscription__c';
  public final static String columns = 'Id, Access_Code__c, Access_Code_Id__c, Account_Code_Prompt__c, Account_Name__c, Add_l_Provisioning_Email_Addresses__c, Add_l_Provisioning_Emails__c, Address_Line_1__c, Address_Line_2__c, App_Share_Allowed__c, Archive_Period__c, Audio_subscription_size__c, Auto_Delete_Slides__c, BBS_CoreAccountId__c, BBS_CoreStatus__c, BBS_L3RAMaster__c, BBS_L3Status__c, BBS_Status__c, BBS_StatusMessage__c, Card_Name__c, Contact__c, City__c, Contact__r.Id, Contact__r.Name, Contact_Toll_Free_Number__c, Contact_Toll_Number__c, Copresenter_Allowed__c, Country__c, CreatedDate, Date_Deleted__c, Entry_Announcement__c, Event_Manager__c, Inactivated_By__c, Inactive__c,  International_Dial_Out_Allowed__c, International_Kit_Number__c, Keep_Active__c, Kit_Name__c, Last_Used_Date__c, LastActivityDate, Moderator_Allowed__c, Name, Parent_Ind_ID__c, Passcode__c, Podcasting__c, PortalAdmin__c, Promotion__c, Provision__c, Quickstart__c, Recording_Allowed__c, Recording_Editing_Allowed__c, Reference_ID__c, Reference_ID_2__c, Reference_ID_3__c, Remote_Control_Allowed__c, Security_Passcode__c, Send_Kit__c, Send_Provisioning_Email__c, SF_Contact_ID__c, Ship_To_Name__c, Slide_Presentation_Allowed__c, State__c, Status__c, Status_Description__c, Subscription_Email__c, Video_Conferencing_Allowed__c, voipAllowed__c, Web_Conference_Allowed__c, Zip__c, Contact__r.Account.Name, Contact_Start_Page__c';

  /**
   * Validations
   */    
  public class builderValidator extends AbstractValidator {     
  } 

  /**
   * Queries
   */
  public Subscription__c findById(Id subscriptionId) {
    return (Subscription__c) Database.query(selectBuilder(table, columns, 'where id =: subscriptionId limit 1'));
  }

  public List<Subscription__c> getSubscriptionsWhereContactInList(List<Id> contactIds){
    return (List<Subscription__c>) Database.query(selectBuilder(table,columns, 'where Provision__c = true and Inactive__c = false and Contact__c in :contactIds'));
  }

  /**
  * Helpers for deletes
  */
  //Executed when someone initiates a delete action for a single subscription (i.e. delete button on contact page)
  public void del(Subscription__c subscription){
    List<Subscription__c> subscriptions = new List<Subscription__c>();
    subscriptions.add(subscription);
    del(subscriptions);
  }  

  //Executed when a list of subscriptions needs to be deleted (i.e. delete all subscriptions under a Contact)
  public void del(List<Subscription__c> subscriptions){
    for(Subscription__c subscription : subscriptions){
      //Mark each subscription as deleted
      subscription.PortalAdmin__c = false;
      subscription.Inactive__c = true;
      subscription.Inactivated_By__c = Userinfo.getUserName();

      //If it was already marked w/ a delete date, don't change it
      if(subscription.Date_Deleted__c == null) 
        subscription.Date_Deleted__c = Datetime.now();

      //If it was already deleted, don't put it back into a deleting status.
      if(subscription.Status__c != 'Delete') 
        subscription.Status__c = 'Deleting';
    }
    try{
      update(subscriptions);    
    }
    catch(Exception e){
      throw new ConstructableException('Sorry, unable to complete deletion of this contact because '+e.getMessage());      
    }
  }
}