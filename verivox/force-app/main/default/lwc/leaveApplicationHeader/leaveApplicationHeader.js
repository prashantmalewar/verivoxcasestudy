import { LightningElement , wire} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import AddLeave from 'c/addLeaveModal';

import UserId from '@salesforce/user/Id';
import UserNameFIELD from '@salesforce/schema/User.Name';
import getEmployeeRecord from '@salesforce/apex/LeaveApplicationController.getEmployeeRecord';

export default class LeaveApplicationHeader extends LightningElement {
    USER_NAME ;

    vacationAllowted = 0;
    vacationTaken = 0;
    vacationRemaining =  0;

    @wire(getRecord, { recordId: UserId, fields: [UserNameFIELD]}) 
    userInfo({error, data}) {
        if (data) {
            this.USER_NAME = data.fields.Name.value;

        } else if (error) {
            this.error = error ;
        }
    }

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
        let employeeRecord = JSON.parse(result);
        this.vacationAllowted = employeeRecord.Active_Vacation_Alloted__c;
        this.vacationTaken = employeeRecord.Vacation_Taken__c;  
        this.vacationRemaining =   this.vacationAllowted -    this.vacationTaken;
    }

    async  handleAddLeave(){
        const result = await AddLeave.open({
            size: 'small'
        });
    }
    
}