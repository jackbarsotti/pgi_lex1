import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import AREA_OF_FOCUS_FIELD from '@salesforce/schema/Case.Area_of_Focus__c';

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

    @wire(getPicklistValues, { recordTypeId: '0121B000001hgNaQAI', fieldApiName: AREA_OF_FOCUS_FIELD })
    caseAreaOfFocus;

    get caseAreaOfFocusData() {
        return this.caseAreaOfFocus ?
                JSON.stringify(this.caseAreaOfFocus.data, null, 2) :
                'No area of interest data';
    }

    get recordTypeId() {
        // Returns a map of record type Ids 
        const rtis = this.objectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'Special Account');
    }
}