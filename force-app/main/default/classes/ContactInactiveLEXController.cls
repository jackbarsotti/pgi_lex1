public class ContactInactiveLEXController {
    
    @AuraEnabled
    public static void updateContact(String recordId){
        if(recordId != null && recordId != '') {
            Contact conObj =[SELECT Id, Name, Inactive__c, FirstName  
                             FROM Contact 
                             WHERE Id =: recordId];
            conObj.Inactive__c = true;
            conObj.FirstName = 'None';
            UPDATE conObj;
        }
    }
}