public with sharing class RTConfig {
    public static final String ACCOUNT_PROVISIONED_ID = '00N50000001ZfXa';
    public static final String ACCOUNT_CARD_NAME_ID = '00N50000001ZfTg';
    public static final String NOT_PROVISIONED_RECORD_TYPE_ID = '0121g0000000Cz1';
    public static final String DEFAULT_TOLL_FREE_NUMBER = '8667401260';
    public static final String SFDEVELOPER_EMAIL_ADDRESS = 'sfdeveloper@readytalk.com';
    
    public static final Integer LIMIT_NUMBER_SUBSCRIPTIONS = 100;
    
    public static final Map<String, String> OBJECT_TO_CONTROLLER_MAPPING = new Map<String, String>{
            'Subscription__c' => '/apex/AccessCode',
            'Contact' => '/apex/Contact',
            'Department__c' => '/apex/Department'};
}