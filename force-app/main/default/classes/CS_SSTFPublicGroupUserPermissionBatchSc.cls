Global class CS_SSTFPublicGroupUserPermissionBatchSc implements Schedulable{
    global void execute(SchedulableContext ctx) {
        CS_SSTFPublicGroupUserPermissionBatch gb=new CS_SSTFPublicGroupUserPermissionBatch();
        Database.executeBatch(gb,200);
    }
}