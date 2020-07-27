import { LightningElement, api } from 'lwc';

export default class Lookupuser extends LightningElement {
    @api childObjectApiName = 'Opportunity';
    @api targetFieldApiName = 'Opportunityuserlookup__c';
    @api fieldLabel = 'Opportunity Owner';
    @api disabled = false;
    @api value;
    @api required = false;

    handleChange(event) {
        const selectedEvent = new CustomEvent('valueselected', {
            detail: event.detail.value
        });
        this.dispatchEvent(selectedEvent);
    }

    @api isValid() {
        if (this.required) {
            this.template.querySelector('lightning-input-field').reportValidity();
        }
    }
}