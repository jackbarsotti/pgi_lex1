import { LightningElement, api } from "lwc";

export default class CaseFormFields extends LightningElement {
  @api isComboDisabled;
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
    var productReatedValues = [];
    var fldval = event.target.value;
    var fldValLbel=event.target.label;
    var reqTabs=[];
    if(this.isPickList && fldval === '--None--'){
      fldval = null;
    }
    this.value = fldval;
    productReatedValues.push({value :this.value,apiName :this.fldApi});
    const selectEvent = new CustomEvent('mycustomevent', {
      detail: productReatedValues
  });
  this.dispatchEvent(selectEvent);
    console.log('The Xhanged',this.value);

     var reqTabValues=this.reqTabSections;
     for(var p in reqTabValues){
       if(reqTabValues[p].fieldLabel===fldValLbel){
        if(fldval==='--None--' || fldval===undefined || fldval===" " || fldval===null){
            this.reqTabNames.push({heading:reqTabValues[p].heading});
        }
       }
     }
  }
 
  @api checkValidity() {

    const allValid = [...this.template.querySelectorAll('lightning-input')]
    .reduce((validSoFar, inputCmp) => {
                return validSoFar && inputCmp.checkValidity();
    }, true);
    if (allValid) {
         alert('All form entries look valid. Ready to submit!');
      } else {
        alert('Please update the invalid form entries and try again.');
    }
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

  @api getValue () {
    return {
      apiName : this.fldApi,
      value : this.value ? this.value : null,
      editableForNew : this.editableForNew,
      required: this.required,
      type: this.fieldType
    }
  }
  @api
  validateInputs11() {
    var isVal = true;
    this.template.querySelectorAll('lightning-combobox').forEach(element => {
      window.console.log('inside combobox for: ', element.reportValidity());
      isVal = isVal && element.reportValidity();
    });
    this.template.querySelectorAll('lightning-input').forEach(element => {
      window.console.log('inside input for: ', element.reportValidity());
      isVal = isVal && element.reportValidity();
    });
    this.template.querySelectorAll('lightning-textarea').forEach(element => {
      window.console.log('inside textarea for: ', element.reportValidity());
      isVal = isVal && element.reportValidity();
    });
    window.console.log('isVal: ', isVal);

  }

  @api 
  setValue (val ) {
    this.value = val;
  }
  @api 
  setproductRelated (value , picklistoption, isdisabled) {
    console.log('VAlue',value);
    picklistoption.forEach(ele =>{
      console.log('option',ele);
    })
    console.log('isdisabled',isdisabled);
    this.value = value;
    this.isComboDisabled = isdisabled;
    this.pckListOptions = picklistoption;
  }

  
  connectedCallback() {
  //  console.log('reqTabSections>>57',this.reqTabSections);
    var fieldDetail = this.fieldDetails;
    for (var key in fieldDetail) {
      if (fieldDetail[key].realApiName === this.fldApi) {
      if(this.fldApi === 'Area_of_Focus__c' || this.fldApi === 'Symptom_Main__c' || this.fldApi === 'Symptom_Sub__c' ){
        this.isComboDisabled =true;
      }
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