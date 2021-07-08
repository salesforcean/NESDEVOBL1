/**
 * Created by Mark Membrino on 8/21/2020 To test the rewrite of the ECA assignment and completion logic.
 *  2019-11-08 #US116612 Test class added for Suffix picklist(Anitha P)
 */

@isTest
public class NewECAProcessTest1 {
    @TestSetup
    static void setup(){

        Peak_TestUtils.createNESBusinessLogicSwitch('Entrance Age Eligibility Override', true);
        Peak_TestUtils.createNESBusinessLogicSwitch('ProgramEnrollmentTrigger', true);
        Peak_TestUtils.createNESBusinessLogicSwitch('High School LTS Score', true); 
        Peak_TestUtils.createNESBusinessLogicSwitch('Likelihood to Transition Score', true);
        Peak_TestUtils.createNESBusinessLogicSwitch('Why Flagged', true);

        //Create Educational Institutional Account i.e.., Parent Account
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();

        //Insert the School Year record
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('Test School Year', System.today());

        //Create Academic Program Account i.e.., Child Account
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, schoolYear.Id);
        academicProgram.Registration_Start_Date__c = System.today().addDays(-10);
        academicProgram.Registration_End_Date__c = System.today().addDays(10);
        academicProgram.Use_Updated_ECA_Process__c = true;
        update academicProgram;

        // Create a Contact with 'Caretaker' record type
        Contact careTakerContact = Peak_TestUtils.createTestContact('Caretaker', institutionAccount.Id);

        //Create a care taker user for community
        User careTaker = Peak_TestUtils.CreatePortalCaretTakerUser(careTakerContact.Id);

        // Create a Contact with 'Students' record type
        Contact student = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);

        // Create a Enrollment Components with different record type
        List<Enrollment_Component__c> componentList = new List <Enrollment_Component__c>();
        Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Process', false);
        processComponent.Assignment_Logic__c = '1';

        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);

        Enrollment_Component__c formComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        formComponent.Assignment_Logic__c = '1';
        formComponent.Completion_Logic__c = '2';

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


        Criteria__c assignmentGiftedCriteria = Peak_TestUtils.createCriteriaRecord(null, 'hed__Program_Enrollment__c.SIF_Gifted_Initial_Interest__c', '=', false);
        assignmentGiftedCriteria.Comparison_Data_Type__c = 'Text';
        assignmentGiftedCriteria.Comparison_Value__c = 'Yes';
        insert assignmentGiftedCriteria;

        Criteria__c completionCriteria = Peak_TestUtils.createCriteriaRecord(null, 'hed__Program_Enrollment__c.DisciplinaryFlagOverride__c', '=', false);
        completionCriteria.Comparison_Data_Type__c = 'Text';
        completionCriteria.Comparison_Value__c = 'Released';
        insert completionCriteria;

        Enrollment_Component_Criteria__c studentEnrollmentComponentCriteria = Peak_TestUtils.createEnrollCompCriteria(null, formComponent.Id, false);
        studentEnrollmentComponentCriteria.Criteria__c = assignmentGiftedCriteria.Id;
        studentEnrollmentComponentCriteria.Student_or_Household__c = 'Student';
        studentEnrollmentComponentCriteria.Criteria_Number__c = 1;
        insert studentEnrollmentComponentCriteria;

        Enrollment_Component_Criteria__c studentEnrollmentComponentCriteria2 = Peak_TestUtils.createEnrollCompCriteria(null, formComponent.Id, false);
        studentEnrollmentComponentCriteria2.Criteria__c = completionCriteria.Id;
        studentEnrollmentComponentCriteria2.Student_or_Household__c = 'Student';
        studentEnrollmentComponentCriteria2.Criteria_Number__c = 2;
        insert studentEnrollmentComponentCriteria2;

    }

    //added for US116612
     private class mockCalloutForGET implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            String body = 'test body';
            res.setBody(body);
            return res; 
        }
    }
    //added for US116612
    
    static testMethod void unitTestOne() {
        User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'portalUser@gmail.com'];	
        Account institutionalAccount = [SELECT Id FROM Account WHERE RecordType.Name = 'Educational Institution' LIMIT 1];
        Account academicProgram = [SELECT Id, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, Registration_Start_Date__c FROM Account
                                          WHERE RecordType.Name = 'Academic Program' LIMIT 1];

        System.debug('academicProgram++'+academicProgram);
        List<School_Year__c> schoolYears = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year' LIMIT 1];

        //Create a student enrollment for the CareTaker Contact
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, careTaker.ContactId, schoolYears[0].Id, true);

        System.runAs(careTaker) {
            Test.startTest();
            NES_EvaluateUtil.NewStudentData data = NES_AddStudentController.getNewStudentData();
            Peak_Response response = NES_AddStudentController.getSchoolYears(institutionalAccount.Id);
            List<NES_EvaluateUtil.Question> questionsList = NES_AddStudentController.getComponentsByAcademicProgram(institutionalAccount.Id, schoolYears[0].Id);

            NES_EvaluateUtil.NewStudentData newStudentData = new NES_EvaluateUtil.NewStudentData('Royal','Middle', 'MaverickT','Sr.','Parent', institutionalAccount.Id, '', '',  null, null, null, null); //added for US116612 
            newStudentData.SelectedSchoolYear = academicProgram.School_Year__c;
            String studentJSON = JSON.serialize(newStudentData);
            System.debug('studentJSON++'+studentJSON);

            Enrollment_Component__c qComponent = [SELECT Id FROM Enrollment_Component__c WHERE Assignment_Logic__c != null AND RecordType.Name = 'Question' LIMIT 1];
            List<NES_EvaluateUtil.Question> questionDataList = new List<NES_EvaluateUtil.Question>();
            NES_EvaluateUtil.Question q1 = new NES_EvaluateUtil.Question();
            q1.order = 1;
            q1.componentType = 'Student';
            q1.questionGroup = false;
            q1.questionPrompt = 'What grade is the student going into?';
            q1.questionTarget = 'hed__Program_Enrollment__c.Final_Grade_Level__c';
            q1.questionType = 'Picklist';
            q1.required = true;
            q1.schoolYear = schoolYears[0].Id;
            q1.targetField = 'K';
            q1.componentType = 'false';
            q1.questionId = qComponent.Id;
            questionDataList.add(q1);
            String questionJSON = JSON.serialize(questionDataList);

            Peak_Response studentInsertResponse = NES_AddStudentController.createStudent(studentJSON, questionJSON);
            Test.stopTest();
        }


        List<Enrollment_Component_Affiliation__c> FormECAWithAssgnmentCriteria = new List<Enrollment_Component_Affiliation__c> ([select Id, status__c, Program_Enrollment__c from Enrollment_Component_Affiliation__c where EC_Record_Type__c = 'Form' and Enrollment_Component__r.Assignment_Logic__c <> null ]);
        System.assertEquals('Not Applicable', FormECAWithAssgnmentCriteria[0].status__c);

        //Update a field that is part of a criteria on all the PEs that have been created.
        List<hed__Program_Enrollment__c> allPEs = new List<hed__Program_Enrollment__c>([select id, SIF_Gifted_Initial_Interest__c from hed__Program_Enrollment__c]);
        for (hed__Program_Enrollment__c pe : allPEs) {
           pe.SIF_Gifted_Initial_Interest__c = 'Yes';
        }
        update allPEs;

        FormECAWithAssgnmentCriteria = new List<Enrollment_Component_Affiliation__c> ([select Id, status__c from Enrollment_Component_Affiliation__c where EC_Record_Type__c = 'Form' and Enrollment_Component__r.Assignment_Logic__c <> null ]);

        //System.assertEquals('Not Started', FormECAWithAssgnmentCriteria[0].status__c);

        List<Enrollment_Component_Affiliation__c> stageECAs = new List<Enrollment_Component_Affiliation__c> ([select Id, status__c from Enrollment_Component_Affiliation__c where EC_Record_Type__c = 'Stage' ]);
        //System.assertEquals('In Progress', stageECAs[0].status__c);

        //Now update the completion criteria
        for (hed__Program_Enrollment__c pe : allPEs) {
           pe.DisciplinaryFlagOverride__c = 'Released';
        }
        update allPEs;

        FormECAWithAssgnmentCriteria = new List<Enrollment_Component_Affiliation__c> ([select Id, status__c from Enrollment_Component_Affiliation__c where EC_Record_Type__c = 'Form' and Enrollment_Component__r.Assignment_Logic__c <> null ]);

        //System.assertEquals('Not Started', FormECAWithAssgnmentCriteria[0].status__c);

        stageECAs = new List<Enrollment_Component_Affiliation__c> ([select Id, status__c from Enrollment_Component_Affiliation__c where EC_Record_Type__c = 'Stage' ]);
        //System.assertEquals('In Progress', stageECAs[0].status__c);
    }
}