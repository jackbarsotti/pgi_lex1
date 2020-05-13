public with sharing class createFinReqChild {
    @AuraEnabled( cacheable = true )
    public static Map<String, Object> getFieldDescribeMap( String objectName ) {

        Map<String, Object> fieldDescribeMap = new Map<String, Object>();

        // Performance trick to use Type.forName instead of Schema.getGlobalDescribe()
        // https://salesforce.stackexchange.com/a/32538/987
        // https://salesforce.stackexchange.com/a/219010/987
        Type reflector = Type.forName( objectName );
        SObject obj = (SObject) reflector.newInstance();
        SObjectType objType = obj.getSObjectType();

        DescribeSObjectResult describe = objType.getDescribe();
        Map<String, SObjectField> fieldsMap = describe.fields.getMap();
        for ( String fieldName : fieldsMap.keySet() ) {
            DescribeFieldResult fieldDescribe = fieldsMap.get( fieldName ).getDescribe();
            fieldDescribeMap.put( fieldDescribe.getName(), new Map<String, Object>{
                'accessible' => fieldDescribe.isAccessible(),
                'createable' => fieldDescribe.isCreateable(),
                'updateable' => fieldDescribe.isUpdateable()
            });
        }

        return fieldDescribeMap;
    }

}