global with sharing class AccessCodeController extends BaseController {
    
    Account a;
    Contact c;
    Subscription__c sub;
    WaitDialog dialog;
    boolean isValidContact;
    String deleteID;
    
    public String planStartDate {
        set;
        get {
            if (planStartDate == null)
                planStartDate = Date.today().format();
            return planStartDate;
        }
    }
    
    public String planId {get; set;}
    public List<SelectOption> accountLevelPlans;
    
    /**
* Default Constructor
*/
    public AccessCodeController() {
        //Delete
        this.deleteID = ApexPages.currentPage().getParameters().get('delID');
        
        //New Subscription
        if (this.deleteID == null) {
            this.sub = new Subscription__c();
            this.c = (Contact) RTDatabaseUtils.getEntireSObject(new Contact(), getPageID(), ',Account.Status__c,Account.defaultPlan__c,Account.Id');
            this.a = (Account) RTDatabaseUtils.getEntireSObject(new Account(), this.c.AccountId);      
            
            //Copy fields from Account/Department/Contact to this subscription
            RTAccessCodeUtils.copyFields(this.sub, this.c, this.a);
        } else
            this.sub = (Subscription__c) RTDatabaseUtils.getEntireSObject(new Subscription__c(), this.deleteID);
    }
    
    public AccessCodeController(ApexPages.StandardController controller) {
        Subscription__c s = (Subscription__c)controller.getRecord();    
        
        if(s!=null){      
            this.sub = s;
        }
    }  
    
    /**
* Action fired on page load
*/
    public PageReference checkContactStatus() {
        if (this.deleteID != null)
            return customDelete();
        
        //Before the page loads, setup the wait dialog content if we have one
        setWaitDialogContent();
        
        //Provision contact if it is not already provisioned (i.e. does not have an Active status)
        if (isValidContact() && (this.c.Status__c == null || !this.c.Status__c.equals('Active'))) {
            try {
                RTContactUtils.provision(this.c);
            } catch (Exception ex) {
                this.c.addError('Could not complete provisioning:');
                setIsValidContact(false);
                ApexPages.addMessages(ex);
                return null;
            }
        }
        
        return null;
    }
    
    /**
* Setter for the wait dialog content.  Usually called during polling
*/
    public void setWaitDialogContent() {
        this.dialog = new WaitDialog();
        Contact temp = null;
        
        //Must re-query here to get the most recent changes to the Contact object
        try {
            temp = (Contact) RTDatabaseUtils.getEntireSObject(new Contact(), this.c.id, ',Account.Status__c');
        } catch (Exception e) {
            return;
        }
        
        //Also, if we have a "billing" id on the contact now, we need it on the Subscription as well before we hit save.
        this.sub.Parent_Ind_ID__c = temp.Individual_ID__c;
        
        //Ensure the contact is valid
        try {
            ValidateContactFields.validate(temp);
        } catch (AccountNotActiveException e) {
            getWaitDialog().setHeader('Invalid data...');
            getWaitDialog().setStatus('Account is not active: ');
            getWaitDialog().setAdditionalInfo(e.getMessage());
            getWaitDialog().setButton('Correct Account');
            getWaitDialog().setClickCommand('gotoAccount()');
            getWaitDialog().setShouldRender(true);
            setIsValidContact(false);
            return;
        } catch (Exception e) {
            getWaitDialog().setHeader('Invalid data...');
            getWaitDialog().setStatus('Validation of Contact failed: ');
            getWaitDialog().setAdditionalInfo(e.getMessage());
            getWaitDialog().setButton('Correct Contact');
            getWaitDialog().setClickCommand('gotoEdit()');
            getWaitDialog().setShouldRender(true);
            setIsValidContact(false);
            return;
        }
        
        //The Contact is valid, let's display the correct information for provisioning...
        setIsValidContact(true);
        boolean contactProvisioned = temp.Status__c.equals('Active') ? true : false;
        getWaitDialog().setShouldRender(!contactProvisioned);
        
        if (temp.Status__c.equals('Not Provisioned') || temp.Status__c.equals('Pending')) {
            getWaitDialog().setHeader('Please wait...');
            getWaitDialog().setStatus('Provisioning contact... <img src="/resource/RTResources/images/spinner.gif"/>');
            getWaitDialog().setButton('Continue working (will not cancel provisioning)');
            getWaitDialog().setClickCommand('gotoEdit()');
        } else if (temp.Status__c.contains('Error')) {
            getWaitDialog().setHeader('Error...');
            getWaitDialog().setStatus('Could not provision Contact: ' + temp.Status__c);
            getWaitDialog().setAdditionalInfo('Description: ' + temp.Status_Description__c);
            getWaitDialog().setButton('Go back to Contact');
            getWaitDialog().setClickCommand('gotoEdit()');
            getWaitDialog().setShouldRender(true);
        }
    }
    
    /**
* Get the Account Level Plans (where today is in the plans start/end range) as SelectOption objects
*/
    public List<SelectOption> getAccountLevelPlans() {
        List<SelectOption> options = new List<SelectOption>();
        Plan planRepository = new Plan();
        List<Plan__c> accountPlans = planRepository.getPlansByAccountIdAndBillableTypeWhereAccessCodeInRange(this.c.Account.Id, 'ACCESS_CODE', Date.today());
        
        for (Plan__c plan : accountPlans) {
            if (plan.isDefault__c != null && plan.isDefault__c && options.size() > 0)
                options.add(0, new SelectOption(plan.Id + ':' + plan.Name + ':' + RTUtils.formatDateSafe(plan.endDate__c, null), plan.Name + ': ' + RTUtils.formatDateSafe(plan.startDate__c, 'No start') + ' - ' + RTUtils.formatDateSafe(plan.endDate__c, '∞')));
            else
                options.add(new SelectOption(plan.Id + ':' + plan.Name + ':' + RTUtils.formatDateSafe(plan.endDate__c, null), plan.Name + ': ' + RTUtils.formatDateSafe(plan.startDate__c, 'No start') + ' - ' + RTUtils.formatDateSafe(plan.endDate__c, '∞')));
        }
        
        if (options.size() > 0) {
            SelectOption option = options.get(0);
            if (option.getLabel().indexOf('(100)') != -1) {
                this.sub.Audio_subscription_size__c = '100';
            }
        }
        
        return options;
    }
    
    /**
* Returns a list of Toll Free Numbers
*/
    public List<SelectOption> getPicklistItemsTollFree() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- None --'));
        List <Schema.PicklistEntry> items = Subscription__c.Contact_Toll_Free_Number__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry entry : items) {
            if (entry.isActive())
                options.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }
        
        return options;
    }
    
    /**
* Returns a list of Toll Numbers
*/
    public List<SelectOption> getDependentPicklistItemsToll() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- None --'));
        List <Schema.PicklistEntry> items = Subscription__c.Contact_Toll_Number__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry entry : items) {
            if (entry.isActive())
                options.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }
        
        return options;
    }
    
    /**
* Returns a list of International Kit Numbers
*/
    public List<SelectOption> getDependentPicklistItemsKit() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- None --'));
        List <Schema.PicklistEntry> items = Subscription__c.International_Kit_Number__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry entry : items) {
            if (entry.isActive())
                options.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }
        
        return options;
    }
    
    
    public PageReference save() {
        //Provision this subscription and go back
        SavePoint sp = Database.setSavePoint();
        try {
            RTAccessCodeUtils.saveAndProvisionSubscription(this.sub, this.c, this.a, false);
            
            //Save the Plan Assignment record
            //Name field: (avoid a lookup by adding name to the id field; same with endDate Looks like: id:name:endDate)
            //Validate the planStartDate first
            if (this.planStartDate == null || this.planStartDate == '')
                throw new ValidationException('Plan start date cannot be empty');
            
            //Validate planId
            if (this.planId == null)
                throw new ValidationException('Unable to provision.  An assigned plan is required to provision an Access Code.');
            
            PlanAssignment planAssignmentRepository = new PlanAssignment();
            planAssignmentRepository.savePlanAssignment(this.planId.split(':')[1], this.planId.split(':')[0], 'Subscription__c', this.sub.Id, this.planStartDate, this.planId.split(':')[2]);
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
            Database.rollback(sp);
            return null;
        }
        
        return gotoView(this.sub.id);
    }
    
    public PageReference saveThenNew() {
        save();
        PageReference redir = new PageReference('/apex' + '/AccessCodeDispatcher');
        
        //For some reason, this fails miserably...
        //redir.getParameters().putAll(ApexPages.currentPage().getParameters());
        
        //This fails too...
        /*
for(String k : ApexPages.currentPage().getParameters().keySet()) {
redir.getParameters().put(k, ApexPages.currentPage().getParameters().get(k));
}
*/
        
        //This seems to work fine though...not quite sure why
        redir.getParameters().put('id', ApexPages.currentPage().getParameters().get('id'));
        redir.getParameters().put('retURL', ApexPages.currentPage().getParameters().get('retURL'));
        
        return redir.setRedirect(true);
    }
    
    public PageReference customDelete() {
        try {
            Subscription subscriptionRepository = new Subscription();
            subscriptionRepository.del(this.sub);
        } catch (Exception ex) {
            this.sub.addError('Could not complete deletion:');
            ApexPages.addMessages(ex);
            return null;
        }
        return gotoView(this.sub);
    }
    
    /**
* Remote action to call out to the syncPasscode endpoint
*/
    @RemoteAction
    global static String restore(String subscriptionId) {
        try{
            Subscription__c temp = (Subscription__c) RTDatabaseUtils.getEntireSObject(new Subscription__c(), subscriptionId, ',contact__r.status__c');
            
            if(temp.contact__r.status__c != 'Active')
                throw new ValidationException('Related Contact must be in an Active status before restoring.');
            
            if(temp.status__c != 'RestoreError' && temp.status__c != 'Delete')
                throw new ValidationException('Access Code must be in a Delete satus before restoring.');
            
            if(temp.Date_Deleted__c == null)
                throw new ValidationException('Access Code must have a Date Deleted value set before restoring.');
            
            if(temp.Date_Deleted__c.addDays(30) < DateTime.now())
                throw new ValidationException('Cannot restore Access Codes that were deleted more than 30 days ago.');
            
            temp.status__c = 'Restoring';    
            temp.BBS_L3RAMaster__c = null;
            temp.inactive__c = false;
            temp.Date_Deleted__c = null;
            temp.Inactivated_By__c = null;
            
            update(temp);
        }
        catch (Exception e){
            return e.getMessage();
        }
        return 'success';
    }
    
    @RemoteAction
    global static String getStatusMessage(String subscriptionId) {
        Subscription__c temp = (Subscription__c) (RTDatabaseUtils.getEntireSObject(new Subscription__c(), subscriptionId));
        
        if (temp.Status__c != null) {
            if (temp.Status__c.equals('Active'))
                return 'success';
            else if (temp.Status__c.equals('Restoring'))
                return 'Restoring access code, please wait... <img src="/resource/RTResources/images/spinner.gif"/>';
            else if (temp.Status__c.contains('Error'))
                return 'Could not restore Access Code: ' + temp.Status_Description__c;
        }
        
        return null;
    }
    
    
    public PageReference gotoEdit() {
        Map<String, String> params = new Map<String, String>();
        params.put('cancelURL',  new ApexPages.StandardController(this.c).view().getUrl());
        return gotoEdit(this.c, params);
    }
    
    public PageReference gotoAccount() {
        return gotoView(this.c.Account);
    }
    
    /**
* Method for polling via an actionPoller tag which sets the wait dialog content and returns
*/
    public PageReference pollContactStatus() {
        setWaitDialogContent();
        return null;
    }
    
    /**
* Returns a subscription object
*/
    public Subscription__c getSubscription() {
        return this.sub;
    }
    
    public Id getSubscriptionId() {
        return this.sub.Id;
    }
    
    /**
* Sets the subscription object
*/
    public void setSubscription(Subscription__c sub) {
        this.sub = sub;
    }
    
    public void setIsValidContact(boolean isValidContact) {
        this.isValidContact = isValidContact;
    }
    
    public boolean isValidContact() {
        return this.isValidContact;
    }
    
    /**
* Returns the wait dialog
*/
    public WaitDialog getWaitDialog() {
        return this.dialog;
    }
    
    /**
* Returns the Administrator Information title
*/
    public String getAdministratorInformationTitle() {
        return getIsAdministrator() == true ? 'Administrator Information' : 'For System Administrators Only *** DO NOT ALTER ***';
    }
}