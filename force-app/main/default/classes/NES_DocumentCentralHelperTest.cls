/****
 * 
    @author: Ali KM (Ness Tech)
    * Created this test class on 03/19/2020 for [US 149116]
    * Test coverage for 
        => NES_DocumentCentralHelper.getDocumentsListByUser()
*/

@isTest(SeeAllData=false isParallel=true)
public with sharing class NES_DocumentCentralHelperTest {
    
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
        academicProgram.Document_End_Date__c=System.now()+10;
        academicProgram.Document_Start_Date__c=System.now()-10;
        update academicProgram;
        
        // Create a Contact with 'Caretaker' record type
        Contact careTakerContact = Peak_TestUtils.createTestContact('Caretaker', institutionAccount.Id);
        
        //Create a care taker user for community
        User careTaker = Peak_TestUtils.CreatePortalCaretTakerUser(careTakerContact.Id);
        
        // Program Grade Level
        Grade_Level__c levels=new Grade_Level__c();
        levels.Name='Test User';
        insert levels;
        Program_Grade_Level__c programLevels=new Program_Grade_Level__c();
        programLevels.Academic_Program__c=academicProgram.Id;
        programLevels.Grade_Level__c=levels.Id;
        programLevels.Document_Submission_End_Date__c=System.now()+10;
        programLevels.Document_Submission_Start_Date__c=System.now()-10;
        insert programLevels;
        
        //Create a enrollment for the CareTaker Contact i.e..,House Hold Enrollment
        Id careTakerEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId();
        hed__Program_Enrollment__c careTakerEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, careTaker.ContactId, schoolYear.Id, false);
        careTakerEnrollment.RecordTypeId = careTakerEnrollmentType;
        careTakerEnrollment.Program_Grade_Level__c=programLevels.Id;
        insert careTakerEnrollment;
        
        // Create a Contact with 'Students' record type
        Contact student = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);
        
        //Create a relationship between the User Contact and Student Contact
        hed__Relationship__c  relationship = Peak_TestUtils.createRelationship(careTaker.ContactId, student.Id, true);
        
        //Create a student enrollment with House Hold Enrollment
        Id studentEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        hed__Program_Enrollment__c studentEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, student.Id, schoolYear.Id, false);
        studentEnrollment.RecordTypeId = studentEnrollmentType;
        studentEnrollment.Household_Program_Enrollment__c = careTakerEnrollment.Id;
        studentEnrollment.Program_Enrollment__c = careTakerEnrollment.Id;
        studentEnrollment.hed__Account__c  = academicProgram.Id;
        studentEnrollment.Program_Grade_Level__c=programLevels.Id;
        // studentEnrollment.hed__Contact__c  = student.Id;
        insert studentEnrollment;
        
        // Create a Enrollment Components with different record type
        List<Enrollment_Component__c> componentList = new List <Enrollment_Component__c>();
        Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Process', false);
        processComponent.Completion_Logic__c = 'test';
        processComponent.Assignment_Logic__c = '1';
        processComponent.Process_Academic_Program__c = academicProgram.Id;
        
        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);
        stageComponent.Name = 'tell me something about yourself!';
        
        Enrollment_Component__c formComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        formComponent.Completion_Logic__c = '1';
        // formComponent.Assignment_Logic__c = '1';
        
        Enrollment_Component__c formComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        formComponent_With_No_Logic.Completion_Logic__c = null;
        
        Enrollment_Component__c sectionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent.Completion_Logic__c = '1';
        //Start- Added code for #108693 User Story (Task 109667)
        //Create a Document  
        Enrollment_Component__c DocumentComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Document', false);
        DocumentComponent.is_Required__c = false;
        DocumentComponent.name ='Document';

        Enrollment_Component__c DocumentComponentNotStarted1 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Document', false);
        DocumentComponentNotStarted1.is_Required__c = true;
        DocumentComponentNotStarted1.name ='Doc_NotStarted1';

        Enrollment_Component__c DocumentComponentNotStarted2 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Document', false);
        DocumentComponentNotStarted2.is_Required__c = false;
        DocumentComponentNotStarted2.name ='Doc_NotStarted2';

        Enrollment_Component__c DocumentComponentNotStarted3 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Document', false);
        DocumentComponentNotStarted3.is_Required__c = false;
        DocumentComponentNotStarted3.name ='Doc_NotStarted3';

        //End- Added code for #108693 User Story (Task 109667) 
        Enrollment_Component__c sectionComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent_With_No_Logic.Completion_Logic__c = null;
        
        Enrollment_Component__c questionGroupComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);
        questionGroupComponent.Completion_Logic__c = '1';
        
        Enrollment_Component__c questionGroupComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);
        questionGroupComponent_With_No_Logic.Completion_Logic__c = null;
        
        Enrollment_Component__c questionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponent.Component_Type__c = 'Household';
        questionComponent.Completion_Logic__c = '1';
        
        Enrollment_Component__c questionComponent_With_No_Logic = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponent_With_No_Logic.Component_Type__c = 'Household';
        questionComponent_With_No_Logic.Completion_Logic__c = null;
        Enrollment_Component__c messageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Message', false);
        
        componentList.add(processComponent);
        componentList.add(DocumentComponent);
        componentList.add(DocumentComponentNotStarted1);
        componentList.add(DocumentComponentNotStarted2);
        componentList.add(DocumentComponentNotStarted3); 
        componentList.add(messageComponent);
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
        sectionComponent_With_No_Logic.Completion_Logic__c = null;
        componentList.add(secComplete);
        
        insert componentList;
        
        // create Enrollment Component Relationships with different parent Enrollment Components.
        Enrollment_Component_Relationship__c process_stage_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponent.Id, processComponent.Id);
        system.debug(stageComponent.Id);
        system.debug('pp'+processComponent.Id);
        Enrollment_Component_Relationship__c stage_form_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(formComponent.Id, stageComponent.Id);
        Enrollment_Component_Relationship__c stage_form_with_no_logic_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(formComponent_With_No_Logic.Id, stageComponent.Id);
        stage_form_with_no_logic_ECR.Order__c = 2;
        update stage_form_with_no_logic_ECR;
        
        Enrollment_Component_Relationship__c form_section_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(sectionComponent.Id, formComponent.Id);
        Enrollment_Component_Relationship__c form_section_with_no_logic_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(sectionComponent_With_No_Logic.Id, formComponent.Id);
        form_section_with_no_logic_ECR.Order__c = 2;
        update form_section_with_no_logic_ECR;

        // ALI 
        Enrollment_Component_Relationship__c form_doc_with_no_logic_ECR = Peak_TestUtils.createEnrollmentComponentRelationship(DocumentComponentNotStarted1.Id, formComponent.Id);
        form_doc_with_no_logic_ECR.Order__c = 3;
        update form_doc_with_no_logic_ECR;
        Enrollment_Component_Relationship__c form_doc_with_no_logic_ECR2 = Peak_TestUtils.createEnrollmentComponentRelationship(DocumentComponentNotStarted2.Id, formComponent.Id);
        form_doc_with_no_logic_ECR2.Order__c = 4;
        update form_doc_with_no_logic_ECR2;
        // ALI END
        
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
        
        
        // create Enrollment Component Affiliations with different parent Enrollment Components.
        List<Enrollment_Component_Affiliation__c> enrollmentComponentAffiliations = new List<Enrollment_Component_Affiliation__c>();
        Enrollment_Component_Affiliation__c sectionAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, sectionComponent.Id, false);
        sectionAffiliation.Status__c = 'In Progress';
        enrollmentComponentAffiliations.add(sectionAffiliation);
        
        //Start- Added code for #108693 User Story (Task 109667) 
        //Create ECA for the Document
        Enrollment_Component_Affiliation__c documentAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, DocumentComponent.Id, false);
        documentAffiliation.Status__c = 'Complete';
        enrollmentComponentAffiliations.add(documentAffiliation);
        //End- Added code for #108693 User Story (Task 109667)     

        // ALI 
        Enrollment_Component_Affiliation__c documentAffiliationNotStarted1 = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, DocumentComponentNotStarted1.Id, false);
        documentAffiliationNotStarted1.Status__c = 'Not Started';
        enrollmentComponentAffiliations.add(documentAffiliationNotStarted1);

        Enrollment_Component_Affiliation__c documentAffiliationNotStarted2 = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, DocumentComponentNotStarted2.Id, false);
        documentAffiliationNotStarted2.Status__c = 'Not Started';
        enrollmentComponentAffiliations.add(documentAffiliationNotStarted2);
        
        Enrollment_Component_Affiliation__c questionAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, questionComponent.Id, false);
        enrollmentComponentAffiliations.add(questionAffiliation);
        Enrollment_Component_Affiliation__c questionGrpAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, questionGroupComponent_With_No_Logic.Id, false);
        enrollmentComponentAffiliations.add(questionGrpAffiliation);
        Enrollment_Component_Affiliation__c completedSecAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, secComplete.Id, false);
        enrollmentComponentAffiliations.add(completedSecAffiliation);
        Enrollment_Component_Affiliation__c formSecAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, formComponent.Id, false);
        enrollmentComponentAffiliations.add(formSecAffiliation);
        Enrollment_Component_Affiliation__c stageAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, stageComponent.Id, false);
        stageAffiliation.Status__c = 'In Progress';
        stageAffiliation.Order__c = 0;
        enrollmentComponentAffiliations.add(stageAffiliation);
        Enrollment_Component_Affiliation__c processAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, processComponent.Id, false);
        enrollmentComponentAffiliations.add(processAffiliation);
        Enrollment_Component_Affiliation__c messageAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(studentEnrollment.Id, messageComponent.Id, false);
        enrollmentComponentAffiliations.add(messageAffiliation);
        
        insert enrollmentComponentAffiliations;                
        
        Opportunity opp = Peak_TestUtils.createOpportunity(studentEnrollment.Id);
        
        List<Enrollment_Component_Picklist_Option__c> picklistOptionList = new List<Enrollment_Component_Picklist_Option__c>();
        picklistOptionList.add(Peak_TestUtils.createEnrollmentComponentPicklistOption(questionComponent.Id, false));
        picklistOptionList.add(Peak_TestUtils.createEnrollmentComponentPicklistOption(questionComponent.Id, false));
        insert picklistOptionList;
        
        List<Option_Exclusion__c> optionExclusionList = new List<Option_Exclusion__c>();
        optionExclusionList.add(new Option_Exclusion__c(Academic_Program__c = academicProgram.Id, Option__c = picklistOptionList[0].Id));
        optionExclusionList.add(new Option_Exclusion__c(Academic_Program__c = academicProgram.Id, Option__c = picklistOptionList[0].Id));
        insert optionExclusionList;
        
        Criteria__c finalConformationCriteria = Peak_TestUtils.createCriteriaRecord(null, 'hed__Program_Enrollment__c.hed__Account__r.Confirmation_Start_Date__c', '<=', false);
        finalConformationCriteria.Comparison_Data_Type__c = 'Datetime';
        finalConformationCriteria.Comparison_Value__c = 'today()';
        insert finalConformationCriteria;
        
        Criteria__c additionalCriteria = Peak_TestUtils.createCriteriaRecord(null, 'Account.Internet_Connection_Type__c', '=', false);
        additionalCriteria.Comparison_Data_Type__c = 'Text';
        additionalCriteria.Comparison_Value__c = 'Cable';
        insert additionalCriteria;
        
        Enrollment_Component_Criteria__c studentEnrollmentComponentCriteria = Peak_TestUtils.createEnrollCompCriteria(null, formComponent.Id, false);
        studentEnrollmentComponentCriteria.Criteria__c = finalConformationCriteria.Id;
        studentEnrollmentComponentCriteria.Student_or_Household__c = 'Student';
        studentEnrollmentComponentCriteria.Criteria_Type__c = 'Completion';
        studentEnrollmentComponentCriteria.Criteria_Number__c = 1;
        insert studentEnrollmentComponentCriteria;
        
        Enrollment_Component_Criteria__c studentEnrollmentComponentCriteria2 = Peak_TestUtils.createEnrollCompCriteria(null, stageComponent.Id, false);
        studentEnrollmentComponentCriteria2.Criteria__c = finalConformationCriteria.Id;
        studentEnrollmentComponentCriteria2.Student_or_Household__c = 'Student';
        studentEnrollmentComponentCriteria2.Criteria_Type__c = 'Completion';
        studentEnrollmentComponentCriteria2.Criteria_Number__c = 3;
        insert studentEnrollmentComponentCriteria2;
        
        Enrollment_Component_Criteria__c studentEnrollmentComponentCriteria3 = Peak_TestUtils.createEnrollCompCriteria(null, sectionComponent.Id, false);
        studentEnrollmentComponentCriteria3.Criteria__c = finalConformationCriteria.Id;
        studentEnrollmentComponentCriteria3.Student_or_Household__c = 'Student';
        studentEnrollmentComponentCriteria3.Criteria_Type__c = 'Completion';
        studentEnrollmentComponentCriteria3.Criteria_Number__c = 4;
        insert studentEnrollmentComponentCriteria3;
        
        Enrollment_Component_Criteria__c houseHoldEnrollmentComponentCriteria = Peak_TestUtils.createEnrollCompCriteria(null, formComponent.Id, false);
        houseHoldEnrollmentComponentCriteria.Criteria__c = additionalCriteria.Id;
        houseHoldEnrollmentComponentCriteria.Student_or_Household__c = 'Household';
        houseHoldEnrollmentComponentCriteria.Criteria_Type__c = 'Completion';
        houseHoldEnrollmentComponentCriteria.Criteria_Number__c = 2;
        insert houseHoldEnrollmentComponentCriteria;
        
        Criteria_Group__c criteriaGroup = Peak_TestUtils.createCriteriaGroup(null, formComponent.Id, false);
        criteriaGroup.Group_Number__c = 1;
        criteriaGroup.Group_Logic__c = '2';
        insert criteriaGroup;
        
        Criteria_Group__c criteriaGroup2 = Peak_TestUtils.createCriteriaGroup(null, sectionComponent.Id, false);
        criteriaGroup2.Group_Number__c = 1;
        criteriaGroup2.Group_Logic__c = '2';
        insert criteriaGroup2;
        
        Criteria_Group__c criteriaGroup3 = Peak_TestUtils.createCriteriaGroup(null, stageComponent.Id, false);
        criteriaGroup3.Group_Number__c = 1;
        criteriaGroup3.Group_Logic__c = '2';
        insert criteriaGroup3;
        
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
    }

    static testMethod void getDocumentsListTest() {
            
        hed__Program_Enrollment__c progEnrollments = [Select id,hed__Contact__r.CreatedById from hed__Program_Enrollment__c  where RecordType.Name = 'Student' limit 1 ]; 
        
        Enrollment_Document__c acceptedDoc = Peak_TestUtils.createEnrollmentDocument(progEnrollments.Id, Peak_TestConstants.TEST_ENROLLMENT_DOC_STATUS_REASON_VERIFIED);
        Enrollment_Document__c needsAttentionDoc = Peak_TestUtils.createEnrollmentDocument(progEnrollments.Id, Peak_TestConstants.TEST_ENROLLMENT_DOC_STATUS_REASON_INVALID);
        Enrollment_Document__c UnderReviewDoc = Peak_TestUtils.createEnrollmentDocument(progEnrollments.Id, Peak_TestConstants.TEST_ENROLLMENT_DOC_STATUS_REASON_INVALID);
    
        Test.startTest();
            String result = NES_DocumentCentralController.getDocumentsList(progEnrollments.hed__Contact__r.CreatedById);
            String result2 = NES_DocumentCentralController.getDocumentsList(UnderReviewDoc.Uploader__c);
            System.assertNotEquals(result, null);
            System.assertNotEquals(result2, null);
        Test.stopTest();
        
    }
    

    




    //Added to Cover getDocumentsListByUser method (Jagadish Babu)
    static testMethod void getDocumentsListByUserTest(){        
        List<hed__Program_Enrollment__c> peRec = [SELECT Id, hed__Account__c, Status__c, hed__Contact__r.Name,Household_Program_Enrollment__r.hed__Contact__c, hed__Account__r.Document_Start_Date__c, hed__Account__r.Document_End_Date__c, RecordTypeId, RecordType.Name,(SELECT Id, Name, Status__c, Enrollment_component__r.Id, Enrollment_component__r.Name, Enrollment_component__r.RecordType.Name FROM Enrollment_Component_Affiliation__r), (Select Id, Enrollment_Component_Affiliation__c, Uploader__c from Enrollment_Documents__r) FROM hed__Program_Enrollment__c where recordtype.Name = 'Student'];
        List<User> caretaker = [Select Id, ContactId from User where ContactId=:peRec[0].Household_Program_Enrollment__r.hed__Contact__c];
        String results = NES_DocumentCentralHelper.getDocumentsListByUser(caretaker[0].Id);
        system.assertNotEquals(results, null);
       }
}