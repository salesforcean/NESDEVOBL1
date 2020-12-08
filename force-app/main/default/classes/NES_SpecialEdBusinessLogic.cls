/**
 * Created by Anushka on 22-11-2018.
 * Purpose : BusinessLogic class for SpecialEducationTrigger called by SpecialEducationHandler.
 */

public class NES_SpecialEdBusinessLogic {
    private static Peak_ApexLog logger = new Peak_ApexLog('SpecialEdBusinessLogic');

    /**
    * Created By Anushka on 12/18/2018
    * purpose is to call the calculateLTS method in the NES_BusinessLogicUtils class after Update/Insert.
    */
    public static void calculateLTS(Map<Id, Special_Education__c> oldMap, List<Special_Education__c> newList) {
        Set<Id> programEnrollmentIds = new Set<Id>();
        for (Special_Education__c se : newList) {
            if (oldMap != null) {
                if (se.Gifted__c != oldMap.get(se.Id).Gifted__c)
                    programEnrollmentIds.add(se.Program_Enrollment__c);
            } else if (se.Gifted__c != null)
                programEnrollmentIds.add(se.Program_Enrollment__c);
        }

        List<hed__Program_Enrollment__c> programEnrollments = NES_LTSUtility.calculateLTS(programEnrollmentIds);
        try {
            update programEnrollments;
        } catch(Exception e) {
            logger.logException('calculateLTS', e);
            logger.saveLogs(); 
            throw e;
        }
    }

    public static void calculatePlacement(List<Special_Education__c> newList, Map<Id, Special_Education__c> oldMap) {
        Set<Id> programEnrollmentIds = new Set<Id>();
        Set<Id> asiIds = new Set<Id>();
        for (Special_Education__c se : newList) {
            Special_Education__c oldSp = oldMap.get(se.Id);
            if (se.IEPHistory__c != oldSp.IEPHistory__c || se.Plan504Exit__c != oldSp.Plan504Exit__c
                        || se.Plan504History__c != oldSp.Plan504History__c || se.IEP__c != oldSp.IEP__c || se.EvaluatedWithInLastYear__c != oldSp.EvaluatedWithInLastYear__c) {
                    programEnrollmentIds.add(se.Program_Enrollment__c);
            } 
        }
        if(programEnrollmentIds.size() > 0) {
            List<Annual_Student_Information__c> asis = [SELECT Id, Program_Enrollment__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c IN : programEnrollmentIds];
            NES_AnnualStudentInfoBusinessLogic.verifyAffiliationsComplete(asis);
        }

    }
}