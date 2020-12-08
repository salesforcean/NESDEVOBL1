@isTest(SeeAllData=false isParallel=true)
public with sharing class ali_testClass {

  /**
   * * NU
   * * 56,58,61,63,65,66,68,72,73,94,97,99,100,101,102,104,106,121,124,126,127,128,129,130,132,134,146,160,162,163,164,165,166,167,193,195,196,197,200,201,202,203,205,209,210,212,213,214,216,217,218,231,233,235,
        * 61,63,65,66,68,72,73,94,97,99,100,101,102,104,106,121,124,126,127,128,129,130,132,134,146,160,162,163,164,165,166,167,201,202,203,205,
        * 61,63,65,66,68,72,73,94,97,99,100,101,102,104,106,121,124,126,127,128,129,130,132,134,146,160,162,163,164,165,166,167,201,202,203,205,214,231,235,
   */
  @TestSetup
  static void makeData() {

    // GENERATE THE PROGRAM ACCOUNT
    Account parentAccount = Peak_TestUtils.createAccountRecord('ED Account','Educational Institution');
    School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('2018-2019', date.parse('11/17/2018'));
    Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(parentAccount.Id, schoolYear.Id);
    academicProgram.Registration_Start_Date__c = System.today().addDays(-10);
    academicProgram.Registration_End_Date__c = System.today().addDays(10);
    academicProgram.Document_End_Date__c=System.now()+10;
    academicProgram.Document_Start_Date__c=System.now()-10;
    update academicProgram;
    
    // GENERATE CARETAKER
    Account houseHoldAccount = Peak_TestUtils.createAccountRecord('HouseHold Account','Household');
    // user createUser = Peak_TestUtils.createStandardUser();
    // Contact con=[Select LastName from Contact where LastName =: createUser.LastName];
    contact careTakerContact = Peak_TestUtils.createTestContact('Caretaker', houseHoldAccount.Id);
    careTakerContact = [SELECT Id, CreatedById from Contact where Id = :careTakerContact.Id];

    // get current User
    // User careTakerUser = createStandardUser(careTakerContact.id+'');
    // insert careTakerUser;
    

    // CREATE A STUD CONTACT
    Contact studentContact = Peak_TestUtils.createTestContact('Students', houseHoldAccount.Id);
    // studentContact.createdById = careTakerUser.Id; // NOT WRITEABLE
    update studentContact;
    

    // Plumbbing for STUD PE
    Grade_Level__c levels = new Grade_Level__c();
    levels.Name = 'Test User';
    insert levels;
    Program_Grade_Level__c programLevels = new Program_Grade_Level__c();
    programLevels.Academic_Program__c = academicProgram.Id;
    programLevels.Grade_Level__c = levels.Id;
    programLevels.Document_Submission_End_Date__c = System.now()+10;
    programLevels.Document_Submission_Start_Date__c = System.now()-10;
    insert programLevels;

    // GENERATE STUD PE
    hed__Program_Enrollment__c studentPE = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, studentContact.Id, schoolYear.Id, false);
    studentPE.Status__c = 'In Progress';
    insert studentPE;

    // GENERATE PROCESSID
    List < Enrollment_Component__c > componentList = new List < Enrollment_Component__c > ();
    Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Process', false);

    // GENERATE MULTI STAGES
    Enrollment_Component__c inprogressSTAGE = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);
    inprogressSTAGE.Name = 'Tell us about yourself!';
    Enrollment_Component__c notStartedSTAGE = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Stage', false);
    notStartedSTAGE.Name = 'Waitlisted';  


    // GENERATE MULTI FORMS
    Enrollment_Component__c inprogressFORM = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form',false);
    // Enrollment_Component__c inprogressFORM2 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form',false);
    Enrollment_Component__c notstartedFORM = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Form',false);


    // GENERATE MULTI DOC-TYPES, MSGS, QUESTIONS
    Enrollment_Component__c inprogressDOC = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Document', false);
    Enrollment_Component__c inprogressDOC2 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Document', false);
    // Enrollment_Component__c inprogress2DOC2 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Document', false);
    Enrollment_Component__c notStartedDOC = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Document', false);
    
    Enrollment_Component__c inprogressMSG = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Message', false);
    Enrollment_Component__c inprogressMSG2 = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Message', false);
    Enrollment_Component__c notStartedMSG = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Message', false);
  
    Enrollment_Component__c inprogressQuestion = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
    Enrollment_Component__c notStartedQuestion = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);

    componentList.add(processComponent);
    componentList.add(inprogressSTAGE);
    componentList.add(inprogressFORM);
    componentList.add(inprogressDOC);
    componentList.add(inprogressDOC2);
    componentList.add(inprogressMSG);
    componentList.add(inprogressMSG2);
    componentList.add(inprogressQuestion);
    componentList.add(notStartedSTAGE);
    componentList.add(notstartedFORM);
    componentList.add(notStartedDOC);
    componentList.add(notStartedMSG);
    componentList.add(notStartedQuestion);
    insert componentList;


    // MAP PROCESSID > STAGES > FORMS > DOCTYPES
    // in-progress stage mappings... 
    Enrollment_Component_Relationship__c processToStageInprogressECR = Peak_TestUtils.createEnrollmentComponentRelationship(inprogressSTAGE.Id, processComponent.Id);
    Enrollment_Component_Relationship__c stageToformInprogressECR = Peak_TestUtils.createEnrollmentComponentRelationship(inprogressFORM.Id, inprogressSTAGE.Id);
    Enrollment_Component_Relationship__c docToformInprogressECR = Peak_TestUtils.createEnrollmentComponentRelationship(inprogressDOC.Id, inprogressFORM.Id);
    Enrollment_Component_Relationship__c doc2ToformInprogressECR = Peak_TestUtils.createEnrollmentComponentRelationship(inprogressDOC2.Id, inprogressFORM.Id);
    Enrollment_Component_Relationship__c msgToformInprogressECR = Peak_TestUtils.createEnrollmentComponentRelationship(inprogressMSG.Id, inprogressFORM.Id);
    Enrollment_Component_Relationship__c msg2ToformInprogressECR = Peak_TestUtils.createEnrollmentComponentRelationship(inprogressMSG2.Id, inprogressFORM.Id);
    Enrollment_Component_Relationship__c questionToformInprogressECR = Peak_TestUtils.createEnrollmentComponentRelationship(inprogressQuestion.Id, inprogressFORM.Id);
    // not started stage mappings...
    Enrollment_Component_Relationship__c processToStageNotStartedECR = Peak_TestUtils.createEnrollmentComponentRelationship(notStartedSTAGE.Id, processComponent.Id);
    Enrollment_Component_Relationship__c stageToformNotStartedECR = Peak_TestUtils.createEnrollmentComponentRelationship(notstartedFORM.Id, notStartedSTAGE.Id);
    Enrollment_Component_Relationship__c docToformNotStartedECR= Peak_TestUtils.createEnrollmentComponentRelationship(notStartedDOC.Id, notstartedFORM.Id);
    Enrollment_Component_Relationship__c doc2ToformNotStartedECR = Peak_TestUtils.createEnrollmentComponentRelationship(notStartedMSG.Id, notstartedFORM.Id);
    Enrollment_Component_Relationship__c msgToformNotStartedECR = Peak_TestUtils.createEnrollmentComponentRelationship(notStartedQuestion.Id, notstartedFORM.Id);
    

    // CREATE ECAs FOR THE STUD PE
        // STAGES, FORMS, DOC-TYPES
        // STAGE-1.STATUS = IN-PROGRESS
        // FORM-1.STATUS = IN-PROGRESS
        // DOC-TYPES = NOT STARTED
    
    // In-progress ECAs
    List<Enrollment_Component_Affiliation__c> ecaList = new List<Enrollment_Component_Affiliation__c>();
    Enrollment_Component_Affiliation__c inprogressECASTAGE = Peak_TestUtils.createEnrollmentComponentAffiliation(studentPE.Id, inprogressSTAGE.Id, false);
    inprogressECASTAGE.Status__c = 'In Progress';
    Enrollment_Component_Affiliation__c inprogressECAFORM = Peak_TestUtils.createEnrollmentComponentAffiliation(studentPE.Id, inprogressFORM.Id, false);
    inprogressECAFORM.Status__c = 'In Progress';
    Enrollment_Component_Affiliation__c inprogressECADOC = Peak_TestUtils.createEnrollmentComponentAffiliation(studentPE.Id, inprogressDOC.Id, false);
    inprogressECADOC.Status__c = 'Not Started'; // test candidate2...
    Enrollment_Component_Affiliation__c inprogressECADOC2 = Peak_TestUtils.createEnrollmentComponentAffiliation(studentPE.Id, inprogressDOC2.Id, false);
    inprogressECADOC2.Status__c = 'Not Started'; // test candidate...
    Enrollment_Component_Affiliation__c inprogressECAMSG = Peak_TestUtils.createEnrollmentComponentAffiliation(studentPE.Id, inprogressMSG.Id, false);
    inprogressECAMSG.Status__c = 'Not Started';
    Enrollment_Component_Affiliation__c inprogressECAMSG2 = Peak_TestUtils.createEnrollmentComponentAffiliation(studentPE.Id, inprogressMSG2.Id, false);
    inprogressECAMSG2.Status__c = 'In Progress';
    Enrollment_Component_Affiliation__c inprogressECAQuestion = Peak_TestUtils.createEnrollmentComponentAffiliation(studentPE.Id, inprogressQuestion.Id, false);
    inprogressECAQuestion.Status__c = 'Not Started';
    ecaList.add(inprogressECASTAGE);
    ecaList.add(inprogressECAFORM);
    ecaList.add(inprogressECADOC);
    ecaList.add(inprogressECADOC2);
    ecaList.add(inprogressECAMSG);
    ecaList.add(inprogressECAMSG2);
    ecaList.add(inprogressECAQuestion);

    // Not-Started ECAs
    Enrollment_Component_Affiliation__c notStartedECASTAGE = Peak_TestUtils.createEnrollmentComponentAffiliation(studentPE.Id, notStartedSTAGE.Id, false);
    inprogressECASTAGE.Status__c = 'Not Started';
    Enrollment_Component_Affiliation__c notStartedECAFORM = Peak_TestUtils.createEnrollmentComponentAffiliation(studentPE.Id, notstartedFORM.Id, false);
    inprogressECASTAGE.Status__c = 'Not Started';
    Enrollment_Component_Affiliation__c notStartedECADOC = Peak_TestUtils.createEnrollmentComponentAffiliation(studentPE.Id, notStartedDOC.Id, false);
    inprogressECASTAGE.Status__c = 'Not Started';
    Enrollment_Component_Affiliation__c notStartedECAMSG = Peak_TestUtils.createEnrollmentComponentAffiliation(studentPE.Id, notStartedMSG.Id, false);
    inprogressECASTAGE.Status__c = 'Not Started';
    Enrollment_Component_Affiliation__c notStartedECAQuestion = Peak_TestUtils.createEnrollmentComponentAffiliation(studentPE.Id, notStartedQuestion.Id, false);
    inprogressECASTAGE.Status__c = 'Not Started';
    ecaList.add(notStartedECASTAGE);
    ecaList.add(notStartedECAFORM);
    ecaList.add(notStartedECADOC);
    ecaList.add(notStartedECAMSG);
    ecaList.add(notStartedECAQuestion);
    insert ecaList;



    // CREATE ED WITH UPLOADER==CARETAKER
    List<Enrollment_Document__c> edList = new List<Enrollment_Document__c>();
    Enrollment_Document__c submittedPORED = Peak_TestUtils.createEnrollmentDocumentRecord(studentPE.Id, 'Proof of Residence', 'Submitted', false);
    submittedPORED.uploader__c = careTakerContact.CreatedById;
    Enrollment_Document__c receivedImmRecED = Peak_TestUtils.createEnrollmentDocumentRecord(studentPE.Id, 'Immunization Records', 'Submitted', false);
    submittedPORED.uploader__c = careTakerContact.CreatedById;
    edList.add(submittedPORED);
    edList.add(receivedImmRecED);
    insert edList;
    
    /**
     * How to tie Pe to CareTaker ? 
        and how to tie studPE to careTaker ? 
        and how to link houseHold to the studPE ? 
        A: Just linking the CT as UPloader should  suffice ? 

         Parent Account 
            \
            Academic Account
                \ 

        Household Account
            \
            CareTaker Contact < - > User
     */
      
  }

      /**
    * Created by Anushka on 20/11/18.
    * Purpose : This method is a Test method for getDocumentsList method of NES_DocumentCentralController class.
    **/  
    static testMethod void getDocumentsListTest() {
            
        hed__Program_Enrollment__c progEnrollments = [Select id,hed__Contact__r.CreatedById from hed__Program_Enrollment__c  limit 1 ]; 
        System.debug('::progEnrollments::'+ JSON.serialize(progEnrollments));

        System.debug('::ECAs::Start::');
        for (Enrollment_Component_Affiliation__c eca : [Select Id, Status__c, Enrollment_Component__r.Name, Enrollment_Component__r.RecordTypeId, 
        Enrollment_Component__r.RecordType.Name from Enrollment_Component_Affiliation__c where Program_Enrollment__c = :progEnrollments.Id]) 
        {
          System.Debug(JSON.serialize(eca));
        }
        System.debug('::ECAs::End::');

      
        
        // Enrollment_Document__c acceptedDoc = Peak_TestUtils.createEnrollmentDocument(progEnrollments.Id, Peak_TestConstants.TEST_ENROLLMENT_DOC_STATUS_REASON_VERIFIED);
        // Enrollment_Document__c needsAttentionDoc = Peak_TestUtils.createEnrollmentDocument(progEnrollments.Id, Peak_TestConstants.TEST_ENROLLMENT_DOC_STATUS_REASON_INVALID);
        // Enrollment_Document__c UnderReviewDoc = Peak_TestUtils.createEnrollmentDocument(progEnrollments.Id, Peak_TestConstants.TEST_ENROLLMENT_DOC_STATUS_REASON_INVALID);
    
        Test.startTest();

        String result = NES_DocumentCentralController.getDocumentsList(progEnrollments.hed__Contact__r.CreatedById);
        // String result2 = NES_DocumentCentralController.getDocumentsList(UnderReviewDoc.Uploader__c);
        // System.assertNotEquals(result, null);
        Test.stopTest();
    }
}