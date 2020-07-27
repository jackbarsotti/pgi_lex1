import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


export default class salesLoftImportLead_LexLWC extends NavigationMixin(LightningElement) {
    @api recId;

    connectedCallback() {
        console.log(this.recId);
        window.open('https://app.salesloft.com/app/import/crm?contact=' + this.recId);


        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: 'https://app.salesloft.com/app/import/crm?contact=' + this.recId
        //     }
        // }).then(generatedUrl => {
        //     window.open(generatedUrl);
        // });

        console.log('done redirecting');
    }




}