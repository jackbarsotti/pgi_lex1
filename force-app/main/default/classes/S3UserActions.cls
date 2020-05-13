public class S3UserActions {
  /**
  * Determines whether or not s3User need to get a provisioning email
  */
  public static boolean sendProvisioningEmailIfNeeded(S3User__c newUser, S3User__c oldUser) {
    if(ProvisioningEmailHelper.needsS3ProvisioningEmail(newUser, oldUser)) {
      String templateDevName = 'Provisioning_Replay';    
      return ProvisioningEmailHelper.sendS3ProvisioningEmail(newUser, templateDevName);
    } 
    else {
      return false;
    }
  }    
}