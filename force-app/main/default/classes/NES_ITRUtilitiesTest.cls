@isTest
public class NES_ITRUtilitiesTest {
    
    @TestSetup
    static void setup(){
        //Create Educational Institutional Account i.e.., Parent Account
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        
        //Insert the School Year record
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('Test School Year', System.today());
        
        //Create Academic Program Account i.e.., Child Account
        Id acadamicPgmRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account academicProgramOldYr = new Account(name = 'testAcademicProgram',
                                                   recordTypeId = acadamicPgmRecordTypeId,
                                                   ParentId = institutionAccount.Id,
                                                   School_Year__c = schoolYear.Id,
                                                   Registration_Start_Date__c = System.today().addDays(-10),
                                                   Registration_End_Date__c = System.today().addDays(10),
                                                   Too_Young_Cutoff__c = System.today(), //Added By Anand 1/5/2018
                                                   School_Id__c = 'testAcademicProgram');
        insert academicProgramOldYr;
        
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
        
        Grade_Level__c gradeLevel = Peak_TestUtils.createGradeLevel('1', true);
        Program_Grade_Level__c programGradeLevel = Peak_TestUtils.createProgramGradeLevel('Test',academicProgramOldYr.Id, gradeLevel.Id, System.now(), false);
        programGradeLevel.ActivateWaitlist__c = True;
        programGradeLevel.StartWaitlist__c = System.today();
        programGradeLevel.EndWaitlist__c = System.today();
        insert programGradeLevel;
        
        //Create a enrollment for the CareTaker Contact i.e..,House Hold Enrollment
        Id careTakerEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId();
        hed__Program_Enrollment__c careTakerEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, careTaker.ContactId, schoolYear.Id, false);
        careTakerEnrollment.RecordTypeId = careTakerEnrollmentType;
        insert careTakerEnrollment;
        
        
        // Create a Contact with 'Students' record type
        Contact student = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);
        
        //Create a relationship between the User Contact and Student Contact
        hed__Relationship__c  relationship = Peak_TestUtils.createRelationship(careTaker.ContactId, student.Id, true);
        
        //Create a student enrollment with House Hold Enrollment
        Id studentEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();        
        
        //Create a previous student enrollment with House Hold Enrollment
        hed__Program_Enrollment__c studentOldYrEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgramOldYr.Id, student.Id, schoolYear.Id, false);
        studentOldYrEnrollment.RecordTypeId = studentEnrollmentType;
        studentOldYrEnrollment.Program_Grade_Level__c = programGradeLevel.Id;
        studentOldYrEnrollment.Program_Enrollment__c = careTakerEnrollment.Id;
        insert studentOldYrEnrollment;
        
        Annual_Student_Information__c asRecords = new Annual_Student_Information__c();                
        asRecords.Program_Enrollment__c=studentOldYrEnrollment.id;
        asRecords.School_Year__c=academicProgramOldYr.School_Year__c;
        asRecords.Grade_Level_Requested__c= '1';
        insert asRecords;
        
        
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
        sectionComponent.Assignment_Logic__c = '1';
        sectionComponent.Needed_for_ITR__c = true;
        
        Enrollment_Component__c sectionComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent_With_No_Logic.Assignment_Logic__c = null;
        sectionComponent_With_No_Logic.Needed_for_ITR__c = true;
        
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
        
        
        List<Enrollment_Component_Picklist_Option__c> picklistOptionList = new List<Enrollment_Component_Picklist_Option__c>();
        picklistOptionList.add(Peak_TestUtils.createEnrollmentComponentPicklistOption(questionComponent.Id, false));
        picklistOptionList.add(Peak_TestUtils.createEnrollmentComponentPicklistOption(questionComponent.Id, false));
        insert picklistOptionList;
        
        List<Option_Exclusion__c> optionExclusionList = new List<Option_Exclusion__c>();
        optionExclusionList.add(new Option_Exclusion__c(Academic_Program__c = academicProgram.Id, Option__c = picklistOptionList[0].Id));
        optionExclusionList.add(new Option_Exclusion__c(Academic_Program__c = academicProgram.Id, Option__c = picklistOptionList[0].Id));
        insert optionExclusionList;       
        
    }
    
    public static testMethod void PETest(){
        Id studentEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Id studentContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Students').getRecordTypeId();
        List<Contact> studentRec = [Select Id, FirstName,AccountId, LastName,RecordTypeId from contact where RecordTypeId =:studentContactRT];
        List<Grade_Level__c> grades = [Select Id, Name from Grade_Level__c];
        List<Program_Grade_Level__c> PGLs = [Select Id,Grade_Level__c,Grade_Level__r.Name from  Program_Grade_Level__c];
        List<hed__program_enrollment__c> peList = [Select Id,Start_Year__c,Program_Grade_Level__r.Grade_Level__r.Name,Household_Program_Enrollment__c,Household_Program_Enrollment__r.hed__Contact__c,hed__Account__r.ParentId, hed__Account__c,RecordTypeId, OwnerId from hed__Program_Enrollment__c where RecordTypeId =:studentEnrollmentType];
        test.startTest();
        NES_ITRUtilities.createReturningStudentPE(studentRec[0].Id,peList[0].Id);
        test.stopTest();
        List<hed__Program_Enrollment__c> returningStudentPE  = [Select Id,Program_Grade_Level__r.Grade_Level__r.Name, Enrollment_Type__c, (Select Id from enrollment_component_affiliation__r) from hed__Program_Enrollment__c where Enrollment_Type__c ='Returning Student'];
        system.assertEquals(0, [Select Id from Peak_Apex_Log__c].size());
        system.assertEquals(1, returningStudentPE.size());
        system.assertEquals('Returning Student', returningStudentPE[0].Enrollment_Type__c);
        system.assertEquals(6, returningStudentPE[0].enrollment_component_affiliation__r.size());
    }
    
    public static testMethod void positiveASITest(){
        Id studentEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Id studentContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Students').getRecordTypeId();
        List<Contact> studentRec = [Select Id, FirstName,AccountId, LastName,RecordTypeId from contact where RecordTypeId =:studentContactRT];
        List<hed__program_enrollment__c> peList = [Select Id,Start_Year__c,Program_Grade_Level__c,Program_Grade_Level__r.Grade_Level__r.Name,Household_Program_Enrollment__c,Household_Program_Enrollment__r.hed__Contact__c,hed__Account__r.ParentId, hed__Account__c,RecordTypeId, OwnerId from hed__Program_Enrollment__c where RecordTypeId =:studentEnrollmentType];
        peList[0].Program_Grade_Level__c = null;
        update peList[0];
        List<Annual_Student_Information__c> asiRecs = [Select Id, School_year__c,Program_Enrollment__c, Final_Grade_Level__c from Annual_Student_Information__c where Program_Enrollment__c =: peList[0].Id];
        test.startTest();
        NES_ITRUtilities.createReturningStudentPE(studentRec[0].Id,peList[0].Id);
        test.stopTest();
        system.assertEquals(0, [Select Id from Peak_Apex_Log__c].size());
        List<hed__Program_Enrollment__c> returningStudentPE  = [Select Id,Program_Grade_Level__c,Program_Grade_Level__r.Grade_Level__r.Name, Enrollment_Type__c from hed__Program_Enrollment__c where Enrollment_Type__c ='Returning Student'];
        system.assertEquals(0, [Select Id from Peak_Apex_Log__c].size());
        system.assertEquals('Returning Student', returningStudentPE[0].Enrollment_Type__c);
        system.assertEquals(true, returningStudentPE.size()>0);
    }
    
    
    public static testMethod void ITRResponseTest(){
        Id studentEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Id studentContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Students').getRecordTypeId();
        List<Contact> studentRec = [Select Id, FirstName,AccountId, LastName,RecordTypeId from contact where RecordTypeId =:studentContactRT];
        List<hed__program_enrollment__c> peList = [Select Id,Start_Year__c,Program_Grade_Level__r.Grade_Level__r.Name,Household_Program_Enrollment__c,Household_Program_Enrollment__r.hed__Contact__c,hed__Account__r.ParentId, hed__Account__c,RecordTypeId, OwnerId from hed__Program_Enrollment__c where RecordTypeId =:studentEnrollmentType];
        test.startTest();
        NES_ITRUtilities.ITRResults response= NES_DashboardController.createITRforNextYear(studentRec[0].Id,peList[0].Id);
        test.stopTest();
        system.assertEquals(0, [Select Id from Peak_Apex_Log__c].size());
        system.assertEquals(true, response != null);
    }
}