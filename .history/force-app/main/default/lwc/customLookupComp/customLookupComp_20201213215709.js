import { LightningElement ,wire, track } from 'lwc';
import getAccounts from'@salesforce/apex/AccountSearchController.getAccounts';
export default class CustomLookupComp extends LightningElement {
    @track accounName = '';
    @track accountList = [];
    @track objectApiName = 'Account';
    @track accountId;


   



}