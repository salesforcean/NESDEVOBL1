trigger ProgramEnrollmentCriteriaTrigger on Program_Enrollment_Criteria__c (after update)  {
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
			ProgramEnrollmentCriteriaHandler.handleAfterUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
        }
    }
}