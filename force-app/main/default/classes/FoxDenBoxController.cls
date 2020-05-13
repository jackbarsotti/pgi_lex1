global with sharing class FoxDenBoxController extends BaseController {
  
  FoxDen_Box__c box {get; set;}
  public Boolean isDelete;

  public FoxDenBoxController(ApexPages.StandardController controller) {    
    FoxDen_Box__c box = (FoxDen_Box__c)controller.getRecord();    
    
    if(box!=null){      
      this.box = box;
    }    

    if(ApexPages.currentPage().getParameters().get('delID') != null){
      this.isDelete = true;
    }
  }

  public FoxDenBoxController(){    
  }

  @RemoteAction
  public static void customDelete(String boxId){
    FoxDenBox foxDenBoxRepository = new FoxDenBox();    
    FoxDen_Box__c box = foxDenBoxRepository.findById(boxId);

    box.Inactive__c = true;

    //If it was already marked w/ a delete date, don't change it
    if(box.Date_Deleted__c == null) 
      box.Date_Deleted__c = Datetime.now();

    //If it was already deleted, don't put it back into a deleting status.
    if(box.Status__c != 'Delete') 
      box.Status__c = 'Deleting';
  
    try{
      update(box);    
    }
    catch(Exception e){
      throw new ValidationException('Sorry, unable to complete deletion of this FoxDen Box because '+e.getMessage());      
    }
  }

  public FoxDen_Box__c getBox(){
    return this.box;
  }

  public String getBoxId(){
    return this.box.Id;
  }

  public Boolean getIsDelete(){
    return this.isDelete;
  }
}