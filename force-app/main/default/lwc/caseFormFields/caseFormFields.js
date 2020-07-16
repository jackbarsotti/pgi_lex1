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
  @api isCurrency;
  @api pckListOptions;
  @api editableForNew;
  @api caseTemplateRecValue =[];
  handleOnValueChange (event) {
    var fldval = event.target.value;
    if(this.isPickList && fldval === '--None--'){
      fldval = null;
    }
    this.value = fldval;
    console.log('The Xhanged',this.value);
  }
  @api getValue () {
    return {
      apiName : this.fldApi,
      value : this.value,
      editableForNew : this.editableForNew
    }
  }
  @api 
  setValue (val) {
    this.value = val;
  }
  connectedCallback() {
    var fieldDetail = this.fieldDetails;
    for (var key in fieldDetail) {
      if (fieldDetail[key].realApiName === this.fldApi) {
        this.editableForNew =fieldDetail[key].editableForNew;
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
  }
  onEditFocus () {

  }
  handleValueSelcted(event) {
    this.value = event.detail && event.detail.length > 0 ? event.detail[0] : undefined;
}
}