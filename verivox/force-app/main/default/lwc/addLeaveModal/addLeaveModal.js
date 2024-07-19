import { api, wire, track } from 'lwc';
import LightningModal from 'lightning/modal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import ObjectName from '@salesforce/schema/Employee_Leave__c';
import START_DATE_FIELD from '@salesforce/schema/Employee_Leave__c.Start_Date__c';
import END_DATE_FIELD from '@salesforce/schema/Employee_Leave__c.End_Date__c';
import TYPE_FIELD from '@salesforce/schema/Employee_Leave__c.Type__c';
import IS_SICK_FIELD from '@salesforce/schema/Employee_Leave__c.Is_Sick__c';

import UserId from '@salesforce/user/Id';
import getEmployeeRecord from '@salesforce/apex/LeaveApplicationController.getEmployeeRecord';
import getLeaveTypes  from '@salesforce/apex/LeaveApplicationController.getLeaveTypes';


import DEFAULT_LEAVE_TYPE_CLABEL  from '@salesforce/label/c.Default_Leave_Types';

export default class AddLeaveModal extends LightningModal {
    
    @track leaveTypes=[];
    @track employeeRecord;

    employeeId = "";
    leaveType = "";
    disableAllFields = false;
    isOtherTypeSelected = false;

    objectApiName = ObjectName;
    fields = [START_DATE_FIELD,END_DATE_FIELD,TYPE_FIELD,IS_SICK_FIELD];
    leaveDeafultValues ;

   
    @wire (getEmployeeRecord) 
    getEmployeeRecord(){

        getEmployeeRecord({ userId: UserId })
          .then((result) => {
            this.processEmployeeRecord(result);
        })
        .catch((error) => {
            this.error = error;
        });
    }

    processEmployeeRecord(result){
        this.employeeRecord = JSON.parse(result);
        this.employeeId = this.employeeRecord.Id;       
    }

    @wire (getLeaveTypes) 
    getLeaveTypes({error, data}) {
        if (data) {
            this.leaveTypes.push({label:'---Select---',value:''});
            data.forEach(selectVal => {this.leaveTypes.push({label:selectVal,value:selectVal})});
            (DEFAULT_LEAVE_TYPE_CLABEL.split(';')).forEach(selectVal => {this.leaveTypes.push({label:selectVal,value:selectVal})});
        } else if (error) {
            this.error = error ;
        }
    }

    onTypeChange(event) 
    {
        this.leaveType = event.target.value;
        console.log(this.leaveType);
        this.isOtherTypeSelected = (event.target.value == 'Other');   
        
        if(this.isOtherTypeSelected){
            this.leaveType = '';
        }
    }


    handleSubmitError(event){
        const errorDetail = event.detail;
        this.showToast('You hit a snag!',errorDetail.detail,  'error');
    }

    handleSubmitSuccess(event){
        this.disableAllFields = true;
        this.showToast('Yeppie!','Your vacation request is sumitted!',  'success');
    }

    showToast(title, message, type) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: type,
            mode: (type == 'error'? 'sticky':'dismissible ')
        });
        this.dispatchEvent(event);
    }  

    get showLeaveTypeClass(){
        return (this.isOtherTypeSelected? '' : 'slds-hide');
    
    }

}