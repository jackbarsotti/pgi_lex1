import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class SalesLoftImportContactLEX_LWC extends NavigationMixin(LightningElement) {
    @api recordId;

    connectedCallback() {
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://app.salesloft.com/app/import/crm?contact='+ this.recordId
            }
        },
        false // Replaces the current page in your browser history with the URL
      ).then(url => { window.open(url) });
    }
}