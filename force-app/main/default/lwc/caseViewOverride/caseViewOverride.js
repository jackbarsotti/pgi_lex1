import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';

export default class CaseViewOverride extends LightningElement {
    // Flexipage provides recordId and objectApiName
    @api recordId;
    @api objectApiName;

    @track objectInfo;

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    objectInfo;

    get objectInfoData() {
        return this.objectInfo ?
                JSON.stringify(this.objectInfo.data, null, 2) :
                'No object info';
    }

    get recordTypeId() {
        // Returns a map of record type Ids 
        const rtis = this.objectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'Special Account');
    }
}