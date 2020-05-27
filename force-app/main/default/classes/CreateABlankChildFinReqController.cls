public class CreateABlankChildFinReqController {
    @AuraEnabled
    public static Financial_Request__c  getFields(String recordId){
      Financial_Request__c finreqObj = [Select Id ,Name 
                                        FROM Financial_Request__c where Id =: recordId];
        return finreqObj;
    }

}