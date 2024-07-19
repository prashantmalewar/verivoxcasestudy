public class Util {
    public static final String WEEKEND_DAYS = 'sun;sat';

    public Static Integer getValidHolidaysBetween(Date startDate, Date endDate){
           
        Integer count = 0;
        List<Holiday> holidays = new List<Holiday>([SELECT Id, Name,  ActivityDate 
                                                    FROM Holiday
                                                    WHERE ActivityDate >= :startDate
                                                    AND ActivityDate <= :endDate
                                                    AND IsRecurrence = false
                                                    ]);
                                                    
        for(Holiday h: holidays){
            if(!isInWeekend(h.ActivityDate)){
                count++;
            }
        }

        return count;
    }

    public Static Integer getWorkingDaysBetween(Date startDate, Date endDate, Boolean includeStartDate){
         
        Integer count = 0;

        Integer totalDays = startDate.daysBetween(endDate);

        if(includeStartDate){
            totalDays++;
        }

        for(integer i=0; i < totalDays; i++){

            if(!isInWeekend(startDate + i)){  
                count++;  
            }       
        }

        return count;
    }

    public static Boolean isInWeekend(Date dateValue){

        DateTime dt = DateTime.newInstance(dateValue, Time.newInstance(0, 0, 0, 0));
        String dayOfWeek = dt.format('E').toLowerCase();

        return (WEEKEND_DAYS.contains(dayOfWeek) );
    }

    public static Integer calculateWorkingDays(Date StartDate, Date EndDate){

        Integer validHolidays = Util.getValidHolidaysBetween(StartDate, EndDate);    

        Integer workingDays = Util.getWorkingDaysBetween(StartDate, EndDate, TRUE);

        Integer days = workingDays - validHolidays;
		
        return days;
    }

    public static Boolean approvalActionRequest(Id recordId, String comment, Boolean isApproved){  
        
        Boolean isSuccess = false;

        List<ProcessInstance> piRecords = new List<ProcessInstance>([SELECT Id,Status,TargetObjectId FROM ProcessInstance where Status='Pending' and TargetObjectId = :recordId]);

        if(!piRecords.isEmpty()){
            List<ProcessInstanceWorkitem> piwRecords =  new List<ProcessInstanceWorkitem>([SELECT Id,ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId =:piRecords[0].Id]);

            Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();

            request.setComments(comment);

            if(isApproved){
                request.setComments(comment);
                request.setAction('Approve'); 
            }else{
                request.setComments(comment);
                request.setAction('Reject'); 
            }
            
            request.setNextApproverIds(new List<Id>{UserInfo.getUserId()});

            request.setWorkitemId(piwRecords[0].Id);

            if(!Test.isRunningTest()){
                Approval.ProcessResult result =  Approval.process(request);
            }

            isSuccess = true;
        }
        return isSuccess;
       
    }
}