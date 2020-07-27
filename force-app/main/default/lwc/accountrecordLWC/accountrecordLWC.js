import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccountDetails from '@salesforce/apex/accountrecordsat.getAccountDetails';
import { getRecord } from 'lightning/uiRecordApi';
import createopp from '@salesforce/apex/accountrecordsat.createopp';
//import getExperiments from '@salesforce/apex/accountrecordsat.getExperiments';



import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';



export default class accountrecordLWC extends LightningElement {
    @api recId;
    @api accounts;
    @track error;
    @track name;
    @track accname;
    @api opps;
    @track opportunityname;
    @track showpill = false;
    @track experiments = [];
    @track value = ["Option1"];
    userid = USER_ID;




    connectedCallback() {

        this.showpill = true;

        getAccountDetails({ accid: this.recId })
            .then(result => {
                this.accounts = result;
                console.log(result.Id);
                this.error = undefined;
                console.log(this.recId);
            }).catch(error => {
                this.error = error;
                this.accounts = undefined;

            })


        // getExperiments()
        //     .then(result => {
        //         console.log('inside experiments');
        //         if (result) {
        //             var conts = result;
        //             console.log('inside experiments', conts);

        //             for (var key in conts) {
        //                 console.log('this is key', key);
        //                 this.experiments.push({ value: conts[key], key: key });
        //             }
        //         }
        //     }).catch(error => {
        //         this.error = error;
        //         this.accounts = undefined;

        //     })







    }
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            console.log('inside data');
            this.name = data.fields.Name.value;
            console.log(this.name);
        }
    }





    save() {

        const element = this.template.querySelector('[data-id="oppname"]').value;
        console.log('oppnames', element);
        this.opportunityname = element;


        createopp({ accidt: this.recId, oppname: this.opportunityname })
            .then(result => {

                this.opps = result.Id;
                console.log('hhhh', this.opps);

                console.log(JSON.stringify(result));
                this.error = undefined;
                console.log(this.recId);

                const value = this.opps;
                console.log("hello", this.opps);
                const save = new CustomEvent("save", {
                    detail: { value }
                });
                this.dispatchEvent(save);


            }).catch(error => {
                this.error = error;
                this.opps = undefined;


            })


    }
    cancel() {
        this.dispatchEvent(new CustomEvent('close'));
    }


    handleRemove() {
        this.showpill = false;

    }
    handleChanges() {

    }

}