import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import CASE_PRODUCT_FOCUS_SYMPTOM_OBJECT from '@salesforce/schema/Case_Product_Focus_Symptom__c';
import PRODUCT_FIELD from '@salesforce/schema/Case_Product_Focus_Symptom__c.Product__c';
import AREA_OF_FOCUS_FIELD from '@salesforce/schema/Case_Product_Focus_Symptom__c.Area_of_Focus__c';
import SYMPTOM_FIELD from '@salesforce/schema/Case_Product_Focus_Symptom__c.Symptom__c';
import SUB_SYMPTOM_FIELD from '@salesforce/schema/Case_Product_Focus_Symptom__c.Sub_Symptom__c';

export default class ProductSymptoms_LEX extends LightningElement { 
    // Product__c
    // Area_of_Focus__c
    // Symptom__c
    // Sub_Symptom__c

    @api objectApiName;
    
    @track objectInfo;
    @track defaultrecordtypeid;

    @wire(getObjectInfo, { objectApiName: CASE_PRODUCT_FOCUS_SYMPTOM_OBJECT })
    objectInfo;

    // getObjectInfoData({data,error}) {
        
    //     if(data) {
    //         console.log('log defaultrecordtypeid ' + data.defaultRecordTypeId);
    //         this.defaultrecordtypeid = data.defaultRecordTypeId;
    //     }
    //     else if(error) {
    //         console.log('log error ' + error);
    //         this.error = error;
    //     }
    // }

    
    get objectInfoData() {
        return this.objectInfo ?
                JSON.stringify(this.objectInfo.data, null, 2) :
                'No object info';
    }
    
    // @wire(getPicklistValues, { recordTypeId: this.defaultrecordtypeid, fieldApiName: PRODUCT_FIELD })
    // cpfsProduct;

    // get cpfsProductData() {
        
    //     return this.cpfsProduct ?
    //             JSON.stringify(this.cpfsProduct.data, null, 2) :
    //             'No product data';
    // }

    // @wire(getPicklistValues, { recordTypeId: this.defaultrecordtypeid, fieldApiName: AREA_OF_FOCUS_FIELD })
    // cpfsAreaOfFocus;

    // get cpfsAreaOfFocusData() {
    //     return this.cpfsAreaOfFocus ?
    //             JSON.stringify(this.cpfsAreaOfFocus.data, null, 2) :
    //             'No area of focus data';
    // }

    // @wire(getPicklistValues, { recordTypeId: this.defaultrecordtypeid, fieldApiName: SYMPTOM_FIELD })
    // cpfsSymptom;

    // get cpfsSymptomData() {
    //     return this.cpfsSymptom ?
    //             JSON.stringify(this.cpfsSymptom.data, null, 2) :
    //             'No symptom data';
    // }

    // @wire(getPicklistValues, { recordTypeId: this.defaultrecordtypeid, fieldApiName: SUB_SYMPTOM_FIELD })
    // cpfsSubSymptom;

    // get cpfsSubSymptomData() {
    //     return this.cpfsSubSymptom ?
    //             JSON.stringify(this.cpfsSubSymptom.data, null, 2) :
    //             'No sub symptom data';
    // }
}