/**
 * Created by triciaigoe on 12/26/18.
 */
@IsTest
public with sharing class NES_AddStudentTest {

    @TestSetup
    static void setup() {
        //Account account = Peak_TestUtils.createTestAccount();
        Account account = Peak_TestUtils.createEducationalInstitutionAccount();
        //School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('2018-2019', Date.parse('11/17/2018'));
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('Test School Year', System.today());
        //School_Year__c previousSchoolYear = Peak_TestUtils.createSchoolYears('2017-2018', Date.parse('11/17/2017'));
        User  portalUser= Peak_TestUtils.CreatePortalCaretTakerUser();
        // Create a contact with 'Students' record type
        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);

        // Create a account with 'Academic Program' record type
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(account.Id, schoolYear.Id);
        academicProgram.Registration_Start_Date__c = System.today().addDays(-10);
        academicProgram.Registration_End_Date__c = System.today().addDays(10);
        update academicProgram;
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, portalUser.ContactId, schoolYear.Id, true);

        //User u = [SELECT Id,ContactId FROM User WHERE ContactId != NULL AND IsActive = TRUE LIMIT 1];
        hed__Relationship__c  relationship = Peak_TestUtils.createRelationship(portalUser.ContactId, contact.Id, true);

        // Create a Enrollment Components with different record type
        List < Enrollment_Component__c > componentList = new List < Enrollment_Component__c > ();
        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);
        Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Process', false);
        Enrollment_Component__c questionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        //questionComponent.Component_Type__c = 'Student';
        questionComponent.Component_Type__c = 'Household';
        questionComponent.Assignment_Logic__c = null;
        Enrollment_Component__c sectionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent.Assignment_Logic__c = null;
        Enrollment_Component__c formComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        formComponent.Assignment_Logic__c = null;
        Enrollment_Component__c messageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Message', false);
        Enrollment_Component__c documentComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Document', false);
        Enrollment_Component__c questionGroupComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);
        questionGroupComponent.Assignment_Logic__c = null; 

        componentList.add(questionGroupComponent);
        componentList.add(stageComponent);
        componentList.add(processComponent);
        componentList.add(questionComponent);
        componentList.add(sectionComponent);
        componentList.add(formComponent);
        componentList.add(messageComponent);
        componentList.add(documentComponent);
        insert componentList;

        Criteria_Group__c criteriaGroup1= Peak_TestUtils.createCriteriaGroup('Test CG1',questionComponent.Id,false);
        criteriaGroup1.Group_Number__c = 1;
        criteriaGroup1.Group_Logic__c = '((1 OR 2) AND 3)';
        insert criteriaGroup1;

        Criteria__c criteria1 = Peak_TestUtils.createCriteriaRecord('Test Criteria1','hed__Program_Enrollment__c.LTS__c','>=',false);
        criteria1.Comparison_Field__c = 'hed__Program_Enrollment__c.hed__Credits_Earned__c';
        criteria1.Comparison_Data_Type__c = 'Number';
        insert criteria1;
        Criteria__c criteria2 = Peak_TestUtils.createCriteriaRecord('Test Criteria2','hed__Program_Enrollment__c.LTS__c','>=',false);
        criteria2.Comparison_Field__c = 'hed__Program_Enrollment__c.hed__Credits_Earned__c';
        criteria2.Comparison_Data_Type__c = 'Number';
        insert criteria2;

        Criteria_Refinement__c criteriaRefinement1 = new Criteria_Refinement__c(Criteria__c = criteria1.Id, Refinement_Type__c = 'Left side', Refinement_Value__c = '10',
         Operator__c = '>=',Refinement_Field_Left__c = 'hed__Program_Enrollment__c.LTS__c');
        insert criteriaRefinement1;

        Enrollment_Component_Criteria__c enrollmentComponentCriteria1 = Peak_TestUtils.createEnrollCompCriteria('Test ECC1',questionComponent.Id,false);
        enrollmentComponentCriteria1.Criteria__c = criteria1.Id;
        enrollmentComponentCriteria1.Student_or_Household__c = 'Student';
        enrollmentComponentCriteria1.Criteria_Number__c = 1;
        insert enrollmentComponentCriteria1;

        Enrollment_Component_Criteria__c enrollmentComponentCriteria2 = Peak_TestUtils.createEnrollCompCriteria('Test ECC2',questionComponent.Id,false);
        enrollmentComponentCriteria2.Criteria__c = criteria2.Id;
        enrollmentComponentCriteria2.Student_or_Household__c = 'Household';
        enrollmentComponentCriteria2.Criteria_Number__c = 2;
        insert enrollmentComponentCriteria2;

        // create Enrollment Component Relationships with different parent Enrollment Components.
        Enrollment_Component_Relationship__c enrollCompRelationship = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponent.Id, processComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship2 = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponent.Id, sectionComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship3 = Peak_TestUtils.createEnrollmentComponentRelationship(formComponent.Id, stageComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship4 = Peak_TestUtils.createEnrollmentComponentRelationship(messageComponent.Id, formComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship5 = Peak_TestUtils.createEnrollmentComponentRelationship(sectionComponent.Id, formComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship6 = Peak_TestUtils.createEnrollmentComponentRelationship(questionGroupComponent.Id,sectionComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship7 = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponent.Id,questionGroupComponent.Id);

        // create Enrollment Component Affiliations with different parent Enrollment Components.
        Enrollment_Component_Affiliation__c affiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, formComponent.Id);
        Enrollment_Component_Affiliation__c affiliationStage = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, stageComponent.Id);
        Enrollment_Component_Affiliation__c affiliationSection = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, sectionComponent.Id);
        Enrollment_Component_Affiliation__c affiliationDocument = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, documentComponent.Id);
        Enrollment_Component_Affiliation__c affiliationProcess = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, processComponent.Id);
        Enrollment_Component_Picklist_Option__c picklistOption = Peak_TestUtils.createEnrollmentComponentPicklistOption(questionComponent.Id, true);

        Option_Exclusion__c optionExclusion = new Option_Exclusion__c(Academic_Program__c = academicProgram.Id, Option__c = picklistOption.Id);
        insert optionExclusion;

        // Create a Standard User

        //User  portalUser= Peak_TestUtils.CreatePortalCaretTakerUser();
        //School_Year__c schlYear = Peak_TestUtils.createSchoolYears('SchoolTest', System.today());
        //hed__Program_Enrollment__c ProgramEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, contact.Id, schlYear.Id, false);
        //insert ProgramEnrollmentTest;

    }

    static testMethod void testGetNewStudentData() {
        User portalUser = [SELECT Id FROM User WHERE Username = 'portalUser@gmail.com'];
        Account accnt = [SELECT Id FROM Account WHERE RecordType.Name = 'Educational Institution' LIMIT 1];
        List<School_Year__c> schoolYears = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        Account testAccnt = Peak_TestUtils.createAccountForNewStudentData(accnt.Id, schoolYears[0].Id);
        System.runAs(portalUser) {
            Test.startTest();
            //NES_Utilities.NewStudentData data = NES_AddStudentController.getNewStudentData();
            NES_EvaluateUtil.NewStudentData data = NES_AddStudentController.getNewStudentData();
            Test.stopTest();
        }
    }

    static testMethod void testComponentsByAcademicProgram() {
        //Account accnt = Peak_TestUtils.createTestAccount();
        //List<School_Year__c> schoolYears = Peak_TestUtils.createSchoolYears();
        User portalUser = [SELECT Id FROM User WHERE Username = 'portalUser@gmail.com'];
        Account accnt = [SELECT Id FROM Account WHERE RecordType.Name = 'Educational Institution' LIMIT 1];
        List<School_Year__c> schoolYears = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        //List<NES_Utilities.Question> questions = NES_AddStudentController.getComponentsByAcademicProgram(accnt.Id, schoolYears[0].Id);
        System.runAs(portalUser) {
            Test.startTest();
            List<NES_EvaluateUtil.Question> questions = NES_AddStudentController.getComponentsByAcademicProgram(accnt.Id, schoolYears[0].Id);
            //System.assert(questions.size() > 0);
            Test.stopTest();
        }
    }

    static testMethod void testgetSchoolYears(){
        User portalUser = [SELECT Id FROM User WHERE Username = 'portalUser@gmail.com'];
        Account accnt = [SELECT Id FROM Account WHERE RecordType.Name = 'Educational Institution' LIMIT 1];
        List<School_Year__c> schoolYears = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        System.runAs(portalUser) {
            Test.startTest();
            Peak_Response schoolYearsResponse = NES_AddStudentController.getSchoolYears(schoolYears[0].Id);

            Test.stopTest();
        }
    }

}