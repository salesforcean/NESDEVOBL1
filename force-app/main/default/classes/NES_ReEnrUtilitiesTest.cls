@isTest
public class NES_ReEnrUtilitiesTest {
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
        hed__Program_Enrollment__c studentEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, student.Id, schoolYear.Id, true);
        studentEnrollment.RecordTypeId = studentEnrollmentType;
        studentEnrollment.Program_Enrollment__c = careTakerEnrollment.Id;
        studentEnrollment.Household_Program_Enrollment__c=careTakerEnrollment.id;
        update studentEnrollment;
        
        Contact TestContact = Peak_TestUtils.createTestContact();
        
        hed__Program_Enrollment__c ProgramEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, TestContact.Id, schoolYear.Id, true);
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(ProgramEnrollmentTest.id);
        enrollmentDocument1.Type__c = 'Proof of Age';
        enrollmentDocument1.Status_Reason__c = 'Submitted';
        update enrollmentDocument1;
        
        Enrollment__c enrollmentId=Peak_TestUtils.createEnrollmentRecord(studentEnrollment.id,schoolYear.id,true);
        Grade_Level__c gradeLevel2 = Peak_TestUtils.createGradeLevel('1',true);
        
        Program_Grade_Level__c programGradeLevel1 = Peak_TestUtils.createProgramGradeLevel('Test PGL1', academicProgram.Id,gradeLevel2.Id,System.today().addDays(50),true);
        
        // Create a Enrollment Components with different record type
        List<Enrollment_Component__c> componentList = new List <Enrollment_Component__c>();
        Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Process', false);
        processComponent.Completion_Logic__c = 'test';
        processComponent.Assignment_Logic__c = '1';
        processComponent.Needed_for_ITR__c = true;
        
        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);
        stageComponent.Completion_Logic__c = 'test';
        stageComponent.Needed_for_ITR__c = true;
        
        Enrollment_Component__c formComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        formComponent.Needed_for_ITR__c = true;
        formComponent.Assignment_Logic__c = null;
        
        Enrollment_Component__c formComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        formComponent_With_No_Logic.Needed_for_ITR__c = true;
        
        Enrollment_Component__c sectionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent.Assignment_Logic__c = ' ';
        sectionComponent.Needed_for_ITR__c = true;
        
        Enrollment_Component__c sectionComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent_With_No_Logic.Assignment_Logic__c = null;
        sectionComponent_With_No_Logic.Needed_for_ITR__c = true;
        
        //
        Enrollment_Component__c stageComponentss = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Document', false);
        stageComponentss.Assignment_Logic__c = '';
        stageComponentss.Needed_for_ITR__c = true;
        //
        
        Enrollment_Component__c questionGroupComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);
        questionGroupComponent.Needed_for_ITR__c = true;
        
        Enrollment_Component__c questionGroupComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);
        
        Enrollment_Component__c questionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponent.Component_Type__c = 'Household';
        questionComponent.Needed_for_ITR__c = true;
        
        Enrollment_Component__c questionComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponent_With_No_Logic.Component_Type__c = 'Household';
        questionComponent_With_No_Logic.Assignment_Logic__c = null;
        questionComponent_With_No_Logic.Needed_for_ITR__c = true;
        Enrollment_Component__c messageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Message', false);
        
        
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
        componentList.add(stageComponentss);
        
        
        Enrollment_Component__c secComplete = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        //sectionComponent_With_No_Logic.Assignment_Logic__c = null;
        componentList.add(secComplete);
        
        insert componentList;
        
        // create Enrollment Component Relationships with different parent Enrollment Components.
        Enrollment_Component_Relationship__c process_stage_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponent.Id, processComponent.Id);
        
        Enrollment_Component_Relationship__c stage_form_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(formComponent.Id, stageComponent.Id);
        Enrollment_Component_Relationship__c stage_form_with_no_logic_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(formComponent_With_No_Logic.Id, stageComponent.Id);
        stage_form_with_no_logic_ECR.Order__c = 2;
        update stage_form_with_no_logic_ECR;
        
        Enrollment_Component_Relationship__c form_section_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(sectionComponent.Id, formComponent.Id);
        Enrollment_Component_Relationship__c form_section_with_no_logic_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(sectionComponent_With_No_Logic.Id, formComponent_With_No_Logic.Id);
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
        
        List<Enrollment_Component_Criteria__c> EnrollmentCompCriteriaList = new List<Enrollment_Component_Criteria__c>();
        
        Enrollment_Component_Criteria__c EnrollmentCompCriteria1= Peak_TestUtils.createEnrollCompCriteria('EnrollmentCompCriteria1', String.valueOf(processComponent.Id),false);
        Enrollment_Component_Criteria__c EnrollmentCompCriteria2= Peak_TestUtils.createEnrollCompCriteria('EnrollmentCompCriteria2', String.valueOf(stageComponent.Id),false);
        Enrollment_Component_Criteria__c EnrollmentCompCriteria3= Peak_TestUtils.createEnrollCompCriteria('EnrollmentCompCriteria3', String.valueOf(formComponent.Id),false);
        Enrollment_Component_Criteria__c EnrollmentCompCriteria4= Peak_TestUtils.createEnrollCompCriteria('EnrollmentCompCriteria4', String.valueOf(sectionComponent.Id),false);
        Enrollment_Component_Criteria__c EnrollmentCompCriteria5= Peak_TestUtils.createEnrollCompCriteria('EnrollmentCompCriteria5', String.valueOf(processComponent.Id),false);
        
        EnrollmentCompCriteriaList.add(EnrollmentCompCriteria1);
        EnrollmentCompCriteriaList.add(EnrollmentCompCriteria2);
        EnrollmentCompCriteriaList.add(EnrollmentCompCriteria3);
        EnrollmentCompCriteriaList.add(EnrollmentCompCriteria4);
        EnrollmentCompCriteriaList.add(EnrollmentCompCriteria5);
        
        insert EnrollmentCompCriteriaList;
        
        // create Enrollment Component Affiliations with different parent Enrollment Components.
        List<Enrollment_Component_Affiliation__c> enrollmentComponentAffiliations = new List<Enrollment_Component_Affiliation__c>();
        Enrollment_Component_Affiliation__c affiliationStage = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, stageComponent.Id, false);
        affiliationStage.Status__c = 'In Progress';
        enrollmentComponentAffiliations.add(affiliationStage);
        
        Enrollment_Component_Affiliation__c affiliationStage2 = Peak_TestUtils.createEnrollmentComponentAffiliation(careTakerEnrollment.Id, processComponent.Id, false);
        affiliationStage2.Status__c = 'Not Started';
        enrollmentComponentAffiliations.add(affiliationStage2);
        
        Enrollment_Component_Affiliation__c affiliationDocument = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, stageComponentss.Id, false);
        affiliationDocument.Status__c = 'In Progress';
        enrollmentComponentAffiliations.add(affiliationDocument);
        
        insert enrollmentComponentAffiliations;
        // Create Enrollment Documents
        Enrollment_Document__c enrollmentDocument2 = Peak_TestUtils.createEnrollmentDocumentRecord(ProgramEnrollmentTest.id);
        enrollmentDocument2.Type__c = 'Immunization Records';
        enrollmentDocument2.Enrollment_Component_Affiliation__c = affiliationStage.Id;
        update enrollmentDocument2;
        // 
        
    } 
    static testMethod void pesTest(){
        //User careTaker = [SELECT Id, ContactId FROM User WHERE Username = 'portalUser@gmail.com'];
        Contact studentid=[select id,Birthdate__c from Contact where LastName ='TestCon' AND RecordType.name = 'Students' limit 1];
        
        Account institutionalAccount = [SELECT Id FROM Account WHERE RecordType.Name = 'Educational Institution' LIMIT 1];
        Account academicProgram = [SELECT Id,name, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, Registration_Start_Date__c FROM Account WHERE RecordType.Name = 'Academic Program' LIMIT 1];
        
        hed__Program_Enrollment__c stdPE=[select id,Enrollment_Type__c,Household_Program_Enrollment__c from hed__Program_Enrollment__c WHERE RecordType.Name = 'Student' limit 1];
        
        Enrollment_Component_Affiliation__c ecaList=[SELECT Id,Enrollment_Component__c,Status__c,Order__c,Enrollment_Component__r.RecordType.Name, Name,Program_Enrollment__c,Program_Enrollment__r.Enrollment_Type__c FROM Enrollment_Component_Affiliation__c WHERE Program_Enrollment__c =: stdPE.id AND Enrollment_Component__r.RecordType.Name ='Document' Limit 1];
        ecaList.Status__c='Complete';
        update ecaList;
        
        Test.startTest();
        NES_ReEnrUtilities.ReEnrResults response = NES_EnrollmentController.doReEnrollment(studentid.id,stdPE.id);
        Test.stopTest();
        system.assertEquals(true,response.success);
        system.assertEquals(0, [Select Id from Peak_Apex_Log__c].size());
        
    }
    static testMethod void ecasTest(){
        Account institutionalAccount = [SELECT Id FROM Account WHERE RecordType.Name = 'Educational Institution' LIMIT 1];
        Account academicProgram = [SELECT Id,name, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, Registration_Start_Date__c FROM Account WHERE RecordType.Name = 'Academic Program' LIMIT 1];
        Id studentEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Id studentContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Students').getRecordTypeId();
        List<Contact> studentRec = [Select Id, FirstName,AccountId, LastName,RecordTypeId from contact where RecordTypeId =:studentContactRT];
        
        hed__program_enrollment__c studentPe = [Select Id,Enrollment_Type__c,Household_Program_Enrollment__c,Household_Program_Enrollment__r.hed__Contact__c,hed__Account__r.ParentId, hed__Account__c,RecordTypeId from hed__Program_Enrollment__c where RecordTypeId =:studentEnrollmentType Limit 1];
        studentPe.Enrollment_Type__c='Returning Student';
        update studentPe;
        hed__Program_Enrollment__c caretakerEnrollment = [SELECT Id, hed__Contact__c FROM hed__Program_Enrollment__c where id=:studentPe.Household_Program_Enrollment__c Limit 1];
        List<Enrollment_Component__c> processComponent = [SELECT Id, Assignment_Logic__c FROM Enrollment_Component__c WHERE Process_Academic_Program__c = :academicProgram.id AND RecordType.Name = :NES_DashboardUtilities.PROCESS_RT Limit 1];
        
        Test.startTest();
        NES_ReEnrUtilities.PerformAsyncNewStudentSteps(studentPe.Id,processComponent[0].Id,caretakerEnrollment.Id);
        Test.stopTest(); 
        system.assertEquals(0, [Select Id from Peak_Apex_Log__c].size());
    }
    static testMethod void reactivateEnrollmentTypeTest(){
        Id studentEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        hed__program_enrollment__c studentPe = [Select Id,Enrollment_Type__c,Household_Program_Enrollment__c,Household_Program_Enrollment__r.hed__Contact__c,hed__Account__r.ParentId, hed__Account__c,RecordTypeId from hed__Program_Enrollment__c where RecordTypeId =:studentEnrollmentType Limit 1];
        studentPe.Enrollment_Type__c='Returning Student';
        studentPe.Status__c='Inactive';
        update studentPe;
        
        Test.startTest();
        String result = NES_EnrollmentController.getPEEnrStatus(studentPe.id);
        Test.stopTest();
        system.assertEquals('ReActivation',result);
        system.assertEquals(0, [Select Id from Peak_Apex_Log__c].size());
    }
    static testMethod void reEnrollmentTypeTest(){
        Id studentEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        
        hed__program_enrollment__c studentPe = [Select Id,Enrollment_Type__c,Household_Program_Enrollment__c,Household_Program_Enrollment__r.hed__Contact__c,hed__Account__r.ParentId, hed__Account__c,RecordTypeId from hed__Program_Enrollment__c where RecordTypeId =:studentEnrollmentType Limit 1];
        studentPe.Status__c='Withdrawn';
        update studentPe;
        
        Enrollment__c enrollmentId=[SELECT Id,Program_Enrollment__c,Withdrawal_Category__c FROM Enrollment__c where Program_Enrollment__c =: studentPe.id Limit 1];    
        enrollmentId.Withdrawal_Category__c='No Show';
        update enrollmentId;
        Test.startTest();
        String result = NES_EnrollmentController.getPEEnrStatus(studentPe.id);
        Test.stopTest();
        system.assertEquals('ReEnrollment',result);
        system.assertEquals(0, [Select Id from Peak_Apex_Log__c].size());
    }
}