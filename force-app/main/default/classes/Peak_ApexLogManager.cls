/**
 * Created by raydehler on 2019-03-05.
 */
global with sharing class Peak_ApexLogManager implements Schedulable, Database.Batchable<sObject> {
    // 1 a.m. daily
    private static final String CRON_DAILY = '0 0 1 ? * *';

    private static Peak_Apex_Log_Retention_Manager__c logManager {
        get {
            if (logManager == null) {
                logManager = Peak_Apex_Log_Retention_Manager__c.getInstance();
            }
            return logManager;
        }
        set;
    }

    global static void schedule() {
        if (logManager.Scheduled_Job_Id__c != null) {
            // if there's a Scheduled Job Id, it's already scheduled.  confirm it's valid
            try {
                Integer cronTriggers = [
                        SELECT count()
                        FROM CronTrigger
                        WHERE Id = :logManager.Scheduled_Job_Id__c
                ];

                if (cronTriggers > 0) {
                    // it's scheduled and valid, no need to re-schedule
                    return;
                } else {
                    // wipe it away, schedule again
                    logManager.Scheduled_Job_Id__c = null;
                }
            } catch (Exception e) {
                // most likely not a valid Id, wipe it away, schedule again
                logManager.Scheduled_Job_Id__c = null;
            }
        }

        logManager.Scheduled_Job_Id__c = System.schedule('Daily Apex Log Cleanup '+DateTime.now().format(), CRON_DAILY, new Peak_ApexLogManager());
        upsert logManager;
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new Peak_ApexLogManager());
    }

    global List<Peak_Apex_Log__c> start(Database.BatchableContext bc) {
        Integer numDaysToKeep = 0;
        try {
            numDaysToKeep = -Integer.valueOf(logManager.Days_of_Logs_to_Keep__c);
        } catch(Exception e) {}

        Date newestDateToKeep = Date.today().addDays(numDaysToKeep);
        return [
                SELECT Id
                FROM Peak_Apex_Log__c
                WHERE CreatedDate < :newestDateToKeep
        ];
    }

    global void execute(Database.BatchableContext bc, List<Peak_Apex_Log__c> records) {
        delete records;
    }

    global void finish(Database.BatchableContext bc) {

    }
}