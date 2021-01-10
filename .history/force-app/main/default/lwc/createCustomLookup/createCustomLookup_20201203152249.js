
import { LightningElement, api, track } from 'lwc';
//import fetchLookUpValues from '@salesforce/apex/CreateTourOnLeadController.fetchLookUpValues';
//import fetchExtendedLookUpValues from '@salesforce/apex/CreateTourOnLeadController.fetchExtendedLookUpValues';
import fetchFilterredLookUpValues from '@salesforce/apex/CreateTourOnLeadController.fetchFilterredLookUpValues';

export default class liCreateCommercialCustomLookup extends LightningElement {
    @api objectApiName ;
    @api iconName = 'standard:account';
    @api label = 'Lookup';
    @api controlId = null;
    @api fields = null;
    @api filter = null;
    @api isRequired;
    @api allowCreateNew = false;
    @api fieldsToQuery;
    @api isPreferredHotelLookup = false;
    @api ownerResults = false;
 
    @track resultClass;
    @track selectedRecord = null;
    @api selectedparentrec = null;
    @track results = null;
    @track message = null;
    @track showSpinner = false;
    @track lastSearchValue;
    @track required = false;
    

    get showNewBtn(){
        return this.allowCreateNew === "true" || this.allowCreateNew ? true : false;
        
    }

    @api 
    checkValidity(){
        return this.isRequired === "true" ? (this.selectedRecord && this.selectedRecord != null && this.selectedRecord.Id ? true : false) : true;
    }

    @api 
    reportValidity(){
        if(!this.checkValidity()){
            const input = this.template.querySelector('c-ux-debounced-input-c-c');
            //debugger;
            return input.reportValidity();
        }
        return null;
    }
    connectedCallback(){
        console.log('--888888888inside constructor',this.selectedparentrec);
        if(this.selectedparentrec && typeof(this.selectedparentrec) === "string" && this.selectedparentrec.length > 2){
            //this.handleRecordSelect(JSON.parse(this.selectedparentrec));
            //this.selectedRecord = JSON.parse(this.selectedparentrec);
        }
    }
    constructor() {
        super();
        this.switchResult(false);
       
    }
 
    handleSearchTerm(event) {
        let searchValue = event.detail;
        if (searchValue) {
            this.switchResult(true);
            this.message = 'Searching...';
            this.showSpinner = true;
            console.log('->>>>>>searchValue'+searchValue);
            console.log('->>>>>>this.objectApiName'+this.objectApiName);
            //console.log('->>>>>>this.fieldsToQuery '+this.fieldsToQuery);
            let searchParams = {
                searchKeyWord: searchValue,
                objectName: this.objectApiName,
             //   fieldsToQuery : this.fieldsToQuery,
                filter : this.filter
            };
            this.addFieldsToParam(searchParams);
            fetchFilterredLookUpValues(searchParams)
                .then(result => this.setResult(result))
                .catch(error => this.handleError(error));
        } else {
            this.switchResult(false);
            this.message = null;
            this.showSpinner = false;
            this.results = null;
        }
        this.lastSearchValue = searchValue;
    }
 
    /* Ensure we always have Name and Id in the query */
    addFieldsToParam(searchParam) {
        let allFields = this.fields.split(',');
        allFields.push('Id');
        allFields.push('Name');
      //  allFields.push('LastName')

        let cleanFields = this.dedupeArray(allFields).join(',');
        searchParam.fieldsToQuery = cleanFields;
    }
 
    dedupeArray(incoming) {
        var uniqEs6 = arrArg => {
            return arrArg.filter((elem, pos, arr) => {
                return arr.indexOf(elem) === pos;
            });
        };
        return uniqEs6(incoming);
    }
 
    setResult(newValues) {
        this.showSpinner = false;
        if (newValues && newValues.length > 0) {
            this.message = null;
            this.results = newValues;
        } else {
            this.message = 'No results found';
        }
    }
 
    /* Shows and hides the result area */
    switchResult(on) {
        this.resultClass = on
            ? 'slds-form-element slds-lookup slds-is-open'
            : 'slds-form-element slds-lookup slds-is-close';
    }
 
    handlePillRemove() {
        console.log('main remove');
        this.selectedRecord = null;
        let payload = {
            detail: {
                controlId: this.controlId,
                canceled: true,
                recordId: null
            }
        };
        let selected = new CustomEvent('selection', payload);
        this.dispatchEvent(selected);
        // Restore last results
        this.switchResult(this.lastSearchValue && this.results);
        this.lastSearchValue = '';
    }
 
    handleError(error) {
        this.showSpinner = false;
        this.message = "Sorry didn't work!";
        let errorDispatch = new CustomEvent('failure', { detail: error });
        this.dispatchEvent(errorDispatch);
    }
    @api
    prepopulate(valueObj){
        if(valueObj){
            this.handleRecordSelect({detail:valueObj});
            //this.switchResult(true);
        }
    }
    handleRecordSelect(event) {
        let record = event.detail;
        console.log('====handleRecordSelect'+JSON.stringify(record));
        this.selectedRecord = record;
        let selectionDispatch = new CustomEvent('recordselected', {
            controlId: this.controlId,
            detail: record
        });
        this.dispatchEvent(selectionDispatch);
        this.switchResult(false);
        this.lastSearchValue = null;
    }
    handleNewClick(){
        
        let payload = {
            detail: {
                controlId: this.controlId,
                isCreateNew: true,
                filter: this.filter,
                populateFields: {} 
            }
        };
        let createNew = new CustomEvent('createnew', payload);
        this.dispatchEvent(createNew);
        this.switchResult(false);
    }
}