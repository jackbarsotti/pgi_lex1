import { LightningElement, api, wire, track } from 'lwc';
import CASE_OBJECT from '@salesforce/schema/Case';
import {getPicklistValuesByRecordType, getObjectInfo} from 'lightning/uiObjectInfoApi';
import { getRecordUi, deleteRecord } from 'lightning/uiRecordApi';
import getAllDependentValues from '@salesforce/apex/ProductSymptomsLex.getAllDependentValues';
import getCaseFieldValues from '@salesforce/apex/CaseCreateOverrideController.getCaseFieldValues';
import getRecordTypeDetail from '@salesforce/apex/CaseCreateOverrideController.getRecordTypeDetail';
import createCase from '@salesforce/apex/CaseCreateOverrideController.createCase';
import updateCase from '@salesforce/apex/CaseCreateOverrideController.updateCase';
import getQuickCase from '@salesforce/apex/CaseCreateOverrideController.getQuickCase';
import insertCaseComment from '@salesforce/apex/CaseCreateOverrideController.insertCaseComment';
import { NavigationMixin } from 'lightning/navigation';
import getRecordType from '@salesforce/apex/CaseRTSelection.getRecordType';
import getCaseTabViewRecords from '@salesforce/apex/CaseTabViewerController.getCaseTabViewRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CaseCreateOverride extends NavigationMixin(LightningElement) {
  @api isNew;
  @api isView;

  isEdit = false;
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
  //Assignment Rule
  @track isFireAssRule = true;
  //
  modes;
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
  layoutsection =[];
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
      console.log('the picklist');
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
      //console.log('compVal>>66', JSON.stringify(compVal));
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
      //console.log('isvalidate', isValidate);
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
    //console.log('isvalidate1', isValidate);
    if (isValidate) {
      //console.log('The Original Save');
      caseObj.Id = this.recordId;
      updateCase({
        record: caseObj,
        isAssignmentRule :this.isFireAssRule
      }).then(res => {
        if (res) {

          //CaseComment Insert
          if (this.caseCommentValue !== null && this.caseCommentValue !== '' && this.caseCommentValue != undefined) {
            insertCaseComment({ caseCommentBody: this.caseCommentValue, recordId: this.recordId })
              .then(result => {

              })
              .catch(error => {
                // //console.log('Error',error);
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
        //console.log('The Error Is', JSON.stringify(error));
      });
    }

  }
  // Picklist values based on record type
  connectedCallback() {
    console.log('The First',this.isView)
    
      console.log('result1',this.recordId);
      getRecordTypeDetail({ recordId: this.recordId })
      .then(result => {
         var count = 1;
        console.log('result',result);
         result.forEach(ele =>{
           console.log('The Edit',ele);
          if(count === 1){
             this.recordTypeId = ele;
             count += 1;
          }
          else{
            console.log('Testing');
           this.recordTypeName = ele;
          }
        })
        console.log('The RecTIs',this.recordId);
        console.log('The RecTName',this.recordTypeName);

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
    // getRecordType()
    //   .then(result => {
    //     if (result !== null && result !== undefined) {
    //       var retRecTypData = result;
    //       for (var key in retRecTypData) {
    //         if (retRecTypData[key].Id == this.recordTypeId) {
    //           var currentRTName = retRecTypData[key].Name;
    //           this.recordTypeName = currentRTName;
    //         }
    //       }
    //     }
    //   })
    //   .catch(error => {
    //   });

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

        //console.log('Error>>153', error);
      });
  }

  @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
  caseInfo({ data, error }) {
    if (data) {
      
      
      this.dataTypes = Object.values(data.fields).map((fld) => {
        let { apiName, dataType, label, required, createable, updateable } = fld;
      
        return { apiName, dataType, label, required, createable, updateable };
      });
    }
    //console.log('fld>>188', this.dataTypes);
  }

  @wire(getRecordUi, { recordIds: '$recordId', layoutTypes: 'Full', modes:'View' })
  objectRecordUi({ error, data }) {
    if (data) {
      var fieldApi = [];
      ////console.log('data: ', data);
      var layoutData = data.layouts.Case;
      ////console.log('layoutData: ', layoutData);
      var layoutSectionResult;
      for (var key in layoutData) {
          layoutSectionResult = layoutData[key].Full.View.sections;
        
      }
      console.log('The lay sec Is',layoutSectionResult);
      var sectionHeader = [];
      var eachSection = [];
      var layoutSec = layoutSectionResult;
      for (var key in layoutSec) {
        //all section related Information
        sectionHeader.push(layoutSec[key].heading);
      }
      this.sectionHeading = sectionHeader;
      // //console.log('The Value Is', this.sectionHeading);
      //Layout Sections
      for (var key in layoutSec) {
        var fieldAPIList = [];
        var secRows = layoutSec[key].layoutRows;
        //Retrieve Rows from Section
        for (var i in secRows) {
          var items = secRows[i].layoutItems;
          //Retrieve fields From Items
          for (var j in items) {
            console.log('editableForNew: ',items[j].editableForNew);
            if (items[j].editableForNew) {
              var reqFields = items[j].required;
              var getfieldApi = items[j].layoutComponents;
              //to get ApiName for LayoutItem
              let count = 0;
              for (var k in getfieldApi) {
                let apiNameforMap = getfieldApi[k].apiName;
                if (apiNameforMap !== null && count === 0) {
                  fieldApi.push(getfieldApi[k].apiName);
                  this.lowertoOriginalApi.push({ lower: apiNameforMap.toLowerCase(), apiName: apiNameforMap });
                  fieldAPIList.push({ apiName: getfieldApi[k].apiName, editableForNew: items[j].editableForUpdate, required: reqFields ,lower: apiNameforMap.toLowerCase()});
                  
                }
                count += 1;
              }
            }
            //
          }

        }
        this.layoutsection.push({sectionHeader :layoutSec[key].heading,sectionDetails :fieldAPIList});
      }

      getAllDependentValues().then(result => {
        console.log('ResultDP: ',this.recordId);

        console.log('fieldApi Case: ',fieldApi);
        this.productrelatedmapData = result;
        return getCaseFieldValues({
          recordId: this.recordId,
          fieldAPINameList: fieldApi
        })
      }).then(result => {
        this.record = JSON.parse(result).currentRecord;
        console.log('Result', this.record);
        //To set the Default Value For 
        if (this.isNew === false) {
          this.selectedProduct = this.record['Product__c'];
          this.selectedAreaOfFocus = this.record['Area_of_Focus__c'];
          this.selectedSubSymptom = this.record['Symptom_Sub__c'];
          this.selectedSymptom = this.record['Symptom_Main__c'];
          console.log('The AOFIS', this.selectedAreaOfFocus);
        }
        //to get Dependent Picklist Values

        //Setting Picklist Values And Details
        var fieldDetail = [];
        let sectionResult = this.layoutsection;
        for (var key in sectionResult) {
          let eachSection = sectionResult[key].sectionDetails;
          for (let j in eachSection) {
            this.dataTypes.forEach(ele => {
              if (eachSection[j].apiName === ele.apiName) {
                let optionDefault = [{
                  label: '--None--',
                  value: null
                }];

                console.log('The PickList', this.casePickListOptions[ele.apiName])
                let options = this.casePickListOptions[ele.apiName] || [];

                if (this.selectedProduct &&
                  typeof (this.selectedProduct) !== 'undefined' &&
                  this.selectedProduct !== null) {
                  let optionsList = [];
                  if (eachSection[j].apiName === 'Area_of_Focus__c') {
                    const prodToAof = this.productrelatedmapData.productToAreaOfFocusMap;
                    for (var key in prodToAof) {
                      if (key === this.selectedProduct) {
                        var setofFocus = prodToAof[key];
                        for (var i in setofFocus) {
                          optionsList.push({
                            label: setofFocus[i],
                            value: setofFocus[i]
                          });
                        }
                      }
                    }
                    options = optionsList;
                  }
                  if (eachSection[j].apiName === 'Symptom_Sub__c') {
                    this.valueforSelectingSubSymptom = this.selectedProduct + this.selectedSymptom + this.selectedAreaOfFocus;
                    const prodToAof = this.productrelatedmapData.subSymptomMap;
                    for (var key in prodToAof) {
                      if (key === this.valueforSelectingSubSymptom) {
                        var setofFocus = prodToAof[key];
                        for (var i in setofFocus) {
                          optionsList.push({
                            label: setofFocus[i],
                            value: setofFocus[i]
                          });
                        }
                      }
                    }
                    options = optionsList;
                  }
                  if (eachSection[j].apiName === 'Symptom_Main__c') {
                    this.valueforSelectingSymptom = this.selectedProduct + this.selectedAreaOfFocus;
                    const prodToAof = this.productrelatedmapData.areaOfFocusToSymptomMap;
                    for (var key in prodToAof) {
                      if (key === this.valueforSelectingSymptom) {
                        var setofFocus = prodToAof[key];
                        for (var i in setofFocus) {
                          optionsList.push({
                            label: setofFocus[i],
                            value: setofFocus[i]
                          });
                          //console.log('The log',setofFocus[i]);
                        }
                      }
                    }
                    options = optionsList;
                  }
                }

                fieldDetail.push({
                  realApiName: ele.apiName,
                  dataType: ele.dataType,
                  label: ele.label,
                  required: eachSection[j].required,
                  createable: ele.createable,
                  updateable: ele.updateable,
                  options: optionDefault.concat(options),
                  editableForNew: eachSection[j].editableForNew
                });
                // fieldApi.push(ele.apiName);
              }
            })
          }
        }
        this.fieldDetails = fieldDetail;
        console.log('Field Details>>323', this.fieldDetails);
        //End
      })
      .catch(error => {

        console.log('error in resut: ',error.getMessage());
      });

  }
  }

  handleSectionToggle(event) {
    this.section = event.detail.openSections;
  }
  handleCaseTemplateChange(event) {
    this.selectedCaseTemplate = event.target.value;
    //console.log('The Selected>>361', this.selectedCaseTemplate);
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
            //console.log('The Value Is', ele.apiName);
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
        //console.log('TestE >>>', error);
      });
  }

  handleCommentChange(event) {
    this.caseCommentValue = event.target.value;
    //console.log('the value is', this.caseCommentValue)
  }

  handleOnAssRuleChange(event) {
    this.isFireAssRule = event.target.checked;
    console.log('the value is', this.isFireAssRule);
    console.log('the value is1', event.target.checked);
    console.log('the value is12', event.target.value);
  }

  handleCustomEvent(event) {
    const textVal = event.detail;
    // if(this.fldApi === 'Product__c' || this.fldApi === 'Area_of_Focus__c' || this.fldApi === 'Symptom_Main__c' || this.fldApi === 'Symptom_Sub__c' ){

    // }
    let apiName;
    let value;
    //console.log('The Value Is1', textVal);
    textVal.forEach(ele => {
      apiName = ele.apiName;
      value = ele.value;
    })
    if (apiName === 'Product__c') {
      this.selectedProduct = value;
      this.handleProductChange();
    }
    //If area of focus
    else if (apiName === 'Area_of_Focus__c') {
      this.selectedAreaOfFocus = value;
      this.handleAreaOfFocusChange();
    } else if (apiName === 'Symptom_Main__c') {
      this.selectedSymptom = value;
      this.handleSymptomChange();
    }
  }
  @api
  handleProductChange() {
    var mapDataHandle = this.productrelatedmapData;
    //console.log('The Result', mapDataHandle);
    this.isAOF = false;
    let mapData = [{
      label: '--None--',
      value: null
    }];
    this.isSymptom = true;
    this.isSubSymptom = true;
    this.selectedSymptom = null;
    this.selectedSubSymptom = null;
    this.dependentSymptomValues = [];
    this.dependentAOFValues = [];
    this.dependentSubSymptomValues = [];
    if (this.selectedProduct) {
      // if Selected country is none returns nothing
      var prodToAof = mapDataHandle.productToAreaOfFocusMap;
      for (var key in prodToAof) {
        if (key === this.selectedProduct) {
          var setofFocus = prodToAof[key];
          for (var i in setofFocus) {
            mapData.push({
              label: setofFocus[i],
              value: setofFocus[i]
            });
            //console.log('The log',setofFocus[i]);
          }
        }

      }
      if (mapData.length == 1) {
        console.log('Test 1');
        this.isSymptom = true;
        this.isSubSymptom = true;
        this.isAOF = true;
        this.selectedSymptom = null;
        this.selectedSubSymptom = null;
        this.selectedAreaOfFocus = null;
      }

      this.dependentAOFValues = mapData;
    } else if (this.selectedProduct === null) {
      //console.log('The Null')
      this.isSymptom = true;
      this.isSubSymptom = true;
      this.isAOF = true;
      this.selectedProduct = null;
      this.selectedAreaOfFocus = null;
      this.selectedSymptom = null;
      this.selectedSubSymptom = null;
    }
    let aof = 'Area_of_Focus__c';
    let element = this.template.querySelector(`c-case-form-fields[data-id="${aof}"]`);
    element.setproductRelated(this.selectedAreaOfFocus, this.dependentAOFValues, this.isAOF);
    let sym = 'Symptom_Main__c';
    let element1 = this.template.querySelector(`c-case-form-fields[data-id="${sym}"]`);
    element1.setproductRelated(this.selectedSymptom, this.dependentSymptomValues, this.isSymptom);
    let symSub = 'Symptom_Sub__c';
    let element2 = this.template.querySelector(`c-case-form-fields[data-id="${symSub}"]`);
    element2.setproductRelated(this.selectedSubSymptom, this.dependentSubSymptomValues, this.isSubSymptom);
  }
  @api
  handleAreaOfFocusChange() {
    var mapDataHandle = this.productrelatedmapData;
    console.log('The Value AOF', this.selectedAreaOfFocus)
    this.valueforSelectingSymptom = this.selectedProduct + this.selectedAreaOfFocus;
    let mapData = [{
      label: '--None--',
      value: null
    }];
    this.isSymptom = false;
    this.isSubSymptom = true;
    this.selectedSymptom = null;
    this.selectedSubSymptom = null;
    this.dependentSymptomValues = [];
    this.dependentSubSymptomValues = [];
    //console.log("symptom", this.valueforSelectingSymptom)
    //console.log('The AOF',this.selectedAreaOfFocus);
    if (this.selectedAreaOfFocus) {
      // if returns nothing
      var aofToSymptom = mapDataHandle.areaOfFocusToSymptomMap;
      for (var key in aofToSymptom) {
        if (key === this.valueforSelectingSymptom) {
          var setofSym = aofToSymptom[key];
          for (var i in setofSym) {
            mapData.push({
              label: setofSym[i],
              value: setofSym[i]
            });
            //console.log('The Key',setofSym[i]);
          }
        }

      }
      console.log('TestAof1');
      if (mapData.length == 1) {
        console.log('TestAof1');
        this.isSubSymptom = true;
        this.selectedSymptom = null;
        this.selectedSubSymptom = null;
      }
      this.dependentSymptomValues = mapData;
    } else if (this.selectedAreaOfFocus === null) {
      console.log('TestAof');
      this.isSymptom = true;
      this.isSubSymptom = true;
      this.selectedAreaOfFocus = null;
      this.selectedSymptom = null;
      this.selectedSubSymptom = null;
    }
    console.log('The Symptom is', this.selectedSymptom);
    let sym = 'Symptom_Main__c';
    let element1 = this.template.querySelector(`c-case-form-fields[data-id="${sym}"]`);
    element1.setproductRelated(this.selectedSymptom, this.dependentSymptomValues, this.isSymptom);
    let symSub = 'Symptom_Sub__c';
    let element2 = this.template.querySelector(`c-case-form-fields[data-id="${symSub}"]`);
    element2.setproductRelated(this.selectedSubSymptom, this.dependentSubSymptomValues, this.isSubSymptom);
  }

  handleSymptomChange() {
    console.log('The Value SYM');
    var mapDataHandle = this.productrelatedmapData;

    this.valueforSelectingSubSymptom = this.selectedProduct + this.selectedSymptom + this.selectedAreaOfFocus;
    let mapData = [{
      label: '--None--',
      value: null
    }];
    this.isSubSymptom = false;
    this.selectedSubSymptom = null;
    this.dependentSubSymptomValues = [];
    //console.log("symptom1", this.selectedSymptom)
    if (this.selectedSymptom) {
      // if returns nothing

      var symptomToSub = mapDataHandle.subSymptomMap;
      for (var key in symptomToSub) {
        if (key === this.valueforSelectingSubSymptom) {
          var setofsub = symptomToSub[key];
          for (var i in setofsub) {
            mapData.push({
              label: setofsub[i],
              value: setofsub[i]
            });
          }
        }

      }
      //Check If the Selection dosesnt Have further Value
      if (mapData.length == 1) {
        this.selectedSubSymptom = null;
      }
      this.dependentSubSymptomValues = mapData;
    } else if (this.selectedSymptom === null) {
      //console.log("symptom12", this.selectedSymptom)
      this.isSubSymptom = true;
      this.selectedSubSymptom = null;
      this.selectedSymptom = null;
    }
    let symSub = 'Symptom_Sub__c';
    //console.log('The Picklist Option Is',this.dependentAOFValues);
    let element = this.template.querySelector(`c-case-form-fields[data-id="${symSub}"]`);
    element.setproductRelated(this.selectedSubSymptom, this.dependentSubSymptomValues, this.isSubSymptom);
  }

  handleViewEdit(event){
    console.log('Parent myeditevent: ',event.fldObj);

    // if(this.fieldObject.editableForNew ){

    // }
    this.isView = false;
    this.template.querySelectorAll('c-case-form-fields').forEach(eachElement => {
      eachElement.setEditForView();
    });
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