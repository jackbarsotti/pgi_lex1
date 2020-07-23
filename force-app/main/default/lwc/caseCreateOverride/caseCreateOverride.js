import { LightningElement, api, wire, track } from 'lwc';
import CASE_OBJECT from '@salesforce/schema/Case';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getRecordUi, deleteRecord } from 'lightning/uiRecordApi';
import getCaseFieldValues from '@salesforce/apex/CaseCreateOverrideController.getCaseFieldValues';
import createCase from '@salesforce/apex/CaseCreateOverrideController.createCase';
import updateCase from '@salesforce/apex/CaseCreateOverrideController.updateCase';
import getQuickCase from '@salesforce/apex/CaseCreateOverrideController.getQuickCase';
import { NavigationMixin } from 'lightning/navigation';
import getRecordType from '@salesforce/apex/CaseRTSelection.getRecordType';
import getCaseTabViewRecords from '@salesforce/apex/CaseTabViewerController.getCaseTabViewRecords';

export default class CaseCreateOverride extends NavigationMixin(LightningElement) {
  @api recordId;
  @api recordTypeId;
  @api recordTypeName;
  @api tabRecordType;
  @api topLayoutSections=[];
  @api tabLayoutSections=[];
  @api bottomLayoutSections=[];
  @api buttonSections=[];
  @api reqTabSections=[];
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
    console.log('compVal>>hj');
    let caseObj = {};
    this.template.querySelectorAll('c-case-form-fields').forEach(eachElement => {
      let compVal = eachElement.getValue();
      console.log('compVal>>66',JSON.stringify(compVal));
      if (compVal.apiName != null
        && compVal.apiName != ''
        && compVal.apiName != undefined
        && compVal.value != null
        && compVal.value != undefined
        && compVal.editableForNew) {
          console.log('in if>>74');
        caseObj[compVal.apiName] = compVal.value;
        console.log('in if>>74',caseObj[compVal.apiName]);
      }
    });
    caseObj.Id = this.recordId;
    console.log(caseObj);
    updateCase({ record: caseObj }).then(res => {
      console.log(`${res}`);
      if (res) {
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
      console.log(`${error}`);
    });

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
          if(result !== null && result !== undefined){
            var retRecTypData= result;
             for(var key in retRecTypData){
              if(retRecTypData[key].Id == this.recordTypeId){
                var currentRTName=retRecTypData[key].Name;
                this.recordTypeName=currentRTName;
              }
            }
          }
        })
        .catch(error => {
        });

        // for getting tabCount and topCount from custom setting 
        getCaseTabViewRecords()
     .then(result => {
      var retData= result;
     var topCountValue;
    var tabCountValue;
    for(var key in retData){
        if(retData[key].RecordType__c == this.recordTypeName){
           this.tabRecordType=retData[key].RecordType__c;
          if(retData[key].Top_Count__c >0 && retData[key].Top_Count__c >0){
           topCountValue = retData[key].Top_Count__c;
            this.topCount = topCountValue; 
            tabCountValue=retData[key].Tab_Count__c;
            this.tabCount=tabCountValue;
          }
          else 
          {
            this.topCount= 0;
            this.tabCount= 0;
          }
           
        }
        
    }
      
    })
    .catch(error => {

      console.log('Error>>153',error);
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
     console.log('fld>>188',this.dataTypes);
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
            if(items[j].editableForNew){
            var reqFields=items[j].required;
            var getfieldApi = items[j].layoutComponents;
            //to get ApiName for LayoutItem
            for (var k in getfieldApi) {
              let apiNameforMap = getfieldApi[k].apiName;
              if (apiNameforMap !== null) {
                this.lowertoOriginalApi.push({ lower: apiNameforMap.toLowerCase(), apiName: apiNameforMap });
              }
              fieldAPIList.push({ apiName: getfieldApi[k].apiName, editableForNew: items[j].editableForNew, required:reqFields });
            }
          }
          }
        }
      }

      //for selection of top sections,tab sections and bottom sections
      if(this.topCount > 0 && this.tabCount> 0 && (this.topCount + this.tabCount ) < this.layoutsection.length +1 ){
        this.buttons = true;  
        var i;  
        var topSections=[];
        var tabSections=[];
        var bottomSections=[];
        for(i=0;i<this.layoutsection.length;i++){ 
          if(i<this.topCount){
            topSections=this.layoutsection[i];
          //  this.topLayoutSections=this.topLayoutSection+this.layoutsection[i];
            this.topLayoutSections.push(topSections);
          
           
          }
          else if(i>=this.topCount && i<(this.topCount + this.tabCount)){
            tabSections=this.layoutsection[i];
            console.log('tabSections>>198',tabSections);
            this.tabLayoutSections.push(tabSections);
           var tabSecButtons=this.tabLayoutSections;
           var reqTabs=[];
            var reqFields;
          for(var l in tabSecButtons){
            var secRows = tabSecButtons[l].layoutRows;
            
            for (var m in secRows) {
              var items = secRows[m].layoutItems;  
              for (var n in items) {
                
                reqFields=items[n].required;
                var layComponents=items[n].layoutComponents;
                // if(reqFields==true){
                //   console.log('tabSecButtons[l].heading>>',tabSecButtons[l].heading);
                //   if(reqTabs.contains(tabSecButtons[l].heading)){
                //     console.log('contains>>271');
                //   }
                //   else{
                //     reqTabs.push({heading:tabSecButtons[l].heading,});
                //     console.log('reqTabs>>258',reqTabs);
                //   }
                // }
                for(var o in layComponents){
                 // let reqLabel= layComponents[o].label;
                  // if(items[n].required==true){
                  //   this.reqTabSections.push({heading:tabSecButtons[l].heading,fieldLabel:layComponents[o].label});
                  //     console.log('reqTabSections>>258',this.reqTabSections);
                  // }
                  if(items[n].required==true){
                   
                    // if(reqTabs.heading.contains(tabSecButtons[l].heading)){
                    //   console.log('in272')
                    //   reqTabs.add({fieldLabel:layComponents[o].label});

                    // }
                    reqTabs.push({heading:tabSecButtons[l].heading,fieldLabel:layComponents[o].label});
                      console.log('reqTabs>>258',reqTabs);
                      
                  }
                }
               
              }
              
            }
          }
          this.reqTabSections=reqTabs;
          console.log('reqTabSections>>276',this.reqTabSections);
          }
          else if(i>=(this.topCount + this.tabCount)){
            bottomSections=this.layoutsection[i];
            this.bottomLayoutSections.push(bottomSections);
          }
         
        }
         
        console.log('tabLayoutSections>>206',this.tabLayoutSections);
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
       console.log('Field Details>>323',this.fieldDetails);
    }
  }

  handleTabSections(event){
    var buttonData;
    var clickedButton = event.target.label;
    var layoutSecData=this.layoutsection;
    for(var key in layoutSecData){
      if(layoutSecData[key].heading == clickedButton){
        buttonData=layoutSecData[key];
        this.buttonSections=buttonData;
      }
    }
    console.log('buttonSections>>341',this.buttonSections);
  }

  handleSectionToggle(event) {
    this.section = event.detail.openSections;
  }
  handleCaseTemplateChange(event) {
    this.selectedCaseTemplate = event.target.value;
    console.log('The Selected>>361', this.selectedCaseTemplate);
    //clearing the previous Value
    if(this.caseTemplateRecLayoutValue !== null && this.caseTemplateRecLayoutValue.length > 0){
      var layoutDefVal = this.caseTemplateRecLayoutValue;
      layoutDefVal.forEach(ele =>{
        let element = this.template.querySelector(`c-case-form-fields[data-id="${ele.apiName}"]`);
          element.setValue(null);
      })
      this.caseTemplateRecLayoutValue =[];
    }
    //feetching the default__value of record ApiName and Value
    var defaultValRecordFields = [];
    if(this.selectedCaseTemplate != '--None--'){
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


    //console.log('The ResultVal',JSON.stringify(this.caseTemplateRecValue));
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
      console.log('TestE >>>',error);   
    });
}
}