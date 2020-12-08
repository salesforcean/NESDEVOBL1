Global  class SSTFPublicGroupUserPermissionBatchSC implements Schedulable{
    global void execute(SchedulableContext ctx) {
        SSTFPublicGroupUserPermissionBatch gb=new SSTFPublicGroupUserPermissionBatch();
        Database.executeBatch(gb,200);
    }
}