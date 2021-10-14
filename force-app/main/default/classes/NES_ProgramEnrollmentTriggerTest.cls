/**
* Created by Anand on 12/8/2018.
* purpose: Test class for Nes_ProgramEnrollment
**Change Log:
* Added code by Anitha P for #107180 User Story (Task 108661) on 2019-09-06
* Added code by Anitha P for #107180 User Story (Bug  110762) on 2019-09-30
* Added other Age Eligibility fields needed for calcuations US114797 (Andrew Sim) on 11/05/19
*/
@isTest
private class NES_ProgramEnrollmentTriggerTest {

    @TestSetup
    static void setup() {
        Peak_TestUtils.createNESBusinessLogicSwitch('Entrance Age Eligibility Override', true);
        Peak_TestUtils.createNESBusinessLogicSwitch('ProgramEnrollmentTrigger', true);
        Peak_TestUtils.createNESBusinessLogicSwitch('High School LTS Score', true); 
        Peak_TestUtils.createNESBusinessLogicSwitch('Likelihood to Transition Score', true);
        Peak_TestUtils.createNESBusinessLogicSwitch('Why Flagged', true);

        Account parentAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        Contact TestContact = Peak_TestUtils.createTestContact();
        //School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019',date.parse('11/17/2018'));
        School_Year__c pSchoolYear = Peak_TestUtils.createSchoolYears('2017-2018', date.parse('11/17/2017'));
        School_Year__c previousSchoolYear = Peak_TestUtils.createSchoolYears('PreviousYear', System.today().addYears(-1));
        School_Year__c schlYear = Peak_TestUtils.createSchoolYears('SchoolTest', System.today());

        Account academicAccount = Peak_TestUtils.createAccountForNewStudentData(parentAccount.Id, schlYear.Id);
        academicAccount.FirstDayforStudents__c = System.today().addDays(-56);
        update academicAccount;
        Grade_Level__c gradeLevelTest1 = Peak_TestUtils.createGradeLevel('1', True);
        Grade_Level__c gradeLevelTest2 = Peak_TestUtils.createGradeLevel('2', True);
        Program_Grade_Level__c programGradeLevelTest1 = Peak_TestUtils.createProgramGradeLevel('Test1', academicAccount.Id, gradeLevelTest1.Id, System.now(), True);
        programGradeLevelTest1.Second_Semester_Confirmation_Date__c = datetime.newInstance(2018, 11, 15, 12, 30, 0);
        programGradeLevelTest1.Final_Confirmation_End_Date__c = datetime.newInstance(2018, 11, 12, 12, 30, 0);
        update programGradeLevelTest1 ;

        Program_Grade_Level__c programGradeLevelTest2 = Peak_TestUtils.createProgramGradeLevel('Test2', academicAccount.Id, gradeLevelTest2.Id, System.now(), True);
        programGradeLevelTest2.Second_Semester_Confirmation_Date__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        programGradeLevelTest2.Final_Confirmation_End_Date__c = datetime.newInstance(2018, 12, 01, 12, 30, 0);
        update programGradeLevelTest2 ;

        hed__Program_Enrollment__c ProgramEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicAccount.Id, TestContact.Id, schlYear.Id, false);
        ProgramEnrollmentTest.Final_Grade_Level__c = '1';
       
        Insert ProgramEnrollmentTest;
        

        Annual_Student_Information__c currentASI1 = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schlYear.Id, true);
        //Test Data for WhyFlag Method
        //Test Data for Why Flag Method
        School_Year__c SchoolYear = Peak_TestUtils.createSchoolYears('2018-2019', Date.newInstance(2018, 1, 1));
        SchoolYear.Name = '2018-2019';
        SchoolYear.Start_Date__c = Date.newInstance(2018, 1, 1);
        SchoolYear.End_Date__c = Date.newInstance(2019, 1, 1);
        update SchoolYear ;
        //Start: Test coverage data for Bug #226654
        Enrollment_Component__c enComp1 = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Stage', false);
        enComp1.Name = 'Waitlist';
        Insert enComp1;
        Enrollment_Component__c enComp2 = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Stage', false);
        enComp2.Name = 'Confirmation of Enrollment';
        Insert enComp2;
        Enrollment_Component__c enComp3 = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Form', false);
        enComp3.Name = 'Waitlist';
        Insert enComp3;
        Enrollment_Component__c enComp4 = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Section', false);
        enComp4.Name = 'Waitlist Notice';
        Insert enComp4;
        Enrollment_Component__c enComp = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Form', false);
        enComp.Student_Enrollment_Information__c = true ;
        Insert enComp;
        //End: Test coverage data for Bug #226654

        List<hed__Program_Enrollment__c> programEnrollmentList = new List<hed__Program_Enrollment__c>();
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicAccount.Id, TestContact.Id, pSchoolYear.Id, false);
        //progEnrollment.Status__c = 'Complete';
        progEnrollment.CounselingFlag__c = 'Stop';
        progEnrollment.WaitlistFlag__c = 'Active';
        //Commented Deprecate Technology flag logic for US 476956
        //progEnrollment.UserTechnologyFlag__c = 'Withdraw';
        progEnrollment.HomelessRiskFlag__c = 'Potential Homeless';
        progEnrollment.PrincipalGeneralFlag__c = 'Released';
        progEnrollment.PlacementFlag__c = 'Principal Review' ;
        progEnrollment.Start_Year__c = pSchoolYear.Id;
        progEnrollment.HHPORFlag__c = 'Undeliverable Address';
        progEnrollment.GradeLevelEligibility__c = 'Allowed to Enroll';
        progEnrollment.EntranceAgeEligibilitySystem__c = 'Eligible' ;
        progEnrollment.HomelessRiskFlag__c = 'Potential Homeless';
        progEnrollment.DisciplinaryFlagOverride__c = 'Pending Review';
        progEnrollment.SIS_Integration_Status__c = '204 : No Content';
        progEnrollment.Enrollment_Type__c = 'Initial Enrollment';


        programEnrollmentList.add(progEnrollment) ;

        hed__Program_Enrollment__c progEnrollment2 = Peak_TestUtils.createProgramEnrollment(academicAccount.Id, TestContact.Id, pSchoolYear.Id, false);
        progEnrollment2.CounselingFlag__c = 'Stop';
        progEnrollment2.WaitlistFlag__c = 'Active';
        //Commented Deprecate Technology flag logic for US 476956
        //progEnrollment2.UserTechnologyFlag__c = 'Withdraw';
        progEnrollment2.HomelessRiskFlag__c = 'Potential Homeless';
        progEnrollment2.PlacementFlag__c = 'Principal Review' ;
        progEnrollment2.PORFlag__c = 'Pending';
        progEnrollment2.Start_Year__c = SchoolYear.Id;
        progEnrollment2.HHPORFlag__c = 'Undeliverable Address';
        progEnrollment2.GradeLevelEligibility__c = 'Allowed to Enroll';
        progEnrollment2.EntranceAgeEligibilitySystem__c = 'Eligible' ;
        progEnrollment2.HomelessRiskFlag__c = 'Potential Homeless';
        progEnrollment2.DisciplinaryFlagOverride__c = 'Pending Review';
        progEnrollment2.Enrollment_Type__c = 'Initial Enrollment';
        programEnrollmentList.add(progEnrollment2);

        hed__Program_Enrollment__c progEnrollment3 = Peak_TestUtils.createProgramEnrollment(academicAccount.Id, TestContact.Id, pSchoolYear.Id, false);
        //progEnrollment3.Status__c = 'Complete';
        progEnrollment3.CounselingFlag__c = 'Stop';
        progEnrollment3.WaitlistFlag__c = 'Active';
        //Commented Deprecate Technology flag logic for US 476956
        //progEnrollment3.UserTechnologyFlag__c = 'Withdraw';
        progEnrollment3.PrincipalGeneralFlag__c = 'Released';
        progEnrollment3.PriorWithdrawalFlag__c = 'Hold';
        progEnrollment3.PlacementFlag__c = 'Principal Review' ;
        progEnrollment3.PORFlag__c = 'Pending';
        progEnrollment3.HHPORFlag__c = 'Undeliverable Address';
        progEnrollment3.GradeLevelEligibility__c = 'Allowed to Enroll';
        progEnrollment3.EntranceAgeEligibilitySystem__c = 'Eligible' ;
        progEnrollment3.HomelessRiskFlag__c = 'Potential Homeless';
        progEnrollment3.DisciplinaryFlagOverride__c = 'Pending Review';
        progEnrollment3.Enrollment_Type__c = 'Initial Enrollment';
        programEnrollmentList.add(progEnrollment3);

        Insert programEnrollmentList;
        System.debug('programEnrollmentId_Affiliation==>>' + programEnrollmentList[0].Id);
        Enrollment_Component_Affiliation__c ecaAffiliation1 = Peak_TestUtils.createEnrollmentComponentAffiliation(programEnrollmentList[0].Id, enComp.Id, false);
        ecaAffiliation1.status__c = 'In progress';
        Insert ecaAffiliation1;
        System.debug('ecaAffiliation1===>>' + ecaAffiliation1);
	    //Start: Test coverage data for Bug #226654
        Enrollment_Component_Affiliation__c ecaAffiliation2 = Peak_TestUtils.createEnrollmentComponentAffiliation(programEnrollmentList[0].Id, enComp1.Id, false);
        ecaAffiliation2.status__c = 'Not Started';
        ecaAffiliation2.Order__c = 3.0;
        Insert ecaAffiliation2;
        Enrollment_Component_Affiliation__c ecaAffiliation3 = Peak_TestUtils.createEnrollmentComponentAffiliation(programEnrollmentList[0].Id, enComp2.Id, false);
        ecaAffiliation3.status__c = 'In Progress';
        ecaAffiliation3.Order__c = 4.0;
        Insert ecaAffiliation3;
        Enrollment_Component_Affiliation__c ecaAffiliation4 = Peak_TestUtils.createEnrollmentComponentAffiliation(programEnrollmentList[0].Id, enComp3.Id, false);
        ecaAffiliation4.status__c = 'In Progress';
        ecaAffiliation4.Order__c = 1.0;
         Insert ecaAffiliation4;
        Enrollment_Component_Affiliation__c ecaAffiliation5 = Peak_TestUtils.createEnrollmentComponentAffiliation(programEnrollmentList[0].Id, enComp4.Id, false);
        ecaAffiliation5.status__c = 'In Progress';
        ecaAffiliation5.Order__c = 1.0;
        Insert ecaAffiliation5;
        //End: Test coverage data for Bug #226654
                    
    }
    /**
     * Created by Anand
     * puporse to Test updateFinalConfirmationDate Method for opportunity Final Semester='First'
     */
    static testMethod void updateFinalConfirmationDate() {
        hed__Program_Enrollment__c prEnrollment = [
                select id,Final_Grade_Level__c,hed__Account__c
                FROM hed__Program_Enrollment__c
                WHERE Final_Grade_Level__c = '1'
                LIMIT 1
        ];
        Account parentAccount = [select Id From Account LIMIT 1];
        Opportunity optyTest2 = Peak_TestUtils.createOpportunity('newOpty', parentAccount.Id, System.Today(), 'closed won', False);
        optyTest2.Semester_Indicator__c = 'First';
        optyTest2.Final_Semester_Indicator__c = 'Second';
        optyTest2.program_enrollment__c = prEnrollment.Id;
        optyTest2.Earliest_Final_Confirmation_Date__c = System.Today();
        Insert optyTest2;


        Test.startTest();


        Program_Grade_Level__c progGrade = [
                select id,
                        Final_Confirmation_End_Date__c,
                        Second_Semester_Confirmation_Date__c, grade_level__r.name
                FROM Program_Grade_Level__c
                WHERE Academic_Program__c = :prEnrollment.hed__Account__c AND grade_level__r.name = '2'
        ];
        progGrade.Second_Semester_Confirmation_Date__c=System.today();
        update progGrade;
        prEnrollment.Final_Grade_Level__c = '2';
        update prEnrollment;
        hed__Program_Enrollment__c prEnrollment1 = [
                select id,Final_Grade_Level__c,hed__Account__c, (
                        SELECT id,
                                Earliest_Final_Confirmation_Date__c,
                                Program_Enrollment__c,Final_Semester_Indicator__c
                        FROM Opportunities__r
                        order by createdDate desc
                        limit 1
                )
                FROM hed__Program_Enrollment__c
                WHERE Id = :prEnrollment.Id
        ];
        System.assertEquals(prEnrollment1.Opportunities__r[0].Earliest_Final_Confirmation_Date__c, progGrade.Second_Semester_Confirmation_Date__c);
        Test.stopTest();

    }
    /**
     * Created by Anand
     * puporse to Test updateFinalConfirmationDate Method for opportunity Final Semester='Second'
     */
    static testMethod void updateFinalConfirmationDateTest_OptyFinalSemester() {
        Test.startTest();
        hed__Program_Enrollment__c prEnrollment = [select id,Final_Grade_Level__c,hed__Account__c FROM hed__Program_Enrollment__c WHERE Final_Grade_Level__c = '1' LIMIT 1];
        Account parentAccount = [select Id From Account LIMIT 1];
        Opportunity optyTest2 = Peak_TestUtils.createOpportunity('newOpty', parentAccount.Id, System.Today(), 'closed won', False);
        optyTest2.Semester_Indicator__c = 'First';
        optyTest2.Final_Semester_Indicator__c = 'First';
        optyTest2.program_enrollment__c = prEnrollment.Id;
        optyTest2.Earliest_Final_Confirmation_Date__c = System.Today();
        Insert optyTest2;
        Program_Grade_Level__c progGrade = [
                select id,
                        Final_Confirmation_End_Date__c,
                        Second_Semester_Confirmation_Date__c, grade_level__r.name
                FROM Program_Grade_Level__c
                WHERE Academic_Program__c = :prEnrollment.hed__Account__c AND grade_level__r.name = '2'
        ];
        progGrade.Final_Confirmation_End_Date__c=System.today();
        update progGrade;
        prEnrollment.Final_Grade_Level__c = '2';
        update prEnrollment;
        hed__Program_Enrollment__c prEnrollment1 = [
                select id,Final_Grade_Level__c,hed__Account__c, (
                        SELECT id,
                                Earliest_Final_Confirmation_Date__c,
                                Program_Enrollment__c,Final_Semester_Indicator__c
                        FROM Opportunities__r
                        order by createdDate desc
                        limit 1
                )
                FROM hed__Program_Enrollment__c
                WHERE Id = :prEnrollment.Id
        ];
        System.debug('prEnrollment1' + prEnrollment1.Opportunities__r[0].Final_Semester_Indicator__c);

        System.assertEquals(prEnrollment1.Opportunities__r[0].Earliest_Final_Confirmation_Date__c, progGrade.Final_Confirmation_End_Date__c);
        Test.stopTest();
    }
    
    /**
    * Created by Anushka Bansal
    * Puporse : to Test calculateEntranceAgeEligibilityOverride_Update Method 
    */
    static testMethod void TestCalculateEntranceAgeEligibilityOverrideUpdate() {
        School_Year__c schoolYear = [Select id from School_Year__c where name = '2017-2018'];
        hed__Program_Enrollment__c progEnrollment = [select id, EntranceAgeEligibility__c FROM hed__Program_Enrollment__c LIMIT 1];
        progEnrollment.EntranceAgeEligibilityOverride__c = 'Eligible';
        system.debug('Entrance Age Eligibility Override ' + progEnrollment.EntranceAgeEligibilityOverride__c);
        Test.StartTest();
        update progEnrollment;
        Test.stopTest();
    }

    /**
   * Created by Anushka Bansal
   * Puporse : to Test calculateEntranceAgeEligibilityOverride_Insert Method
   */
    static testMethod void TestCalculateEntranceAgeEligibilityOverrideInsert() {
        Contact contact = [Select id from Contact limit 1];
        Id programEnrollmentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account academicAccount = [Select id from Account where RecordType.Id = :programEnrollmentRecordTypeId limit 1];
        School_Year__c schoolYear = [Select id from School_Year__c where name = '2017-2018'];
        hed__Program_Enrollment__c ProgramEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicAccount.Id, contact.Id, schoolYear.Id, false);
        ProgramEnrollmentTest.EntranceAgeEligibilityOverride__c = 'Eligible';


        Test.StartTest();
        Insert ProgramEnrollmentTest;
        Test.stopTest();
    }


    /**
   * Created by  Anushka Bansal
   * Puporse : to Test recalculateRecommendedAutoPlacement_Update Method on updation of Start Year field.
   */
    static testMethod void TestUpdateProgramEnrollments() {
        School_Year__c schoolYear = [Select id from School_Year__c where name = '2017-2018'];
        system.debug('school year ' + schoolYear);
        hed__Program_Enrollment__c progEnrollment = [select id,Start_Year__c,Final_Grade_Level__c,hed__Account__c FROM hed__Program_Enrollment__c WHERE Final_Grade_Level__c = '1' LIMIT 1];
        progEnrollment.Start_Year__c = schoolYear.Id;

        Test.StartTest();
        update progEnrollment;
        Test.stopTest();
    }

    // Create By Anand
    Static testMethod void calculateEllflag() {
        hed__Program_Enrollment__c prEnrollment = [select id,HLSStudentFlag__c,Final_Grade_Level__c,hed__Account__c FROM hed__Program_Enrollment__c LIMIT 1];
        prEnrollment.HLSStudentFlag__c = True;
        prEnrollment.HLS_Date_Completed__c = System.Today();//added by anitha P
        prEnrollment.ELLFlag__c='Potential EL';
        Update prEnrollment;
        hed__Program_Enrollment__c prEnrollment1 = [Select Id,HLSStudentFlag__c,ELLFlag__c FROM hed__Program_Enrollment__c WHERE Id = :prEnrollment.Id];
        System.assertEquals(prEnrollment1.ELLFlag__c, 'Potential EL');
    }
    
    

    //Start : Added by Ritvik for populatecalculateHighSchoolLTS method in NES_ProgramEnrollmentBusinessLogic class.
    //After changing the logic of the CalculateLTS Group to update the ASI I think this below test method is invalid
    static testMethod void test_populatecalculateHighSchoolLTS_AfterInsert() {
        Contact contact = [Select id from Contact limit 1];
        Id programEnrollmentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account academicAccount = [Select id from Account where RecordType.Id = :programEnrollmentRecordTypeId limit 1];
        School_Year__c schoolYear = [Select id from School_Year__c where name = 'SchoolTest'];
        hed__Program_Enrollment__c ProgramEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicAccount.Id, contact.Id, schoolYear.Id, false);
        ProgramEnrollmentTest.LTS__c = -6;
        Test.startTest();
        insert ProgramEnrollmentTest;
        hed__Program_Enrollment__c ProgramEnrollmentTest1 = [SELECT Id,LTS__c FROM hed__Program_Enrollment__c WHERE Id = :ProgramEnrollmentTest.Id];
       //system.assertEquals(-6, ProgramEnrollmentTest1.LTS__c);
        Test.stopTest();
    }

    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate1() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.LTS__c = 5;

        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }

    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate2() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.LTS__c = 7;
        //Start-added for #107180 User Story (Bug 110762) on 2019-09-30/
            //ProgramEnrollmentTest.PAHStatus__c = 'Verified';
            //ProgramEnrollmentTest.UTStatus__c = 'Verified';
            //ProgramEnrollmentTest.RCStatus__c = 'Verified';
        //End-added for #107180 User Story (Bug 110762) on 2019-09-30
        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }

    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate3() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.LTS__c = 9;

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);
        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;

        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }

    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate4() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.LTS__c = 10;

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);
        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;

        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }

    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate5() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.LTS__c = 11;

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);
        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;

        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }

    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate6() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.LTS__c = 13;

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);
        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;

        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }

    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate7() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.LTS__c = 14;

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);
        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;

        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;
        Test.stopTest();
    }

    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate8() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.LTS__c = 15;

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);
        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;

        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;
        Test.stopTest();
    }

    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate9() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.LTS__c = 16;

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);
        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;

        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;
        Test.stopTest();
    }

    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate10() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        Id programEnrollmentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account academicAccount = [Select id from Account where RecordType.Id = :programEnrollmentRecordTypeId limit 1];

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.LTS__c = 17;
        System.debug('ProgramEnrollmentTest.Id'+ProgramEnrollmentTest.Id);

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);

        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;

        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }

    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate11() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.LTS__c = 18;

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);

        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;

        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;
        Test.stopTest();
    }
    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate12() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.LTS__c = 19;

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);

        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;


        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;
        Test.stopTest();
    }
    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate13() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.LTS__c = 20;

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);

        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;

        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }
    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate14() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.LTS__c = 22;

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);

        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;


        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }
    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate15() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.LTS__c = 23;

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);

        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;


        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }
    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate16() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.LTS__c = 5;

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);

        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;


        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }
    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate17() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.DisciplinaryPastActions__c = 'No';

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);

        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;

        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }
    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate18() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.DisciplinaryPastActions__c = 'Yes, expelled';

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);

        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;


        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }
    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate19() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.Academic_Doc_Performance__c = 'Yes';

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);

        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;


        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }
    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate20() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.Academic_Doc_Performance__c = 'No';

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);

        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;


        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }
    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate21() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.Post_High_School_Plans_2__c = 'Undecided';

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);

        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;


        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }
    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate22() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.Post_High_School_Plans_2__c = 'To enroll in a two-year or community college';

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);

        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;


        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }
    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate23() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.Post_High_School_Plans_2__c = 'To enter the military';

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);

        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;


        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }
    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate24() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.Post_High_School_Plans_2__c = 'To enter the workforce';

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);

        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;


        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;
        Test.stopTest();
    }
    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate25() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id, hed__Account__c FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.Post_High_School_Plans_2__c = 'To enroll in a four-year college or university';

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);

        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;


        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }
    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate26() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        Id programEnrollmentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account academicAccount = [Select id from Account where RecordType.Id = :programEnrollmentRecordTypeId limit 1];

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', academicAccount.Id, System.today().addDays(32), 'Closed Won', false);

        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;
        ProgramEnrollmentTest.SIFStudentRetained__c = 'Yes';
        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }
    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate27() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;
        School_Year__c pSchoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'PreviousYear'];
        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        Annual_Student_Information__c currentAsi = [SELECT Id FROM Annual_Student_Information__c WHERE Name = 'Current ASI1'];
        currentAsi.Grade_Level_Requested__c = '9';
        update currentAsi;
        Annual_Student_Information__c PreviousAsi = Peak_TestUtils.createAnnualStudentInformation('PrvsAsi', ProgramEnrollmentTest.Id, pSchoolYear.Id, false);
        PreviousAsi.Grade_Level_Requested__c = '9';
        insert PreviousAsi;
        ProgramEnrollmentTest.SIFStudentRetained__c = 'Yes';
        ProgramEnrollmentTest.First_Yr_Complete_HS_Coursework__c = 'No';
        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }
    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate28() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];
        ProgramEnrollmentTest.SIFStudentRetained__c = 'Yes';

        Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', ProgramEnrollmentTest.Id, schoolYear.Id, true);

        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }
    static testMethod void test_populatecalculateHighSchoolLTS_AfterUpdate29() {
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        schoolYear.Current_Year__c = true;
        update schoolYear;

        hed__Program_Enrollment__c ProgramEnrollmentTest = [SELECT Id FROM hed__Program_Enrollment__c WHERE Start_Year__c = :schoolYear.Id];

        Annual_Student_Information__c currentAsi = [SELECT Id FROM Annual_Student_Information__c WHERE Name = 'Current ASI1'];
        currentAsi.Grade_Level_Requested__c = '5';
        update currentAsi;

        ProgramEnrollmentTest.SIFStudentRetained__c = 'Yes';

        Test.startTest();
        update ProgramEnrollmentTest;

        Test.stopTest();
    }
    //End

    static testMethod void test_calculateLTS_Insert() {
        Contact contact = [Select id from Contact limit 1];
        Id programEnrollmentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account academicAccount = [Select id from Account where RecordType.Id = :programEnrollmentRecordTypeId limit 1];
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        hed__Program_Enrollment__c ProgramEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicAccount.Id, contact.Id, schoolYear.Id, false);
        ProgramEnrollmentTest.Stress_Factors__c = 'Yes';
        test.startTest();
        insert ProgramEnrollmentTest;
        System.assertEquals(null, ProgramEnrollmentTest.LTS__c);
        test.stopTest();
    }

    static testMethod void calculateWhyFlagTest() {
        Id programEnrollmentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account academicAccount = [SELECT Id FROM Account WHERE RecordTypeId = :programEnrollmentRecordTypeId LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Date StartDate = Date.newInstance(2018, 1, 1);
        School_Year__c cSchoolYear = [SELECT Id,Start_Date__c,End_Date__c FROM School_Year__c WHERE Start_Date__c = :StartDate LIMIT 1];
        //  School_Year__c  SchoolYear =[SELECT Id,Start_Date__c,End_Date__c FROM School_Year__c LIMIT 1];
        List<hed__Program_Enrollment__c> programEnrollmentList = new List<hed__Program_Enrollment__c>();
        //Commented Deprecate Technology flag logic for US 476956
        for (hed__Program_Enrollment__c progEnrollment : [
                SELECT Id,Status__c,CounselingFlag__c,WaitlistFlag__c,/*UserTechnologyFlag__c,*/
                        HomelessRiskFlag__c,PrincipalGeneralFlag__c,PlacementFlag__c,
                        PORFlag__c,Start_Year__c,HHPORFlag__c,GradeLevelEligibility__c,
                        EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,
                        DisciplinaryFlagOverride__c
                FROM hed__Program_Enrollment__c
                LIMIT 1
        ]) { //End

            //progEnrollment.Status__c = 'Complete';
            progEnrollment.Start_Year__c = cSchoolYear.Id;
            progEnrollment.CounselingFlag__c = 'Stop';
            progEnrollment.WaitlistFlag__c = 'Active';
            //Commented Deprecate Technology flag logic for US 476956
            //progEnrollment.UserTechnologyFlag__c = 'Pending Review';
            progEnrollment.HomelessRiskFlag__c = 'Potential Homeless';

            progEnrollment.PriorWithdrawalFlag__c = 'Hold';
            progEnrollment.GradeLevelEligibility__c = 'Allowed to Enroll';
            progEnrollment.EntranceAgeEligibilitySystem__c = 'Eligible' ;
            progEnrollment.WhyFlagged__c='Testing';
            programEnrollmentList.add(progEnrollment);
        }

        Test.StartTest();
        update programEnrollmentList;
        Test.StopTest();
        for (hed__Program_Enrollment__c progEnrollment : [SELECT Id,WhyFlagged__c FROM hed__Program_Enrollment__c LIMIT 1]) {
            System.assertNotEquals(progEnrollment.WhyFlagged__c, null);

        }


    }

    Static TestMethod void calculateStudentsEnrolledTest(){
        List<hed__Program_Enrollment__c> progEnrollmentsToUpdate = new List<hed__Program_Enrollment__c>();
        Program_Grade_Level__c progGrade = [SELECT Id,Academic_Program__c,Grade_Level__r.Name,Number_of_Enrolled_Students__c
                                                    FROM Program_Grade_Level__c WHERE Grade_Level__r.Name = '1'];

        Program_Grade_Level__c progGradeUpdated = [SELECT Id FROM Program_Grade_Level__c WHERE Id =:progGrade.Id LIMIT 1];
        Integer i=0;
        for(hed__Program_Enrollment__c progEnrollment : [SELECT id,Status__c,Enrollment_Type__c,hed__Account__c,Final_Grade_Level__c FROM hed__Program_Enrollment__c WHERE Status__c <> 'Complete' AND SIS_Integration_Status__c != null]){
            if(i == 0){
                progEnrollment.Status__c = 'Complete';
                progEnrollment.hed__Account__c = progGrade.Academic_Program__c;
                progEnrollment.Final_Grade_Level__c = '1';
                progEnrollment.Enrollment_Type__c='Initial Enrollment';
            }else {
                progEnrollment.Final_Grade_Level__c = '1';
                progEnrollment.Status__c = 'Complete';
            }
            progEnrollmentsToUpdate.add(progEnrollment);
            i +=1 ;
        }
        Test.startTest();
        update progEnrollmentsToUpdate;
        System.assert(progGrade.Number_of_Enrolled_Students__c != 0);
        Test.stopTest();
                              
    }
    
    
}