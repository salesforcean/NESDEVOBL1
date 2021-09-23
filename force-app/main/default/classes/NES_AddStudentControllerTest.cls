/**
 * Created by ajith on 19/02/19.
 *  2019-11-08 #US116612 Test class added for Suffix picklist(Anitha P)
 */

@isTest
public class NES_AddStudentControllerTest {
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
        //User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'alex.chisholm+ctdemo1@pearson.com.nesspoc1'];
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
    }

    static testMethod void unitTestTwo() {
        User careTaker = [SELECT Id FROM User WHERE Username = 'portalUser@gmail.com'];
        Account institutionalAccount = [SELECT Id FROM Account WHERE RecordType.Name = 'Educational Institution' LIMIT 1];
        Account academicProgram = [SELECT Id, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, Registration_Start_Date__c FROM Account
        WHERE RecordType.Name = 'Academic Program' LIMIT 1];

        System.debug('academicProgram++'+academicProgram);
        List<School_Year__c> schoolYears = [SELECT Id FROM School_Year__c WHERE Name = 'Test School Year'];
        Enrollment_Component__c ec = [SELECT Id FROM Enrollment_Component__c WHERE Assignment_Logic__c != null AND RecordType.Name = 'Form'];

        System.runAs(careTaker) {
            Test.startTest();
            NES_EvaluateUtil.NewStudentData data = NES_AddStudentController.getNewStudentData();
            Peak_Response response = NES_AddStudentController.getSchoolYears(institutionalAccount.Id);
            List<NES_EvaluateUtil.Question> questionsList = NES_AddStudentController.getComponentsByAcademicProgram(institutionalAccount.Id, schoolYears[0].Id);

            NES_EvaluateUtil.NewStudentData newStudentData = new NES_EvaluateUtil.NewStudentData('Royal','Middle','MaverickT','Sr.','Parent', institutionalAccount.Id, '', '',  null, null, null, null);//added for US116612 
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
    }

    static testMethod void unitTestThree() {
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

            NES_EvaluateUtil.NewStudentData newStudentData = new NES_EvaluateUtil.NewStudentData('Royal','Middle','MaverickT','Sr.','Parent', institutionalAccount.Id, '', '',  null, null, null, null);//added for US116612 
            newStudentData.SelectedSchoolYear = academicProgram.School_Year__c;
            String studentJSON = JSON.serialize(newStudentData);
            System.debug('studentJSON++'+studentJSON);

            Enrollment_Component__c qComponent = [SELECT Id FROM Enrollment_Component__c WHERE Assignment_Logic__c != null AND RecordType.Name = 'Question' LIMIT 1];
            List<NES_EvaluateUtil.Question> questionDataList = new List<NES_EvaluateUtil.Question>();
            NES_EvaluateUtil.Question q1 = new NES_EvaluateUtil.Question();
            q1.order = 1;
            q1.componentType = 'Household';
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

            NES_EvaluateUtil.Question q2 = new NES_EvaluateUtil.Question();
            q2.order = 1;
            q2.componentType = 'Household';
            q2.questionGroup = false;
            q2.questionPrompt = 'What is the age of your child?';
            q2.questionTarget = 'Contact.Birthdate__c';
            q2.questionType = 'Date';
            q2.required = true;
            q2.schoolYear = schoolYears[0].Id;
            q2.targetField = 'K';
            q2.componentType = 'false';
            q2.questionId = qComponent.Id;
            questionDataList.add(q2);
            String questionJSON = JSON.serialize(questionDataList);

            Peak_Response studentInsertResponse = NES_AddStudentController.createStudent(studentJSON, questionJSON);
            Test.stopTest();
        }
    }
    //added for US116612
     @IsTest
    static void testPickListRetrieves() {
      // Set mock
        Test.setMock(HttpCalloutMock.class, new mockCalloutForGET());
        Test.startTest();
        List<String> suffixList = NES_AddStudentController.getSuffixValuesIntoList();
		System.assert(suffixList.size()>0);
        Test.stopTest();
    }
  //added for US116612
}