import { LightningElement ,wire, track } from 'lwc';
import getAccounts from'@salesforce/apex/AccountSearchController.getAccounts';
export default class CustomLookupComp extends LightningElement {
    @track accounName = '';
    @track accountList = [];
    @track objectApiName = 'Account';
    @track accountId;
    @track isshow = 'false';
    @track messageResult = False;
    @track isShowResult = true;
    @track showSearchParameter = False;



   sss



}