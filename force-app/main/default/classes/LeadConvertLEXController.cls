public class LeadConvertLEXController {
@AuraEnabled
    public static string getStatus(String recordId){
        string status ='';
        if(recordId != null || recordId != ''){
      Lead objLead = [SELECT Id,Status 
                      FROM Lead 
                      WHERE Id =:recordId];
         status = objLead.Status;
        }
        return status;
    }
}