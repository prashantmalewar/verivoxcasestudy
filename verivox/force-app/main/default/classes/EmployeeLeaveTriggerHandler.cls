public with sharing class EmployeeLeaveTriggerHandler {
    
    public static Map<Id,Employee__c> employeeMap;
    
    public static void onBeforeUpdate(List<Employee_Leave__c> newList, Map<Id,Employee_Leave__c> oldMap){
        List<Employee_Leave__c> updatedDatesLeaveList = new List<Employee_Leave__c>();
		List<Id> approvedLeaveIdList = new List<Id>();
        
        for(Employee_Leave__c leave : newList){
            Employee_Leave__c oldRecord = oldMap.get(leave.Id);
            if((leave.Start_Date__c != oldRecord.Start_Date__c ) || 
                (leave.End_Date__c != oldRecord.End_Date__c)){
                updatedDatesLeaveList.add(leave);
            }
            
            if((leave.Status__c != oldRecord.Status__c ) && leave.Status__c == 'Approved'){
                approvedLeaveIdList.add(leave.Id);
            }
        }

        if(!updatedDatesLeaveList.isEmpty()){
            validateLeavesForExistingLeave(newList);

            calculateLeaveDays(newList);
        }
        
        if(!approvedLeaveIdList.isEmpty()){
            syncLeaveWithExternalSystem(approvedLeaveIdList);
        }
        
    }

    public static void onBeforeInsert(List<Employee_Leave__c> newList){
        
        validateLeavesForExistingLeave(newList);

        calculateLeaveDays(newList);
    }

    public static void validateLeavesForExistingLeave(List<Employee_Leave__c> newList){
        setEmployeeMap(newList);
        
        for(Employee_Leave__c empLeave : newList){

            if(employeeMap.containsKey(empLeave.Employee__c)){
                Boolean isValid = EmployeeLeaveUtility.isValidLeaveRange(employeeMap.get(empLeave.Employee__c).Employee__c, empLeave.Start_Date__c,empLeave.End_Date__c);    
                
                if(!isValid){
                    empLeave.addError('Invalid Range! Please check your applied leaves');
                }
            }
        }
    }


    public static void calculateLeaveDays(List<Employee_Leave__c> newList){
        setEmployeeMap(newList);
        
        for(Employee_Leave__c empLeave : newList){
            empLeave.No_Of_Days__c = Util.calculateWorkingDays(empLeave.Start_Date__c, empLeave.End_Date__c);
        }
    }

    private static void setEmployeeMap(List<Employee_Leave__c> newList){
        if(employeeMap == NULL){
            Set<Id> employeeIds = new Set<Id>();
            
            for(Employee_Leave__c empLeave : newList){
                employeeIds.add(empLeave.Employee__c);
            }

            employeeMap = new Map<Id,Employee__c>([SELECT ID,Employee__c FROM Employee__c WHERE ID IN :employeeIds]);
        }
    }
    
    @future(callout=true)
    public static void syncLeaveWithExternalSystem(List<Id> approvedLeaveIds){
        /*
         * Step1: Refetch the record including details of parent Employee 
         *        Parent Employee should contain External Id as well
         * Step2: prepare valid JSON (Suggestion Wrapper Class)
         * Step3: Authenticate and invoke Rest callout
         * Step4: Process HttpResponse
         * 
		*/ 
    }
}