import { LightningElement, api } from 'lwc';

export default class SendAnEmail extends LightningElement {
    @api recordId;
    value = 'new';

    get options() {
        return [
            { label: 'None', value: '' },
            { label: 'Closed', value: 'closed' },
            { label: 'New', value: 'new' },
            { label: 'Customer Replied', value: 'customerReplied' },
            { label: 'New', value: 'new' },
            { label: 'Pending Client Info/Action', value: 'pendingClientAction' },
            { label: 'New-Transferred', value: 'newTransferred' },
            { label: 'In Progress', value: 'inProgress' },
            { label: 'Pending Internal Replay', value: 'pendingInternalReplay' },
        ];
    }
}