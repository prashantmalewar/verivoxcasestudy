public with sharing class LeaveApplicationController {
    
    @AuraEnabled
    public static String getVacationSummary(Id userId){
        
        List<Vacation> vacations = new List<Vacation>();

        List<Employee_Leave__c> employeeLeave = new List<Employee_Leave__c>([SELECT Id, Start_Date__c, End_Date__c, Status__c, Type__c, Employee__c, Is_In_Current_Year__c ,No_Of_Days__c,Is_Sick__c
                                                                            FROM Employee_Leave__c
                                                                            WHERE Employee__r.Employee__c = :userId
                                                                            AND Is_In_Current_Year__c = TRUE
                                                                            Order By Start_Date__c DESC
                                                                            ]);
        
        for(Employee_Leave__c leave: employeeLeave){
            Vacation   vac = new Vacation();
            vac.LeaveId = leave.Id;
            vac.StartDate = leave.Start_Date__c;
            vac.EndDate = leave.End_Date__c;
            vac.Type = leave.Type__c;
            vac.Status = leave.Status__c;
            vac.NoOfDays = Integer.valueOf(leave.No_Of_Days__c);

            vacations.add(vac);
        }
        
        return JSON.serialize(vacations);
    }

    @AuraEnabled(cacheable=true)
    public static String getEmployeeRecord(Id userId){
        
        List<Employee__c> employee = new List<Employee__c>([SELECT ID, Active_Vacation_Alloted__c,Vacation_Taken__c , Employee__c  
                                                            FROM Employee__c 
                                                            WHERE Employee__c = :userId]);
        if(!employee.isEmpty()){
            return JSON.serialize(employee[0]);
        }
        return '{}';
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getLeaveTypes() {
        List<AggregateResult> aggrResult = new List<AggregateResult>([SELECT Type__c, count(Id)  
                                                                      FROM Employee_Leave__c 
                                                                      WHERE Status__c = 'Approved'
                                                                      Group By Type__c
                                                                     ]);
        
        List<String> leaveTypes = new List<String>();
        for (AggregateResult res : aggrResult) {

            leaveTypes.add(String.valueOf(res.get('Type__c')));
        }

        return leaveTypes;
    }

    @AuraEnabled(cacheable=true)
    public static List<Employee_Leave__c> getLeaveRecord(Id leaveId) {
        List<Employee_Leave__c> leaveRecords = new List<Employee_Leave__c>([SELECT ID, Start_Date__c,End_Date__c,Status__c, Type__c, Employee__c, Is_In_Current_Year__c ,No_Of_Days__c,Employee__r.Employee__r.Name,Employee__r.Employee__r.ManagerId,
                                                                            Employee__r.Active_Vacation_Alloted__c,Employee__r.Vacation_Taken__c
                                                                            FROM Employee_Leave__c
                                                                            WHERE Id = :leaveId
                                                                            ]);
        return leaveRecords;
    
    }

    @AuraEnabled
    public static void approvalActionRequest(Id leaveId, String comment, Boolean isApproved){
        Boolean isSuccess;
        try {
            isSuccess = Util.approvalActionRequest(leaveId,comment,isApproved);

            if(!isSuccess){
                throw new AuraHandledException('Error occured while approving/rejecting record.');
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }    

    public class Vacation{
        @AuraEnabled
        public String  LeaveId {get;set;}

        @AuraEnabled
        public Date StartDate {get;set;}

        @AuraEnabled
        public Date EndDate {get;set;}

        @AuraEnabled
        public Integer NoOfDays {get;set;}

        @AuraEnabled
        public String Status {get;set;}

        @AuraEnabled
        public String Type {get;set;}
    }   
}