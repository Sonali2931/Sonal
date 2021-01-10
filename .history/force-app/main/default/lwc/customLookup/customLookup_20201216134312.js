import lookUp from '@salesforce/apex/Lookup.Search';
import {api, LightningElement, track, wire } from 'lwc';

export default class CustomLookup extends LightningElement {
    @api objName;
    @api iconName;
    @api filter = '';
    @api SearchPlaceholder= 'Search';

    @track selectName;
    @track records;
    @track isValueSelected;
    @track blurTimeout;

   searchTerm;
   //css
   @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
   @track inputClass = '';
   @wire(lookUp, {searchTerm : '$searchTerm', myObject : '$objName', filter : '$filter'})
    wiredRecords({ error, data }) {
        if (data) {
            this.record = data;
            this.error = undefined;
            
        } else if (error) {
            this.error = error;
            this.record = undefined;

          OnBlur() {
this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
    




handleRemovePill() {
    this.isValueSelected = false;


onChange(event) {
    this.searchTerm = event.target.value;

}
          }