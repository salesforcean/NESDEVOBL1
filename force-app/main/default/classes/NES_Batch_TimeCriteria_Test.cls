/**
 * Created by ajith on 05/02/19.
 * purpose : To Test The NES_Batch_TimeCriteria
 */

@isTest 

private class NES_Batch_TimeCriteria_Test {

    @testSetup static void setup(){
    
        Account account = Peak_TestUtils.createEducationalInstitutionAccount();

        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('Test School Year', System.today());

        User  portalUser= Peak_TestUtils.CreatePortalCaretTakerUser();

        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);

        // Create a account with 'Academic Program' record type
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(account.Id, schoolYear.Id);
        academicProgram.Registration_Start_Date__c = System.today().addDays(-10);
        academicProgram.Registration_End_Date__c = System.today().addDays(10);
        update academicProgram;

        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, portalUser.ContactId, schoolYear.Id, false);
        progEnrollment.Status__c = 'In Progress';
        progEnrollment.Initial_ECA_Creation_Complete__c = true;
        insert progEnrollment;


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
        criteria1.Comparison_Data_Type__c = 'Date';
        insert criteria1;
        Criteria__c criteria2 = Peak_TestUtils.createCriteriaRecord('Test Criteria2','hed__Program_Enrollment__c.LTS__c','>=',false);
        criteria2.Comparison_Field__c = 'hed__Program_Enrollment__c.hed__Credits_Earned__c';
        criteria2.Comparison_Data_Type__c = 'Date';
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
        List<Enrollment_Component_Affiliation__c> enrollmentComponentAffiliations = new List<Enrollment_Component_Affiliation__c>();
        Enrollment_Component_Affiliation__c affiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, formComponent.Id, false);
        affiliation.Status__c = 'In Progress';
        Enrollment_Component_Affiliation__c affiliationStage = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, stageComponent.Id, false);
        affiliationStage.Status__c = 'In Progress';
        Enrollment_Component_Affiliation__c affiliationSection = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, sectionComponent.Id, false);
        affiliationSection.Status__c = 'In Progress';
        Enrollment_Component_Affiliation__c affiliationQuestion = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, questionComponent.Id, false);
        affiliationQuestion.Status__c = 'In Progress';
        Enrollment_Component_Affiliation__c affiliationDocument = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, documentComponent.Id, false);
        Enrollment_Component_Affiliation__c affiliationProcess = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, processComponent.Id, false);


        enrollmentComponentAffiliations.add(affiliation);
        enrollmentComponentAffiliations.add(affiliationStage);
        enrollmentComponentAffiliations.add(affiliationSection);
        enrollmentComponentAffiliations.add(affiliationDocument);
        enrollmentComponentAffiliations.add(affiliationProcess);
        enrollmentComponentAffiliations.add(affiliationQuestion);

        insert enrollmentComponentAffiliations;  
    } 

    static testMethod void unitTestPositiveTests(){

        Test.startTest();
        hed__Program_Enrollment__c progEnrollment = [SELECT Id FROM hed__Program_Enrollment__c WHERE Status__c = 'In Progress'];
        List<Enrollment_Component_Affiliation__c> affiliations = [SELECT Id, Status__c, Enrollment_Component__c, Program_Enrollment__c
                                                                        FROM Enrollment_Component_Affiliation__c
                                                                        WHERE Status__c != 'Complete'];
        System.debug('affiliations++++++'+affiliations);

        List<Enrollment_Component_Criteria__c> enrollmentComponentCriteria = new List<Enrollment_Component_Criteria__c>([SELECT Id, Criteria__r.Comparison_Data_Type__c, Enrollment_Component__c FROM Enrollment_Component_Criteria__c]);
        System.debug('enrollmentComponentCriteria++++'+enrollmentComponentCriteria);

        NES_Batch_TimeCriteria obj = new NES_Batch_TimeCriteria();
        DataBase.executeBatch(obj);
        Test.stopTest();
    }


}