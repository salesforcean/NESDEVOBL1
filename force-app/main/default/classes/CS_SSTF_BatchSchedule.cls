/***************************************************************************************************************************************
* Name: CS_SSTF_BatchSchedule
****************************************************************************************************************************************
* Author: Sai rakesh Puli
* Purpose: This is a Schedulable class for CS_SSTFPermissionBatch .
* User Story # 176990 
* Task # 177183 
* Created Date: 05/9/2020
****************************************************************************************************************************************/

global class CS_SSTF_BatchSchedule implements Schedulable{
global void execute(SchedulableContext ctx) {
        CS_SSTFPermissionBatch sstf=new CS_SSTFPermissionBatch();
        Database.executeBatch(sstf,200);
    }
}