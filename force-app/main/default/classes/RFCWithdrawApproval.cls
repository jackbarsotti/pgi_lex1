public class RFCWithdrawApproval {
    private ApexPages.StandardController controller {get; set;}
    public RFCWithdrawApproval(ApexPages.StandardController std) {
        this.controller = std;
    }
    public PageReference withdraw() {
        Request_For_Change__c myObj = [SELECT isWithdrawRequestClicked__c, Status__c FROM Request_For_Change__c WHERE Id =: controller.getId()];
        if(myObj.Status__c == 'Approved') { 
	        myObj.Status__c = 'Draft'; 
            myObj.isWithdrawRequestClicked__c  = !myObj.isWithdrawRequestClicked__c ;
        } else if(myObj.Status__c == 'Complete' || myObj.Status__c == 'Unsuccessful') { 
	        myObj.Status__c = 'Approved'; 
        } else { 
	        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Withdrawing is only for Approved or Closed requests,if your request is Pending Approval then use the ' + 'Recall Approval Request'+ ' button down in the Approval area')); 
            return null;
        }
        try {
            update myObj;
        } catch (exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
        }
        return new PageReference('/' + myObj.Id);
    }
}