import { LightningElement, wire, api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';

import getPriceBookID from '@salesforce/apex/searchProductController.getPriceBookEntryID';
import getProducts from '@salesforce/apex/searchProductController.fetchProduct';
import getOrderSummary from '@salesforce/apex/searchProductController.getRelatedOrderItem';
import confirm_ord from '@salesforce/apex/searchProductController.confirmOrder';

const DELAY = 300;

export default class OrderCaptureScreen extends LightningElement {

    @track selectedOption='1';

    screenTitle="Add Products";

    @api searchKey_name = "";
    @api product_id;
    @api addIndex;
    @api unitprice;
    @api pricebookentryid;
    @api product_code;
    
    @track orderNumber;
    @track orderTotalPrice;
    @track orderTotalQuantity;
    orderPriceBookId;
    isShowFinalOrder=false;
    showConfirmOrder=false;
    currentOrderId;
   // message;
    products;
    noRecordsFound = false;
    isshow = false;
    isShowAdd = false;
    showSearch = true;
    @api relatedOrderItems;
    getPriceBookResult;


    
    @wire(getProducts,{searchKeyWord:'$searchKey_name',option:'$selectedOption'})
    wiredContacts({ error, data }) {
        if (data) {
            this.products = data;
            this.error = undefined;
            console.log("hi");
            console.log(JSON.stringify(data));
            //this.isshow=false;
                if(this.products.length>0){
                    this.noRecordsFound = false;
                    this.isshow = true;}
                else{
                    this.noRecordsFound = true;
                    this.isshow = false;
                }
        } else if (error) {
            this.error = error;
            this.products = undefined;
            console.log("not working"+error);
            this.noRecordsFound = true;
            this.isshow = false;
        }
    }

getOrderItem() {
    getOrderSummary({ordId:this.currentOrderId}).then(
        result=>{
            console.log("result received");
            console.log(JSON.stringify(result));
            this.relatedOrderItems = JSON.parse(JSON.stringify(result));
            if(this.relatedOrderItems.length>0){
                console.log(this.relatedOrderItems.length);
            this.orderNumber = this.relatedOrderItems[0].Order.OrderNumber;
            this.orderTotalPrice = this.relatedOrderItems[0].Order.TotalAmount;
            this.orderTotalQuantity = this.relatedOrderItems[0].Order.Order_Quantity__c;
            this.showConfirmOrder= true;
            }
            else{
                this.OrderNumber="No Orders";
                this.orderTotalPrice=0;
                this.orderTotalQuantity=0;
                this.showConfirmOrder=false;
            }
        }
        ).catch(error => {
        // display server exception in toast msg 
        const event = new ShowToastEvent({
            title: 'Error',
            variant: 'error',
            message: error.body.message,
        });
        this.dispatchEvent(event);
        // reset contacts var with null   
       // this.order = null;
        });
    }

    searchProduct(){
        if(this.error===undefined)
            this.isshow=true;
    }

    // qtyChanged(event){
    //     this.unitprice = 
    // }
    
    changeHandler(event) {
    const field = event.target.name;
    if (field === 'optionSelect') {
        this.selectedOption = event.target.value;
            //alert("you have selected : "+this.selectedOption);
        } 
    }

    // pricebookchange(event){
    //     this.pbeid = event.target.value;
    //     alert(this.pbeid+' Peicebook ID '+this.pricebookentryid);
    // }

    handleKeyNameChange(event) {
        // Debouncing this method: Do not update the reactive property as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        window.clearTimeout(this.delayTimeout);
        const searchKey_name = event.target.value;
        console.log("Name => "+searchKey_name);
        this.delayTimeout = setTimeout(() => {
            this.searchKey_name = searchKey_name;
        }, DELAY);
    
    }


    handleAdd(event)
    {
        console.log("Product Id : "+event.target.value);
        this.addIndex = event.target.value;
        //console.log(this.products[this.product_id].ProductCode);
        this.product_id = this.products[this.addIndex].Product2Id;
        this.unitprice = this.products[this.addIndex].UnitPrice;
        this.product_code = this.products[this.addIndex].ProductCode;
        this.orderPriceBookId = this.products[this.addIndex].Id;

        //alert('Price book ID '+this.orderPriceBookId);
        
        //this.pricebookentryid = this.products[this.addIndex].Id;
        //alert(' index Id '+this.pricebookentryid);
       // this.pricebookentryid = this.products[this.addIndex].Id;
       // alert('Values found '+this.product_id+' MRP '+this.unitprice);
        this.isShowAdd = true;
        this.isshow = false;
    }

    handleRemove(event)
    {
        deleteRecord(event.target.value).then(
            result=>{
                console.log(result);
                this.getOrderItem();
                //alert("Deleted succesfully");              
            }
        ).catch(error => {
            // display server exception in toast msg 
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: error.body.message,
            });
            this.dispatchEvent(event);
            // reset contacts var with null   
           // this.order = null;
        });
       // this.handleContinueHelper();
      
    }

    handleSuccess(event)
    {
        const updatedRecord = event.detail.id;
        //alert('Success');
        //alert('ID is'+this.currentOrderId); 
        //alert('look up id '+this.pbeid+' index Id '+this.pricebookentryid);
        console.log('onsuccess: ', updatedRecord); 
        this.isShowAdd = false;
        const evt = new ShowToastEvent({
            title: 'Saved',
            message: 'Order Product Added Successfully',
            variant: 'success',
        });
        this.dispatchEvent(evt);
        this.isshow = false;
        this.isShowFinalOrder = true; 
         this.screenTitle = "Order Summary";
        this.showSearch = false;
        this.getOrderItem();
    }

    saveOrderID(event){
        this.currentOrderId = event.target.value;
        //alert('Current Order Id is '+this.currentOrderId);
        getPriceBookID({ prdctCode:this.product_id,ordId:this.currentOrderId }).then(
            result=>{
                console.log("result received");
                console.log(JSON.stringify(result));
                this.pricebookentryid = JSON.parse(JSON.stringify(result));
                console.log('Price Book Entry ID is '+this.pricebookentryid+' From array '+this.orderPriceBookId);
                //this.pricebookentryid = this.getPriceBookResult[1].Id;
            
            }
            ).catch(error => {
                        // display server exception in toast msg 
                        const event = new ShowToastEvent({
                            title: 'Error',
                            variant: 'error',
                            message: error.body.message,
                        });
                        this.dispatchEvent(event);
                        });
    }

    handleError(event) {
        //alert('Error');
        console.log("handleError event");
        console.log(JSON.stringify(event.detail));
        const msg = JSON.parse(JSON.stringify(event.detail)).detail;
        console.log('Error detail is '+msg);
        //alert('look up id '+this.pbeid+' index Id '+this.pricebookentryid);
        //this.isShowAdd = false;
        const evt = new ShowToastEvent({
            title: 'Error',
            message: msg,
            variant: 'error',
        });
        this.dispatchEvent(evt);
       // errMsg = event.detail;
        //console.log(errMsg.output);
    }

    handleClose(event)
    {
        this.isShowAdd = false;
        const evt = new ShowToastEvent({
            title: 'Order Product Creation Cancelled',
            variant: 'info',
        });
        this.dispatchEvent(evt);
    }

    cancelProduct(event){
        //location.reload();
        this.screenTitle = "Add Products";
        this.showSearch = true;
        this.isShowFinalOrder = false;
    }

    handleConfirmOrder(event){
        //alert('current Order Id '+this.currentOrderId);
        confirm_ord({ordId:this.currentOrderId}).then(
            result=>{
                console.log('Success updated '+result);
                const evt = new ShowToastEvent({
                    title: 'Confirmed',
                    message: 'Order Products Confirmed',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
            }).catch(
                error=>{
                    console.log('Error while confirming '+error.body.message);}
            );
            this.isShowFinalOrder = false;
            this.showSearch = true;
    }
}