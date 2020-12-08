/**
* Created by Anand on 11/06/18.
* Desciption: Schedule Class for BatchUpdateHardStopTimeConst to schedule it Hourly
*/
global class NES_Sch_UpdateHardStopTimeCons implements Schedulable {
    global void execute(System.SchedulableContext sc) {
        // Executes the Batch_UpdateHardStopTimeCons class every Hour  Cron : 0 0 * * * ?
        NES_Batch_UpdateHardStopTimeConstraint bc = new NES_Batch_UpdateHardStopTimeConstraint();
        Database.executeBatch(bc);
    }

}