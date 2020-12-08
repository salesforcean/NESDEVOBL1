/***************************************************************************************************************************************
* Name: CS_SSTF_PUBLICGRPUSR_KM_BatchSchedule
****************************************************************************************************************************************
* Author: Guravaiah Gunturi
* Purpose: This is a Schedulable class for CS_SSTFPublicGroupUserPermissionBatch .
* User Story: # 183264 
* Task: # 183930
* Created Date: 05/10/2020
****************************************************************************************************************************************/

Global class CS_SSTF_PUBLICGRPUSR_KM_BatchSchedule implements Schedulable{
    global void execute(SchedulableContext ctx) {
        CS_SSTFPublicGroupUserPermissionBatch gb=new CS_SSTFPublicGroupUserPermissionBatch();
        Database.executeBatch(gb,200);
    }
}