@IsTest
public class EmployeeLeaveTriggerHandlerTest {
	@testSetup static void setup() {
        List<Employee__c> empList= TestDataFactory.createEmployees(UserInfo.getUserId(),1);
       	INSERT empList;
        
        List<Employee_Vacation_Allocation__c> vacationList = TestDataFactory.createEmployeeVacations(empList[0].Id,1);
        INSERT vacationList;
    }
    
    @isTest static void onBeforeInsertTest() {
        List<Employee__c> empList = [SELECT ID FROM Employee__c WHERE Employee__c =:UserInfo.getUserId()];
        List<Employee_Leave__c> leaveList = TestDataFactory.createEmployeeLeaves(empList[0].Id,1,10,1);
        
        Test.startTest();
        	INSERT leaveList;
        Test.stopTest();
        
        List<Employee_Leave__c> newLeaveList = [SELECT ID, No_Of_Days__c,Status__c FROM Employee_Leave__c WHERE ID IN :leaveList];

        System.assert(newLeaveList[0].No_Of_Days__c >0, 'Must be greater than 2');
        System.assertEquals(newLeaveList[0].Status__c, 'In Progress', 'Updated by Approval Process');
    }
    
    @isTest static void onBeforeUpdate1Test() {
        List<Employee__c> empList = [SELECT ID FROM Employee__c WHERE Employee__c =:UserInfo.getUserId()];
        List<Employee_Leave__c> leaveList = TestDataFactory.createEmployeeLeaves(empList[0].Id,1,10,1);
        INSERT leaveList;
        
        Test.startTest();
        	leaveList[0].Status__c = 'Approved';
        	UPDATE leaveList;
        Test.stopTest();
        
        List<Employee_Leave__c> newLeaveList = [SELECT ID, No_Of_Days__c,Status__c,Employee__r.Vacation_Taken__c FROM Employee_Leave__c WHERE ID IN :leaveList];

        System.assert(newLeaveList[0].No_Of_Days__c >0, 'Must be greater than 2');
        System.assertEquals(newLeaveList[0].Status__c, 'Approved', 'Approved by default');
        System.assertEquals(newLeaveList[0].Employee__r.Vacation_Taken__c, newLeaveList[0].No_Of_Days__c, 'Vacation taken must be updated');
    }
    
    @isTest static void onBeforeUpdateTest() {
        List<Employee__c> empList = [SELECT ID FROM Employee__c WHERE Employee__c =:UserInfo.getUserId()];
        List<Employee_Leave__c> leaveList = TestDataFactory.createEmployeeLeaves(empList[0].Id,1,10,1);
        INSERT leaveList;
        
        Test.startTest();
        	leaveList[0].Start_Date__c = System.today().addDays(5);
        	leaveList[0].End_Date__c = System.today().addDays(15);
        	UPDATE leaveList;
        Test.stopTest();
        
        List<Employee_Leave__c> newLeaveList = [SELECT ID, No_Of_Days__c,Status__c,Employee__r.Vacation_Taken__c FROM Employee_Leave__c WHERE ID IN :leaveList];

        System.assert(newLeaveList[0].No_Of_Days__c >0, 'Must be greater than 2');
    }
}