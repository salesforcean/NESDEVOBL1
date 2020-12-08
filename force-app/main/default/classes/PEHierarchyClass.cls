/**
    @class:         ExpressionParserTest           
	@author: 		Mark Membrino
	@date:			8/31/2020
	@description:   Test coverage expression evaluator, part of rewrite of the ECA assignment and completion logic.
    @classes-covered with coverage snapshot: 	
        => SyntaxKind (% coverage)
        
        // ECA_HierarchyStatusUpdateTest
            // Forward: Section is marked completed from Not-Started, Section has only 1 Form, so Stage=completed, next stage goes to 'In Progress'
            // Backward: Section is marked In-progress from Complete, Section has only 1 Form, so Stage/Form/Section go to 'In Progress' & next stage goes to 'Not Started'

        // ECA_CriteriaEvaluatorTest
            // ensure you cover all the test in the Truth-table
            // ensure you fire it on Insert & on Update whe is_Dirty__c flag is set to true.

        // ECA_CriteriaEvaluatorHelperTest (OPTIONAL, in case covrage is low)

*/
@isTest(SeeAllData=false isParallel=true)
public class PEHierarchyClass
{
    @TestSetup
    static void setup()
    {
        // create:  
            // academic-program-account, 
            // caretaker-account, 
            // contact-parent, 
            // contact-child
        // create: school-configuration
            // ECs (Process, Stages (atleast 2), Forms, Sections)
            // criteria (atleast 2)
            // tie criteria to EC.ECCs (atleast 2)
            // add assignment & completion logic to the ECCs.EC
            // Map Process hierarchy in ECRs
        // create: 
            // hh-pe, 
            // stud-pe
                // ECAs 
                    // (Stage-1 & children as In-progress / Not Started)
                    // (Stage-2 & children as Not Started)

        setupTestSchoolReferentialData();
        // setupGenericTestData();
        // setupTestSpecificData();

    }

    public static void setupTestSchoolReferentialData() 
    {

        Account account = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019', Date.parse('11/17/2018'));
        // School_Year__c previousSchoolYear = Peak_TestUtils.createSchoolYears('2017-2018', Date.parse('11/17/2017'));


        // Create a contact with 'Students' record type
        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);


        // Create a account with 'Academic Program' record type
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(account.Id, currentSchoolYear.Id);
        academicProgram.Registration_End_Date__c=Date.today().addMonths(1);
        academicProgram.Registration_Start_Date__c=Date.newInstance(2017,11,11);
        academicProgram.Confirmation_End_Date__c = Date.today().addMonths(1);
        update academicProgram;


        // Create STUDENT PE
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, contact.Id, currentSchoolYear.Id, false);
        progEnrollment.Status__c='Inactive';
        insert progEnrollment;


        // NOT SURE WHY WE NEED Relationship
        User u = [SELECT Id,ContactId FROM User WHERE ContactId != NULL AND IsActive = TRUE LIMIT 1];
        hed__Relationship__c  relationship = Peak_TestUtils.createRelationship(u.ContactId, contact.Id, true);


        // Create nodes (w/ECs)
        Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Process', false); // Level 1 process
        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false); // Level 2 stages 
        Enrollment_Component__c formComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false); // Level 3 forms
        // Level 4 sections
        Enrollment_Component__c sectionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        Enrollment_Component__c documentComponentForForm = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Document', false);
        // Level 5 questionGroups / questions (for sections)
        Enrollment_Component__c questionGroupComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);
        Enrollment_Component__c questionComponentForSection1 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false); 
        Enrollment_Component__c questionComponentForSection2 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        Enrollment_Component__c messageComponentForSection = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Message', false);
        // Level 6 questions 
        Enrollment_Component__c questionComponentForQG1 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        Enrollment_Component__c questionComponentForQG2 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        Enrollment_Component__c questionComponentForQG3 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        

        // insert nodes
        List < Enrollment_Component__c > componentList = new List < Enrollment_Component__c > ();
        componentList.add(processComponent);
        componentList.add(stageComponent);
        componentList.add(formComponent);
        componentList.add(sectionComponent);
        componentList.add(documentComponentForForm);
        componentList.add(questionGroupComponent);
        componentList.add(questionComponentForSection1);
        componentList.add(questionComponentForSection2);
        componentList.add(messageComponentForSection);
        componentList.add(questionComponentForQG1);
        componentList.add(questionComponentForQG2);
        componentList.add(questionComponentForQG3);
        insert componentList;

        // insert Criteria
        // insert ECC
        // update EC Assignment / Completion Criteria
        
        // @todo: Optimize this, currently each record is inserted...
        // tie the nodes (by ECRs)
        Enrollment_Component_Relationship__c stageECR = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponent.Id, processComponent.Id); // level-1
        Enrollment_Component_Relationship__c formECR = Peak_TestUtils.createEnrollmentComponentRelationship(formComponent.Id, stageComponent.Id); // level-2
        Enrollment_Component_Relationship__c sectionECR = Peak_TestUtils.createEnrollmentComponentRelationship(sectionComponent.Id, formComponent.Id); // level-3
        Enrollment_Component_Relationship__c documentECR = Peak_TestUtils.createEnrollmentComponentRelationship(documentComponentForForm.Id, formComponent.Id); // level-3
        
        Enrollment_Component_Relationship__c questionGroupECR = Peak_TestUtils.createEnrollmentComponentRelationship(questionGroupComponent.Id, sectionComponent.Id); // level-4
        Enrollment_Component_Relationship__c questionToSectionECR1 = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponentForSection1.Id, sectionComponent.Id); // level-4
        Enrollment_Component_Relationship__c questionToSectionECR2 = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponentForSection2.Id, sectionComponent.Id); // level-4
        Enrollment_Component_Relationship__c messageToSectionECR2 = Peak_TestUtils.createEnrollmentComponentRelationship(messageComponentForSection.Id, sectionComponent.Id); // level-4

        Enrollment_Component_Relationship__c questionGroupECR1 = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponentForQG1.Id, questionGroupComponent.Id); // level-5
        Enrollment_Component_Relationship__c questionGroupECR2 = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponentForQG2.Id, questionGroupComponent.Id); // level-5
        Enrollment_Component_Relationship__c questionGroupECR3 = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponentForQG3.Id, questionGroupComponent.Id); // level-5

    }

    /**
     * test-scenario: Stage1-Section1 status goes from 'Not Started' to 'Complete'
     *
     *  
     **/

    
    @IsTest
    static void testPassingFieldsUpdatesPECriteria3() 
    {

        Criteria__c criteria1 = Peak_TestUtils.createCriteriaRecord(null, 'Annual_Student_Information__c.Grade_Level_Requested__c', '=', false);
        criteria1.Comparison_Data_Type__c = 'Text';
        criteria1.Comparison_Value__c = '5';
        insert criteria1;

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

        hed__program_enrollment__c program_enrollment_1 = Peak_TestUtils.createProgramEnrollment(String.valueOf(academicProgram.Id), String.valueOf(Student.Id), String.valueOf(schoolYear.Id), false);
        insert program_enrollment_1;

        //Insert a Program Enrollment Criteria record that will link the PE to the Criteria record created above.
        Program_Enrollment_Criteria__c newPEC = new Program_Enrollment_Criteria__c (Program_Enrollment__c=program_enrollment_1.Id, Criteria__c = criteria1.id, Result__c = false, School_Year__c = '2019-2020');
        insert newPEC;

        List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> ();
        EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate ();
        newFieldUpdate.programEnrollmentId = program_enrollment_1.Id;
        newFieldUpdate.objectAndFieldName = 'Annual_Student_Information__c.Grade_Level_Requested__c';
        newFieldUpdate.schoolYear = 'NOT2019-2020';  //Notice that the school doesn't match from the school year from the PE Criteria
        newFieldUpdate.newValue = '5';
        fieldUpdateList.add(newFieldUpdate);

        Test.startTest();
        EvaluationUtils.evaluateChangedFields  (fieldUpdateList);
        Test.stopTest();

        List<Program_Enrollment_Criteria__c> afterEvaluate = new List<Program_Enrollment_Criteria__c> ([select Result__c from Program_Enrollment_Criteria__c]);

        //This test confirms that when the the school year is used and they DON'T match, the criteria is NOT updated.
        System.assertEquals(false, afterEvaluate[0].Result__c);
    }
}