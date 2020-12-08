/*
 * Developed By - Rakesh Ramaswamy (Ness Technologies)
 * Related User Story No. 164369
 * Description - This is a scheduler class to invoke the Program Enrollment batch at a specific time of the day.
 *               This scheduler will be setup for executing at the specific time each day through the "Schedule Apex" feature on Salesforce Setup >> Apex Classes.
 */


global class CS_CTSTDLC_PE_RLTN_KM_BatchSchedule implements Schedulable {              

    global void execute(SchedulableContext sc) {

       Records_Processing_Intervals__mdt recordProcessInterval = [SELECT Batch_Size__c FROM Records_Processing_Intervals__mdt WHERE DeveloperName = :CS_Constants.LC_KBA_ACCESS_PROGENROLL_RECS_PROCESS];
       Integer batchSize = 200;
       if((recordProcessInterval.Batch_Size__c != null) && (recordProcessInterval.Batch_Size__c > 0)){
           batchSize = Integer.valueOf(recordProcessInterval.Batch_Size__c);
       }
       Database.executeBatch(new CS_LCUserCTPermSetsAccessProgEnrollBatch(), batchSize);     
    }     
}