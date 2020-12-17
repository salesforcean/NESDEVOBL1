/**
 * Created by Maddileti for US #335371 on 12/04/2020
 */
@istest
public class NES_ReactivateSYTest {
    
    @TestSetup
    static void setup(){
        
        //Create Educational Institutional Account i.e.., Parent Account
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        
        //Insert the School Year record
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('Test School', System.today());
        
        //Create Academic Program Account i.e.., Child Account
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, schoolYear.Id);
        academicProgram.Registration_Start_Date__c = System.today().addDays(-10);
        academicProgram.Registration_End_Date__c = System.today().addDays(10);
        academicProgram.MaxSpecialEdBirthdate__c = Date.today().addMonths(-2);
        update academicProgram;
        
        // Create a Contact with 'Caretaker' record type
        Contact careTakerContact = Peak_TestUtils.createTestContact('Caretaker', institutionAccount.Id);
        
        //Create a care taker user for community
        User careTaker = Peak_TestUtils.CreatePortalCaretTakerUser(careTakerContact.Id);
        
        
        //Create a enrollment for the CareTaker Contact i.e..,House Hold Enrollment
        Id careTakerEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId();
        hed__Program_Enrollment__c careTakerEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, careTaker.ContactId, schoolYear.Id, false);
        careTakerEnrollment.RecordTypeId = careTakerEnrollmentType;
        insert careTakerEnrollment;
        
        Id studentRecordTypeId =Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Students').getRecordTypeId();
        // Create a Contact with 'Students' record type
        Contact student = Peak_TestUtils.createTestContact();
        student.LastName='TestCon';
        student.Phone='8143098909';
        student.Birthdate__c=Date.newInstance(2014, 2, 17);
        student.AccountId=institutionAccount.Id;  
        student.RecordTypeId=studentRecordTypeId;
        update student;
        
        
        //Create a relationship between the User Contact and Student Contact
        hed__Relationship__c  relationship = Peak_TestUtils.createRelationship(careTaker.ContactId, student.Id, true);
        
        //Create a student enrollment
        Id studentEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        hed__Program_Enrollment__c studentEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, student.Id, schoolYear.Id, false);
        studentEnrollment.RecordTypeId = studentEnrollmentType;
        studentEnrollment.Program_Enrollment__c = careTakerEnrollment.Id;
        insert studentEnrollment;
        
        Grade_Level__c gradeLevel2 = Peak_TestUtils.createGradeLevel('1',true);
        
        Program_Grade_Level__c programGradeLevel1 = Peak_TestUtils.createProgramGradeLevel('Test PGL1', academicProgram.Id,gradeLevel2.Id,System.today().addDays(50),true);
        
        //
        
        // Create a Enrollment Components with different record type
        List<Enrollment_Component__c> componentList = new List <Enrollment_Component__c>();
        Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Process', false);
        processComponent.Completion_Logic__c = 'test';
        //processComponent.Assignment_Logic__c = '1';
        
        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);
        stageComponent.Completion_Logic__c = 'test';
        stageComponent.Assignment_Logic__c = '1';
        
        Enrollment_Component__c formComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        formComponent.Assignment_Logic__c = '1';
        
        Enrollment_Component__c formComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        formComponent_With_No_Logic.Assignment_Logic__c = null;
        
        Enrollment_Component__c sectionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent.Assignment_Logic__c = '1';
        
        Enrollment_Component__c sectionComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent_With_No_Logic.Assignment_Logic__c = '1';
        
        Enrollment_Component__c questionGroupComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);
        questionGroupComponent.Assignment_Logic__c = '1';
        
        Enrollment_Component__c questionGroupComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);
        questionGroupComponent_With_No_Logic.Assignment_Logic__c = '1';
        
        Enrollment_Component__c questionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponent.Component_Type__c = 'Household';
        questionComponent.Assignment_Logic__c = '1';
        
        Enrollment_Component__c questionComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponent_With_No_Logic.Component_Type__c = 'Household';
        questionComponent_With_No_Logic.Assignment_Logic__c = '1';
        Enrollment_Component__c messageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Message', false);
        //added
        Enrollment_Component__c stageComponent1 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);
        stageComponent.name = 'Waitlist';
        //added
        
        Enrollment_Component__c processComponentNew = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Process', false);        
        Enrollment_Component__c stageComponentNew = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);
        Enrollment_Component__c formComponentNew = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);        
        Enrollment_Component__c sectionComponentNew = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);        
        Enrollment_Component__c questionGroupComponentNew = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);        
        Enrollment_Component__c questionComponentNew = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        Enrollment_Component__c messageComponentNew = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Message', false);
        
        componentList.add(messageComponent);
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
        componentList.add(stageComponent1);//added
        
        
        //Second version of stage records
        componentList.add(processComponentNew);
        componentList.add(stageComponentNew);//added
        componentList.add(formComponentNew);//added
        componentList.add(sectionComponentNew);//added
        componentList.add(questionGroupComponentNew);//added
        componentList.add(questionComponentNew);//added
        componentList.add(messageComponentNew);//added
        
        
        
        
        Enrollment_Component__c secComplete = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent_With_No_Logic.Assignment_Logic__c = null;
        componentList.add(secComplete);
        
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
        
        Enrollment_Component_Relationship__c section_questionGroup_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(questionGroupComponent.Id,sectionComponent.Id);
        section_questionGroup_ECR.Order__c = 3;
        update section_questionGroup_ECR;
        
        Enrollment_Component_Relationship__c section_questionGroup_with_no_logic_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(questionGroupComponent_With_No_Logic.Id,sectionComponent_With_No_Logic.Id);
        section_questionGroup_with_no_logic_ECR.Order__c = 4;
        update section_questionGroup_with_no_logic_ECR;
        
        Enrollment_Component_Relationship__c messageRelationShip = Peak_TestUtils.createEnrollmentComponentRelationship(questionGroupComponent.Id,messageComponent.Id); 
        
        //Second Version of Enrollment component Relationship records
        Enrollment_Component_Relationship__c process_stage_ECRNew = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponentNew.Id, processComponentNew.Id);
        Enrollment_Component_Relationship__c stage_form_ECRNew = Peak_TestUtils.createEnrollmentComponentRelationship(formComponentNew.Id, stageComponentNew.Id);
        Enrollment_Component_Relationship__c form_section_ECRNew = Peak_TestUtils.createEnrollmentComponentRelationship(sectionComponentNew.Id, formComponentNew.Id);
        Enrollment_Component_Relationship__c section_question_ECRNew = Peak_TestUtils.createEnrollmentComponentRelationship(questionGroupComponentNew.Id, sectionComponentNew.Id);
        Enrollment_Component_Relationship__c questionGroup_question_ECRNew = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponentNew.Id,questionGroupComponentNew.Id);
        Enrollment_Component_Relationship__c messageRelationShipNew = Peak_TestUtils.createEnrollmentComponentRelationship(questionGroupComponentNew.Id,messageComponentNew.Id);
        
        
        
        // create Enrollment Component Affiliations with different parent Enrollment Components.
        List<Enrollment_Component_Affiliation__c> enrollmentComponentAffiliations = new List<Enrollment_Component_Affiliation__c>();
        Enrollment_Component_Affiliation__c sectionAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, sectionComponent.Id, false);
        enrollmentComponentAffiliations.add(sectionAffiliation);
        Enrollment_Component_Affiliation__c questionAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, questionComponent.Id, false);
        enrollmentComponentAffiliations.add(questionAffiliation);
        Enrollment_Component_Affiliation__c questionGrpAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, questionGroupComponent_With_No_Logic.Id, false);
        enrollmentComponentAffiliations.add(questionGrpAffiliation);
        Enrollment_Component_Affiliation__c completedSecAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, secComplete.Id, false);
        enrollmentComponentAffiliations.add(completedSecAffiliation);
        Enrollment_Component_Affiliation__c formSecAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, formComponent.Id, false);
        enrollmentComponentAffiliations.add(formSecAffiliation);
        Enrollment_Component_Affiliation__c stageAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, stageComponent.Id, false);
        enrollmentComponentAffiliations.add(stageAffiliation);
        Enrollment_Component_Affiliation__c processAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, processComponent.Id, false);
        enrollmentComponentAffiliations.add(processAffiliation);
        Enrollment_Component_Affiliation__c messageAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, messageComponent.Id, false);
        enrollmentComponentAffiliations.add(messageAffiliation);
        
        insert enrollmentComponentAffiliations;
        
        
    }
    static testMethod void unitTesting() {
        
        User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'portalUser@gmail.com'];
        Contact studentid=[select id,Birthdate__c from Contact where LastName ='TestCon' AND RecordType.name = 'Students' limit 1];
        Account institutionalAccount = [SELECT Id FROM Account WHERE RecordType.Name = 'Educational Institution' LIMIT 1];
        Account academicProgram = [SELECT Id,name, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, Registration_Start_Date__c FROM Account WHERE RecordType.Name = 'Academic Program' LIMIT 1];
        
        Grade_Level__c gradeLevel=[select id,name from Grade_Level__c where name ='1' limit 1];
        List<School_Year__c> schoolYears = [Select id,name FROM School_Year__c WHERE Name ='Test School' LIMIT 1];
        hed__Program_Enrollment__c stdPE=[select id from hed__Program_Enrollment__c WHERE RecordType.Name = 'Student' limit 1];
        boolean flag=true;
        String callType='community';
        System.runAs(careTaker) { 
            Test.startTest();
            Peak_Response studentInsertResponse = NES_EnrollmentController.nextYearEnrollment(studentid.Id,academicProgram.Name,schoolYears[0].name,gradeLevel.Name, callType,flag,stdPE.id);
            Test.stopTest();
        }
    }
    
}