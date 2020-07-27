public class CreateABlankChildFinReqController {
    @AuraEnabled
    public static Financial_Request__c  getFields(String recordId){
      Financial_Request__c finreqObj = [SELECT Id ,Name 
                                                FROM Financial_Request__c 
                                                WHERE Id =: recordId];
        return finreqObj;
    }

}