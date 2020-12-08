/**
 * 2020-05-29 added test class for #US169194  (Mark Membrino)
 * Code coverage: Batch_FECTaskCreation (100%)
 */
@isTest(SeeAllData=false)
public class Batch_FECTaskCreationTest {

    public static final String MISSING_RULES_ERROR_MESSAGE = 'Missing required FEC Task Creation Setting: Found zero records for FEC_Task_Creation_Rule__mdt';

    @TestSetup 
    static void setup() {

        // Create institution Account
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('Test School Year', System.today());

        // Create a account with 'Academic Program' record type
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, currentSchoolYear.Id);
        academicProgram.Registration_End_Date__c=Date.today().addMonths(1);
        academicProgram.Registration_Start_Date__c=Date.newInstance(2017,11,11);
        academicProgram.Confirmation_End_Date__c = Date.today().addMonths(1);
        update academicProgram;

        // Create a Contact with 'Caretaker' record type
        Contact careTakerContact = Peak_TestUtils.createTestContact('Caretaker', institutionAccount.Id);
        User careTaker = Peak_TestUtils.CreatePortalCaretTakerUser(careTakerContact.Id);
        Id careTakerEnrollmentType = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId();
        hed__Program_Enrollment__c careTakerEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, careTaker.ContactId, currentSchoolYear.Id, false);
        careTakerEnrollment.RecordTypeId = careTakerEnrollmentType;
        insert careTakerEnrollment;

        // Create a contact with 'Students' record type
        Contact contact = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);

        // Create STUDENT PE
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, contact.Id, currentSchoolYear.Id, false);
        progEnrollment.Status__c=Batch_FECTaskCreation.PE_STATUS;
        insert progEnrollment;

        // Create EnrollmentSupport Case for the student PE
        Case esCase = createCase(progEnrollment.Id, institutionAccount.Id, careTakerContact.Id, true);

        // MISC...
        User u = [SELECT Id,ContactId FROM User WHERE ContactId != NULL AND IsActive = TRUE LIMIT 1];
        hed__Relationship__c  relationship = Peak_TestUtils.createRelationship(u.ContactId, contact.Id, true);


        // Create ECs with different record type
        List < Enrollment_Component__c > componentList = new List < Enrollment_Component__c > ();
        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);
        Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Process', false);
        Enrollment_Component__c questionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        Enrollment_Component__c sectionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        Enrollment_Component__c formComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        Enrollment_Component__c messageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Message', false);
        Enrollment_Component__c documentComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Document', false);
        componentList.add(stageComponent);
        componentList.add(processComponent);
        componentList.add(questionComponent);
        componentList.add(sectionComponent);
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

        // create Enrollment Component Affiliations with different parent Enrollment Components.
        Enrollment_Component_Affiliation__c affiliationForm = createEnrollmentComponentAffiliation(progEnrollment.Id, formComponent.Id);
        Enrollment_Component_Affiliation__c affiliationForm2 = createEnrollmentComponentAffiliation(progEnrollment.Id, formComponent.Id);
        Enrollment_Component_Affiliation__c affiliationForm3 = createEnrollmentComponentAffiliation(progEnrollment.Id, formComponent.Id);
        Enrollment_Component_Affiliation__c affiliationStage = createEnrollmentComponentAffiliation(progEnrollment.Id, stageComponent.Id);
        Enrollment_Component_Affiliation__c affiliationSection = createEnrollmentComponentAffiliation(progEnrollment.Id, sectionComponent.Id);
        Enrollment_Component_Affiliation__c affiliationDocument = createEnrollmentComponentAffiliation(progEnrollment.Id, documentComponent.Id);
        Enrollment_Component_Affiliation__c affiliationProcess = createEnrollmentComponentAffiliation(progEnrollment.Id, processComponent.Id);
        Enrollment_Component_Picklist_Option__c picklistOption = Peak_TestUtils.createEnrollmentComponentPicklistOption(questionComponent.Id, true);
        List<Enrollment_Component_Affiliation__c> ecas = new List<Enrollment_Component_Affiliation__c>();
        ecas.add(affiliationForm);
        ecas.add(affiliationForm2);
        ecas.add(affiliationForm3);
        ecas.add(affiliationStage);
        ecas.add(affiliationSection);
        ecas.add(affiliationDocument);
        ecas.add(affiliationProcess);
        insert ecas;
    }

    /**
     *  test to verify creation of Task for rule qualifiying PE/Cases
     * */    
    static testMethod void Batch_FECTaskCreationPositiveTest() {

        // get the FEC Task Creation Rules
        List<FEC_Task_Creation_Rule__mdt> fecTaskCreationRules = Batch_FECTaskCreation.getTaskCreationRules();
        FEC_Task_Creation_Rule__mdt currentRule = fecTaskCreationRules[0];

        if (fecTaskCreationRules.size()==0)
            throw new Batch_FECTaskCreation.FECTaskCreationException(MISSING_RULES_ERROR_MESSAGE);

        // get PE
        hed__Program_Enrollment__c progEnrollment = 
            [SELECT Id FROM hed__Program_Enrollment__c WHERE RecordTypeId 
                = :Batch_FECTaskCreation.STUD_PE_RECORD_TYPE_ID ORDER BY CreatedDate DESC LIMIT 1];
        
        // get case
        Case c = [SELECT Id from Case LIMIT 1];
                
        // Move the createdDate back as per current rule
        Datetime newCreatedDate = datetime.now().addDays((Integer)(-1 * currentRule.lowerLimitInDays__c));
        Test.setCreatedDate(progEnrollment.Id, newCreatedDate);

        // verify CreatedDate is set as expected
        progEnrollment = refreshPE(progEnrollment.Id);
        System.assertEquals(newCreatedDate, progEnrollment.CreatedDate);
    
        Test.startTest();
            Batch_FECTaskCreation taskCreationBatch = new Batch_FECTaskCreation();
            Database.executeBatch(taskCreationBatch);
        Test.stopTest();

        // get Task for the given Case
        c = refreshCase(c.Id);
        Task tsk = [Select Id, CreatedDate, Subject, RecordTypeId, Type, SubType__c, OwnerId from Task where whatId = :c.Id LIMIT 1];

        // assertions/verification
        System.assertEquals(label.Household_Pool_Queue_ID, tsk.OwnerId);
        System.assertEquals(Batch_FECTaskCreation.NEW_TASK_RECORD_ID, tsk.RecordTypeId);
        System.assertEquals(currentRule.taskTypeDefault__c, tsk.Type);
        System.assertEquals(currentRule.taskSubTypeDefault__c, tsk.SubType__c);
    }

    /**
    *  test to verify NO NEW task get created for existing task for the same rule.
    * */    
    static testMethod void Batch_FECTaskCreationPositiveTest2() {

        // get the FEC Task Creation Rules
        List<FEC_Task_Creation_Rule__mdt> fecTaskCreationRules = Batch_FECTaskCreation.getTaskCreationRules();
        FEC_Task_Creation_Rule__mdt currentRule = fecTaskCreationRules[2];

        if (fecTaskCreationRules.size()==0)
            throw new Batch_FECTaskCreation.FECTaskCreationException(MISSING_RULES_ERROR_MESSAGE);

        // get PE
        hed__Program_Enrollment__c progEnrollment = 
            [SELECT Id FROM hed__Program_Enrollment__c WHERE RecordTypeId 
                = :Batch_FECTaskCreation.STUD_PE_RECORD_TYPE_ID ORDER BY CreatedDate DESC LIMIT 1];
        
        // get case
        Case c = [SELECT Id from Case LIMIT 1];
                
        // Move the createdDate back as per current rule
        // Integer moveInDays = (Integer)(-1 * currentRule.lowerLimitInDays__c); 
        Datetime newCreatedDate = datetime.now().addDays((Integer)(-1 * currentRule.lowerLimitInDays__c));
        Test.setCreatedDate(progEnrollment.Id, newCreatedDate);

        // verify CreatedDate is set as expected
        progEnrollment = refreshPE(progEnrollment.Id);
        System.assertEquals(newCreatedDate, progEnrollment.CreatedDate);

        Test.startTest();
            // run the batch 1st time: 
            Batch_FECTaskCreation taskCreationBatch = new Batch_FECTaskCreation();
            Database.executeBatch(taskCreationBatch);

            // run the batch 2nd time: 
            Batch_FECTaskCreation taskCreationBatch2 = new Batch_FECTaskCreation();
            Database.executeBatch(taskCreationBatch2);
        Test.stopTest();

        // get Task for the given Case
        c = refreshCase(c.Id);
        List<Task> tsks = [Select Id, CreatedDate, Subject, RecordTypeId, Type, SubType__c, OwnerId from Task where whatId = :c.Id];

        // assertions/verification
        System.assertEquals(1, tsks.size());

    }

    /**
    *  test to verify NO task is created for Case/PE that does not meet any rule criteria.
    * */    
    static testMethod void Batch_FECTaskCreationNegativeTest() {

        // get the FEC Task Creation Rules
        List<FEC_Task_Creation_Rule__mdt> fecTaskCreationRules = Batch_FECTaskCreation.getTaskCreationRules();
        FEC_Task_Creation_Rule__mdt currentRule = fecTaskCreationRules[0];

        if (fecTaskCreationRules.size()==0)
            throw new Batch_FECTaskCreation.FECTaskCreationException(MISSING_RULES_ERROR_MESSAGE);

        // get PE
        hed__Program_Enrollment__c progEnrollment = 
            [SELECT Id FROM hed__Program_Enrollment__c WHERE RecordTypeId 
                = :Batch_FECTaskCreation.STUD_PE_RECORD_TYPE_ID ORDER BY CreatedDate DESC LIMIT 1];
        
        // get case
        Case c = [SELECT Id from Case LIMIT 1];
                
        // Move the createdDate back as per current rule
        // Integer moveInDays = (Integer)(-1 * currentRule.lowerLimitInDays__c);
        Datetime newCreatedDate = datetime.now();
        Test.setCreatedDate(progEnrollment.Id, newCreatedDate);

        // verify CreatedDate is set as expected
        progEnrollment = refreshPE(progEnrollment.Id);
        System.assertEquals(newCreatedDate, progEnrollment.CreatedDate);
    
        Test.startTest();
            Batch_FECTaskCreation taskCreationBatch = new Batch_FECTaskCreation();
            Database.executeBatch(taskCreationBatch);
        Test.stopTest();

        // get Task for the given Case
        c = refreshCase(c.Id);
        List<Task> tsks = [Select Id, CreatedDate, Subject, RecordTypeId, Type, SubType__c, OwnerId from Task where whatId = :c.Id];

        // assertions/verification
        System.assertEquals(0, tsks.size());
    }

    /**
    *  test for scheduled run.
    * */    
    static testMethod void testSchedule() {
        Test.StartTest();
            Batch_FECTaskCreation schClass = new Batch_FECTaskCreation();
            String sch = '0 0 23 * * ?'; 
            system.schedule('Test FEC Task Creation Scheduled run', sch, schClass); 
        Test.stopTest(); 
    }

    public static Case createCase(Id peId, Id accID, Id conId, Boolean isInsert) {
        Case c = new Case();
        c.AccountId = accID; //caretaker.Contact.AccountId;
        c.ContactId = conId; //caretaker.ContactId; 
        c.Origin = 'Enrollment Community';
        c.Type = 'Enrollment Assistance';
        c.Ticket_Type__c='New Applicant Call';
        c.Platform__c = 'Pearson Connexus';
        c.Description = 'New Applicant Call';
        c.Program_Enrollment__c = peId; //newStudentEnrollment.Id;
        c.Subject = 'Initial Call';
        c.RecordTypeId = Batch_FECTaskCreation.CASE_RECORD_ID;

        if(isInsert) insert c;
        return c;
    }

    public static Enrollment_Component_Affiliation__c createEnrollmentComponentAffiliation(String programEnrollmentId, String componentId) {

        Enrollment_Component_Affiliation__c compAffiliation = new Enrollment_Component_Affiliation__c();
        compAffiliation.Status__c = 'Not Started';
        compAffiliation.Program_Enrollment__c = programEnrollmentId;
        compAffiliation.Enrollment_Component__c = componentId;
        return compAffiliation;
    }

    public static hed__Program_Enrollment__c refreshPE(Id peId) {
        return [SELECT Id, Name, Status__c, Total_Forms__c, Total_Forms_Completed__c, Percent_Complete__c, CreatedDate, Date_Today__c
                FROM hed__Program_Enrollment__c
                WHERE Id = :peID];
    }

    public static Case refreshCase(Id caseId) {
        return [SELECT  Id, OwnerId, Owner.Type, RecordTypeId, Program_Enrollment__c
                FROM Case 
                WHERE Id = :caseId];
    }
    
}