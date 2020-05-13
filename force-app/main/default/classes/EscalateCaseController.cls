/* Class Name : EscalateCaseController
 * Developer  : Anup
 * Ticket     : RT-293
 */
public class EscalateCaseController {
    public  String selectedEscalationType {get; set;}
    public  String selectedEscalationRecordType {get; set;}
    public  Boolean isContinue{get; set;}
    public  string currentRecordId {get; set;}
    public  Boolean isEscalated{get; set;}
    public  String returnId {get;set;}
    /* Method Name : EscalateCaseController
    *  Description : Constructor method to initialise the fields
    */
    public EscalateCaseController(ApexPages.StandardController controller) {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        isContinue = true;
        selectedEscalationType ='';
        selectedEscalationRecordType='';
    }
    /* Method Name : init
    *  Description : This method will be called when the vf page loads
    */
    public  void init(){
        isEscalated = [SELECT Escalated__c FROM Case where id=:currentRecordId].Escalated__c;
        if(isEscalated) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This Email has already been escalated, please view the Parent Case or related FinReq for further actions.'));
        }
    }
    /* Method Name : getEscalationType
    *  Description : Assigning Escalation type to the select box
    */
    public  List<SelectOption> getEscalationType() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        options.add(new SelectOption('Case','Case'));
        options.add(new SelectOption('Financial_Request__c','FinReq'));
        return options;
    }
    /* Method Name : handleRecordButton
    *  Description : 
    */
    public  void handleRecordButton(){
        isContinue = false;
    }
    /* Method Name : handleRecord
    *  Description : The record will be created based on the selected escalation type and record type
    */
    public  void handleRecord(){
        System.debug('Id->'+currentRecordId);
        isContinue = true;
        Id recordTypeId = [SELECT Id FROM RecordType WHERE name LIKE :('%' + selectedEscalationRecordType + '%') and SobjectType =: selectedEscalationType limit 1].Id;
        Case currentCase = [SELECT ID, PGi_Client__c, Escalated__c,SuppliedEmail, PGi_Company__c, Subject, Caller_Name__c, ParentId, Follow_Up_Email_Address__c  
                            FROM Case 
                            WHERE Id =: currentRecordId];
        if(selectedEscalationType == 'Case'){
            Case escalatedCase = new Case(Origin = 'Email', 
                                    recordTypeId = recordTypeId,
                                    PGi_Client__c = currentCase.PGi_Client__c,
                                    PGi_Company__c = currentCase.PGi_Company__c,
                                    Follow_Up_Email_Address__c = currentCase.SuppliedEmail,
                                    Subject = currentCase.Subject,
                                    Caller_Name__c = currentCase.Caller_Name__c);
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            escalatedCase.setOptions(dmo);
            INSERT escalatedCase;
            currentCase.ParentId = escalatedCase.Id;
            currentCase.Escalated__c = true;
            UPDATE currentCase;
            returnId = escalatedCase.Id;
        }else{
            
            Financial_Request__c finReq = new Financial_Request__c(
                                    recordTypeId = recordTypeId,
                                    PGi_Client__c = currentCase.PGi_Client__c,
                                    PGi_Company__c = currentCase.PGi_Company__c,
                                    SuppliedEmail__c = currentCase.SuppliedEmail, 
                                    Subject__c = currentCase.Subject,
                                    Origin__c = 'Email',
                                    Related_Case__c = currentCase.Id);          
            INSERT finReq;
            currentCase.Escalated__c = true;
            UPDATE currentCase;
            returnId = finReq.Id;
        }
    }
    /* Method Name : getEscalationRecordType
    *  Description : Assigning Escalation record type to the select box
    */
    public  List<SelectOption> getEscalationRecordType() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        if(selectedEscalationType!='null' && selectedEscalationType != '' && selectedEscalationType != 'undefined'){
            if(selectedEscalationType == 'Case'){
                options.add(new SelectOption('Internal Support','Internal Support'));
                options.add(new SelectOption('Client External Support','Client External Support'));
                options.add(new SelectOption('Reservations Request','Reservations Request'));
                options.add(new SelectOption('Parent Ticket (NOC)','Parent Ticket (NOC)'));
                return options;
            }
            else if(selectedEscalationType == 'Financial_Request__c'){
                options.add(new SelectOption('Billing Support','Billing Support'));
                options.add(new SelectOption('Company Credit','Company Credit'));
                options.add(new SelectOption('Payment Research Request','Payment Research Request'));
                options.add(new SelectOption('Credit Request','Credit Request'));
                options.add(new SelectOption('Pricing Help Request','Pricing Help Request'));
                options.add(new SelectOption('Profile Request','Profile Request'));
                options.add(new SelectOption('Rate Entry Request','Rate Entry Request'));
                options.add(new SelectOption('Request for Adjustment','Request for Adjustment'));
                options.add(new SelectOption('Revenue Assurance Audit Request','Revenue Assurance Audit Request'));
                return options;
            }
        }
            return options;
    }
    
    
}