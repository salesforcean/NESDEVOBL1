@isTest
public class NES_IntentToReturnHandlerTest {
	@TestSetup
    static void setup() {
        
        Account account = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019', Date.parse('11/17/2018'));
        School_Year__c previousSchoolYear = Peak_TestUtils.createSchoolYears('2017-2018', Date.parse('11/17/2017'));
        
        // Create a contact with 'Students' record type
        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);
        
        // Create a account with 'Academic Program' record type
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(account.Id, currentSchoolYear.Id);

        academicProgram.use_updated_ECA_Process__c = true;
        update academicProgram;

        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, contact.Id, currentSchoolYear.Id, true);
        
        User u = [SELECT Id,ContactId FROM User WHERE ContactId != NULL AND IsActive = TRUE LIMIT 1];
        hed__Relationship__c  relationship = Peak_TestUtils.createRelationship(u.ContactId, contact.Id, true);
        
        // Create a Enrollment Components with different record type
        List < Enrollment_Component__c > componentList = new List < Enrollment_Component__c > ();
        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);
        Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Process', false);
        Enrollment_Component__c questionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        Enrollment_Component__c sectionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);

        Enrollment_Component__c sectionComponentITRSection = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponentITRSection.Name = 'ITR Section';
        sectionComponentITRSection.Assignment_Logic__c = '1';

        Enrollment_Component__c formComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        Enrollment_Component__c messageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Message', false);
        Enrollment_Component__c documentComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Document', false);
        
        componentList.add(stageComponent);
        componentList.add(processComponent);
        componentList.add(questionComponent);
        componentList.add(sectionComponent);

        componentList.add(sectionComponentITRSection);

        componentList.add(formComponent);
        componentList.add(messageComponent);
        componentList.add(documentComponent);
        insert componentList;
        
        // create Enrollment Component Relationships with different parent Enrollment Components.
        Enrollment_Component_Relationship__c enrollCompRelationship = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponent.Id, processComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship2 = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponent.Id, sectionComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship3 = Peak_TestUtils.createEnrollmentComponentRelationship(formComponent.Id, stageComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship4 = Peak_TestUtils.createEnrollmentComponentRelationship(messageComponent.Id, formComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship5 = Peak_TestUtils.createEnrollmentComponentRelationship(sectionComponent.Id, formComponent.Id);

        Enrollment_Component_Relationship__c enrollCompRelationship6 = Peak_TestUtils.createEnrollmentComponentRelationship(sectionComponentITRSection.Id, formComponent.Id);

        
        // create Enrollment Component Affiliations with different parent Enrollment Components.
        Enrollment_Component_Affiliation__c affiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, formComponent.Id);
        Enrollment_Component_Affiliation__c affiliationStage = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, stageComponent.Id);
        Enrollment_Component_Affiliation__c affiliationSection = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, sectionComponent.Id);
        Enrollment_Component_Affiliation__c affiliationDocument = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, documentComponent.Id);
        Enrollment_Component_Affiliation__c affiliationProcess = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, processComponent.Id);
        Enrollment_Component_Picklist_Option__c picklistOption = Peak_TestUtils.createEnrollmentComponentPicklistOption(questionComponent.Id, true);
        

        
        Criteria__c cr2 = Peak_TestUtils.createCriteriaRecord(null, 'Intent_To_Return__c.SchoolCity__c', '=', false);
        cr2.Comparison_Data_Type__c = 'Text';
        cr2.Comparison_Value__c = 'test City1';
        insert cr2;
        Enrollment_Component_Criteria__c ecc2 = Peak_TestUtils.createEnrollCompCriteria(null, sectionComponentITRSection.Id, false);
        ecc2.Criteria__c = cr2.Id;
        ecc2.Student_or_Household__c = 'Student';
        ecc2.Criteria_Number__c = 1;
        insert ecc2;
        
        Program_Enrollment_Criteria__c newPEC = new Program_Enrollment_Criteria__c (Program_Enrollment__c=progEnrollment.Id, Criteria__c = cr2.id, Result__c = false);
        insert newPEC;
        

        // Create a Standard User
        
        User  portalUser= Peak_TestUtils.CreatePortalCaretTakerUser();
        School_Year__c schlYear = Peak_TestUtils.createSchoolYears('SchoolTest', System.today());
        hed__Program_Enrollment__c ProgramEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, contact.Id, schlYear.Id, false);
        insert ProgramEnrollmentTest;            

        Enrollment_Component_Affiliation__c affiliationSection1 = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, sectionComponentITRSection.Id);
        affiliationSection1.Status__c = 'Not Applicable';
        update affiliationSection1;
        
        Intent_To_Return__c ITRObj= new Intent_To_Return__c();
        ITRObj.SchoolName__c = 'test school';
        ITRObj.SchoolState__c = 'test state';
        ITRObj.SchoolDistrict__c = 'test destrict';
        ITRObj.Program_Enrollment__c = progEnrollment.Id;

        ITRObj.Phone__c = '7923799332';
        ITRObj.SchoolCity__c = 'test city';
        ITRObj.SchoolStreet_Address__c = 'test street';
        ITRObj.SchoolType__c = 'Homeschool';
        ITRObj.SchoolZIP__c = '12345';
        ITRObj.Question_Group__c  = questionComponent.Id;
        insert ITRObj;
    }
    
    static testMethod void testForUpdateScenario() {

        List<Account> academicPrograms = [Select Id, Name, ParentId,use_updated_ECA_Process__c from Account where  recordType.Name = 'Academic Program'];
        hed__program_enrollment__c pgEnrollment1 = [SELECT Id,(Select Id, Program_Enrollment__c,Criteria__c, Result__c from Program_Enrollment_Criteria__r),(Select Id, SchoolCity__c from Intent_To_Returns__r) FROM hed__program_enrollment__c LIMIT 1];
        User caretakerUser = [SELECT Id, ContactId FROM User LIMIT 1];
        Criteria__c cr1 = [SELECT Id, Comparison_Data_Type__c,Operator__c,Comparison_Field__c,Comparison_Value__c FROM Criteria__c ];
        Contact caretaker = [SELECT Id, RecordType.Name, AccountId FROM Contact WHERE RecordType.Name = 'Caretaker' LIMIT 1];
        Contact student = [SELECT Id, RecordType.Name, AccountId FROM Contact WHERE RecordType.Name = 'Students' LIMIT 1];
        List<Enrollment_Component__c> parentEnrollmentComponent = [SELECT Id,Assignment_Logic__c,(SELECT Id,Criteria_Number__c, Enrollment_Component__c,Criteria__c,Student_or_Household__c  FROM Enrollment_Component_Criteria__r) FROM Enrollment_Component__c];
        List<Program_Enrollment_Criteria__c> PECs = [Select Id, Program_Enrollment__c,Criteria__c, Result__c from Program_Enrollment_Criteria__c];   
        List<Enrollment_Component_Affiliation__c> ecas = [Select Id, Name,Status__c,Is_Dirty__c, Enrollment_Component__r.Name from Enrollment_Component_Affiliation__c ];        
        Intent_To_Return__c ITRRec = [Select Id,Program_Enrollment__c, SchoolCity__c from Intent_To_Return__c limit 1];
        ITRRec.SchoolCity__c = 'test City1';        
        update ITRRec;
        system.assertEquals(true, [Select Id, Name,Status__c, Enrollment_Component__r.Name from Enrollment_Component_Affiliation__c where Enrollment_Component__r.Name ='ITR Section'].size()>0);

    }
}