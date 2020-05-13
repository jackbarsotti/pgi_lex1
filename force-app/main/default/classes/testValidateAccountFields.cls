@isTest
private class testValidateAccountFields {
    private static List<Account> newList;
    private static List<Account> oldList;
    
    static {
        MockAccount mock = new MockAccount();
        
        MockAccount badMock = new MockAccount();
        badMock.ReservationlessWeb = 0.140;
        
        newList = new List<Account>();
        newList.add((Account)RTDatabaseUtils.getEntireSObject(new Account(), mock.getAccount().id));
        
        oldList = new List<Account>();
        oldList.add((Account)RTDatabaseUtils.getEntireSObject(new Account(), badMock.getAccount().id));
    }
    
    /*
static testMethod void testValidAudioRateStartDate(){
System.assert(ValidateAccountFields.validateAudioRateStartDate(newList, oldList) == false); 
Date startOfPreviousMonth = date.today().addMonths(-1).toStartOfMonth();
newList[0].Rate_Start_Date__c = startOfPreviousMonth;
System.assert(ValidateAccountFields.validateAudioRateStartDate(newList, oldList) == true); 
}
*/
    static testMethod void testValidateAccountSource() {
        System.assert(ValidateAccountFields.validateAccountSource(newList) == true); 
    }
    
    static testMethod void testValidateAccountSourceValueChanged() {
        for(Account a:newList){
           a.AccountSource ='Data.com';
          }
        update newList;
        System.assert(ValidateAccountFields.validateAccountSource(newList) == false);
    }
    
    static testMethod void testvalidateInvoiceFormat() {
        System.assert(ValidateAccountFields.validateInvoiceFormat(newList, oldList) == true);
    }
    
    static testMethod void testvalidateInvoiceTypes() {
        System.assert(ValidateAccountFields.validateInvoiceTypes(newList, oldList) == true);
    }
    static testMethod void testvalidateInvoiceTypesNullValues() {
         for(Account a:newList){
           a.Invoice_Types__c=null;
          }
        update newList;
        System.assert(ValidateAccountFields.validateInvoiceTypes(newList, oldList) == false);
    }
    
    static testMethod void testvalidateBillingCountry() {
        System.assert(ValidateAccountFields.validateBillingCountry(newList) == true);
    }
    // static testMethod void testtimeFrameOKToBulkDelete(){
    //     oldList=null;
    //     System.assert(ValidateAccountFields.validateAccessCodeCount(newList, oldList) == true);
    //     System.assert(ValidateAccountFields.timeFrameOKToBulkDelete==true);
    //     // System.assert(ValidateAccountFields.timeFrameOKToBulkDelete==false);
    // }
   
    static testMethod void testvalidateAccessCodeCount(){
        System.assert(ValidateAccountFields.validateAccessCodeCount(newList, oldList) == true);
    }
    static testMethod void testvalidateAccessCodeCountNull(){
        newList=null;
        System.assert(ValidateAccountFields.validateAccessCodeCount(newList, oldList) == true);
         System.assert(ValidateAccountFields.validateAccountSource(newList) == true);
    }
}