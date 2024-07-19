public with sharing class EmployeeLeaveUtility {
    
    public static Boolean isValidLeaveRange(Id UserId, Date startDate, Date endDate){

        Boolean isValid = false;
        List<Employee_Leave__c> employeeLeaves = [SELECT Id, Name, Start_Date__c, End_Date__c, Employee__c
                                                    FROM Employee_Leave__c
                                                    WHERE Employee__r.Employee__c = :UserId
                                                    AND (
                                                        (Start_Date__c >= :startDate
                                                        AND End_Date__c <= :startDate)
                                                        OR
                                                        (End_Date__c >= :endDate
                                                        AND End_Date__c <= :endDate)

                                                        OR
                                                        (Start_Date__c >= :startDate
                                                        AND End_Date__c <= :endDate)
                                                    )

                                                    AND Status__c IN ('Approved','In Progress')
                                                    ];


        if(employeeLeaves.isEmpty()){
            isValid = true;
        }

        return isValid;
    }
}

/*
System.debug('###### --- false '+ EmployeeLeaveUtility.isValidLeaveRange(UserInfo.getUserId(), Date.newInstance(2024,07,17),Date.newInstance(2024,07,24)));

System.debug('###### --- false '+ EmployeeLeaveUtility.isValidLeaveRange(UserInfo.getUserId(), Date.newInstance(2024,07,15),Date.newInstance(2024,07,28)));

System.debug('###### --- false '+ EmployeeLeaveUtility.isValidLeaveRange(UserInfo.getUserId(), Date.newInstance(2024,07,1),Date.newInstance(2024,07,26)));
System.debug('###### --- false '+ EmployeeLeaveUtility.isValidLeaveRange(UserInfo.getUserId(), Date.newInstance(2024,07,1),Date.newInstance(2024,07,28)));
System.debug('###### --- true '+ EmployeeLeaveUtility.isValidLeaveRange(UserInfo.getUserId(), Date.newInstance(2024,07,1),Date.newInstance(2024,07,5)));
System.debug('###### --- false '+ EmployeeLeaveUtility.isValidLeaveRange(UserInfo.getUserId(), Date.newInstance(2024,07,28),Date.newInstance(2024,08,5)));
System.debug('###### --- true '+ EmployeeLeaveUtility.isValidLeaveRange(UserInfo.getUserId(), Date.newInstance(2024,08,16),Date.newInstance(2024,08,20)));
*/