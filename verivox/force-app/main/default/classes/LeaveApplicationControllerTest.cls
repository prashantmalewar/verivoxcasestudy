@IsTest
public class LeaveApplicationControllerTest {
	@testSetup static void setup() {
        List<Employee__c> empList= TestDataFactory.createEmployees(UserInfo.getUserId(),1);
       	INSERT empList;
        
        List<Employee_Vacation_Allocation__c> vacationList = TestDataFactory.createEmployeeVacations(empList[0].Id,1);
        INSERT vacationList;
        
        List<Employee_Leave__c> leaveList = TestDataFactory.createEmployeeLeaves(empList[0].Id,1,4,1);
        INSERT leaveList;
       
    }
    
    @isTest static void getVacationSummaryTest() {
              
        Test.startTest();
        	String vacationSummary = LeaveApplicationController.getVacationSummary( UserInfo.getUserId());
        Test.stopTest();
        
        List<LeaveApplicationController.Vacation> vacationSummaryList = (List<LeaveApplicationController.Vacation>)JSON.deserialize(vacationSummary, List<LeaveApplicationController.Vacation>.class);
        
        System.assert(!vacationSummaryList.isEmpty(),'Must have atleast one record!');
        System.assertEquals(vacationSummaryList[0].StartDate,System.today().addDays(1));
    }
    
    @isTest static void getEmployeeRecordTest() {
        
        Test.startTest();
        	String employeeStr = LeaveApplicationController.getEmployeeRecord( UserInfo.getUserId());
        Test.stopTest();
        
        Employee__c employee = (Employee__c)JSON.deserialize(employeeStr, Employee__c.class);
        
        List<Employee__c> empList = [SELECT ID FROM Employee__c WHERE Employee__c = : UserInfo.getUserId()];
        
        System.assert(employee != NULL,'Must have atleast one record!');
        System.assertEquals(employee.Id,empList[0].ID);
    }
    
    @isTest static void getLeaveTypesTest() {
        List<Employee_Leave__c> leaveList = [SELECT ID FROM Employee_Leave__c WHERE Type__c = 'LeaveTest'];
        leaveList[0].Status__c = 'Approved';
        UPDATE leaveList;
        
        Test.startTest();
        	List<String> typeList = LeaveApplicationController.getLeaveTypes();
        Test.stopTest();
        
        System.assert(typeList != NULL,'Must have atlast one record!');
        System.assertEquals(typeList[0],'LeaveTest');
    }
    
}