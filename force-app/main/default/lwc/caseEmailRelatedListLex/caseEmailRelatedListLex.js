import { LightningElement, wire } from 'lwc';
import getAllEmailMessage from '@salesforce/apex/CaseEmailRelatedListControllerLex.getAllEmailMessage';

/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 300;

export default class ApexWireMethodWithParams extends LightningElement {
    searchKey = '5002900000C7OilAAF';

    @wire(getAllEmailMessage, { searchKey: '$searchKey' })
    emailMessages;
}