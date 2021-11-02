/**
 * Created by Ritvik on 19-11-2018.
 * Purpose : BusinessLogic class for AnnualStudentInformationTrigger called by AnnualStudentInformationHandler.
  */
public class NES_AnnualStudentInfoBusinessLogic {
    private static Peak_ApexLog logger = new Peak_ApexLog('AnnualStudentInfoBusinessLogic');
    public static String placementFlag='Placement Review';

    /** 
     * Created by Ritvik on 19-11-2018.
     * Modified by Ritvik on 26-11-2018.
     * Purpose : Updating Final_Grade_Level__c field on Program Enrollment on after insert or update of Annual Student Information record.
     * Param : newList of ASI records to be updated or inserted.
     */
    public static void populateProgramEnroll_FinalGradeLevel(List<Annual_Student_Information__c> newList) {

        //List to store program enrollment ids.
        Set<Id> programEnrollmentIds = new Set<Id>();

        //List to store program enrollment record that is to be updated on insert or update of Annual Student Information record related to it.
        List<hed__Program_Enrollment__c> programEnrollmentList = new List<hed__Program_Enrollment__c>();

        //Iterating over Annual Student Information record which were in newlist.
        for (Annual_Student_Information__c record : [SELECT School_Year__c,Program_Enrollment__c,Program_Enrollment__r.Start_Year__c, Final_Grade_Level__c FROM Annual_Student_Information__c WHERE Id IN :newList]) {
            //Checking for program enrollment record whose Start_Year__c field is equal to Annual Student Information School_Year__c field.
            if (record.School_Year__c == record.Program_Enrollment__r.Start_Year__c) {
                programEnrollmentIds.add(record.Program_Enrollment__c);
            }
        }

        if (programEnrollmentIds.isEmpty()) {
            return;
        }

        //Map to store program enrollment Id as key & program enrollment record as value.
        Map<Id, hed__Program_Enrollment__c> programEnrollmentMap = new Map<Id, hed__Program_Enrollment__c>();
        //Iterating over program enrollment record whose contact record type is students & Id is in programEnrollmentIds list.
        for (hed__Program_Enrollment__c programEnrollmentRecord : [
                SELECT Id,Status__c,hed__Contact__r.RecordTypeId,Program_Grade_Level__c, Final_Grade_Level__c,PlacementFlag__c
                FROM hed__Program_Enrollment__c
                WHERE
                Id IN :programEnrollmentIds AND hed__Contact__r.RecordType.Name = 'Students'
        ]) {
            programEnrollmentMap.put(programEnrollmentRecord.Id, programEnrollmentRecord);
        }

        Set<Id> tempEnrollIds = new Set<Id>();
        for (Annual_Student_Information__c record : newList) {
            if (programEnrollmentMap.containsKey(record.Program_Enrollment__c)) {
                //Checking for program enrollment status field before populating Final_Grade_Level__c field with Annual Student Information Final_Grade_Level__c field.
                System.debug('programEnrollmentMap.get(record.Program_Enrollment__c).Status__c'+programEnrollmentMap+'<<newList>>'+newList);
                //Modified the below if condition to check if the Final Grade Level on the ASI is null or not if it is not null then only update PE record
                if ((programEnrollmentMap.get(record.Program_Enrollment__c).Status__c == 'Enrolled' || programEnrollmentMap.get(record.Program_Enrollment__c).Status__c == 'Withdrawn' || programEnrollmentMap.get(record.Program_Enrollment__c).Status__c == 'In Progress' || programEnrollmentMap.get(record.Program_Enrollment__c).Status__c == 'Complete') &&
                        record.Final_Grade_Level__c != null) {
                    hed__Program_Enrollment__c programEnrollment = new hed__Program_Enrollment__c(Id = record.Program_Enrollment__c);
                    
                      //getProgramGradeLevelId function is used to get Program_Grade_Level__c id value, paramters are program enrollment id and grade level
                      // programEnrollment.Program_Grade_Level__c = NES_AnnualStudentInfoHandler.getProgramGradeLevelId(programEnrollmentMap.get(record.Program_Enrollment__c).Id,record.Grade_Level_Requested__c);
                       
                       programEnrollment.Final_Grade_Level__c = record.Final_Grade_Level__c;
                       
                    if (!tempEnrollIds.contains(programEnrollment.Id)) {
                        tempEnrollIds.add(programEnrollment.Id);
                        programEnrollmentList.add(programEnrollment);
                    }

                }
                //If program enrollment status field doesn't matches to specified values populate program enrollment Final_Grade_Level__c field to none i.e.''.
                else {
                    System.debug('Setting to blank');
                    //Added one more check by Ajith to check whether the Final Grade Level is already blank or not if yes don't update PE
                    if(programEnrollmentMap.get(record.Program_Enrollment__c).Final_Grade_Level__c != null && programEnrollmentMap.get(record.Program_Enrollment__c).Final_Grade_Level__c != ''){
                        hed__Program_Enrollment__c programEnrollment = new hed__Program_Enrollment__c(Id = record.Program_Enrollment__c);
                        programEnrollment.Final_Grade_Level__c = '';
                        if (!tempEnrollIds.contains(programEnrollment.Id)) {
                            tempEnrollIds.add(programEnrollment.Id);
                            programEnrollmentList.add(programEnrollment);
                        }
                    }
                }
            }
        }

        if (programEnrollmentList.size() > 0) {
            try {
                update(programEnrollmentList);
            } catch (Exception ex) {
                System.debug('Exception Thrown:' + ex.getMessage());
                logger.logException('populateFinalGradeLevel', ex);
                logger.saveLogs();
            }

        }
    }

    /**
    * Created By Anand 12/10/2018
    *Purpose:To call calculateELLFlag function of NES_BusinessLOgicUtils on After Insert/Update
    * @param oldMap
    * @param newMap
    */
    public static void calculateELLFlag(List<Annual_Student_Information__c> newList, Map<Id, Annual_Student_Information__c> oldMap) {
        List<Annual_Student_Information__c> annualStudList = new List<Annual_Student_Information__c>();
        if (oldMap != null && !oldMap.isEmpty()) {
            for (Annual_Student_Information__c stud : newList) {
                if (stud.Program_Enrollment__c <> Null && oldMap.get(stud.Id).StudentIsELL__c != stud.StudentIsELL__c) {
                    System.debug('Updated');
                    annualStudList.add(stud);
                }
            }
        } else {
            for (Annual_Student_Information__c studInfo : newList) {
                if (studInfo.Program_Enrollment__c != Null) {
                    annualStudList.add(studInfo);
                }
            }
        }
        if (!annualStudList.isEmpty()) {
            NES_BusinessLogicUtils bussLogicUtils = new NES_BusinessLogicUtils();
            bussLogicUtils.calculateELLFlag(new List<Home_Language_Survey__c>(), annualStudList, new List<Hed__Program_Enrollment__c>());

        }
    }

    /**
    * Created By Ritvik 12/13/2018
    *Purpose:To call calculateHighSchoolLTSGroup function of NES_BusinessLOgicUtils on After Insert/Update
    * @param oldMap
    * @param newMap
    */
    public static void populatePEHighSchoolLTSGroup(List<Annual_Student_Information__c> newList, Map<Id, Annual_Student_Information__c> oldMap) {
        Set<Id> asiIds = new Set<Id>();
        if (oldMap != null) {
            for (Annual_Student_Information__c annualStudentInformation : newList) {
                if (annualStudentInformation.Grade_Level_Requested__c != null &&
                        (annualStudentInformation.HS_LTS__c != oldMap.get(annualStudentInformation.Id).HS_LTS__c ||
                                annualStudentInformation.Grade_Level_Requested__c != oldMap.get(annualStudentInformation.Id).Grade_Level_Requested__c)) {
                    asiIds.add(annualStudentInformation.Id);
                }
            }
        } else {
            for (Annual_Student_Information__c annualStudentInformation : newList) {
                if (annualStudentInformation.HS_LTS__c != null && annualStudentInformation.Grade_Level_Requested__c != null) {
                    asiIds.add(annualStudentInformation.Id);
                }
            }
        }
        if (!asiIds.isEmpty()) {
            System.debug('asiIds' + asiIds);
            NES_BusinessLogicUtils.calculateHighSchoolLTSGroup(asiIds);
        }
    }


    /**
   * Created By Ritvik 12/14/2018
   *Purpose:To call calculateHighSchoolLTS function of NES_BusinessLOgicUtils on After Insert/Update
   * @param oldMap
   * @param newMap
   */
    public static void populatecalculateHighSchoolLTS(List<Annual_Student_Information__c> newList, Map<Id, Annual_Student_Information__c> oldMap) {
        System.debug('In populatecalculateHighSchoolLTS Business Logic');
        Set<Id> progEnrollIds = new Set<Id>();
        if (oldMap != null) {
            for (Annual_Student_Information__c annualStudentInformation : newList) {
                if (annualStudentInformation.Grade_Level_Requested__c != oldMap.get(annualStudentInformation.Id).Grade_Level_Requested__c) {
                    progEnrollIds.add(annualStudentInformation.Program_Enrollment__c);
                }
            }
        } else {
            for (Annual_Student_Information__c annualStudentInformation : newList) {
                if (annualStudentInformation.Grade_Level_Requested__c != null) {
                    progEnrollIds.add(annualStudentInformation.Program_Enrollment__c);
                    System.debug('asiIds TLSHS_LTS__c' + annualStudentInformation.HS_LTS__c);
                }
            }
        }

        if (!progEnrollIds.isEmpty()) {
            NES_BusinessLogicUtils.calculateHighSchoolLTS(progEnrollIds);
        }
    }

    /**
     * Created By Anushka 21/12/2018
     *Purpose:To call waitlistCalculator function of NES_BusinessLogicUtils on After Update/Insert
     */
    public static void waitlistCalculator(List<Annual_Student_Information__c> newList, Map<Id, Annual_Student_Information__c> oldMap) {
        Set<Id> programEnrollmentIds = new Set<Id>();
        if (oldMap != null) {
            for (Annual_Student_Information__c asi : newList) {
                if (asi.Final_Grade_Level__c != oldMap.get(asi.Id).Final_Grade_Level__c ||
                        asi.Grade_Level_Requested__c != oldMap.get(asi.Id).Grade_Level_Requested__c)
                    programEnrollmentIds.add(asi.Program_Enrollment__c);
            }
        } else {
            for (Annual_Student_Information__c asi : newList) {
                if (asi.Final_Grade_Level__c != null || asi.Grade_Level_Requested__c != null)
                    programEnrollmentIds.add(asi.Program_Enrollment__c);
            }
        }

        if (programEnrollmentIds.size() > 0) {
            //Bug 80271 Change the logic to Batch 
            Database.executeBatch(new NES_WaitListCalculatorBatch(programEnrollmentIds),100);
        }
    }

    /**
      * Created by Ajith on 25-03-2019.
      * Purpose : This method populating the AutomatedPlacementExclude__c field on Annual Student Information object after inserting/Updating .
      * Param : newList of ASI and OldMap of ASI.
      */
    /*public static List<Annual_Student_Information__c> populateAutomatedPlacementExclude(List<Annual_Student_Information__c> newList) {
        
        System.debug('populateAutomatedPlacementExclude+++');
        Set<Id> peIdsSet = new Set<Id>();
        List<Annual_Student_Information__c> asis = new List<Annual_Student_Information__c>();
        for (Annual_Student_Information__c asiRecord : newList) {
            peIdsSet.add(asiRecord.Program_Enrollment__c);
        }
        System.debug(peIdsSet);
        if (peIdsSet.size() > 0) {
             return NES_AnnualStudentInformationUtilities.calculateAutomatedPlacementExclude(peIdsSet, true);
        } else {
            return asis;
        }
    }*/

    /**
      * Created by Ajith on 26-03-2019.
      * Purpose : This method populating the Program_Grade_Level__c field on Program Enrollment record based on the
      *           Final Grade Level and Requested Grade Level (#Bug 80641)
      * Param : newList of ASI and OldMap of ASI.
      */
    public static void populateProgramGradeLevel(List<Annual_Student_Information__c> newList, Map<Id, Annual_Student_Information__c> oldMap) {
        System.debug('In PopulateProgramGradeLevel+++');
        Set<Id> peIdsSet = new Set<Id>();
        if (oldMap != null) {
            for (Annual_Student_Information__c asiRecord : newList) {
                if ( (asiRecord.Final_Grade_Level__c != null && asiRecord.Final_Grade_Level__c != oldMap.get(asiRecord.Id).Final_Grade_Level__c) ||
                        (asiRecord.Grade_Level_Requested__c != null && asiRecord.Grade_Level_Requested__c != oldMap.get(asiRecord.Id).Grade_Level_Requested__c)) {
                    peIdsSet.add(asiRecord.Program_Enrollment__c);
                }
            }
        } else {
            for (Annual_Student_Information__c asiRecord : newList) {
                if(asiRecord.Final_Grade_Level__c != null || asiRecord.Grade_Level_Requested__c != null){
                    peIdsSet.add(asiRecord.Program_Enrollment__c);
                }
            }
        }
        System.debug('peIdsSet+++'+peIdsSet);
        if(peIdsSet.isEmpty()){
            return;
        }

        //Some Variables to work with
        Map<Id, List<Program_Grade_Level__c>> programGradeLevelMap = new Map<Id, List<Program_Grade_Level__c>> ();
        List<hed__Program_Enrollment__c> programEnrollmentsToUpdate = new List<hed__Program_Enrollment__c>();
        for(Program_Grade_Level__c gradeLevel : [
                SELECT Id, Name, Grade_Level__c, Grade_Level__r.Name, Academic_Program__c
                FROM Program_Grade_Level__c
                WHERE Academic_Program__c IN (SELECT hed__Account__c FROM hed__Program_Enrollment__c WHERE Id IN :peIdsSet)
                AND Grade_Level__c != null]){
            if (programGradeLevelMap.containsKey(gradeLevel.Academic_Program__c)) {
                programGradeLevelMap.get(gradeLevel.Academic_Program__c).add(gradeLevel);
            } else {
                programGradeLevelMap.put(gradeLevel.Academic_Program__c, new List<Program_Grade_Level__c>{gradeLevel});
            }
        }
        System.debug('programGradeLevelMap++++'+programGradeLevelMap);
        for(hed__Program_Enrollment__c pe : [
                SELECT Id, hed__Account__c, Program_Grade_Level__c, Start_Year__c,
                (SELECT Id, Final_Grade_Level__c, Grade_Level_Requested__c, School_Year__c FROM Annual_Student_Information__r)
                FROM hed__Program_Enrollment__c
                WHERE Id IN :peIdsSet]){
            //Variable to hold the Current Year ASI Record
            Annual_Student_Information__c currentYearASI;
            if(pe.Annual_Student_Information__r != null){
                //Iterate over the ASI records related to the Program enrollments and find out the current year ASI record
                for(Annual_Student_Information__c asi : pe.Annual_Student_Information__r){
                    if(asi.School_Year__c == pe.Start_Year__c){
                        currentYearASI = asi;
                    }
                }
                System.debug('currentYearASI'+currentYearASI);
                // If ASI record for enrolling year(Current year) exists and Grade level record for the Academic Program on the Program Enrollment Exists populate the Program Grade level
                if(currentYearASI != null && programGradeLevelMap.containsKey(pe.hed__Account__c)) {
                    String gradeLevelName;
                    if(currentYearASI.Final_Grade_Level__c != null) {
                        gradeLevelName = currentYearASI.Final_Grade_Level__c;
                    } else {
                        gradeLevelName = currentYearASI.Grade_Level_Requested__c;
                    }
                    if(gradeLevelName == 'Kindergarten') {
                        gradeLevelName = 'K';
                    }
                    for(Program_Grade_Level__c gradeLevel : programGradeLevelMap.get(pe.hed__Account__c)){
                        System.debug('gradelevelk '+ gradeLevel.Grade_Level__r.Name);
                        if(gradeLevelName == gradeLevel.Grade_Level__r.Name){
                            pe.Program_Grade_Level__c = gradeLevel.Id;
                            programEnrollmentsToUpdate.add(pe);
                            break;
                        }
                    }
                }
            }
        }
        System.debug('programEnrollmentsToUpdate+++'+programEnrollmentsToUpdate);
        if(!programEnrollmentsToUpdate.isEmpty()){
            try {
                update programEnrollmentsToUpdate;
            }catch (Exception ex){
                System.debug('Exception Thrown:' + ex.getMessage());
                logger.logException('populateProgramGradeLevel', ex);
                logger.saveLogs();
            }
        }
    }

 //code commented for 121803US
    /*public static List<Annual_Student_Information__c> calculatePlacementScore(List<Annual_Student_Information__c> newList){
    
        List<Id> peIds = new List<Id>();
        for(Annual_Student_Information__c asi : newList) {
            peIds.add(asi.Program_Enrollment__c);
        }

        return NES_ECABusinessLogic.calculatePlacementScore(peIds, newList);

    }*/
//code commented for 121803US
    public static void shouldRunPlacementVoid(List<Annual_Student_Information__c> newList, Map<Id, Annual_Student_Information__c> oldMap) {

        /* List<Annual_Student_Information__c> allASIsToRun = new List<Annual_Student_Information__c>();
        for(Annual_Student_Information__c asi : newList) {
            Annual_Student_Information__c oldASI = oldMap.get(asi.Id);
            if(oldASI.Academic_Documentation_Summary__c != asi.Academic_Documentation_Summary__c ||
                    oldASI.AutomatedPlacementExclude__c != asi.AutomatedPlacementExclude__c ||
                    oldASI.AutomatedPlacementScore__c != asi.AutomatedPlacementScore__c ||
                    oldASI.CoursesFinalized__c != asi.CoursesFinalized__c ||
                    oldASI.Final_Grade_Level__c != asi.Final_Grade_Level__c ||
                    oldASI.GiftedProgramRequest_LA_M_S__c != asi.GiftedProgramRequest_LA_M_S__c ||
                    oldASI.Grade_Level_Completed__c != asi.Grade_Level_Completed__c ||
                    oldASI.Grade_Level_Requested__c != asi.Grade_Level_Requested__c ||
                    oldASI.HowStudentPlacementCompleted__c != asi.HowStudentPlacementCompleted__c ||
                    oldASI.LA_Placement_Level__c != asi.LA_Placement_Level__c ||
                    oldASI.Math_Placement_Level__c != asi.Math_Placement_Level__c ||
                    oldASI.RecommendedAutoPlacement__c != asi.RecommendedAutoPlacement__c ||
                    oldASI.Science_Placement_Level__c != asi.Science_Placement_Level__c) {

                System.debug('i am here right now');

                allASIsToRun.add(asi);

            }
        }
        if(allASIsToRun.size() > 0) {
            verifyAffiliationsComplete(allASIsToRun);
        }
        */
    }

    public static void verifyAffiliationsComplete(List<Annual_Student_Information__c> newList) {
		/*
            List<Id> programEnrollmentIds = new List<Id>();
            System.debug(newList);
            Map<Id, List<Annual_Student_Information__c>> peASIMap = new Map<Id, List<Annual_Student_Information__c>>();
            for(Annual_Student_Information__c asi : newList) {
                programEnrollmentIds.add(asi.Program_Enrollment__c);

                List<Annual_Student_Information__c> asis = new List<Annual_Student_Information__c>();

                if(peASIMap.containsKey(asi.Program_Enrollment__c)) {
                    asis = peASIMap.get(asi.Program_Enrollment__c);
                }
                asis.add(asi);
                peASIMap.put(asi.Program_Enrollment__c, asis);
            }

            Map<Id, List<Enrollment_Component_Affiliation__c>> peAffiliationsMap =new Map<Id, List<Enrollment_Component_Affiliation__c>>();
            List<Enrollment_Component_Affiliation__c> affiliations = [
                    SELECT Id, Status__c, Enrollment_Component__r.Required_to_Complete_for_Auto_Placement__c, Program_Enrollment__c
                    FROM Enrollment_Component_Affiliation__c
                    WHERE Program_Enrollment__c IN : programEnrollmentIds
                    AND Enrollment_Component__r.Required_to_Complete_for_Auto_Placement__c = TRUE];

            for(Enrollment_Component_Affiliation__c affiliation : affiliations) {

                List<Enrollment_Component_Affiliation__c> mappedAffiliations = new List<Enrollment_Component_Affiliation__c>();
                if(peAffiliationsMap.containsKey(affiliation.Program_Enrollment__c)) {
                    mappedAffiliations = peAffiliationsMap.get(affiliation.Program_Enrollment__c);
                }

                mappedAffiliations.add(affiliation);
                peAffiliationsMap.put(affiliation.Program_Enrollment__c, mappedAffiliations);
            }

            List<Annual_Student_Information__c> evalASIs = new List<Annual_Student_Information__c>();
            for(Id peId : peAffiliationsMap.keySet()) {

                Boolean notComplete = false;

                for(Enrollment_Component_Affiliation__c affiliation : peAffiliationsMap.get(peId)) {

                    if(affiliation.Status__c != 'Complete') {
                        notComplete = true;
                        break;
                    }
                }
                System.debug(peId);
                System.debug(notComplete);
                if(!notComplete) {
                    evalASIs.addAll(peASIMap.get(peId));
                }
            }

            System.debug(evalASIs);
            if(evalASIs.size() > 0) {

                List<Id> asisIds = new List<Id>();
                for(Annual_Student_Information__c newASI : evalASIs) {
                    asisIds.add(newASI.Id);
                }
                verifySameYearASI(asisIds);
            }*/

    }

    public static void verifySameYearASI(List<Id> asiIds) {
		/*
        List<Annual_Student_Information__c> asis = [SELECT Id, School_Year__c, Program_Enrollment__r.Start_Year__c FROM Annual_Student_Information__c WHERE Id IN : asiIds];
        List<Id> actualASIIds = new List<Id>();

        for(Annual_Student_Information__c asi : asis) {

            if(asi.School_Year__c == asi.Program_Enrollment__r.Start_Year__c) {
                actualASIIds.add(asi.Id);
            }
        }

        if(actualASIIds.size() > 0) {
            System.enqueueJob(new NES_PlacementQueueable(actualASIIds));
        }*/
    }

    public static void runPlacement(List<Id> asiIds) {
		/*
        List<Annual_Student_Information__c> newList = [
                SELECT Id, Program_Enrollment__c,Academic_Documentation_Summary__c,School_Year__r.Start_Date__c,
                        LA_Placement_Level__c, HowStudentPlacementCompleted__c, CoursesFinalized__c, Math_Placement_Level__c,
                        Science_Placement_Level__c, Grade_Level_Requested__c, RecommendedAutoPlacement__c,
                        Final_Grade_Level__c, GiftedProgramRequest_LA_M_S__c, Program_Enrollment__r.Start_Year__r.Start_Date__c,
                        School_Year__c FROM Annual_Student_Information__c WHERE Id IN: asiIds
        ];

        List<Annual_Student_Information__c> asis = new List<Annual_Student_Information__c>();
        List<Annual_Student_Information__c> asis2 = new List<Annual_Student_Information__c>();

        List<Annual_Student_Information__c> updatedASIs1 = new List<Annual_Student_Information__c>();
        List<Annual_Student_Information__c> updatedASIs2 = new List<Annual_Student_Information__c>();
        List<Annual_Student_Information__c> updatedASIs3 = new List<Annual_Student_Information__c>();
        List<Annual_Student_Information__c> updatedASIs4 = new List<Annual_Student_Information__c>();

        Set<Id> programEnrollmentIds = new Set<Id>();

        programEnrollmentIds = grabPEIds(newList);
        updatedASIs1 = NES_BusinessLogicUtils.placementWhyFlagged(programEnrollmentIds, newList).clone();
        updatedASIs2 = populateAutomatedPlacementExclude(updatedASIs1).clone();
        System.debug(updatedASIs1);
        updatedASIs3 = calculatePlacementScore(updatedASIs2).clone();
        System.debug(updatedASIs3);

        for(Annual_Student_Information__c asi : updatedASIs3) {
            if(asi.HowStudentPlacementCompleted__c == null && (asi.RecommendedAutoPlacement__c == 'Yes' || (asi.AutomatedPlacementScore__c != null && asi.AutomatedPlacementExclude__c == false
                    && asi.LA_Placement_Level__c == null && asi.Science_Placement_Level__c == null
                    && asi.Final_Grade_Level__c == null && asi.Math_Placement_Level__c == null
                    && asi.Grade_Level_Requested__c != '9' && asi.Grade_Level_Requested__c != '10'
                    && asi.Grade_Level_Requested__c != '11' && asi.Grade_Level_Requested__c != '12'))) {
                asis.add(asi);
            } else {
                asis2.add(asi);
            }
        }
        System.debug(asis);
        if(asis.size() > 0) {
            programEnrollmentIds = grabPEIds(asis);
            updatedASIs4 = NES_BusinessLogicUtils.calculateAutomatedPlacementProcess(programEnrollmentIds, asis).clone();
            updatedASIs4.addAll(asis2);
        } else {
            updatedASIs4.addAll(updatedASIs3);
        }
        update updatedASIs4;
        System.debug(updatedASIs4);

        programEnrollmentIds = grabPEIds(updatedASIs4);
        System.debug(programEnrollmentIds);
        List<Annual_Student_Information__c> newASIs = NES_BusinessLogicUtils.placementWhyFlagged(programEnrollmentIds, updatedASIs4).clone();
        if(newASIs.size() > 0) {
            NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(newASIs, true);
            populateProgramEnroll_FinalGradeLevel(newASIs);
        } else {
            NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(updatedASIs4, true);
            populateProgramEnroll_FinalGradeLevel(updatedASIs4);
        }*/

    }

    public static Set<Id> grabPEIds(List<Annual_Student_Information__c> asis) {

        Set<Id> programEnrollmentIds = new Set<Id>();
        for(Annual_Student_Information__c asi : asis) {

            programEnrollmentIds.add(asi.Program_Enrollment__c);
        }

        return programEnrollmentIds;
    }
}