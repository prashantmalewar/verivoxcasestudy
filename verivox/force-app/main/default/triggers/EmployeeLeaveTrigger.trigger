trigger EmployeeLeaveTrigger on Employee_Leave__c (before insert, before update) {

    if(Trigger.isBefore && Trigger.isInsert){
            EmployeeLeaveTriggerHandler.onBeforeInsert(Trigger.new);
    }

    if(Trigger.isBefore && Trigger.isUpdate){
        EmployeeLeaveTriggerHandler.onBeforeUpdate(Trigger.new,Trigger.oldMap);
    }
}