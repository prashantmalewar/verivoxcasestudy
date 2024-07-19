import { LightningElement,api,wire,track } from 'lwc';
import LightningPrompt from 'lightning/prompt';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import UserId from '@salesforce/user/Id';

import getLeaveRecord from '@salesforce/apex/LeaveApplicationController.getLeaveRecord';
import approvalActionRequest from '@salesforce/apex/LeaveApplicationController.approvalActionRequest';

export default class ApprovalModal extends LightningElement {

    @api recordId;
    @track leaveDetails;

    disableButton = false;

    @wire (getLeaveRecord) 
    getLeaveRecord(){

        getLeaveRecord({ leaveId: this.recordId })
          .then((result) => {
            this.processLeaveResponse(result);
        })
        .catch((error) => {
            this.error = error;
        });
    }


    processLeaveResponse(result){
        this.leaveDetails = result[0];
        this.disableActions = this.checkRightApprover();
    }

    get getNewRemainingVacation(){
        let newRemainingVacation = this.leaveDetails.Employee__r.Active_Vacation_Alloted__c - (this.leaveDetails.No_Of_Days__c + this.leaveDetails.Employee__r.Vacation_Taken__c);
        return newRemainingVacation;
    }

    get checkRightApprover(){
        return this.leaveDetails.Employee__r.Employee__r.ManagerId != UserId;
    }

    approveRecord(event){
        LightningPrompt.open({
            message: 'Comment',
            label: 'Comment'
        }).then((result) => {
            approvalActionRequest({ leaveId: this.recordId , comment: result, isApproved: true})
            .then((result) => {
                this.disableActions = true;
                this.showToast('Approved! ','success', 'Approval Successfully');
                
            })
            .catch((error) => {
                this.showToast('Failed!','error', 'Approval Failed! Contact Admin');
            });
        }).catch(
            (error) => {
                console.log(error);
            }
        );
    }

    rejectRecord(event){
        LightningPrompt.open({
            message: 'Comment',
            label: 'Comment'
        }).then((result) => {
            approvalActionRequest({ leaveId: this.recordId , comment: result, isApproved: false})
            .then((result) => {
                this.disableActions = true;
                this.showToast('Approved! ','success', 'Approval Successfully');
                
            })
            .catch((error) => {
                this.showToast('Failed!','error', 'Approval Failed! Contact Admin');
            });
        }).catch(
            (error) => {
                console.log(error);
            }
        );
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

}