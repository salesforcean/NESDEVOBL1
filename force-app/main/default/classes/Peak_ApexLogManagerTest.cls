/**
 * Created by raydehler on 2019-03-06.
 */
@isTest
private class Peak_ApexLogManagerTest {
    static testMethod void testSchedule() {
        Peak_ApexLogManager.schedule();
        System.assertNotEquals(null, Peak_Apex_Log_Retention_Manager__c.getInstance().Scheduled_Job_Id__c);
    }

    static testMethod void testScheduleWhenItExists() {
        Peak_ApexLogManager.schedule();
        Peak_ApexLogManager.schedule();
        System.assertNotEquals(null, Peak_Apex_Log_Retention_Manager__c.getInstance().Scheduled_Job_Id__c);
    }

    static testMethod void testScheduleWhenInvalidId() {
        Peak_Apex_Log_Retention_Manager__c palrm = Peak_Apex_Log_Retention_Manager__c.getInstance();
        palrm.Scheduled_Job_Id__c = 'xxxxxxxxxxxxxxx';
        upsert palrm;
        Peak_ApexLogManager.schedule();
        System.assertNotEquals(null, Peak_Apex_Log_Retention_Manager__c.getInstance().Scheduled_Job_Id__c);
    }

    static testMethod void testScheduleWhenValidIdButNotFound() {
        Peak_Apex_Log_Retention_Manager__c palrm = Peak_Apex_Log_Retention_Manager__c.getInstance();
        palrm.Scheduled_Job_Id__c = '001001001001001';
        upsert palrm;
        Peak_ApexLogManager.schedule();
        System.assertNotEquals(null, Peak_Apex_Log_Retention_Manager__c.getInstance().Scheduled_Job_Id__c);
    }


    static testMethod void testBatch() {
        Peak_Apex_Log_Persona_Manager__c palpm = Peak_Apex_Log_Persona_Manager__c.getInstance();
        palpm.Log_Level__c = 3; // Info
        upsert palpm;

        Peak_ApexLog logger = new Peak_ApexLog('Questions');
        logger.logInfo('methodName', 'message');
        logger.saveLogs();

        System.assertEquals(1, [select count() from Peak_Apex_Log__c]);

        Peak_Apex_Log_Retention_Manager__c palrm = Peak_Apex_Log_Retention_Manager__c.getInstance();
        palrm.Days_of_Logs_to_Keep__c = -1;
        upsert palrm;

        Test.startTest();
        Database.executeBatch(new Peak_ApexLogManager());
        Test.stopTest();

        System.assertEquals(0, [select count() from Peak_Apex_Log__c]);
    }
}