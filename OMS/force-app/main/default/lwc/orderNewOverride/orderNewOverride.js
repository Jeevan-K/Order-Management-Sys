import { LightningElement, track } from 'lwc';

export default class NewOverride extends LightningElement {
    @track orderId;
    handleSuccess(event)
    {
        this.orderId = event.detail.id;
        console.log(this.orderId);
        alert("Order Created Successfully");
        location.reload();
    }

    handleSubmit(event) {
        //console.log(hi);
        // event.preventDefault(); // stop the form from submitting
        // const fields = event.detail.fields;
        // console.log(JSON.stringify(fields));

        // fields.title = 'VP of Opearations';
        // fields.MobilePhone = '2123123123213';
        // fields.LeadSource = 'Web';
        // this.template.querySelector('lightning-record-edit-form').submit(fields);
    }
}