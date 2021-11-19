/**
 * Created by Ritvik on 04-12-2018.
 */

@IsTest
private class NES_AnnualStudentInfoUtilitiesTest {

    @TestSetup
    static void testSetup() {
        NES_LogicFeatureSwitch__c logicSwitch= Peak_TestUtils.createNESBusinessLogicSwitch('ProgramEnrollmentTrigger',true);
        Account account = Peak_TestUtils.createTestAccount();

        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019',date.parse('11/17/2018'));

        School_Year__c currentSchoolYearTest = Peak_TestUtils.createSchoolYears('2019-2020',date.parse('11/17/2020'));
        School_Year__c currentSchoolYear2020 = Peak_TestUtils.createSchoolYears('2021-2022',date.parse('11/17/2018'));

        School_Year__c previousSchoolYear = Peak_TestUtils.createSchoolYears('2017-2018',date.parse('11/17/2017'));

        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);

        Account academicProgramAccount = Peak_TestUtils.createAccountForNewStudentData(account.Id,currentSchoolYear.Id);
        academicProgramAccount.AutomatedPlacementMaxCutoff__c = 90;
        update academicProgramAccount;
        hed__Program_Enrollment__c progEnrollment5 = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear2020.Id, false);
        insert progEnrollment5;
        
        hed__Program_Enrollment__c progEnrollment1 = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear.Id, false);
        progEnrollment1.EntranceAgeEligibilitySystem__c = '';
        progEnrollment1.Start_Year__c =previousSchoolYear.Id;
        progEnrollment1.GradeLevelEligibility__c = '';
        progEnrollment1.PriorSchoolAttendanceElg__c = '';
        progEnrollment1.HomeschoolMembershipElg__c = '';
        progEnrollment1.AcademicPerformanceEligibility__c = '';
        progEnrollment1.CohortEligibility__c = '';
        progEnrollment1.WhyFlagged__c = '';
        progEnrollment1.PlacementFlag__c = 'Principal Review';
        progEnrollment1.EnrollmentSpecialistContactReq__c = '';
        progEnrollment1.MoreHighSchoolDocumentation__c = '';
        progEnrollment1.CreditByExamScores__c = '';
        progEnrollment1.HomeSchoolEvaluatorReport__c = '';
        insert progEnrollment1;
        hed__Program_Enrollment__c progEnrollment4 = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear.Id, false);
        progEnrollment4.EntranceAgeEligibilitySystem__c = '';
        progEnrollment4.Start_Year__c =currentSchoolYear.Id;
        progEnrollment4.GradeLevelEligibility__c = '';
        progEnrollment4.PriorSchoolAttendanceElg__c = '';
        progEnrollment4.HomeschoolMembershipElg__c = '';
        progEnrollment4.AcademicPerformanceEligibility__c = '';
        progEnrollment4.CohortEligibility__c = '';
        progEnrollment4.WhyFlagged__c = '';
        progEnrollment4.PlacementFlag__c = 'Principal Review';
        progEnrollment4.EnrollmentSpecialistContactReq__c = '';
        progEnrollment4.MoreHighSchoolDocumentation__c = '';
        progEnrollment4.CreditByExamScores__c = '';
        progEnrollment4.HomeSchoolEvaluatorReport__c = '';
        insert progEnrollment4;
        hed__Program_Enrollment__c progEnrollment3 = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYearTest.Id, false);
        progEnrollment3.EntranceAgeEligibilitySystem__c = '';
        progEnrollment3.Start_Year__c =currentSchoolYearTest.Id;
        progEnrollment3.GradeLevelEligibility__c = '';
        progEnrollment3.PriorSchoolAttendanceElg__c = '';
        progEnrollment3.HomeschoolMembershipElg__c = '';
        progEnrollment3.AcademicPerformanceEligibility__c = '';
        progEnrollment3.CohortEligibility__c = '';
        progEnrollment3.WhyFlagged__c = '';
        progEnrollment3.PlacementFlag__c = 'Principal Review- Gifted';
        progEnrollment3.EnrollmentSpecialistContactReq__c = '';
        progEnrollment3.MoreHighSchoolDocumentation__c = '';
        progEnrollment3.CreditByExamScores__c = '';
        progEnrollment3.HomeSchoolEvaluatorReport__c = '';
        insert progEnrollment3;
        
        Annual_Student_Information__c currentASI1 = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', progEnrollment1.Id, currentSchoolYear.Id, false);
        currentASI1.Final_Grade_Level__c = '3';
        currentASI1.CoursesFinalized__c = '';
        currentASI1.HowStudentPlacementCompleted__c = '';
        currentASI1.AutomatedPlacementScore__c = null;
        currentASI1.AutomatedPlacementExclude__c = false;
        currentASI1.Academic_Documentation_Summary__c = '';
        currentASI1.Science_Placement_Level__c = '';
        currentASI1.LA_Placement_Level__c = '';
        currentASI1.Math_Placement_Level__c = '';
        currentASI1.Grade_Level_Requested__c = '';
        insert currentASI1;
        Annual_Student_Information__c currentASI11 = peak_TestUtils.createAnnualStudentInformation('Current ASI11', progEnrollment5.Id, currentSchoolYear2020.Id, false);
        currentASI11.Final_Grade_Level__c = '1';
        currentASI11.CoursesFinalized__c = 'yes';
        currentASI11.HowStudentPlacementCompleted__c = '';
        currentASI11.AutomatedPlacementScore__c = null;
        currentASI11.AutomatedPlacementExclude__c = false;
        currentASI11.Academic_Documentation_Summary__c = '';
        currentASI11.Science_Placement_Level__c = '';
        currentASI11.LA_Placement_Level__c = '';
        currentASI11.Math_Placement_Level__c = '';
        currentASI11.Grade_Level_Requested__c = '';
        insert currentASI11;
        hed__Program_Enrollment__c progEnrollment2 = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,previousSchoolYear.Id, true);


        Annual_Student_Information__c prevASI1 = Peak_TestUtils.createAnnualStudentInformation('Previous ASI1', progEnrollment4.Id, currentSchoolYear.Id, false);
        prevASI1.CoursesFinalized__c = 'Yes';
        //precASI1.
        insert  prevASI1;
        Annual_Student_Information__c prevASI3 = Peak_TestUtils.createAnnualStudentInformation('Previous ASI3', progEnrollment3.Id, previousSchoolYear.Id, false);
        prevASI1.CoursesFinalized__c = 'Yes';
        //precASI1.
        insert  prevASI3;
       Annual_Student_Information__c prevASI5 = Peak_TestUtils.createAnnualStudentInformation('Previous ASI5', progEnrollment5.Id, currentSchoolYear2020.Id, false);
        
          prevASI5.HowStudentPlacementCompleted__c = 'Modified Auto-Placement Process';
        prevASI5.CoursesFinalized__c = 'Yes';
        prevASI5.Final_Grade_Level__c = '1';
        insert prevASI5;

        Annual_Student_Information__c prevASI2 = Peak_TestUtils.createAnnualStudentInformation('Previous ASI2', progEnrollment1.Id, previousSchoolYear.Id, false);
        prevASI1.CoursesFinalized__c = 'Yes';
        insert prevASI2;
        Special_Education__c specialEducations = Peak_TestUtils.createSpecialEducation(progEnrollment1.Id,false);
        specialEducations.Name = 'SE1';
        insert specialEducations;

        Enrollment_Document__c enrollmentDocumentOne = Peak_TestUtils.createEnrollmentDocumentRecord(progEnrollment1.Id,'Individualized Education Program', 'Invalid-Illegible', true);
        Enrollment_Document__c enrollmentDocumentTwo = Peak_TestUtils.createEnrollmentDocumentRecord(progEnrollment1.Id,'Individualized Education Program', 'Invalid-Outdated', true);
    }

   /*static testMethod void caseScenario1(){
        Set<Id> asiIdList = new Set<Id>();
        //hed__Program_Enrollment__c prvsProgramEnrollment = [SELECT Id FROM hed__Program_Enrollment__c WHERE Start_Year__c =: prevoiusYear.Id];
        Annual_Student_Information__c prvsASI = [SELECT Id FROM Annual_Student_Information__c WHERE Name = 'Previous ASI1' ];
        prvsASI.CoursesFinalized__c = 'Denied';
        update prvsASI;
        asiIdList.add(prvsASI.Id);
        Test.startTest();
        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c Asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI1'];
        System.assertEquals('BROKEN',Asi.StudentPlacementBucket__c);
        Test.stopTest();


    }*/
    Static testMethod void recalculateStudentTestCase1(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c prevoiusYear = [SELECT Id FROM School_Year__c WHERE Name = '2017-2018'];
        hed__Program_Enrollment__c prvsProgramEnrollment = [SELECT Id FROM hed__Program_Enrollment__c WHERE Start_Year__c =: prevoiusYear.Id LIMIT 1];
        prvsProgramEnrollment.CohortEligibility__c = '';
        prvsProgramEnrollment.WhyFlagged__c = 'Disciplinary History';
       

        Annual_Student_Information__c prvsASI = [SELECT Id FROM Annual_Student_Information__c WHERE Program_Enrollment__c = :prvsProgramEnrollment.Id LIMIT 1];
        prvsASI.CoursesFinalized__c = 'Yes';
        update prvsASI;
         update prvsProgramEnrollment;
        Test.startTest();
        Annual_Student_Information__c Asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c =:prvsProgramEnrollment.Id LIMIT 1];
        //System.assertEquals('Eligibility- Enrollment',Asi.StudentPlacementBucket__c);REMOVED PER BUG 85147
        //System.assertEquals('Placed - K8', Asi.StudentPlacementBucket__c);
        System.assertEquals(null, Asi.StudentPlacementBucket__c);
        Test.stopTest();

    }
    Static testMethod void recalculateStudentTestCase2(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c prevoiusYear = [SELECT Id FROM School_Year__c WHERE Name = '2017-2018'];
        hed__Program_Enrollment__c prvsProgramEnrollment = [SELECT Id FROM hed__Program_Enrollment__c WHERE Start_Year__c =: prevoiusYear.Id LIMIT 1];
        prvsProgramEnrollment.EntranceAgeEligibilityOverride__c = 'Pending Review';
       

        Annual_Student_Information__c prvsASI = [SELECT Id FROM Annual_Student_Information__c WHERE Program_Enrollment__c = :prvsProgramEnrollment.Id LIMIT 1];
        prvsASI.CoursesFinalized__c = 'Yes';
        update prvsASI;
         update prvsProgramEnrollment;
        Test.startTest();
        //NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c Asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c =:prvsProgramEnrollment.Id LIMIT 1];
        //System.assertEquals('Eligibility- Pending Review',Asi.StudentPlacementBucket__c);
        System.assertEquals(null ,Asi.StudentPlacementBucket__c);
        Test.stopTest();

    }

    static testMethod void caseScenario3(){
          Set<Id> asiIdList = new Set<Id>();
          School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = '2018-2019' LIMIT 1];
          hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilityFinal__c,CohortEligibility__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
          currentProgramEnrollment.CohortEligibility__c = 'Ineligible';
          update currentProgramEnrollment;
           hed__Program_Enrollment__c currentProgramEnrollment1 = [SELECT Id,EntranceAgeEligibilityFinal__c,CohortEligibility__c FROM hed__Program_Enrollment__c WHERE Id=: currentProgramEnrollment.Id];
             System.debug('Id:::'+currentProgramEnrollment1+'CohortEligibility__c:::'+currentProgramEnrollment1.CohortEligibility__c);
          Annual_Student_Information__c Asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c = :currentProgramEnrollment1.Id];
          System.assertEquals(null ,Asi.StudentPlacementBucket__c);
             }
    static testMethod void caseScenario4(){
        Annual_Student_Information__c prvsASI = [SELECT Id FROM Annual_Student_Information__c WHERE Name = 'Previous ASI3' ];

        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = '2019-2020' LIMIT 1];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilityFinal__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id LIMIT 1];
        currentProgramEnrollment.CohortEligibility__c = '';
        currentProgramEnrollment.WhyFlagged__c = 'Disciplinary History';
        update currentProgramEnrollment;
        Annual_Student_Information__c Asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c = :currentProgramEnrollment.Id];
        //System.assertEquals('Eligibility- Enrollment',Asi.StudentPlacementBucket__c); REMOVED PER BUG 85147
        System.assertEquals(null ,Asi.StudentPlacementBucket__c);
    }

    static testMethod void caseScenario5(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = '2018-2019'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilityFinal__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.WhyFlagged__c = 'Prior Withdrawal';
        update currentProgramEnrollment;
        Annual_Student_Information__c currentASI = [SELECT Id FROM Annual_Student_Information__c WHERE Name = 'Current ASI1' ];
        asiIdList.add(currentASI.Id);
        Test.startTest();
        Annual_Student_Information__c Asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c = :currentProgramEnrollment.Id];
        //System.assertEquals('Eligibility- Enrollment',Asi.StudentPlacementBucket__c); REMOVED PER BUG 85147
        //System.assertEquals('Principal',Asi.StudentPlacementBucket__c);
        System.assertEquals(null,Asi.StudentPlacementBucket__c);
        Test.stopTest();
    }

    static testMethod void caseScenario6(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = '2018-2019'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilityFinal__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.CohortEligibility__c = 'Cohort 2016-2017 or earlier';
        update currentProgramEnrollment;
        Annual_Student_Information__c currentASI = [SELECT Id FROM Annual_Student_Information__c WHERE Name = 'Current ASI1' ];
        asiIdList.add(currentASI.Id);
        Test.startTest();
        //NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c Asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c = :currentProgramEnrollment.Id];
        //System.assertEquals('Eligibility- Pending',Asi.StudentPlacementBucket__c);
        System.assertEquals(null,Asi.StudentPlacementBucket__c);
        Test.stopTest();
    }

    static testMethod void caseScenario7(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = '2018-2019'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilityFinal__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.PlacementFlag__c = 'Awaiting Communication- WYCA';
        update currentProgramEnrollment;
        Annual_Student_Information__c currentASI = [SELECT Id FROM Annual_Student_Information__c WHERE Name = 'Current ASI1' ];
        asiIdList.add(currentASI.Id);
        Test.startTest();
        //NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c Asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c =:currentProgramEnrollment.Id];
        //System.assertEquals('Parent - Call APS',Asi.StudentPlacementBucket__c);
        System.assertEquals(null,Asi.StudentPlacementBucket__c);
        Test.stopTest();
    }

   static testMethod void caseScenario8(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = '2018-2019'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilityFinal__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.EnrollmentSpecialistContactReq__c = 'Pending Review';
        update currentProgramEnrollment;
        Annual_Student_Information__c currentASI = [SELECT Id FROM Annual_Student_Information__c WHERE Name = 'Current ASI1' ];
        asiIdList.add(currentASI.Id);
        Test.startTest();
        //NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c Asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c =:currentProgramEnrollment.Id];
        //System.assertEquals('Parent - Enrollment Specialist',Asi.StudentPlacementBucket__c);
       System.assertEquals(null,Asi.StudentPlacementBucket__c);
        Test.stopTest();
    }

    static testMethod void caseScenario9(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = '2018-2019'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilityFinal__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.PlacementFlag__c = 'Awaiting Communication- School Counselor';
        update currentProgramEnrollment;
        Annual_Student_Information__c currentASI = [SELECT Id FROM Annual_Student_Information__c WHERE Name = 'Current ASI1' ];
        asiIdList.add(currentASI.Id);
        Test.startTest();
        //NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c Asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c =:currentProgramEnrollment.Id];
        //System.assertEquals('Parent - School Counselor',Asi.StudentPlacementBucket__c);
        System.assertEquals(null,Asi.StudentPlacementBucket__c);
        Test.stopTest();
    } 

    static testMethod void caseScenario10(){
               Set<Id> asiIdList = new Set<Id>();
      
        Annual_Student_Information__c currentASI = [SELECT Id,HowStudentPlacementCompleted__c,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI5' LIMIT 1 ];
       hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,WhyFlagged__c,EntranceAgeEligibilityFinal__c FROM hed__Program_Enrollment__c WHERE id =: currentASI.Program_Enrollment__c LIMIT 1];
        currentProgramEnrollment.WhyFlagged__c = 'Awaiting Communication- WYCA';
        //currentProgramEnrollment.Start_Year__c =  currentYear.Id;
      update currentProgramEnrollment;
        Test.startTest();
       // NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c Asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c =:currentProgramEnrollment.Id LIMIT 1];
        System.assertEquals(null,Asi.StudentPlacementBucket__c);
        Test.stopTest();
      
    }  
    static testMethod void caseScenarioAutoPlacedTest(){
               Set<Id> asiIdList = new Set<Id>();
      
        Annual_Student_Information__c currentASI = [SELECT Id,HowStudentPlacementCompleted__c,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI5' LIMIT 1 ];
        currentASI.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';
        update currentASI; 
        System.debug('currentAsi==>>'+currentASI.HowStudentPlacementCompleted__c);
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,WhyFlagged__c,EntranceAgeEligibilityFinal__c FROM hed__Program_Enrollment__c WHERE id =: currentASI.Program_Enrollment__c LIMIT 1];
        currentProgramEnrollment.WhyFlagged__c = 'Awaiting Communication- WYCA';
        //currentProgramEnrollment.Start_Year__c =  currentYear.Id;
      update currentProgramEnrollment;
        Test.startTest();
       // NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c Asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c =:currentProgramEnrollment.Id LIMIT 1];
        //System.assertEquals('Placed - K8',Asi.StudentPlacementBucket__c);
        System.assertEquals(null ,Asi.StudentPlacementBucket__c);
        Test.stopTest();
      
    }  
    
    static testMethod void caseScenarioAutoPlacedSchoolTest(){
               Set<Id> asiIdList = new Set<Id>();
      
        Annual_Student_Information__c currentASI = [SELECT Id,Final_Grade_Level__c,HowStudentPlacementCompleted__c,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI5' LIMIT 1 ];
        currentASI.Final_Grade_Level__c = '10';
        update currentASI; 
        System.debug('currentAsi==>>'+currentASI.HowStudentPlacementCompleted__c);
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,Final_Grade_Level__c,WhyFlagged__c,EntranceAgeEligibilityFinal__c FROM hed__Program_Enrollment__c WHERE id =: currentASI.Program_Enrollment__c LIMIT 1];
        currentProgramEnrollment.WhyFlagged__c = 'Awaiting Communication- WYCA';
        //currentProgramEnrollment.Start_Year__c =  currentYear.Id;
      update currentProgramEnrollment;
        Test.startTest();
       // NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c Asi = [SELECT Id,Final_Grade_Level__c,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c =:currentProgramEnrollment.Id LIMIT 1];
     
        Test.stopTest();
      
    }
    
    static testMethod void placedHighSchoolTest(){
               Set<Id> asiIdList = new Set<Id>();
      
        Annual_Student_Information__c currentASI = [SELECT Id,Final_Grade_Level__c,HowStudentPlacementCompleted__c,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI5' LIMIT 1 ];
        currentASI.HowStudentPlacementCompleted__c = '';
        currentASI.Final_Grade_Level__c = '10';
        update currentASI; 
        System.debug('currentAsi==>>'+currentASI.HowStudentPlacementCompleted__c);
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,Final_Grade_Level__c,WhyFlagged__c,EntranceAgeEligibilityFinal__c FROM hed__Program_Enrollment__c WHERE id =: currentASI.Program_Enrollment__c LIMIT 1];
        currentProgramEnrollment.WhyFlagged__c = 'Awaiting Communication- WYCA';
        //currentProgramEnrollment.Start_Year__c =  currentYear.Id;
      update currentProgramEnrollment;
        Test.startTest();
       // NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c Asi = [SELECT Id,Final_Grade_Level__c,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c =:currentProgramEnrollment.Id LIMIT 1];
     
        Test.stopTest();
      
    }
    
    static testMethod void autoPlacementProgressTest(){
             Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = '2018-2019'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        Account acc = [Select AutomatedPlacementMaxCutoff__c From Account Where Id = :currentProgramEnrollment.hed__Account__c];
        acc.AutomatedPlacementMaxCutoff__c = 50;
        update acc;
        Annual_Student_Information__c currentASI = [SELECT Id,AutomatedPlacementScore__c,AutomatedPlacementExclude__c,School_Year__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c =: currentProgramEnrollment.Id ];
        System.debug('currentAsi==>>'+currentASI.AutomatedPlacementScore__c+'ASI.Start year'+currentASI.School_Year__c);
        currentASI.AutomatedPlacementScore__c = 30;
        currentASI.Academic_Documentation_Summary__c = 'Verified';
        currentASI.AutomatedPlacementExclude__c = false;
        currentASI.School_Year__c = currentYear.Id;

        update currentASI;

        system.debug('current asi id:::'+currentASI.Id);

        asiIdList.add(currentASI.Id);
        Test.startTest();
        //NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c Asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Id = :currentASI.Id];
        //System.debug('---Asi.StudentPlacementBucket__c---'+Asi.StudentPlacementBucket__c);//ss
        System.assertEquals(null,Asi.StudentPlacementBucket__c);
        Test.stopTest();
    }
    
     static testMethod void principalTest(){
             Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = '2018-2019'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,PlacementFlag__c,hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.PlacementFlag__c = 'Principal Review';
        update currentProgramEnrollment;
         Annual_Student_Information__c currentASI = [SELECT Id,AutomatedPlacementExclude__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c =: currentProgramEnrollment.Id ];
        
        
        Test.startTest();
        //NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c Asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Id = :currentASI.Id];
        //System.assertEquals('Principal',Asi.StudentPlacementBucket__c);
         System.assertEquals(null ,Asi.StudentPlacementBucket__c);
        Test.stopTest();
    }
    
    static testMethod void caseScenario11(){
          Set<Id> asiIdList = new Set<Id>();
       
        Annual_Student_Information__c currentASI = [SELECT Id,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Current ASI11' LIMIT 1 ];
       hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,WhyFlagged__c,Start_Year__c,EntranceAgeEligibilityFinal__c FROM hed__Program_Enrollment__c WHERE id =: currentASI.Program_Enrollment__c LIMIT 1];
        Test.startTest();
       // NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
       // Annual_Student_Information__c Asi = [SELECT Id,Final_Grade_Level__c,HowStudentPlacementCompleted__c,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c =:currentProgramEnrollment.Id];
       
         currentProgramEnrollment.WhyFlagged__c = 'Awaiting Communication- WYCA';
        //currentProgramEnrollment.Start_Year__c =  currentYear.Id;
      update currentProgramEnrollment;

    }
    
    static testMethod void caseScenario16_1(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = '2018-2019'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        Annual_Student_Information__c currentASI = [SELECT Id,AutomatedPlacementScore__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c =: currentProgramEnrollment.Id ];
        currentASI.Academic_Documentation_Summary__c = 'Verified';
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument1.Type__c = 'Individualized Education Program';
        enrollmentDocument1.Status_Reason__c = 'Invalid-Illegible';
        insert enrollmentDocument1;


        update currentASI;

        asiIdList.add(currentASI.Id);
        Test.startTest(); 
        //NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c Asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Id = :currentASI.Id];
        //System.assertEquals('Special Education Director',Asi.StudentPlacementBucket__c);
        Test.stopTest();
    }

    static testMethod void calculateRecommendedAutoPlacementTest(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = '2018-2019'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.PlacementFlag__c = 'Principal Review';
        update currentProgramEnrollment;

        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'IEP';
        insert education;

        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument1.Type__c = 'IEP Exit Documentation';
        enrollmentDocument1.Status_Reason__c = 'Requested';
        insert enrollmentDocument1;

        Annual_Student_Information__c currentASI = [SELECT Id,LA_Placement_Level__c,RecommendedAutoPlacement__c,Final_Grade_Level__c,Math_Placement_Level__c,Grade_Level_Requested__c FROM Annual_Student_Information__c WHERE Name = 'Current ASI1' ];
        currentASI.LA_Placement_Level__c = '2';
        currentASI.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI.Grade_Level_Requested__c = '8';
        currentASI.Final_Grade_Level__c = '9';
        update  currentASI;
        
        Annual_Student_Information__c Asi = [SELECT Id,RecommendedAutoPlacement__c FROM Annual_Student_Information__c WHERE Id = :currentASI.Id];
       // System.assertEquals('Excluded',Asi.RecommendedAutoPlacement__c);
    }

    static testMethod void unitTest_calculateAutomatedPlacementExclude_One(){
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = '2018-2019'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c, hed__Account__c, Start_Year__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;

        Enrollment_Document__c enrollmentDocument = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument.Type__c = 'IEP Exit Documentation';
        enrollmentDocument.Status_Reason__c = 'Requested';
        insert enrollmentDocument;

        Grade_Level__c gradeLevel = Peak_TestUtils.createGradeLevel('3', true);
        Account academicProgramAccount = [SELECT Id FROM Account WHERE Id =: currentProgramEnrollment.hed__Account__c];
        Program_Grade_Level__c programGradeLevel = Peak_TestUtils.createProgramGradeLevel('3', academicProgramAccount.Id, gradeLevel.Id, System.today(), false);
        programGradeLevel.AutoplacementExclude__c = true;
        insert programGradeLevel;

        Annual_Student_Information__c currentASI1 = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', currentProgramEnrollment.Id, currentProgramEnrollment.Start_Year__c, false);
        currentASI1.Final_Grade_Level__c = '3';
        currentASI1.LA_Placement_Level__c = '3';
        currentASI1.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI1.Grade_Level_Requested__c = '3';
        insert currentASI1;

        currentProgramEnrollment.PlacementFlag__c = 'Released';
        currentProgramEnrollment.EntranceAgeEligibilityOverride__c = 'Eligible';
        update currentProgramEnrollment;
    }

    static testMethod void unitTest_calculateAutomatedPlacementExclude_Two(){
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = '2018-2019'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c, hed__Account__c, Start_Year__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];

        Account acc = [SELECT Id, AutomatedPlacementExclude__c FROM Account WHERE Id =: currentProgramEnrollment.hed__Account__c];
        acc.AutomatedPlacementExclude__c = true;
        update acc;

        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;

        Enrollment_Document__c enrollmentDocument = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument.Type__c = 'IEP Exit Documentation';
        enrollmentDocument.Status_Reason__c = 'Requested';
        insert enrollmentDocument;

        Grade_Level__c gradeLevel = Peak_TestUtils.createGradeLevel('3', true);
        Account academicProgramAccount = [SELECT Id FROM Account WHERE Id =: currentProgramEnrollment.hed__Account__c];
        List<Program_Grade_Level__c> programGradeLevels = new List<Program_Grade_Level__c>();
        Program_Grade_Level__c programGradeLevel = Peak_TestUtils.createProgramGradeLevel('3', academicProgramAccount.Id, gradeLevel.Id, System.today(), false);
        programGradeLevel.AutoPlacement_PublicExclude__c = true;
        programGradeLevels.add(programGradeLevel);

        Program_Grade_Level__c programGradeLevelOne = Peak_TestUtils.createProgramGradeLevel('10', academicProgramAccount.Id, gradeLevel.Id, System.today(), false);
        programGradeLevel.AutoPlacement_PublicExclude__c = true;
        programGradeLevel.AutoPlacement_PrivateExclude__c = true;
        programGradeLevel.AutoPlacement_HomeExclude__c = true;
        programGradeLevel.AutoPlacement_NoneExclude__c = true;
        programGradeLevels.add(programGradeLevelOne);

        insert programGradeLevels;

        Annual_Student_Information__c currentASI1 = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', currentProgramEnrollment.Id, currentProgramEnrollment.Start_Year__c, false);
        currentASI1.Final_Grade_Level__c = '3';
        currentASI1.LA_Placement_Level__c = '3';
        currentASI1.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI1.Grade_Level_Requested__c = '3';
        insert currentASI1;

        List<Prior_School__c> priorSchoolsList = new List<Prior_School__c>();
        Prior_School__c priorSchool = Peak_TestUtils.createPriorSchool(currentProgramEnrollment.Id, 'Public School', false);
        priorSchool.School_Year__c = currentProgramEnrollment.Start_Year__c;
        priorSchoolsList.add(priorSchool);
        insert priorSchoolsList;

        Placement_and_Elective__c placementAndElective = Peak_TestUtils.createPlacementAndElective(currentProgramEnrollment.Id, true);

        currentProgramEnrollment.PlacementFlag__c = 'Released';
        currentProgramEnrollment.EntranceAgeEligibilityOverride__c = 'Eligible';
        currentProgramEnrollment.Credit_for_HS_Coursework__c = 'Yes';
        update currentProgramEnrollment;
    }

    static testMethod void unitTest_calculateAutomatedPlacementExclude_Three(){
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = '2018-2019'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c, hed__Account__c, Start_Year__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];

        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;

        Enrollment_Document__c enrollmentDocument = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument.Type__c = 'IEP Exit Documentation';
        enrollmentDocument.Status_Reason__c = 'Requested';
        insert enrollmentDocument;

        Grade_Level__c gradeLevel = Peak_TestUtils.createGradeLevel('3', true);
        Account academicProgramAccount = [SELECT Id FROM Account WHERE Id =: currentProgramEnrollment.hed__Account__c];
        List<Program_Grade_Level__c> programGradeLevels = new List<Program_Grade_Level__c>();
        Program_Grade_Level__c programGradeLevel = Peak_TestUtils.createProgramGradeLevel('3', academicProgramAccount.Id, gradeLevel.Id, System.today(), false);
        programGradeLevel.AutoPlacement_PublicExclude__c = true;
        programGradeLevels.add(programGradeLevel);

        Program_Grade_Level__c programGradeLevelOne = Peak_TestUtils.createProgramGradeLevel('10', academicProgramAccount.Id, gradeLevel.Id, System.today(), false);
        programGradeLevel.AutoPlacement_PublicExclude__c = true;
        programGradeLevel.AutoPlacement_PrivateExclude__c = true;
        programGradeLevel.AutoPlacement_HomeExclude__c = true;
        programGradeLevel.AutoPlacement_NoneExclude__c = true;
        programGradeLevels.add(programGradeLevelOne);

        insert programGradeLevels;

        Annual_Student_Information__c currentASI1 = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', currentProgramEnrollment.Id, currentProgramEnrollment.Start_Year__c, false);
        currentASI1.Final_Grade_Level__c = '3';
        currentASI1.LA_Placement_Level__c = '3';
        currentASI1.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI1.Grade_Level_Requested__c = '3';
        insert currentASI1;

        List<Prior_School__c> priorSchoolsList = new List<Prior_School__c>();

        Prior_School__c priorSchool_Private = Peak_TestUtils.createPriorSchool(currentProgramEnrollment.Id, 'Private/Parochial School', false);
        priorSchool_Private.School_Year__c = currentProgramEnrollment.Start_Year__c;
        priorSchoolsList.add(priorSchool_Private);

        insert priorSchoolsList;

        Placement_and_Elective__c placementAndElective = Peak_TestUtils.createPlacementAndElective(currentProgramEnrollment.Id, true);

        currentProgramEnrollment.PlacementFlag__c = 'Released';
        currentProgramEnrollment.EntranceAgeEligibilityOverride__c = 'Eligible';
        currentProgramEnrollment.Credit_for_HS_Coursework__c = 'Yes';
        update currentProgramEnrollment;
    }

    static testMethod void unitTest_calculateAutomatedPlacementExclude_Four(){
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = '2018-2019'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c, hed__Account__c, Start_Year__c, hed__Account__r.ParentId FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        Account acc = [SELECT Id, Name FROM Account WHERE Id =: currentProgramEnrollment.hed__Account__r.ParentId];
        acc.Name = 'NMCA';
        update acc;

        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;

        Enrollment_Document__c enrollmentDocument = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument.Type__c = 'IEP Exit Documentation';
        enrollmentDocument.Status_Reason__c = 'Requested';
        insert enrollmentDocument;

        Grade_Level__c gradeLevel = Peak_TestUtils.createGradeLevel('3', true);
        Account academicProgramAccount = [SELECT Id FROM Account WHERE Id =: currentProgramEnrollment.hed__Account__c];
        List<Program_Grade_Level__c> programGradeLevels = new List<Program_Grade_Level__c>();
        Program_Grade_Level__c programGradeLevel = Peak_TestUtils.createProgramGradeLevel('3', academicProgramAccount.Id, gradeLevel.Id, System.today(), false);
        programGradeLevel.AutoPlacement_PublicExclude__c = true;
        programGradeLevels.add(programGradeLevel);

        Program_Grade_Level__c programGradeLevelOne = Peak_TestUtils.createProgramGradeLevel('10', academicProgramAccount.Id, gradeLevel.Id, System.today(), false);
        programGradeLevel.AutoPlacement_PublicExclude__c = true;
        programGradeLevel.AutoPlacement_PrivateExclude__c = true;
        programGradeLevel.AutoPlacement_HomeExclude__c = true;
        programGradeLevel.AutoPlacement_NoneExclude__c = true;
        programGradeLevels.add(programGradeLevelOne);

        insert programGradeLevels;

        Annual_Student_Information__c currentASI1 = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', currentProgramEnrollment.Id, currentProgramEnrollment.Start_Year__c, false);
        currentASI1.Final_Grade_Level__c = '3';
        currentASI1.LA_Placement_Level__c = '3';
        currentASI1.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI1.Grade_Level_Requested__c = '3';
        currentASI1.GiftedProgramRequest_LA_M_S__c = 'Math';
        insert currentASI1;

        List<Prior_School__c> priorSchoolsList = new List<Prior_School__c>();

        Prior_School__c priorSchool_Homeschool = Peak_TestUtils.createPriorSchool(currentProgramEnrollment.Id, 'HomeSchool', false);
        priorSchool_Homeschool.School_Year__c = currentProgramEnrollment.Start_Year__c;
        priorSchoolsList.add(priorSchool_Homeschool);

        insert priorSchoolsList;

        Placement_and_Elective__c placementAndElective = Peak_TestUtils.createPlacementAndElective(currentProgramEnrollment.Id, true);

        currentProgramEnrollment.PlacementFlag__c = 'Released';
        currentProgramEnrollment.EntranceAgeEligibilityOverride__c = 'Eligible';
        currentProgramEnrollment.Credit_for_HS_Coursework__c = 'Yes';
        update currentProgramEnrollment;
    }

    static testMethod void unitTest_calculateAutomatedPlacementExclude_Five(){
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = '2018-2019'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c, hed__Account__c, Start_Year__c, hed__Account__r.ParentId FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];

        Account acc = [SELECT Id, Name FROM Account WHERE Id =: currentProgramEnrollment.hed__Account__r.ParentId];
        acc.Name = 'NMCA';
        update acc;

        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;

        Enrollment_Document__c enrollmentDocument = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument.Type__c = 'IEP Exit Documentation';
        enrollmentDocument.Status_Reason__c = 'Requested';
        insert enrollmentDocument;

        Grade_Level__c gradeLevel = Peak_TestUtils.createGradeLevel('3', true);
        Account academicProgramAccount = [SELECT Id FROM Account WHERE Id =: currentProgramEnrollment.hed__Account__c];
        List<Program_Grade_Level__c> programGradeLevels = new List<Program_Grade_Level__c>();
        Program_Grade_Level__c programGradeLevel = Peak_TestUtils.createProgramGradeLevel('3', academicProgramAccount.Id, gradeLevel.Id, System.today(), false);
        programGradeLevel.AutoPlacement_PublicExclude__c = true;
        programGradeLevels.add(programGradeLevel);

        Program_Grade_Level__c programGradeLevelOne = Peak_TestUtils.createProgramGradeLevel('10', academicProgramAccount.Id, gradeLevel.Id, System.today(), false);
        programGradeLevel.AutoPlacement_PublicExclude__c = true;
        programGradeLevel.AutoPlacement_PrivateExclude__c = true;
        programGradeLevel.AutoPlacement_HomeExclude__c = true;
        programGradeLevel.AutoPlacement_NoneExclude__c = true;
        programGradeLevels.add(programGradeLevelOne);

        insert programGradeLevels;

        Annual_Student_Information__c currentASI1 = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', currentProgramEnrollment.Id, currentProgramEnrollment.Start_Year__c, false);
        currentASI1.Final_Grade_Level__c = '3';
        currentASI1.LA_Placement_Level__c = '3';
        currentASI1.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI1.Grade_Level_Requested__c = '3';
        currentASI1.GiftedProgramRequest_LA_M_S__c = 'Science';
        insert currentASI1;

        List<Prior_School__c> priorSchoolsList = new List<Prior_School__c>();
        Prior_School__c priorSchool_None = Peak_TestUtils.createPriorSchool(currentProgramEnrollment.Id, '', false);
        priorSchool_None.School_Year__c = currentProgramEnrollment.Start_Year__c;
        priorSchool_None.SchoolType__c = '';
        priorSchoolsList.add(priorSchool_None);

        insert priorSchoolsList;

        Placement_and_Elective__c placementAndElective = Peak_TestUtils.createPlacementAndElective(currentProgramEnrollment.Id, true);

        currentProgramEnrollment.WhyFlagged__c = 'Disciplinary';
        currentProgramEnrollment.Credit_for_HS_Coursework__c = 'Yes';
        currentProgramEnrollment.PlacementFlag__c = 'Released';
        update currentProgramEnrollment;
    }

    static testMethod void unitTest_calculateAutomatedPlacementExclude_Six(){
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = '2018-2019'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c, hed__Account__c, Start_Year__c, hed__Account__r.ParentId FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];

        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;

        Enrollment_Document__c enrollmentDocument = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument.Type__c = 'IEP Exit Documentation';
        enrollmentDocument.Status_Reason__c = 'Requested';
        insert enrollmentDocument;

        Grade_Level__c gradeLevel = Peak_TestUtils.createGradeLevel('3', true);
        Grade_Level__c gradeLevelOne = Peak_TestUtils.createGradeLevel('9', true);
        Account academicProgramAccount = [SELECT Id FROM Account WHERE Id =: currentProgramEnrollment.hed__Account__c];
        List<Program_Grade_Level__c> programGradeLevels = new List<Program_Grade_Level__c>();
        Program_Grade_Level__c programGradeLevel = Peak_TestUtils.createProgramGradeLevel('3', academicProgramAccount.Id, gradeLevel.Id, System.today(), false);
        programGradeLevel.AutoPlacement_PublicExclude__c = true;
        programGradeLevels.add(programGradeLevel);

        Program_Grade_Level__c programGradeLevelOne = Peak_TestUtils.createProgramGradeLevel('9', academicProgramAccount.Id, gradeLevel.Id, System.today(), false);
        programGradeLevel.AutoPlacement_PublicExclude__c = true;
        programGradeLevel.AutoPlacement_PrivateExclude__c = true;
        programGradeLevel.AutoPlacement_HomeExclude__c = true;
        programGradeLevel.AutoPlacement_NoneExclude__c = true;
        programGradeLevels.add(programGradeLevelOne);

        insert programGradeLevels;

        Annual_Student_Information__c currentASI1 = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', currentProgramEnrollment.Id, currentProgramEnrollment.Start_Year__c, false);
        currentASI1.Final_Grade_Level__c = '3';
        currentASI1.LA_Placement_Level__c = '3';
        currentASI1.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI1.Grade_Level_Requested__c = '10';
        insert currentASI1;

        List<Prior_School__c> priorSchoolsList = new List<Prior_School__c>();
        Prior_School__c priorSchool_None = Peak_TestUtils.createPriorSchool(currentProgramEnrollment.Id, '', false);
        priorSchool_None.School_Year__c = currentProgramEnrollment.Start_Year__c;
        priorSchool_None.SchoolType__c = '';
        priorSchoolsList.add(priorSchool_None);

        insert priorSchoolsList;

        Placement_and_Elective__c placementAndElective = Peak_TestUtils.createPlacementAndElective(currentProgramEnrollment.Id, false);
        placementAndElective.Level_Requested__c = 'Standard';
        placementAndElective.Course_Requested__c = 'English';
        insert placementAndElective;

        currentProgramEnrollment.WhyFlagged__c = 'Disciplinary';
        currentProgramEnrollment.PlacementFlag__c = 'Released';
        update currentProgramEnrollment;
    }
}