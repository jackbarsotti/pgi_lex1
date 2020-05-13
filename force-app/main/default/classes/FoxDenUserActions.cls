public class FoxDenUserActions {
  /**
  * Determines whether or not foxden_users need to get a provisioning email
  */
  public static boolean sendProvisioningEmailIfNeeded(FoxDen_User__c newUser, FoxDen_User__c oldUser) {
    if(ProvisioningEmailHelper.needsFoxDenProvisioningEmail(newUser, oldUser)) {
      String templateDevName = 'Provisioning_FoxDen';    
      return ProvisioningEmailHelper.sendFoxDenProvisioningEmail(newUser, templateDevName);
    } 
    else {
      return false;
    }
  }    
}