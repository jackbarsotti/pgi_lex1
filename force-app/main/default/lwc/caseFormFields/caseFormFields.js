Julyimport { LightningElement, api } from "lwc";

export default class CaseFormFields extends LightningElement {
  @api isNew;
  @api isView;
  @api fieldObject = {};
  @api isComboDisabled;
  @api recordId;
  @api fldApi;
  @api record;
  @api fieldDetails = [];
  @api reqTabSections=[];
  @api fieldProperty;
  @api caseTemplateRecValue =[];
  @api reqTabNames=[];
  @api isError = false;
  @api error;
  handleOnValueChange (event) {
    var productReatedValues = [];
    var fldval = event.target.value;
    var fldValLbel=event.target.label;
    var reqTabs=[];
    if(this.fieldObject.isPicklist && fldval === '--None--'){
      fldval = null;
    }
    this.fieldObject.value = fldval;
    productReatedValues.push({value :this.fieldObject.value,apiName :this.fldApi});
    const selectEvent = new CustomEvent('mycustomevent', {
      detail: productReatedValues
  });
  this.dispatchEvent(selectEvent);
    console.log('The Xhanged',this.fieldObject.value);

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
      value : this.fieldObject.value ? this.fieldObject.value : null,
      editableForNew : this.fieldObject.editableForNew,
      required: this.fieldObject.required,
      type: this.fieldObject.fieldType
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
    this.fieldObject.value = val;
  }
  @api 
  setproductRelated (value , picklistoption, isdisabled) {
    console.log('VAlue',value);
    picklistoption.forEach(ele =>{
      console.log('option',ele);
    })
    console.log('isdisabled',isdisabled);
    this.fieldObject.value = value;
    this.isComboDisabled = isdisabled;
    this.fieldObject.pckListOptions = picklistoption;
  }

  
  connectedCallback() {
  //  console.log('reqTabSections>>57',this.reqTabSections);
    var fieldDetail = this.fieldDetails;
    for (var key in fieldDetail) {
      if ( this.fldApi === fieldDetail[key].realApiName ) {
      if(this.isNew && (this.fldApi === 'Area_of_Focus__c' || this.fldApi === 'Symptom_Main__c' || this.fldApi === 'Symptom_Sub__c' )){
        this.isComboDisabled =true;
      }
      this.fieldObject.editableForNew = fieldDetail[key].editableForNew;
        //this.fieldObject.editableForNew =fieldDetail[key].editableForNew;
        this.fieldObject.required = fieldDetail[key].required;
        //this.fieldObject.required=fieldDetail[key].required;
        //this.fieldObject.fieldProperty = fieldDetail[key];
        this.fieldObject.fieldProperty = fieldDetail[key];
        this.fieldObject.fieldType = fieldDetail[key].dataType;
        //this.fieldObject.fieldType = fieldDetail[key].dataType;
        this.fieldObject.value = this.record[this.fldApi];
        //this.fieldObject.value = this.record[this.fldApi];
        //this.fieldObject.label = fieldDetail[key].label;
        this.fieldObject.label = fieldDetail[key].label;
        //this.fieldObject.fieldRequired = fieldDetail[key].required;
        this.fieldObject.fieldRequired = fieldDetail[key].required;
        //this.fieldObject.pckListOptions = fieldDetail[key].options || [];
        this.fieldObject.pckListOptions = fieldDetail[key].options || [];
        // this.fieldObject.pckListOptions.unshift({label:'--None--',value:'--None--'});
        // console.log('The Picklist Option',JSON.stringify(fieldDetail[key].options));
      }
    }
    let type;
    if (this.fieldObject.fieldType !== null && this.fieldObject.fieldType !== undefined) {
      type = this.fieldObject.fieldType.toUpperCase();
    }
    if (type === "PICKLIST" || type === "COMBOBOX") {
      this.fieldObject.isPickList = true;
    }
    if (type === "DATE") {
      this.fieldObject.isDate = true;
    }
    if (type === "DATETIME") {
      this.fieldObject.isDateTime = true;
    }
    if (type === "STRING") {
      this.fieldObject.isString = true;
    }
    if (type === "TEXTAREA") {
      this.fieldObject.isTextArea = true;
    }
    if (type === "REFERENCE") {
      this.fieldObject.isLookup = true;
    }
    if (type === "URL") {
      this.fieldObject.isUrl = true;
    }
    if (type === "EMAIL") {
      this.fieldObject.isEmail = true;
    }
    if (type === "DOUBLE" || type === "PHONE") {
      this.fieldObject.isNumber = true;
    }
    if (type === "CURRENCY") {
      this.fieldObject.isCurrency = true;
    }
    if (type=== "BOOLEAN"){
      this.fieldObject.isBoolean=true;
    }
  }
  onEditFocus () {

  }
  handleValueSelcted(event) {
    this.fieldObject.value = event.detail && event.detail.length > 0 ? event.detail[0] : undefined;
}
}