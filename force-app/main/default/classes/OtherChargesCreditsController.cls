public with sharing class OtherChargesCreditsController {

    OtherChargeCredit__c otherChargeCredit;
    Id accessCodeID;

    public OtherChargesCreditsController(ApexPages.StandardController controller) {        
        otherChargeCredit = (OtherChargeCredit__c)controller.getRecord(); 
        accessCodeID = otherChargeCredit.AccessCode__c;
    }
    
    public PageReference save() {
        try{
            if(!ValidateOtherChargeCreditFields.validateChargeCredit(otherChargeCredit)) return null;                            
            upsert(otherChargeCredit);
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
            return null;
        }
        
        return goBack();
    }    
    
    public PageReference customDelete() {
        this.otherChargeCredit.Inactive__c = true;
        this.otherChargeCredit.Inactivated_By__c = Userinfo.getUserName();
        this.otherChargeCredit.Date_Deleted__c = Datetime.now();
        update(this.otherChargeCredit);
        return goBack();        
    }
    
    public PageReference checkBilledStatus() {
        String delID = ApexPages.currentPage().getParameters().get('delID');
        String id = ApexPages.currentPage().getParameters().get('id');
        
        //If we are deleting and the billed date is null, then allow the delete, and go back to the subscription page
        if(delID != null && otherChargeCredit.BilledDate__c == null) {
            return customDelete();            
        }
        
        //If we are deleting and the billed date is not null, then don't allow the delete, and display an error message
        else if(delID != null && otherChargeCredit.BilledDate__c != null) {
            otherChargeCredit.addError('You cannot delete an Other Charge or Credit that has already been billed.');
            return null;
        }
        
        //If we are editing (have and ID param) and the billed date is not null, then display an error message
        else if(id != null && otherChargeCredit.BilledDate__c != null) {
            otherChargeCredit.addError('You cannot edit an Other Charge or Credit that has already been billed.');
            return null;
        }
        
        return null;
    }
    
    public OtherChargeCredit__c getOtherChargeCredit(){
        return otherChargeCredit;
    }
    
    public PageReference goBack() {
        //Redirect back to the owning subscription page
        Subscription__c subscription = [select id from Subscription__c where id = : accessCodeID];
          
        PageReference subscriptionPage = new ApexPages.StandardController(subscription).view();
        subscriptionPage.setRedirect(true);

        return subscriptionPage;
    }
}