/**
 * Created by Ajith on 15-04-2019.
 * Added other Age Eligibility fields needed for calcuations US114797 (Andrew Sim) on 11/05/19
 */

@isTest
public with sharing class NES_ASIUtilitiesTest {
    @TestSetup
    static void setup(){
        //Create Educational Institutional Account i.e.., Parent Account
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();

        //Insert the School Year record
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('Test School Year', System.today());

        //Create Academic Program Account i.e.., Child Account
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, schoolYear.Id);
        academicProgram.Registration_Start_Date__c = System.today().addDays(-10);
        academicProgram.Registration_End_Date__c = System.today().addDays(10);
        update academicProgram;

        // Create a Contact with 'Caretaker' record type
        Contact careTakerContact = Peak_TestUtils.createTestContact('Caretaker', institutionAccount.Id);

        //Create a care taker user for community
        User careTaker = Peak_TestUtils.CreatePortalCaretTakerUser(careTakerContact.Id);

        // Create a Contact with 'Students' record type
        Contact student = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);

        //Commenting the insertion of the Relationship and PE record since they would be inserted from the AddStudentHelper Code
        //Create a relationship between the User Contact and Student Contact
        //hed__Relationship__c  relationship = Peak_TestUtils.createRelationship(careTaker.ContactId, student.Id, true);

        //Create a student enrollment for the CareTaker Contact
        //hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, careTaker.ContactId, schoolYear.Id, true);

        // Create a Enrollment Components with different record type
        List<Enrollment_Component__c> componentList = new List <Enrollment_Component__c>();
        Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Process', false);
        processComponent.Assignment_Logic__c = '1';

        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);

        Enrollment_Component__c formComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        formComponent.Assignment_Logic__c = '1';

        Enrollment_Component__c formComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        formComponent_With_No_Logic.Assignment_Logic__c = null;

        Enrollment_Component__c sectionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent.Assignment_Logic__c = '1';

        Enrollment_Component__c sectionComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent_With_No_Logic.Assignment_Logic__c = null;

        Enrollment_Component__c questionGroupComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);
        questionGroupComponent.Assignment_Logic__c = '1';

        Enrollment_Component__c questionGroupComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);
        questionGroupComponent_With_No_Logic.Assignment_Logic__c = null;

        Enrollment_Component__c questionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponent.Component_Type__c = 'Household';
        questionComponent.Assignment_Logic__c = '1';

        Enrollment_Component__c questionComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponent_With_No_Logic.Component_Type__c = 'Household';
        questionComponent_With_No_Logic.Assignment_Logic__c = null;


        componentList.add(processComponent);
        componentList.add(stageComponent);
        componentList.add(formComponent);
        componentList.add(formComponent_With_No_Logic);
        componentList.add(sectionComponent);
        componentList.add(sectionComponent_With_No_Logic);
        componentList.add(questionGroupComponent);
        componentList.add(questionGroupComponent_With_No_Logic);
        componentList.add(questionComponent);
        componentList.add(questionComponent_With_No_Logic);

        insert componentList;

        // create Enrollment Component Relationships with different parent Enrollment Components.
        Enrollment_Component_Relationship__c process_stage_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponent.Id, processComponent.Id);

        Enrollment_Component_Relationship__c stage_form_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(formComponent.Id, stageComponent.Id);
        Enrollment_Component_Relationship__c stage_form_with_no_logic_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(formComponent_With_No_Logic.Id, stageComponent.Id);
        stage_form_with_no_logic_ECR.Order__c = 2;
        update stage_form_with_no_logic_ECR;

        Enrollment_Component_Relationship__c form_section_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(sectionComponent.Id, formComponent.Id);
        Enrollment_Component_Relationship__c form_section_with_no_logic_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(sectionComponent_With_No_Logic.Id, formComponent.Id);
        form_section_with_no_logic_ECR.Order__c = 2;
        update form_section_with_no_logic_ECR;

        Enrollment_Component_Relationship__c section_question_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponent.Id, sectionComponent_With_No_Logic.Id);
        Enrollment_Component_Relationship__c section_question_with_no_logic_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponent_With_No_Logic.Id, sectionComponent_With_No_Logic.Id);
        section_question_with_no_logic_ECR.Order__c = 2;
        update section_question_with_no_logic_ECR;

        Enrollment_Component_Relationship__c questionGroup_question_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponent.Id,questionGroupComponent_With_No_Logic.Id);
        Enrollment_Component_Relationship__c questionGroup_question_with_no_logic_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponent_With_No_Logic.Id,questionGroupComponent_With_No_Logic.Id);
        questionGroup_question_with_no_logic_ECR.Order__c = 2;
        update questionGroup_question_with_no_logic_ECR;

        Enrollment_Component_Relationship__c section_questionGroup_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(questionGroupComponent.Id,sectionComponent_With_No_Logic.Id);
        section_questionGroup_ECR.Order__c = 3;
        update section_questionGroup_ECR;
        Enrollment_Component_Relationship__c section_questionGroup_with_no_logic_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(questionGroupComponent_With_No_Logic.Id,sectionComponent_With_No_Logic.Id);
        section_questionGroup_with_no_logic_ECR.Order__c = 4;
        update section_questionGroup_with_no_logic_ECR;


        Criteria__c finalConformationCriteria = Peak_TestUtils.createCriteriaRecord(null, 'hed__Program_Enrollment__c.hed__Account__r.Confirmation_Start_Date__c', '<=', false);
        finalConformationCriteria.Comparison_Data_Type__c = 'Datetime';
        finalConformationCriteria.Comparison_Value__c = 'today()';
        insert finalConformationCriteria;

        Enrollment_Component_Criteria__c studentEnrollmentComponentCriteria = Peak_TestUtils.createEnrollCompCriteria(null, formComponent.Id, false);
        studentEnrollmentComponentCriteria.Criteria__c = finalConformationCriteria.Id;
        studentEnrollmentComponentCriteria.Student_or_Household__c = 'Student';
        studentEnrollmentComponentCriteria.Criteria_Number__c = 1;
        insert studentEnrollmentComponentCriteria;

        Enrollment_Component_Criteria__c houseHoldEnrollmentComponentCriteria = Peak_TestUtils.createEnrollCompCriteria(null, formComponent.Id, false);
        houseHoldEnrollmentComponentCriteria.Criteria__c = finalConformationCriteria.Id;
        houseHoldEnrollmentComponentCriteria.Student_or_Household__c = 'Household';
        houseHoldEnrollmentComponentCriteria.Criteria_Number__c = 2;
        insert houseHoldEnrollmentComponentCriteria;

        Criteria_Group__c criteriaGroup = Peak_TestUtils.createCriteriaGroup(null, formComponent.Id, false);
        criteriaGroup.Group_Number__c = 1;
        criteriaGroup.Group_Logic__c = '2';
        insert criteriaGroup;

        Criteria_Refinement__c refinementOne = new Criteria_Refinement__c();
        refinementOne.Criteria__c = finalConformationCriteria.Id;
        refinementOne.Refinement_Field_Left__c = 'hed__account__r.Name';
        refinementOne.Refinement_Type__c = 'Right Side';
        refinementOne.Operator__c = '=';
        refinementOne.Refinement_Value__c = 'TNCA';
        insert refinementOne;

        Criteria_Refinement__c refinementTwo = new Criteria_Refinement__c();
        refinementTwo.Criteria__c = finalConformationCriteria.Id;
        refinementTwo.Refinement_Field_Left__c = 'hed__account__r.Name';
        refinementTwo.Refinement_Type__c = 'Right Side';
        refinementTwo.Operator__c = '=';
        refinementTwo.Refinement_Value__c = 'Pearson Pre';
        insert refinementTwo;

        Criteria_Refinement__c refinementThree = new Criteria_Refinement__c();
        refinementThree.Criteria__c = finalConformationCriteria.Id;
        refinementThree.Refinement_Field_Left__c = 'hed__account__r.Name';
        refinementThree.Refinement_Type__c = 'Left Side';
        refinementThree.Operator__c = '=';
        refinementThree.Refinement_Value__c = 'Pearson Pre';
        //insert refinementThree;

        hed__Program_Enrollment__c progEnrollment1 = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, careTakerContact.Id,schoolYear.Id, false);
        progEnrollment1.EntranceAgeEligibilitySystem__c = '';
        progEnrollment1.EntranceAgeEligibilityOverride__c = '';
        progEnrollment1.Start_Year__c =schoolYear.Id;
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

        Enrollment_Component_Affiliation__c eca1 = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment1.Id, formComponent_With_No_Logic.Id, false);
        insert eca1;

        Annual_Student_Information__c asi1 = Peak_TestUtils.createAnnualStudentInformation('Test ASI1', progEnrollment1.Id, schoolYear.Id, false);
        insert asi1;
    }
    static testMethod void calculateRecommendedAutoPlacementTest1(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];   
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.PlacementFlag__c = 'Principal Review';
        update currentProgramEnrollment;
        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';      
        insert education;
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument1.Type__c = 'IEP Exit Documentation';
        enrollmentDocument1.Status_Reason__c = 'Requested';
        insert enrollmentDocument1;
        Annual_Student_Information__c currentASI = [SELECT Id,LA_Placement_Level__c,RecommendedAutoPlacement__c,Final_Grade_Level__c,Math_Placement_Level__c,Grade_Level_Requested__c FROM Annual_Student_Information__c WHERE Name = 'Test ASI1' ];
        currentASI.LA_Placement_Level__c = '2';
        currentASI.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';  
        currentASI.Grade_Level_Requested__c = '8';
        currentASI.Final_Grade_Level__c = '9';
        update  currentASI;
        List<Id> ASId = new List<Id>();
        ASId.add(currentASI.Id);
        //System.enqueueJob(new NES_PlacementQueueable(ASId));
    }
    static testMethod void calculateRecommendedAutoPlacementTest2(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.EntranceAgeEligibilityOverride__c = 'Ineligible';
        update currentProgramEnrollment;
        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument1.Type__c = 'IEP Exit Documentation';
        enrollmentDocument1.Status_Reason__c = 'Requested';
        insert enrollmentDocument1;
        Annual_Student_Information__c currentASI = [SELECT Id,LA_Placement_Level__c,RecommendedAutoPlacement__c,Final_Grade_Level__c,Math_Placement_Level__c,Grade_Level_Requested__c FROM Annual_Student_Information__c WHERE Name = 'Test ASI1' ];
        currentASI.LA_Placement_Level__c = '2';
        currentASI.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI.Grade_Level_Requested__c = '8';
        currentASI.Final_Grade_Level__c = '9';
        update  currentASI;
        List<Id> ASId = new List<Id>();
        ASId.add(currentASI.Id);
        //System.enqueueJob(new NES_PlacementQueueable(ASId));
    }
    static testMethod void calculateRecommendedAutoPlacementTest3(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.EntranceAgeEligibilityOverride__c = 'Pending Review';
        update currentProgramEnrollment;
        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument1.Type__c = 'IEP Exit Documentation';
        enrollmentDocument1.Status_Reason__c = 'Requested';
        insert enrollmentDocument1;
        Annual_Student_Information__c currentASI = [SELECT Id,LA_Placement_Level__c,RecommendedAutoPlacement__c,Final_Grade_Level__c,Math_Placement_Level__c,Grade_Level_Requested__c FROM Annual_Student_Information__c WHERE Name = 'Test ASI1' ];
        currentASI.LA_Placement_Level__c = '2';
        currentASI.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI.Grade_Level_Requested__c = '8';
        currentASI.Final_Grade_Level__c = '9';
        update  currentASI;
        List<Id> ASId = new List<Id>();
        ASId.add(currentASI.Id);
        Annual_Student_Information__c Asi = [SELECT Id,RecommendedAutoPlacement__c FROM Annual_Student_Information__c WHERE Id = :currentASI.Id];
        // System.assertEquals('Excluded',Asi.RecommendedAutoPlacement__c);
        //System.enqueueJob(new NES_PlacementQueueable(ASId));
    }
    static testMethod void calculateRecommendedAutoPlacementTest4(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.EntranceAgeEligibilityOverride__c = 'Pending Review';
        update currentProgramEnrollment;
        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument1.Type__c = 'IEP Exit Documentation';
        enrollmentDocument1.Status_Reason__c = 'Requested';
        insert enrollmentDocument1;
        Annual_Student_Information__c currentASI = [SELECT Id,LA_Placement_Level__c,RecommendedAutoPlacement__c,Final_Grade_Level__c,Math_Placement_Level__c,Grade_Level_Requested__c FROM Annual_Student_Information__c WHERE Name = 'Test ASI1' ];
        currentASI.LA_Placement_Level__c = '2';
        currentASI.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI.Grade_Level_Requested__c = '8';
        currentASI.Final_Grade_Level__c = '9';
        update  currentASI;
        List<Id> ASId = new List<Id>();
        ASId.add(currentASI.Id);
        Annual_Student_Information__c Asi = [SELECT Id,RecommendedAutoPlacement__c FROM Annual_Student_Information__c WHERE Id = :currentASI.Id];
        // System.assertEquals('Excluded',Asi.RecommendedAutoPlacement__c);
        //System.enqueueJob(new NES_PlacementQueueable(ASId));
    }
    static testMethod void calculateRecommendedAutoPlacementTest5(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.PlacementFlag__c = 'Awaiting Communication- More Info';
        update currentProgramEnrollment;
        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument1.Type__c = 'IEP Exit Documentation';
        enrollmentDocument1.Status_Reason__c = 'Requested';
        insert enrollmentDocument1;
        Annual_Student_Information__c currentASI = [SELECT Id,LA_Placement_Level__c,RecommendedAutoPlacement__c,Final_Grade_Level__c,Math_Placement_Level__c,Grade_Level_Requested__c FROM Annual_Student_Information__c WHERE Name = 'Test ASI1' ];
        currentASI.LA_Placement_Level__c = '2';
        currentASI.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI.Grade_Level_Requested__c = '8';
        currentASI.Final_Grade_Level__c = '9';
        update  currentASI;
        List<Id> ASId = new List<Id>();
        ASId.add(currentASI.Id);
        Annual_Student_Information__c Asi = [SELECT Id,RecommendedAutoPlacement__c FROM Annual_Student_Information__c WHERE Id = :currentASI.Id];
        // System.assertEquals('Excluded',Asi.RecommendedAutoPlacement__c);
        //System.enqueueJob(new NES_PlacementQueueable(ASId));
    }
    static testMethod void calculateRecommendedAutoPlacementTest6(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.EnrollmentSpecialistContactReq__c = 'Pending Review';
        update currentProgramEnrollment;
        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument1.Type__c = 'IEP Exit Documentation';
        enrollmentDocument1.Status_Reason__c = 'Requested';
        insert enrollmentDocument1;
        Annual_Student_Information__c currentASI = [SELECT Id,LA_Placement_Level__c,RecommendedAutoPlacement__c,Final_Grade_Level__c,Math_Placement_Level__c,Grade_Level_Requested__c FROM Annual_Student_Information__c WHERE Name = 'Test ASI1' ];
        currentASI.LA_Placement_Level__c = '2';
        currentASI.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI.Grade_Level_Requested__c = '8';
        currentASI.Final_Grade_Level__c = '9';
        update  currentASI;
        List<Id> ASId = new List<Id>();
        ASId.add(currentASI.Id);
        Annual_Student_Information__c Asi = [SELECT Id,RecommendedAutoPlacement__c FROM Annual_Student_Information__c WHERE Id = :currentASI.Id];
        // System.assertEquals('Excluded',Asi.RecommendedAutoPlacement__c);
        //System.enqueueJob(new NES_PlacementQueueable(ASId));
    }
    static testMethod void calculateRecommendedAutoPlacementTest7(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.PlacementFlag__c = 'Awaiting Communication- School Counselor';
        update currentProgramEnrollment;
        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument1.Type__c = 'IEP Exit Documentation';
        enrollmentDocument1.Status_Reason__c = 'Requested';
        insert enrollmentDocument1;
        Annual_Student_Information__c currentASI = [SELECT Id,LA_Placement_Level__c,RecommendedAutoPlacement__c,Final_Grade_Level__c,Math_Placement_Level__c,Grade_Level_Requested__c FROM Annual_Student_Information__c WHERE Name = 'Test ASI1' ];
        currentASI.LA_Placement_Level__c = '2';
        currentASI.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI.Grade_Level_Requested__c = '8';
        currentASI.Final_Grade_Level__c = '9';
        update  currentASI;
        List<Id> ASId = new List<Id>();
        ASId.add(currentASI.Id);
        Annual_Student_Information__c Asi = [SELECT Id,RecommendedAutoPlacement__c FROM Annual_Student_Information__c WHERE Id = :currentASI.Id];
        // System.assertEquals('Excluded',Asi.RecommendedAutoPlacement__c);
        //System.enqueueJob(new NES_PlacementQueueable(ASId));
    }
    static testMethod void calculateRecommendedAutoPlacementTest8(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.PlacementFlag__c = 'Counselor Review';
        update currentProgramEnrollment;
        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument1.Type__c = 'IEP Exit Documentation';
        enrollmentDocument1.Status_Reason__c = 'Requested';
        insert enrollmentDocument1;
        Annual_Student_Information__c currentASI = [SELECT Id,LA_Placement_Level__c,RecommendedAutoPlacement__c,Final_Grade_Level__c,Math_Placement_Level__c,Grade_Level_Requested__c FROM Annual_Student_Information__c WHERE Name = 'Test ASI1' ];
        currentASI.LA_Placement_Level__c = '2';
        currentASI.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI.Grade_Level_Requested__c = '8';
        currentASI.CoursesFinalized__c = 'Yes';
        currentASI.Final_Grade_Level__c = '1';
        currentASI.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';

        update  currentASI;
        List<Id> ASId = new List<Id>();
        ASId.add(currentASI.Id);
        Annual_Student_Information__c Asi = [SELECT Id,RecommendedAutoPlacement__c FROM Annual_Student_Information__c WHERE Id = :currentASI.Id];
        // System.assertEquals('Excluded',Asi.RecommendedAutoPlacement__c);
        //System.enqueueJob(new NES_PlacementQueueable(ASId));
    }
    static testMethod void calculateRecommendedAutoPlacementTest9(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.PlacementFlag__c = 'Counselor Review';
        update currentProgramEnrollment;
        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument1.Type__c = 'IEP Exit Documentation';
        enrollmentDocument1.Status_Reason__c = 'Requested';
        insert enrollmentDocument1;
        Annual_Student_Information__c currentASI = [SELECT Id,LA_Placement_Level__c,RecommendedAutoPlacement__c,Final_Grade_Level__c,Math_Placement_Level__c,Grade_Level_Requested__c FROM Annual_Student_Information__c WHERE Name = 'Test ASI1' ];
        currentASI.LA_Placement_Level__c = '2';
        currentASI.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI.Grade_Level_Requested__c = '8';
        currentASI.CoursesFinalized__c = 'Yes';
        currentASI.Final_Grade_Level__c = 'K';
        currentASI.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';

        update  currentASI;
        List<Id> ASId = new List<Id>();
        ASId.add(currentASI.Id);
        Annual_Student_Information__c Asi = [SELECT Id,RecommendedAutoPlacement__c FROM Annual_Student_Information__c WHERE Id = :currentASI.Id];
        // System.assertEquals('Excluded',Asi.RecommendedAutoPlacement__c);
        //System.enqueueJob(new NES_PlacementQueueable(ASId));
    }
    static testMethod void calculateRecommendedAutoPlacementTest10(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.PlacementFlag__c = 'Counselor Review';
        update currentProgramEnrollment;
        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument1.Type__c = 'IEP Exit Documentation';
        enrollmentDocument1.Status_Reason__c = 'Requested';
        insert enrollmentDocument1;
        Annual_Student_Information__c currentASI = [SELECT Id,LA_Placement_Level__c,RecommendedAutoPlacement__c,Final_Grade_Level__c,Math_Placement_Level__c,Grade_Level_Requested__c FROM Annual_Student_Information__c WHERE Name = 'Test ASI1' ];
        currentASI.LA_Placement_Level__c = '2';
        currentASI.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI.Grade_Level_Requested__c = '8';
        currentASI.CoursesFinalized__c = 'Yes';
        currentASI.Final_Grade_Level__c = 'K';

        update  currentASI;
        List<Id> ASId = new List<Id>();
        ASId.add(currentASI.Id);
        Annual_Student_Information__c Asi = [SELECT Id,RecommendedAutoPlacement__c FROM Annual_Student_Information__c WHERE Id = :currentASI.Id];
        // System.assertEquals('Excluded',Asi.RecommendedAutoPlacement__c);
        //System.enqueueJob(new NES_PlacementQueueable(ASId));
    }
    static testMethod void calculateRecommendedAutoPlacementTest11(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.PlacementFlag__c = 'Counselor Review';
        update currentProgramEnrollment;
        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument1.Type__c = 'IEP Exit Documentation';
        enrollmentDocument1.Status_Reason__c = 'Requested';
        insert enrollmentDocument1;
        Annual_Student_Information__c currentASI = [SELECT Id,LA_Placement_Level__c,RecommendedAutoPlacement__c,Final_Grade_Level__c,Math_Placement_Level__c,Grade_Level_Requested__c FROM Annual_Student_Information__c WHERE Name = 'Test ASI1' ];
        currentASI.LA_Placement_Level__c = '2';
        currentASI.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI.Grade_Level_Requested__c = '8';
        currentASI.HowStudentPlacementCompleted__c = 'Modified Auto-Placement Process';
        currentASI.CoursesFinalized__c = 'Yes';
        currentASI.Final_Grade_Level__c = '12';

        update  currentASI;
        List<Id> ASId = new List<Id>();
        ASId.add(currentASI.Id);
        Annual_Student_Information__c Asi = [SELECT Id,RecommendedAutoPlacement__c FROM Annual_Student_Information__c WHERE Id = :currentASI.Id];
        // System.assertEquals('Excluded',Asi.RecommendedAutoPlacement__c);
        //System.enqueueJob(new NES_PlacementQueueable(ASId));
    }
    static testMethod void calculateRecommendedAutoPlacementTest12(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.PlacementFlag__c = 'Counselor Review';
        update currentProgramEnrollment;
        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument1.Type__c = 'IEP Exit Documentation';
        enrollmentDocument1.Status_Reason__c = 'Requested';
        insert enrollmentDocument1;
        Annual_Student_Information__c currentASI = [SELECT Id,LA_Placement_Level__c,RecommendedAutoPlacement__c,Final_Grade_Level__c,Math_Placement_Level__c,Grade_Level_Requested__c FROM Annual_Student_Information__c WHERE Name = 'Test ASI1' ];
        currentASI.LA_Placement_Level__c = '2';
        currentASI.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI.Grade_Level_Requested__c = '8';
        currentASI.CoursesFinalized__c = 'Yes';
        currentASI.Final_Grade_Level__c = '12';

        update  currentASI;
        List<Id> ASId = new List<Id>();
        ASId.add(currentASI.Id);
        Annual_Student_Information__c Asi = [SELECT Id,RecommendedAutoPlacement__c FROM Annual_Student_Information__c WHERE Id = :currentASI.Id];
        // System.assertEquals('Excluded',Asi.RecommendedAutoPlacement__c);
        //System.enqueueJob(new NES_PlacementQueueable(ASId));
    }
    static testMethod void calculateRecommendedAutoPlacementTest13(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.PlacementFlag__c = 'Counselor Review';
        update currentProgramEnrollment;
        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument1.Type__c = 'IEP Exit Documentation';
        enrollmentDocument1.Status_Reason__c = 'Requested';
        //insert enrollmentDocument1;
        Annual_Student_Information__c currentASI = [SELECT Id, AutomatedPlacementScore__c,LA_Placement_Level__c,RecommendedAutoPlacement__c,Final_Grade_Level__c,Math_Placement_Level__c,Grade_Level_Requested__c FROM Annual_Student_Information__c WHERE Name = 'Test ASI1' ];
        currentASI.LA_Placement_Level__c = '2';
        currentASI.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI.Grade_Level_Requested__c = '8';
        currentASI.Final_Grade_Level__c = '12';
        update  currentASI;
        List<Id> ASId = new List<Id>();
        ASId.add(currentASI.Id);
        Annual_Student_Information__c Asi = [SELECT Id,RecommendedAutoPlacement__c FROM Annual_Student_Information__c WHERE Id = :currentASI.Id];
        // System.assertEquals('Excluded',Asi.RecommendedAutoPlacement__c);
        //System.enqueueJob(new NES_PlacementQueueable(ASId));
    }
    static testMethod void calculateRecommendedAutoPlacementTest14(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.PlacementFlag__c = 'RC/PAH Not Uploaded';
        update currentProgramEnrollment;
        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument1.Type__c = 'IEP Exit Documentation';
        enrollmentDocument1.Status_Reason__c = 'Requested';
        insert enrollmentDocument1;
        Annual_Student_Information__c currentASI = [SELECT Id, AutomatedPlacementScore__c,LA_Placement_Level__c,RecommendedAutoPlacement__c,Final_Grade_Level__c,Math_Placement_Level__c,Grade_Level_Requested__c FROM Annual_Student_Information__c WHERE Name = 'Test ASI1' ];
        currentASI.LA_Placement_Level__c = '2';
        currentASI.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI.Grade_Level_Requested__c = '8';
        currentASI.Final_Grade_Level__c = '12';
        currentASI.Academic_Documentation_Summary__c = 'Received';
        update  currentASI;
        List<Id> ASId = new List<Id>();
        ASId.add(currentASI.Id);
        Annual_Student_Information__c Asi = [SELECT Id,RecommendedAutoPlacement__c FROM Annual_Student_Information__c WHERE Id = :currentASI.Id];
        // System.assertEquals('Excluded',Asi.RecommendedAutoPlacement__c);
        //System.enqueueJob(new NES_PlacementQueueable(ASId));
    }
    static testMethod void calculateRecommendedAutoPlacementTest15(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.PlacementFlag__c = 'RC/PAH Not Uploaded';
        update currentProgramEnrollment;
        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;
        Annual_Student_Information__c currentASI = [SELECT Id, AutomatedPlacementScore__c,LA_Placement_Level__c,RecommendedAutoPlacement__c,Final_Grade_Level__c,Math_Placement_Level__c,Grade_Level_Requested__c FROM Annual_Student_Information__c WHERE Name = 'Test ASI1' ];
        currentASI.Grade_Level_Requested__c = '8';
        currentASI.Final_Grade_Level__c = '10';
        update  currentASI;
        List<Id> ASId = new List<Id>();
        ASId.add(currentASI.Id);
        Annual_Student_Information__c Asi = [SELECT Id,RecommendedAutoPlacement__c FROM Annual_Student_Information__c WHERE Id = :currentASI.Id];
        // System.assertEquals('Excluded',Asi.RecommendedAutoPlacement__c);
        //System.enqueueJob(new NES_PlacementQueueable(ASId));
    }
    static testMethod void calculateRecommendedAutoPlacementTest16(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.PlacementFlag__c = 'Released';
        currentProgramEnrollment.MoreHighSchoolDocumentation__c = 'Documentation needed';
        update currentProgramEnrollment;
        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument1.Type__c = 'IEP Exit Documentation';
        enrollmentDocument1.Status_Reason__c = 'Verified';
        insert enrollmentDocument1;
        Annual_Student_Information__c currentASI = [SELECT Id, AutomatedPlacementScore__c,LA_Placement_Level__c,RecommendedAutoPlacement__c,Final_Grade_Level__c,Math_Placement_Level__c,Grade_Level_Requested__c FROM Annual_Student_Information__c WHERE Name = 'Test ASI1' ];
        currentASI.LA_Placement_Level__c = '2';
        currentASI.Science_Placement_Level__c = '3';
        currentASI.Academic_Documentation_Summary__c = 'Not Applicable';
        currentASI.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI.Grade_Level_Requested__c = '8';
        currentASI.Final_Grade_Level__c = '12';
        currentASI.CoursesFinalized__c = null;
        update  currentASI;
        List<Id> ASId = new List<Id>();
        ASId.add(currentASI.Id);
        Annual_Student_Information__c Asi = [SELECT Id,RecommendedAutoPlacement__c FROM Annual_Student_Information__c WHERE Id = :currentASI.Id];
        // System.assertEquals('Excluded',Asi.RecommendedAutoPlacement__c);
        //System.enqueueJob(new NES_PlacementQueueable(ASId));
    }
    static testMethod void calculateRecommendedAutoPlacementTest17(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c LIMIT 1];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c FROM hed__Program_Enrollment__c LIMIT 1];
        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        insert education;
        Annual_Student_Information__c currentASI = [SELECT Id, AutomatedPlacementScore__c,LA_Placement_Level__c,RecommendedAutoPlacement__c,Final_Grade_Level__c,Math_Placement_Level__c,Grade_Level_Requested__c FROM Annual_Student_Information__c LIMIT 1 ];
        update  currentASI;
        List<Id> ASId = new List<Id>();
        ASId.add(currentASI.Id);
        Annual_Student_Information__c Asi = [SELECT Id,RecommendedAutoPlacement__c FROM Annual_Student_Information__c WHERE Id = :currentASI.Id];
        // System.assertEquals('Excluded',Asi.RecommendedAutoPlacement__c);
        //System.enqueueJob(new NES_PlacementQueueable(ASId));
    }

    static testMethod void calculateRecommendedAutoPlacementTest18(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.PlacementFlag__c = 'Released';
        currentProgramEnrollment.MoreHighSchoolDocumentation__c = 'Documentation needed';
        update currentProgramEnrollment;
        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument1.Type__c = 'IEP Exit Documentation';
        enrollmentDocument1.Status_Reason__c = 'Verified';
        insert enrollmentDocument1;
        Annual_Student_Information__c currentASI = [SELECT Id, AutomatedPlacementScore__c, School_Year__r.Start_Date__c, LA_Placement_Level__c,RecommendedAutoPlacement__c,Final_Grade_Level__c,Math_Placement_Level__c,Grade_Level_Requested__c FROM Annual_Student_Information__c WHERE Name = 'Test ASI1' ];
        currentASI.LA_Placement_Level__c = '2';
        currentASI.Science_Placement_Level__c = '3';
        currentASI.Academic_Documentation_Summary__c = 'Not Applicable';
        currentASI.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI.Grade_Level_Requested__c = '8';
        currentASI.Final_Grade_Level__c = '12';
        currentASI.CoursesFinalized__c = null;
        update  currentASI;
        System.debug(currentASI.School_Year__r.Start_Date__c);
        List<Id> ASId = new List<Id>();
        ASId.add(currentASI.Id);
        Annual_Student_Information__c Asi = [SELECT Id,RecommendedAutoPlacement__c FROM Annual_Student_Information__c WHERE Id = :currentASI.Id];
        // System.assertEquals('Excluded',Asi.RecommendedAutoPlacement__c);
       // System.enqueueJob(new NES_PlacementQueueable(ASId));
    }

    static testMethod void calculateRecommendedAutoPlacementTest19(){
        Set<Id> asiIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.PlacementFlag__c = 'Released';
        currentProgramEnrollment.WhyFlagged__c  = 'Disciplinary';
        update currentProgramEnrollment;
        Special_Education__c education = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education.IEP__c = 'Documenting';
        insert education;
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument1.Type__c = 'IEP Exit Documentation';
        enrollmentDocument1.Status_Reason__c = 'Verified';
        insert enrollmentDocument1;
        Annual_Student_Information__c currentASI = [SELECT Id, AutomatedPlacementScore__c, School_Year__r.Start_Date__c, LA_Placement_Level__c,RecommendedAutoPlacement__c,Final_Grade_Level__c,Math_Placement_Level__c,Grade_Level_Requested__c FROM Annual_Student_Information__c WHERE Name = 'Test ASI1' ];
        currentASI.LA_Placement_Level__c = '2';
        currentASI.Science_Placement_Level__c = '3';
        currentASI.Academic_Documentation_Summary__c = 'Not Applicable';
        currentASI.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI.Grade_Level_Requested__c = '8';
        currentASI.Final_Grade_Level__c = '12';
        currentASI.CoursesFinalized__c = null;
        update  currentASI;
        System.debug(currentASI.School_Year__r.Start_Date__c);
        List<Id> ASId = new List<Id>();
        ASId.add(currentASI.Id);
        Annual_Student_Information__c Asi = [SELECT Id,RecommendedAutoPlacement__c FROM Annual_Student_Information__c WHERE Id = :currentASI.Id];
        // System.assertEquals('Excluded',Asi.RecommendedAutoPlacement__c);
        //System.enqueueJob(new NES_PlacementQueueable(ASId));
    }

    static testMethod void calculateAutomatedPlacementExclude1(){
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c, hed__Account__r.AutomatedPlacementExclude__c, hed__Account__c, Start_Year__c, hed__Account__r.ParentId FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];

        Account acc = [SELECT Id, Name FROM Account WHERE Id =: currentProgramEnrollment.hed__Account__r.ParentId];
        acc.Name = 'NMCA';
        update acc;

        Account eduAcc = [SELECT Id FROM Account where Id =:currentProgramEnrollment.hed__Account__c];
        eduAcc.AutomatedPlacementExclude__c = true;
        update eduAcc;

        List<Special_Education__c> educationList = new List<Special_Education__c>();
        Special_Education__c education1 = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education1.IEP__c = 'Documenting';
        educationList.add(education1);

        Special_Education__c education2 = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education2.IEP__c = 'Documenting';
        educationList.add(education2);
        insert educationList;

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
        List<Id> ASId = new List<Id>();
        Annual_Student_Information__c currentASI1 = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', currentProgramEnrollment.Id, currentProgramEnrollment.Start_Year__c, false);
        currentASI1.Final_Grade_Level__c = '3';
        currentASI1.LA_Placement_Level__c = '3';
        currentASI1.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI1.Grade_Level_Requested__c = '3';
        currentASI1.GiftedProgramRequest_LA_M_S__c = 'Math';
        insert currentASI1;
        ASId.add(currentASI1.Id);

        List<Prior_School__c> priorSchoolsList = new List<Prior_School__c>();

        Prior_School__c priorSchool_Homeschool = Peak_TestUtils.createPriorSchool(currentProgramEnrollment.Id, 'HomeSchool', false);
        priorSchool_Homeschool.School_Year__c = currentProgramEnrollment.Start_Year__c;
        priorSchoolsList.add(priorSchool_Homeschool);

        insert priorSchoolsList;

        Placement_and_Elective__c placementAndElective = Peak_TestUtils.createPlacementAndElective(currentProgramEnrollment.Id, true);

        currentProgramEnrollment.PlacementFlag__c = 'Released';
        currentProgramEnrollment.EntranceAgeEligibilityOverride__c = 'Eligible';
        currentProgramEnrollment.Credit_for_HS_Coursework__c = 'Yes';
        //currentProgramEnrollment.hed__Account__r.AutomatedPlacementExclude__c = true;
        update currentProgramEnrollment;

        //System.enqueueJob(new NES_PlacementQueueable(ASId));
    }

    static testMethod void calculateAutomatedPlacementExclude2(){
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c, hed__Account__r.AutomatedPlacementExclude__c, hed__Account__c, Start_Year__c, hed__Account__r.ParentId FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];

        Account acc = [SELECT Id, Name FROM Account WHERE Id =: currentProgramEnrollment.hed__Account__r.ParentId];
        acc.Name = 'NMCA';
        update acc;

        Account eduAcc = [SELECT Id FROM Account where Id =:currentProgramEnrollment.hed__Account__c];
        eduAcc.AutomatedPlacementExclude__c = true;
        update eduAcc;

        List<Special_Education__c> educationList = new List<Special_Education__c>();
        Special_Education__c education1 = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education1.IEP__c = 'Documenting';
        educationList.add(education1);

        Special_Education__c education2 = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education2.IEP__c = 'Documenting';
        educationList.add(education2);
        insert educationList;

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
        List<Id> ASId = new List<Id>();
        Annual_Student_Information__c currentASI1 = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', currentProgramEnrollment.Id, currentProgramEnrollment.Start_Year__c, false);
        currentASI1.Final_Grade_Level__c = '3';
        currentASI1.LA_Placement_Level__c = '3';
        currentASI1.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI1.Grade_Level_Requested__c = '3';
        currentASI1.GiftedProgramRequest_LA_M_S__c = 'Math';
        insert currentASI1;
        ASId.add(currentASI1.Id);

        Placement_and_Elective__c placementAndElective = Peak_TestUtils.createPlacementAndElective(currentProgramEnrollment.Id, true);

        currentProgramEnrollment.PlacementFlag__c = 'Released';
        currentProgramEnrollment.EntranceAgeEligibilityOverride__c = 'Eligible';
        currentProgramEnrollment.Credit_for_HS_Coursework__c = 'Yes';
        //currentProgramEnrollment.hed__Account__r.AutomatedPlacementExclude__c = true;
        update currentProgramEnrollment;

        //System.enqueueJob(new NES_PlacementQueueable(ASId));
    }

    static testMethod void calculateAutomatedPlacementExclude3(){
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilitySystem__c,EntranceAgeEligibilityOverride__c,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c, hed__Account__r.AutomatedPlacementExclude__c, hed__Account__c, Start_Year__c, hed__Account__r.ParentId FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];

        Account acc = [SELECT Id, Name FROM Account WHERE Id =: currentProgramEnrollment.hed__Account__r.ParentId];
        acc.Name = 'NMCA';
        update acc;

        Account eduAcc = [SELECT Id FROM Account where Id =:currentProgramEnrollment.hed__Account__c];
        eduAcc.AutomatedPlacementExclude__c = true;
        update eduAcc;

        List<Special_Education__c> educationList = new List<Special_Education__c>();
        Special_Education__c education1 = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education1.IEP__c = 'Documenting';
        educationList.add(education1);

        Special_Education__c education2 = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education2.IEP__c = 'Documenting';
        educationList.add(education2);
        insert educationList;

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
        List<Id> ASId = new List<Id>();
        Annual_Student_Information__c currentASI1 = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', currentProgramEnrollment.Id, currentProgramEnrollment.Start_Year__c, false);
        currentASI1.Final_Grade_Level__c = '3';
        currentASI1.LA_Placement_Level__c = '3';
        currentASI1.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI1.Grade_Level_Requested__c = '3';
        currentASI1.GiftedProgramRequest_LA_M_S__c = 'Science';
        insert currentASI1;
        ASId.add(currentASI1.Id);

        List<Prior_School__c> priorSchoolsList = new List<Prior_School__c>();

        Prior_School__c priorSchool_Homeschool = Peak_TestUtils.createPriorSchool(currentProgramEnrollment.Id, 'HomeSchool', false);
        priorSchool_Homeschool.School_Year__c = currentProgramEnrollment.Start_Year__c;
        priorSchoolsList.add(priorSchool_Homeschool);

        insert priorSchoolsList;

        Placement_and_Elective__c placementAndElective = Peak_TestUtils.createPlacementAndElective(currentProgramEnrollment.Id, true);

        currentProgramEnrollment.PlacementFlag__c = 'Released';
        currentProgramEnrollment.EntranceAgeEligibilityOverride__c = 'Eligible';
        currentProgramEnrollment.Credit_for_HS_Coursework__c = 'Yes';
        //currentProgramEnrollment.hed__Account__r.AutomatedPlacementExclude__c = true;
        update currentProgramEnrollment;

        //System.enqueueJob(new NES_PlacementQueueable(ASId));
    }

    static testMethod void calculateAgeTest(){
        Date birthDate = Date.Today();
        Test.startTest();
        NES_AnnualStudentInformationUtilities.calculateAge(birthDate);
        Test.stopTest();
    }
}