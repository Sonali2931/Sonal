/* eslint-disable radix */
/* eslint-disable no-debugger */
/* eslint-disable vars-on-top */
/* eslint-disable @lwc/lwc/no-inner-html */
/* eslint-disable no-console */
/* eslint-disable no-undef */

import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
//import getLeadDetails from '@salesforce/apex/CreateTourOnLeadController.getLeadDetails';
import createTours from '@salesforce/apex/CreateTourOnLeadController.createTours';
import getTypeOptions from '@salesforce/apex/CreateTourOnLeadController.getTypeOptions';
import getStatusOptions from '@salesforce/apex/CreateTourOnLeadController.getStatusOptions';
import getChargeTypeOptions from '@salesforce/apex/CreateTourOnLeadController.getChargeTypeOptions';
import getRoomTypeOptions from '@salesforce/apex/CreateTourOnLeadController.getRoomTypeOptions';
import RELATIONSHIPSTATUS_FIELD from '@salesforce/schema/Case.Relationship_Status__c';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

const LEAD_FIELDS = ['Lead.FirstName', 'Lead.LastName', 'Lead.Phone','Lead.Phone3__c','Lead.Id','Lead.Email','Lead.Street','Lead.City',
'Lead.State','Lead.Country','Lead.PostalCode','Lead.RelationshipStatus__c',
'Lead.Tour_Age_of_Children__c','Lead.Tour_No_of_Children__c','Lead.TourLocation__c','Lead.TourLocation__r.Name',
'Lead.MeetsIncomeMinimum__c','Lead.MeetsAgeMinimum__c','Lead.OwnsaCreditCard__c'];
export default class CreateTourOnLead extends NavigationMixin(LightningElement) {
    @api recordId;
    @api tourTypeOptions;
    @api ChargeTypeOptions;
    @api RoomTypeOptions;
    @api tourStatusOptions;
    @api selectedContactRecord;
    //let selectRecordId;
    @track selectdAcc;
    @track selectdproduct;
    @track tourRecId;
    @track leadObj;
    @track isTourWave=false;
    @track activeSections = ['BookyourTour', 'premiums', 'demographic','Qualification'];
    @api todaysDate = new Date().toJSON().slice(0, 10);
    @track listOfTour = {
        fname: '',
        lname: '',
        gFname: '',
        gLname: '',
        relation: '',
        street: '',
        city: '',
        state: '',
        zip:'',
        phone: '',
        phone2: '',
        //phone3: '',
        email: '',
        relationshipStatus: '',
        noOfKids: '',
        tourType: '',
        tourDate: '',
        amount: '',
        ChargeType: '',
        RoomType: '',
        searchLookupId: '',
        tourTime:'',
        nights: 1,
        adults: 1,
        children: 0,
        age: '',
        quantity: 0,
        tourStatus: '',
        location: '',
        campaign:'',
    };
    relationshipStatusOptions;
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: RELATIONSHIPSTATUS_FIELD })
    propertyOrFunction({error, data}){
        if(data){
            let typeValues = [];
                typeValues.push({
                    label: '--None--',
                    value: ''
                });
                for (let i = 0; i < data.values.length; i++) {
                    typeValues.push({
                        label: data.values[i].label,
                        value: data.values[i].value
                    });
                }
                this.relationshipStatusOptions = typeValues;
        }else if(error){ console.log('picklist error'+ error);}
    }
    @wire(getRecord, { recordId: '$recordId', fields: LEAD_FIELDS }) //lead;
    getleadInfo({ error, data }){
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            console.log(message);
        } else if (data)  {
            this.lead = data;
            console.log('this.lead', this.lead);
            console.log('this.lead.TourLocation__c', this.lead.fields.TourLocation__c);
            let tourLocation = {
                Id: this.lead.fields.TourLocation__c.value,
                Name: this.lead.fields.TourLocation__r.displayValue
            };
            this.listOfTour = {
                fname: this.lead.fields.FirstName.value,
                lname: this.lead.fields.LastName.value,
                gFname: '',
                gLname: '',
                relation: '',
                street: this.lead.fields.Street.value,
                city: this.lead.fields.City.value,
                state: this.lead.fields.State.value,
                zip:this.lead.fields.PostalCode.value,
                phone: this.lead.fields.Phone.value,
                phone2: this.lead.fields.Phone3__c.value,
                //phone3: this.lead.fields.Phone3__c.value,
                email: this.lead.fields.Email.value,
                relationshipStatus: this.lead.fields.RelationshipStatus__c.value,
                meetsAgeMin: this.lead.fields.MeetsAgeMinimum__c.value,
                meetsIncomeMin: this.lead.fields.MeetsIncomeMinimum__c.value,
                ownsCreditCard: this.lead.fields.OwnsaCreditCard__c.value,
                noOfKids: this.lead.fields.Tour_No_of_Children__c.value,
                tourType: '',
                tourDate: '',
                amount: '50',
                ChargeType: '',
                RoomType: '',
                tourTime:'',
                tourwave:'',
                nights: '',
                adults: '',
                children: '',
                tourage: this.lead.fields.Tour_Age_of_Children__c.value,
                age: '',
                quantity: 0,
                tourStatus: '',
                searchLookupId: '',
                location: JSON.stringify(tourLocation)
                //selectdAcc : this.lead.fields.TourLocation__c.value,
            };
            console.log('location', this.listOfTour.location);
            debugger;
            //this.template.querySelector('[control-id="location"]').handleRecordSelect({detail:tourLocation});            
            [...this.template.querySelectorAll('c-create-custom-lookup')]
            .reduce((validSoFar, inputCmp) => {
                //inputCmp.reportValidity();
                console.log(inputCmp);
                debugger;
                if(inputCmp && inputCmp.controlId === "location" && tourLocation && tourLocation.Id && tourLocation.Name){
                    inputCmp.prepopulate(tourLocation);
                }
                return true;
            }, true);
        }
    }
    @track listofleads;
    @track listOfPremium = [];
    @track qty;
    @track isminivactour = false;
    @track disableAddBtn = true;
    @track prodRec = null;

    @track arrHead = [ 'Quantity', 'Product',''];
    @track openpremium = false;
    @track td;
    @track count = 0;
    @track room = 1;
    @track tableArr = [];
    @track prodId;
    @track hotelfilter = "RecordType.Name='Accommodation' AND IsOwner__c=true";
    @track inventoryfilter = "Product__r.RecordType.Name='Premium'";
    @track wavefilter = "Active__c=true";
    @track trdate;
    

    connectedCallback() {

        /*getLeadDetails({
            leadId: this.recordId
        }).then(result => {
            this.listofleads = JSON.stringify(result);
            console.log('listofleads', this.listofleads)
            this.leadObj = JSON.parse(this.listofleads);
            this.listOfTour = this.leadObj;
            // console.log('lstleads'+this.leadObj.name);
        });*/
        
        getTypeOptions({}).then(resultS => {
                let typeValues = [];
                typeValues.push({
                    label: '--None--',
                    value: ''
                });
                for (let i = 0; i < resultS.length; i++) {
                    typeValues.push({
                        label: resultS[i],
                        value: resultS[i]
                    });
                }
                this.tourTypeOptions = typeValues;
            })
            .catch(() => {

            })
        getStatusOptions({}).then(resultS => {
                let typeValues = [];
                typeValues.push({
                    label: '--None--',
                    value: ''
                });
                for (let i = 0; i < resultS.length; i++) {
                    typeValues.push({
                        label: resultS[i],
                        value: resultS[i]
                    });
                }
                this.tourStatusOptions = typeValues;
            })
            .catch(() => {

            })
        getChargeTypeOptions({}).then(resultS => {
                let typeValues = [];
                typeValues.push({
                    label: '--None--',
                    value: ''
                });
                for (let i = 0; i < resultS.length; i++) {
                    typeValues.push({
                        label: resultS[i],
                        value: resultS[i]
                    });
                }
                this.ChargeTypeOptions = typeValues;
            })
            .catch(() => {

            })
            getRoomTypeOptions({}).then(resultS => {
                let typeValues = [];
                typeValues.push({
                    label: '--None--',
                    value: ''
                });
                for (let i = 0; i < resultS.length; i++) {
                    typeValues.push({
                        label: resultS[i],
                        value: resultS[i]
                    });
                }
                this.RoomTypeOptions = typeValues;
            })
            .catch(() => {

            })
    }
    get showPremiumTable(){
        if(this.listOfPremium && this.listOfPremium.length > 0){
            return true;
        }
        return false;
    }
    get yesNoOptions(){
        return [{
            label: 'Yes',
            value: 'Yes'
            },
            {
                label: 'No',
                value: 'No'
            }];
    }
    handlelookupselectaccount(event) {
        //const field = event.target.name;
        // this.listOfTour=this.selectRecordId;        
        this.selectRecordId = event.detail;
        this.selectd = JSON.stringify(this.selectRecordId);
        this.selectdAcc = JSON.parse(this.selectd);
        this.listOfTour.searchLookupId = this.selectRecordId;
        this.listOfTour.location = this.selectdAcc;
        this.hotelfilter = "RecordType.Name='Accommodation' AND IsOwner__c=true";
        // AND TourLocation__c='"+this.selectdAcc.Id+"'";
        this.inventoryfilter = "Product__r.RecordType.Name='Premium' AND Product__r.IsActive = true AND Location__c='"+this.listOfTour.location.Id+"'";
        this.wavefilter = "Active__c=true AND TourLocation__c='"+this.selectdAcc.Id+"'" ;
        var dated =this.listOfTour.tourDate;
        if(this.selectdAcc.Id !== null || this.selectdAcc.Id !== undefined){
            console.log('main if')
           if(!dated){                  
            console.log('inside main if',this.listOfTour.tourDate);
                this.isTourWave =false;
            }else{
                this.isTourWave =true;
            }
        }else{
            this.isTourWave =false;
        }

        console.log('tourDate', this.listOfTour.tourDate);
        if( this.listOfTour.tourDate !== null || this.listOfTour.tourDate !== undefined){
            console.log('IFtourDate', this.listOfTour.tourDate);
            this.wavefilter = "Active__c=true "+ (this.selectdAcc && this.selectdAcc.Id ? "AND TourLocation__c='"+ this.selectdAcc.Id+"' ":"")+"AND TourDate__c ="+this.listOfTour.tourDate;
        }else{
            console.log('ElsetourDate', this.listOfTour.tourDate);
            this.wavefilter = "Active__c=true AND TourLocation__c='"+this.selectdAcc.Id+"'" ;
        }
       
        console.log('selectdId', this.selectdAcc.Id);
    }
    handleCampaignselect(event) {               
        this.selectRecordId = event.detail;
        this.selectCampaignstr = JSON.stringify(this.selectRecordId);
        this.selectedCampaign = JSON.parse(this.selectCampaignstr);
        this.listOfTour.campaign = this.selectedCampaign;
    }
    handlewaveselect(event) {
        // this.listOfTour=this.selectRecordId;        
        this.selectRecordId = event.detail;
        this.selectwavestr = JSON.stringify(this.selectRecordId);
        this.selectedwave = JSON.parse(this.selectwavestr);
        this.listOfTour.tourwave = this.selectedwave;
    }
    handlehotelselect(event){
        this.selectRecordId = event.detail;
        this.selectHotelstr = JSON.stringify(this.selectRecordId);
        this.selectedHotel = JSON.parse(this.selectHotelstr);
        this.listOfTour.accomodation = this.selectedHotel;
        //this.inventoryfilter = "Product__r.RecordType.Name='Premium' AND Location__c='"+this.listOfTour.location.Id+"'";
    }
    handlelookupselectProduct(event) {
        this.selectRecordId = event.detail;
        this.prodid = JSON.stringify(this.selectRecordId);
        this.selectdproduct = JSON.parse(this.prodid);
        console.log('selectdId', this.selectdproduct.Id);
        this.setAccessibilityOfAddBtn();
    }
    handleChange(event) {
        const field = event.target.name;
        console.log('fieldssssss',field)
        console.log('this.selectdAcc.iddd',this.listOfTour.location.id);
        console.log('selectedaccc',this.selectdAcc)
      
       if(field === 'tourDate'){  
        this.trdate = event.target.value;
       }
       console.log('trdate',this.trdate)
        //var dated =this.listOfTour.tourDate;
        if(this.trdate !== undefined || this.trdate !== 'undefined' || this.trdate !== null ){  
          //  var 
        if(this.selectdAcc === undefined || this.selectdAcc === 'undefined' || this.selectdAcc === null ){ 
            console.log('this.selectdAcc',this.selectdAcc);          
                this.isTourWave =false;
            }else{
                this.isTourWave =true;
            }
        }else if(this.trdate === null){
            this.isTourWave =false;
        }
        if (field === 'fname') {
            this.listOfTour.fname = event.target.value;
        } else if (field === 'lname') {
            this.listOfTour.lname = event.target.value;
        } else if (field === 'gFname') {
            this.listOfTour.gFname = event.target.value;
        } else if (field === 'gLname') {
            this.listOfTour.gLname = event.target.value;
        } else if (field === 'relation') {
            this.listOfTour.relation = event.target.value;
        } else if (field === 'street') {
            this.listOfTour.street = event.target.value;
        } else if (field === 'city') {
            this.listOfTour.city = event.target.value;
        } else if (field === 'state') {
            this.listOfTour.state = event.target.value;
        } else if (field === 'zip') {
            this.listOfTour.zip = event.target.value;
        } else if (field === 'phone') {
            this.listOfTour.phone = event.target.value;
        } else if (field === 'phone2') {
            this.listOfTour.phone2 = event.target.value;
        }else if (field === 'email') {
            this.listOfTour.email = event.target.value;
        } else if (field === 'relationshipStatus') {
            this.listOfTour.relationshipStatus = event.target.value;
        } else if (field === 'meetsAgeMin') {
            this.listOfTour.meetsAgeMin = event.target.value;
        } else if (field === 'meetsIncomeMin') {
            this.listOfTour.meetsIncomeMin = event.target.value;
        } else if (field === 'ownsCreditCard') {
            this.listOfTour.ownsCreditCard = event.target.value;
        } else if (field === 'noOfKids') {
            this.listOfTour.noOfKids = event.target.value;
        } else if (field === 'tourage') {
            this.listOfTour.tourage = event.target.value;
        } else if (field === 'tourDate') {
            this.listOfTour.tourDate = event.target.value;
            this.wavefilter = "Active__c=true "+ (this.selectdAcc && this.selectdAcc.Id ? "AND TourLocation__c='"+ this.selectdAcc.Id+"' ":"")+"AND TourDate__c ="+this.listOfTour.tourDate;
        }      
         else if (field === 'tourType') {
            this.listOfTour.tourType = event.target.value;
            this.isminivactour = this.listOfTour.tourType === "Minivac";
        } else if (field === 'amount') {
            this.listOfTour.amount = event.target.value ? event.target.value : '';
        } else if (field === 'tourTime') {
            this.listOfTour.tourTime = event.target.value;
        } else if (field === 'ChargeType') {
            this.listOfTour.ChargeType = event.target.value;
        }else if (field === 'RoomType') {
            this.listOfTour.RoomType = event.target.value;
        }
         else if (field === 'checkindate') {
            this.listOfTour.checkindate = event.target.value;
        } else if (field === 'nights') {
            this.listOfTour.nights = event.target.value;
        } else if (field === 'adults') {
            this.listOfTour.adults = event.target.value;
        } else if (field === 'children') {
            this.listOfTour.children = event.target.value;
        } else if (field === 'age') {
            this.listOfTour.age = event.target.value;
        } else if (field === 'quantity') {
            this.qty = event.target.value;
            this.setAccessibilityOfAddBtn();
        }
    }
    createTour(event) {
        var allValid = [...this.template.querySelectorAll('lightning-input, lightning-combobox, c-create-custom-lookup')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allValid && allValid === true) {
            const allproducts = JSON.stringify(this.listOfPremium);
            console.log('vluesss', allproducts);
            //this.listOfTour.searchLookupId = this.selectedContactRecord.Id;
            console.log('listOfTour', this.listOfTour);
            this.template.querySelector(".save").disabled = true;
            const listOfTourDatatoPass = JSON.stringify(this.listOfTour);
            console.log('listOfTourDatatoPass', listOfTourDatatoPass);
            console.log('this.selectdAcc', this.selectdAcc);
            createTours({
                    listOfTourDetails: listOfTourDatatoPass,
                    leadId: this.recordId,
                    accId: this.selectdAcc ? this.selectdAcc.Id: null,
                    productId: allproducts
                }).then(result => {
                    this.check = result;
                    console.log('check', this.check);
                    // View a custom object record.
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.check,
                            objectApiName: 'Account', // objectApiName is optional
                            actionName: 'view'
                        }
                    }, true);
                })
                .catch((err) => {
                    console.log('error'+JSON.stringify(err));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error Saving Tour',
                            message: err.body.message,
                            variant: 'error',
                        }),
                    );
                    this.template.querySelector(".save").disabled = false;
                });
        }
        //alert('Please update the invalid form entries and try again.');
        event.preventDefault();
        event.stopPropagation();
    }
    clearSearchValue(event) {
        //this.selectedContactRecord = undefined;
        if(!event || !event.detail){return;}
        console.log(JSON.stringify(event));
        if(event.detail.controlId === 'location'){
            this.hotelfilter = "RecordType.Name='Accommodation' AND IsOwner__c=true";
            this.inventoryfilter = "Product__c.RecordType.Name='Premium'";
        } else if(event.detail.controlId === 'inventory'){
            this.selectdproduct = null;
            this.qty = "0";
            this.setAccessibilityOfAddBtn();
        }
        //this.isTourWave =false; commented by AJ
    }
    setAccessibilityOfAddBtn(){
        if(this.qty && parseInt(this.qty) > 0 && this.selectdproduct && this.selectdproduct.Id){
            this.disableAddBtn = false;
        }else{
            this.disableAddBtn = true;
        }
    }

    addPremiumRow(){
        if(!this.selectdproduct || !this.selectdproduct.Id || !this.qty || parseInt(this.qty) < 1){
            return;
        }
        if(!this.listOfPremium){
            this.listOfPremium = [];
        }
        let doesNotExist = true;
        for(var idx = 0; idx < this.listOfPremium.length; idx++){
            let item = this.listOfPremium[idx];
            if(item.inventoryId === this.selectdproduct.Id){
                doesNotExist = false;
                item.quantity = item.quantity + parseInt(this.qty);
                this.listOfPremium[idx] = item;
            }
        }
        if(doesNotExist){
            this.listOfPremium.push({
                quantity: parseInt(this.qty),
                inventoryId: this.selectdproduct.Id,
                productId: this.selectdproduct.Product__c,
                locationId: this.selectdproduct.Location__c,
                product: this.selectdproduct.Name
            });
        }
        //reset input
        this.qty = "0";
        this.prodRec = null;
        this.setAccessibilityOfAddBtn();
    }
    deletePremium(event){
        let indx = event.target.name;
        this.listOfPremium = this.listOfPremium.filter(function(item,idx){ return idx !== indx;});
    }
}