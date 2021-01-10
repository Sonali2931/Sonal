import { LightningElement } from 'lwc';

export default class EproductDisplay extends LightningElement {
    import { LightningElement,track,wire } from 'lwc';
import getproduct from '@salesforce/apex/EproductDisplay.getproduct';
  
    @track productrecords;
    @track errors;
    @track columns = [{label: 'Product Name', fieldName: 'Name', type: 'text'}];
    @wire(getproduct)
    getwiredproduct({error, data})
    {
        if (data) {
            this.productrecords = data;
            this.error = undefined;
            console.log(this.productrecords +'*');
        } else if (error) {
            this.error = error;
            this.record = undefined;
            console.log(this.error +'&&&');
        } 
    }
