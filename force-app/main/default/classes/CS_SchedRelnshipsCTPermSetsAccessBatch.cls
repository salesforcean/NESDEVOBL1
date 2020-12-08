/*
 * Developed By - Rakesh Ramaswamy (Ness Technologies)
 * Related User Story No. 164369
 * Description - This is a scheduler class to invoke the Relationship batch periodically based on the custom metadata type 
 *               definition defining the frequency in terms of every hour or specific time in a day or in terms of mins that the batch
 *               will need to be executed.
 */

global class CS_SchedRelnshipsCTPermSetsAccessBatch implements Schedulable {

    global static void scheduleMe(String CRON_EXPR) {
        System.schedule('CS_SchedRelnshipsCTPermSetsAccessBatch - '+String.valueOf(Math.abs(Crypto.getRandomLong())).substring(0, 5), CRON_EXPR, new CS_SchedRelnshipsCTPermSetsAccessBatch());
    }
    
    global void execute(SchedulableContext sc) {
        set<Id> studRecsIdSet = new set<Id>();
        Database.executeBatch(new CS_LCUserCTPermSetsAccessRelnshipBatch(studRecsIdSet), 50);
    } 
    
}