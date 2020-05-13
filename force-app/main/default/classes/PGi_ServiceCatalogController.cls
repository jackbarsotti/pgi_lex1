global without sharing class PGi_ServiceCatalogController {
  public Boolean internalUser {get {
      return (UserInfo.getUserType() == 'Standard');
    }
  }
  public List<PGi_ServiceCatalog_Category__c> categoryList {get {
    if(categoryList.size() == 0) {
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Oops. Nothing to find here.');
          ApexPages.addMessage(myMsg);
    } else {
      ApexPages.getMessages().clear();
    }
    return categoryList;
  } set;}
  private Map<Id, PGi_ServiceCatalog_Category__c> categoryMap {
    get {
      return new Map<Id, PGi_ServiceCatalog_Category__c>(categoryList);
    }
  }

  public Attachment attach {get; set;}

  public String baseUrl {get {
    String urlString = URL.getCurrentRequestUrl().toExternalForm();
    system.debug(urlString);
    if(urlString.contains('/apex') && !internalUser) {
      String[] urlList = urlString.split('/apex');
      urlString = urlList[0];
    }
    //system.debug(URL.getCurrentRequestUrl();
    return urlString;
  }}
  public PGi_ServiceCatalog_Category__c selectedCategory {get; set;}
  public Id selectedCategoryId {get; set {
    selectedCategoryOptionId = null;
    selectedCategory = categoryMap.get(value);
    selectedCategoryId = value;
  }}

  public List<PGi_ServiceCatalog_Category_Option__c> displayCategoryOptionList {get {
    displayCategoryOptionList = new List<PGi_ServiceCatalog_Category_Option__c>();
    if(selectedCategoryId != null) {
      for(PGi_ServiceCatalog_Category_Option__c catOpt: categoryOptionList) {
        if(catOpt.Category__c == selectedCategoryId) {
          displayCategoryOptionList.add(catOpt);
        }
      }
    }
    if(displayCategoryOptionList.isEmpty()){
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Oops. Nothing to find here.');
          ApexPages.addMessage(myMsg);
    } else {
      ApexPages.getMessages().clear();
    }
    return displayCategoryOptionList;
  } set;}
  private List<PGi_ServiceCatalog_Hidden_Input_Value__c> hiddenValueList {get; set;}
  private List<PGi_ServiceCatalog_Category_Option__c> categoryOptionList {get; set;}
  private Map<Id, PGi_ServiceCatalog_Category_Option__c> categoryOptionMap {
    get {
      return new Map<Id, PGi_ServiceCatalog_Category_Option__c>(categoryOptionList);
    }
  }
  public PGi_ServiceCatalog_Category_Option__c selectedCategoryOption {get; set;}
  public Id selectedCategoryOptionId {get; set {
    selectedCategoryOption = categoryOptionMap.get(value);
    selectedCategoryOptionId = value;
  }}

  
  private List<PGi_ServiceCatalog_Section__c> sectionList {get; set;}
  
  public List<PGi_ServiceCatalog_Section__c> displaySectionList {get {
    List<PGi_ServiceCatalog_Section__c> returnList = new List<PGi_ServiceCatalog_Section__c>();
    if(selectedCategoryOptionId != null) {
      for(PGi_ServiceCatalog_Section__c s: sectionList) {
        if(s.Category_Option__c == selectedCategoryOptionId) {
          returnList.add(s);
        }
      }
    }
    if(returnList.size() == 0) {
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Oops. Nothing to find here.');
          ApexPages.addMessage(myMsg);
    } else {
      ApexPages.getMessages().clear();
    }
    return returnList;
  }}

  global PGi_ServiceCatalogController() {
    attach = new attachment();
    //initialize soql queries
    String categorySoql   = 'SELECT Id, Static_Resource_Image__c, Navigate_to__c, Title__c FROM PGi_ServiceCatalog_Category__c ';
    String categoryOptionSoql = 'SELECT Id, Category__c, Title__c, Allow_Attachments__c, Description__c, Internal_User_Instructions__c, External_User_Instructions__c, Navigate_to__c, Object_Api_Name__c FROM PGi_ServiceCatalog_Category_Option__c ';
    String sectionSoql     = 'SELECT Id, Field_Set_API_Name__c, Title__c, Category_Option__c, Category_Option__r.Object_Api_Name__c FROM PGi_ServiceCatalog_Section__c ';
    String hiddenSoql    = 'SELECT Id, Category_Option__c, Field_API_Name__c, Set_Value__c FROM PGi_ServiceCatalog_Hidden_Input_Value__c ';
    //filter based upon active
    if(ApexPages.currentPage().getParameters().get('devPreview') == null || ApexPages.currentPage().getParameters().get('devPreview').toUpperCase() != 'TRUE') {
      categorySoql     += ' WHERE Active__c = TRUE ';
      categoryOptionSoql   += ' WHERE Active__c = TRUE ';
    }
    categorySoql       += ' ORDER BY Sort_Order__c ASC NULLS LAST';
    categoryOptionSoql     += ' ORDER BY Sort_Order__c ASC NULLS LAST';
    sectionSoql       += ' ORDER BY Sort_Order__c ASC NULLS LAST';
    categoryList     = database.query(categorySoql);
    categoryOptionList   = database.query(categoryOptionSoql);
    sectionList     = database.query(sectionSoql);
    hiddenValueList    = database.query(hiddenSoql);

    if(ApexPages.currentPage().getParameters().get('category') != null) {
      try {
        selectedCategoryId = ApexPages.currentPage().getParameters().get('category');
      } catch (exception e) {
        system.debug(e);
      }
    }
    if(ApexPages.currentPage().getParameters().get('categoryOption') != null) {
      try {
        selectedCategoryOptionId = ApexPages.currentPage().getParameters().get('categoryOption');
      } catch (exception e) {
        system.debug(e);
      }
    }
  }
  public PageReference rerender() {
    PageReference pr;
    if(selectedCategory != null && selectedCategory.Navigate_to__c != null) {
      if(selectedCategory.Navigate_to__c.contains('http://') || selectedCategory.Navigate_to__c.contains('https://')) {
        pr = new PageReference(selectedCategory.Navigate_to__c);
      } else {
        pr = new PageReference('https://' + selectedCategory.Navigate_to__c);
      }
      pr.setRedirect(true);
      return pr;
    } else if (selectedCategoryOption != null && selectedCategoryOption.Navigate_to__c != null) {
      if(selectedCategoryOption.Navigate_to__c.contains('http://') || selectedCategoryOption.Navigate_to__c.contains('https://')) {
        pr = new PageReference(selectedCategoryOption.Navigate_to__c);
      } else {
        pr = new PageReference('https://' + selectedCategoryOption.Navigate_to__c);
      }
      pr.setRedirect(true);
      return pr;
    } else {
      pr = new PageReference(baseUrl);
    }
    system.debug(pr);
    //return ApexPages.currentPage();
    return setPageParams(pr);
  }
  public String rerender {get {
    return rerender().getUrl();
  } set;}
  public String sObjectType {get{
    if(selectedCategoryOption == null){
      return null;
    }
    return selectedCategoryOption.Object_Api_Name__c;
  }}
  private PageReference setPageParams(PageReference pr) {
    String devPreview = ApexPages.currentPage().getParameters().get('devPreview');
    pr.getParameters().clear();
    if(devPreview != null) {
      pr.getParameters().put('devPreview', devPreview);
    }
    if(selectedCategoryId == null) {

    } else if(selectedCategoryOptionId != null) {
      pr.getParameters().put('categoryOption', selectedCategoryOptionId);
      pr.getParameters().put('category', selectedCategoryId);
    } else {
      pr.getParameters().put('category', selectedCategoryId);
    }
    pr.setRedirect(true);
    system.debug(pr);
    return pr;
  }
  public PageReference cancel() {
    ApexPages.getMessages().clear();
    
    if(theRecord != null && theRecord.get('Id') != null) {
      theRecord = null;
      selectedCategoryOptionId = null;
      selectedCategoryId = null;
    }

    if(selectedCategoryOptionId == null) {
      if(selectedCategoryId != null) {
        selectedCategoryId = null;
      }
    } else {
      selectedCategoryOptionId = null;
    }
    PageReference pr = new PageReference(baseUrl);
    system.debug(pr);
    return setPageParams(pr);
  }
  public String nullValue {get {
    return null;
  }}
  public PageReference home() {
    String devPreview = ApexPages.currentPage().getParameters().get('devPreview');
    String urlString = baseUrl;
    PageReference pr = new PageReference(urlString);
    if(devPreview != null) {
      pr.getParameters().put('devPreview', devPreview);
    }
    pr.setRedirect(true);
    system.debug(pr);
    return pr;
  }
  public PageReference navigateToRecord() {
    if(theRecord != null && theRecord.Id != null) {
      return new PageReference('/'+theRecord.Id);
    }
    return null;
  }
  /* hack to fix known issue found here: https://success.salesforce.com/issues_view?id=a1p30000000Sz5RAAS */
  private sObject cloneObject(sObject originalSObj) {
	Map<String, Object> fieldsToValue = originalSObj.getPopulatedFieldsAsMap();
	sObject newSObject = gd.get(sObjectType).newSObject();
	Map<String, Schema.SobjectField> fieldMap = gd.get(sObjectType).getDescribe().fields.getMap();
	for (String fieldName : fieldsToValue.keySet()) {
		if(fieldMap.get(fieldName).getDescribe().isCreateable()){
        	newSObject.put(fieldName, fieldsToValue.get(fieldName));
		}
	}
	return newSObject;
  }
    public sObject theRecord {get {
      system.debug(theRecord);
      if(!String.isBlank(sObjectType) && theRecord == null) {
        if(gd.get(sObjectType) == null) {
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Unsupported object ' + sObjectType);
            ApexPages.addMessage(myMsg);
      } else {
        theRecord = gd.get(sObjectType).newSObject();
                populateHiddenValues();

            	if(gd.get(sObjectType).getDescribe().fields.getMap().keySet().contains('recordtype') || gd.get(sObjectType).getDescribe().fields.getMap().keySet().contains('recordtypeid')) {
                  String recordTypeId = (String)theRecord.get('RecordTypeId');
                  sObject theRecordTemp = gd.get(sObjectType).newSObject(recordTypeId, true);
                  theRecord = cloneObject(theRecordTemp);
              } else {
              sObject theRecordTemp = gd.get(sObjectType).newSObject(null, true);
              	theRecord = cloneObject(theRecordTemp);
              }
              if(gd.get(sObjectType).getDescribe().fields.getMap().keySet().contains('requested_for__c')){
                  //populate the requested for value
                  if(internalUser) {
                    theRecord.put('Requested_For__c', (String)UserInfo.getUserEmail());
                } else {
                  theRecord.put('Requested_For__c', ADUser);
                }
              }

      }
        
      } else if (String.isBlank(sObjectType)) {
        theRecord = null;
      }
      return theRecord;
  } set;}

  public Map<String, Schema.SObjectType> gd { 
    get {
      if (gd == null) {
        gd = Schema.getGlobalDescribe();
      } 
      return gd;
    } set;
  }

    public List<Schema.FieldSet> fieldSetList(String sObjectName) {
      if(String.isBlank(sObjectName) || gd.get(sObjectName) == null) {
        return new List<Schema.FieldSet>();
      }
      return gd.get(sObjectName).getDescribe().fieldsets.getMap().values();
  }

  public Map<Id, List<Schema.FieldSetMember>> sectionIdToFields {get {
    if(sectionIdToFields == null) {
      Map<String, Schema.SObjectField> fieldmap = gd.get(sObjectType).getDescribe().fields.getMap();
      sectionIdToFields = new Map<Id, List<Schema.FieldSetMember>>();
      for(PGi_ServiceCatalog_Section__c s: sectionList) {
        List<Schema.FieldSetMember> fieldList = new List<Schema.FieldSetMember>();
        if(s != null && s.Category_Option__r != null && s.Category_Option__r.Object_Api_Name__c != null ) {
          for(Schema.FieldSet fs: fieldSetList(s.Category_Option__r.Object_Api_Name__c)) {
            if(fs.getName() == s.Field_Set_API_Name__c) {
                  for(Schema.FieldSetMember fsm: fs.getFields()) {
                    //only add editable fields to the list
                    if(fieldmap.get(fsm.getFieldPath()) != null && fieldmap.get(fsm.getFieldPath()).getDescribe().isCreateable()){
                      //filter lookups
                      //if(fieldmap.get(fsm.getFieldPath()).getDescribe().getRelationshipName() == null || fieldmap.get(fsm.getFieldPath()).getDescribe().getRelationshipName().contains('__r')) {
                        fieldList.add(fsm);
                      //}
                    }
                  }
                }
              }
            }
            sectionIdToFields.put(s.Id, fieldList);
      }
    }
    return sectionIdToFields;
  } set;}
  public Boolean allowSave { 
    get {
      system.debug(theRecord);
      if(theRecord == null || theRecord != null && theRecord.get('Id') != null) {
        return false;
      }
      return true;
    }
  }
  private void populateHiddenValues() {
    if(selectedCategoryOptionId != null) {
      for(PGi_ServiceCatalog_Hidden_Input_Value__c h: hiddenValueList) {
        try {
          if(h.Category_Option__c == selectedCategoryOptionId) {
            theRecord.put(h.Field_API_Name__c, h.Set_Value__c);
          }
        } catch (exception e) {
          system.debug(e.getMessage());
        }
      }
      
      
    }
  }
  public String ADUser {get; set;}
  public PageReference saveServiceCatalog() {
    PGi_ServiceCatalogValidatorUtility validator = new PGi_ServiceCatalogValidatorUtility();
    try {
      populateHiddenValues();
      ApexPages.getMessages().clear();
      if(sObjectType == 'Case' || sObjectType == 'Lead') {
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = TRUE;
        if(sObjectType == 'Case') {
        	dmo.EmailHeader.triggerAutoResponseEmail = TRUE;
        	dmo.EmailHeader.triggerUserEmail = TRUE;
        }
        theRecord.setOptions(dmo);
      }
      if(!String.isBlank(ADUser)) {
        if(validator.validField(sObjectType, 'AD_User__c')) {
          theRecord.put('AD_User__c', ADUser);
        }
      }
      insert theRecord;
      if(attach != null){
          try{
              attach.parentId = (Id)theRecord.get('Id');
              insert attach;
          }
          catch(Exception e){ 
          }
          finally{
              attach.body = null;
              attach = new Attachment();
          }
      }
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Your ticket was successfully submitted.');
          ApexPages.addMessage(myMsg);
    } catch (exception e) {
      ApexPages.Message myMsg;
      if(e.getTypeName() == 'System.DmlException') {
        myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Unable to save record: ' + e.getDmlMessage(0));
      } else {
        myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Unable to save record:' + e.getMessage());
      }
          ApexPages.addMessage(myMsg);
    }
    return null;
  }
}