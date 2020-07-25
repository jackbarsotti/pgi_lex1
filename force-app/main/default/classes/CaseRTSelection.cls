public with sharing class CaseRTSelection {
    @AuraEnabled(cacheable=true)
    public static List<RecordType> getRecordType() {
    return [SELECT Id, Name, DeveloperName, Description 
            FROM RecordType 
            WHERE SobjectType = 'Case'];   
    }
@AuraEnabled(cacheable=true)
public static Id getDefaultRecordType() {
List<Schema.RecordTypeInfo> infos = Schema.SObjectType.Case.RecordTypeInfos;
Id defaultRecordTypeId;

//check each one
for (Schema.RecordTypeInfo info : infos) {
if (info.DefaultRecordTypeMapping) {
defaultRecordTypeId = info.RecordTypeId;
}
}
return defaultRecordTypeId;
//here is the default Opportunity RecordType Id for the current user

}
}