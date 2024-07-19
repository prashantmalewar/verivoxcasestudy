import { LightningElement, wire,track,api } from 'lwc';
import UserId from '@salesforce/user/Id';
import getVacationSummary from '@salesforce/apex/LeaveApplicationController.getVacationSummary';

export default class LeaveApplicationBody extends LightningElement {
    @track vacation;
    @track columns;
    @track allLeaves;
    @track approvedLeaves;
    @track inApprovalLeaves;
    @track draftRejectedLeaves;

    connectedCallback(){
        this.initConfiguration();
        this.initData();
    }

    initConfiguration(){
        this.columns = [
                            { label: 'Start', fieldName: 'StartDate',sortable: true },
                            { label: 'End', fieldName: 'EndDate',sortable: true },
                            { label: 'Type', fieldName: 'Type',sortable: true },
                            { label: 'Status', fieldName: 'Status',sortable: true },
                            { label: 'No of days', fieldName: 'NoOfDays',sortable: true }
                        ];
    }

    initData(){
        getVacationSummary({ userId: UserId })
          .then((result) => {
            this.processVacationSummary(result);
        })
        .catch((error) => {
            this.error = error;
        });
    }

    processVacationSummary(summary){
        this.allLeaves =  JSON.parse(summary);
        
        this.approvedLeaves = this.allLeaves.filter(leave =>  leave.Status =='Approved');
        this.inApprovalLeaves = this.allLeaves.filter(leave =>  leave.Status =='In Progress');
        this.draftRejectedLeaves = this.allLeaves.filter(leave =>  (leave.Status =='Not Approved' || leave.Status =='Draft'));
    }
}