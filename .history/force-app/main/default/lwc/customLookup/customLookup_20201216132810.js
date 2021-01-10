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
   

}