import { LightningElement,track,wire } from 'lwc';
import getRecordType from '@salesforce/apex/CaseRTSelection.getRecordType';
import { getObjectInfo} from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
export default class CaseRecordTypeSelectionInLWC extends LightningElement {
    @track selectedValue;
    @track recTypeData = [];
    @track openCaseTab;
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    getdefault({error,data}){
       if(data){
         // perform your custom logic here
         console.log('The Default RecordTypr',data.defaultRecordTypeId);
         this.selectedValue = data.defaultRecordTypeId;
       }else if(error){
           // perform your logic related to error 
        }
     }

    @wire(getRecordType)
    wiredResult(result) {
        if (result.data) {
            var returnValues = result.data;
            console.log('const',returnValues);
            this.recTypeData=returnValues;
            console.log('recTypeData>>24',this.recTypeData);

        }
    }

    handleChange(event) {
        this.selectedValue = event.target.value;
        console.log('The Selected Value',this.selectedValue);
    }


    @track isModalOpen = false;

    connectedCallback() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }
    submitDetails() {
        
        console.log('The Selected Value',this.selectedValue);
        this.openCaseTab = true;
        this.isModalOpen = false;
    }
}