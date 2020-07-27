import { LightningElement,track,wire ,api} from 'lwc';
import { getObjectInfo} from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import CASE_OBJECT from '@salesforce/schema/Case';
import getRecordType from '@salesforce/apex/CaseRTSelection.getRecordType';
export default class CaseRecordTypeSelectionInLWC extends NavigationMixin(LightningElement) {
    @track selectedValue;
    @track recTypeData = [];
    @track openCaseTab;
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    getdefault({error,data}){
       if(data){
         // perform your custom logic here
         console.log('The Default RecordTypr',data.defaultRecordTypeId);
         this.selectedValue = data.defaultRecordTypeId;
        //  const rtInfos = data.recordTypeInfos;
        //  let rtValues = Object.values(rtInfos);
        //  console.log('The Rt Values rtInfos',rtInfos);
        //  for(let i = 0; i < rtValues.length; i++) {
        //     if(rtValues[i].name !== 'Master') {
        //         console.log('The Rt Values Is',rtValues[i]);
        //     }
        // }
       }else if(error){
           // perform your logic related to error 
        }
     }

    @wire(getRecordType)
    wiredResult(result) {
        if (result.data) {
            console.log('TestIng for>>>>')
            var returnValues = result.data;
            console.log('const',returnValues);
            returnValues.forEach(ele =>{
                if(ele.Id === this.selectedValue){
                    this.recTypeData.push({Name:ele.Name,Id:ele.Id,Description:ele.Description,default:true});
                }
                else{
                    this.recTypeData.push({Name:ele.Name,Id:ele.Id,Description:ele.Description,default:false});
                }
            })
            //this.recTypeData=returnValues;
            console.log('recTypeData>>24',this.recTypeData);

        }
    }

    @api
    get defaultchecked() {
        return this.selectedValue;
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
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "Case",
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            },
        });
    }
    submitDetails() {
        
        console.log('The Selected Value',this.selectedValue);
        this.openCaseTab = true;
        this.isModalOpen = false;
    }
}