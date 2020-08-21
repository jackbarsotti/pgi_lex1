public with sharing class CaseEditOverrideController {
    @AuraEnabled
    public static case getRecordTypeDetail(string recordId) {
        case objcase =[SELECT Id, RecordtypeId, RecordType.name FROM Case where Id =: recordId];
        return objcase;
    }
}