global without sharing class CaseTabViewer {
    public Boolean isConsole {get; set; }
    global CaseTabViewer() {
        
           
    }
    global CaseTabViewer(PGi_ServiceCatalogController controller) {
        
           
    }
    public String ProductSymptoms {get; set; }
    @RemoteAction
    public static PGI_Client__c getClientInfo(String clientName, Id clientId) {
        PGI_Client__c client;
        try {
            if(!String.isBlank(clientId)) {
                client = [SELECT Id, PGI_Company__c, PGI_Company__r.Company_Name__c, PGI_Company__r.Name FROM PGI_Client__c WHERE Id =: clientId]; 
            } else {
                client = [SELECT Id, PGI_Company__c, PGI_Company__r.Company_Name__c, PGI_Company__r.Name FROM PGI_Client__c WHERE Name =: clientName]; 
            }
        } catch (exception e) {
            try {
                client = [SELECT Id, PGI_Company__c, PGI_Company__r.Company_Name__c, PGI_Company__r.Name FROM PGI_Client__c WHERE Name =: clientName]; 
                return client;
            } catch (exception ex) {
                System.debug(ex);
            }
            System.debug(e);
        }
        return client;
    }
    // COD - 1265
    @RemoteAction
    public static PGI_Conference__c getConferenceInfo(String conferenceName, Id conferenceId) {
        //Case cse = (Case)controller.getRecord();
        System.debug(conferenceName);
        PGI_Conference__c conf;
        try{
            if(!String.isBlank(conferenceId)) {
            //Bridge Name, Moderator Passcode, Listen Only Passcode, Participant Passcode pre-polulated prior to saving 
                conf = [SELECT Id, Bridge_Name__c, Moderator_Passcode__c, PGI_Client__r.PGI_Company__r.Name, PGI_Client__r.PGI_Company__c, PGI_Client__r.Name, PGI_Client__c, Listen_Only_Passcode__c, Participant_Passcode__c FROM PGI_Conference__c WHERE Id =: conferenceId];
            } else {
                conf = [SELECT Id, Bridge_Name__c, Moderator_Passcode__c, PGI_Client__r.PGI_Company__r.Name, PGI_Client__r.PGI_Company__c, PGI_Client__r.Name, PGI_Client__c, Listen_Only_Passcode__c, Participant_Passcode__c FROM PGI_Conference__c WHERE Name =: conferenceName];
            }
             
        } catch (exception e) {
            System.debug(e);
        }
        return conf;
    }
    // public String ProductSymptoms {get {
    //     if(ProductSymptoms == null) {
    //        ProductSymptoms = JSON.serialize(new ProductSymptoms());
    //     }
    //     return ProductSymptoms;
    // } set;}
    /* RT-306---------Start--*/
    @RemoteAction
    public static Object fetchProductSymptoms(){
        return new ProductSymptoms();
    }
    /* end-- */
//expose public property, this property will be listing each layout section
    public String aname {get; set; }
    public List<LayoutDescriberHelper.LayoutSection> layoutSections {get; set; }
    public List<LayoutDescriberHelper.AssignmentModel> assignmentSections {get; set; }
    public List<CaseTabViewer__c> ctvList {get{
        System.debug('ctvlst123');
        if(ctvList == null) {
            System.debug('ctvlst1234');
            ctvList = CaseTabViewer__c.getAll().values();
        }
        System.debug('CtvList'+ctvList);
        return ctvList;
    } set;}
    
    private Set<String> ctvRtSet { get{
        if(ctvRtSet == null){
            ctvRtSet = new Set<String>();
            for(CaseTabViewer__c c: ctvList) {
                ctvRtSet.add(c.RecordType__c);
            }
        }
        return ctvRtSet;
    } set;}
    
    private Id rtId {get {
        if(rtId == null) {
            rtId = (Id)controller.getRecord().get('RecordTypeId');
        }
        System.debug('rtId>>>>>'+rtId);
        return rtId;
    } set;}
    
    public Boolean quickCaseEnabled { get {
        if(caseTabSettings != null) {
            return caseTabSettings.Enable_Quick_Case__c;
        }
        return false;
    } set; }

    public Boolean caseCommentEnabled { get {
        if(caseTabSettings != null) {
            return caseTabSettings.Show_New_Comment__c;
        }
        return false;
    } set; } 

   @TestVisible private String rtName { get{
        if(rtName == null) {
            if(rtId != null) {
                rtName = [SELECT Id, Name FROM RecordType WHERE Id =: rtId AND sObjectType = 'Case'].Name;
                
            }
        }
        return rtName;
    } set;}
    public String caseCommentBody {get; set;} 
    public CaseTabViewer__c caseTabSettings {get {
        System.debug('ctv123'+caseTabSettings);
        if(caseTabSettings == null) {
            System.debug('ctv456');
            for(CaseTabViewer__c ctv: ctvList) {
                System.debug('ctv789');
                if(ctv.RecordType__c == rtName) {
                    caseTabSettings = ctv;
                    System.debug('ctv'+caseTabSettings);
                }
            }
        }
        System.debug('the Value is'+caseTabSettings);
        return caseTabSettings;
    }set;}

    public Decimal topCount {get {
        topCount = caseTabSettings != null && caseTabSettings.Top_Count__c != null ? caseTabSettings.Top_Count__c : 0;
        return topCount;
    } set;}
    
    public Decimal tabCount {get {
        tabCount = caseTabSettings != null && caseTabSettings.Tab_Count__c != null ? caseTabSettings.Tab_Count__c : 0;
        return tabCount;
    } set;}
    
    public PageReference init() {
        System.debug('>>>>>>>2');
        PageReference pr;
         String recIdInit = (String)controller.getRecord().get('Id');
        
        Id recordTyId = ApexPages.currentPage().getParameters().get('RecordType');
        String rtName ='';
        if(recordTyId != Null){
            rtName =  Schema.SObjectType.Case.getRecordTypeInfosById().get(recordTyId).getName();
            rtId = recordTyId;
        }
        if(rtName == '' && rtId != null){
            rtName =  Schema.SObjectType.Case.getRecordTypeInfosById().get(rtId).getName();
        }
        
        system.debug(rtId+' @@ '+rtName);
        
        if(rtId != null){
            if(ctvRtSet.contains(rtName)) {
                return pr;
            }
        }
        
        if( recIdInit == null) {
            pr = new PageReference('/500/e?retURL=%2F500%2Fo');
        } else {
            pr = new PageReference('/'+ recIdInit+'/e?retURL=%2F'+recIdInit);
        }
        if(recordTyId == Null ){
            pr.getParameters().put('RecordTypeId',rtId);
        }else{
            pr.getParameters().put('RecordType',recordTyId);
        }
        if(recordTyId == null && rtId == null && recIdInit == null){
             success = false;
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please navigate through record type or quick case selection'));
            return null;
        }
        system.debug(isClassic());
        system.debug(recIdInit);
        if(recIdInit != null || isClassic()) {
            success = true;
        }
        CreateCase cc = new CreateCase();
        cc.passForwardParams(pr);
        pr.getParameters().put('nooverride','1');
        return pr;
    }
    
    public Boolean isFireAssRule{get; set;}
    public Boolean isSendNotification{get;set;}
    
    private ApexPages.StandardController controller {get; set;}
    public static String getLabelString(String labelName ){
        Component.Apex.OutputText output = new Component.Apex.OutputText();
        output.expressions.value = '{!$Label.' + labelName + '}';
        System.debug('Value>>>>>>'+String.valueOf(output.value));
        return String.valueOf(output.value);
    }
    public CaseTabViewer(ApexPages.StandardController controller) {
        isConsole = false;
         String headerdata= ApexPages.currentPage().getHeaders().get('Host');
         System.debug('url'+headerdata);
        this.controller = controller;
        List<String> fieldList = new List<String>(Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap().keyset());       
        if(!Test.isRunningTest()){ 
            // Add fields to controller. This is to avoid the SOQL error in visualforce page
            controller.addFields(fieldList);
        }
        Case cse = (Case)controller.getRecord();
        PageReference cp = ApexPages.currentPage();
        for(String s: cp.getParameters().keySet()){
            if(s == 'CF00N1B00000AxSsh_lkid') {
                cse.X3rd_Party_Vendor__c = cp.getParameters().get(s);
            }
            if(s == 'CF00N1B00000AxSsf_lkid') {
                cse.X3rd_Party_Vendor_2__c = cp.getParameters().get(s);
            }
            if(s == 'CF00N1B00000AxSsg_lkid') {
                cse.X3rd_Party_Vendor_3__c = cp.getParameters().get(s);
            }
            if(s == 'CF00N1B00000AxTvd_lkid') {
                cse.Bill_To_Client__c = cp.getParameters().get(s);
            }
            if(s == 'CF00N1B00000AxRSs_lkid') {
                cse.Contract__c = cp.getParameters().get(s);
            }
            if(s == 'CF00N1B00000AxV71_lkid') {
                cse.External_Support_Case_Number__c = cp.getParameters().get(s);
            }
            if(s == 'CF00N1B00000AxSOn_lkid') {
                cse.HR_Request_Form__c = cp.getParameters().get(s);
            }
            if(s == 'CF00N1300000ArPOW_lkid') {
                cse.Opportunity_Name__c = cp.getParameters().get(s);
            }
            if(s == 'CF00N1B00000BUvEm_lkid') {
                cse.PGi_Client__c = cp.getParameters().get(s);
            }
            if(s == 'CF00N1B00000BUvEn_lkid') {
                cse.PGi_Company__c = cp.getParameters().get(s);
            }
            if(s == 'CF00N1B00000BUvEo_lkid') {
                cse.PGi_Conference__c = cp.getParameters().get(s);
            }
            // if(s == 'CF00N5B000001A9yw_lkid') {
            //     cse.PGi_Video_Conference__c = cp.getParameters().get(s);
            // }
            if(s == 'CF00N1300000BGwXd_lkid') {
                cse.RelatedContractRequest__c = cp.getParameters().get(s);
            }
            // if(s == 'CF00N1300000BD51U_lkid') {
            //     cse.Related_Video_Site_ID__c = cp.getParameters().get(s);
            // }
        }
        
        if(cse.Id == null && !isClassic()) {
            return;
        }
        system.debug('new_--->'+isNew);
        if(isNew) {
            isFireAssRule = true;
            if(ApexPages.currentPage().getParameters().get('QuickCase') != null) {
                quickCase = ApexPages.currentPage().getParameters().get('QuickCase');
                quickCasePopulation();
            }
        } else {
            isFireAssRule = false;
        }
        Id recordTyId = ApexPages.currentPage().getParameters().get('RecordTypeId'); //sometimes RT is populated and other times it is RTId
        Id recordTy = ApexPages.currentPage().getParameters().get('RecordType'); //sometimes RT is populated and other times it is RTId
        System.debug('recordTy>>'+recordTy);
        if(!String.isBlank(recordTy)) {
            System.debug('setting rt');
            recordTyId = recordTy;
        } else if (!String.isBlank(recordTyId)) {
            System.debug('setting rt');
            recordTy = recordTyId;
        }
        if(!String.isBlank(recordTyId)){
            System.debug('setting rt');
            rtId = recordTyId;
            cse.RecordTypeId = recordTyId;
        } else if (cse.RecordTypeId != null) {
            System.debug('setting rt');
            rtId = cse.RecordTypeId;
            ApexPages.currentPage().getParameters().put('RecordType', cse.RecordTypeId);
            ApexPages.currentPage().getParameters().put('RecordTypeId', cse.RecordTypeId);
        } else if (cse.Id == null && !isClassic()) {
            System.debug('setting rt');
            success = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please navigate through record type or quick case selection'));
            return;
        
        }
        success = true;
        system.debug('success');
        //if(cse.RecordTypeId == null) {    
        //    cse.RecordTypeId = rtId;
        //}

        /* dynamically get all fields for the Account object and add them to the controller */
        
        /************************************************************************/
         //getting the default record type
        //if we want an specific layout we must provide the appropriate record type id

        id theRecordTypeIdToDescribe = LayoutDescriberHelper.getDefaultRecordType(cse);
        //get the layout section items
        layoutSections = LayoutDescriberHelper.describeSectionWithFields(rtId, 'Case');
        
        //get the assignment section for displaying 
        assignmentSections = LayoutDescriberHelper.describeAssignment(rtId, 'Case');
        
    }    

 
    public Boolean success {get; set;}
    public String errorMessage {get; set;}
    public PageReference addError() {
        errorMessage = ApexPages.currentPage().getParameters().get('errorMessage');
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please fill out required fields: ' + errorMessage));
        return null;
    }
    public PageReference isInConsole() {
        return null;
    }
    public String quickCase {get; set;}
    public String oldQuickCase {get; set; }

    public void quickCasePopulation() {

        Case cse = (Case)controller.getRecord();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap();
        List<Case_Template__c> caseTemplates = Database.query('SELECT Name, Name__c, (SELECT Field_API_Name__c, Value__c FROM Default_Values__r) FROM Case_Template__c WHERE (Name =: quickCase OR Name =: oldQuickCase)');
        Set<String> ignoreFields = new Set<String>();
        //if there was a previous quickcase value - purge anything that has not been set already
        //have to have old quick case loop through first and reset any values already set


            for(Case_Template__c ct: caseTemplates) { 
                System.debug(ct.Name__c);
                //find the old values
                if(ct.Name != oldQuickCase) {
                    continue;
                }
                System.debug('NOT SUPPOSED TO BE HERE');
                //clear the old values
                for(Default_Value__c dv: ct.Default_Values__r) {
                    String fieldName = dv.Field_API_Name__c;
                    String inputValue = (String)dv.get('Value__c');
                    try {
                        System.debug('fieldName>>>>>>>>>>>>>> '+fieldName);
                        String fieldType = String.ValueOf(fieldMap.get(fieldName).getDescribe().getType());
                        System.debug('fieldType>>>>>>>>>>>>>> '+fieldType);
                        if(fieldType.toUpperCase() == 'REFERENCE' ||  fieldType.toUpperCase() == 'PICKLIST' ||
                           fieldType.toUpperCase() == 'STRING' || fieldType.toUpperCase() == 'TEXTAREA' || fieldType.toUpperCase() == 'MULTIPICKLIST' ||
                           fieldType.toUpperCase() == 'ID' || fieldType.toUpperCase() == 'PHONE' || fieldType.toUpperCase() == 'EMAIL' ||
                           fieldType.toUpperCase() == 'URL' || fieldType.toUpperCase() == 'ADDRESS' || fieldType.toUpperCase() == 'ENCRYPTEDSTRING'){
                                System.debug(cse.get(fieldName) == inputValue);
                                System.debug(cse.get(fieldName));
                                System.debug(inputValue);
                                if(cse.get(fieldName) == inputValue) {
                                    cse.put(fieldName, null);
                                }  else {
                                    ignoreFields.add(fieldName);
                                }
                        } else if(fieldType.toUpperCase() == 'BOOLEAN'){
                            if(cse.get(fieldName) == Boolean.valueOf(inputValue)) {
                                cse.put(fieldName, null);
                            } else {
                                ignoreFields.add(fieldName);
                            }
                        } else if(fieldType.toUpperCase() == 'DOUBLE' || fieldType.toUpperCase() == 'CURRENCY' || fieldType.toUpperCase() == 'PERCENT'){
                            if(cse.get(fieldName) == Decimal.valueOf(inputValue)) {
                                cse.put(fieldName, null);
                            } else {
                                ignoreFields.add(fieldName);
                            }
                        } else if(fieldType.toUpperCase() == 'INTEGER'){
                            if(cse.get(fieldName) == Integer.valueOf(inputValue)) {
                                cse.put(fieldName, null);
                            } else {
                                ignoreFields.add(fieldName);
                            }
                        } else if(fieldType.toUpperCase() == 'DATE'){
                            Datetime Currenttime = Datetime.valueOf(inputValue);
                            String convertedtimeStr = Currenttime.format('MM/dd/yyyy');
                            inputValue = convertedtimeStr;
                            if(cse.get(fieldName) == Date.valueOf(inputValue)) {
                                cse.put(fieldName, null);
                            } else {
                                ignoreFields.add(fieldName);
                            }
                        } else if(fieldType.toUpperCase() == 'DATETIME'){
                            Datetime Currenttime;
                            try {
                                Currenttime = Datetime.valueOfGMT(inputValue);
                            } catch (exception e) {
                                Currenttime = (DateTime)Date.parse(inputValue);
                            }
                            if(cse.get(fieldName) == Currenttime) {
                                cse.put(fieldName, null);
                            } else {
                                ignoreFields.add(fieldName);
                            }
                       }
                    } catch (exception e) {
                        system.debug(e);
                    }
                }
            } 

        for(Case_Template__c ct: caseTemplates) {
            if(ct.Name != quickCase) {
                continue;
            } 
            for(Default_Value__c dv: ct.Default_Values__r) {
                String fieldName = dv.Field_API_Name__c.trim();
                if(ignoreFields.contains(fieldName)) { continue; }
                String inputValue = (String)dv.get('Value__c');
                try {
                    String fieldType = String.ValueOf(fieldMap.get(fieldName).getDescribe().getType());
                    system.debug(fieldType);
                    if(fieldType.toUpperCase() == 'REFERENCE' ||  fieldType.toUpperCase() == 'PICKLIST' ||
                       fieldType.toUpperCase() == 'STRING' || fieldType.toUpperCase() == 'TEXTAREA' || fieldType.toUpperCase() == 'MULTIPICKLIST' ||
                       fieldType.toUpperCase() == 'ID' || fieldType.toUpperCase() == 'PHONE' || fieldType.toUpperCase() == 'EMAIL' ||
                       fieldType.toUpperCase() == 'URL' || fieldType.toUpperCase() == 'ADDRESS' || fieldType.toUpperCase() == 'ENCRYPTEDSTRING'){
                            system.debug(fieldName + inputValue);
                            cse.put(fieldName, inputValue);
                                
                    } else if(fieldType.toUpperCase() == 'BOOLEAN'){
                        cse.put(fieldName, Boolean.valueOf(inputValue));
                    } else if(fieldType.toUpperCase() == 'DOUBLE' || fieldType.toUpperCase() == 'CURRENCY' || fieldType.toUpperCase() == 'PERCENT'){
                        cse.put(fieldName, Decimal.valueOf(inputValue));

                    } else if(fieldType.toUpperCase() == 'INTEGER'){
                       
                        cse.put(fieldName, Integer.valueOf(inputValue));
                    } else if(fieldType.toUpperCase() == 'DATE'){
                        Datetime Currenttime = Datetime.valueOf(inputValue);
                        String convertedtimeStr = Currenttime.format('MM/dd/yyyy');
                        inputValue = convertedtimeStr;

                        cse.put(fieldName, Date.valueOf(inputValue));

                    } else if(fieldType.toUpperCase() == 'DATETIME'){
                        Datetime Currenttime;
                        try {
                            Currenttime = Datetime.valueOfGMT(inputValue);
                        } catch (exception e) {
                            Currenttime = (DateTime)Date.parse(inputValue);
                        }
                        cse.put(fieldName, Currenttime);
                   }

                } catch (exception e) {
                    system.debug(e);
                }
            }
        }
        oldQuickCase = quickCase;
        //return null;
    }
    public PageReference doNothing(){ 
        return null;
    }
    public PageReference save() {
        Case cse = (Case)controller.getRecord();
        Id recordId = controller.getId();
        List<Case> originalValues = [SELECT Id, Description, Resolution_Comments__c FROM Case WHERE Id =: recordId];
        Case originalCase = new Case();
        if(originalValues.size() > 0) {
            originalCase = originalValues[0];
        }

        Boolean newCase = false;
        if(cse.Id == null || cse.Auto_Generated_For_Case__c == true || ApexPages.currentPage().getParameters().get('isNew') == 'true') {
            newCase = true;
        }
        try {
            if(ApexPages.currentPage().getParameters().get('isNew') == 'true') {
                String cseId = ApexPages.currentPage().getParameters().get('Id');
                undelete new Case(Id = cseId);    
            }
        } catch (exception e) {

        }
        
        cse.Auto_Generated_For_Case__c = false;
        //cse.put('auto_generated_for_case__c', false);
        system.debug('@##--> '+cse.recordTypeId);
         if(isFireAssRule) {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            cse.setOptions(dmo);
        }
        try {
            //PageReference pr = database.sz;
            upsert cse;
            // 1517 & 1518
            // TODO: need to query case? check for insert vs. update?
            if(String.isNotBlank(caseCommentBody)) {
                if(String.IsNotBlank(cse.Description) && String.IsNotBlank(cse.Resolution_Comments__c) && (originalCase.Description != cse.Description || originalCase.Resolution_Comments__c != cse.Resolution_Comments__c)) {
                    caseCommentBody += '\n';
                    caseCommentBody += '' + cse.Description + '\n';
                    caseCommentBody += '' + cse.Resolution_Comments__c + '\n';
                }
                if(caseCommentBody != null && String.isNotBlank(caseCommentBody)) {
                    CaseComment caseComment = new CaseComment(CommentBody = caseCommentBody, ParentId = cse.Id);
                    //caseComment.ParentId = cse.Id;                
                    caseComment.CommentBody = caseCommentBody;
                    insert caseComment;
                }
            }
            PageReference pr = new ApexPages.StandardController(cse).view();
            pr.getParameters().put('isNew', 'false');
            pr.setRedirect(true);   
            return pr;
        } catch (DmlException e) {
            if(e.getDmlMessage(0) != null){
                if(e.getMessage().contains('entity is deleted')) {
                    try {
                        undelete new Case(Id = cse.Id);
                        cse.Auto_Generated_For_Case__c = false;
                        update cse;
                    } catch (Exception ex) {
                        cse.addError(ex.getMessage());
                        return null;
                    }    
                } else {
                    cse.addError(e.getDmlMessage(0));
                    return null;
                }
            } 
        } catch (Exception e) {
            System.assert(false, e.getMessage());
            if(e.getMessage() != null){
                cse.addError(e.getMessage());
            } 
            return null;
        }
        
       
        return new PageReference('/'+ cse.Id); 
    }
   
   public Boolean isNew {get{
        if(ApexPages.currentPage().getParameters().get('isNew') != null) {
            return Boolean.valueOf(ApexPages.currentPage().getParameters().get('isNew'));
        } else {
            return false;

        }
    } set;}
    public PageReference inConsole() {
        return populateCaseNumber();
    }
    public PageReference notInConsole() {
        Set<String> passForwardParams = new Set<String>{'retURL', 'isClassic', 'isNew', 'saveUrl', 'Id', 'RecordType', 'RecordTypeId', 'QuickCase', 'save_new'};
        PageReference cp = ApexPages.currentPage();
        PageReference pr = Page.CaseTabViewer;
        pr.getParameters().put('isClassic', 'true');
        for(String s: cp.getParameters().keySet()){
            system.debug(s);
            if(passForwardParams.contains(s)){
                pr.getParameters().put(s, cp.getParameters().get(s));
            }
        }
        return pr;
    }
    public Boolean isClassic() {
        if(ApexPages.currentPage().getParameters().get('isClassic') != null) {
            return Boolean.valueOf(ApexPages.currentPage().getParameters().get('isClassic'));
        }
        return false;
    }
    public PageReference cancel() {
        system.debug('cancel');
        system.debug('cancel--->'+isConsole);
        PageReference pr;
        if(ApexPages.currentPage().getParameters().get('retURL') != null) {
            pr = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
            pr.setRedirect(true);
        } else {
            pr = null;
        }
        if(isNew) {
            try {
                Case c = [SELECT Id, Auto_Generated_For_Case__c FROM Case WHERE Id =: controller.getRecord().Id];
                if(c.Auto_Generated_For_Case__c) {
                    delete controller.getRecord();
                }
            } catch (exception e) {
                system.debug(e);
            } 
        }
        if(isConsole){
            pr = null;
        }
        return pr;
    }
    
    public PageReference populateCaseNumber() {
        Case cse = (Case)controller.getRecord();
        try {
            //PageReference pr = database.sz;
            upsert cse;
            PageReference pr = Page.CaseTabViewer;
            pr.getParameters().put('isNew', 'true');
            pr.setRedirect(true);   
            return pr;
        } catch (DmlException e) {
            if(e.getDmlMessage(0) != null){
                cse.addError(e.getDmlMessage(0));
            } 
            return null;
        } catch (Exception e) {
            if(e.getMessage() != null){
                cse.addError(e.getMessage());
            } 
            return null;
        }
    }
}