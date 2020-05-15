public class ContactInactiveController {
@AuraEnabled
    public static void updateContact(String recordId){
        if(recordId != null || recordId != '') {
            Contact conObj =[Select Id,Name,Inactive__c,FirstName  from contact Where Id =:recordId];
            conObj.Inactive__c=true;
            conObj.FirstName = 'None';
            UPDATE conObj;
        }
    }
}