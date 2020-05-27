public class ChatEscalateLandingPageController {
    
    public  Id currentRecordId {get; set;}
    public  String returnId {get;set;}
    public  String returnRecordType {get;set;}
    
    public ChatEscalateLandingPageController() {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');   
    }
    
    public void viewRecord() {
        returnId = ApexPages.currentPage().getParameters().get('recordId');
        returnRecordType = ApexPages.currentPage().getParameters().get('recordType');
    }
}