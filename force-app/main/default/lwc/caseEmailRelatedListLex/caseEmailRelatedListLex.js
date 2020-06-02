import { LightningElement, wire , api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAllEmailMessage from '@salesforce/apex/CaseEmailRelatedListControllerLex.getAllEmailMessage';

/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 300;

export default class ApexWireMethodWithParams extends NavigationMixin(LightningElement) {
   // @api recordID;
   // @wire(getAllEmailMessage, { recordID: '$recordID' })
    searchKey = '5002900000C7OilAAF';
    @wire(getAllEmailMessage, { recordID: '$searchKey' })
    emailMessages;


        redirectToOutbound(event) {
            console.log('The value',event.target.id);
        let emailId = event.target.id;
         console.log('The value',emailId);
         console.log('The URl','/apex/OutboundEmailMessages?emailMsgId=' + emailId +'&ObjcaseId='+ this.searchKey);
        // this[NavigationMixin.GenerateUrl]({
        //     type: 'standard__webPage',
        //     attributes: {
                
        //         url: '/apex/OutboundEmailMessages?emailMsgId=' + emailId +'&ObjcaseId='+ this.searchKey
        //     }
        // }).then(generatedUrl => {
        //     window.open(generatedUrl);
        // });
    }
    
}