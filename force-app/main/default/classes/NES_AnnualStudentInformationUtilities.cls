/**
* Created by Ritvik on 22/11/18.
* Purpose : Method to re-populate or update Annual Student Information record Student Placement Bucket field.
* Param : @AsiList list of Asi record id which needs to be updated.
*Change Log:
* -Added code by Anitha P on 30/07/2019 for Placement Bucket field vlaues 'Student Counselor' for user story 101931.
* -Added logic by Anitha P for Placement Bucket field vlaues 'Parent' for user story #105712 on 06/09/2019 
* -Updated placement logic for User Story #USXXX (Andrew Sim/Mark Membrino)
* -Added other Age Eligibility fields needed for calcuations US114797 (Andrew Sim) on 11/05/19
*/

public without sharing class  NES_AnnualStudentInformationUtilities {
    
    private static Peak_ApexLog logger = new Peak_ApexLog('AnnualStudentInformationUtilities');
    static Boolean isStudentPlacementBucketFire = true;
    
    public static void recalculateStudentPlacementBucket(List<Annual_Student_Information__c> asiList, Boolean firedFromASI) {
        //System.debug('in recalculateStudentPlacementBucket'+asiList+'firedFromASI'+firedFromASI);
        
        Set<Id> progEnrollIds = new Set<Id>();
        // if a single ASI change triggers, this, we need all ASIs related to the parent PEs
        for (Annual_Student_Information__c asi : asiList) {
            progEnrollIds.add(asi.Program_Enrollment__c);
        }
        List<Annual_Student_Information__c> newasis = [SELECT Id, Program_Enrollment__c,Program_Enrollment__r.hed__Account__r.AutomatedPlacementMaxCutoff__c,Program_Enrollment__r.Start_Year__r.Current_Year__c,
                                                       Academic_Documentation_Summary__c,Grade_Level_Completed__c,AutomatedPlacementScore__c,AutomatedPlacementExclude__c,School_Year__r.Start_Date__c, LA_Placement_Level__c, Program_Enrollment__r.WaitlistFlag__c, Program_Enrollment__r.WhyFlagged__c,
                                                       HowStudentPlacementCompleted__c, CoursesFinalized__c, Math_Placement_Level__c, Science_Placement_Level__c, Grade_Level_Requested__c, RecommendedAutoPlacement__c,
                                                       Final_Grade_Level__c, GiftedProgramRequest_LA_M_S__c, Program_Enrollment__r.Start_Year__r.Start_Date__c, School_Year__c, APS_PlacedTimeStamp__c
                                                       FROM Annual_Student_Information__c WHERE Program_Enrollment__c IN : progEnrollIds];
        
        List<Annual_Student_Information__c> annualStudentInformationsRecordList = new List<Annual_Student_Information__c>();
        Map<Id, hed__Program_Enrollment__c> programEnrollmentMap = new Map<Id, hed__Program_Enrollment__c>();
        Map<Id, Annual_Student_Information__c> previousASIMap = new Map<Id, Annual_Student_Information__c>();
        List<Annual_Student_Information__c> tempASIs = new List<Annual_Student_Information__c>();
        
        for (Annual_Student_Information__c asiRecord : newasis) {
            System.debug('asiRecord'+asiRecord);
            
            if (asiRecord.School_Year__r.Start_Date__c <> null && asiRecord.Program_Enrollment__r.Start_Year__r.Start_Date__c <> null &&
                asiRecord.School_Year__r.Start_Date__c == asiRecord.Program_Enrollment__r.Start_Year__r.Start_Date__c.addYears(-1))
            {
                previousASIMap.put(asiRecord.Program_Enrollment__c, asiRecord);
            } else {
                tempASIs.add(asiRecord);
                System.debug('tempASIs'+tempASIs);
            }
        }
        
        System.debug('progEnrollIds>>>' + progEnrollIds);
        
        if (progEnrollIds.isEmpty()) {
            return;
        }
        //
        set<id> schid = new set<id>();
        //
        
        for (hed__Program_Enrollment__c progEnrollRecord : [
            SELECT Id,Start_Year__c,Start_Year__r.Start_Date__c,Start_Year__r.End_Date__c,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,GradeLevelEligibility__c,PriorSchoolAttendanceElg__c,
            HomeschoolMembershipElg__c,AcademicPerformanceEligibility__c,CohortEligibility__c,WhyFlagged__c,PlacementFlag__c,HomelessRiskFlag__c,
            EnrollmentSpecialistContactReq__c,MoreHighSchoolDocumentation__c,CreditByExamScores__c,HomeSchoolEvaluatorReport__c, Status__c,RCStatus__c,
            UTStatus__c,PAHStatus__c,
            hed__Account__r.AutomatedPlacementMaxCutoff__c,
//MM No longer needed?            (SELECT IEP__c FROM Special_Educations__r ORDER BY CreatedDate DESC LIMIT 1),
//MM No longer needed?            (SELECT Type__c,Status_Reason__c FROM Enrollment_Documents__r WHERE Type__c = 'Individualized Education Program' ORDER BY Submission_Time__c DESC LIMIT 1),
            (SELECT Document_Type__c, Status__c FROM Enrollment_Component_Affiliation__r where Enrollment_Component__r.Is_Required__c = true)
            FROM hed__Program_Enrollment__c
            WHERE Id IN :progEnrollIds
        ]) {
            programEnrollmentMap.put(progEnrollRecord.Id, progEnrollRecord);
            
        }
        
        //Start-added for #105712 User Story (Task 108006) on 2019-09-03
        map<string,id> edType = new map<string,id>();
        map<id,string> edStatus = new map<id,string>();
        map<id,id> edPeds = new map<id,id>();
        Map<Id,List<Enrollment_Document__c>> ECA_EnrollDoclist = new Map<Id,List<Enrollment_Document__c>> ();
        //Fetch all relavent Docments related to program enromments for required document types
        for(Enrollment_Document__c dL : [Select id, Type__c, Status_Reason__c, Enrollment_Component_Affiliation__c
                                                    from Enrollment_Document__c
                                                    where Program_Enrollment__c IN:programEnrollmentMap.keyset() 
                                                    order by Enrollment_Component_Affiliation__c
                                                    ])
        {
            //edType.put( documentsList.Type__c,documentsList.id );
            //edStatus.put( documentsList.id,documentsList.Status_Reason__c);   
            //edPeds.put(documentsList.program_Enrollment__c,documentsList.id);

            //Build  a map between the ECA and the list of documents tied to that ECA so we can determine if a document is required
            //on a Program Enrollment that it is actually been uploaded.
            List<Enrollment_Document__c> docsThisECA = ECA_EnrollDoclist.get(dL.Enrollment_Component_Affiliation__c);

            if (docsThisECA == null)
            {
                docsThisECA = new List<Enrollment_Document__c> ();
                ECA_EnrollDoclist.put(dL.Enrollment_Component_Affiliation__c, docsThisECA);
            }
            docsThisECA.add(new Enrollment_Document__c(id = dL.Id, Type__c = dL.Type__c, Status_Reason__c = dL.Status_Reason__c, Enrollment_Component_Affiliation__c = dL.Enrollment_Component_Affiliation__c));
        }
        
        //End-added for #105712 User Story (Task 108006) on 2019-09-03
        
        System.debug('programEnrollmentMap>>>>' + programEnrollmentMap);
        
        if (programEnrollmentMap.isEmpty()) {
            return;
        }
        
        System.debug('previousASI>>>>' + previousASIMap);
        for (Annual_Student_Information__c asiRecord : tempASIs) {
            if (!programEnrollmentMap.containsKey(asiRecord.Program_Enrollment__c) ||
                programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Start_Year__c == null ||
                programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Start_Year__r.Start_Date__c == null){
                                  continue;
                }
            System.debug('Inside logic '+asiRecord);
            String cohort = 'Cohort '+String.valueOf(programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Start_Year__r.Start_Date__c.year()-2) + '-' + String.valueOf(programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Start_Year__r.Start_Date__c.year()-1) + ' or earlier';
            System.debug('cohort+++++'+cohort);
            Integer startYear = programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Start_Year__r.Start_Date__c.year();
            
            if(programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Enrollment_Documents__r<> null &&
               !programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Enrollment_Documents__r.isEmpty()){
                   System.debug('enrollmentsDocSize==>>'+programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Enrollment_Documents__r.size());
                   System.debug('enrollmentsDocSize==>>'+programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Enrollment_Documents__r.size());
                   System.debug('DocType==>>'+programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Enrollment_Documents__r.get(0).Type__c);
                   System.debug('StatusReason==>>'+programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Enrollment_Documents__r.get(0).Status_Reason__c );
               }
            System.debug('isMatch==>>'+ isMatch(asiRecord.Academic_Documentation_Summary__c, 'Verified', false));
            System.debug('docSummary'+asiRecord.Academic_Documentation_Summary__c);
            System.debug('gradeLevelrequested==>>'+asiRecord.Grade_Level_Requested__c);
            System.debug('StartYear==>>'+asiRecord.Program_Enrollment__r.Start_Year__r.Start_Date__c);
            System.debug('previousASI==>>'+previousASIMap.get(asiRecord.Program_Enrollment__c));
            System.debug('placementFlag==>>'+programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PlacementFlag__c);
            String whyFlagged = programEnrollmentMap.get(asiRecord.Program_Enrollment__c).WhyFlagged__c;
            if(whyFlagged == null) {
                whyFlagged = '123';
            }
            
            // for optimization purposes
            hed__Program_Enrollment__c peObj = programEnrollmentMap.get(asiRecord.Program_Enrollment__c);
            
            //3 - 'Eligibility- Ineligible'
            System.debug(programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PlacementFlag__c);
            if (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).EntranceAgeEligibilityFinal__c == 'Ineligible' ||
                programEnrollmentMap.get(asiRecord.Program_Enrollment__c).GradeLevelEligibility__c == 'Ineligible' ||
                programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PriorSchoolAttendanceElg__c == 'Ineligible' ||
                programEnrollmentMap.get(asiRecord.Program_Enrollment__c).HomeschoolMembershipElg__c == 'Ineligible' ||
                programEnrollmentMap.get(asiRecord.Program_Enrollment__c).AcademicPerformanceEligibility__c == 'Ineligible' ||
                programEnrollmentMap.get(asiRecord.Program_Enrollment__c).CohortEligibility__c == 'Ineligible') {
                    asiRecord.StudentPlacementBucket__c = 'Eligibility- Ineligible';
                    annualStudentInformationsRecordList.add(asiRecord);
                }
            //5 - 'Eligibility- Pending Review'
            else if (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).EntranceAgeEligibilityFinal__c == 'Pending Review' ||
                     programEnrollmentMap.get(asiRecord.Program_Enrollment__c).GradeLevelEligibility__c == 'Pending Review' ||
                     programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PriorSchoolAttendanceElg__c == 'Pending Review' ||
                     programEnrollmentMap.get(asiRecord.Program_Enrollment__c).HomeschoolMembershipElg__c == 'Pending Review' ||
                     programEnrollmentMap.get(asiRecord.Program_Enrollment__c).AcademicPerformanceEligibility__c == 'Pending Review' ||
                     programEnrollmentMap.get(asiRecord.Program_Enrollment__c).CohortEligibility__c == 'Pending Review') {
                         asiRecord.StudentPlacementBucket__c = 'Eligibility- Pending Review';
                         annualStudentInformationsRecordList.add(asiRecord);
                     }
            //6 - 'Eligibility- Pending'
            // removed unnecessary cohort logic (Andrew Sim) #USXXX
            else if (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).EntranceAgeEligibilityFinal__c == 'Pending' ||
                     programEnrollmentMap.get(asiRecord.Program_Enrollment__c).GradeLevelEligibility__c == 'Pending' ||
                     programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PriorSchoolAttendanceElg__c == 'Pending' ||
                     programEnrollmentMap.get(asiRecord.Program_Enrollment__c).HomeschoolMembershipElg__c == 'Pending' ||
                     programEnrollmentMap.get(asiRecord.Program_Enrollment__c).AcademicPerformanceEligibility__c == 'Pending' ||
                     programEnrollmentMap.get(asiRecord.Program_Enrollment__c).CohortEligibility__c == 'Pending') {
                          asiRecord.StudentPlacementBucket__c = 'Eligibility- Pending';
                          annualStudentInformationsRecordList.add(asiRecord);
                      }
            //7 - 'Parent - Call APS'
            // removed WYCA logic (Andrew Sim) #USXXX
            else if (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PlacementFlag__c == 'Awaiting Communication- More Info' ||
                     programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PlacementFlag__c == 'Awaiting Communication- Retain') {
                         asiRecord.StudentPlacementBucket__c = 'Parent - Call APS';
                         annualStudentInformationsRecordList.add(asiRecord);
                     }
            //8 - 'Parent - Enrollment Specialist'
            else if (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).EnrollmentSpecialistContactReq__c == 'Pending Review') {
                asiRecord.StudentPlacementBucket__c = 'Parent - Enrollment Specialist';
                annualStudentInformationsRecordList.add(asiRecord);
            }
            //9 - 'Parent - School Counselor'
            else if (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PlacementFlag__c == 'Awaiting Communication- School Counselor') {
                asiRecord.StudentPlacementBucket__c = 'Parent - School Counselor';
                annualStudentInformationsRecordList.add(asiRecord);
            }
            //10 - 'Placed - Auto Placed K8'
            // removed modified auto-placement process,school recommmended auto-placement (Andrew Sim) #USXXX
            // inverted grade level logic for efficiency (Andrew Sim) #USXXX
            else if (asiRecord.HowStudentPlacementCompleted__c == 'Standard Auto-Placement Process' &&
                     asiRecord.CoursesFinalized__c == 'Yes' &&
                     (asiRecord.Final_Grade_Level__c != '9' &&
                      asiRecord.Final_Grade_Level__c != '10' &&
                      asiRecord.Final_Grade_Level__c != '11' &&
                      asiRecord.Final_Grade_Level__c != '12')) {
                          asiRecord.StudentPlacementBucket__c = 'Placed - Auto Placed K8';
                          annualStudentInformationsRecordList.add(asiRecord);
                      }
            //11 - 'Placed - K8'
            // inverted grade level logic for efficiency (Andrew Sim) #USXXX
            else if (asiRecord.CoursesFinalized__c == 'Yes' &&
                     ((asiRecord.Final_Grade_Level__c != '9' &&
                      asiRecord.Final_Grade_Level__c != '10' &&
                      asiRecord.Final_Grade_Level__c != '11' &&
                      asiRecord.Final_Grade_Level__c != '12'))) {
                          asiRecord.StudentPlacementBucket__c = 'Placed - K8';
                          annualStudentInformationsRecordList.add(asiRecord);
                      }
            //12 - 'Placed – Auto Placed High School'
            // removed auto placed high school bucket (Andrew Sim) #USXXX
            /*
            else if (asiRecord.HowStudentPlacementCompleted__c == 'Modified Auto-Placement Process' &&
                     asiRecord.CoursesFinalized__c == 'Yes' &&
                     (asiRecord.Final_Grade_Level__c == '9' ||
                      asiRecord.Final_Grade_Level__c == '10' ||
                      asiRecord.Final_Grade_Level__c == '11' ||
                      asiRecord.Final_Grade_Level__c == '12')) {
                          asiRecord.StudentPlacementBucket__c = 'Placed – Auto Placed High School';
                          annualStudentInformationsRecordList.add(asiRecord);
                      }
            */
            //13 - 'Placed – High School'
            else if (asiRecord.CoursesFinalized__c == 'Yes' &&
                     (asiRecord.Final_Grade_Level__c == '9' ||
                      asiRecord.Final_Grade_Level__c == '10' ||
                      asiRecord.Final_Grade_Level__c == '11' ||
                      asiRecord.Final_Grade_Level__c == '12')) {
                          asiRecord.StudentPlacementBucket__c = 'Placed – High School';
                          annualStudentInformationsRecordList.add(asiRecord);
                      }
            //14 - 'Placement - Auto-Placement in Progress'
            else if (asiRecord.AutomatedPlacementScore__c != null &&
                     asiRecord.AutomatedPlacementScore__c <= programEnrollmentMap.get(asiRecord.Program_Enrollment__c).hed__Account__r.AutomatedPlacementMaxCutoff__c &&
                     asiRecord.AutomatedPlacementExclude__c != true && 
                     programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Status__c == 'In Progress') {
                         asiRecord.StudentPlacementBucket__c = 'Placement - Auto-Placement in Progress';
                         annualStudentInformationsRecordList.add(asiRecord);
                     }
            //15 - 'Principal'
            // move to after 14 (Andrew Sim) #USXXX
            // remove HomelessRiskFlag__c check  (Andrew Sim) #USXXX
            // remove PlacementFlag__c check for 'Principal Review- Awaiting Feedback' (Andrew Sim) #USXXX
            else if (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PlacementFlag__c == 'Principal Review' ||
                     programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PlacementFlag__c == 'Principal Review- Gifted' ||
                     whyFlagged.contains('Prior Withdrawal') ||
                     whyFlagged.contains('Disciplinary History')) {
                         asiRecord.StudentPlacementBucket__c = 'Principal';
                         annualStudentInformationsRecordList.add(asiRecord);
                     }
            // 15.5 - 'Parent'
            // new logic introduced (Andrew Sim) #USXXX
            //Start-added for #105712 User Story (Task 108006) on 2019-09-03
            //added logic for Student Parent bucket value 'Parent'.
            /*else if (((programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Special_Educations__r.size() > 0 && 
                      (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Special_Educations__r.get(0).IEP__c != 'IEP'&&
                       programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Special_Educations__r.get(0).IEP__c != 'Documenting'))&&
                       previousASIMap.size()> 0 &&
                      (asiRecord.Academic_Documentation_Summary__c != null && asiRecord.Academic_Documentation_Summary__c != 'Verified')&& 
                      (asiRecord.Grade_Level_Requested__c != 'K'&& previousASIMap.get(asiRecord.Program_Enrollment__c).Grade_Level_Completed__c != null)&&
                      (((edType.get('Individualized Education Plan') == Edpeds.get(asiRecord.Program_Enrollment__c ))&&
                      (edType.containskey('Individualized Education Plan')) && ( Edstatus.get(Edtype.get('Individualized Education Plan')) != 'Received'))||
                      ((edType.get('Evaluation') == Edpeds.get(asiRecord.Program_Enrollment__c))&& 
                      (edType.containskey('Evaluation'))&& (Edstatus.get(Edtype.get('Evaluation')) != 'Received'))|| 
                      ((edType.get('IEP Exit Documentation') == Edpeds.get(asiRecord.Program_Enrollment__c ))&& 
                      (edType.containskey('IEP Exit Documentation'))&& (Edstatus.get( Edtype.get('IEP Exit Documentation')) != 'Received'))))||
                      ((programEnrollmentMap.get(asiRecord.Program_Enrollment__c).RCStatus__c == 'Incomplete'||
                       programEnrollmentMap.get(asiRecord.Program_Enrollment__c).RCStatus__c =='Requested'|| 
                       programEnrollmentMap.get(asiRecord.Program_Enrollment__c).RCStatus__c =='Illegible'||
                       programEnrollmentMap.get(asiRecord.Program_Enrollment__c).RCStatus__c =='File Error')||
                      (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).UTStatus__c == 'Incomplete' || 
                       programEnrollmentMap.get(asiRecord.Program_Enrollment__c).UTStatus__c == 'Requested'||
                       programEnrollmentMap.get(asiRecord.Program_Enrollment__c).UTStatus__c == 'Illegible' ||
                       programEnrollmentMap.get(asiRecord.Program_Enrollment__c).UTStatus__c == 'File Error')||
                      (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PAHStatus__c  == 'Incomplete'||
                       programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PAHStatus__c  == 'Requested'|| 
                       programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PAHStatus__c  == 'Illegible'||
                       programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PAHStatus__c  == 'File Error'))||
                      ((edType.get('Re Eval Conference Form') == Edpeds.get(asiRecord.Program_Enrollment__c ))&&
                      (edType.containskey('Re Eval Conference Form')) && ((Edstatus.get(Edtype.get('Re Eval Conference Form')) != 'Submitted')||
                      (Edstatus.get(Edtype.get('Re Eval Conference Form')) != 'Invalid')))|| 
                      ((programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PlacementFlag__c != 'Principal Review- Complete' &&
                       programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PlacementFlag__c != 'Principal Review- Need Information') && 
                      ((edType.get('State Test Scores') == Edpeds.get(asiRecord.Program_Enrollment__c))&& (edType.containskey('State Test Scores'))))||
                      (((edType.get('Re Eval Conference Form') == Edpeds.get(asiRecord.Program_Enrollment__c))&& (edType.containskey('Re Eval Conference Form')) &&
                      ((Edstatus.get(Edtype.get('Re Eval Conference Form')) == 'Missing')||
                      ( Edstatus.get(Edtype.get('Re Eval Conference Form')) == 'Invalid') ||  (Edstatus.get(Edtype.get('Re Eval Conference Form')) == 'Illegible')))||
                      ((edType.get('Evaluation') == Edpeds.get(asiRecord.Program_Enrollment__c))&& (edType.containskey('Evaluation')) && 
                      ((Edstatus.get(Edtype.get('Evaluation')) == 'Missing')||
                      ( Edstatus.get(Edtype.get('Evaluation')) == 'Invalid') ||  (Edstatus.get(Edtype.get('Evaluation' )) == 'Illegible'))) ||
                      ((edType.get('IEP Exit Documentation') == Edpeds.get(asiRecord.Program_Enrollment__c))&& (edType.containskey('IEP Exit Documentation')) && 
                      ((Edstatus.get(Edtype.get('IEP Exit Documentation')) == 'Missing')||
                      ( Edstatus.get(Edtype.get('IEP Exit Documentation')) == 'Invalid') || (Edstatus.get(Edtype.get('IEP Exit Documentation')) == 'Illegible'))))||
                      ((programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PlacementFlag__c != 'Principal Review- Complete' &&
                       programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PlacementFlag__c != 'Principal Review- Need Information') && 
                      ((edType.get('Gifted Documentation') == Edpeds.get(asiRecord.Program_Enrollment__c ))&& (edType.containskey('Gifted Documentation')))))
            {
                asiRecord.StudentPlacementBucket__c = 'Parent';
                annualStudentInformationsRecordList.add(asiRecord);
            } */

            //new logic introduced (Mark Membrino) #USXXX
            else if (shouldAssignToParentBucket(asiRecord.Program_Enrollment__c, programEnrollmentMap, ECA_EnrollDoclist)) {
                asiRecord.StudentPlacementBucket__c = 'Parent';
                System.debug ('ASI record before going in the list.' + asiRecord);
                annualStudentInformationsRecordList.add(asiRecord);
                System.debug ('ASI update list.' + annualStudentInformationsRecordList);
            }


            //End-added for #105712 User Story (Task 108006) on 2019-09-03
            
            //16 - 'Special Education Director'
            // comment out old logic (Andrew Sim) #USXXX
/*            else if (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Enrollment_Documents__r.size() > 0 &&
                     programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Enrollment_Documents__r.get(0).Status_Reason__c != null &&
                     programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Enrollment_Documents__r.get(0).Status_Reason__c.contains('Received')) {
                         
                         if ((asiRecord.Academic_Documentation_Summary__c == 'Verified' ||
                              asiRecord.Academic_Documentation_Summary__c == 'Not Applicable' ||
                              ((asiRecord.Grade_Level_Requested__c == 'K' ||
                                asiRecord.Grade_Level_Requested__c == 'Kindergarten') &&
                               asiRecord.Program_Enrollment__r.Start_Year__r.Start_Date__c <> null &&
                               (!previousASIMap.isEmpty() && previousASIMap.containsKey(asiRecord.Program_Enrollment__c) &&
                                (previousASIMap.get(asiRecord.Program_Enrollment__c).Grade_Level_Completed__c == 'None- entering kindergarten for the first time.' ||
                                 (previousASIMap.get(asiRecord.Program_Enrollment__c).Grade_Level_Completed__c != null &&
                                  previousASIMap.get(asiRecord.Program_Enrollment__c).Grade_Level_Completed__c.contains('None- student was not enrolled during the'))) &&
                                (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PlacementFlag__c == 'Released' ||
                                 programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PlacementFlag__c == null)))) ||
                             programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Special_Educations__r.get(0).IEP__c == 'Documenting') {
*/                                 
            //new logic introduced (Andrew Sim) #USXXX
            else if (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PlacementFlag__c == 'Special Education Director') {
                                 asiRecord.StudentPlacementBucket__c = 'Special Education Director';
                                 annualStudentInformationsRecordList.add(asiRecord);
                             }
            //17 - 'School Counselor'
            // comment out old logic (Andrew Sim) #USXXX
/*            else if (((asiRecord.Grade_Level_Requested__c == '11' ||
                       asiRecord.Grade_Level_Requested__c == '12') &&
                      asiRecord.CoursesFinalized__c != 'Yes' &&
                      //Added code by Anitha P for 101931 user story
                      (asiRecord.Academic_Documentation_Summary__c != null && asiRecord.Academic_Documentation_Summary__c != 'Verified') &&
                      programEnrollmentMap.get(asiRecord.Program_Enrollment__c).MoreHighSchoolDocumentation__c != 'Documentation needed' &&
                      (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).CreditByExamScores__c == null ||
                       programEnrollmentMap.get(asiRecord.Program_Enrollment__c).CreditByExamScores__c == 'Not Applicable' ||
                       isMatch(programEnrollmentMap.get(asiRecord.Program_Enrollment__c).CreditByExamScores__c, 'Verified', false)) &&
                      (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).HomeSchoolEvaluatorReport__c == null ||
                       programEnrollmentMap.get(asiRecord.Program_Enrollment__c).HomeSchoolEvaluatorReport__c == 'Not Applicable' ||
                       isMatch(programEnrollmentMap.get(asiRecord.Program_Enrollment__c).HomeSchoolEvaluatorReport__c, 'Verified', false))) ||
                     programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PlacementFlag__c == 'Counselor Review' ||
                     ((asiRecord.Grade_Level_Requested__c == '9' ||
                       asiRecord.Grade_Level_Requested__c == '10' ||
                       asiRecord.Grade_Level_Requested__c == '11' ||
                       asiRecord.Grade_Level_Requested__c == '12') &&
                      (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Special_Educations__r.size() > 0 &&
                       programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Special_Educations__r.get(0).IEP__c == 'IEP') &&
                      asiRecord.CoursesFinalized__c != 'Yes')) {
*/
            //new logic introduced (Andrew Sim) #USXXX
            else if (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PlacementFlag__c == 'Counselor Review') {
                          asiRecord.StudentPlacementBucket__c = 'School Counselor';
                          annualStudentInformationsRecordList.add(asiRecord);
                      }
            //18 - 'Enrollment - RC/PAH Not Uploaded'
            // comment out old logic (Andrew Sim) #USXXX
/*            else if (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PlacementFlag__c == 'RC/PAH Not Uploaded') {
                asiRecord.StudentPlacementBucket__c = 'Enrollment - RC/PAH Not Uploaded';
                annualStudentInformationsRecordList.add(asiRecord);
            }
*/
            //19 - 'Placement'
            // comment out old logic (Andrew Sim) #USXXX
/*            else if ((asiRecord.LA_Placement_Level__c == null && asiRecord.Science_Placement_Level__c == null &&
                      asiRecord.Math_Placement_Level__c == null &&
                      (asiRecord.Academic_Documentation_Summary__c == 'Received' ||
                       asiRecord.Academic_Documentation_Summary__c == 'Verified' ||
                       asiRecord.Academic_Documentation_Summary__c == 'Not Applicable' ||
                       asiRecord.Grade_Level_Requested__c == 'K') &&
                      (asiRecord.Final_Grade_Level__c == null ||
                       asiRecord.Final_Grade_Level__c == '9' ||
                       asiRecord.Final_Grade_Level__c == '10' ||
                       asiRecord.Final_Grade_Level__c == '11' ||
                       asiRecord.Final_Grade_Level__c == '12')) ||
                     (asiRecord.Final_Grade_Level__c == null &&
                      (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Special_Educations__r.size() > 0 &&
                       programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Special_Educations__r.get(0).IEP__c == 'IEP' &&
                       programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Enrollment_Documents__r.size() > 0 &&
                       programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Enrollment_Documents__r.get(0).Status_Reason__c.contains('Verified') ||
                       (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Special_Educations__r.size() > 0 &&
                        programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Special_Educations__r.get(0).IEP__c == 'Documenting' &&
                        programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Enrollment_Documents__r.size() > 0 &&
                        programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Enrollment_Documents__r.get(0).Status_Reason__c.contains('Reviewed')))) ||
                     (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).MoreHighSchoolDocumentation__c == 'Documentation needed' &&
                      asiRecord.CoursesFinalized__c == null) ||
                     programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PlacementFlag__c == 'Principal Review- Complete' ||
                     programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PlacementFlag__c == 'Principal Review- Need Information' ||
                     (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).HomeSchoolEvaluatorReport__c == 'Received' &&
                      (asiRecord.Academic_Documentation_Summary__c == 'Received' ||
                       asiRecord.Academic_Documentation_Summary__c == 'Verified' ||
                       asiRecord.Academic_Documentation_Summary__c == 'Not Applicable')) ||
                     ((asiRecord.Final_Grade_Level__c == '9' ||
                       asiRecord.Final_Grade_Level__c == '10' ||
                       asiRecord.Final_Grade_Level__c == '11' ||
                       asiRecord.Final_Grade_Level__c == '12') &&
                      programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Enrollment_Documents__r.size() > 0 &&
                      programEnrollmentMap.get(asiRecord.Program_Enrollment__c).Enrollment_Documents__r.get(0).Status_Reason__c.contains('Reviewed'))) {
                          asiRecord.StudentPlacementBucket__c = 'Placement';
                          annualStudentInformationsRecordList.add(asiRecord);
                      }
*/
            //new logic introduced (Andrew Sim) #USXXX
            else if (programEnrollmentMap.get(asiRecord.Program_Enrollment__c).PlacementFlag__c == 'Academic Placement Advisor') {
                          asiRecord.StudentPlacementBucket__c = 'Placement';
                          annualStudentInformationsRecordList.add(asiRecord);
            }
            //20 - 'BROKEN'
            else {
                asiRecord.StudentPlacementBucket__c = 'BROKEN';
                annualStudentInformationsRecordList.add(asiRecord);
            }
        }
        System.debug('asiList==>>'+annualStudentInformationsRecordList.size()+'firedFromASI'+firedFromASI);
        system.debug('annualStudentInformationsRecordList'+annualStudentInformationsRecordList);
        //Check for list size & updating list. //change for #77940 bug
        if (annualStudentInformationsRecordList.size() > 0) {
            try {
                System.debug('***update:' + annualStudentInformationsRecordList);
                update annualStudentInformationsRecordList;
            } catch(Exception e) {
                logger.logException('recalculateStudentPlacementBucket', e);
                logger.saveLogs();
                throw e;
            }
        }
    }
    
    private static boolean shouldAssignToParentBucket (Id ASIRecId, Map<Id, hed__Program_Enrollment__c> programEnrollmentMap, Map<Id,List<Enrollment_Document__c>> ECA_EnrollDoclist)
    {
        //Calculate if all the documents that are required have actually been provided.  This will come into play
        //if the bucket needs to be set to 'Parent'
        boolean needsAIEP = false;
        boolean hasAIEP = false;
        boolean needsEval = false;
        boolean hasEval = false;
        boolean needsExitDoc = false;
        boolean hasExitDoc = false;
        boolean needsReportCard = false;
        boolean hasReportCard = false;
        boolean needsHSAcHist = false;
        boolean hasHSAcHist = false;
        boolean needsUnofcTrans = false;
        boolean hasUnofcTrans = false;
        boolean needsGiftedDoc = false;
        boolean hasGiftedDoc = false;
        boolean needsStateScores = false;
        boolean hasStateScores = false;

        //Get all the Enrollment Component Affiliations for this Program Enrollment.
        hed__Program_Enrollment__c thisPEsECAS = programEnrollmentMap.get(ASIRecId);

        for (Enrollment_Component_Affiliation__c eca : thisPEsECAS.Enrollment_Component_Affiliation__r)
        {
            if (eca.Document_Type__c == 'Individualized Education Program') 
            {
                needsAIEP = true;
                List<Enrollment_Document__c> docsThisECA = ECA_EnrollDoclist.get(eca.id);
                if (docsThisECA != null) {
                    for (Enrollment_Document__c ec : docsThisECA)
                    {
                        if ( ec.Type__c == 'Individualized Education Program' && (ec.Status_Reason__c.startsWithIgnoreCase('verified') || ec.Status_Reason__c.startsWithIgnoreCase('received')) )
                        {   hasAIEP = true; break;  }
                    }
                }
            }
        }

        for (Enrollment_Component_Affiliation__c eca : thisPEsECAS.Enrollment_Component_Affiliation__r)
        {
            if (eca.Document_Type__c == 'Evaluation') 
            {
                needsEval = true;
                List<Enrollment_Document__c> docsThisECA = ECA_EnrollDoclist.get(eca.id);
                if (docsThisECA != null) {
                    for (Enrollment_Document__c ec : docsThisECA)
                    {
                        if ( ec.Type__c == 'Evaluation' && (ec.Status_Reason__c.startsWithIgnoreCase('verified') || ec.Status_Reason__c.startsWithIgnoreCase('received')) )
                        {   hasEval = true; break;  }
                    }
                }
            }
        }

        for (Enrollment_Component_Affiliation__c eca : thisPEsECAS.Enrollment_Component_Affiliation__r)
        {
            if (eca.Document_Type__c == 'IEP Exit Documentation') 
            {
                needsExitDoc = true;
                List<Enrollment_Document__c> docsThisECA = ECA_EnrollDoclist.get(eca.id);
                if (docsThisECA != null) {
                    for (Enrollment_Document__c ec : docsThisECA)
                    {
                        if ( ec.Type__c == 'IEP Exit Documentation' && (ec.Status_Reason__c.startsWithIgnoreCase('verified') || ec.Status_Reason__c.startsWithIgnoreCase('received') || ec.Status_Reason__c.startsWithIgnoreCase('not applicable')) )
                        {   hasExitDoc = true;  break;  }
                    }
                }
            }
        }

        for (Enrollment_Component_Affiliation__c eca : thisPEsECAS.Enrollment_Component_Affiliation__r)
        {
            if (eca.Document_Type__c == 'Report Card') 
            {
                needsReportCard = true;
                List<Enrollment_Document__c> docsThisECA = ECA_EnrollDoclist.get(eca.id);
                if (docsThisECA != null) {
                    for (Enrollment_Document__c ec : docsThisECA)
                    {
                        if ( ec.Type__c == 'Report Card' && (ec.Status_Reason__c.startsWithIgnoreCase('verified') || ec.Status_Reason__c.startsWithIgnoreCase('received') ) )
                        {   hasReportCard = true;break;     }
                    }
                }
            }
        }


        for (Enrollment_Component_Affiliation__c eca : thisPEsECAS.Enrollment_Component_Affiliation__r)
        {
            if (eca.Document_Type__c == 'Home School Prior Academic History') 
            {
                needsHSAcHist = true;
                List<Enrollment_Document__c> docsThisECA = ECA_EnrollDoclist.get(eca.id);
                if (docsThisECA != null) {
                    for (Enrollment_Document__c ec : docsThisECA)
                    {
                        if ( ec.Type__c == 'Home School Prior Academic History' && (ec.Status_Reason__c.startsWithIgnoreCase('verified') || ec.Status_Reason__c.startsWithIgnoreCase('received') ) )
                        {   hasHSAcHist = true; break;  }
                    }
                }
            }
        }
        
        for (Enrollment_Component_Affiliation__c eca : thisPEsECAS.Enrollment_Component_Affiliation__r)
        {
            if (eca.Document_Type__c == 'Unofficial Transcript') 
            {
                needsUnofcTrans = true;
                List<Enrollment_Document__c> docsThisECA = ECA_EnrollDoclist.get(eca.id);
                if (docsThisECA != null) {
                    for (Enrollment_Document__c ec : docsThisECA)
                    {
                        if ( ec.Type__c == 'Unofficial Transcript' && (ec.Status_Reason__c.startsWithIgnoreCase('verified') || ec.Status_Reason__c.startsWithIgnoreCase('received') ) )
                        {   hasUnofcTrans = true;   break;  }
                    }
                }
            }
        }

        for (Enrollment_Component_Affiliation__c eca : thisPEsECAS.Enrollment_Component_Affiliation__r)
        {
            if (eca.Document_Type__c == 'Gifted Documentation') 
            {
                needsGiftedDoc = true;
                List<Enrollment_Document__c> docsThisECA = ECA_EnrollDoclist.get(eca.id);
                if (docsThisECA != null) {
                    for (Enrollment_Document__c ec : docsThisECA)
                    {
                        if ( ec.Type__c == 'Gifted Documentation' && (ec.Status_Reason__c.startsWithIgnoreCase('verified') || ec.Status_Reason__c.startsWithIgnoreCase('received') ) )
                        {   hasGiftedDoc = true;  break;  }
                    }
                }
            }
        }

        for (Enrollment_Component_Affiliation__c eca : thisPEsECAS.Enrollment_Component_Affiliation__r)
        {
            if (eca.Document_Type__c == 'State Test Scores') 
            {
                needsStateScores = true;
                List<Enrollment_Document__c> docsThisECA = ECA_EnrollDoclist.get(eca.id);
                if (docsThisECA != null) {
                    for (Enrollment_Document__c ec : docsThisECA)
                    {
                        if ( ec.Type__c == 'State Test Scores' && ec.Status_Reason__c.startsWithIgnoreCase('verified'))
                        {   hasStateScores = true;  break;  }
                    }
                }
            }
        }

        if (    (needsAIEP && !hasAIEP) 
                || (needsEval && !hasEval) 
                || (needsExitDoc && !hasExitDoc) 
                || (needsReportCard && !hasReportCard) 
                || (needsHSAcHist && !hasHSAcHist) 
                || (needsUnofcTrans && !hasUnofcTrans) 
                || (needsGiftedDoc && !hasGiftedDoc) 
                || (needsStateScores && !hasStateScores) )
            return true;
        else
            return false;

    }   
    /**
* Created by Ajith on 03/22/2019.
* MethodName: automatedPlacementExclude
* Description: Trigger Handler Method of Excluding the Student from the auto placement
* Params : @enrollmentIds - Set of PE Ids
*/
   /* public static List<Annual_Student_Information__c> calculateAutomatedPlacementExclude(Set<Id> pesToProcess, Boolean isFiredFromASI) {
        
        System.debug('In calculateAutomatedPlacementExclude Method');
        
        //Create Some Variables to Work With
        List<Annual_Student_Information__c> asiListToBeUpdated = new List<Annual_Student_Information__c>();
        Map<Id, List<Program_Grade_Level__c>> programGradelevelMap = new Map<Id, List<Program_Grade_Level__c>> ();
        
        for(Program_Grade_Level__c gradeLevel : [
            SELECT Id, Grade_Level__c, Grade_Level__r.Name, Academic_Program__c, AutoplacementExclude__c, AutoPlacement_HomeExclude__c,
            AutoPlacement_Special_EdExclude__c, AutoPlacement_PublicExclude__c, AutoPlacement_PrivateExclude__c, AutoPlacement_NoneExclude__c
            FROM Program_Grade_Level__c
            WHERE Academic_Program__c IN (SELECT hed__Account__c FROM hed__Program_Enrollment__c WHERE Id IN :pesToProcess) AND Grade_Level__c != null]){
                
                if (programGradelevelMap.containsKey(gradeLevel.Academic_Program__c)) {
                    programGradelevelMap.get(gradeLevel.Academic_Program__c).add(gradeLevel);
                } else {
                    programGradelevelMap.put(gradeLevel.Academic_Program__c, new List<Program_Grade_Level__c>{gradeLevel});
                }
            }
        
        List<hed__Program_Enrollment__c> programEnrollments = new List<hed__Program_Enrollment__c>([
            SELECT Id, EntranceAgeEligibilityOverride__c, EntranceAgeEligibilitySystem__c, EntranceAgeEligibilityFinal__c, WhyFlagged__c, Final_Grade_Level__c,Credit_for_HS_Coursework__c,
            hed__Account__r.AutomatedPlacementExclude__c, Start_Year__r.Start_Date__c, hed__Account__r.Parent.Name, Program_Grade_Level__c,
            (SELECT Id, Program_Enrollment__c,Program_Enrollment__r.hed__Account__r.AutomatedPlacementMaxCutoff__c,Program_Enrollment__r.Start_Year__r.Current_Year__c,
             Academic_Documentation_Summary__c,School_Year__r.Start_Date__c, LA_Placement_Level__c, Program_Enrollment__r.WaitlistFlag__c, Program_Enrollment__r.WhyFlagged__c,
             HowStudentPlacementCompleted__c, CoursesFinalized__c, Math_Placement_Level__c, Science_Placement_Level__c, Grade_Level_Requested__c, RecommendedAutoPlacement__c,
             Final_Grade_Level__c, GiftedProgramRequest_LA_M_S__c, Program_Enrollment__r.Start_Year__r.Start_Date__c, School_Year__c, APS_PlacedTimeStamp__c
             FROM Annual_Student_Information__r),
            (SELECT Id, Status_Reason__c, Type__c, Program_Enrollment__c FROM Enrollment_Documents__r),
            (SELECT Id, Level_Requested__c, Course_Requested__c FROM Placement_and_Elective_Requests__r),
            (SELECT Id,SchoolType__c, School_Year__c FROM Prior_Schools__r),
            (SELECT Id, Program_Enrollment__c, IEP__c FROM Special_Educations__r)
            FROM hed__Program_Enrollment__c
            WHERE Id in :pesToProcess
        ]);
        //Some Variables/Collections to Work with
        Map<Id, Annual_Student_Information__c> progEnrollmentToAsiMap = new Map<Id, Annual_Student_Information__c>();
        Map<Id, List<Enrollment_Document__c>> enrollmentDocumentMap = new Map<Id, List<Enrollment_Document__c>>();
        Map<Id, Special_Education__c> specialEducationMap = new Map<Id, Special_Education__c>();
        Map<Id, Prior_School__c> priorSchoolMap = new Map<Id, Prior_School__c>();
        Map<Id, Placement_and_Elective__c> pleMap = new Map<Id,Placement_and_Elective__c>();
        
        for(hed__Program_Enrollment__c pe : programEnrollments) {
            if(pe.Annual_Student_Information__r != null){
                for(Annual_Student_Information__c asi : pe.Annual_Student_Information__r){
                    if(asi.School_Year__c != null && asi.Program_Enrollment__r.Start_Year__c != null && asi.School_Year__c == asi.Program_Enrollment__r.Start_Year__c){
                        progEnrollmentToAsiMap.put(asi.Program_Enrollment__c, asi);
                        System.debug('asi.FinalGrade Level'+asi.Final_Grade_Level__c);
                    }
                }
            }
            if(pe.Enrollment_Documents__r != null){
                for (Enrollment_Document__c document : pe.Enrollment_Documents__r) {
                    if (enrollmentDocumentMap.containsKey(document.Program_Enrollment__c)) {
                        enrollmentDocumentMap.get(document.Program_Enrollment__c).add(document);
                    } else {
                        enrollmentDocumentMap.put(document.Program_Enrollment__c, new List<Enrollment_Document__c>{document});
                    }
                }
            }
            if(pe.Special_Educations__r != null){
                for (Special_Education__c specialEducation : pe.Special_Educations__r) {
                    specialEducationMap.put(specialEducation.Program_Enrollment__c, specialEducation);
                }
            }
            if(pe.Prior_Schools__r != null){
                for(Prior_School__c school : pe.Prior_Schools__r){
                    if(school.School_Year__c != null && school.School_Year__c == pe.Start_Year__c){
                        priorSchoolMap.put(pe.Id, school);
                    }
                }
            }
            if(pe.Placement_and_Elective_Requests__r != null){
                for(Placement_and_Elective__c ple : pe.Placement_and_Elective_Requests__r){
                    pleMap.put(pe.Id, ple);
                }
            }
        }
        
        System.debug('progEnrollmentToAsiMap++' + progEnrollmentToAsiMap);
        System.debug('enrollmentDocumentMap+++' + enrollmentDocumentMap);
        System.debug('specialEducationMap++' + specialEducationMap);
        System.debug('programEnrollments++' + programEnrollments);
        
        for(hed__Program_Enrollment__c pe : programEnrollments) {
            Annual_Student_Information__c asi = progEnrollmentToAsiMap.get(pe.Id);
            asi.AutomatedPlacementExclude__c = false;
            //Account Conditions
            //
            if(pe.hed__Account__r.AutomatedPlacementExclude__c){
                asi.AutomatedPlacementExclude__c = true;
            }
            //Grade Level Conditions
            if(progEnrollmentToAsiMap.containsKey(pe.Id) && programGradelevelMap.containsKey(pe.hed__Account__c)){
                for(Program_Grade_Level__c gradeLevel : programGradelevelMap.get(pe.hed__Account__c)){
                    System.debug('progEnrollmentToAsiMap.get(pe.Id).Final_Grade_Level__c'+progEnrollmentToAsiMap.get(pe.Id).Final_Grade_Level__c);
                    System.debug('gradeLevel.Grade_Level__r.Name'+gradeLevel.Grade_Level__r.Name);
                    if(pe.Program_Grade_Level__c == gradeLevel.Id){
                        if(gradeLevel.AutoplacementExclude__c){
                            asi.AutomatedPlacementExclude__c = true;
                        }else if(priorSchoolMap.containsKey(pe.Id) && priorSchoolMap.get(pe.Id).SchoolType__c != null){
                            if(priorSchoolMap.get(pe.Id).SchoolType__c == 'Public School' && gradeLevel.AutoPlacement_PublicExclude__c){
                                asi.AutomatedPlacementExclude__c = true;
                            }
                            if(priorSchoolMap.get(pe.Id).SchoolType__c == 'Private/Parochial School' && gradeLevel.AutoPlacement_PrivateExclude__c){
                                asi.AutomatedPlacementExclude__c = true;
                            }
                            if(priorSchoolMap.get(pe.Id).SchoolType__c == 'Homeschool' && gradeLevel.AutoPlacement_HomeExclude__c){
                                asi.AutomatedPlacementExclude__c = true;
                            }
                            if(priorSchoolMap.get(pe.Id).SchoolType__c == 'None' && gradeLevel.AutoPlacement_NoneExclude__c){
                                asi.AutomatedPlacementExclude__c = true;
                            }
                            
                        }else if(priorSchoolMap.containsKey(pe.Id) && priorSchoolMap.get(pe.Id).SchoolType__c == null && gradeLevel.AutoPlacement_NoneExclude__c){
                            asi.AutomatedPlacementExclude__c = true;
                        }
                        if(gradeLevel.AutoPlacement_Special_EdExclude__c && specialEducationMap.containsKey(pe.Id) && specialEducationMap.get(pe.Id).IEP__c != null){
                            asi.AutomatedPlacementExclude__c = true;
                        }
                    }
                }
            }
            String gradeRequested = asi.Grade_Level_Requested__c;
            if(gradeRequested == 'K' || gradeRequested == 'Kindergarten') {
                gradeRequested = '0';
            }
            //Program Enrollment Conditions
            if(pe.EntranceAgeEligibilityFinal__c != null && pe.EntranceAgeEligibilityFinal__c != 'Eligible'){
                System.debug('Ineligible:' +pe.EntranceAgeEligibilityFinal__c);
                asi.AutomatedPlacementExclude__c = true;
            }else if(pe.WhyFlagged__c != null && pe.WhyFlagged__c.contains('Disciplinary')){
                System.debug('In why flagged'+pe.WhyFlagged__c);
                asi.AutomatedPlacementExclude__c = true;
            }
            //ASI Conditions
            if(asi.GiftedProgramRequest_LA_M_S__c != null){
                if(pe.hed__Account__r.Parent.Name.contains('NMCA') && asi.GiftedProgramRequest_LA_M_S__c != 'Math'){
                    asi.AutomatedPlacementExclude__c = true;
                }else{
                    asi.AutomatedPlacementExclude__c = true;
                }
            }else if(asi.Grade_Level_Requested__c == null || (asi.Grade_Level_Requested__c != null && Integer.valueOf(gradeRequested) > 9)){
                asi.AutomatedPlacementExclude__c = true;
            }else if(asi.Grade_Level_Requested__c != null && Integer.valueOf(gradeRequested) == 9){
                if(pe.Credit_for_HS_Coursework__c == 'Yes'){
                    asi.AutomatedPlacementExclude__c = true;
                }
                if(pleMap.containsKey(pe.Id)){
                    Placement_and_Elective__c ple = pleMap.get(pe.Id);
                    if(ple.Level_Requested__c != null && ple.Course_Requested__c != null){
                        if(
                            ple.Level_Requested__c == 'Standard' && ple.Course_Requested__c == 'English' ||
                            ple.Level_Requested__c == 'Standard' && ple.Course_Requested__c == 'Math' ||
                            ple.Level_Requested__c == 'Standard' && ple.Course_Requested__c == 'Science' ||
                            ple.Level_Requested__c == 'Standard' && ple.Course_Requested__c == 'Social Studies' ||
                            (ple.Course_Requested__c == 'Math I' && ple.Course_Requested__c == 'Algebra 1' && ple.Course_Requested__c == 'Secondary Math 1')
                        ){
                            asi.AutomatedPlacementExclude__c = true;
                        }
                    }
                }
            }
            
            //Enrollment Document Conditions
            if(!pe.Enrollment_Documents__r.isEmpty() ){
                for(Enrollment_Document__c doc : pe.Enrollment_Documents__r){
                    if(doc.Type__c != null && doc.Type__c == 'IEP Exit Documentation' && doc.Status_Reason__c != null) {
                        String statusReason = doc.Status_Reason__c;
                        if(statusReason.contains('Reviewed') || statusReason.contains('Invalid') || statusReason.contains('Received') || statusReason.contains('Illegible') ||
                           statusReason.contains('No Documentation Available') || statusReason.contains('Missing') || statusReason.contains('Awaiting IEP')) {
                               asi.AutomatedPlacementExclude__c = true;
                           }
                    }
                }
            }
            asiListToBeUpdated.add(asi);
        }
        return asiListToBeUpdated;
    }*/
    
    /**
* Created by Ritvik on 1/12/18.
* Purpose : Method to check if field contains or equals to a certain string.
* Params : @actualText - takes string field value.
*          @expectedText - takes string which we want to check against.
*          @isExactMatch - True for equals condition & False for contains condition.
*/
    private static boolean isMatch(String actualText, String expectedText, boolean isExactMatch) {
        if (String.isNotBlank(actualText)) {
            if ((isExactMatch && actualText.equals(expectedText)) ||
                ((!isExactMatch) && actualText.contains(expectedText))) {
                    return true;
                }
        }
        return false;
        
    }
    /**
* Created By Ajith on 22/03/2019
* purpose is to calc the Contact based on the Birthdate__c and Today
*/
    public static Integer calculateAge(Date birthDate){
        Integer age;
        if(birthDate != null){
            Integer days = birthDate.daysBetween(Date.Today());
            age = Integer.valueOf(days/365);
        }
        return age;
    }
}