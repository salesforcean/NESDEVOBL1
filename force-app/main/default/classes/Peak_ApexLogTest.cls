/**
 * Created by raydehler on 2019-03-06.
 */
@isTest
private class Peak_ApexLogTest {
    static testMethod void testApexLogManager() {

    }

    static testMethod void testApexLogNoManager() {
        Peak_ApexLog logger = new Peak_ApexLog('Not present');
        logger.logInfo('methodName', 'message');
        logger.logWarn('methodName', 'message');
        logger.logError('methodName', 'message');
        logger.logException('methodName', new Peak_ApexLog.Peak_ApexLogException('message'));
        logger.saveLogs();
        System.assertEquals(0, [select count() from Peak_Apex_Log__c]);
    }

    static testMethod void testApexLogNoPersona() {
        Peak_ApexLog logger = new Peak_ApexLog('Questions');
        logger.logInfo('methodName', 'message');
        logger.logWarn('methodName', 'message');
        logger.logError('methodName', 'message');
        logger.logException('methodName', new Peak_ApexLog.Peak_ApexLogException('message'));
        logger.saveLogs();
        System.assertEquals(0, [select count() from Peak_Apex_Log__c]);
    }


    static testMethod void testApexLogAll() {
        Peak_Apex_Log_Persona_Manager__c palpm = Peak_Apex_Log_Persona_Manager__c.getInstance();
        palpm.Log_Level__c = 3; // Info
        upsert palpm;

        Peak_ApexLog logger = new Peak_ApexLog('Questions');
        logger.logInfo('methodName', 'message');
        logger.logWarn('methodName', 'message');
        logger.logError('methodName', 'message');
        logger.logException('methodName', new Peak_ApexLog.Peak_ApexLogException('message'));
        logger.saveLogs();
        System.assertEquals(4, [select count() from Peak_Apex_Log__c]);
    }

    static testMethod void testApexLogErrors() {
        Peak_Apex_Log_Persona_Manager__c palpm = Peak_Apex_Log_Persona_Manager__c.getInstance();
        palpm.Log_Level__c = 1; // Error
        upsert palpm;

        Peak_ApexLog logger = new Peak_ApexLog('Questions');
        logger.logInfo('methodName', 'message');
        logger.logWarn('methodName', 'message');
        logger.logError('methodName', 'message');
        logger.logException('methodName', new Peak_ApexLog.Peak_ApexLogException('message'));
        logger.saveLogs();
        System.assertEquals(2, [select count() from Peak_Apex_Log__c]);
    }

}