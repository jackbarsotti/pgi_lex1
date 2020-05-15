public class LeadConvertJsController {
@AuraEnabled
    public static string getStatus(String recordId){
        string status ='';
        if(recordId != null || recordId != ''){
      Lead objLead = [Select Id,Status from Lead where Id =:recordId];
         status = objLead.Status;
        }
        return status;
    }
}