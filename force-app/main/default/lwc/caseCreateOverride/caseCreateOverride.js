import { LightningElement, api, wire, track } from 'lwc';
import CASE_OBJECT from '@salesforce/schema/Case';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getRecordUi, deleteRecord } from 'lightning/uiRecordApi';
import getAllDependentValues from '@salesforce/apex/ProductSymptomsLex.getAllDependentValues';
import getCaseFieldValues from '@salesforce/apex/CaseCreateOverrideController.getCaseFieldValues';
import createCase from '@salesforce/apex/CaseCreateOverrideController.createCase';
import updateCase from '@salesforce/apex/CaseCreateOverrideController.updateCase';
import getQuickCase from '@salesforce/apex/CaseCreateOverrideController.getQuickCase';
import insertCaseComment from '@salesforce/apex/CaseCreateOverrideController.insertCaseComment';
import { NavigationMixin } from 'lightning/navigation';
import getRecordType from '@salesforce/apex/CaseRTSelection.getRecordType';
import getCaseTabViewRecords from '@salesforce/apex/CaseTabViewerController.getCaseTabViewRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CaseCreateOverride extends NavigationMixin(LightningElement) {
  //Product Related Dependent Picklist
  productrelatedmapData;
  @track productValues = [];
  @track dependentAOFValues = [];
  @track dependentSymptomValues = [];
  @track dependentSubSymptomValues = [];
  @track selectedProduct;
  @track selectedAreaOfFocus;
  @track selectedSymptom;
  @track selectedSubSymptom;
  @track valueforSelectingSymptom;
  @track valueforSelectingSubSymptom;
  @track isAOF = true;
  @track isSymptom = true;
  @track isSubSymptom = true;
  @track error;
  @track ifFirstTime = true;
  //
  @api recordId;
  @api recordTypeId;
  @api recordTypeName;
  @api tabRecordType;
  @api topLayoutSections = [];
  @api tabLayoutSections = [];
  @api bottomLayoutSections = [];
  @api buttonSections = [];
  @api reqTabSections = [];
  @api requiredCaseComment;
  @api caseCommentValue;
  //caseTemplate Selecction List
  @track quickCaseListOption = [];
  //All case Templete Records
  caseTemplateRecord;
  //Selected Case Templete
  @track selectedCaseTemplate;
  //Case Templete Default record Values
  @track caseTemplateRecLayoutValue = [];
  //Fields Which are not in Layout Also need to be added.
  @track caseTemplateRecValueOther = [];
  lowertoOriginalApi = [];
  record;
  topCount;
  tabCount;
  buttons;
  layoutsection;
  sectionHeading = [];
  section = 'A';
  formLayoutFieldAPInames;
  dataTypes;
  FIELDS = [];
  fieldDetails;
  // Final list to Update
  fieldstoUpdate = [];
  //All the Picklist Options
  casePickListOptions = [];

  @wire(getPicklistValuesByRecordType, { objectApiName: CASE_OBJECT, recordTypeId: '$recordTypeId' })
  casePickList({ error, data }) {
    if (data) {
      this.error = null;
      Object.keys(data.picklistFieldValues).forEach(ele => {
        this.casePickListOptions[ele] = data.picklistFieldValues[ele].values;
      });
    } else if (error) {
      this.error = JSON.stringify(error);
    }
  }

  handleSave() {
    let caseObj = {};
    caseObj.sobjectType = 'Case';
    let isValidate = true;
    this.template.querySelectorAll('c-case-form-fields').forEach(eachElement => {
      eachElement.validateInputs11();
      let compVal = eachElement.getValue();
      console.log('compVal>>66', JSON.stringify(compVal));
      if (compVal.required && compVal.value == null)
      //|| compVal.value === undefined || compVal.value === ''))
      {
        isValidate = false;
        const evt = new ShowToastEvent({
          title: 'Toast Error',
          message: 'Please fill the required fields',
          variant: 'error',
          mode: 'dismissable'
        });
        this.dispatchEvent(evt);
      }
      console.log('isvalidate', isValidate);
      if (isValidate && compVal.apiName != null &&
        compVal.apiName != '' &&
        compVal.apiName != undefined &&
        compVal.value != null &&
        compVal.value != undefined &&
        compVal.editableForNew) {
        if (compVal.type !== null && (compVal.type.toUpperCase() === "DATE" || compVal.type.toUpperCase() === "DATETIME")) {
          caseObj[compVal.apiName] = new Date(compVal.value);
        }
        else {
          caseObj[compVal.apiName] = compVal.value;
        }
      }
    });
    console.log('isvalidate1', isValidate);
    if (isValidate) {
      console.log('The Original Save');
      caseObj.Id = this.recordId;
      updateCase({
        record: caseObj
      }).then(res => {
        if (res) {

          //CaseComment Insert
          if (this.caseCommentValue !== null && this.caseCommentValue !== '' && this.caseCommentValue != undefined) {
            insertCaseComment({ caseCommentBody: this.caseCommentValue, recordId: this.recordId })
              .then(result => {

              })
              .catch(error => {
                // console.log('Error',error);
              });
          }

          //
          this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
              recordId: this.recordId,
              objectApiName: 'Case',
              actionName: 'view'
            },
          });



        }
      }).catch(error => {
        console.log('The Error Is', JSON.stringify(error));
      });
    }

  }
  // Picklist values based on record type
  connectedCallback() {
    createCase({ recordType: this.recordTypeId })
      .then(result => {
        this.recordId = result;
        console.log('Result', this.recordId);
      })
      .catch(error => {
        console.log('Error', error);
      });
    getQuickCase()
      .then(result => {
        if (result !== null && result !== undefined) {
          [{ label: '--None--', value: '--None--' }];
          this.caseTemplateRecord = result;
          this.quickCaseListOption = [{ label: '--None--', value: '--None--' }];
          result.forEach(ele => {
            this.quickCaseListOption.push({ label: ele.Name__c, value: ele.Name })
          })
        }
      })
      .catch(error => {
      });
    getRecordType()
      .then(result => {
        if (result !== null && result !== undefined) {
          var retRecTypData = result;
          for (var key in retRecTypData) {
            if (retRecTypData[key].Id == this.recordTypeId) {
              var currentRTName = retRecTypData[key].Name;
              this.recordTypeName = currentRTName;
            }
          }
        }
      })
      .catch(error => {
      });

    // for getting tabCount and topCount from custom setting 
    getCaseTabViewRecords()
      .then(result => {
        var retData = result;
        var topCountValue;
        var tabCountValue;
        for (var key in retData) {
          if (retData[key].RecordType__c == this.recordTypeName) {
            this.tabRecordType = retData[key].RecordType__c;
            if (retData[key].Top_Count__c > 0 && retData[key].Top_Count__c > 0) {
              topCountValue = retData[key].Top_Count__c;
              this.topCount = topCountValue;
              tabCountValue = retData[key].Tab_Count__c;
              this.tabCount = tabCountValue;
              this.requiredCaseComment = retData[key].Show_New_Comment__c;
            }
            else {
              this.topCount = 0;
              this.tabCount = 0;
            }

          }

        }

      })
      .catch(error => {

        console.log('Error>>153', error);
      });
  }

  @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
  caseInfo({ data, error }) {
    if (data) {
      this.dataTypes = Object.values(data.fields).map((fld) => {
        //console.log('fld', fld);
        let { apiName, dataType, label, required, createable, updateable } = fld;
        return { apiName, dataType, label, required, createable, updateable };
      });
    }
    console.log('fld>>188', this.dataTypes);
  }



  @wire(getRecordUi, { recordIds: '$recordId', layoutTypes: 'Full', modes: 'Create' })
  objectRecordUi({ error, data }) {
    if (data) {
      //console.log('data: ', data);
      var layoutData = data.layouts.Case;
      //console.log('layoutData: ', layoutData);
      for (var key in layoutData) {
        this.layoutsection = layoutData[key].Full.Create.sections;
      }
      var sectionHeader = [];
      var eachSection = [];
      var layoutSec = this.layoutsection;
      for (var key in layoutSec) {
        //all section related Information
        sectionHeader.push(layoutSec[key].heading);
      }
      this.sectionHeading = sectionHeader;
      // console.log('The Value Is', this.sectionHeading);
      var fieldAPIList = [];
      //Layout Sections
      for (var key in layoutSec) {
        var secRows = layoutSec[key].layoutRows;
        //Retrieve Rows from Section
        for (var i in secRows) {
          var items = secRows[i].layoutItems;
          //Retrieve fields From Items
          for (var j in items) {
            if (items[j].editableForNew) {
              var reqFields = items[j].required;
              var getfieldApi = items[j].layoutComponents;
              //to get ApiName for LayoutItem
              for (var k in getfieldApi) {
                let apiNameforMap = getfieldApi[k].apiName;
                if (apiNameforMap !== null) {
                  this.lowertoOriginalApi.push({ lower: apiNameforMap.toLowerCase(), apiName: apiNameforMap });

                  fieldAPIList.push({ apiName: getfieldApi[k].apiName, editableForNew: items[j].editableForNew, required: reqFields });
                }
              }
            }
          }
        }
      }

      //for selection of top sections,tab sections and bottom sections
      if (this.topCount > 0 && this.tabCount > 0 && (this.topCount + this.tabCount) < this.layoutsection.length + 1) {
        this.buttons = true;
        var i;
        var topSections = [];
        var tabSections = [];
        var bottomSections = [];
        for (i = 0; i < this.layoutsection.length; i++) {
          if (i < this.topCount) {
            topSections = this.layoutsection[i];
            //  this.topLayoutSections=this.topLayoutSection+this.layoutsection[i];
            this.topLayoutSections.push(topSections);


          }
          else if (i >= this.topCount && i < (this.topCount + this.tabCount)) {
            tabSections = this.layoutsection[i];
            console.log('tabSections>>198', tabSections);
            this.tabLayoutSections.push(tabSections);
            var tabSecButtons = this.tabLayoutSections;
            var reqTabs = [];
            var requiredLabel = [];
            var heading = [];
            var tempHolder = [];
            var reqFields;
            for (var l in tabSecButtons) {

              var secRows = tabSecButtons[l].layoutRows;
              console.log('secRows >>', secRows);
              for (var m in secRows) {

                var items = secRows[m].layoutItems;

                for (var n in items) {

                  reqFields = items[n].required;

                  var layComponents = items[n].layoutComponents;
                  for (var o in layComponents) {
                    if (items[n].required == true) {

                      reqTabs.push({ heading: tabSecButtons[l].heading, fieldLabel: layComponents[o].label });
                      console.log('reqTabs>>258', reqTabs);

                    }
                  }

                }

              }
            }
            this.reqTabSections = reqTabs;
            console.log('reqTabSections>>276', this.reqTabSections);
          }
          else if (i >= (this.topCount + this.tabCount)) {
            bottomSections = this.layoutsection[i];
            this.bottomLayoutSections.push(bottomSections);
          }

        }

        console.log('tabLayoutSections>>206', this.tabLayoutSections);
      }
      // end for caseTabviewer



      var fieldDetail = [];
      var fieldApi = [];
      //to get is editable ornot
      var fieldProperty = [];
      //to get the Api Name to Querry
      // var only1CreatedDate = true;
      for (var key in fieldAPIList) {
        this.dataTypes.forEach(ele => {
          if (fieldAPIList[key].apiName === ele.apiName) {
            fieldProperty.push({ apiName: ele.apiName, editableForNew: fieldAPIList[key].editableForNew, required: fieldAPIList[key].required });
            fieldApi.push(ele.apiName);
          }
        })
      }
      getCaseFieldValues({ recordId: this.recordId, fieldAPINameList: fieldApi })
        .then(result => {
          this.record = JSON.parse(result).currentRecord;
          // console.log('Result',this.record);
        })
        .catch(error => {
          // console.log('Error',error);
        });

      //To get the Field Details
      var recordData = this.record;
      for (var key in fieldProperty) {
        this.dataTypes.forEach(ele => {
          if (fieldProperty[key].apiName === ele.apiName) {
            let optionDefault = [{ label: '--None--', value: null }];
            let options = this.casePickListOptions[ele.apiName] || [];
            fieldDetail.push({
              realApiName: ele.apiName,
              dataType: ele.dataType,
              label: ele.label,
              required: fieldProperty[key].required,
              createable: ele.createable,
              updateable: ele.updateable,
              options: optionDefault.concat(options),
              editableForNew: fieldProperty[key].editableForNew
            });

          }
        })
      }
      this.fieldDetails = fieldDetail;
      console.log('Field Details>>323', this.fieldDetails);
    }
  }

  handleTabSections(event) {
    var buttonData;
    var clickedButton = event.target.label;
    var layoutSecData = this.layoutsection;
    for (var key in layoutSecData) {
      if (layoutSecData[key].heading == clickedButton) {
        buttonData = layoutSecData[key];
        this.buttonSections = buttonData;
      }
    }
    console.log('buttonSections>>341', this.buttonSections);
  }

  handleSectionToggle(event) {
    this.section = event.detail.openSections;
  }
  handleCaseTemplateChange(event) {
    this.selectedCaseTemplate = event.target.value;
    console.log('The Selected>>361', this.selectedCaseTemplate);
    //clearing the previous Value
    if (this.caseTemplateRecLayoutValue !== null && this.caseTemplateRecLayoutValue.length > 0) {
      var layoutDefVal = this.caseTemplateRecLayoutValue;
      layoutDefVal.forEach(ele => {
        let element = this.template.querySelector(`c-case-form-fields[data-id="${ele.apiName}"]`);
        element.setValue(null);
      })
      this.caseTemplateRecLayoutValue = [];
    }
    //feetching the default__value of record ApiName and Value
    var defaultValRecordFields = [];
    if (this.selectedCaseTemplate != '--None--') {
      if (this.caseTemplateRecord !== null && this.caseTemplateRecord !== undefined) {
        this.caseTemplateRecord.forEach(ele => {
          if (ele.Name === this.selectedCaseTemplate && ele.Default_Values__r !== null && ele.Default_Values__r !== undefined) {
            var defaultValueofTemplate = ele.Default_Values__r;
            for (var key in defaultValueofTemplate) {
              defaultValRecordFields.push({ apiName: defaultValueofTemplate[key].Field_API_Name__c, value: defaultValueofTemplate[key].Value__c });
            }
          }
        })
      }
      //to store ApiName and Value.present in Layout
      var defaultTemplateValues = [];
      var upperToLowerCaseApi = this.lowertoOriginalApi;
      if (defaultValRecordFields.length > 0) {

        defaultValRecordFields.forEach(ele => {
          for (var i in upperToLowerCaseApi) {
            //Storing Value Matching the Layout
            if (ele.apiName === upperToLowerCaseApi[i].lower) {
              defaultTemplateValues.push({ apiName: upperToLowerCaseApi[i].apiName, value: ele.value });
            }
            // else{
            //   this.caseTemplateRecValueOther.push({ apiName: ele.apiName, value: ele.value });
            // }
          }
        })
        this.caseTemplateRecLayoutValue = defaultTemplateValues;
        //Setting Value for Fields
        if (defaultTemplateValues.length > 0) {
          defaultTemplateValues.forEach(ele => {
            console.log('The Value Is', ele.apiName);
            let element = this.template.querySelector(`c-case-form-fields[data-id="${ele.apiName}"]`);
            element.setValue(ele.value);
          })
        }
      }
    }
    else {

    }
  }

  handleCancel() {
    deleteRecord(this.recordId)
      .then(result => {
        this[NavigationMixin.Navigate]({
          type: 'standard__objectPage',
          attributes: {
            objectApiName: 'Case',
            actionName: 'list'
          },
          state: {
            filterName: 'Recent'
          },
        });
      })
      .catch(error => {
        console.log('TestE >>>', error);
      });
  }

  handleCommentChange(event) {
    this.caseCommentValue = event.target.value;
    console.log('the value is', this.caseCommentValue)
  }
  handleCustomEvent(event) {
    const textVal = event.detail;
    // if(this.fldApi === 'Product__c' || this.fldApi === 'Area_of_Focus__c' || this.fldApi === 'Symptom_Main__c' || this.fldApi === 'Symptom_Sub__c' ){

    // }
    let apiName;
    let value;
    console.log('The Value Is1', textVal);
    textVal.forEach(ele => {
      apiName = ele.apiName;
      value = ele.value;
    })
    if (apiName === 'Product__c') {
      if (this.ifFirstTime) {
        this.ifFirstTime = false;
        console.log('The Value Is1');
        getAllDependentValues()
          .then(result => {
            this.productrelatedmapData = result;
            this.selectedProduct = value;
            console.log('Test1');
            this.handleProductChange(value);
          })
          .catch(error => {
            console.log('Error', error);
          });
      }
      else {
        this.selectedProduct = value;
        if (this.productrelatedmapData !== undefined && this.productrelatedmapData != null && this.ifFirstTime === false) {
          console.log('Test');
          this.handleProductChange();
        }
      }
    }
    //If area of focus
    else if (apiName === 'Area_of_Focus__c'){ 
      this.selectedAreaOfFocus = value;
      this.handleAreaOfFocusChange();
    }
    else if (apiName === 'Symptom_Main__c'){ 
      this.selectedSymptom = value;
      this.handleSymptomChange();
    }
  }
  @api
  handleProductChange() {
    var mapDataHandle = this.productrelatedmapData;
    console.log('The Result', mapDataHandle);
    this.isAOF = false;
    let mapData = [{ label: '--None--', value: null }];

    if (this.selectedProduct) {
      // if Selected country is none returns nothing
      if (this.selectedProduct === null) {
        this.isSymptom = true;
        this.isSubSymptom = true;
        this.isAOF = true;
        mapData = [{ label: '--None--', value: null }];
        this.selectedProduct = null;
        this.selectedAreaOfFocus = null;
        this.selectedSymptom = null;
        this.selectedSubSymptom = null;
        return;
      }
      var prodToAof = mapDataHandle.productToAreaOfFocusMap;
      for (var key in prodToAof) {
        if (key === this.selectedProduct) {
          var setofFocus = prodToAof[key];
          for (var i in setofFocus) {
            mapData.push({ label: setofFocus[i], value: setofFocus[i] });
            console.log('The log',setofFocus[i]);
          }
        }

      }
      if (mapData.length == 1) {
        this.isSymptom = true;
        this.isSubSymptom = true;
        this.selectedSymptom = null;
        this.selectedSubSymptom = null;
        this.selectedAreaOfFocus = null;
      }

      this.dependentAOFValues = mapData;
    }
    let aof = 'Area_of_Focus__c';
    console.log('The Picklist Option Is',this.dependentAOFValues);
    let element = this.template.querySelector(`c-case-form-fields[data-id="${aof}"]`);
    element.setproductRelated(this.selectedAreaOfFocus, this.dependentAOFValues, this.isAOF);
  }
  @api
  handleAreaOfFocusChange() {
      var mapDataHandle = this.productrelatedmapData;
      this.valueforSelectingSymptom = this.selectedProduct + this.selectedAreaOfFocus 
      let mapData= [{label:'--None--', value: null}];
      this.isSymptom = false;
      console.log("symptom", this.valueforSelectingSymptom)
      console.log('The AOF',this.selectedAreaOfFocus);
      if(this.selectedAreaOfFocus) {
          // if returns nothing
          if(this.selectedAreaOfFocus === null) {
              this.isSymptom = true;
              this.isSubSymptom = true;
              mapData = [{label:'--None--', value: null}];
              this.selectedAreaOfFocus = null;
              this.selectedSymptom = null;
              this.selectedSubSymptom = null;
              return;
          }
          var aofToSymptom = mapDataHandle.areaOfFocusToSymptomMap;
          for(var key in aofToSymptom){
              if(key === this.valueforSelectingSymptom){
                  var setofSym =aofToSymptom[key];
                  for(var i in setofSym){
                      mapData.push({label:setofSym[i],value:setofSym[i]}); 
                      console.log('The Key',setofSym[i]);
                  }
              }

          }
          if(mapData.length == 1){
              this.isSubSymptom = true;
              this.selectedSymptom = null;
              this.selectedSubSymptom = null;
          }
          this.dependentSymptomValues = mapData;
      }
      let sym = 'Symptom_Main__c';
    console.log('The Picklist Option Is',this.dependentAOFValues);
    let element = this.template.querySelector(`c-case-form-fields[data-id="${sym}"]`);
    element.setproductRelated(this.selectedSymptom, this.dependentSymptomValues, this.isSymptom);
  }

  handleSymptomChange() {
      var mapDataHandle = this.productrelatedmapData;
     
      this.valueforSelectingSubSymptom = this.selectedProduct + this.selectedSymptom + this.selectedAreaOfFocus;
      let mapData= [{label:'--None--', value:null}];
      this.isSubSymptom = false;
      console.log("symptom1", this.selectedSymptom)
      if(this.selectedSymptom) {
          // if returns nothing
          if(this.selectedSymptom ===null) {
            console.log("symptom12", this.selectedSymptom)
              this.isSubSymptom = true;
              mapData = [{label:'--None--', value:null}];
              this.selectedSubSymptom = null;
              this.selectedSymptom = null;
              return;
          }
          var symptomToSub = mapDataHandle.subSymptomMap;
          for(var key in symptomToSub){
              if(key === this.valueforSelectingSubSymptom){
                  var setofsub =symptomToSub[key];
                  for(var i in setofsub){
                      mapData.push({label:setofsub[i],value:setofsub[i]}); 
                  }
              }

          }
          //Check If the Selection dosesnt Have further Value
          if(mapData.length == 1){
              this.selectedSubSymptom = null;
          }
          this.dependentSubSymptomValues = mapData;
      }
    let symSub = 'Symptom_Sub__c';
    console.log('The Picklist Option Is',this.dependentAOFValues);
    let element = this.template.querySelector(`c-case-form-fields[data-id="${symSub}"]`);
    element.setproductRelated(this.selectedSubSymptom, this.dependentSubSymptomValues, this.isSubSymptom);
  }

  // handleSubSymptomChange(event) {
  //     this.selectedSubSymptom = event.target.value;
  //     if(this.selectedSubSymptom) {
  //         // if  returns nothing
  //         if(this.selectedSubSymptom === '--None--') {
  //             this.selectedSubSymptom = null;
  //             return;
  //         }
  //     }
  // }
}