/**
* Created by Anushka on 22-11-2018.
* Purpose : BusinessLogic class for ProgramEnrollmentTrigger called by ProgramEnrollmentHandler.
**Change Log:
* Added code by Anitha P for #107180 User Story (Task 108661) on 2019-09-06
* Added code by Anitha P for #107180 User Story (Bug  110762) on 2019-09-30
* Added code by viswa for #167639 User Story (Alternative Shipping Address Case Workflow) on 2020-04-24
*/


public class NES_ProgramEnrollmentBusinessLogic {
    
    private static Peak_ApexLog logger = new Peak_ApexLog('ProgramEnrollmentBusinessLogic');
    
  /* public static void calculatePlacement(List<hed__Program_Enrollment__c> newList, Map<Id, hed__Program_Enrollment__c > oldMap) {
        System.debug('In Program Enrollment Business logic for Update');
        Set<Id> programEnrollmentIds = new Set<Id>(); // Modified By Anand to Set on Jan 2 2019
        
       for (hed__Program_Enrollment__c pe : newList) {
            hed__Program_Enrollment__c oldPE = oldMap.get(pe.Id);
            if (pe.Start_Year__c != oldPE.Start_Year__c ||
                pe.PlacementFlag__c != oldPE.PlacementFlag__c ||
                pe.Principal_Review_Comments__c != oldPE.Principal_Review_Comments__c ||
                pe.Gifted_Program_Request__c != oldPE.Gifted_Program_Request__c ||
                pe.Academic_Doc_Performance__c != oldPE.Academic_Doc_Performance__c ||
                pe.AcademicPerformanceEligibility__c != oldPE.AcademicPerformanceEligibility__c ||
                pe.CohortEligibility__c != oldPE.CohortEligibility__c ||
                pe.Credit_for_HS_Coursework__c != oldPE.Credit_for_HS_Coursework__c ||
                pe.CreditByExamScores__c != oldPE.CreditByExamScores__c ||
                pe.EnrollmentSpecialistContactReq__c != oldPE.EnrollmentSpecialistContactReq__c ||
                pe.AddressEligibilitySystem__c != oldPE.AddressEligibilitySystem__c ||
                pe.AddressEligibilityOverride__c != oldPE.AddressEligibilityOverride__c ||
                pe.EntranceAgeEligibilitySystem__c != oldPE.EntranceAgeEligibilitySystem__c ||
                pe.EntranceAgeEligibilityOverride__c != oldPE.EntranceAgeEligibilityOverride__c ||
                pe.GradeLevelEligibility__c != oldPE.GradeLevelEligibility__c ||
                pe.HomelessRiskFlag__c != oldPE.HomelessRiskFlag__c ||
                pe.HomeSchoolEvaluatorReport__c != oldPE.HomeSchoolEvaluatorReport__c ||
                pe.HomeschoolMembershipElg__c != oldPE.HomeschoolMembershipElg__c ||
                pe.MoreHighSchoolDocumentation__c != oldPE.MoreHighSchoolDocumentation__c ||
                pe.PriorSchoolAttendanceElg__c != oldPE.PriorSchoolAttendanceElg__c ||
                pe.SIF_AcademicSupportNeeds__c != oldPE.SIF_AcademicSupportNeeds__c ||
                pe.SIF_SummerSchoolCourses__c != oldPE.SIF_SummerSchoolCourses__c ||
                pe.SIFStudentRetained__c != oldPE.SIFStudentRetained__c ||
                pe.Final_Grade_Level__c != oldPE.Final_Grade_Level__c ||
                pe.WhyFlagged__c != oldPE.WhyFlagged__c ||
                pe.PORFlag__c != oldPE.PORFlag__c ||
                pe.HHPORFlag__c != oldPE.HHPORFlag__c ||
                pe.PriorWithdrawalFlag__c != oldPE.PriorWithdrawalFlag__c ||
                pe.HowStudentPlacementCompleted__c != oldPE.HowStudentPlacementCompleted__c ||
                pe.CounselingFlag__c != oldPE.CounselingFlag__c ||
                pe.WaitlistFlag__c != oldPE.WaitlistFlag__c ||
                pe.UserTechnologyFlag__c != oldPE.UserTechnologyFlag__c ||
                pe.DisciplinaryFlagOverride__c != oldPE.DisciplinaryFlagOverride__c ||
                pe.PrincipalGeneralFlag__c != oldPE.PrincipalGeneralFlag__c) {
                    programEnrollmentIds.add(pe.Id);
                }
        }
        
        /*if (programEnrollmentIds.size() > 0) {
            
            List<Annual_Student_Information__c> asis = [
                SELECT Id, Program_Enrollment__c FROM Annual_Student_Information__c
                WHERE Program_Enrollment__c IN : programEnrollmentIds
            ];
            NES_AnnualStudentInfoBusinessLogic.verifyAffiliationsComplete(asis);
        }
    }*/
    
    public static void updateFinalConfirmationDate(Map<Id, hed__Program_Enrollment__c > newMap, Map<Id, hed__Program_Enrollment__c > oldMap) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> updatedIds = new Set<Id>();
        Map<Id, Program_Grade_Level__c> programGradesMap = new Map<Id, Program_Grade_Level__c>();
        List<Opportunity> optyToUpdate = new List<Opportunity>();
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        List<Opportunity> optyList = new List<Opportunity>();
        // populate the updated enrollment IDs
        for (Id enrollmentId : oldMap.keySet()) {
            if (oldMap.get(enrollmentId).Final_Grade_Level__c != newMap.get(enrollmentId).Final_Grade_Level__c) {
                accountIds.add(oldMap.get(enrollmentId).hed__Account__c);
                updatedIds.add(enrollmentId);
            }
        }
        
        //Start: Ritvik/Ashish 12/02/2019 Code refactor
        if (accountIds.isEmpty() || updatedIds.isEmpty()) {
            return;
        }
        //End
        
        // Fetch programGrades associated with the account  where program finalgrade equals to gradelevel Name
        for (Id enrollmentId : updatedIds) {
            for (Program_Grade_Level__c programGrade : [
                select id,Grade_Level__r.Name,Second_Semester_Confirmation_Date__c,Academic_Program__c,
                Final_Confirmation_End_Date__c
                from Program_Grade_Level__C
                WHERE Academic_Program__c IN :accountIds
            ]) {
                System.debug('programGrade' + programGrade.Grade_Level__r.Name + '=====' + newMap.get(enrollmentId).Final_Grade_Level__c);
                if (newMap.get(enrollmentId).Final_Grade_Level__c == programGrade.Grade_Level__r.Name &&
                    newMap.get(enrollmentId).hed__Account__c == programGrade.Academic_Program__c) {
                        programGradesMap.put(enrollmentId, programGrade);
                    }
                
            }
            
        }
        
        //Start: Ritvik/Ashish 12/02/2019 Code refactor
        if (programGradesMap.isEmpty()) {
            return;
        }
        //End
        
        // Get The Latest Opportunity that is tagged to program enrollment and update opportunities
        for (hed__Program_Enrollment__c prEnrollment : [
            SELECT id, (
                SELECT id,
                Earliest_Final_Confirmation_Date__c,
                Program_Enrollment__c,Final_Semester_Indicator__c
                FROM Opportunities__r
                order by createdDate desc
                limit 1
            )
            FROM hed__Program_Enrollment__c
            WHERE ID IN :updatedIds
        ]) {
            if (programGradesMap.containsKey(prEnrollment.Id) && !prEnrollment.Opportunities__r.isEmpty() &&
                (prEnrollment.Opportunities__r[0].Earliest_Final_Confirmation_Date__c > programGradesMap.get(prEnrollment.Id).Second_Semester_Confirmation_Date__c) &&
                (prEnrollment.Opportunities__r[0].Final_Semester_Indicator__c == 'Second')) {
                    prEnrollment.Opportunities__r[0].Earliest_Final_Confirmation_Date__c = programGradesMap.get(prEnrollment.Id).Second_Semester_Confirmation_Date__c;
                    optyList.add(prEnrollment.Opportunities__r[0]);
                }
            if (programGradesMap.containsKey(prEnrollment.Id) && !prEnrollment.Opportunities__r.isEmpty() &&
                (prEnrollment.Opportunities__r[0].Earliest_Final_Confirmation_Date__c > programGradesMap.get(prEnrollment.Id).Final_Confirmation_End_Date__c) &&
                (prEnrollment.Opportunities__r[0].Final_Semester_Indicator__c == 'First')) {
                    
                    prEnrollment.Opportunities__r[0].Earliest_Final_Confirmation_Date__c = programGradesMap.get(prEnrollment.Id).Final_Confirmation_End_Date__c;
                    optyList.add(prEnrollment.Opportunities__r[0]);
                }
        }
        try {
            //Start: Ritvik/Ashish 12/02/2019 Code refactor
            update optyList;
            
            //End
        } catch (DmlException e) {
            logger.logException('updateFinalConfirmationDate', e);
            logger.saveLogs();
        }
    }
    
    /**
* Created By Anand on 12/10/2018
*Purpose: To call CalculateELLFlag Method on Update
*
*/
    public static void calculateELLFlag(List<hed__Program_Enrollment__c> progEnrollmentList, Map<Id, hed__Program_Enrollment__c> newMap, Map<Id, hed__Program_Enrollment__c> oldMap) {
        List<hed__Program_Enrollment__c> prgEnrollments = new List<hed__Program_Enrollment__c>();
        System.debug('calculateELLFlag');
        NES_BusinessLogicUtils bussLogicUtils = new NES_BusinessLogicUtils();
        if (newMap <> null && oldMap <> null && !newMap.isEmpty() && !oldMap.isEmpty()) {
            for (Id enrollmentId : oldMap.keyset()) {
                if (oldMap.get(enrollmentId).HLSStudentFlag__c != newMap.get(enrollmentId).HLSStudentFlag__c) {
                    
                    prgEnrollments.add(newMap.get(enrollmentId));
                }
            }
            if (!prgEnrollments.isEmpty()) {
                bussLogicUtils.calculateELLFlag(new List<Home_Language_Survey__c> (), new List<Annual_Student_Information__c>(), prgEnrollments);
            }
        } else if (progEnrollmentList <> null && !progEnrollmentList.isEmpty()) {
            bussLogicUtils.calculateELLFlag(new List<Home_Language_Survey__c> (), new List<Annual_Student_Information__c>(), progEnrollmentList);
            
        }
        
    }
    
    /**
* Created By Anushka on 12/11/2018
*Purpose: To calculate Entrance Age Eligibility Override on Update
*Param : @List<hed__Program_Enrollment__c>
*        @Map<Id,hed__Program_Enrollment__c>
*/
    public static void calculateEntranceAgeEligibilityOverride(List<hed__Program_Enrollment__c> newList, Map<Id, hed__Program_Enrollment__c> oldMap) {
        //Mark Membrino 11/5/2019  Per 114797, we are changing the way the age elig overview works and making it a formula.  We no
        //longer need this override method to be called.
        /*List<hed__Program_Enrollment__c> prgEnrollments = new List<hed__Program_Enrollment__c>();
        
        for (hed__Program_Enrollment__c progEnrollment : newList) {
            if (oldMap != null) {
                if (oldMap.get(progEnrollment.Id).EntranceAgeEligibility__c != progEnrollment.EntranceAgeEligibility__c && progEnrollment.EntranceAgeEligibilityOverride__c != 'Released') {
                    prgEnrollments.add(progEnrollment);
                }
            } else {
                if (progEnrollment.EntranceAgeEligibility__c != null && progEnrollment.EntranceAgeEligibilityOverride__c != 'Released') {
                    prgEnrollments.add(progEnrollment);
                }
            }
        }
        //End
        
        //Start: Ritvik/Ashish 12/02/2019 Code refactor
        if (!prgEnrollments.isEmpty()) {
            NES_BusinessLogicUtils.calculateEntranceAgeEligibilityOverrideReview(prgEnrollments);
        } */
        //End
    }
    
    
    /**
* Created By Ritvik 12/13/2018
*Purpose:To call calculateHighSchoolLTS function of NES_BusinessLOgicUtils on After Update
* @param newList,OldMap of program enrollment.
*/
    public static void populatecalculateHighSchoolLTS(Map<Id, hed__Program_Enrollment__c> oldMap, List<hed__Program_Enrollment__c> newList) {
        Set<Id> progEnrollIds = new Set<Id>();
        for (hed__Program_Enrollment__c programEnrollment : newList) {
            if (oldMap != null) {
                if (programEnrollment.LTS__c != oldMap.get(programEnrollment.Id).LTS__c || programEnrollment.DisciplinaryPastActions__c != oldMap.get(programEnrollment.Id).DisciplinaryPastActions__c ||
                    programEnrollment.Academic_Doc_Performance__c != oldMap.get(programEnrollment.Id).Academic_Doc_Performance__c ||
                    programEnrollment.Post_High_School_Plans_2__c != oldMap.get(programEnrollment.Id).Post_High_School_Plans_2__c ||
                    programEnrollment.First_Yr_Complete_HS_Coursework__c != oldMap.get(programEnrollment.Id).First_Yr_Complete_HS_Coursework__c ||
                    programEnrollment.SIFStudentRetained__c != oldMap.get(programEnrollment.Id).SIFStudentRetained__c) {
                        progEnrollIds.add(programEnrollment.Id);
                    }
            } else {
                if (programEnrollment.LTS__c != null || programEnrollment.DisciplinaryPastActions__c != null ||
                    programEnrollment.Academic_Doc_Performance__c == 'Yes' ||
                    programEnrollment.Post_High_School_Plans_2__c != null || programEnrollment.First_Yr_Complete_HS_Coursework__c == 'Yes' ||
                    programEnrollment.SIFStudentRetained__c == 'Yes') {
                        progEnrollIds.add(programEnrollment.Id);
                    }
            }
        }
        if (!progEnrollIds.isEmpty()) {
            NES_BusinessLogicUtils.calculateHighSchoolLTS(progEnrollIds);
        }
    }
    
    
    /**
* Created By Anushka on 12/18/2018
* Purpose : To call the calculateLTS method in the NES_BusinessLogicUtils class after Update.
* Param : @Map<Id,hed__Program_Enrollment__c >, Map of old values before update.
*         @List<hed__Program_Enrollment__c >, List of record inserted or updated values.
*/
    
    public static void calculateLTS(Map<Id, hed__Program_Enrollment__c > oldMap, List<hed__Program_Enrollment__c > newList) {
        
        Set<Id> ids = new Set<Id>();
        for (hed__Program_Enrollment__c pe : newList) {
            //Start : Code refactor by Ritvik on 01/08/2019
            if (oldMap != null) {
                if (pe.LastSchoolType__c != oldMap.get(pe.Id).LastSchoolType__c || pe.Stress_Factors__c != oldMap.get(pe.Id).Stress_Factors__c
                    || pe.DisciplinaryPastActions__c != oldMap.get(pe.Id).DisciplinaryPastActions__c)
                    ids.add(pe.Id);
            } else {
                if (pe.LastSchoolType__c != null || pe.Stress_Factors__c != null
                    || pe.DisciplinaryPastActions__c != null)
                    ids.add(pe.Id);
            }
            //End
        }
        
        //Start: Ritvik/Ashish 12/02/2019 Code refactor
        if (!ids.isEmpty()) {
            List<hed__Program_Enrollment__c> programEnrollments = NES_LTSUtility.calculateLTS(ids);
            
            if (programEnrollments != null && programEnrollments.size() > 0) {
                try {
                    update programEnrollments;
                } catch(Exception e) {
                    logger.logException('calculateLTS', e);
                    logger.saveLogs();
                    throw e;
                }
            }
        }
        //End
    }
    
    //Start: code by Viswa for #167639 User Story (Alternative Shipping Address Case Workflow) on 2020-04-24
    
    //New method for determining if the student needs an alternate shipping address.
    //This will only get passed student PEs that were just set to a status of 'Complete' 
    
    public static void updateHHPEOrderHold(set<Id> PEsToCheck) {
        // We need.  
        // 1. Alt shipping address fields  hed__Contact__r.account.Alt_Shipping_Street_1__c  Alt_Shipping_City__c
        // 2. Household PE   (Household_Program_Enrollment__c)
        
        set<id> householdPEsToUpdateSet  = new set<id>();
        list<hed__Program_Enrollment__c> HouseHoldPEsToUpdateList= new list<hed__Program_Enrollment__c>();
        
        list<case> casesToCreate = new list<case>();
        for (hed__Program_Enrollment__c newPE : [select id,Household_Program_Enrollment__c,hed__Contact__c,
                                                     OrderingHoldFlag__c,OrderingHoldDate__c,
                                                     hed__Contact__r.account.Alt_Shipping_City__c,hed__Contact__r.account.Alternative_Address_Request__c
                                                     from hed__Program_Enrollment__c
                                                     where id in :PEsToCheck]) {
                                                    
            if (newPE.hed__Contact__r.account.Alternative_Address_Request__c == 'Yes')
            {
           //for all the household pes that we found, we should update the OrderingHoldFlag__c to 'Alternate Shipping' and the OrderingHoldDate__c to today
            hed__Program_Enrollment__c newEP ;
            newEP= new hed__Program_Enrollment__c();
            newEP.id=newPE.Household_Program_Enrollment__c;                                                      
            newEP.OrderingHoldFlag__c = 'Alternate Shipping';
            newEP.OrderingHoldDate__c = System.now().date();
            
            HouseHoldPEsToUpdateList.add(newEP);
            system.debug('newPE+++++'+newEP);
            //Create a case to notify the shipping team there is a new student that has an alternate address.
            Case objcase = new Case();
            objcase.Type='Fulfillment';
            objcase.Ticket_Type__c='Request ST Materials';
            objcase.Ticket_Sub_Type__c='Alternate Shipping';
            objcase.Description='Care Taker request to have equipment and materials sent to an alternative shipping address';
            objcase.Subject='Alternative Shipping Address Requested';
            objcase.OwnerId=System.Label.NES_Fulfillment_Queue;
            objcase.Platform__c = 'Pearson Connexus';
            objcase.Origin = 'Enrollment Community'; //Mohammad Shaik-Based on picklist value api name change for US : 183731
            objcase.System_of_Origin__c='New Enrollment';
            objcase.ContactId = newPE.hed__Contact__c;
            casesToCreate.add(objcase);
               
         }
       }
       system.debug('HouseHoldPEsToUpdateList==='+HouseHoldPEsToUpdateList);
        if (HouseHoldPEsToUpdateList.size() > 0 )
            database.Update(HouseHoldPEsToUpdateList, false);
            
        
        system.debug('casesToCreate+++++'+casesToCreate);
        if (casesToCreate.size() > 0 )
           database.insert(casesToCreate, false);
          
    }
    //Added code by Maddileti Boya for #194222 User Story on 2020-06-15 
    public static void updateASIForCompletedPEs(set<Id> pesToProcess) {
        List<hed__Program_Enrollment__c> programEnrollments = new List<hed__Program_Enrollment__c>([
            SELECT Id, Start_Year__c,
            (SELECT Id, Potential_Child_Find__c,Potential_Child_Find_Detailed_Log__c,
                    School_Year__c, Program_Enrollment__r.Start_Year__c  FROM Annual_Student_Information__r),
            (SELECT Id, Program_Enrollment__c, IEPLastUpdated__c,Plan504History__c,
                    IEPHistory__c, HasStudentEverHad504Plan__c, EvaluatedWithinLastYear__c  FROM Special_Educations__r)
            FROM hed__Program_Enrollment__c
            WHERE Id in :pesToProcess
        ]);        

        //Some Variables/Collections to Work with
        Map<Id, Annual_Student_Information__c> progEnrollmentToAsiMap = new Map<Id, Annual_Student_Information__c>();
        Map<Id, Special_Education__c> specialEducationMap = new Map<Id, Special_Education__c>();

        for(hed__Program_Enrollment__c pe : programEnrollments) {
            if(pe.Annual_Student_Information__r != null){
                for(Annual_Student_Information__c asi : pe.Annual_Student_Information__r){
                    if(asi.School_Year__c != null && asi.Program_Enrollment__r.Start_Year__c != null && asi.School_Year__c == asi.Program_Enrollment__r.Start_Year__c){
                        progEnrollmentToAsiMap.put(asi.Program_Enrollment__c, asi);
                        
                    }
                }
            }

            if(pe.Special_Educations__r != null){
                for (Special_Education__c specialEducation : pe.Special_Educations__r) {
                    specialEducationMap.put(specialEducation.Program_Enrollment__c, specialEducation);
                }
            }
        }
        
         List<Annual_Student_Information__c> updateAsi=new List<Annual_Student_Information__c>();
        
        for(hed__Program_Enrollment__c pe : programEnrollments) {
            //Added below if condition as part of US228767 (Jagadish Babu)  to avoid Null exception when ASI or specED not present
            if(progEnrollmentToAsiMap.containsKey(pe.Id) && specialEducationMap.containsKey(pe.Id)){
                 Annual_Student_Information__c asi = progEnrollmentToAsiMap.get(pe.Id);
                 Special_Education__c specEd = specialEducationMap.get(pe.Id);                         
                 //Make sure we have an ASI and a specEd recorder to work with.
                if (specEd <> null && String.isBlank(asi.Potential_Child_Find__c) && (specEd.IEPLastUpdated__c !='Within the last year' && specEd.IEPLastUpdated__c !='Within the last two years' && specEd.IEPLastUpdated__c !='Within the last three years' 
                       || specEd.Plan504History__c !='Yes') && (specEd.IEPHistory__c =='Decline to Disclose' || specEd.HasStudentEverHad504Plan__c =='Decline to Disclose' || specEd.EvaluatedWithInLastYear__c =='Decline to Disclose' || specEd.EvaluatedWithInLastYear__c =='Yes'))
                   {
     
                     asi.Potential_Child_Find__c ='Yes';
                     asi.Potential_Child_Find_Detailed_Log__c ='Caretaker reports student has been evaluated in the last year, but did not indicate that the student has an IEP or Section 504 Plan or the caretaker declined to disclose.';
                     updateAsi.add(asi);
                  } 
            }                                   
        }
        logger.logInfo('updateASIForCompletedPEs', String.valueOf(updateAsi));
        //Added below if condition as part of US228767 (Jagadish Babu) to update only if list has records and exception handling
        if(updateAsi.size() > 0){
            try{
                update updateAsi;
            }catch (Exception e) {
                logger.logException('updateASIForCompletedPEs', e);
                logger.saveLogs();
                System.debug('Exception Thrown::' + e.getMessage());
            }
        }
            
          
    }
    //End code by Maddileti Boya for #194222 User Story on 2020-06-15 
    /**
* @author : Ajith on 02/13/2018
* @Method : updateEnrollmentCapacity
* @Params : newList and OldMap of Program Enrollments
* @Purpose : To update the No of Enrolled students on the cap grades levels
*            associated to a PE when marked as completed
* @return : void
*/
    public static void updateEnrollmentCapacity(Map<Id, hed__Program_Enrollment__c> oldMap, List<hed__Program_Enrollment__c> newList) {
        Set<Id> academicProgramIdsToRecalc = new Set<Id>();
        Set<String> gradesToRecalc = new Set<String>();
        
        for (hed__Program_Enrollment__c pe : newList) {
            if (oldMap != null) {
                hed__Program_Enrollment__c oldPe = oldMap.get(pe.Id);
                if (oldPe.Status__c != pe.Status__c &&
                    (pe.Status__c == NES_Constants.PE_STATUS_COMPLETE || oldPe.Status__c == NES_Constants.PE_STATUS_COMPLETE)) {
                        
                        academicProgramIdsToRecalc.add(pe.hed__Account__c);
                        gradesToRecalc.add(pe.Final_Grade_Level__c);
                    }
            }
        }
        
        if (academicProgramIdsToRecalc.isEmpty()) {
            return;
        }
        
        Map<String, Integer> academicProgramGradeCountMap = new Map<String, Integer>();
        for (AggregateResult ar : [
            select Final_Grade_Level__c, hed__Account__c, count(Id) cnt
            from hed__Program_Enrollment__c
            where hed__Account__c in :academicProgramIdsToRecalc
            and Status__c = :NES_Constants.PE_STATUS_COMPLETE
            group by Final_Grade_Level__c, hed__Account__c
        ]) {
            
            String key = (Id) ar.get('hed__Account__c') + ';' + (String) ar.get('Final_Grade_Level__c');
            academicProgramGradeCountMap.put(key, (Integer) ar.get('cnt'));
        }
        logger.logInfo('updateEnrollmentCapacity', String.valueOf(academicProgramGradeCountMap));
        
        List<Cap_Grade_Level__c> capGradeLevelsToUpdate = new List<Cap_Grade_Level__c>();
        List<Program_Grade_Level__c> programGradeLevelsToUpdate = new List<Program_Grade_Level__c>();
        for (Program_Grade_Level__c gradeLevel : [
            SELECT Id, Grade_Level__r.Name, Academic_Program__c, Number_of_Enrolled_Students__c,
            (SELECT Id, Number_of_Enrolled_Students__c FROM Cap_Grade_Levels__r)
            FROM Program_Grade_Level__c
            WHERE Academic_Program__c IN :academicProgramIdsToRecalc
            and Grade_Level__r.Name IN :gradesToRecalc
        ]) {
            
            String key = gradeLevel.Academic_Program__c + ';' + gradeLevel.Grade_Level__r.Name;
            Integer numEnrolledStudents = academicProgramGradeCountMap.containsKey(key) ? academicProgramGradeCountMap.get(key) : 0;
            
            gradeLevel.Number_of_Enrolled_Students__c = numEnrolledStudents;
            programGradeLevelsToUpdate.add(gradeLevel);
            
            for (Cap_Grade_Level__c cap : gradeLevel.Cap_Grade_Levels__r) {
                cap.Number_of_Enrolled_Students__c = numEnrolledStudents;
                capGradeLevelsToUpdate.add(cap);
            }
            logger.logInfo('updateEnrollmentCapacity', String.valueOf(capGradeLevelsToUpdate));
        }
        
        if (programGradeLevelsToUpdate.size() > 0) {
            try {
                update programGradeLevelsToUpdate;
            } catch (Exception e) {
                logger.logException('updateEnrollmentCapacity', e);
                logger.saveLogs();
                System.debug('Exception Thrown::' + e.getMessage());
            }
        }
        
        if (capGradeLevelsToUpdate.size() > 0) {
            try {
                update capGradeLevelsToUpdate;
            } catch (Exception e) {
                logger.logException('updateEnrollmentCapacity', e);
                logger.saveLogs();
                System.debug('Exception Thrown::' + e.getMessage());
            }
        }
        
    }
    /*    
**Change Log: Added code by Anitha P for #107180 User Story (Task 108660) on 2019-09-06  
* Purpose   : Update ASI Academic document Summary values based on PE statuses.
* Added code by Anitha P for #107180 User Story (Bug  110762) on 2019-09-06 
*/
    //Start-added for #107180 User Story (Task 108660) on 2019-09-06
  /* public static void updateAnnualStudStatus( List<hed__Program_Enrollment__c > newList) {
        
        if ( newlist.size()>0 ) {
            map<id,string> peIdsAndYear = new map<id,string> (); 
            map<Id,Id> annStIds =  new map<id,id>();
            map<Id,hed__Program_Enrollment__c> peList =  new map<id,hed__Program_Enrollment__c>();
            List<hed__Program_Enrollment__c > matchedPeIds = new  List<hed__Program_Enrollment__c >();
            hed__Program_Enrollment__c peRecord = new hed__Program_Enrollment__c ();
            list<Annual_Student_Information__c> annStList = new list<Annual_Student_Information__c>();
            Annual_Student_Information__c annStudent = new Annual_Student_Information__c();
            //map values of PE's and AIS's 
            for( hed__Program_Enrollment__c  peId: newList){
                peIdsAndYear.put( peId.Id, peId.start_year__c );
            } 
            //added logic for bug 110762 to determine the academic documentations Summary
            for( hed__Program_Enrollment__c  peId: [select id,PAHStatus__c,RCStatus__c,UTStatus__c from hed__Program_Enrollment__c where id in:peIdsAndYear.keyset()]){    
                peList.put(peId.Id,peId);   
            } 
            
           //Fetch Annaul info Students of PE's whose School year is same as PE's start year.
            for( Annual_Student_Information__c asi : [SELECT Id, Program_Enrollment__c,Academic_Documentation_Summary__c
                                                      FROM Annual_Student_Information__c WHERE Program_Enrollment__c IN : peIdsAndYear.keyset()
                                                      and School_year__c IN: peIdsAndYear.values() ]){
                                                          annStIds.put(asi.Program_Enrollment__c, asi.id);
                                                          peRecord =  peList.get(asi.Program_Enrollment__c) ;
                                                          matchedPeIds.add(peRecord);                 
                                                      }
            //Update Annual info student Academic document Summary values based on PE statuses
            if (matchedPeIds.size()>0){
                for ( hed__Program_Enrollment__c peIds :matchedPeIds)
                {
                    //changed existing logic for the bug 110762 to determine the academic documentations Summary 
                    if ( !String.isEmpty(peIds.UTStatus__c) &&!String.isEmpty( peIds.RCStatus__c) && !String.isEmpty(peIds.PAHStatus__c)) {
                        if((peIds.RCStatus__c.contains('Received') ||peIds.UTStatus__c.contains('Received')|| peIds.PAHStatus__c.contains('Received'))  
                           && (peIds.RCStatus__c.contains('Received') || peIds.RCStatus__c.contains('Verified')|| peIds.RCStatus__c == null)
                           && (peIds.UTStatus__c.contains('Received') || peIds.UTStatus__c.contains('Verified') || peIds.UTStatus__c == null)
                           && (peIds.PAHStatus__c.contains('Received') || peIds.PAHStatus__c.contains('Verified') || peIds.PAHStatus__c == null)){  
                               if(annStIds!= null){ 
                                   annStudent.id = annStIds.get(peIds.Id);
                               }
                               annStudent.Academic_Documentation_Summary__c = 'Received';
                               annStList.add(annStudent);  
                           }else if((peIds.RCStatus__c.contains('Verified') ||peIds.UTStatus__c.contains('Verified')|| peIds.PAHStatus__c.contains('Verified'))  
                                    && (peIds.RCStatus__c.contains('Verified')  || peIds.RCStatus__c== null)
                                    && (peIds.UTStatus__c.contains('Verified')  || peIds.UTStatus__c== null)
                                    && (peIds.PAHStatus__c.contains('Verified') || peIds.PAHStatus__c == null)){
                                        if(annStIds!= null){ 
                                            annStudent.id = annStIds.get(peIds.Id);
                                    }         
                                        annStudent.Academic_Documentation_Summary__c = 'Verified';
                                        annStList.add(annStudent);  
                                    }  
                    }
                }
            }
            //Updated Annual student Academic document Summary
            system.debug(annStList);
            if (annStList.size() > 0) {
                try {
                    update annStList;               
                } catch (Exception ex) {
                    System.debug('Exception Thrown : ' + ex.getMessage());
                    logger.logException('updateSObjects', ex);
                    logger.saveLogs();
                }
            }        
        }
    }*/
    //End-added for #107180 User Story (Task 108660) on 2019-09-06
}