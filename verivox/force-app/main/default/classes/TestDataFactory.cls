public class TestDataFactory {
    public static List<Employee__c> createEmployees(Id userId, Integer count){
        List<Employee__c> empList = new List<Employee__c>();
        
        while(count-- != 0){
            Employee__c emp = new Employee__c();
            emp.Employee__c = userId;
            empList.add(emp);
        }
        
        return empList;
    }
    
    public static List<Employee_Vacation_Allocation__c> createEmployeeVacations(Id employeeId, Integer count){
        List<Employee_Vacation_Allocation__c> vacationList = new List<Employee_Vacation_Allocation__c>();

        while(count-- != 0){
            Employee_Vacation_Allocation__c vacation = new Employee_Vacation_Allocation__c();
            vacation.Employee__c = employeeId;
            vacation.Number_of_Days__c = 20;
            vacation.Expiry__c = System.today().addDays(100);
            vacation.Status__c = 'Active';
            vacationList.add(vacation);
        }
        
        return vacationList;
    }
    
    public static List<Employee_Leave__c> createEmployeeLeaves(Id employeeId, Integer startAddDays,Integer endAddDays,Integer count){
        List<Employee_Leave__c> leaveList = new List<Employee_Leave__c>();

        while(count-- != 0){
            Employee_Leave__c leave = new Employee_Leave__c();
            leave.Employee__c = employeeId;
            leave.Start_Date__c = System.today().addDays(startAddDays);
            leave.End_Date__c = System.today().addDays(endAddDays);
            leave.Type__c = 'LeaveTest';
            leaveList.add(leave);
        }
        
        return leaveList;
    }
}