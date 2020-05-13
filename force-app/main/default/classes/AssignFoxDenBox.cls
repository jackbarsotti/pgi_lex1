global with sharing class AssignFoxDenBox {  
  private final Id objectId;
  
  public AssignFoxDenBox(ApexPages.StandardController controller) {
    SObject o = controller.getRecord();    

    if(o!=null)
      this.objectId = (Id)o.get('Id');
    else
      this.objectId = ApexPages.currentPage().getParameters().get('id');
  }

  /**
  * Returns all FoxDen Boxes in inventory
  */
  @RemoteAction
  global static List<FoxDen_Box__c> getInventory() {
    FoxDenBox foxDenBoxRepo = new FoxDenBox();
    return foxDenBoxRepo.getFoxDenBoxesWhereAccountIdIsNullAndActive();
  }

  /**
  * Assigns FoxDen Box(es) to an account
  */
  @RemoteAction
  global static void assignBoxes(Id accountId, List<Id> boxesToAssign) {
      System.debug('boxesToAssign>>>>>>>>>>> '+boxesToAssign);
    if(boxesToAssign == null || boxesToAssign.size() < 1)
      throw new ValidationException('Select a FoxDen Box to continue.');      

    FoxDenBox foxDenBoxRepo = new FoxDenBox();

    List<FoxDen_Box__c> boxes = foxDenBoxRepo.getFoxDenBoxesInSet(boxesToAssign);
    List<FoxDen_Box__c> boxesToUpdate = new List<FoxDen_Box__c>();

    for(FoxDen_Box__C box : boxes){
      boxesToUpdate.add(foxDenBoxRepo.assignBox(accountId, box));
        
    }
	System.debug('boxesToUpdate>>>>'+boxesToUpdate);
      
    try{
      update(boxesToUpdate);    
    }
    catch(Exception e){
      throw new ValidationException('Could not assign FoxDen Boxes because of error: '+e);
    }
  }  

  public Id getObjectId() {
    return this.objectId;
  }
}