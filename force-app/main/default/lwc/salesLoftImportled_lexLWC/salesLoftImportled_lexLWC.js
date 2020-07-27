import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


export default class SalesLoftImportled_lexLWC extends NavigationMixin(LightningElement) {


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
        //     console.log(typeof (generatedUrl));
        //     var urlchange = decodeURIComponent(generatedUrl);
        //     var changedurl = urlchange.substring(19);
        //     console.log(changedurl);

        //     console.log(urlchange);
        //     window.open(changedurl);
        // });


        console.log('done redirecting');

    }


}