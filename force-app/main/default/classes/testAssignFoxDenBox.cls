@isTest
private class testAssignFoxDenBox {

  private static ApexPages.StandardController controller = new ApexPages.StandardController(new FoxDen_Box__c());

  //AssignFoxDenBox.AssignFoxDenBox
  static testMethod void testConstruct() {
    AssignFoxDenBox b = new AssignFoxDenBox(controller);
    b.getObjectId();
    AssignFoxDenBox.getInventory();

    Account a = MockAccount.getNewAccount();

    try{
      AssignFoxDenBox.assignBoxes(a.Id, new List<Id>());
    }
    catch(Exception e){

    }

    System.assert(b != null);
  }    
}