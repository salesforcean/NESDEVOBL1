/**
* Created by Anand on 11/06/18.
* Desciption: Test Class for ScheduleUpdateTimeContraint
*/
@isTest
private class NES_Sch_UpdateHardStopTimeConsTest {
    static testmethod void schedulerTest()
    {
		Test.startTest();
        String CRON_EXP = '0 0 * * * ?';
        String jobId = System.schedule('ScheduleHourTest',  CRON_EXP, new NES_Sch_UpdateHardStopTimeCons());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        Test.stopTest();
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    }
    
}