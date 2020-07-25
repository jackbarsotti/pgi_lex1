import { LightningElement, api, wire, track } from "lwc";
import { getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi"; 
import CASE_OBJECT from "@salesforce/schema/Case";
import { updateRecord } from "lightning/uiRecordApi";
import LANG from "@salesforce/i18n/lang";
import mediumDateFormat from "@salesforce/i18n/dateTime.mediumDateFormat";
import usertimeZone from "@salesforce/i18n/timeZone";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CaseFormFields extends LightningElement {
  @api recordId;
  @api recordTypeId;
  @api fldApi;
  @api record;
  @api fieldDetails = [];
  @api reqTabSections=[];
  @api fieldProperty;
  @api value;
  @api label;
  @api fieldRequired;
  @api fieldType;
  @api fieldLabel;
  @api isString;
  @api isPickList;
  @api isDate;
  @api isDateTime;
  @api isTextArea;
  @api isisLookupDate;
  @api isUrl;
  @api isEmail;
  @api isNumber;
  @api isBoolean;
  @api isCurrency;
  @api pckListOptions;
  @api editableForNew;
  @api required;
  @api caseTemplateRecValue =[];
  @api reqTabNames=[];
  @api isError = false;
  @api error;
  handleOnValueChange (event) {
    var fldval = event.target.value;
    var fldValLbel=event.target.label;
    var reqTabs=[];
    console.log('fldValLbel>>40',fldValLbel);

    if(this.isPickList && fldval === '--None--'){
      fldval = null;
    }
    this.value = fldval;
    console.log('The Xhanged',this.value);

     var reqTabValues=this.reqTabSections;
     for(var p in reqTabValues){
       console.log('in for >53 ');
       if(reqTabValues[p].fieldLabel===fldValLbel){
        console.log('in if >55 ');
        if(fldval==='--None--' || fldval===undefined || fldval===" " || fldval===null){
          console.log('in for >57 ')
            this.reqTabNames.push({heading:reqTabValues[p].heading});
            console.log('tabNames>>56',this.reqTabNames);
        }
       }
     }
  }
 
  @api checkValidity() {

    const allValid = [...this.template.querySelectorAll('lightning-input')]
    .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                // console.log('inputCmp.reportvalidity',JSON.stringify(inputCmp.reportValidity()));
                // console.log('validsoFar',validSoFar);
                // console.log('inputCmp.checkValidity()',JSON.stringify(inputCmp.checkValidity()));
                return validSoFar && inputCmp.checkValidity();
    }, true);
    if (allValid) {
         alert('All form entries look valid. Ready to submit!');
      } else {
        alert('Please update the invalid form entries and try again.');
    }
      
  //   var inputCmp=[];
  // /*  let divclass=this.template.querySelector('.div-class');
  //   console.log('divClass>>',JSON.stringify(divclass));
  //   let secondClasses = divclass.querySelectorAll(".inputCmp");
  //   console.log('secondclass>>',JSON.stringify(secondClasses));*/
  //   inputCmp.push(this.template.querySelectorAll("lightning-input"));
  //   console.log('inputCmp',inputCmp);
  //   console.log('inputCmp>>66',JSON.stringify(this.template.querySelectorAll("lightning-input")));
  //   var value = inputCmp.value;
  //   console.log('value>>69',value);
  //   // is input is valid?
  //   if (!value) {
  //     inputCmp.setCustomValidity("Please Enter a valid Value");
  //   } else {
  //     inputCmp.setCustomValidity(""); 
  //   }
  //   inputCmp.reportValidity(); // Tells lightning-input to show the error right away without needing interaction
  }

  @api
    validateInputs() {
     return [...this.template.querySelectorAll('lightning-input')]
            .reduce((allValid, inputCmp) => {
              window.console.log('inputCm: ',inputCmp);
              window.console.log('inputCmp.checkValidit: ',inputCmp.checkValidity());
              inputCmp.reportValidity();
                if (inputCmp.checkValidity()) {
                    return allValid; 
                }
                return false;
            }, true);
          }
    /*
               inputCmp.reportValidity();
                if (inputCmp.checkValidity()) {
                    return allValid; 
                }
                return false;
            }, true);
      
     */
    /*   inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
    if (allValid) {
        alert('All form entries look valid. Ready to submit!');
    } else {
        alert('Please update the invalid form entries and try again.');
    }*/

  @api getValue () {
    return {
      apiName : this.fldApi,
      value : this.value ? this.value : null,
      editableForNew : this.editableForNew,
      required: this.required
    }
  }
  @api 
  setValue (val) {
    this.value = val;
  }
  // @api 
  // setError () {
  //   if(this.value === null || this.value === '' || this.value === undefined){
  //     console.log('The ReQFLD',this.fldApi);
  //     this.isError =true;
  //     this.error = 'Please fill the required Field';
  //   }
  // }

  
  connectedCallback() {
  //  console.log('reqTabSections>>57',this.reqTabSections);
    var fieldDetail = this.fieldDetails;
    for (var key in fieldDetail) {
      if (fieldDetail[key].realApiName === this.fldApi) {
        this.editableForNew =fieldDetail[key].editableForNew;
        this.required=fieldDetail[key].required;
        var caseTempValues = this.caseTemplateRecValue;
        // if(caseTempValues.length > 0){
        // for(var i in caseTempValues){
        //   if(caseTempValues[i].apiName === this.fldApi){
        //     console.log('The TempLATE API',caseTempValues[i].apiName);
        //     console.log('The TempLATE Val1',caseTempValues[i].value);
        //   }
        // }
        // }
        this.fieldProperty = fieldDetail[key];
        this.fieldType = fieldDetail[key].dataType;
        this.value = this.record[this.fldApi];
        this.label = fieldDetail[key].label;
        this.fieldRequired = fieldDetail[key].required;
        this.pckListOptions = fieldDetail[key].options || [];
        // this.pckListOptions.unshift({label:'--None--',value:'--None--'});
        // console.log('The Picklist Option',JSON.stringify(fieldDetail[key].options));
      }
    }
    let type;
    if (this.fieldType !== null && this.fieldType !== undefined) {
      type = this.fieldType.toUpperCase();
    }
    if (type === "PICKLIST" || type === "COMBOBOX") {
      this.isPickList = true;
    }
    if (type === "DATE") {
      this.isDate = true;
    }
    if (type === "DATETIME") {
      this.isDateTime = true;
    }
    if (type === "STRING") {
      this.isString = true;
    }
    if (type === "TEXTAREA") {
      this.isTextArea = true;
    }
    if (type === "REFERENCE") {
      this.isLookup = true;
    }
    if (type === "URL") {
      this.isUrl = true;
    }
    if (type === "EMAIL") {
      this.isEmail = true;
    }
    if (type === "DOUBLE" || type === "PHONE") {
      this.isNumber = true;
    }
    if (type === "CURRENCY") {
      this.isCurrency = true;
    }
    if (type=== "BOOLEAN"){
      this.isBoolean=true;
    }
  }
  onEditFocus () {

  }
  handleValueSelcted(event) {
    this.value = event.detail && event.detail.length > 0 ? event.detail[0] : undefined;
}
}