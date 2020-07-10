import { LightningElement, api ,track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class IContractLex extends NavigationMixin (LightningElement) {
    @api recordId;
    
      get Url(){
        return '/apex/iContract_NA_Master?id='+this.recordId;
         
    }
}