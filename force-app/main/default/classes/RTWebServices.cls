global class RTWebServices {
  webService static String RTAccessCodeUtilsGetNewAccessCode(String phone) {
    return RTAccessCodeUtils.getNewAccessCode(phone);
  }

  webService static String RTAccessCodeUtilsGetNewValidPasscode(String accessCode) {
    return RTAccessCodeUtils.getValidNewPasscode(accessCode);
  }

  webService static Boolean RTAccessCodeUtilsValidatePasscode(String passCode, String accessCode){
    return ValidateSubscriptionFields.validatePassCodeAgainstAccessCode(passcode, accessCode);
  }
  
  webService static List<String> RTCascadeContactAddressToAccessCode(String contactId) {
    return RTContactUtils.pushAddressToActiveAccessCodes(contactId);
  }
}