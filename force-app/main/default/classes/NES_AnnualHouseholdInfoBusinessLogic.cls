/**
 * Created by Raju on 15-12-2018.
 * Purpose : BusinessLogic class for AnnualHouseholdInformationTrigger called by AnnualHouseholdInformationHandler.
 * Added Testing logic for new fields and corresponding logic for HHFedPovertyEligibility & HHFARMEligCalculate US117580 (Jagadeesh) on 11/13/2019
*/
public class NES_AnnualHouseholdInfoBusinessLogic {
    private static Peak_ApexLog logger =  new Peak_ApexLog('AnnualHouseholdInfoBusinessLogic');

    /**
     * Created By Raju on 15-12-2018.
     * purpose is to call the calculateFederalPovertyEligibility method in the NES_BusinessLogicUtils class after Update/Insert.
     */
    public static void federalPovertyEligibility(List<Annual_Household_Information__c> newList, Map<Id, Annual_Household_Information__c> oldMap) {
        Set<Id> peIdSet = new Set<Id>();
        Set<Id> ahiIdSet = new Set<Id>();

        for (Annual_Household_Information__c ahiRecord : newList) {
            if (oldMap != null) {
                if ((oldMap.get(ahiRecord.Id).Total_Gross_HH_Income__c != ahiRecord.Total_Gross_HH_Income__c ||
                        oldMap.get(ahiRecord.Id).Number_HH_Children__c != ahiRecord.Number_HH_Children__c ||
                        oldMap.get(ahiRecord.Id).Number_HH_Adults__c != ahiRecord.Number_HH_Adults__c ||
                        oldMap.get(ahiRecord.Id).HH_Has_Food_Stamp_Recipient__c != ahiRecord.HH_Has_Food_Stamp_Recipient__c ||
                        oldMap.get(ahiRecord.Id).HH_Has_Foster_Children__c != ahiRecord.HH_Has_Foster_Children__c ||
                        oldMap.get(ahiRecord.Id).Income_Opt_Out_Options__c != ahiRecord.Income_Opt_Out_Options__c) &&
                        ahiRecord.Program_Enrollment__c != null) {
                    System.debug('In Update if');
                    peIdSet.add(ahiRecord.Program_Enrollment__c);
                    ahiIdSet.add(ahiRecord.Id);
                }
            } else {
                if ((ahiRecord.Total_Gross_HH_Income__c != null || ahiRecord.Number_HH_Children__c != null || ahiRecord.Number_HH_Adults__c != null ||
                        ahiRecord.HH_Has_Food_Stamp_Recipient__c != null || ahiRecord.HH_Has_Foster_Children__c != null || ahiRecord.Income_Opt_Out_Options__c != null) &&
                        ahiRecord.Program_Enrollment__c != null) {
                    peIdSet.add(ahiRecord.Program_Enrollment__c);
                    ahiIdSet.add(ahiRecord.Id);
                }
            }
        }

        if (ahiIdSet.size() > 0 && peIdSet.size() > 0) {
            List<Annual_Household_Information__c> ahiList = new List<Annual_Household_Information__c>([
                    SELECT Id,Total_Gross_HH_Income__c,
                            Number_HH_Children__c,
                            Number_HH_Adults__c,
                            HH_Has_Food_Stamp_Recipient__c,
                            Program_Enrollment__c,
                            HH_Has_Foster_Children__c, Income_Opt_Out_Options__c,
                            Program_Enrollment__r.Start_Year__r.id,
                            School_Year__c,
               				 Program_Enrollment__r.hed__Account__r.Fed_Elig_Inc_Free_Meals_HH_Size_of_1__c,// added by jagadeesh - user story : 117580
                    		Program_Enrollment__r.hed__Account__r.Fed_Poverty_Elig_Inc_Addl_Per_Person__c, // added by jagadeesh - user story : 117580
                   			 Program_Enrollment__r.hed__Account__r.FARM_Elig_Inc_Free_Meals_HH_Size_of_1__c,// added by jagadeesh - user story : 117580
                   			 Program_Enrollment__r.hed__Account__r.FARM_Elig_Inc_Free_Meals_Addl_Per_Person__c,// added by jagadeesh - user story : 117580
                   			 Program_Enrollment__r.hed__Account__r.FARM_Elig_Inc_Red_Meals_HH_Size_of_1__c, // added by jagadeesh - user story : 117580
                   			 Program_Enrollment__r.hed__Account__r.FARM_Elig_Inc_Red_Meals_Addl_Per_Person__c // added by jagadeesh - user story : 117580

                    FROM Annual_Household_Information__c
                    WHERE Program_Enrollment__c IN:peIdSet AND Id IN:ahiIdSet
            ]);
            NES_BusinessLogicUtils.calculateFederalPovertyEligibility(peIdSet, ahiList);
        }
    }

    /**
     * Created By Anushka on 12/18/2018
     * purpose is to call the calculateLTS method in the NES_BusinessLogicUtils class after Update/Insert.
     */
    public static void calculateLTS(List<Annual_Household_Information__c > newList, Map<Id, Annual_Household_Information__c > oldMap) {

        Set<Id> householdProgramEnrollmentIds = new Set<Id>();
        Set<Id> programEnrollmentIds = new Set<Id>();
        for (Annual_Household_Information__c ahi : newList) {
            if (oldMap != null) {
                if (ahi.Total_Gross_HH_Income__c != oldMap.get(ahi.Id).Total_Gross_HH_Income__c)
                    householdProgramEnrollmentIds.add(ahi.Program_Enrollment__c);
            } else {
                if (ahi.Total_Gross_HH_Income__c != null)
                    householdProgramEnrollmentIds.add(ahi.Program_Enrollment__c);
            }
        }

        if (!householdProgramEnrollmentIds.isEmpty()) {
            for (hed__Program_Enrollment__c pe : [
                    SELECT Id
                    from hed__Program_Enrollment__c
                    where Household_Program_Enrollment__c in :householdProgramEnrollmentIds]) {
                programEnrollmentIds.add(pe.Id);
            }
        }
        if (programEnrollmentIds.size() > 0) {
            List<hed__Program_Enrollment__c> programEnrollments = NES_LTSUtility.calculateLTS(programEnrollmentIds);
            try {
                update programEnrollments;
            } catch (Exception ex) {
                System.debug('Exception Thrown:' + ex.getMessage());
                logger.logException('calculateLTS', ex);
                logger.saveLogs();
            }
        }
    }
}