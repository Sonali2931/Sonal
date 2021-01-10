import { LightningElement,track,wire} from 'lwc';
import creatCase from '@salesforce/apex/caseRecordController.creatCase';


import  opportunity_Name from '@salesforce/schema/Opportunity.Name';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import 	Stage from '@salesforce/schema/Opportunity.StageName';
import 	LeadSource from '@salesforce/schema/Opportunity.LeadSource';
import 	Type from '@salesforce/schema/Opportunity.Type';




export default class CaseApp extends LightningElement {
   
        @track caseRecord =
        {
            
            opportunityName:opportunity_Name
        }
        handleStatusChange(event)
    {
      this.selectedcaseStatus = event.target.value;
    }
    
    
   
  
    handleNameChange(Event)
    {
        this.caseRecord.opportunity_Name=Event.target.value;
    }
    


    selectedOppStage;
    typeValues;
        @wire(getPicklistValues,
             { recordTypeId: '012000000000000AAA', 
             fieldApiName:Stage})
             typeValues;
         handleStageChange(event)
              {
                  this. selectedOppStage = event.target.value;
              }
    
     selectedOppType;
     typeValues1;
        @wire(getPicklistValues,
        { recordTypeId: '012000000000000AAA', 
                 fieldApiName: Type})
                 typeValues1;
                 handleTypeChange(event)
                 {
                    this.selectedOppType = event.target.value;
                 }
              
    selectedLeadSource;
    typeValues2;
        @wire(getPicklistValues,
        { recordTypeId: '012000000000000AAA', 
                 fieldApiName: LeadSource})
                 typeValues2;
                    handleLeadChange(event)
                      {
                        this.selectedLeadSource = event.target.value;
                      }        
      
    

 handelSaveCase()
       {
       creatCase({caseRecObj:this.caseRecord})
        .then(result=>{
        this.caseRecord={};
        const toastEvent =new ShowToastEvent(
            {
                title:'Success!',
                message:'Opportunity Created'
            }
        );
        this.dispatchEvent(toastEvent);
    })
    .catch(error=>
    {
        this.error=error.message;
    });

}


checkBoxFieldValue;
    checkBoxButtonFieldValue;

    handleCheckBoxChange(event){
        this.checkBoxFieldValue = event.target.checked;
    }
    
    



    textFieldValue;
    handleTextChange(event)
    {
    this.textFieldValue = event.target.value;

    }

    
   
    
    selectedRecordId; //store the record id of the selected 
    handleValueSelcted(event) {
        this.selectedRecordId = event.detail;
    }
    validateLookupField() {
        this.template.querySelector('c-custom-lookup').isValid();
}





}