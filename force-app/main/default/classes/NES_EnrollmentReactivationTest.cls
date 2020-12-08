/** 

@author: Ali KM (Ness Tech)
* Created this test class on 12/03/2019 for [US 119348]
* Test coverage for 
// => NES_EnrollmentReactivation.cls  (DEPRECATED - NO LONGER USED)
=> NES_EnrollmentReactivationBase.cls
=> NES_StudentReenrollment.cls
=> NES_StudentReactivation.cls
=> NES_EnrollmentReactivationHandler.cls

*/
@isTest(SeeAllData=false isParallel=true)
public with sharing class NES_EnrollmentReactivationTest { 
    public enum Reactivation {SOFT, FULL, RE_ENROLLMENT } 
    
    
    public static final String EC_DEFAULT_REACTIVATION_STATUS = 'Not Started'; // OR => In Progress // EC.Reactivation_Status__c
    public static final String OPP_DEFAULT_OPP_STAGE = 'Closed Lost';
    public static final String REACTIVATION_FULL = 'FULL';
    public static final String REACTIVATION_SOFT = 'SOFT';
    public static final String STUDENT_RE_ENROLLMENT = 'RE_ENROLLMENT';
    
    
    @TestSetup 
    static void setup() {
        
        Account account = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019', Date.parse('11/17/2018'));
        School_Year__c previousSchoolYear = Peak_TestUtils.createSchoolYears('2017-2018', Date.parse('11/17/2017'));
        
        
        // Create a contact with 'Students' record type
        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);
        
        
        // Create a account with 'Academic Program' record type
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(account.Id, currentSchoolYear.Id);
        academicProgram.Registration_End_Date__c=Date.today().addMonths(1);
        academicProgram.Registration_Start_Date__c=Date.newInstance(2017,11,11);
        academicProgram.Confirmation_End_Date__c = Date.today().addMonths(1);
        update academicProgram;
        
        
        // Create STUDENT PE
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, contact.Id, currentSchoolYear.Id, false);
        progEnrollment.Status__c='Inactive';
        insert progEnrollment;
        
        
        // NOT SURE WHY WE NEED Relationship
        User u = [SELECT Id,ContactId FROM User WHERE ContactId != NULL AND IsActive = TRUE LIMIT 1];
        hed__Relationship__c  relationship = Peak_TestUtils.createRelationship(u.ContactId, contact.Id, true);
        
        
        // Create ECs with different record type
        List < Enrollment_Component__c > componentList = new List < Enrollment_Component__c > ();
        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);
        stageComponent.Reactivation_Status__c = EC_DEFAULT_REACTIVATION_STATUS;
        Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Process', false);
        Enrollment_Component__c questionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponent.Reactivation_Status__c = EC_DEFAULT_REACTIVATION_STATUS;
        Enrollment_Component__c questionGroupComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question_Group', false);
        questionGroupComponent.Reactivation_Status__c = EC_DEFAULT_REACTIVATION_STATUS;
        Enrollment_Component__c sectionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        Enrollment_Component__c formComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form', false);
        formComponent.Reactivation_Status__c = EC_DEFAULT_REACTIVATION_STATUS;
        Enrollment_Component__c messageComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Message', false);
        Enrollment_Component__c documentComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Document', false);
        documentComponent.Reactivation_Status__c = EC_DEFAULT_REACTIVATION_STATUS;
        
        componentList.add(stageComponent);
        componentList.add(processComponent);
        componentList.add(questionComponent);
        componentList.add(questionGroupComponent);
        componentList.add(sectionComponent);
        componentList.add(formComponent);
        componentList.add(messageComponent);
        componentList.add(documentComponent);
        insert componentList;
        
        
        // Not sure why we need this
        // create Enrollment Component Relationships with different parent Enrollment Components.
        Enrollment_Component_Relationship__c enrollCompRelationship = Peak_TestUtils.createEnrollmentComponentRelationship(stageComponent.Id, processComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship2 = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponent.Id, questionGroupComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship3 = Peak_TestUtils.createEnrollmentComponentRelationship(questionGroupComponent.Id, sectionComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship4 = Peak_TestUtils.createEnrollmentComponentRelationship(formComponent.Id, stageComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship5 = Peak_TestUtils.createEnrollmentComponentRelationship(messageComponent.Id, formComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship6 = Peak_TestUtils.createEnrollmentComponentRelationship(sectionComponent.Id, formComponent.Id);
        
        
        // create Enrollment Component Affiliations with different parent Enrollment Components.
        Enrollment_Component_Affiliation__c affiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, formComponent.Id);
        Enrollment_Component_Affiliation__c affiliationStage = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, stageComponent.Id);
        Enrollment_Component_Affiliation__c affiliationSection = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, sectionComponent.Id);
        Enrollment_Component_Affiliation__c affiliationDocument = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, documentComponent.Id);
        Enrollment_Component_Affiliation__c affiliationProcess = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, processComponent.Id);
        Enrollment_Component_Affiliation__c affiliationQuestionGroup = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, questionGroupComponent.Id);
        Enrollment_Component_Picklist_Option__c picklistOption = Peak_TestUtils.createEnrollmentComponentPicklistOption(questionComponent.Id, true);
        
        
        // create EDs
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(progEnrollment.Id,'IEP Exit Documentation','Requested',false);
        // enrollmentDocument1.Type__c = 'IEP Exit Documentation';
        // enrollmentDocument1.Status_Reason__c = 'Requested';
        enrollmentDocument1.Enrollment_Component_Affiliation__c = affiliation.Id;
        insert enrollmentDocument1;
        
        Grade_Level__c gradeLevel = Peak_TestUtils.createGradeLevel('Test',true);
        Program_Grade_Level__c programGradeLevel = Peak_TestUtils.createProgramGradeLevel('Test', academicProgram.Id, gradeLevel.Id,Datetime.now(), true);
        
        // Create a Standard User
        User  portalUser= Peak_TestUtils.CreatePortalCaretTakerUser(contact.Id);
        School_Year__c schlYear = Peak_TestUtils.createSchoolYears('SchoolTest', System.today());
        // hed__Program_Enrollment__c ProgramEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, contact.Id, schlYear.Id, false);
        // insert ProgramEnrollmentTest;
        
        // create ASIs
        Annual_Student_Information__c annualStudentInformation 
            = Peak_TestUtils.createAnnualStudentInformation('Test ASI',progEnrollment.Id,currentSchoolYear.Id,true);
        
        // create SE
        Special_Education__c specialEducation = Peak_TestUtils.createSpecialEducation(progEnrollment.Id,false);
        specialEducation.IEP__c = 'Documenting';
        specialEducation.Plan504__c = 'Received';
        insert specialEducation;
        
        // create Opportunity
        Opportunity newOpp = createOpportunity(progEnrollment.Id, progEnrollment.hed__Account__c, OPP_DEFAULT_OPP_STAGE, true);
        
        
    }
    
    
    static testMethod void studReenrollment_Positive() {
        
        hed__Program_Enrollment__c progEnrollment = [SELECT Id,hed__Account__c, Status__c,RecordType.Name FROM hed__Program_Enrollment__c  LIMIT 1];
        progEnrollment.Status__c = NES_EnrollmentReactivationBase.PE_WITHDRAWAL_STATUS;
        update progEnrollment;
        List<Enrollment_Component__c> lstECs = new List<Enrollment_Component__c>();
        for(Enrollment_Component__c EC : [Select Id,RecordType.Name, Needed_For_Re_Enrollment__c from Enrollment_Component__c]){
            lstECs.add(new Enrollment_Component__c(Id=EC.Id, Needed_For_Re_Enrollment__c = true));
        }
        update lstECs;
        List<Enrollment_Component_Affiliation__c> lstECAs = new List<Enrollment_Component_Affiliation__c>();
        for(Enrollment_Component_Affiliation__c ECA : [Select Id, Status__c, Program_Enrollment__c, Enrollment_Component__r.RecordType.Name from Enrollment_Component_Affiliation__c where Program_enrollment__c =:progEnrollment.Id]){
            lstECAs.add(new Enrollment_Component_Affiliation__c(Id=ECA.Id, Status__c ='Complete'));
        }
        update lstECAs;
        Test.startTest();
        Peak_Response response = NES_EnrollmentReactivationHandler.reactivateStudent(progEnrollment.Id, STUDENT_RE_ENROLLMENT);
        Test.stopTest();
        System.assertEquals(true,response.success);
        
    }
    
    
    static testMethod void studEnrollmentReactivationFull_Positive() {
        
        hed__Program_Enrollment__c progEnrollment = [SELECT Id,hed__Account__c, Status__c,RecordType.Name FROM hed__Program_Enrollment__c  LIMIT 1];
        
        Test.startTest();
        Peak_Response response = NES_EnrollmentReactivationHandler.reactivateStudent(progEnrollment.Id, REACTIVATION_FULL);
        Test.stopTest();
        System.assertEquals(true,response.success);
        
        
    }
    
    
    static testMethod void studEnrollmentReactivationSoft_Positive() {
        
        hed__Program_Enrollment__c progEnrollment = [SELECT Id,hed__Account__c, Status__c,RecordType.Name FROM hed__Program_Enrollment__c  LIMIT 1];
        
        Test.startTest();
        Peak_Response response = NES_EnrollmentReactivationHandler.reactivateStudent(progEnrollment.Id, REACTIVATION_SOFT);
        Test.stopTest();
        System.assertEquals(true,response.success);
        
    }
    
    
    static testMethod void studEnrollmentReactivation_Negative() {
        
        hed__Program_Enrollment__c progEnrollment = [SELECT Id,hed__Account__c, Status__c,RecordType.Name FROM hed__Program_Enrollment__c  LIMIT 1];
        
        Test.startTest();
        Peak_Response response = NES_EnrollmentReactivationHandler.reactivateStudent(progEnrollment.Id, 'UNLISTED');
        Test.stopTest();
        System.assertEquals(false,response.success);
        
        
    }
    
    
    // Test Data creation methods
    public static Opportunity createOpportunity(Id programEnrollmentId, Id accID, String stageName, Boolean isInsert) {
        
        Opportunity newOpportunity = new Opportunity(
            Program_Enrollment__c = programEnrollmentId,
            Name = Peak_TestConstants.OPP_NAME,
            StageName = stageName,
            AccountId = accID,
            CloseDate = Date.today().addMonths(1)
        );
        
        if(isInsert) {
            Insert newOpportunity;
        }
        
        return newOpportunity;
        
        
    }
    static testMethod void studentsMigratedTest() {
        hed__Program_Enrollment__c progEnrollment = [SELECT Id,V2_External_ID__c,hed__Account__c, Status__c,RecordType.Name FROM hed__Program_Enrollment__c  LIMIT 1];
        progEnrollment.V2_External_ID__c  = 'Test Migrated';
        progEnrollment.Status__c = NES_EnrollmentReactivationBase.PE_WITHDRAWAL_STATUS;
        update progEnrollment;
        List<Enrollment_Component_Affiliation__c> ecaList = [Select Id,Program_Enrollment__c from Enrollment_Component_Affiliation__c where Program_Enrollment__c =: progEnrollment.Id];
        delete ecaList;
        List<Enrollment_Component__c> ecList = new List<Enrollment_Component__c>();
        for(Enrollment_Component__c EC : [Select Id, Assignment_Logic__c,Needed_for_Re_enrollment__c from Enrollment_Component__c]){
            ecList.add(new Enrollment_Component__c(Id=Ec.Id, Needed_for_Re_enrollment__c = true,Assignment_Logic__c=''));
        }
        update ecList;
        Test.startTest();
        Peak_Response response = NES_EnrollmentReactivationHandler.reactivateStudent(progEnrollment.Id, STUDENT_RE_ENROLLMENT);
        Test.stopTest();
        System.assertEquals(true,response.success);
    }
    
    static testMethod void studReenrollment_NegativeRec() {
        hed__Program_Enrollment__c progEnrollment = [SELECT Id,hed__Account__c, Status__c,RecordType.Name FROM hed__Program_Enrollment__c  LIMIT 1];
        progEnrollment.RecordTypeId = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByDeveloperName().get('Caretaker').getRecordTypeId();
        update progEnrollment;       
        Test.startTest();
        Peak_Response response = NES_EnrollmentReactivationHandler.reactivateStudent(progEnrollment.Id, STUDENT_RE_ENROLLMENT);
        try{
            NES_StudentReactivation obj = new NES_StudentReactivation(progEnrollment.Id, NES_EnrollmentReactivationBase.Reactivation.RE_ENROLLMENT);
        }
        catch(Exception e1){}
        Test.stopTest();
    }
    static testMethod void studReenrollment_NegativeRec1() {
        hed__Program_Enrollment__c progEnrollment = [SELECT Id,hed__Account__c, Status__c,RecordType.Name FROM hed__Program_Enrollment__c  LIMIT 1];   
        Test.startTest();
        Peak_Response response = NES_EnrollmentReactivationHandler.reactivateStudent(progEnrollment.Id, STUDENT_RE_ENROLLMENT);
        try{
            NES_StudentReactivation obj = new NES_StudentReactivation(progEnrollment.Id, NES_EnrollmentReactivationBase.Reactivation.RE_ENROLLMENT);        
            obj.validateStudPEID(null);
        }
        catch(Exception e1){}
        Test.stopTest();
    }
    static testMethod void studReenrollment_NegativeRec2() {
        hed__Program_Enrollment__c progEnrollment = [SELECT Id,hed__Account__c, Status__c,RecordType.Name FROM hed__Program_Enrollment__c  LIMIT 1];   
        Test.startTest();
        Peak_Response response = NES_EnrollmentReactivationHandler.reactivateStudent(progEnrollment.Id, STUDENT_RE_ENROLLMENT);
        try{
            NES_StudentReactivation obj = new NES_StudentReactivation(progEnrollment.Id, NES_EnrollmentReactivationBase.Reactivation.RE_ENROLLMENT);        
            id recId = [Select id from Account limit 1].Id;
            obj.validateStudPEID(recId);
        }
        catch(Exception e1){}
        Test.stopTest();
    }
    
    static testMethod void studEnrollmentReactivationFull_Positive2() {
        
        hed__Program_Enrollment__c progEnrollment = [SELECT Id,hed__Account__c, Status__c,RecordType.Name FROM hed__Program_Enrollment__c  LIMIT 1];     
        Test.startTest();
        Peak_Response response = NES_EnrollmentReactivationHandler.reactivateStudent(progEnrollment.Id, STUDENT_RE_ENROLLMENT);
        Test.stopTest();
    }
    
    
    static testMethod void studEnrollmentReactivationSoft_Positive1() {
        
        hed__Program_Enrollment__c progEnrollment = [SELECT Id,hed__Account__c, Status__c,RecordType.Name FROM hed__Program_Enrollment__c  LIMIT 1];      
        Test.startTest();
        Peak_Response response = NES_EnrollmentReactivationHandler.reactivateStudent(progEnrollment.Id, STUDENT_RE_ENROLLMENT);
        NES_StudentReactivation obj = new NES_StudentReactivation(progEnrollment.Id, NES_EnrollmentReactivationBase.Reactivation.RE_ENROLLMENT);
        obj.processECAs(STUDENT_RE_ENROLLMENT);
        Test.stopTest();
    }    
}