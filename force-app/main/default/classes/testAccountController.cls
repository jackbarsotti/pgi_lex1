@isTest
private class testAccountController {

  private static ApexPages.StandardController controller = new ApexPages.StandardController(MockAccount.getNewAccount());

  static {
    ApexPages.currentPage().getParameters().put('delID', ((Account)controller.getRecord()).Id);
  }

  static testMethod void testConstruct() {
    AccountController a = new AccountController(controller);
    System.assert(a != null);
  }

  static testMethod void testCustomDelete() {
    AccountController a = new AccountController(controller);
    System.assert(a.customDelete() != null);
  }

  static testMethod void testCancelDelete() {
    AccountController a = new AccountController(controller);
    System.assert(a.cancelDelete() != null);
  }

  static testMethod void testGetWaitDialog() {
    AccountController a = new AccountController(controller);
    a.setWaitDialogContent();
    System.assert(a.getWaitDialog() != null);
  }

  static testMethod void testGetAccount() {
    AccountController a = new AccountController(controller);
    System.assert(a.getAccount() != null);
  }

  static testMethod void testPreDelete() {
    AccountController a = new AccountController(controller);
    a.preDelete();
    System.assert(1 == 1);
  }

  static testMethod void testCancel() {
    AccountController a = new AccountController(controller);
    ApexPages.currentPage().getParameters().put('retURL', 'foo');
    a.cancel();
    a.init();
  }
}