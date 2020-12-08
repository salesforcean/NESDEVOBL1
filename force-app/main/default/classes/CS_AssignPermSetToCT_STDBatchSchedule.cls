/*
* Created by:  Sumanth B
* Created date: 2020-May-13
* User Story : 176990 (Task # 177184)
* Purpose: Its a schedule class for 'CS_AssignPermissionSetToCT_STDBatchJob' and the Batch Job handles the association of Student's School Permission Sets (SchoolName_CT & SchoolName_STD) 
		   to existing Caretakers and Students Users based on Program Enrollment Status = Complete 
* Change Log: 
*
*/

global class CS_AssignPermSetToCT_STDBatchSchedule implements Schedulable{

    global void execute(SchedulableContext sc) {
        CS_AssignPermissionSetToCT_STDBatchJob batchJob=new CS_AssignPermissionSetToCT_STDBatchJob();
        Database.executeBatch(batchJob,200);
    }
}